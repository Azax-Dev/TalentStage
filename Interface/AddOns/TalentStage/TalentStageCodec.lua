-- TalentStageCodec: build-code import/export, compatible with octowow.st's
-- talent calculator (github.com/Haaxor1689/talent-builder, GPL-3.0-only).
--
-- This is an independent Lua reimplementation of the scheme, not a port of
-- their TypeScript source (GPL would obligate re-licensing this addon under
-- GPL too; understanding-then-reimplementing keeps our own license clean).
--
-- IMPORTANT: the scheme implemented here is NOT the same as what currently
-- ships in the talent-builder GitHub repo's src/components/calculator/utils.ts
-- (that version trims trailing zeros before packing). It was reverse
-- engineered from the actual minified bundle served live at octowow.st
-- (page-ce9cdb06bf9c66c9.js, module 8106) on 2026-08-22/23, and verified
-- byte-for-byte against it: the worked example "RI-DgJI-AQ" decodes to
-- Assassination 4/47 (2/3,1/2,1/5), Combat 10/54 (3/5,4/5,1/5,1/3,1/5),
-- Subtlety 2/47 (2/2) -- exactly matching a real octowow.st screenshot -- and
-- a 200-case round-trip fuzz test against the live bundle's own encode/decode
-- functions (Node) produced zero mismatches against this exact algorithm
-- before it was transcribed into Lua.
--
-- Scheme, per tree (fixed 7 tiers x 4 columns = 28 slots, index = (tier-1)*4
-- + (column-1)): each rank (0-7) -> 3-bit binary, concatenated to an 84-bit
-- string, chunked into <=8-bit pieces (last piece is 4 bits, NOT zero-padded
-- -- this is a real quirk of the deployed encoder, reproduced deliberately
-- for compatibility), each piece parsed as an integer byte, base64-encoded
-- (standard alphabet), the encoder's own trailing '=' padding character
-- dropped unconditionally, then any trailing run of 'A' characters (base64
-- for an all-zero sextet) stripped. The 3 tree segments are joined with '-'.
-- Decode reverses this, padding each segment back out to 14 base64
-- characters with 'A' before decoding (matching the site's own decoder,
-- including its one known edge case: a segment that would naturally still be
-- 15 characters long after stripping -- i.e. a tree with no trailing zero
-- slots at all, unreachable with real vanilla talent data since no real
-- build spends every single one of the 28 grid slots -- decodes the tail
-- incorrectly, same as the live site does).
--
-- No bitwise operators are used anywhere below: vanilla Lua 5.0 has none.
-- Every step is plain integer arithmetic (math.mod/math.floor), matching a
-- pure-arithmetic mirror of this same algorithm that was verified in Python
-- against the real bundle before this file was written.

TalentStageCodec = {}
local TSC = TalentStageCodec

TSC.SLOTS = 28 -- 7 tiers x 4 columns, fixed for all real WoW talent trees

local B64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local B64_INDEX = {}
for i = 1, string.len(B64_CHARS) do
	B64_INDEX[string.sub(B64_CHARS, i, i)] = i - 1
end

--------------------------------------------------------------------------
-- Bit-string helpers (binary text, MSB first -- no bitwise ops available)
--------------------------------------------------------------------------

local function toBinary(v, width)
	local bits = {}
	local n = v
	for i = 1, width do
		bits[width - i + 1] = math.mod(n, 2)
		n = math.floor(n / 2)
	end
	return table.concat(bits)
end

local function binToInt(s)
	local n = 0
	for i = 1, string.len(s) do
		local c = string.sub(s, i, i)
		n = n * 2 + (c == "1" and 1 or 0)
	end
	return n
end

--------------------------------------------------------------------------
-- Base64 (standard alphabet, matches JS btoa/atob byte-for-byte)
--------------------------------------------------------------------------

