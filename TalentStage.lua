-- TalentStage: standalone redesigned talent UI, phase 1.
-- Targets the Blizzard_TalentUI namespace only insofar as it never touches it:
-- this addon owns its own frame identity (TalentStageFrame, TalentStagePanelN,
-- TalentStageButtonN_M) and never references TalentFrame / TalentFrame_Toggle,
-- so the stock frame is simply never shown. See CLAUDE.md "Frame identity and
-- skin-hook safety".

TalentStage = {}
local TS = TalentStage

-- [ Layout constants ]
TS.BUTTON_SIZE     = 32
TS.COL_SPACING     = 58
TS.TIER_SPACING    = 58
TS.PANEL_PAD       = 24
TS.PANEL_BOTTOM_PAD = 18
TS.HEADER_HEIGHT   = 62
TS.TREE_GAP        = 28
TS.MARGIN          = 16
TS.TITLE_HEIGHT    = 40
TS.IMPORT_ROW_HEIGHT = 30
TS.LEDGER_HEIGHT   = 68
TS.QUEUE_FALLBACK_DELAY = 1.0 -- seconds; LearnTalent has a short server-side
                               -- delay between calls, this is a safety net in
                               -- case TALENT_UPDATE never fires for a call.

-- [ Tree background art: dev test, Rogue only ]
-- One shared texture per class, tab N reads a 1/numTabs horizontal slice via
-- SetTexCoord -- mirrors the rogue-talent-redesign-v3-treebg.html demo's
-- background-position trick instead of shipping one cropped file per tree.
-- Source art is a Gemini generation (docs/Rogue/rogue3.jpeg), resized to
-- 768x512 (3 panels of 256x512) then padded onto a 1024x512 canvas --
-- vanilla's texture loader needs power-of-two dimensions, and confirmed
-- in-game that anything as large as 2048x1024 silently fails to load on
-- this client even though it's p-o-t; 1024x512 is the first size that
-- actually rendered. Real content only fills the left 0.75 of the
-- texture's u range; the remaining 0.25 is transparent padding. Saved as
-- an uncompressed 32-bit TGA (this client build reads .tga fine -- pfUI
-- and ElvUI both ship them). Not wired for any other class yet; see
-- CLAUDE.md backlog note on theming.
--
-- User-facing toggle/opacity now live in TalentStageOptionsDB (SavedVariables,
-- per-character), set via the gear button on the main frame -- see
-- TalentStage_LoadTreeArtOptions / TalentStage_BuildTreeArtSettings.
TS.TREE_ART_OPTION_DEFAULTS = { showTreeArt = true, treeArtAlpha = 0.35 }
TS.TREE_BG_TEXTURES = {
	ROGUE = {
		[1] = { 0.00, 0.25, 0, 1 }, -- Assassination: left panel
		[2] = { 0.25, 0.50, 0, 1 }, -- Combat: middle panel
		[3] = { 0.50, 0.75, 0, 1 }, -- Subtlety: right panel
	},
}

TS.PLAIN_BACKDROP = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 11, right = 12, top = 12, bottom = 11 },
}

-- lighter-weight boxed backdrop for each individual tree panel, so the three
-- trees read as distinct grouped panels instead of icons floating loose on
-- the outer dialog background
TS.PANEL_BACKDROP = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4 },
}

-- lightweight backdrop for the import/export text field
TS.INPUT_BACKDROP = {
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 8, edgeSize = 8,
	insets = { left = 2, right = 2, top = 2, bottom = 2 },
}

-- thin border-only backdrop applied directly to each talent button, so tile
-- state (locked/available/staged/confirmed) reads as a colored ring around
-- the icon, matching the mockup's tile treatment. No bgFile: the icon
-- texture already fills the button, this only draws the edge on top of it.
TS.TILE_BACKDROP = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 8,
}

-- Palette lifted from the rogue-talent-redesign-v2.html mockup (see CLAUDE.md
-- "Design reference"). Generic, not per-tree-colored: the mockup uses
-- per-tree accent colors (red/orange/blue) that only make sense for a
-- Rogue's three specific trees, but this addon runs against any class's
-- tabs, so every tree shares one gold accent instead.
TS.COLOR = {
	bgVoid       = { 0.063, 0.047, 0.035 },
	panel        = { 0.133, 0.106, 0.078 },
	panel2       = { 0.102, 0.078, 0.059 },
	edge         = { 0.290, 0.227, 0.141 },
	edgeBright   = { 0.541, 0.416, 0.208 },
	gold         = { 0.851, 0.663, 0.310 },
	goldBright   = { 0.953, 0.804, 0.494 },
	parchment    = { 0.851, 0.788, 0.639 },
	muted        = { 0.553, 0.498, 0.408 },
	lockedBg     = { 0.133, 0.110, 0.086 },
	lockedEdge   = { 0.235, 0.204, 0.153 },
	lockedIcon   = { 0.329, 0.298, 0.231 },
	pending      = { 0.949, 0.839, 0.459 },
}

TS.POLL_INTERVAL = 0.5 -- seconds; periodic safety-net refresh while the
                        -- panel is visible, so applied points always
                        -- converge to the real server state even if
                        -- TALENT_UPDATE is ever late or missed

-- [ State ]
TS.built = false
TS.panels = {}          -- panels[tab] = panel frame
TS.staged = {}           -- staged[tab][talentIndex] = pending rank count
TS.queue = {}            -- confirm queue, list of {tab=, idx=}
TS.processing = false
TS.nextAllowed = 0
TS.inFlight = nil       -- {tab=, idx=} of the queue entry currently awaiting
                        -- server confirmation, so its staged point stays
                        -- displayed until it's actually landed
TS.confirmedButtons = {} -- confirmedButtons[tab][idx] = true; buttons settled
                        -- during the current confirm run, flashed together
                        -- (with one sound) once the whole queue drains
TS.queueTotal = 0      -- size of the current confirm run, for the "Applying
                        -- X of Y" ledger progress text
TS.queueDone = 0        -- points settled so far in the current confirm run

-- Dev/sandbox mode: confirm runs go through the exact same queue/settle/
-- flash/progress-bar code path as a real confirm, but never call LearnTalent
-- and never touch real character state, so the UI can be tested without
-- spending (or paying to respec) real talent points. sandboxConfirmed is a
-- purely cosmetic overlay of "confirmed" points layered on top of the real
-- GetTalentInfo rank, mirroring how staged points are already layered on.
-- Character level -> total talent points, matching the classic "1 point per
-- level starting at 10" formula, capped at level 60 (51 points).
TS.SANDBOX_LEVEL_CAPS = { 10, 20, 30, 40, 50, 60 }

TS.sandboxMode = false
TS.sandboxLevelCap = nil -- nil = unlimited (999) sandbox points; otherwise one of
                        -- TS.SANDBOX_LEVEL_CAPS, and available points is capped
                        -- to what a character of that level would actually have
TS.sandboxConfirmed = {} -- sandboxConfirmed[tab][idx] = fake-confirmed rank count
TS.CONFIRM_FLASH_DURATION = 0.5
TS.TIER_FLASH_DURATION = 0.6
TS.tierUnlockState = {} -- tierUnlockState[tab][tier] = last known IsTierUnlocked
                        -- result, so Refresh can detect a locked<->unlocked
                        -- transition and flash the whole row once, instead of
                        -- the color just snapping between grey and lit.
TS.prereqMetState = {}  -- prereqMetState[tab][idx] = last known TalentStage_PrereqsMet
                        -- result, so a line-connected talent (e.g. Riposte)
                        -- can flash on its own when its specific prereq
                        -- (Deflection) fills/unfills, independent of whether
                        -- the tier itself unlocks or locks.

--------------------------------------------------------------------------
-- Frame lifecycle
--------------------------------------------------------------------------

function TalentStageFrame_OnLoad()
	this:RegisterForDrag("LeftButton")
	this:RegisterEvent("TALENT_UPDATE")
	this:RegisterEvent("CHARACTER_POINTS_CHANGED")
end

function TalentStageFrame_OnEvent()
	if event == "TALENT_UPDATE" then
		if TS.processing then
			TalentStage_ProcessQueue()
		end
		if TalentStageFrame:IsVisible() then
			TalentStage_Refresh()
		end
	elseif event == "CHARACTER_POINTS_CHANGED" then
		if TalentStageFrame:IsVisible() then
			TalentStage_UpdateLedger()
		end
	end
end

function TalentStageFrame_OnShow()
	if not TS.built then
		TalentStage_BuildUI()
	end
	TalentStage_Refresh()
	PlaySound("TalentScreenOpen")
end

function TalentStageFrame_OnHide()
	-- staged points intentionally persist across hide/show so the player can
	-- close and reopen without losing an in-progress plan.
	PlaySound("TalentScreenClose")
	if TS.artSettingsPanel and TS.artSettingsPanel:IsVisible() then
		TS.artSettingsPanel:Hide()
	end
end

-- A persistent ticker independent of frame visibility: OnUpdate does not fire
-- on hidden frames, but a confirm queue must keep advancing (via its fallback
-- timer) even if the player closes the window mid-confirm.
TS.ticker = CreateFrame("Frame")
TS.ticker:SetScript("OnUpdate", function()
	if TS.processing and GetTime() >= TS.nextAllowed then
		TalentStage_ProcessQueue()
	end

	if TS.built and TalentStageFrame:IsVisible() then
		TS.pollElapsed = (TS.pollElapsed or 0) + arg1
		if TS.pollElapsed >= TS.POLL_INTERVAL then
			TS.pollElapsed = 0
			TalentStage_Refresh()
		end
	end
end)

-- Standard vanilla mechanism for making a custom frame close on Escape: the
-- default UI's escape handler walks this global name list and Hides
-- whichever ones are currently shown. Registering by name works even though
-- TalentStageFrame doesn't exist yet at this point in file load.
tinsert(UISpecialFrames, "TalentStageFrame")

--------------------------------------------------------------------------
-- Hook the talent panel open path.
-- Confirmed from Interface\FrameXML\MainMenuBarMicroButtons.xml: the micro
-- button's OnClick and the default "N" keybinding (TOGGLETALENTS) both just
-- call the global ToggleTalentFrame(). Overriding that one global function
-- covers both entry points without touching Blizzard_TalentUI at all.
--------------------------------------------------------------------------

function ToggleTalentFrame()
	if UnitLevel("player") < 10 then
		return
	end
	if TalentStageFrame:IsVisible() then
		TalentStageFrame:Hide()
	else
		TalentStageFrame:Show()
	end
end

--------------------------------------------------------------------------
-- UI construction (built once, on first show)
--------------------------------------------------------------------------

function TalentStage_ApplyPlainBackdrop(frame, alpha, bg, border)
	bg = bg or TS.COLOR.bgVoid
	border = border or TS.COLOR.edgeBright
	frame:SetBackdrop(TS.PLAIN_BACKDROP)
	frame:SetBackdropColor(bg[1], bg[2], bg[3], alpha or 1)
	frame:SetBackdropBorderColor(border[1], border[2], border[3], 1)
end

