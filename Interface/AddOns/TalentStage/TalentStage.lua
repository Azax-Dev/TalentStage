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
	sandboxText  = { 0.941, 0.659, 0.408 },
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
TS.sandboxMode = false
TS.sandboxConfirmed = {} -- sandboxConfirmed[tab][idx] = fake-confirmed rank count
TS.CONFIRM_FLASH_DURATION = 0.5
TS.TIER_FLASH_DURATION = 0.6
TS.tierUnlockState = {} -- tierUnlockState[tab][tier] = last known IsTierUnlocked
                        -- result, so Refresh can detect a locked<->unlocked
                        -- transition and flash the whole row once, instead of
                        -- the color just snapping between grey and lit.

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

				-- lock-in "swirl": a small spark that orbits the button fast
				-- (vanilla has no texture rotation, so this fakes it by moving
				-- the anchor point around a circle each frame) and fades out
				local swirl = btn:CreateTexture(nil, "OVERLAY")
				swirl:SetTexture("Interface\\Buttons\\WHITE8X8")
				swirl:SetWidth(11)
				swirl:SetHeight(11)
				swirl:SetBlendMode("ADD")
				swirl:SetVertexColor(1, 0.85, 0.3)
				swirl:SetAlpha(0)
				btn.swirl = swirl

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
	title:SetPoint("TOP", TalentStageFrame, "TOP", 0, -14)
	title:SetTextColor(TS.COLOR.goldBright[1], TS.COLOR.goldBright[2], TS.COLOR.goldBright[3])
	title:SetText("Talents")
	TalentStageFrame.title = title

	local sandboxLabel = TalentStageFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	sandboxLabel:SetPoint("TOP", title, "BOTTOM", 0, -2)
	sandboxLabel:SetTextColor(TS.COLOR.sandboxText[1], TS.COLOR.sandboxText[2], TS.COLOR.sandboxText[3])
	sandboxLabel:SetText("SANDBOX MODE - not saved to character")
	sandboxLabel:Hide()
	TS.sandboxLabel = sandboxLabel

	TalentStage_BuildImportRow()
	TalentStage_BuildLedger()
	TalentStage_BuildSettings()
end

--------------------------------------------------------------------------
-- Import/export row: matches the rogue-talent-redesign-v2.html mockup's
-- always-visible row above the trees. The actual build-code codec doesn't
-- exist yet (separate future task, see CLAUDE.md "Design reference" /
-- Phase 2 decision) -- these controls are wired to a no-op placeholder for
-- now, not left out, so the layout/chrome can be reviewed as a whole.
--------------------------------------------------------------------------

function TalentStage_ImportExportNoop()
	DEFAULT_CHAT_FRAME:AddMessage("TalentStage: import/export isn't implemented yet.")
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
	exportBtn:SetScript("OnClick", TalentStage_ImportExportNoop)
	TS.exportButton = exportBtn

	local importBtn = CreateFrame("Button", "TalentStageImportButton", row, "UIPanelButtonTemplate")
	importBtn:SetWidth(70)
	importBtn:SetHeight(22)
	importBtn:SetPoint("RIGHT", exportBtn, "LEFT", -6, 0)
	importBtn:SetText("Import")
	importBtn:SetScript("OnClick", TalentStage_ImportExportNoop)
	TS.importButton = importBtn

	local editBg = CreateFrame("Frame", "TalentStageImportBox", row)
	editBg:SetPoint("LEFT", row, "LEFT", 0, -4)
	editBg:SetPoint("RIGHT", importBtn, "LEFT", -8, 0)
	editBg:SetHeight(22)
	editBg:SetBackdrop(TS.INPUT_BACKDROP)
	editBg:SetBackdropColor(TS.COLOR.panel2[1], TS.COLOR.panel2[2], TS.COLOR.panel2[3], 0.9)
	editBg:SetBackdropBorderColor(TS.COLOR.edgeBright[1], TS.COLOR.edgeBright[2], TS.COLOR.edgeBright[3], 1)

	local edit = CreateFrame("EditBox", "TalentStageImportEditBox", editBg)
	edit:SetAutoFocus(false)
	edit:SetFontObject(ChatFontNormal)
	edit:SetPoint("LEFT", editBg, "LEFT", 8, 0)
	edit:SetPoint("RIGHT", editBg, "RIGHT", -8, 0)
	edit:SetHeight(18)
	edit:SetTextColor(TS.COLOR.parchment[1], TS.COLOR.parchment[2], TS.COLOR.parchment[3])
	edit:SetScript("OnEscapePressed", function() this:ClearFocus() end)
	TS.importEditBox = edit

	TS.importRow = row
end