-- bytes: array (1-indexed) of integers 0-255. Always emits '=' padding,
-- exactly like JS btoa -- callers that need the padding-stripped form strip
-- it themselves (see PackTree), matching the real encoder's own two-step
-- slice(0,-1) + trailing-'A' strip.
function TSC.Base64Encode(bytes)
	local out = {}
	local n = table.getn(bytes)
	local i = 1
	while i <= n do
		local b1, b2, b3 = bytes[i], bytes[i + 1], bytes[i + 2]
		if b2 and b3 then
			local n24 = b1 * 65536 + b2 * 256 + b3
			table.insert(out, string.sub(B64_CHARS, math.floor(n24 / 262144) + 1, math.floor(n24 / 262144) + 1))
			table.insert(out, string.sub(B64_CHARS, math.mod(math.floor(n24 / 4096), 64) + 1, math.mod(math.floor(n24 / 4096), 64) + 1))
			table.insert(out, string.sub(B64_CHARS, math.mod(math.floor(n24 / 64), 64) + 1, math.mod(math.floor(n24 / 64), 64) + 1))
			table.insert(out, string.sub(B64_CHARS, math.mod(n24, 64) + 1, math.mod(n24, 64) + 1))
		elseif b2 then
			local n24 = b1 * 65536 + b2 * 256
			table.insert(out, string.sub(B64_CHARS, math.floor(n24 / 262144) + 1, math.floor(n24 / 262144) + 1))
			table.insert(out, string.sub(B64_CHARS, math.mod(math.floor(n24 / 4096), 64) + 1, math.mod(math.floor(n24 / 4096), 64) + 1))
			table.insert(out, string.sub(B64_CHARS, math.mod(math.floor(n24 / 64), 64) + 1, math.mod(math.floor(n24 / 64), 64) + 1))
			table.insert(out, "=")
		else
			local n24 = b1 * 65536
			table.insert(out, string.sub(B64_CHARS, math.floor(n24 / 262144) + 1, math.floor(n24 / 262144) + 1))
			table.insert(out, string.sub(B64_CHARS, math.mod(math.floor(n24 / 4096), 64) + 1, math.mod(math.floor(n24 / 4096), 64) + 1))
			table.insert(out, "=")
			table.insert(out, "=")
		end
		i = i + 3
	end
	return table.concat(out)
end

-- Lenient like browser atob on unpadded input: a dangling 2- or 3-character
-- final group is decoded as a partial byte instead of erroring, matching how
-- the real decode() feeds a padEnd(14, "A")'d (not '='-padded) string in.
function TSC.Base64Decode(str)
	local bytes = {}
	local len = string.len(str)
	local i = 1
	while i <= len do
		local remaining = len - i + 1
		if remaining >= 4 then
			local c1 = B64_INDEX[string.sub(str, i, i)] or 0
			local c2 = B64_INDEX[string.sub(str, i + 1, i + 1)] or 0
			local c3 = B64_INDEX[string.sub(str, i + 2, i + 2)] or 0
			local c4 = B64_INDEX[string.sub(str, i + 3, i + 3)] or 0
			local n24 = c1 * 262144 + c2 * 4096 + c3 * 64 + c4
			table.insert(bytes, math.floor(n24 / 65536))
			table.insert(bytes, math.mod(math.floor(n24 / 256), 256))
			table.insert(bytes, math.mod(n24, 256))
			i = i + 4
		elseif remaining == 3 then
			local c1 = B64_INDEX[string.sub(str, i, i)] or 0
			local c2 = B64_INDEX[string.sub(str, i + 1, i + 1)] or 0
			local c3 = B64_INDEX[string.sub(str, i + 2, i + 2)] or 0
			local n18 = c1 * 4096 + c2 * 64 + c3
			table.insert(bytes, math.floor(n18 / 1024))
			table.insert(bytes, math.mod(math.floor(n18 / 4), 256))
			i = i + 3
		elseif remaining == 2 then
			local c1 = B64_INDEX[string.sub(str, i, i)] or 0
			local c2 = B64_INDEX[string.sub(str, i + 1, i + 1)] or 0
			local n12 = c1 * 64 + c2
			table.insert(bytes, math.floor(n12 / 16))
			i = i + 2
		else
			i = i + 1 -- stray trailing char, ignore
		end
	end
	return bytes
end

--------------------------------------------------------------------------
-- Per-tree pack/unpack
--------------------------------------------------------------------------