function TalentStage_BuildUI()
	TS.built = true
	TalentStage_LoadTreeArtOptions()

	local numTabs = GetNumTalentTabs()
	local totalWidth = TS.MARGIN
	local maxPanelHeight = 0

	for tab = 1, numTabs do
		local numTalents = GetNumTalents(tab)
		local maxTier, maxCol = 1, 1
		local nodes = {}
		local info = {}

		for idx = 1, numTalents do
			local name, icon, tier, column, rank, maxRank = GetTalentInfo(tab, idx)
			-- guard against degenerate/placeholder entries (tier or column
			-- < 1): building a button for one anchors it above row 1, inside
			-- the header band, and registers it as a real prereq node that
			-- connectors can be drawn to/from with no visible button there
			if tier and column and tier >= 1 and column >= 1 then
				info[idx] = { name = name, icon = icon, tier = tier, column = column, rank = rank, maxRank = maxRank }
				if tier > maxTier then maxTier = tier end
				if column > maxCol then maxCol = column end
				if not nodes[tier] then nodes[tier] = {} end
				nodes[tier][column] = idx
			end
		end

		local panelWidth = maxCol * TS.COL_SPACING + TS.PANEL_PAD
		local panelHeight = TS.HEADER_HEIGHT + maxTier * TS.TIER_SPACING + TS.PANEL_BOTTOM_PAD

		local panel = CreateFrame("Frame", "TalentStagePanel"..tab, TalentStageFrame)
		panel:SetWidth(panelWidth)
		panel:SetHeight(panelHeight)
		panel:SetPoint("TOPLEFT", TalentStageFrame, "TOPLEFT", totalWidth, -(TS.TITLE_HEIGHT + TS.IMPORT_ROW_HEIGHT))

		panel:SetBackdrop(TS.PANEL_BACKDROP)
		panel:SetBackdropColor(TS.COLOR.panel2[1], TS.COLOR.panel2[2], TS.COLOR.panel2[3], 0.85)
		panel:SetBackdropBorderColor(TS.COLOR.edgeBright[1], TS.COLOR.edgeBright[2], TS.COLOR.edgeBright[3], 1)

		do
			local _, engClass = UnitClass("player")
			local bgCoords = TS.TREE_BG_TEXTURES[engClass] and TS.TREE_BG_TEXTURES[engClass][tab]
			if bgCoords then
				-- BACKGROUND, not ARTWORK: the panel's own backdrop border
				-- (set below via SetBackdropBorderColor) draws on the BORDER
				-- layer, which sits above ARTWORK -- an ARTWORK-layer texture
				-- at any real opacity painted straight over that border.
				local bg = panel:CreateTexture(nil, "BACKGROUND")
				bg:SetAllPoints(panel)
				bg:SetTexture("Interface\\AddOns\\TalentStage\\Art\\TreeBG_"..engClass..".tga")
				bg:SetTexCoord(bgCoords[1], bgCoords[2], bgCoords[3], bgCoords[4])
				bg:SetAlpha(TalentStageOptionsDB.treeArtAlpha)
				if not TalentStageOptionsDB.showTreeArt then
					bg:Hide()
				end
				panel.bgTexture = bg
			end
		end

		local header = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
		header:SetPoint("TOP", panel, "TOP", 0, -8)
		header:SetTextColor(TS.COLOR.parchment[1], TS.COLOR.parchment[2], TS.COLOR.parchment[3])
		do
			local fontPath, fontSize, fontFlags = header:GetFont()
			header:SetFont(fontPath, fontSize + 5, fontFlags)
		end
		panel.header = header

		local pointsText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		pointsText:SetPoint("TOP", header, "BOTTOM", 0, -3)
		do
			local fontPath, fontSize, fontFlags = pointsText:GetFont()
			pointsText:SetFont(fontPath, fontSize + 3, fontFlags)
		end
		panel.pointsText = pointsText

		-- connector layer sits behind the buttons, one frame per tree so we
		-- can wipe/redraw it without touching sibling trees.
		local connectorLayer = CreateFrame("Frame", nil, panel)
		connectorLayer:SetAllPoints(panel)
		panel.connectorLayer = connectorLayer
		panel.connectorTextures = {}
		panel.connectorCount = 0

		panel.nodes = nodes
		panel.info = info
		panel.buttons = {}
		panel.tab = tab

		for idx = 1, numTalents do
			local d = info[idx]
			if d then
				local btn = CreateFrame("Button", "TalentStageButton"..tab.."_"..idx, panel)
				btn:SetWidth(TS.BUTTON_SIZE)
				btn:SetHeight(TS.BUTTON_SIZE)

				local px = (d.column - 1) * TS.COL_SPACING + TS.PANEL_PAD
				local py = -((d.tier - 1) * TS.TIER_SPACING) - TS.HEADER_HEIGHT
				btn:SetPoint("TOPLEFT", panel, "TOPLEFT", px, py)
				d.px, d.py = px, py

				btn:SetBackdrop(TS.TILE_BACKDROP)
				btn:SetBackdropBorderColor(TS.COLOR.edge[1], TS.COLOR.edge[2], TS.COLOR.edge[3], 1)

				local iconTex = btn:CreateTexture(nil, "ARTWORK")
				iconTex:SetAllPoints(btn)
				iconTex:SetTexture(d.icon)
				iconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				btn.icon = iconTex

				btn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

				local glow = btn:CreateTexture(nil, "OVERLAY")
				glow:SetPoint("TOPLEFT", btn, "TOPLEFT", -4, 4)
				glow:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 4, -4)
				glow:SetTexture("Interface\\Buttons\\CheckButtonHilight")
				glow:SetBlendMode("ADD")
				glow:SetAlpha(0)
				btn.glow = glow

				local rankText = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
				rankText:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -2, 2)
				btn.rankText = rankText

				btn.tab = tab
				btn.talentIndex = idx
				btn:SetID(idx)
				btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
				btn:SetScript("OnClick", TalentStage_TalentButton_OnClick)
				btn:SetScript("OnEnter", TalentStage_TalentButton_OnEnter)
				btn:SetScript("OnLeave", TalentStage_TalentButton_OnLeave)
				btn:SetScript("OnUpdate", TalentStage_TalentButton_OnUpdate)

				panel.buttons[idx] = btn
			end
		end

		TS.panels[tab] = panel
		totalWidth = totalWidth + panelWidth + TS.TREE_GAP
		if panelHeight > maxPanelHeight then maxPanelHeight = panelHeight end
	end

	-- totalWidth carries one trailing TS.TREE_GAP added after the last panel
	-- (the loop above adds it unconditionally each iteration); drop it here
	-- so the frame ends at the last tree plus a plain right-side margin,
	-- instead of a full tree-gap-sized gap plus that margin stacked together.
	local totalHeight = TS.TITLE_HEIGHT + TS.IMPORT_ROW_HEIGHT + maxPanelHeight + TS.LEDGER_HEIGHT
	TalentStageFrame:SetWidth(totalWidth - TS.TREE_GAP + TS.MARGIN)
	TalentStageFrame:SetHeight(totalHeight)

	TalentStage_ApplyPlainBackdrop(TalentStageFrame, 0.92)

	local title = TalentStageFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", TalentStageFrame, "TOP", 0, -24)
	title:SetTextColor(TS.COLOR.goldBright[1], TS.COLOR.goldBright[2], TS.COLOR.goldBright[3])
	title:SetText("Talent Stage")
	TalentStageFrame.title = title

	TalentStage_BuildImportRow()
	TalentStage_BuildLedger()
	TalentStage_BuildSettings()
	TalentStage_BuildTreeArtSettings()
end

--------------------------------------------------------------------------
-- Import/export row: matches the rogue-talent-redesign-v2.html mockup's
-- always-visible row above the trees. Build codes use the octowow.st talent
-- calculator's own scheme (see TalentStageCodec.lua for the reverse-
-- engineering notes and compatibility caveats) so a code copied from either
-- tool works in the other.
--------------------------------------------------------------------------

