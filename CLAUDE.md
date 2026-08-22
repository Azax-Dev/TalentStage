# Project: redesigned talent UI for WoW 1.12 (Turtle WoW / OctoWoW)

## What this is
A drop-in addon that replaces the default Blizzard talent frame with a modern
layout: all three specialization trees visible at once, no internal
scrolling, and a stage-then-confirm flow so clicking a talent doesn't spend
the point until the player confirms.

This is an addon, not engine code. It ships as a normal
`Interface\AddOns\<AddonName>\` folder and must work on the stock 1.12.1
client used by Turtle WoW and OctoWoW today. No dependency on the custom
WoWee client — that's a possible future home for this logic, not the target.

## Environment
Live client install, read for reference only, do not edit in place:

`/mnt/C2D20695D2068E3B/Games/Turtle WoW`
- `Interface\AddOns\pfUI\` — installed, active
- `Interface\AddOns\ElvUI\` — ElvUI-Vanilla port, installed, has thrown Lua
  errors before, treat its API as unverified until read from source
- `Interface\FrameXML\` — ground-truth reference for the default talent
  frame's real API calls

New addon lives in its own folder, e.g. `Interface\AddOns\TalentStage\`
(placeholder name, rename freely). Never edit `FrameXML`, `pfUI`, or `ElvUI`
in place — read them, don't modify them.

## Hard requirement: border inherits from the active UI addon
Ship no custom border art. Detect whichever of pfUI / ElvUI is loaded and use
that addon's own frame styling, so the talent window matches the rest of the
player's UI instead of clashing with it.

- pfUI — confirmed public API: `pfUI.api.CreateBackdrop(frame, border)`
  applies pfUI's standard backdrop/border to any frame. pfUI also supports
  `pfUI:RegisterSkin("name", "version", function() ... end)` for registering
  a skin against a third-party frame. Read `pfUI\modules\skin.lua` and the
  community `pfUI-addonskinner` project on GitHub for the established
  pattern before writing this.
- ElvUI — general convention on modern ElvUI is
  `local E, L, V, P, G = unpack(ElvUI)`, `local S = E:GetModule('Skins')`,
  then `S:HandleFrame(frame)` or `frame:SetTemplate("Default")`. Do **not**
  assume the installed ElvUI-Vanilla fork matches this 1:1 — read its actual
  `modules\skins\` source first and confirm the real hook before using it.
- Detect at load with `IsAddOnLoaded("pfUI")` / `IsAddOnLoaded("ElvUI")` and
  branch. Don't assume either is present — fall back to a plain hand-rolled
  `SetBackdrop` border (vanilla has no `BackdropTemplateMixin`) so the addon
  still works standalone.

## Confirmed WoW 1.12 API facts
- `GetNumTalentTabs()`, `GetTalentTabInfo(tabIndex)` → name, texture,
  pointsSpent, background
- `GetNumTalents(tabIndex)`
- `GetTalentInfo(tabIndex, talentIndex)` → name, iconTexture, tier, column,
  rank, maxRank, isExceptional, meetsPrereq
- `GetTalentPrereqs(tabIndex, talentIndex)` — the stock UI feeds this into
  `TalentFrame_SetBranchTexture` / `TALENT_BRANCH_TEXTURECOORDS` to draw
  prereq connectors as stitched texture pieces, not vector lines. Follow the
  same approach rather than trying to draw arbitrary lines.
- `LearnTalent(tabIndex, talentIndex)` — do not call in a tight loop, there's
  a short server-side delay between successive calls. Confirming several
  staged points needs a small queue (a ticking frame — vanilla has no
  `C_Timer`) that fires one point at a time and advances on the
  `TALENT_UPDATE` event. The `Talented` addon already solves this exact
  "apply a saved build" problem — read it before reinventing the queue.

## Rendering constraints (Lua 5.0 / vanilla FrameXML)
- No blur, box-shadow, or glow. Fake the "staged, not yet confirmed" glow
  with an `OnUpdate`-driven alpha pulse on an overlay texture.
- No native texture rotation, no `AnimationGroup` (that API is WotLK+).
  Animate by hand via `OnUpdate` and elapsed time.
- Custom fonts are fine — bundle a `.ttf` and reference it via a `Font`
  template, same as pfUI and ElvUI already do.
- Layout is `Frame` anchors only, no CSS-grid equivalent — no different from
  any complex pfUI/ElvUI custom frame, just more verbose.

## Read before writing code
- `Interface\FrameXML\TalentFrame.lua` / `.xml` (may instead live under
  `AddOns\Blizzard_TalentUI\` depending on this client's exact build) —
  ground truth for the real API and the branch-texture connector trick.
- `Interface\AddOns\pfUI\modules\skin.lua` and `pfUI\api\` — border API.
- `Interface\AddOns\ElvUI\` skins module — verify the real skinning hook for
  this specific vanilla fork before using it.
- The `Talented` addon (GitHub/CurseForge) — reference for queued/batched
  `LearnTalent` calls.

## Design reference
A browser mockup of the target look and interaction already exists: dark
stone panel, icon grid per tree, gold connector lines between prereqs, and a
stage-then-confirm ledger bar at the bottom. Talent names and point totals in
that mockup are placeholders — real data comes from the `GetTalentInfo` calls
above, not hardcoded values.

Second mockup pass: `rogue-talent-redesign-v2.html` (repo root, HTML/CSS/JS
demo, Rogue talent data is a hardcoded placeholder). Reference for: overall
panel chrome (titlebar with reset link + close button), three-tree
side-by-side layout/spacing, talent grid/tile styling per state
(locked/available/staged/confirmed/maxed), connector line treatment (gold met
/ gray unmet, small circle joints), the always-visible Import/Export row
above the trees, and the ledger-bar-becomes-progress-bar swap during a
multi-point confirm. This is look-and-feel only — it does not cover the
lock-in bloom/spark or row lock/unlock flash (already implemented, see
`TalentStage_TalentButton_OnUpdate`), which this redesign pass only retunes
cosmetically, not rebuilds.

**Decision (2026-08-22): Import/Export row + settings gear.** Keep the
mockup's Import/Export row as a separate always-visible row (not folded into
the settings-gear popup) — explicit user call, since the sandbox-mode gear
button is expected to go away later anyway. For this redesign pass: hide the
gear button (dev-only sandbox toggle stays in the code, just not shown/
reachable); build the Import/Export row's box + buttons but wire them to
no-ops — the actual import/export codec doesn't exist yet, that's a separate
future task.

## Open questions — RESOLVED (read from source 2026-08-22)

### 1. Default talent frame source
This client build has NO `Interface/FrameXML/` or `Interface/AddOns/*` on disk
except loose files — everything else (including all of FrameXML) ships packed
inside `Data/*.MPQ`. There is no unpacked copy to read directly; extracting
required a listfile-aware MPQ reader (`mpyq` worked; `patch-4/8/9/W.mpq` are
encrypted and unreadable this way, but weren't needed).

The talent UI is the **`Blizzard_TalentUI` addon**, not raw FrameXML:
- `Interface\AddOns\Blizzard_TalentUI\Blizzard_TalentUI.lua/.xml/.toc` — lives
  in `Data/patch.MPQ` (and `Data/interface.MPQ` for the unpatched base copy).
  `.toc` confirms `## LoadOnDemand: 1`.
- `Interface\FrameXML\TalentFrame.lua/.xml` also still exists in
  `Data/interface.MPQ`, but diffing it against `Blizzard_TalentUI.lua` shows
  the addon copy is the live one: it independently registers
  `UIPanelWindows["TalentFrame"]` and owns `TalentFrame_Toggle` (FrameXML's
  copy has neither — it defines the older `ToggleTalentFrame` name instead
  and doesn't self-register the panel window). pfUI's own skin
  (`pfUI/skins/blizzard/talents.lua`) hooks `Blizzard_TalentUI` via
  `HookAddonOrVariable`, confirming this addon is what actually loads at
  runtime. **Build addon code against `Blizzard_TalentUI`, not FrameXML.**

Real implementations (from `Blizzard_TalentUI.lua`):

```lua
-- GetTalentInfo / GetTalentPrereqs are engine C API calls, not Lua — there is
-- no Lua-side implementation to paste. Their call sites establish the real
-- signature/contract:
name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq =
    GetTalentInfo(PanelTemplates_GetSelectedTab(TalentFrame), i);

-- GetTalentPrereqs returns a flat vararg list consumed as (tier, column,
-- isLearnable) triples, spliced onto (buttonTier, buttonColumn,
-- forceDesaturated, tierUnlocked, ...):
if ( TalentFrame_SetPrereqs(tier, column, forceDesaturated, tierUnlocked,
     GetTalentPrereqs(PanelTemplates_GetSelectedTab(TalentFrame), i)) and meetsPrereq ) then

function TalentFrame_SetPrereqs(...)
	local buttonTier = arg[1];
	local buttonColumn = arg[2];
	local forceDesaturated = arg[3];
	local tierUnlocked = arg[4];
	local tier, column, isLearnable;
	local requirementsMet;
	if ( tierUnlocked and not forceDesaturated ) then
		requirementsMet = 1;
	else
		requirementsMet = nil;
	end
	for i=5, arg.n, 3 do
		tier = arg[i];
		column = arg[i+1];
		isLearnable = arg[i+2];
		if ( not isLearnable or forceDesaturated ) then
			requirementsMet = nil;
		end
		TalentFrame_DrawLines(buttonTier, buttonColumn, tier, column, requirementsMet);
	end
	return requirementsMet;
end

-- Branch connectors are stitched texture pieces, coords keyed by direction
-- and by requirementsMet sign (1 = met/gold, -1 = unmet/gray):
TALENT_BRANCH_TEXTURECOORDS = {
	up    = { [1] = {0.12890625, 0.25390625, 0, 0.484375}, [-1] = {0.12890625, 0.25390625, 0.515625, 1.0} },
	down  = { [1] = {0, 0.125, 0, 0.484375}, [-1] = {0, 0.125, 0.515625, 1.0} },
	left  = { [1] = {0.2578125, 0.3828125, 0, 0.5}, [-1] = {0.2578125, 0.3828125, 0.5, 1.0} },
	right = { [1] = {0.2578125, 0.3828125, 0, 0.5}, [-1] = {0.2578125, 0.3828125, 0.5, 1.0} },
	topright = { [1] = {0.515625, 0.640625, 0, 0.5}, [-1] = {0.515625, 0.640625, 0.5, 1.0} },
	topleft  = { [1] = {0.640625, 0.515625, 0, 0.5}, [-1] = {0.640625, 0.515625, 0.5, 1.0} },
	bottomright = { [1] = {0.38671875, 0.51171875, 0, 0.5}, [-1] = {0.38671875, 0.51171875, 0.5, 1.0} },
	bottomleft  = { [1] = {0.51171875, 0.38671875, 0, 0.5}, [-1] = {0.51171875, 0.38671875, 0.5, 1.0} },
	tdown = { [1] = {0.64453125, 0.76953125, 0, 0.5}, [-1] = {0.64453125, 0.76953125, 0.5, 1.0} },
	tup   = { [1] = {0.7734375, 0.8984375, 0, 0.5}, [-1] = {0.7734375, 0.8984375, 0.5, 1.0} },
};

function TalentFrame_SetBranchTexture(tier, column, texCoords, xOffset, yOffset)
	local branchTexture = TalentFrame_GetBranchTexture();
	branchTexture:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4]);
	branchTexture:SetPoint("TOPLEFT", "TalentFrameScrollChildFrame", "TOPLEFT", xOffset, yOffset);
end
```
Connector direction/state per talent is computed once per `TalentFrame_Update()`
into a `TALENT_BRANCH_ARRAY[tier][column]` node table (`.up/.down/.left/.right/
.topArrow/...`, values `1`/`-1`/`nil`) by `TalentFrame_DrawLines`, then drawn
in a second pass. Confirms the CLAUDE.md guidance: replicate this
node-table + stitched-texture approach rather than drawing arbitrary lines.

### 2. pfUI skinning API
Confirmed exact signatures (`pfUI/api/api.lua`):
```lua
function pfUI.api.CreateBackdrop(f, inset, legacy, transp, backdropSetting)
function pfUI.api.CreateBackdropShadow(f)
function pfUI.api.HookAddonOrVariable(addon, func)  -- fires `func` once `addon` is loaded (or already is)
```
`pfUI:RegisterSkin(name, func)` (`pfUI.lua:395`) stores `func` and later calls
it via `setfenv(func, pfUI:GetEnvironment())` — inside a registered skin body,
bare identifiers like `CreateBackdrop`, `StripTextures`, `SkinButton`, `SkinTab`
resolve through that injected environment to `pfUI.api.*`, so both bare-name
and `pfUI.api.`-prefixed calls appear interchangeably in pfUI's own skin files
(see `pfUI/skins/blizzard/talents.lua`, which already skins the default
Blizzard talent frame — read it directly as the reference implementation
rather than re-deriving the pattern). Real usage pattern:
```lua
pfUI:RegisterSkin("Talents", function ()
  HookAddonOrVariable("Blizzard_TalentUI", function()
    local TALENT_FRAME = _G.TalentFrame
    StripTextures(TALENT_FRAME)
    CreateBackdrop(TALENT_FRAME, nil, nil, .75)
    CreateBackdropShadow(TALENT_FRAME)
    ...
  end)
end)
```

### 3. ElvUI-Vanilla skinning hook
Confirmed NOT retail's `S:HandleFrame`/`frame:SetTemplate("Default")`
free-function convention. Real API (`ElvUI/Core/toolkit.lua`,
`ElvUI/Modules/Skins/Skins.lua`):
```lua
function E:SetTemplate(f, t, glossTex, ignoreUpdates, forcePixelMode, isUnitFrameElement)
function E:CreateBackdrop(f, t, tex, ignoreUpdates, forcePixelMode, isUnitFrameElement)
function E:StripTextures(object, kill, alpha)
function S:AddCallbackForAddon(addonName, eventName, loadFunc, forceLoad, bypass)
```
These are **methods on `E`/`S`** (via `local E, L, V, P, G = unpack(ElvUI)`,
`local S = E:GetModule("Skins")`), called as `E:CreateBackdrop(frame, "Transparent")`
/ `E:SetTemplate(frame, "Default")` — matches the general shape guessed in the
old note, but the load-hook is `S:AddCallbackForAddon`, not a raw
`ADDON_LOADED` listener. This fork already ships
`ElvUI/Modules/Skins/Blizzard/Talent.lua` skinning the stock talent frame —
read it directly:
```lua
local E, L, V, P, G = unpack(ElvUI);
local S = E:GetModule("Skins");

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.talent ~= true then return end
	E:StripTextures(TalentFrame)
	E:CreateBackdrop(TalentFrame, "Transparent")
	S:HandleCloseButton(TalentFrameCloseButton)
	for i = 1, 5 do S:HandleTab(_G["TalentFrameTab"..i]) end
	S:HandleScrollBar(TalentFrameScrollFrameScrollBar)
	for i = 1, MAX_NUM_TALENTS do
		local talent = _G["TalentFrameTalent"..i]
		if talent then
			E:StripTextures(talent)
			E:SetTemplate(talent, "Default")
			E:StyleButton(talent)
		end
	end
end
S:AddCallbackForAddon("Blizzard_TalentUI", "Talent", LoadSkin)
```

### 4. Talent data: stock vanilla vs. server-modified — RESOLVED, static DBC
parsing is UNRELIABLE, use the live dump only

Confirmed 2026-08-22 by diffing `tools/talent_reference.txt` (offline
`patch-7.mpq` parse) against a real `/ts dump` taken in-game on a level 22
Hunter on Turtle WoW. They do **not** match — not cosmetically, structurally.
Entire talents are in different tier/column slots or don't exist at all in
the offline parse:

| Slot | Offline (patch-7.mpq) | Live (in-game dump) |
|---|---|---|
| BM t3c1/c2 | Elusiveness / Bestial Swiftness | Pathfinding / Coordinated Assault |
| BM t5c1 | Bestial Precision | Scent of Blood |
| BM t6c1/c2 | Spirit Bond / (empty) | Bestial Precision / Spirit Bond |
| BM t7c2 | Bestial Wrath | Kill Command (Bestial Wrath moved to t5c2) |
| MM t3c2 | — | Aimed Shot |
| MM t5c2 | — | Experimental Ammunition |
| Survival t2c4 | — | Alone Against the World |
| Survival t5c3 | — | Lacerate |

**"Aimed Shot" and "Experimental Ammunition" are confirmed real, live-client
talents** (Marksmanship idx 6 and idx 11 in the dump) — this server really
does run this custom tree; it is not an octowow.st mixup.

**Correction to the note below**: the earlier patch-4/8/9/W.mpq finding
("weren't needed") was scoped only to locating FrameXML/Lua source files —
it was never established (and is now disproven by this diff) that those
encrypted archives are not load-bearing for `Talent.dbc`. Don't reuse that
conclusion outside FrameXML-location context.

**Going forward: `tools/dump_talents.py` / static `Talent.dbc` parsing is
NOT a trustworthy reference for this or any other class.** The only
authoritative source for talent tier/column/prereq data is the live
`/ts dump` (TalentStage's debug slash command, dumps
`GetTalentInfo`/`GetTalentPrereqs` as actually resolved by the running
client) taken in-game per class. `tools/talent_reference.txt` and
`tools/dump_talents.py` are kept for historical reference only — do not
build or validate connector/prereq logic against them.

A structural sweep of the live Hunter dump (all 3 tabs) found no cross-tab,
backwards, or self-referencing prereqs. Every prereq in that dump is either
same-column (vertical) or same-tier (horizontal) — none exercise the
diagonal L-shaped connector branch in `TalentStage_DrawConnectors` at all.
Several span a 2-tier gap in the same column (Frenzy, Mortal Shots,
Experimental Ammunition, Lock and Load, Lacerate, Untamed Trapper) but each
passes through an empty node at the skipped tier, so none should collide
with an unrelated button under the current code. The originally-reported odd
connector was not reproduced from this data alone — still need the exact
tab/tier/column repro from a live screenshot to pin down the actual bug.

## Progress

### Phase 1 — standalone addon (built 2026-08-22, awaiting in-game verification)
`Interface/AddOns/TalentStage/` scaffolded and copied into the live client
(`.../Games/Turtle WoW/Interface/AddOns/TalentStage/`) for testing. No pfUI/
ElvUI dependency yet — plain hand-rolled `SetBackdrop`, own frame identity
(`TalentStageFrame`, `TalentStagePanel<tab>`, `TalentStageButton<tab>_<idx>`),
never references `TalentFrame`/`TalentFrame_Toggle`.

- Global `ToggleTalentFrame()` is overridden outright (confirmed both the
  micro button's `OnClick` and the default "N" keybind just call that one
  global, per `MainMenuBarMicroButtons.xml`) — so the stock frame never
  loads/shows, no need to touch `Blizzard_TalentUI` itself.
- Layout/tier/column sizing is computed per tab from live `GetTalentInfo`
  data (max tier/column actually seen), not hardcoded 8x4 — deliberate, since
  Turtle's `Talent.dbc` is confirmed modified in size and grid shape wasn't
  verified to match stock.
- Staging state (`TalentStage.staged[tab][idx]`) is local-only; prereq/tier
  gating is recomputed against staged+actual ranks (not the engine's
  `meetsPrereq`/`isLearnable` flags, which only reflect confirmed server
  state) so a prereq + dependent can be staged together in one sitting before
  confirming.
- Confirm queue pops one `{tab, idx}` LearnTalent call at a time, advances on
  `TALENT_UPDATE`, with an always-running ticker frame (independent of the
  main frame's visibility, since `OnUpdate` doesn't fire on hidden frames) as
  a fallback in case that event is ever missed.
- Connectors: straight rectangle textures (`WHITE8X8`) computed from the same
  tier/column pixel math used to place buttons — vertical/horizontal for
  same-column/same-tier prereqs, a two-segment L for diagonal ones. Gold when
  the prereq's effective (staged-aware) rank is met, gray otherwise.

Not yet done: pfUI/ElvUI skin integration (phase 1 explicitly excludes it),
verified in-game (no confirmed screenshot/playtest yet — do that before
layering skinning on top), and the OnUpdate-driven "staged" glow pulse only
proves out visually once tested live.

### Phase 2 — visual/UX redesign pass (started 2026-08-22)
Look-and-feel only, against the `rogue-talent-redesign-v2.html` mockup (see
Design reference) — no change to staging/prereq/confirm-queue logic. Broken
into independently testable passes, in order:

1. Chrome/layout — panel/titlebar/tile-state restyle. Sizing stays driven by
   live `GetNumTalents`/tier/column data, not the mockup's fixed grid.
2. Connectors — build a synthetic fixture exercising the diagonal
   (different-tier-AND-different-column) L-branch in
   `TalentStage_DrawConnectors` *before* restyling it, since no real class
   dump has ever hit that path — then reskin line/joint treatment.
3. Staged/confirmed tile state colors, reusing the existing `btn.glow`/
   `stagedGlow` mechanism.
4. Ledger → progress-bar swap reskin, reusing existing
   `TS.processing`/`queueDone`/`queueTotal` logic untouched.
5. Lock-in bloom/spark + row flash — cosmetic retune only (colors/timing) of
   the already-implemented `TalentStage_TalentButton_OnUpdate` logic.
6. Import/Export row (built, wired to a real codec — see "Build-code
   import/export" below) + hide the settings gear — see the Design reference
   decision above.

### Build-code import/export (built 2026-08-23) — RESOLVED, do not re-derive
Import/Export buttons are wired to a real codec now (`TalentStageCodec.lua`),
compatible with octowow.st's talent calculator. Key finding: **the deployed
site does NOT match `github.com/Haaxor1689/talent-builder`'s current `main`
branch** (`src/components/calculator/utils.ts`'s `bitPack`/`bitUnpack` trims
trailing zeros before packing; the live site does not). The real scheme was
recovered by pulling and reading the actual bundle served at octowow.st
(`page-ce9cdb06bf9c66c9.js`, module `8106`, functions `i`/`o`), not the repo.
If the deployed bundle ever changes, re-derive from a fresh fetch of that
page's chunks rather than trusting the GitHub repo.

Scheme (see `TalentStageCodec.lua`'s header comment for the full write-up):
per tree, a fixed 28-slot array (7 tiers x 4 columns, slot = `(tier-1)*4 +
(column-1) + 1`, 1-indexed) of 3-bit ranks, concatenated to 84 bits, chunked
into <=8-bit pieces (last piece 4 bits, deliberately *not* zero-padded —
reproduced as-is for compatibility), base64'd, one trailing `=` dropped
unconditionally, then trailing `A` runs stripped; the 3 tree segments joined
with `-`. Decode pads each segment back to 14 base64 chars with `A` before
decoding. No bitwise ops used (vanilla Lua 5.0 has none) — pure arithmetic
(`math.mod`/`math.floor`), verified against the real bundle: a pure-arithmetic
Python mirror, then the actual `.lua` file (loaded through `lupa`/LuaJIT,
since no Lua 5.0/5.1 CLI was available in the dev sandbox — `math.mod` and
`table.getn` were shimmed onto LuaJIT's 5.4-family stdlib for the test), both
reproduced the worked example (`"RI-DgJI-AQ"` → Assassination 4/47, Combat
10/54, Subtlety 2/47) exactly and round-tripped 200 random realistic builds
against the live bundle's own encode/decode with zero mismatches.

Talent ordering within a tree does **not** need to match whatever order
`GetTalentInfo`'s `talentIndex` enumerates in: the talent-builder schema has
no separate tier/column field on a talent record at all (position is
implied entirely by flat array index over the fixed 7x4 grid), so
`TalentStageCodec.SlotForTierColumn(tier, column)` places each talent by its
own live `(tier, column)` directly — sidesteps needing a live dump
cross-check of ordering.

Import always *adds* staged points on top of whatever's already actually
spent (real rank, or sandbox-fake-confirmed) — there's no way to unstage a
real point outside an actual respec, so a target lower than an already-spent
rank on some talent can't be represented; `TalentStage_ImportBuild` reports
any such shortfall rather than pretending to apply it. It loops staging
attempts to a fixed point (via the existing `TalentStage_Stage`, given a new
`silent` param to skip the per-point sound/refresh during a batch import)
so prereq/tier-unlock ordering resolves itself regardless of `pairs()` walk
order, reusing all of `TalentStage_Stage`'s existing real-game validation
rather than re-implementing it.

Export encodes `TalentStage_EffectiveRank` (real + staged, sandbox-aware) —
what's currently displayed, including any not-yet-confirmed staged plan, not
just the character's actually-spent points. The full-URL export uses
`UnitClass("player")`'s english class name, lowercased, as the octowow.st
class-slug path segment; import accepts either a bare code or a full URL
(extracts `points=` and, if present, the `/talents/<slug>/` class for a
mismatch warning) via `TalentStage_ExtractImportCode`.

Only the current `points=` scheme is supported — octowow.st's legacy
`t=`/`c=` query params (old-format shared links, single-digit-per-talent, no
base64) are intentionally not decoded; this addon only needs to round-trip
codes it can also produce itself.

## Notes changing the approach
- Target `Blizzard_TalentUI`'s namespace/frames, not FrameXML's — same names
  in this build, but the addon copy is what's live, and it's the one pfUI
  already hooks. `HookAddonOrVariable("Blizzard_TalentUI", ...)` is the
  correct load-order gate for this new addon too, mirroring pfUI's own skin.
- Both pfUI and ElvUI-Vanilla already ship working skins for the *stock*
  talent frame (`pfUI/skins/blizzard/talents.lua`,
  `ElvUI/Modules/Skins/Blizzard/Talent.lua`). Since this project replaces
  that frame with a custom one, pfUI/ElvUI's existing hook will fire against
  frame names/children that may no longer exist once the custom UI is
  substituted in — decide explicitly whether to disable/replace those two
  built-in skin files' effect on `TalentFrame` or design the new addon to
  reuse the same global frame name so their hooks still apply harmlessly.
- Confirmed real per-node struct used for branch drawing is
  `TALENT_BRANCH_ARRAY[tier][column]` with `.up/.down/.left/.right/.topArrow/
  .leftArrow/.rightArrow` fields set to `1` (met), `-1` (unmet/gray), or `nil`
  (absent) — worth mirroring this shape if reimplementing prereq-line layout
  logic rather than inventing a new representation.

## Deployment

After every update to the addon source, copy the updated files into the live
client's AddOns folder so the change is immediately testable in-game:

```
cp Interface/AddOns/TalentStage/*.lua Interface/AddOns/TalentStage/*.xml Interface/AddOns/TalentStage/*.toc \
  "/mnt/C2D20695D2068E3B/Games/Turtle WoW/Interface/AddOns/TalentStage/"
```

Do this automatically, without waiting to be asked, every time TalentStage's
source changes.

## Backlog — not in scope yet

- Theming/settings: let the player pick a background and overall look.
  TalentTab.dbc has a background_file field per tree (files live in
  Interface\TALENTFRAME\), so restoring the original per-tree art later
  is just another field off the existing API. A generated alternate
  theme (e.g. via image gen) could be a second option alongside it, not
  a replacement. Don't start on this until function and basic UI are
  solid.