-- ranks: table keyed 1..28 (or sparse; missing = 0), each value the rank
-- (0-7) at grid slot (tier-1)*4+(column-1)+1.
function TSC.PackTree(ranks)
	local bitParts = {}
	for i = 1, TSC.SLOTS do
		bitParts[i] = toBinary(ranks[i] or 0, 3)
	end
	local allBits = table.concat(bitParts)

	local byteValues = {}
	local pos = 1
	local len = string.len(allBits)
	while pos <= len do
		local chunkLen = 8
		if pos + chunkLen - 1 > len then chunkLen = len - pos + 1 end
		table.insert(byteValues, binToInt(string.sub(allBits, pos, pos + chunkLen - 1)))
		pos = pos + chunkLen
	end

	local b64 = TSC.Base64Encode(byteValues)
	b64 = string.sub(b64, 1, string.len(b64) - 1) -- drop the one trailing '=' (always present: 11 bytes % 3 == 2)

	while string.len(b64) > 0 and string.sub(b64, -1) == "A" do
		b64 = string.sub(b64, 1, string.len(b64) - 1)
	end
	return b64
end

function TSC.UnpackTree(segment)
	local ranks = {}
	if not segment or segment == "" then
		for i = 1, TSC.SLOTS do ranks[i] = 0 end
		return ranks
	end

	local padded = segment
	while string.len(padded) < 14 do
		padded = padded .. "A"
	end

	local byteValues = TSC.Base64Decode(padded)
	local bitParts = {}
	for i = 1, table.getn(byteValues) do
		bitParts[i] = toBinary(byteValues[i], 8)
	end
	local allBits = table.concat(bitParts)

	local pos = 1
	local len = string.len(allBits)
	local idx = 1
	while pos + 2 <= len and idx <= TSC.SLOTS do
		ranks[idx] = binToInt(string.sub(allBits, pos, pos + 2))
		idx = idx + 1
		pos = pos + 3
	end
	while idx <= TSC.SLOTS do
		ranks[idx] = 0
		idx = idx + 1
	end
	return ranks
end

--------------------------------------------------------------------------
-- Public API: 3-tree code <-> three 28-slot rank tables
--------------------------------------------------------------------------

function TSC.Encode(tree1, tree2, tree3)
	return TSC.PackTree(tree1) .. "-" .. TSC.PackTree(tree2) .. "-" .. TSC.PackTree(tree3)
end

-- Returns tree1, tree2, tree3 (each a 28-slot table) on success, or nil plus
-- an error string on malformed input. Only the current "points=<code>"
-- scheme is supported -- the site's legacy "t=<digits>-<digits>-<digits>" /
-- "c=<classMask>" query params (old-format shared links, single-digit-per-
-- talent, no base64) are not decoded here; this addon only needs to round-
-- trip codes it itself can also produce.
function TSC.Decode(code)
	if not code or code == "" then
		local z1, z2, z3 = {}, {}, {}
		for i = 1, TSC.SLOTS do z1[i], z2[i], z3[i] = 0, 0, 0 end
		return z1, z2, z3
	end

	local segs = {}
	local start = 1
	while true do
		local dashPos = string.find(code, "-", start, true)
		if not dashPos then
			table.insert(segs, string.sub(code, start))
			break
		end
		table.insert(segs, string.sub(code, start, dashPos - 1))
		start = dashPos + 1
	end

	if table.getn(segs) ~= 3 then
		return nil, "Invalid build code format"
	end

	return TSC.UnpackTree(segs[1]), TSC.UnpackTree(segs[2]), TSC.UnpackTree(segs[3])
end

--------------------------------------------------------------------------
-- Slot <-> tier/column conversion, matching octowow.st's flat indexing
-- (confirmed from talent-builder's schema: talents are keyed by flat index
-- with no separate tier/column field, so position is entirely implied by
-- index over a fixed rows(7) x 4 grid).
--------------------------------------------------------------------------

-- 1-indexed slot (1..28) for a 1-indexed (tier, column) pair, tier 1-7,
-- column 1-4 -- the same convention GetTalentInfo already returns.
function TSC.SlotForTierColumn(tier, column)
	return (tier - 1) * 4 + (column - 1) + 1
end

function TSC.TierColumnForSlot(slot)
	local zeroBased = slot - 1
	local tier = math.floor(zeroBased / 4) + 1
	local column = math.mod(zeroBased, 4) + 1
	return tier, column
end