-- Percent-decodes a query-string value. Deliberately does NOT turn '+' into
-- a space (the usual application/x-www-form-urlencoded convention): '+' is a
-- meaningful base64 character in these codes, and a well-formed octowow.st
-- link already percent-encodes any literal '+' as %2B, so leaving bare '+'
-- alone is correct for both a pasted URL and a pasted bare code.
local function TalentStage_UrlDecode(s)
	return (string.gsub(s, "%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end))
end

-- Accepts either a bare build code or a full octowow.st URL (any query
-- param order/extras) and returns the bare code plus the class slug from the
-- URL path, if one was present (nil for a bare code -- there's nothing to
-- extract it from).
function TalentStage_ExtractImportCode(input)
	input = string.gsub(input, "^%s*(.-)%s*$", "%1")
	local _, _, raw = string.find(input, "points=([^&]*)")
	if not raw then
		return input, nil
	end
	local _, _, slug = string.find(input, "/talents/(%a+)/")
	return TalentStage_UrlDecode(raw), slug
end

function TalentStage_BuildExportCode()
	local trees = {}
	for tab = 1, 3 do
		local ranks = {}
		for i = 1, TalentStageCodec.SLOTS do ranks[i] = 0 end
		local panel = TS.panels[tab]
		if panel then
			for idx, d in pairs(panel.info) do
				local slot = TalentStageCodec.SlotForTierColumn(d.tier, d.column)
				ranks[slot] = TalentStage_EffectiveRank(tab, idx, d.rank)
			end
		end
		trees[tab] = ranks
	end
	return TalentStageCodec.Encode(trees[1], trees[2], trees[3])
end

function TalentStage_BuildExportUrl(code)
	local _, engClass = UnitClass("player")
	local slug = string.lower(engClass or "class")
	return "https://octowow.st/talents/" .. slug .. "/?points=" .. code
end

function TalentStage_OnExportClick()
	local code = TalentStage_BuildExportCode()
	local url = TalentStage_BuildExportUrl(code)

	TS.importEditBox:SetText(url)
	TS.importEditBox:HighlightText()
	TS.importEditBox:SetFocus()
	if TS.importHint then TS.importHint:Hide() end
	if TS.importClearButton then TS.importClearButton:Show() end

	DEFAULT_CHAT_FRAME:AddMessage("TalentStage: build code - " .. code)
	DEFAULT_CHAT_FRAME:AddMessage("TalentStage: full link (also placed in the import/export box, ready to copy) - " .. url)
end

-- Only ever ADDS staged points on top of whatever's already actually spent
-- (real ranks, or -- in sandbox mode -- fake-confirmed ones): there's no way
-- to unstage/unlearn a real point outside of an actual in-game respec, so an
-- imported build that wants fewer points in a talent than the character
-- already has invested there simply can't be reflected for that talent.
-- Loops to a fixed point rather than a single pass so prereq/tier-unlock
-- ordering resolves itself regardless of which slot happens to be visited
-- first in an unordered pairs() walk.
function TalentStage_ImportBuild(code, slug)
	if TS.processing then
		DEFAULT_CHAT_FRAME:AddMessage("TalentStage: can't import while a confirm is in progress.")
		return
	end

	local t1, t2, t3, err = TalentStageCodec.Decode(code)
	if not t1 then
		DEFAULT_CHAT_FRAME:AddMessage("TalentStage: import failed - " .. (err or "invalid build code"))
		return
	end

	if slug then
		local _, engClass = UnitClass("player")
		if string.lower(slug) ~= string.lower(engClass or "") then
			DEFAULT_CHAT_FRAME:AddMessage("TalentStage: warning - this link is for " .. slug .. ", but you're playing " .. (engClass or "?") .. ". Importing anyway, but the tree layout won't match.")
		end
	end

	TS.staged = {}
	local trees = { t1, t2, t3 }

	local function targetFor(panel, idx, d, ranks)
		local slot = TalentStageCodec.SlotForTierColumn(d.tier, d.column)
		local target = ranks[slot] or 0
		if target > d.maxRank then target = d.maxRank end
		return target
	end

	local progressed = true
	while progressed do
		progressed = false
		for tab = 1, 3 do
			local panel = TS.panels[tab]
			local ranks = trees[tab]
			if panel and ranks then
				for idx, d in pairs(panel.info) do
					local target = targetFor(panel, idx, d, ranks)
					local effRank = TalentStage_EffectiveRank(tab, idx, d.rank)
					if effRank < target then
						local before = TalentStage_GetStaged(tab, idx)
						TalentStage_Stage(tab, idx, true)
						if TalentStage_GetStaged(tab, idx) > before then
							progressed = true
						end
					end
				end
			end
		end
	end

	local shortfall = 0
	for tab = 1, 3 do
		local panel = TS.panels[tab]
		local ranks = trees[tab]
		if panel and ranks then
			for idx, d in pairs(panel.info) do
				local target = targetFor(panel, idx, d, ranks)
				local effRank = TalentStage_EffectiveRank(tab, idx, d.rank)
				if effRank < target then
					shortfall = shortfall + (target - effRank)
				end
			end
		end
	end

	TalentStage_Refresh()
	if shortfall > 0 then
		DEFAULT_CHAT_FRAME:AddMessage("TalentStage: build imported, but " .. shortfall .. " point(s) couldn't be staged (not enough available points, or a prereq/tier already blocked by real spent points). Review the staged plan, then Confirm to apply what did stage.")
	else
		DEFAULT_CHAT_FRAME:AddMessage("TalentStage: build imported and staged. This replaced any previously staged (unconfirmed) points. Review, then Confirm to spend them.")
	end
end

-- Clicking anywhere on the panel background that isn't itself a mouse-
-- enabled child (talent buttons, the edit box, other buttons) bubbles up to
-- TalentStageFrame's own OnMouseDown -- used as a lightweight "click away"
-- to drop focus out of the import/export box.
function TalentStage_ClearImportFocus()
	if TS.importEditBox and TS.importEditBoxFocused then
		TS.importEditBox:ClearFocus()
	end
end

-- Catches clicks outside TalentStageFrame entirely (e.g. the game world,
-- empty screen space) so the import box also loses focus there, not just on
-- clicks within the panel. Full-screen and BACKGROUND-strata so any real UI
-- frame above it (action bars, minimap, TalentStageFrame itself) still gets
-- the click first -- this only ever sees clicks nothing else claimed. Only
-- enabled while the import box is actually focused, so it never interferes
-- with normal world clicks (camera turn, targeting) otherwise.
function TalentStage_ShowClickCatcher()
	if not TS.clickCatcher then
		local f = CreateFrame("Frame", "TalentStageClickCatcher", UIParent)
		f:SetFrameStrata("BACKGROUND")
		f:SetAllPoints(UIParent)
		f:EnableMouse(true)
		f:SetScript("OnMouseDown", function() TalentStage_ClearImportFocus() end)
		f:Hide()
		TS.clickCatcher = f
	end
	TS.clickCatcher:Show()
end

function TalentStage_HideClickCatcher()
	if TS.clickCatcher then
		TS.clickCatcher:Hide()
	end
end

function TalentStage_OnImportClick()
	local input = TS.importEditBox:GetText()
	if not input or input == "" then
		DEFAULT_CHAT_FRAME:AddMessage("TalentStage: paste a build code or octowow.st link into the box first.")
		return
	end
	local code, slug = TalentStage_ExtractImportCode(input)
	TalentStage_ImportBuild(code, slug)
end

function TalentStage_BuildImportRow()
	local row = CreateFrame("Frame", "TalentStageImportRow", TalentStageFrame)
	row:SetPoint("TOPLEFT", TalentStageFrame, "TOPLEFT", TS.MARGIN, -TS.TITLE_HEIGHT)
	row:SetPoint("TOPRIGHT", TalentStageFrame, "TOPRIGHT", -TS.MARGIN, -TS.TITLE_HEIGHT)
	row:SetHeight(TS.IMPORT_ROW_HEIGHT)

	local exportBtn = CreateFrame("Button", "TalentStageExportButton", row, "UIPanelButtonTemplate")
	exportBtn:SetWidth(70)
	exportBtn:SetHeight(22)
	exportBtn:SetPoint("RIGHT", row, "RIGHT", 0, -4)
	exportBtn:SetText("Export")
	exportBtn:SetScript("OnClick", TalentStage_OnExportClick)
	TS.exportButton = exportBtn

	local importBtn = CreateFrame("Button", "TalentStageImportButton", row, "UIPanelButtonTemplate")
	importBtn:SetWidth(70)
	importBtn:SetHeight(22)
	importBtn:SetPoint("RIGHT", exportBtn, "LEFT", -6, 0)
	importBtn:SetText("Import")
	importBtn:SetScript("OnClick", TalentStage_OnImportClick)
	TS.importButton = importBtn

	local editBg = CreateFrame("Frame", "TalentStageImportBox", row)
	editBg:SetPoint("LEFT", row, "LEFT", 0, -4)
	editBg:SetPoint("RIGHT", importBtn, "LEFT", -8, 0)
	editBg:SetHeight(22)
	editBg:SetBackdrop(TS.INPUT_BACKDROP)
	editBg:SetBackdropColor(TS.COLOR.panel2[1], TS.COLOR.panel2[2], TS.COLOR.panel2[3], 0.9)
	editBg:SetBackdropBorderColor(TS.COLOR.edgeBright[1], TS.COLOR.edgeBright[2], TS.COLOR.edgeBright[3], 1)

	local clearBtn = CreateFrame("Button", "TalentStageImportClearButton", editBg)
	clearBtn:SetWidth(14)
	clearBtn:SetHeight(14)
	clearBtn:SetPoint("RIGHT", editBg, "RIGHT", -6, 0)
	local clearText = clearBtn:CreateFontString(nil, "OVERLAY")
	clearText:SetFontObject(GameFontNormalSmall)
	clearText:SetAllPoints(clearBtn)
	clearText:SetJustifyH("CENTER")
	clearText:SetText("x")
	clearText:SetTextColor(TS.COLOR.parchment[1], TS.COLOR.parchment[2], TS.COLOR.parchment[3], 0.6)
	clearBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	TS.importClearButton = clearBtn

	local edit = CreateFrame("EditBox", "TalentStageImportEditBox", editBg)
	edit:SetAutoFocus(false)
	edit:SetFontObject(ChatFontNormal)
	edit:SetPoint("LEFT", editBg, "LEFT", 8, 0)
	edit:SetPoint("RIGHT", clearBtn, "LEFT", -4, 0)
	edit:SetHeight(18)
	edit:SetTextColor(TS.COLOR.parchment[1], TS.COLOR.parchment[2], TS.COLOR.parchment[3])
	edit:SetScript("OnEscapePressed", function() this:ClearFocus() end)
	-- vanilla 1.12's EditBox has no :HasFocus() (added WotLK+) -- track focus
	-- by hand so TalentStage_ClearImportFocus knows whether to call ClearFocus
	edit:SetScript("OnEditFocusGained", function()
		TS.importEditBoxFocused = true
		TalentStage_ShowClickCatcher()
	end)
	edit:SetScript("OnEditFocusLost", function()
		TS.importEditBoxFocused = false
		TalentStage_HideClickCatcher()
	end)
	TS.importEditBox = edit

	local hint = editBg:CreateFontString("TalentStageImportHint", "OVERLAY")
	hint:SetFontObject(ChatFontNormal)
	hint:SetPoint("LEFT", edit, "LEFT", 0, 0)
	hint:SetPoint("RIGHT", edit, "RIGHT", 0, 0)
	hint:SetJustifyH("LEFT")
	hint:SetTextColor(TS.COLOR.parchment[1], TS.COLOR.parchment[2], TS.COLOR.parchment[3], 0.45)
	hint:SetText("Paste a talent code or octowow.st link to import")
	TS.importHint = hint

	local function TalentStage_UpdateImportHint()
		if edit:GetText() == "" then
			hint:Show()
			clearBtn:Hide()
		else
			hint:Hide()
			clearBtn:Show()
		end
	end
	edit:SetScript("OnTextChanged", TalentStage_UpdateImportHint)
	clearBtn:SetScript("OnClick", function()
		edit:SetText("")
		edit:ClearFocus()
	end)
	TalentStage_UpdateImportHint()

	TS.importRow = row
end

--------------------------------------------------------------------------
-- Tree art settings: user-facing gear button (top-left of the main frame,
-- mirrors the close button's top-right placement) opening a small popup
-- with a "show spec art" checkbox and an opacity slider. Separate from the
-- dev-only sandbox settings panel below -- this one ships to real players.
--------------------------------------------------------------------------

function TalentStage_LoadTreeArtOptions()
	TalentStageOptionsDB = TalentStageOptionsDB or {}
	if TalentStageOptionsDB.showTreeArt == nil then
		TalentStageOptionsDB.showTreeArt = TS.TREE_ART_OPTION_DEFAULTS.showTreeArt
	end
	if TalentStageOptionsDB.treeArtAlpha == nil then
		TalentStageOptionsDB.treeArtAlpha = TS.TREE_ART_OPTION_DEFAULTS.treeArtAlpha
	end
end

-- Re-applies the current showTreeArt/treeArtAlpha settings to every already-
-- built tree panel's background texture, so the checkbox/slider update live
-- without needing to close and reopen the talent frame.
function TalentStage_ApplyTreeArtSettings()
	for tab, panel in pairs(TS.panels) do
		if panel.bgTexture then
			panel.bgTexture:SetAlpha(TalentStageOptionsDB.treeArtAlpha)
			if TalentStageOptionsDB.showTreeArt then
				panel.bgTexture:Show()
			else
				panel.bgTexture:Hide()
			end
		end
	end
end

function TalentStage_ToggleTreeArtSettingsPanel()
	if TS.artSettingsPanel:IsVisible() then
		TS.artSettingsPanel:Hide()
	else
		TS.artSettingsPanel:Show()
	end
end

function TalentStage_BuildTreeArtSettings()
	local gearBtn = CreateFrame("Button", "TalentStageArtSettingsButton", TalentStageFrame)
	gearBtn:SetWidth(20)
	gearBtn:SetHeight(20)
	gearBtn:SetPoint("TOPLEFT", TalentStageFrame, "TOPLEFT", TS.MARGIN - 4, -10)

	local icon = gearBtn:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints(gearBtn)
	-- INV_Misc_Gear_01: a plain gear/cog icon (confirmed present in this
	-- client's interface.MPQ) -- reads as a generic "settings" icon, unlike
	-- Trade_Engineering's busier workbench/goggles art.
	icon:SetTexture("Interface\\Icons\\INV_Misc_Gear_01")
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	gearBtn.icon = icon

	gearBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	gearBtn:SetScript("OnClick", TalentStage_ToggleTreeArtSettingsPanel)
	gearBtn:SetScript("OnEnter", function()
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText("Settings")
		GameTooltip:Show()
	end)
	gearBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
	TS.artSettingsButton = gearBtn

	local panel = CreateFrame("Frame", "TalentStageArtSettingsPanel", UIParent)
	panel:SetWidth(220)
	panel:SetHeight(120)
	panel:SetPoint("TOPRIGHT", TalentStageFrame, "TOPLEFT", -8, 0)
	panel:SetFrameStrata("DIALOG")
	panel:SetToplevel(true)
	panel:EnableMouse(true)
	TalentStage_ApplyPlainBackdrop(panel, 0.95)
	panel:Hide()
	TS.artSettingsPanel = panel
	-- Standard vanilla mechanism (see TalentStageFrame's own registration
	-- above) so Escape closes this panel like any other UI window.
	tinsert(UISpecialFrames, "TalentStageArtSettingsPanel")

	local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -2, -2)
	close:SetScript("OnClick", function() panel:Hide() end)

	local heading = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	heading:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -10)
	heading:SetText("Settings")

	-- First section: talent tree art. More sections (their own sub-heading
	-- plus controls) get added below this one as they're built, same panel.
	local sectionHeading = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	sectionHeading:SetPoint("TOPLEFT", panel, "TOPLEFT", 14, -30)
	sectionHeading:SetTextColor(TS.COLOR.parchment[1], TS.COLOR.parchment[2], TS.COLOR.parchment[3])
	sectionHeading:SetText("Talent Tree Art")

	local check = CreateFrame("CheckButton", "TalentStageArtSettingsCheck", panel, "UICheckButtonTemplate")
	check:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -48)
	getglobal("TalentStageArtSettingsCheckText"):SetText("Show spec art")
	check:SetScript("OnClick", function()
		TalentStageOptionsDB.showTreeArt = this:GetChecked() and true or false
		TalentStage_ApplyTreeArtSettings()
	end)
	TS.artSettingsCheck = check

	local slider = CreateFrame("Slider", "TalentStageArtSettingsSlider", panel, "OptionsSliderTemplate")
	slider:SetPoint("TOP", panel, "TOP", 0, -80)
	slider:SetWidth(190)
	slider:SetHeight(16)
	slider:SetMinMaxValues(0, 100)
	slider:SetValueStep(1)
	getglobal("TalentStageArtSettingsSliderLow"):SetText("0%")
	getglobal("TalentStageArtSettingsSliderHigh"):SetText("100%")
	getglobal("TalentStageArtSettingsSliderText"):SetText("Opacity")
	slider:SetScript("OnValueChanged", function()
		TalentStageOptionsDB.treeArtAlpha = this:GetValue() / 100
		TalentStage_ApplyTreeArtSettings()
	end)
	TS.artSettingsSlider = slider

	-- initialize widget states from the loaded DB (set after the OnValueChanged
	-- handler above so this initial sync also runs through it harmlessly)
	check:SetChecked(TalentStageOptionsDB.showTreeArt)
	slider:SetValue(TalentStageOptionsDB.treeArtAlpha * 100)
end

--------------------------------------------------------------------------
-- Dev panel: sandbox mode toggle only, reachable via "/ts dev" instead of
-- a visible gear icon on the main frame (see CLAUDE.md dev/release split
-- decision 2026-08-23) -- a slash command keeps the release and dev code
-- identical instead of exporting two addon copies.
--------------------------------------------------------------------------

function TalentStage_BuildSettings()
	-- parented to UIParent (not TalentStageFrame) and given its own toplevel
	-- strata so its size/position are never constrained by the talent frame's
	-- own (dynamic, often narrower-than-220) bounds
	local PAD = 12

	local panel = CreateFrame("Frame", "TalentStageSettingsPanel", UIParent)
	panel:SetWidth(230)
	panel:SetHeight(190)
	panel:SetPoint("CENTER", UIParent, "CENTER", -260, 0)
	panel:SetFrameStrata("DIALOG")
	panel:SetToplevel(true)
	panel:EnableMouse(true)
	panel:SetMovable(true)
	panel:RegisterForDrag("LeftButton")
	panel:SetScript("OnDragStart", function() this:StartMoving() end)
	panel:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
	TalentStage_ApplyPlainBackdrop(panel, 0.95)
	panel:Hide()
	TS.settingsPanel = panel

	local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -4, -4)
	close:SetScript("OnClick", function() panel:Hide() end)

	local heading = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	heading:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD, -10)
	heading:SetText("Dev settings")

	local sandboxCheck = CreateFrame("CheckButton", "TalentStageSandboxCheck", panel, "UICheckButtonTemplate")
	sandboxCheck:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD - 4, -28)
	getglobal("TalentStageSandboxCheckText"):SetText("Sandbox mode (dev)")
	sandboxCheck:SetScript("OnClick", TalentStage_ToggleSandboxMode)
	TS.sandboxCheck = sandboxCheck

	local capLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	capLabel:SetPoint("TOPLEFT", panel, "TOPLEFT", PAD, -66)
	capLabel:SetTextColor(TS.COLOR.parchment[1], TS.COLOR.parchment[2], TS.COLOR.parchment[3])
	capLabel:SetText("Point cap (unchecked = unlimited)")

	-- Level-cap ladder: mutually-exclusive checkboxes, one per 10 levels, so
	-- sandbox testing can be limited to what a character of that level would
	-- actually have (level - 9 points, classic's 1-point-per-level-from-10
	-- formula) instead of always getting the unlimited 999. Laid out as an
	-- explicit 3x2 grid (rather than computed via mod/floor, which older Lua
	-- 5.0 clients handle inconsistently) so the six boxes stay evenly spaced.
	local rows = { { 10, 20, 30 }, { 40, 50, 60 } }
	local colWidth = 62
	local rowHeight = 24
	TS.sandboxLevelChecks = {}
	for r = 1, table.getn(rows) do
		local rowLevels = rows[r]
		for c = 1, table.getn(rowLevels) do
			local lvl = rowLevels[c]
			local name = "TalentStageSandboxLevelCheck"..lvl
			local check = CreateFrame("CheckButton", name, panel, "UICheckButtonTemplate")
			check:SetWidth(18)
			check:SetHeight(18)
			check:SetPoint("TOPLEFT", panel, "TOPLEFT", (PAD - 4) + (c - 1) * colWidth, -86 - (r - 1) * rowHeight)
			local label = getglobal(name.."Text")
			label:SetFontObject(GameFontHighlightSmall)
			label:SetText(tostring(lvl))
			check.sandboxLevel = lvl
			check:SetScript("OnClick", TalentStage_SelectSandboxLevelCap)
			TS.sandboxLevelChecks[lvl] = check
		end
	end

	local resetBtn = CreateFrame("Button", "TalentStageSandboxResetButton", panel, "UIPanelButtonTemplate")
	resetBtn:SetWidth(190)
	resetBtn:SetHeight(26)
	resetBtn:SetPoint("TOP", panel, "TOP", 0, -148)
	resetBtn:SetText("Reset sandbox talents")
	resetBtn:SetScript("OnClick", TalentStage_ResetSandbox)
	TS.sandboxResetButton = resetBtn