--------------------------------------------------------------------------
-- Settings: currently just the dev sandbox toggle. The gear icon/panel is
-- deliberately generic so future real settings (theme, etc, see CLAUDE.md
-- backlog) can be added as more rows without restructuring this.
--
-- Left visible for now for in-progress testing (was hidden briefly during
-- Phase 2, see CLAUDE.md "Design reference" decision, 2026-08-22, which
-- expects it to go away once sandbox mode is no longer needed for dev
-- testing) -- `gear:Hide()` is the one line to remove it again later.
--------------------------------------------------------------------------

function TalentStage_BuildSettings()
	local gear = CreateFrame("Button", "TalentStageSettingsButton", TalentStageFrame)
	gear:SetWidth(22)
	gear:SetHeight(22)
	gear:SetPoint("TOPLEFT", TalentStageFrame, "TOPLEFT", 6, -6)
	local gearTex = gear:CreateTexture(nil, "ARTWORK")
	gearTex:SetAllPoints(gear)
	-- a real trade-skill icon rather than "Interface\Buttons\UI-OptionsButton":
	-- that path doesn't exist in the 1.12 client (renders blank), this one is
	-- guaranteed present and reads as a gear/cog at a glance
	gearTex:SetTexture("Interface\\Icons\\Trade_Engineering")
	gearTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	gear:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	gear:SetScript("OnClick", TalentStage_ToggleSettingsPanel)

	-- parented to UIParent (not TalentStageFrame) and given its own toplevel
	-- strata so its size/position are never constrained by the talent frame's
	-- own (dynamic, often narrower-than-220) bounds
	local panel = CreateFrame("Frame", "TalentStageSettingsPanel", UIParent)
	panel:SetWidth(210)
	panel:SetHeight(96)
	panel:SetPoint("TOPLEFT", gear, "BOTTOMLEFT", -4, -6)
	panel:SetFrameStrata("DIALOG")
	panel:SetToplevel(true)
	TalentStage_ApplyPlainBackdrop(panel, 0.95)
	panel:Hide()
	TS.settingsPanel = panel

	local heading = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	heading:SetPoint("TOPLEFT", panel, "TOPLEFT", 12, -10)
	heading:SetText("Settings")

	local sandboxCheck = CreateFrame("CheckButton", "TalentStageSandboxCheck", panel, "UICheckButtonTemplate")
	sandboxCheck:SetPoint("TOPLEFT", heading, "BOTTOMLEFT", -2, -8)
	getglobal("TalentStageSandboxCheckText"):SetText("Sandbox mode (dev)")
	sandboxCheck:SetScript("OnClick", TalentStage_ToggleSandboxMode)
	TS.sandboxCheck = sandboxCheck

	local resetBtn = CreateFrame("Button", "TalentStageSandboxResetButton", panel, "UIPanelButtonTemplate")
	resetBtn:SetWidth(150)
	resetBtn:SetHeight(22)
	resetBtn:SetPoint("TOP", sandboxCheck, "BOTTOM", 2, -16)
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