end

function TalentStage_ToggleSettingsPanel()
	if TS.settingsPanel:IsVisible() then
		TS.settingsPanel:Hide()
	else
		TS.settingsPanel:Show()
	end
end

function TalentStage_ToggleSandboxMode()
	if TS.processing then
		-- don't let the mode flip mid-confirm-run, the in-flight entries
		-- were queued under the old mode
		this:SetChecked(not this:GetChecked())
		return
	end
	TS.sandboxMode = this:GetChecked() and true or false
	-- entering or leaving sandbox mode always starts from a clean fake
	-- state -- there's no meaningful way to carry fake-confirmed points
	-- across the boundary with real character state
	TalentStage_ResetSandbox()
end

-- Level-cap checkboxes act as a radio group (Blizzard's CheckButton has no
-- native radio behavior): clicking one clears the others, and re-clicking
-- the currently-checked one drops back to unlimited (999).
function TalentStage_SelectSandboxLevelCap()
	if TS.processing then
		-- don't let the cap change mid-confirm-run, the in-flight entries
		-- were queued under the old cap
		this:SetChecked(not this:GetChecked())
		return
	end
	local lvl = this.sandboxLevel
	local checked = this:GetChecked() and true or false
	for otherLvl, check in pairs(TS.sandboxLevelChecks) do
		if otherLvl ~= lvl then check:SetChecked(false) end
	end
	TS.sandboxLevelCap = checked and lvl or nil
	TalentStage_ResetSandbox()
end

function TalentStage_ResetSandbox()
	if TS.processing then return end
	TS.sandboxConfirmed = {}
	-- also drop any staged-but-unconfirmed picks: "reset" means a fully
	-- blank tree, not just undoing confirmed fake points
	TS.staged = {}
	TalentStage_Refresh()
end

function TalentStage_BuildLedger()
	local bar = CreateFrame("Frame", "TalentStageLedger", TalentStageFrame)
	bar:SetPoint("BOTTOMLEFT", TalentStageFrame, "BOTTOMLEFT", TS.MARGIN, TS.MARGIN)
	bar:SetPoint("BOTTOMRIGHT", TalentStageFrame, "BOTTOMRIGHT", -TS.MARGIN, TS.MARGIN)
	bar:SetHeight(TS.LEDGER_HEIGHT - TS.MARGIN)
	-- Same tin/tooltip-style box as the tree panels and import field, not the
	-- Blizzard dialog-frame backdrop -- only TalentStageFrame itself (the
	-- outer panel) uses TS.PLAIN_BACKDROP now.
	bar:SetBackdrop(TS.PANEL_BACKDROP)
	bar:SetBackdropColor(TS.COLOR.panel2[1], TS.COLOR.panel2[2], TS.COLOR.panel2[3], 0.85)
	bar:SetBackdropBorderColor(TS.COLOR.edgeBright[1], TS.COLOR.edgeBright[2], TS.COLOR.edgeBright[3], 1)

	local text = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	text:SetPoint("LEFT", bar, "LEFT", 16, 0)
	text:SetTextColor(TS.COLOR.parchment[1], TS.COLOR.parchment[2], TS.COLOR.parchment[3])
	TS.ledgerText = text

	-- Progress label sits on its own line above the track (reference's
	-- .progress-label), not centered on top of a full-height fill -- kept
	-- separate from `text` above since the two states (staged/unspent vs.
	-- applying-N-of-M) never show at the same time but use different anchors.
	local progressLabel = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	progressLabel:SetPoint("TOPLEFT", bar, "TOPLEFT", 16, -10)
	progressLabel:SetTextColor(TS.COLOR.goldBright[1], TS.COLOR.goldBright[2], TS.COLOR.goldBright[3])
	progressLabel:Hide()
	TS.progressLabel = progressLabel

	local confirmBtn = CreateFrame("Button", "TalentStageConfirmButton", bar, "UIPanelButtonTemplate")
	confirmBtn:SetWidth(90)
	confirmBtn:SetHeight(22)
	confirmBtn:SetPoint("RIGHT", bar, "RIGHT", -16, 0)
	confirmBtn:SetText("Confirm")
	confirmBtn:SetScript("OnClick", TalentStage_ConfirmStaged)
	TS.confirmButton = confirmBtn

	local clearBtn = CreateFrame("Button", "TalentStageClearButton", bar, "UIPanelButtonTemplate")
	clearBtn:SetWidth(90)
	clearBtn:SetHeight(22)
	clearBtn:SetPoint("RIGHT", confirmBtn, "LEFT", -6, 0)
	clearBtn:SetText("Clear")
	clearBtn:SetScript("OnClick", TalentStage_ClearStaged)
	TS.clearButton = clearBtn

	-- Thin track (reference's .progress-track: 8px tall, inset dark bg, thin
	-- border) sitting below progressLabel, not a full-height fill behind the
	-- text -- that was the earlier bug (spilled past the frame's own bottom
	-- border because the fill was as tall as the whole footer). Clear/Confirm
	-- are hidden while this shows (they're inert anyway, TS.processing blocks
	-- their handlers), so the label+track pair fits in the same box those
	-- buttons normally occupy, well within the footer's existing bounds.
	-- No SetBackdrop here: TS.PANEL_BACKDROP's edgeSize (16) and insets (4)
	-- are sized for normal-height panels, and on an 8px track the corner/edge
	-- art overlaps itself at each end and reads as a solid vertical strip.
	-- Built instead from plain WHITE8X8 textures (background + 1px border),
	-- same technique the connector lines already use -- no template sized for
	-- full-height frames involved.
	local track = CreateFrame("Frame", nil, bar)
	track:SetPoint("TOPLEFT", bar, "TOPLEFT", 16, -28)
	track:SetPoint("RIGHT", bar, "RIGHT", -16, 0)
	track:SetHeight(8)
	track:Hide()
	TS.progressBg = track

	local trackBg = track:CreateTexture(nil, "BACKGROUND")
	trackBg:SetAllPoints(track)
	trackBg:SetTexture("Interface\\Buttons\\WHITE8X8")
	trackBg:SetVertexColor(TS.COLOR.lockedBg[1], TS.COLOR.lockedBg[2], TS.COLOR.lockedBg[3], 0.9)

	local function trackBorderLine(point1, relPoint1, x1, y1, point2, relPoint2, x2, y2)
		local line = track:CreateTexture(nil, "BORDER")
		line:SetTexture("Interface\\Buttons\\WHITE8X8")
		line:SetVertexColor(TS.COLOR.edgeBright[1], TS.COLOR.edgeBright[2], TS.COLOR.edgeBright[3], 1)
		line:SetPoint(point1, track, relPoint1, x1, y1)
		line:SetPoint(point2, track, relPoint2, x2, y2)
		return line
	end
	trackBorderLine("TOPLEFT", "TOPLEFT", 0, 0, "TOPRIGHT", "TOPRIGHT", 0, 0):SetHeight(1)
	trackBorderLine("BOTTOMLEFT", "BOTTOMLEFT", 0, 0, "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0):SetHeight(1)
	trackBorderLine("TOPLEFT", "TOPLEFT", 0, 0, "BOTTOMLEFT", "BOTTOMLEFT", 0, 0):SetWidth(1)
	trackBorderLine("TOPRIGHT", "TOPRIGHT", 0, 0, "BOTTOMRIGHT", "BOTTOMRIGHT", 0, 0):SetWidth(1)

	-- Plain flat color, not a themed statusbar asset (e.g. UI-StatusBar) --
	-- avoids any baked-in end-cap art rendering regardless of fill width.
	local progressFill = track:CreateTexture(nil, "ARTWORK")
	progressFill:SetPoint("TOPLEFT", track, "TOPLEFT", 1, -1)
	progressFill:SetPoint("BOTTOMLEFT", track, "BOTTOMLEFT", 1, 1)
	progressFill:SetTexture("Interface\\Buttons\\WHITE8X8")
	progressFill:SetVertexColor(TS.COLOR.gold[1], TS.COLOR.gold[2], TS.COLOR.gold[3])
	progressFill:SetWidth(1)
	TS.progressFill = progressFill
	TS.progressBarWidth = function() return track:GetWidth() - 2 end
end

--------------------------------------------------------------------------
-- Data refresh
--------------------------------------------------------------------------

function TalentStage_GetStaged(tab, idx)
	local list = TS.staged[tab]
	if not list then return 0 end
	return list[idx] or 0
end

function TalentStage_GetSandboxConfirmed(tab, idx)
	local list = TS.sandboxConfirmed[tab]
	if not list then return 0 end
	return list[idx] or 0
end

-- Sandbox mode simulates testing from a blank tree, not your real character's
-- invested points: the real rank/points-spent must never leak into any
-- effective-rank math while it's on, or tier gates / prereqs / the available-
-- points cap would still be constrained by talents you actually have.
function TalentStage_BaseRank(rank)
	if TS.sandboxMode then return 0 end
	return rank or 0
end

function TalentStage_GetAvailablePoints()
	if TS.sandboxMode then
		if TS.sandboxLevelCap then return TS.sandboxLevelCap - 9 end
		return 999
	end
	return UnitCharacterPoints("player")
end

-- effRank for a talent node: real rank (unless sandboxed away) + staged +
-- sandbox-confirmed. Central so Stage/Refresh/PrereqsMet never drift.
function TalentStage_EffectiveRank(tab, idx, rank)
	return TalentStage_BaseRank(rank) + TalentStage_GetStaged(tab, idx) + TalentStage_GetSandboxConfirmed(tab, idx)
end

function TalentStage_GetTotalStaged()
	local total = 0
	for tab, list in pairs(TS.staged) do
		for idx, n in pairs(list) do
			total = total + n
		end
	end
	return total
end

function TalentStage_GetEffectiveSpent(tab)
	local pointsSpent = 0
	if not TS.sandboxMode then
		local name, texture, realSpent = GetTalentTabInfo(tab)
		pointsSpent = realSpent or 0
	end
	local stagedTotal = 0
	local list = TS.staged[tab]
	if list then
		for idx, n in pairs(list) do
			stagedTotal = stagedTotal + n
		end
	end
	local sandboxTotal = 0
	local sList = TS.sandboxConfirmed[tab]
	if sList then
		for idx, n in pairs(sList) do
			sandboxTotal = sandboxTotal + n
		end
	end
	return pointsSpent + stagedTotal + sandboxTotal
end

-- Points spent strictly in tiers below `tier` -- NOT TalentStage_GetEffectiveSpent,
-- which sums the whole tab including the tier being checked (and beyond). A
-- point already sitting in this tier must never count toward unlocking this
-- same tier: in the real game that can't happen (rows can only be filled
-- top-down, so by the time a row has a point, the threshold below it is
-- already independently met), but this addon's stage/unstage lets the player
-- unstage an earlier row out of order, and total-based counting let that
-- row's own already-staged point prop up its own unlock check -- one point
-- short of the real threshold below it still read as "unlocked".
function TalentStage_GetEffectiveSpentBelowTier(tab, tier)
	local panel = TS.panels[tab]
	if not panel then return 0 end
	local total = 0
	for idx, d in pairs(panel.info) do
		if d.tier < tier then
			total = total + TalentStage_EffectiveRank(tab, idx, d.rank)
		end
	end
	return total
end

function TalentStage_IsTierUnlocked(tab, tier)
	if tier <= 1 then return true end
	return (tier - 1) * 5 <= TalentStage_GetEffectiveSpentBelowTier(tab, tier)
end

-- GetTalentPrereqs returns a flat vararg of (tier, column, isLearnable)
-- triples. We recompute "met" ourselves from tier/column looked up against
-- our own node table, rather than trusting the isLearnable flag, because
-- that flag reflects only the server's actual current ranks -- it can't know
-- about points we've staged locally but not confirmed yet.
function TalentStage_PrereqsMet(tab, idx)
	local panel = TS.panels[tab]
	local args = { GetTalentPrereqs(tab, idx) }
	local n = table.getn(args)
	if n == 0 then return true end

	for i = 1, n, 3 do
		local ptier = args[i]
		local pcol = args[i + 1]
		local prow = panel.nodes[ptier]
		local pidx = prow and prow[pcol]
		if pidx then
			local d = panel.info[pidx]
			local effRank = TalentStage_EffectiveRank(tab, pidx, d.rank)
			-- a prereq line requires the source talent maxed out, not just a
			-- single point in it -- e.g. Deflection (5 ranks) -> Riposte
			if effRank < d.maxRank then
				return false
			end
		end
	end
	return true
end

-- A confirmed point's staged count must be dropped the instant the real rank
-- catches up to it, not just when a TALENT_UPDATE event happens to arrive:
-- the poll ticker (TS.POLL_INTERVAL) calls TalentStage_Refresh() on its own
-- schedule too, and if it runs after the server has applied the point but
-- before the matching TALENT_UPDATE has been handled here, realRank+staged
-- double-counts that point (shows one rank too high, then drops back once
-- the event/fallback finally decrements staged). Checking here, from every
-- refresh path, keeps that window from ever being observed.
function TalentStage_SettleInFlight()
	local e = TS.inFlight
	if not e then return end

	if e.sandbox then
		-- no server round-trip to wait on: settle once the same fallback
		-- delay used for real confirms has elapsed, so the sandbox run
		-- paces itself identically to a real one
		if GetTime() < TS.nextAllowed then return end
	else
		local _, _, _, _, rank = GetTalentInfo(e.tab, e.idx)
		if not rank or rank <= e.priorRank then return end
	end

	local staged = TalentStage_GetStaged(e.tab, e.idx)
	if staged > 0 then
		TS.staged[e.tab][e.idx] = staged - 1
	end
	if e.sandbox then
		if not TS.sandboxConfirmed[e.tab] then
			TS.sandboxConfirmed[e.tab] = {}
		end
		TS.sandboxConfirmed[e.tab][e.idx] = TalentStage_GetSandboxConfirmed(e.tab, e.idx) + 1
	end
	TS.inFlight = nil
	TS.queueDone = TS.queueDone + 1

	-- Don't flash/play the fanfare per point: a multi-point confirm run
	-- (one talent at 5/5, or several talents at once) fires this once per
	-- LearnTalent call. Record the button and defer the actual flash+sound
	-- until TalentStage_ProcessQueue drains the whole run, so every button
	-- touched this run flashes together with a single sound.
	if not TS.confirmedButtons[e.tab] then
		TS.confirmedButtons[e.tab] = {}
	end
	TS.confirmedButtons[e.tab][e.idx] = true
end