function TalentStage_ResetSandbox()
	if TS.processing then return end
	TS.sandboxConfirmed = {}
	-- also drop any staged-but-unconfirmed picks: "reset" means a fully
	-- blank tree, not just undoing confirmed fake points
	TS.staged = {}
	if TS.sandboxLabel then
		if TS.sandboxMode then TS.sandboxLabel:Show() else TS.sandboxLabel:Hide() end
	end
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

	-- fills the whole ledger bar (the same box that holds the staged/unspent
	-- text and the Clear/Confirm buttons) while a confirm queue is draining;
	-- Clear/Confirm are hidden for that span (they're inert anyway,
	-- TS.processing blocks their handlers) so the entire box reads as one
	-- active progress bar instead of text plus two dead buttons.
	--
	-- Plain texture regions owned directly by `bar`, not a separate child
	-- frame: a child frame always draws above its parent's own regions
	-- regardless of creation order, which would bury ledgerText (owned by
	-- `bar`) under the fill. Regions on the same frame instead layer by their
	-- draw-layer (BACKGROUND < BORDER < ARTWORK < OVERLAY), so keeping the
	-- fill at BORDER and the text at OVERLAY keeps the text on top reliably.
	local progressBg = bar:CreateTexture(nil, "BACKGROUND")
	progressBg:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, -2)
	progressBg:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)
	progressBg:SetTexture(TS.COLOR.lockedBg[1], TS.COLOR.lockedBg[2], TS.COLOR.lockedBg[3], 0.9)
	progressBg:Hide()
	TS.progressBg = progressBg

	local progressFill = bar:CreateTexture(nil, "BORDER")
	progressFill:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, -2)
	progressFill:SetHeight(TS.LEDGER_HEIGHT - TS.MARGIN - 4)
	progressFill:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
	progressFill:SetVertexColor(TS.COLOR.gold[1], TS.COLOR.gold[2], TS.COLOR.gold[3])
	progressFill:SetWidth(1)
	progressFill:Hide()
	TS.progressFill = progressFill
	TS.progressBarWidth = function() return bar:GetWidth() - 4 end
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
	if TS.sandboxMode then return 999 end
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
			if effRank < 1 then
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

		-- Detect a row's lock state flipping since the last refresh and flash
		-- every button in that row once: gold on unlock, red on re-lock (it
		-- still ends up grey either way once the flash decays -- the static
		-- lit/grey color below is unaffected by this, it's a one-shot overlay
		-- on top). Skipped on this tab's very first refresh (prev == nil) so
		-- opening the panel doesn't flash every already-unlocked row.
		if not TS.tierUnlockState[tab] then TS.tierUnlockState[tab] = {} end
		local tierState = TS.tierUnlockState[tab]
		for tier, row in pairs(panel.nodes) do
			local unlocked = TalentStage_IsTierUnlocked(tab, tier)
			local prev = tierState[tier]
			if prev ~= nil and prev ~= unlocked then
				local r, g, b
				if unlocked then r, g, b = 1, 0.85, 0.1 else r, g, b = 0.9, 0.15, 0.15 end
				for _, rowIdx in pairs(row) do
					local rowBtn = panel.buttons[rowIdx]
					if rowBtn then
						rowBtn.tierFlashElapsed = 0
						rowBtn.tierFlashColor = { r, g, b }
					end
				end
			end
			tierState[tier] = unlocked
		end

		for idx, btn in pairs(panel.buttons) do
			local realName, icon, tier, column, rank, maxRank = GetTalentInfo(tab, idx)
			local d = panel.info[idx]
			d.rank, d.maxRank = rank, maxRank

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

	if TS.processing then
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
			TS.ledgerText:SetText("Applying "..applying.." of "..TS.queueTotal.." -- "..name)
		else
			TS.ledgerText:SetText("Applying "..applying.." of "..TS.queueTotal.."...")
		end
		TS.ledgerText:SetTextColor(TS.COLOR.goldBright[1], TS.COLOR.goldBright[2], TS.COLOR.goldBright[3])

		local frac = applying / TS.queueTotal
		local fullWidth = TS.progressBarWidth()
		local w = fullWidth * frac
		if w < 1 then w = 1 end
		TS.progressFill:SetWidth(w)

		-- progress bar fills the whole ledger box while a confirm run is
		-- draining, so that space stays doing something useful instead of
		-- showing two disabled buttons
		TS.confirmButton:Hide()
		TS.clearButton:Hide()
		TS.progressBg:Show()
		TS.progressFill:Show()
	else
		TS.ledgerText:SetText("Staged: "..total.."   Unspent: "..(available - total).." / "..available)
		TS.ledgerText:SetTextColor(TS.COLOR.parchment[1], TS.COLOR.parchment[2], TS.COLOR.parchment[3])
		TS.progressBg:Hide()
		TS.progressFill:Hide()
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
					local met = pEffRank >= 1
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
			this.swirl:SetAlpha(0)
		else
			this.glow:SetAlpha(1 - t)

			-- bloom outward 20% of the button's own size at the moment it
			-- locks in, then shrink back down to the normal 4px border as
			-- the flash decays, for a punchier "lock-in" pop
			local bloom = 4 + (this:GetWidth() * 0.2 * (1 - t))
			this.glow:ClearAllPoints()
			this.glow:SetPoint("TOPLEFT", this, "TOPLEFT", -bloom, bloom)
			this.glow:SetPoint("BOTTOMRIGHT", this, "BOTTOMRIGHT", bloom, -bloom)

			-- gold-hot at the peak, cooling back to plain white as it fades
			this.glow:SetVertexColor(1, 0.85 + 0.15 * t, 0.5 + 0.5 * t)

			-- swirl: a spark orbiting the button's edge, fading out as the
			-- flash decays. Eased (ease-out) angular speed instead of a
			-- constant one: fast on the outer laps, slowing into the finish,
			-- which reads far smoother than a constant-speed spin at the
			-- variable, often-low frame rates this client actually renders at.
			local radius = (this:GetWidth() / 2) + 12
			local eased = 1 - (1 - t) * (1 - t)
			local angle = eased * 2.5 * 2 * math.pi -- ~2.5 laps over the flash
			this.swirl:ClearAllPoints()
			this.swirl:SetPoint("CENTER", this, "CENTER", radius * math.cos(angle), radius * math.sin(angle))
			this.swirl:SetAlpha(1 - t)
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
		this.glowPhase = (this.glowPhase or 0) + arg1
		local a = 0.35 + 0.35 * math.abs(math.sin(this.glowPhase * 3))
		this.glow:SetAlpha(a)
	end
end

function TalentStage_Stage(tab, idx)
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

	PlaySound("igMainMenuOptionCheckBoxOn")
	TalentStage_Refresh()
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
	else
		DEFAULT_CHAT_FRAME:AddMessage("TalentStage: /ts dump - dump live GetTalentInfo/GetTalentPrereqs data to a copy box and SavedVariables. /ts testconnectors - show a synthetic diagonal-connector test panel.")
	end
end