function TalentStage_Refresh()
	if not TS.built then return end

	TalentStage_SettleInFlight()

	for tab, panel in pairs(TS.panels) do
		local name, texture, pointsSpent = GetTalentTabInfo(tab)
		panel.header:SetText(name or "")

		local stagedInTab = 0
		local list = TS.staged[tab]
		if list then
			for _, n in pairs(list) do
				stagedInTab = stagedInTab + n
			end
		end
		pointsSpent = TS.sandboxMode and 0 or (pointsSpent or 0)
		local sList = TS.sandboxConfirmed[tab]
		if sList then
			for _, n in pairs(sList) do
				pointsSpent = pointsSpent + n
			end
		end
		if stagedInTab > 0 then
			panel.pointsText:SetText(pointsSpent.." +"..stagedInTab.." points")
			panel.pointsText:SetTextColor(1, 0.82, 0)
		else
			panel.pointsText:SetText(pointsSpent.." points")
			panel.pointsText:SetTextColor(0.8, 0.8, 0.8)
		end

		local pointsLeft = TalentStage_GetAvailablePoints() - TalentStage_GetTotalStaged()

		-- Refresh rank/maxRank for every node up front so both flash passes
		-- below (tier and prereq) see this refresh's live data rather than
		-- whatever was left over from the previous one.
		for idx, d in pairs(panel.info) do
			local _, _, _, _, rank, maxRank = GetTalentInfo(tab, idx)
			d.rank, d.maxRank = rank, maxRank
		end

		-- Detect a row's lock state flipping since the last refresh and flash
		-- every button in that row once: gold on unlock, red on re-lock (it
		-- still ends up grey either way once the flash decays -- the static
		-- lit/grey color below is unaffected by this, it's a one-shot overlay
		-- on top). Skipped on this tab's very first refresh (prev == nil) so
		-- opening the panel doesn't flash every already-unlocked row.
		--
		-- A tier unlocking does NOT by itself make a line-gated talent (e.g.
		-- Riposte) available, so it only flashes gold for row members whose
		-- own prereq is already independently met. A tier re-locking, though,
		-- always flashes the whole row red -- every talent in it just became
		-- unavailable regardless of its own prereq state.
		if not TS.tierUnlockState[tab] then TS.tierUnlockState[tab] = {} end
		local tierState = TS.tierUnlockState[tab]
		for tier, row in pairs(panel.nodes) do
			local unlocked = TalentStage_IsTierUnlocked(tab, tier)
			local prev = tierState[tier]
			if prev ~= nil and prev ~= unlocked then
				for _, rowIdx in pairs(row) do
					if unlocked and not TalentStage_PrereqsMet(tab, rowIdx) then
						-- skip: tier opened up, but this talent's own line
						-- prereq still isn't filled, so it's still locked
					else
						local r, g, b
						if unlocked then r, g, b = 1, 0.85, 0.1 else r, g, b = 0.9, 0.15, 0.15 end
						local rowBtn = panel.buttons[rowIdx]
						if rowBtn then
							rowBtn.tierFlashElapsed = 0
							rowBtn.tierFlashColor = { r, g, b }
						end
					end
				end
			end
			tierState[tier] = unlocked
		end

		-- Independent of the tier flash above: a line-connected talent's own
		-- prereq can fill/unfill (e.g. staging/unstaging Deflection) while
		-- its tier stays unlocked the whole time. Flash it on its own so
		-- that transition is visible even when no tier boundary is crossed.
		if not TS.prereqMetState[tab] then TS.prereqMetState[tab] = {} end
		local prereqState = TS.prereqMetState[tab]
		for idx, btn in pairs(panel.buttons) do
			local met = TalentStage_PrereqsMet(tab, idx)
			local prev = prereqState[idx]
			local d = panel.info[idx]
			if prev ~= nil and prev ~= met and TalentStage_IsTierUnlocked(tab, d.tier) then
				local r, g, b
				if met then r, g, b = 1, 0.85, 0.1 else r, g, b = 0.9, 0.15, 0.15 end
				btn.tierFlashElapsed = 0
				btn.tierFlashColor = { r, g, b }
			end
			prereqState[idx] = met
		end

		for idx, btn in pairs(panel.buttons) do
			local d = panel.info[idx]
			local tier, rank, maxRank = d.tier, d.rank, d.maxRank

			local effRank = TalentStage_EffectiveRank(tab, idx, rank)
			btn.rankText:SetText(effRank .. "/" .. maxRank)

			local tierUnlocked = TalentStage_IsTierUnlocked(tab, tier)
			local prereqsMet = TalentStage_PrereqsMet(tab, idx)
			-- lit up (full color) only if it's actually learnable right now:
			-- unlocked/prereqs met, and either already has a real invested
			-- rank or there's an unspent point available to put into it.
			-- Otherwise -- e.g. tier-1 talents in every tree when the player
			-- has 0 unspent points -- it should read as grey, not falsely
			-- inviting a click that Stage() would just reject.
			local lit = tierUnlocked and prereqsMet and (effRank > 0 or pointsLeft > 0)
			local usable = lit and effRank < maxRank
			local staged = TalentStage_GetStaged(tab, idx)

			if lit then
				btn.icon:SetVertexColor(1, 1, 1)
			else
				btn.icon:SetVertexColor(0.4, 0.4, 0.4)
			end

			if effRank > 0 then
				btn.rankText:SetTextColor(1, 0.82, 0)
			else
				btn.rankText:SetTextColor(0.6, 0.6, 0.6)
			end

			-- tile border color by state, matching the mockup's
			-- locked/available/staged/confirmed tile treatment
			local border
			if not tierUnlocked or not prereqsMet then
				border = TS.COLOR.lockedEdge
			elseif staged > 0 then
				border = TS.COLOR.pending
			elseif effRank > 0 then
				border = TS.COLOR.gold
			else
				border = TS.COLOR.edge
			end
			btn:SetBackdropBorderColor(border[1], border[2], border[3], 1)

			btn.stagedGlow = staged > 0
			-- maxed-rank talents get a static soft gold glow (mockup's maxed-
			-- tile box-shadow); staging always takes visual priority over it
			-- since it's the more actionable state
			btn.maxedGlow = (not btn.stagedGlow) and effRank > 0 and effRank >= maxRank
			if btn.maxedGlow then
				btn.glow:SetVertexColor(TS.COLOR.gold[1], TS.COLOR.gold[2], TS.COLOR.gold[3])
				btn.glow:SetAlpha(0.28)
			elseif not btn.stagedGlow and not btn.confirmFlashElapsed and not btn.tierFlashElapsed then
				btn.glow:SetVertexColor(1, 1, 1)
				btn.glow:SetAlpha(0)
			end
		end

		TalentStage_DrawConnectors(panel)
	end

	TalentStage_UpdateLedger()
end

function TalentStage_UpdateLedger()
	local total = TalentStage_GetTotalStaged()
	local available = TalentStage_GetAvailablePoints()

	if TS.processing and TS.queueTotal > 1 then
		-- +1: the in-flight point counts as "being applied", not "done" yet
		local applying = TS.queueDone + 1
		if applying > TS.queueTotal then applying = TS.queueTotal end

		local name = ""
		if TS.inFlight then
			local panel = TS.panels[TS.inFlight.tab]
			local d = panel and panel.info[TS.inFlight.idx]
			name = d and d.name or ""
		end
		if name ~= "" then
			TS.progressLabel:SetText("Applying "..applying.." of "..TS.queueTotal.." -- "..name)
		else
			TS.progressLabel:SetText("Applying "..applying.." of "..TS.queueTotal.."...")
		end

		local frac = applying / TS.queueTotal
		local fullWidth = TS.progressBarWidth()
		local w = fullWidth * frac
		if w < 1 then w = 1 end
		TS.progressFill:SetWidth(w)

		-- label+track replace the staged/unspent text and the Clear/Confirm
		-- buttons while a confirm run is draining, so that space stays doing
		-- something useful instead of showing two disabled buttons
		TS.ledgerText:Hide()
		TS.confirmButton:Hide()
		TS.clearButton:Hide()
		TS.progressLabel:Show()
		TS.progressBg:Show()
	elseif TS.processing then
		-- a single-point confirm settles in one round trip -- a progress bar
		-- for a queue of 1 has nothing meaningful to animate, so just say so
		TS.ledgerText:SetText("Applying...")
		TS.ledgerText:SetTextColor(TS.COLOR.parchment[1], TS.COLOR.parchment[2], TS.COLOR.parchment[3])
		TS.ledgerText:Show()
		TS.confirmButton:Hide()
		TS.clearButton:Hide()
		TS.progressLabel:Hide()
		TS.progressBg:Hide()
	else
		TS.ledgerText:SetText("Staged: "..total.."   Unspent: "..(available - total).." / "..available)
		TS.ledgerText:SetTextColor(TS.COLOR.parchment[1], TS.COLOR.parchment[2], TS.COLOR.parchment[3])
		TS.ledgerText:Show()
		TS.progressLabel:Hide()
		TS.progressBg:Hide()
		TS.confirmButton:Show()
		TS.clearButton:Show()
	end

	if total > 0 and not TS.processing then
		TS.confirmButton:Enable()
		TS.clearButton:Enable()
	else
		TS.confirmButton:Disable()
		TS.clearButton:Disable()
	end
end

--------------------------------------------------------------------------
-- Prereq connectors: stitched straight-line texture segments positioned by
-- the same tier/column pixel math used to place the talent buttons, mirroring
-- Blizzard_TalentUI's TalentFrame_SetBranchTexture approach (real texture
-- pieces, not a vector Line widget). Phase 1 uses a plain solid color instead
-- of the stock branch-art atlas.
--------------------------------------------------------------------------

function TalentStage_GetConnectorTexture(panel)
	panel.connectorCount = panel.connectorCount + 1
	local tex = panel.connectorTextures[panel.connectorCount]
	if not tex then
		tex = panel.connectorLayer:CreateTexture(nil, "BACKGROUND")
		tex:SetTexture("Interface\\Buttons\\WHITE8X8")
		panel.connectorTextures[panel.connectorCount] = tex
	end
	tex:Show()
	return tex
end

-- Snap to whole pixels. Bilinear filtering on WHITE8X8 smears any edge that
-- lands on a fractional pixel into a soft blur -- most visible on the small
-- arrowhead bars, since a half-pixel offset is a bigger fraction of an 8px
-- (or smaller) segment than of a long connector line.
local function TalentStage_Snap(v)
	if v < 0 then
		return -(math.floor(-v + 0.5))
	end
	return math.floor(v + 0.5)
end

function TalentStage_DrawSegment(panel, x, y, w, h, r, g, b)
	if w < 0 then x = x + w; w = -w end
	if h < 0 then y = y - h; h = -h end
	if w < 2 then w = 2 end
	if h < 2 then h = 2 end
	x = TalentStage_Snap(x)
	y = TalentStage_Snap(y)
	w = TalentStage_Snap(w)
	h = TalentStage_Snap(h)

	local tex = TalentStage_GetConnectorTexture(panel)
	tex:ClearAllPoints()
	tex:SetPoint("TOPLEFT", panel.connectorLayer, "TOPLEFT", x, y)
	tex:SetWidth(w)
	tex:SetHeight(h)
	tex:SetVertexColor(r, g, b, 1)
end

-- Small square dot centered at (cx, cy), same texture pool as the line
-- segments -- the mockup's connector joints are circles, but there's no round
-- texture readily at hand in this client, and a small square reads close
-- enough at this size. cy is in the same top-left-origin, y-more-negative-
-- going-down space as everything else here, so the top-left corner is
-- cy + half (moving "up"/less negative by half the dot's size).
function TalentStage_DrawJoint(panel, cx, cy, size, r, g, b)
	local half = size / 2
	TalentStage_DrawSegment(panel, cx - half, cy + half, size, size, r, g, b)
end

local TS_JOINT_SIZE = 6

-- Arrowheads: no native texture rotation in this client, so these are faked
-- as a stepped taper of solid bars (wide -> narrow), same WHITE8X8 technique
-- as everything else here. Only ever used at the dependent (arrival) end of
-- a connector, pointing in the direction the line actually arrives from, so
-- the two ends of a connector read differently (source dot vs. arrival
-- arrow) instead of two identical dots.
local TS_ARROW_SIZES = { 8, 5, 2 }

-- tipY: the y-coordinate the arrow points at (touches the dependent talent).
function TalentStage_DrawArrowDown(panel, cx, tipY, r, g, b)
	for i = 1, table.getn(TS_ARROW_SIZES) do
		local w = TS_ARROW_SIZES[i]
		local y = tipY + (table.getn(TS_ARROW_SIZES) - i) * 2
		TalentStage_DrawSegment(panel, cx - w / 2, y, w, 2, r, g, b)
	end
end

-- tipX: the x-coordinate the arrow points at. dir: 1 = pointing right
-- (tip is the rightmost point), -1 = pointing left (tip is the leftmost).
function TalentStage_DrawArrowHoriz(panel, tipX, cy, dir, r, g, b)
	for i = 1, table.getn(TS_ARROW_SIZES) do
		local h = TS_ARROW_SIZES[i]
		local d = (table.getn(TS_ARROW_SIZES) - i) * 2
		local x = tipX - dir * d
		TalentStage_DrawSegment(panel, x - 1, cy - h / 2, 2, h, r, g, b)
	end
end

-- Draws one prereq->dependent connector: straight vertical (same column),
-- straight horizontal (same tier), or an L-shaped two-segment connector for
-- the diagonal (different tier AND column) case. p and d only need px/py
-- (top-left button anchor, same convention as panel.info[idx].px/py) and are
-- otherwise plain data -- this is also exercised directly, with synthetic
-- p/d, by TalentStage_BuildConnectorTestFrame (see "/ts testconnectors"),
-- since no real class dump has ever hit the diagonal branch (CLAUDE.md "Open
-- questions" #4).
function TalentStage_DrawConnectorEdge(panel, p, d, met)
	local r, g, b
	if met then
		r, g, b = TS.COLOR.gold[1], TS.COLOR.gold[2], TS.COLOR.gold[3]
	else
		r, g, b = TS.COLOR.edge[1], TS.COLOR.edge[2], TS.COLOR.edge[3]
	end

	local fromCx, fromCy = p.px + TS.BUTTON_SIZE / 2, p.py - TS.BUTTON_SIZE / 2
	local toCx, toCy = d.px + TS.BUTTON_SIZE / 2, d.py - TS.BUTTON_SIZE / 2

	if p.column == d.column then
		-- straight vertical segment between the two buttons.
		-- topY is already the correct (higher/less-negative) anchor, so the
		-- height must be topY - botY, not botY - topY: botY is always more
		-- negative than topY here, so the latter is always negative and
		-- DrawSegment's h<0 normalization would shift the whole segment up
		-- by its own length instead of fixing it.
		local topY = p.py - TS.BUTTON_SIZE
		local botY = d.py
		TalentStage_DrawSegment(panel, fromCx - 2, topY, 4, topY - botY, r, g, b)
		TalentStage_DrawJoint(panel, fromCx, topY, TS_JOINT_SIZE, r, g, b)
		TalentStage_DrawArrowDown(panel, toCx, botY, r, g, b)
	elseif p.tier == d.tier then
		-- straight horizontal segment between the two buttons
		local leftX, rightX
		if p.px < d.px then leftX, rightX = p.px, d.px else leftX, rightX = d.px, p.px end
		local edgeY = fromCy
		TalentStage_DrawSegment(panel, leftX + TS.BUTTON_SIZE, edgeY - 2, rightX - (leftX + TS.BUTTON_SIZE), 4, r, g, b)
		if p.px < d.px then
			-- dependent is the right-hand node
			TalentStage_DrawJoint(panel, leftX + TS.BUTTON_SIZE, edgeY, TS_JOINT_SIZE, r, g, b)
			TalentStage_DrawArrowHoriz(panel, rightX, edgeY, 1, r, g, b)
		else
			-- dependent is the left-hand node
			TalentStage_DrawArrowHoriz(panel, leftX + TS.BUTTON_SIZE, edgeY, -1, r, g, b)
			TalentStage_DrawJoint(panel, rightX, edgeY, TS_JOINT_SIZE, r, g, b)
		end
	else
		-- different tier and column: an L-shaped two segment connector
		-- (vertical from the prereq, then horizontal into the dependent
		-- talent's column). Same sign convention as the vertical branch
		-- above: topY is the correct anchor, height is topY - toCy.
		local topY = p.py - TS.BUTTON_SIZE
		TalentStage_DrawSegment(panel, fromCx - 2, topY, 4, topY - toCy, r, g, b)

		local leftX, rightX
		if fromCx < toCx then leftX, rightX = fromCx, toCx else leftX, rightX = toCx, fromCx end
		TalentStage_DrawSegment(panel, leftX, toCy - 2, rightX - leftX, 4, r, g, b)

		TalentStage_DrawJoint(panel, fromCx, topY, TS_JOINT_SIZE, r, g, b)
		-- the horizontal leg is the one that actually arrives at the
		-- dependent, so the arrow direction follows fromCx/toCx, not topY
		local dir = 1
		if toCx < fromCx then dir = -1 end
		TalentStage_DrawArrowHoriz(panel, toCx, toCy, dir, r, g, b)
	end
end

function TalentStage_DrawConnectors(panel)
	panel.connectorCount = 0

	for idx, d in pairs(panel.info) do
		local args = { GetTalentPrereqs(panel.tab, idx) }
		local n = table.getn(args)
		if n > 0 then
			for i = 1, n, 3 do
				local ptier = args[i]
				local pcol = args[i + 1]
				local prow = panel.nodes[ptier]
				local pidx = prow and prow[pcol]
				if pidx then
					local p = panel.info[pidx]
					local pEffRank = p.rank + TalentStage_GetStaged(panel.tab, pidx)
					local met = pEffRank >= p.maxRank
					TalentStage_DrawConnectorEdge(panel, p, d, met)
				end
			end
		end
	end

	for i = panel.connectorCount + 1, table.getn(panel.connectorTextures) do
		panel.connectorTextures[i]:Hide()
	end
end

--------------------------------------------------------------------------
-- Synthetic connector test harness: the diagonal (different tier AND
-- column) branch of TalentStage_DrawConnectorEdge has never been exercised
-- by real class data (see CLAUDE.md "Open questions" #4 -- the live Hunter
-- dump's prereqs are all same-column or same-tier). This builds two fake
-- prereq edges that force that branch, using the exact same edge-drawing
-- code as the real trees, so the geometry can be checked visually in-game
-- before trusting/restyling it. Invoke with "/ts testconnectors".
--------------------------------------------------------------------------

function TalentStage_BuildConnectorTestFrame()
	if TS.connectorTestFrame then return end

	local f = CreateFrame("Frame", "TalentStageConnectorTestFrame", UIParent)
	f:SetWidth(320)
	f:SetHeight(260)
	f:SetPoint("CENTER", 220, 0)
	f:SetFrameStrata("DIALOG")
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", function() this:StartMoving() end)
	f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
	TalentStage_ApplyPlainBackdrop(f, 0.95)
	f:Hide()

	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
	close:SetScript("OnClick", function() f:Hide() end)

	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOP", f, "TOP", 0, -12)
	title:SetText("Connector test: diagonal L-branch (left=met, right=unmet)")

	-- bare table with just the fields TalentStage_DrawConnectorEdge /
	-- DrawSegment / GetConnectorTexture actually touch -- none of this is
	-- real talent data, it's a fixture
	local panel = {
		connectorLayer = CreateFrame("Frame", nil, f),
		connectorTextures = {},
		connectorCount = 0,
	}
	panel.connectorLayer:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -34)
	panel.connectorLayer:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)

	-- tier/column are required here, not cosmetic: TalentStage_DrawConnectorEdge
	-- branches on p.column==d.column / p.tier==d.tier to pick straight-vs-L
	-- rendering. Omitting them made both nil, and nil==nil is true in Lua --
	-- so an earlier version of this fixture silently fell into the
	-- same-column branch instead of the diagonal one it was built to test.
	local function fakeNode(px, py, tier, column, met)
		local btn = CreateFrame("Frame", nil, f)
		btn:SetWidth(TS.BUTTON_SIZE)
		btn:SetHeight(TS.BUTTON_SIZE)
		btn:SetPoint("TOPLEFT", panel.connectorLayer, "TOPLEFT", px, py)
		local bg = btn:CreateTexture(nil, "ARTWORK")
		bg:SetAllPoints(btn)
		bg:SetTexture("Interface\\Buttons\\WHITE8X8")
		if met then
			bg:SetVertexColor(TS.COLOR.gold[1], TS.COLOR.gold[2], TS.COLOR.gold[3])
		else
			bg:SetVertexColor(TS.COLOR.lockedIcon[1], TS.COLOR.lockedIcon[2], TS.COLOR.lockedIcon[3])
		end
		return { px = px, py = py, tier = tier, column = column }
	end

	-- case A: minimal diagonal, 1 tier + 1 column gap, met
	local a1 = fakeNode(20, -10, 1, 1, true)
	local a2 = fakeNode(20 + TS.COL_SPACING, -10 - TS.TIER_SPACING, 2, 2, true)
	TalentStage_DrawConnectorEdge(panel, a1, a2, true)

	-- case B: worse diagonal, 2 tiers + 2 columns gap, unmet
	local b1 = fakeNode(170, -10, 1, 1, false)
	local b2 = fakeNode(170 + 2 * TS.COL_SPACING, -10 - 2 * TS.TIER_SPACING, 3, 3, false)
	TalentStage_DrawConnectorEdge(panel, b1, b2, false)

	TS.connectorTestFrame = f
end

--------------------------------------------------------------------------
-- Staging interaction
--------------------------------------------------------------------------

function TalentStage_TalentButton_OnClick()
	local tab, idx = this.tab, this.talentIndex
	if arg1 == "RightButton" then
		TalentStage_Unstage(tab, idx)
	else
		TalentStage_Stage(tab, idx)
	end
end

function TalentStage_TalentButton_OnEnter()
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
	GameTooltip:SetTalent(this.tab, this.talentIndex)
	GameTooltip:Show()
end

function TalentStage_TalentButton_OnLeave()
	GameTooltip:Hide()
end

function TalentStage_TalentButton_OnUpdate()
	-- a point locking in confirmed takes priority over the slow staged pulse:
	-- a quick bright flash that decays to nothing (or back to the staged
	-- pulse, if other points on this button are still staged) over
	-- TS.CONFIRM_FLASH_DURATION seconds
	if this.confirmFlashElapsed then
		this.confirmFlashElapsed = this.confirmFlashElapsed + arg1
		local t = this.confirmFlashElapsed / TS.CONFIRM_FLASH_DURATION
		if t >= 1 then
			this.confirmFlashElapsed = nil
			this.glow:SetAlpha(this.stagedGlow and 0.35 or 0)
			this.glow:SetVertexColor(1, 1, 1)
			this.glow:ClearAllPoints()
			this.glow:SetPoint("TOPLEFT", this, "TOPLEFT", -4, 4)
			this.glow:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", 4, -4)
		else
			this.glow:SetAlpha(1 - t)

			-- bloom outward 22% of the button's own size at the moment it
			-- locks in, then shrink back down to the normal 4px border as
			-- the flash decays, for a punchier "lock-in" pop
			local bloom = 4 + (this:GetWidth() * 0.22 * (1 - t))
			this.glow:ClearAllPoints()
			this.glow:SetPoint("TOPLEFT", this, "TOPLEFT", -bloom, bloom)
			this.glow:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", bloom, -bloom)

			-- gold-hot at the peak, cooling back to plain white as it fades
			this.glow:SetVertexColor(1, 0.85 + 0.15 * t, 0.5 + 0.5 * t)
		end
		return
	end

	-- Row unlock/lock flash: a plain color-and-alpha fade on the same glow
	-- texture the staged pulse and confirm flash use, no swirl (this marks a
	-- row's availability changing, not a point landing). Confirm flash takes
	-- priority above (it means a point just locked in, which matters more),
	-- so a tier flash queued mid-confirm-flash just waits, frozen at 0, and
	-- plays in full once the confirm flash's own cleanup returns here.
	if this.tierFlashElapsed then
		this.tierFlashElapsed = this.tierFlashElapsed + arg1
		local t = this.tierFlashElapsed / TS.TIER_FLASH_DURATION
		if t >= 1 then
			this.tierFlashElapsed = nil
			this.tierFlashColor = nil
			this.glow:SetAlpha(this.stagedGlow and 0.35 or 0)
			this.glow:SetVertexColor(1, 1, 1)
			this.glow:ClearAllPoints()
			this.glow:SetPoint("TOPLEFT", this, "TOPLEFT", -4, 4)
			this.glow:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", 4, -4)
		else
			local c = this.tierFlashColor
			this.glow:SetVertexColor(c[1], c[2], c[3])
			this.glow:SetAlpha(1 - t)

			local bloom = 4 + (this:GetWidth() * 0.15 * (1 - t))
			this.glow:ClearAllPoints()
			this.glow:SetPoint("TOPLEFT", this, "TOPLEFT", -bloom, bloom)
			this.glow:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", bloom, -bloom)
		end
		return
	end

	if this.stagedGlow then
		-- driven off a shared clock (not a per-button elapsed accumulator)
		-- so every staged button pulses in lockstep regardless of when it
		-- was individually staged
		local a = 0.35 + 0.35 * math.abs(math.sin(GetTime() * 3))
		this.glow:SetAlpha(a)
	end
end

-- silent: skip the click sound and per-call Refresh -- used by build import,
-- which stages many points in one batch and refreshes/reports once at the end
-- instead of once per point.
function TalentStage_Stage(tab, idx, silent)
	if TS.processing then return end

	local panel = TS.panels[tab]
	local d = panel.info[idx]
	local staged = TalentStage_GetStaged(tab, idx)
	local effRank = TalentStage_EffectiveRank(tab, idx, d.rank)

	if effRank >= d.maxRank then return end
	if not TalentStage_IsTierUnlocked(tab, d.tier) then return end
	if not TalentStage_PrereqsMet(tab, idx) then return end

	local available = TalentStage_GetAvailablePoints()
	if TalentStage_GetTotalStaged() >= available then return end

	if not TS.staged[tab] then TS.staged[tab] = {} end
	TS.staged[tab][idx] = staged + 1

	if not silent then
		PlaySound("igMainMenuOptionCheckBoxOn")
		TalentStage_Refresh()
	end
end

-- True if any currently-staged point in this tab would fail its tier-unlock
-- or prereq check right now. Used by Unstage to simulate-then-check a
-- removal *before* committing it, rather than removing and cleaning up the
-- wreckage after -- mirrors how real talent calculators (e.g. octowow.st)
-- behave: a point already spent deeper in the tree pins the row(s) below it,
-- refusing the removal outright, instead of silently discarding the deeper
-- point once its support is pulled out from under it.
function TalentStage_StagedWouldBeInvalid(tab)
	local panel = TS.panels[tab]
	local list = TS.staged[tab]
	if not panel or not list then return false end
	for idx, n in pairs(list) do
		if n > 0 then
			local d = panel.info[idx]
			if not TalentStage_IsTierUnlocked(tab, d.tier) or not TalentStage_PrereqsMet(tab, idx) then
				return true
			end
		end
	end
	return false
end

function TalentStage_Unstage(tab, idx)
	if TS.processing then return end

	local staged = TalentStage_GetStaged(tab, idx)
	if staged <= 0 then return end

	TS.staged[tab][idx] = staged - 1
	if TalentStage_StagedWouldBeInvalid(tab) then
		-- would strand a deeper staged point below its own unlock/prereq
		-- requirement -- undo and refuse the removal instead
		TS.staged[tab][idx] = staged
		PlaySound("igQuestFailed")
		return
	end

	PlaySound("igMainMenuOptionCheckBoxOff")
	TalentStage_Refresh()
end

function TalentStage_ClearStaged()
	if TS.processing then return end
	TS.staged = {}
	TalentStage_Refresh()
end

--------------------------------------------------------------------------
-- Confirm queue: LearnTalent has a short server-side delay between calls, so
-- staged points are spent one at a time, advancing on TALENT_UPDATE (with an
-- OnUpdate-driven fallback in case that event is ever missed).
--------------------------------------------------------------------------

function TalentStage_ConfirmStaged()
	if TS.processing then return end

	TS.queue = {}
	for tab, list in pairs(TS.staged) do
		for idx, count in pairs(list) do
			local i = 1
			while i <= count do
				table.insert(TS.queue, { tab = tab, idx = idx })
				i = i + 1
			end
		end
	end

	if table.getn(TS.queue) == 0 then return end

	TS.queueTotal = table.getn(TS.queue)
	TS.queueDone = 0

	-- deliberately NOT wiping TS.staged here: each entry's staged point stays
	-- displayed (effRank = realRank + staged) until TalentStage_ProcessQueue
	-- decrements it at the moment that specific point actually confirms, so
	-- the displayed rank never dips back down and pops forward again.
	TalentStage_ProcessQueue()
end

function TalentStage_ProcessQueue()
	TalentStage_SettleInFlight()

	if TS.inFlight then
		-- still waiting on this entry to land server-side; the fallback
		-- ticker (or the next TALENT_UPDATE) will call us again
		return
	end

	if table.getn(TS.queue) == 0 then
		TS.processing = false

		local flashedAny = false
		for tab, idxs in pairs(TS.confirmedButtons) do
			local panel = TS.panels[tab]
			for idx in pairs(idxs) do
				local btn = panel and panel.buttons[idx]
				if btn then
					btn.confirmFlashElapsed = 0
					flashedAny = true
				end
			end
		end
		TS.confirmedButtons = {}
		TS.queueTotal = 0
		TS.queueDone = 0
		if flashedAny then
			-- "flag defended" fanfare, distinct from the plain checkbox click
			-- used while staging: this is the confirm run actually locking in.
			PlaySoundFile("Sound\\Spells\\PVPFlagReturned.wav")
		end

		if TalentStageFrame:IsVisible() then
			-- full grid redraw, not just the ledger: this is what has to
			-- reflect the newly-learned rank once the queue drains, and it
			-- must not depend solely on a TALENT_UPDATE event landing (the
			-- OnUpdate fallback ticker can be what drains the queue instead)
			TalentStage_Refresh()
		else
			TalentStage_UpdateLedger()
		end
		return
	end

	TS.processing = true
	local entry = TS.queue[1]
	table.remove(TS.queue, 1)
	if TS.sandboxMode then
		-- fake the server round-trip entirely: no LearnTalent call, no real
		-- rank read, so nothing about the character actually changes
		TS.inFlight = { tab = entry.tab, idx = entry.idx, sandbox = true }
	else
		local _, _, _, _, priorRank = GetTalentInfo(entry.tab, entry.idx)
		TS.inFlight = { tab = entry.tab, idx = entry.idx, priorRank = priorRank or 0 }
		LearnTalent(entry.tab, entry.idx)
	end
	TS.nextAllowed = GetTime() + TS.QUEUE_FALLBACK_DELAY
end

--------------------------------------------------------------------------
-- Debug dump: authoritative live reference for GetNumTalentTabs /
-- GetTalentTabInfo / GetNumTalents / GetTalentInfo / GetTalentPrereqs, as
-- actually resolved by the running client (sidesteps offline patch-layer
-- guessing entirely -- see CLAUDE.md "Open questions" section 4). Every
-- talent index is included unfiltered, unlike TalentStage_BuildUI which
-- drops degenerate tier/col<1 entries for display purposes.
--------------------------------------------------------------------------

function TalentStage_BuildDumpText()
	local lines = {}
	local class = UnitClass("player")
	table.insert(lines, "-- TalentStage live dump --")
	table.insert(lines, "-- class="..(class or "?").." level="..UnitLevel("player").." time="..(date and date("%Y-%m-%d %H:%M:%S") or tostring(GetTime())))

	local numTabs = GetNumTalentTabs()
	for tab = 1, numTabs do
		local tabName = GetTalentTabInfo(tab)
		table.insert(lines, "")
		table.insert(lines, "=== Tab "..tab..": "..(tabName or "?").." ===")

		local numTalents = GetNumTalents(tab)
		local nodes = {}
		local info = {}
		for idx = 1, numTalents do
			local name, icon, tier, column, rank, maxRank = GetTalentInfo(tab, idx)
			info[idx] = { name = name, tier = tier, column = column, rank = rank, maxRank = maxRank }
			if not nodes[tier] then nodes[tier] = {} end
			nodes[tier][column] = idx
		end

		local order = {}
		for idx = 1, numTalents do table.insert(order, idx) end
		table.sort(order, function(a, b)
			local da, db = info[a], info[b]
			if da.tier ~= db.tier then return da.tier < db.tier end
			return da.column < db.column
		end)

		for i = 1, table.getn(order) do
			local idx = order[i]
			local d = info[idx]
			local args = { GetTalentPrereqs(tab, idx) }
			local n = table.getn(args)
			local prereqParts = {}
			for j = 1, n, 3 do
				local ptier, pcol, isLearnable = args[j], args[j + 1], args[j + 2]
				local prow = nodes[ptier]
				local pidx = prow and prow[pcol]
				local pname = pidx and info[pidx].name or "??"
				table.insert(prereqParts, "tier="..tostring(ptier).." col="..tostring(pcol).."("..pname..") learnable="..tostring(isLearnable))
			end
			table.insert(lines, string.format("  idx=%3d tier=%s col=%s maxrank=%s name=%-35s prereq=[%s]",
				idx, tostring(d.tier), tostring(d.column), tostring(d.maxRank), "'"..(d.name or "?").."'", table.concat(prereqParts, ", ")))
		end
	end

	return table.concat(lines, "\n")
end

function TalentStage_BuildDumpFrame()
	if TS.dumpFrame then return end

	local f = CreateFrame("Frame", "TalentStageDumpFrame", UIParent)
	f:SetWidth(640)
	f:SetHeight(520)
	f:SetPoint("CENTER")
	f:SetFrameStrata("DIALOG")
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", function() this:StartMoving() end)
	f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
	TalentStage_ApplyPlainBackdrop(f, 0.95)
	f:Hide()

	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
	close:SetScript("OnClick", function() f:Hide() end)

	local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", f, "TOP", 0, -14)
	title:SetText("TalentStage Dump  (click box, Ctrl+A, Ctrl+C to copy)")

	local scroll = CreateFrame("ScrollFrame", "TalentStageDumpScroll", f, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -44)
	scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -32, 16)

	local edit = CreateFrame("EditBox", "TalentStageDumpEditBox", scroll)
	edit:SetMultiLine(true)
	edit:SetAutoFocus(false)
	edit:SetFontObject(ChatFontNormal)
	edit:SetWidth(580)
	edit:SetHeight(4000)
	edit:SetScript("OnEscapePressed", function() f:Hide() end)
	scroll:SetScrollChild(edit)

	TS.dumpFrame = f
	TS.dumpEditBox = edit
end

function TalentStage_RunDump()
	local text = TalentStage_BuildDumpText()

	TalentStageDumpDB = TalentStageDumpDB or {}
	TalentStageDumpDB.lastDump = text
	TalentStageDumpDB.lastDumpTime = date and date("%Y-%m-%d %H:%M:%S") or tostring(GetTime())

	TalentStage_BuildDumpFrame()
	TS.dumpEditBox:SetText(text)
	TS.dumpEditBox:HighlightText()
	TS.dumpFrame:Show()

	DEFAULT_CHAT_FRAME:AddMessage("TalentStage: dump saved to SavedVariables (TalentStageDumpDB.lastDump) and shown in copy box. /reloadui or /camp to flush SavedVariables to disk.")
end

SLASH_TALENTSTAGE1 = "/talentstage"
SLASH_TALENTSTAGE2 = "/ts"
SlashCmdList["TALENTSTAGE"] = function(msg)
	msg = string.lower(msg or "")
	if msg == "dump" then
		TalentStage_RunDump()
	elseif msg == "testconnectors" then
		TalentStage_BuildConnectorTestFrame()
		TS.connectorTestFrame:Show()
	elseif msg == "dev" then
		TalentStage_ToggleSettingsPanel()
	else
		DEFAULT_CHAT_FRAME:AddMessage("TalentStage: /ts dump - dump live GetTalentInfo/GetTalentPrereqs data to a copy box and SavedVariables. /ts testconnectors - show a synthetic diagonal-connector test panel. /ts dev - toggle the dev sandbox-mode panel.")
	end
end
