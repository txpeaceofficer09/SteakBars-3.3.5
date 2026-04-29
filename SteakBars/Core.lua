local f = CreateFrame("Frame", nil, UIParent)

local BTN_SIZE = 36
local BTN_SCALE = 28 / BTN_SIZE
local buttonOffsets = {0, 36, 60, 48, 12, 24}

local _, class = UnitClass("player")
local pages = {
	["DRUID"] = "[bonusbar:5] 11; [bonusbar:1,nostealth] 7; [bonusbar:1,stealth] %s; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["WARRIOR"] = "[bonusbar:5] 11; [bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	["PRIEST"] = "[bonusbar:5] 11; [bonusbar:1] 7;",
	["ROGUE"] = "[bonusbar:5] 11; [bonusbar:1] 7; [form:3] 8;",
	["WARLOCK"] = "[bonusbar:5] 11; [form:2] 7;",
	["DEFAULT"] = "[bonusbar:5] 11; [bar:2] 1; [bar:3] 1; [bar:4] 1; [bar:5] 1; [bar:6] 1;"
}

local function UpdateState(bar)
	if InCombatLockdown() then
		f.updatestates = true
		return
	end

	f.updatestates = nil

	local button

	if bar:GetName() == "SteakBar1" then
		for i=1,12 do
			button = _G["SteakBar1Button"..i]
			bar:SetFrameRef("SteakBar1Button"..i, button)
		end
	
		bar:SetAttribute("_onstate-page", [[
			if newstate == "possess" or newstate == 11 then
				if HasVehicleActionBar() then
					newstate = GetVehicleBarIndex()
				elseif HasTempShapeshiftActionBar() then
					newstate = GetTempShapeshiftBarIndex()
				elseif HasBonusActionBar() then
					newstate = GetBonusBarIndex()
				else
					newstate = 12
				end
			end

			for i=1,12 do
				button = self:GetFrameRef("SteakBar1Button"..i)
				button:SetAttribute("actionpage", tonumber(newstate))
			end
		]])

		local condition = pages["DEFAULT"]
		local page = pages[class]

		if page then
			if class == "DRUID" then
				if IsSpellKnown(33891) then
					page = page:format(7)
				else
					page = page:format(8)
				end
			end
			condition = condition.." "..page
		end
		condition = condition.." 1"

		RegisterStateDriver(bar, "page", condition)
	else
		RegisterStateDriver(bar, "visibility", "[bonusbar:5] hide; show")
	end
end

for a=1,6 do
	local bar = CreateFrame("Frame", "SteakBar"..a, UIParent, "SecureHandlerStateTemplate")

	bar:SetSize((BTN_SIZE * 12)+(4*11), BTN_SIZE)
	bar:SetScale(BTN_SCALE)

	local prefix = "SteakBar"..a.."Button"
	for b=1,12 do
		local btn = _G[prefix..b]
		--local bar = _G["SteakBar"..a]

		if not btn then
			--local actionID = buttonOffsets[a]+b
			local actionID = ((a*12)-12)+b

			btn = CreateFrame("CheckButton", prefix..b, bar, "ActionBarButtonTemplate")

			btn:SetSize(BTN_SIZE, BTN_SIZE)
			btn:SetAttribute("action", actionID)
			btn.action = actionID
			btn:SetID(actionID)

			_G[btn:GetName().."Name"]:Hide() -- Hide macro name
			_G[btn:GetName().."Name"]:SetAlpha(0) -- Hide macro name

			local cdt = btn:CreateFontString(btn:GetName().."CDText", "OVERLAY")
			cdt:SetFont("Fonts\\ARIALN.ttf", 18, "OUTLINE")
			cdt:SetPoint("CENTER", btn, "CENTER", 0, 0)
			cdt:SetSize(btn:GetSize())

			btn:HookScript("OnUpdate", function(self, elapsed)
				local name = self:GetName()
				local start, duration, enable = GetActionCooldown(self.action)
				local cooldown = _G[name.."CDText"]
				local endTime = start+duration
				local remain

				if endTime > GetTime() and duration > 1.5 then
					remain = endTime-GetTime()

					if remain <= 1 then
						cooldown:SetTextColor(1, 0, 0, 1)
					elseif remain <= 2 then
						cooldown:SetTextColor(1, 0.5, 0, 1)
					elseif remain <= 3 then
						cooldown:SetTextColor(1, 1, 0, 1)
					else
						cooldown:SetTextColor(1, 1, 1, 1)
					end

					if (remain/3600) > 1 then
						remain = ceil(remain/3600).."h"
					elseif (remain/60) > 1 then
						remain = ceil(remain/60).."m"
					else
						remain = ("%.1f"):format(remain)
					end

					cooldown:SetText(remain)
					cooldown:Show()
				else
					cooldown:Hide()
				end
			end)
		end

		btn:SetParent(bar)
		btn:SetSize(BTN_SIZE, BTN_SIZE)
		btn:ClearAllPoints()
		btn:SetAttribute("buttonlock", true)
		btn:SetAttribute("showgrid", 1)
		btn:SetAttribute("statehidden", false)
		btn:SetAttribute("checkselfcast", true)
		btn:SetAttribute("checkfocuscast", true)

		if b == 1 then
			btn:SetPoint("LEFT", bar, "LEFT", 0, 0)
		else
			btn:SetPoint("LEFT", _G[prefix..(b-1)], "RIGHT", 4, 0)
		end
	end

	if a == 1 then
		bar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 64, 30)
	elseif a % 2 == 0 then
		bar:SetPoint("LEFT", _G["SteakBar"..(a-1)], "RIGHT", 4, 0)
	else
		bar:SetPoint("BOTTOM", _G["SteakBar"..(a-2)], "TOP", 0, 4)
	end

	UpdateState(bar)
end

local function UpdateBindings()
	--[[
	for i=1,12,1 do
		local btn = _G["SteakBar1Button"..i]
		local hotkey = _G["SteakBar1Button"..i.."HotKey"]

		local key = GetBindingKey("STEAKBAR1BUTTON"..i)
		local text = GetBindingText(key, "KEY_", 1)

		if text == "" then
			hotkey:SetPoint("TOPLEFT", btn, "TOPLEFT", -5, -4)
		else
			hotkey:SetPoint("TOPLEFT", btn, "TOPLEFT", -8, -4)
		end
	end
	]]

	for a=1,6 do
		for i=1,12,1 do
			local btn = _G["SteakBar"..a.."Button"..i]

			if btn then
				local id = btn:GetID()

				local hotkey = _G[btn:GetName().."HotKey"]
				local key = GetBindingKey("STEAKBAR"..a.."BUTTON"..i)
				local text = GetBindingText(key, "KEY_", 1)
					
				if text == "" then
					hotkey:SetText(RANGE_INDICATOR)
					hotkey:SetPoint("TOPLEFT", btn, "TOPLEFT", -5, -4)
					hotkey:Show()					
				else
					hotkey:SetText(text)
					hotkey:SetPoint("TOPLEFT", btn, "TOPLEFT", -8, -4)
					hotkey:Show()
					SetOverrideBindingClick(btn, true, key, btn:GetName(), "LeftButton")
				end
			end
		end
	end
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_TALENT_UPDATE" or event == "GLYPH_UPDATE" then
		for i=1,6 do
			UpdateState(_G["SteakBar"..i])
		end
	end

	if event == "UPDATE_BINDINGS" then
		if not InCombatLockdown() then
			UpdateBindings()
		else
			self.needBindUpdate = true
		end
	elseif event == "VARIABLES_LOADED" or event == "PLAYER_ENTERING_WORLD" then
		SetActionBarToggles(0, 0, 0, 0, 0)
		SHOW_MULTI_ACTIONBAR_1 = 0
		SHOW_MULTI_ACTIONBAR_2 = 0
		SHOW_MULTI_ACTIONBAR_3 = 0
		SHOW_MULTI_ACTIONBAR_4 = 0
		MultiActionBar_Update()
	elseif event == "PLAYER_LOGIN" then
		for a=1,6 do
			_G["BINDING_HEADER_STEAKBAR"..a] = "SteakBar "..a

			for b=1,12 do
				_G["BINDING_NAME_STEAKBAR"..a.."BUTTON"..b] = "Bar "..a.." Button "..b
			end
		end
	end
end

local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer < 0.2 then return end
	self.timer = 0

	if self.needBindUpdate and not InCombatLockdown() then
		UpdateBindings()

		self.needBindUpdate = nil
	end

	if self.updatestates and not InCombatLockdown() then
		for i=1,6 do
			UpdateState(_G["SteakBar"..i])
		end

		self.updatestates = nil
	end
end

--f:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
--f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_BINDINGS")
f:RegisterEvent("PLAYER_LOGIN")
--f:RegisterEvent("PLAYER_LOSES_VEHICLE_DATA")
--f:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA")
--f:RegisterEvent("UNIT_EXITED_VEHICLE")
--f:RegisterEvent("UNIT_ENTERED_VHEICLE")
--f:RegisterEvent("VEHICLE_UPDATED")
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("PLAYER_TALENT_UPDATE")
f:RegisterEvent("GLYPH_UPDATE")
f:RegisterEvent("PLAYER_REGEN_ENABLED")

f:SetScript("OnEvent", OnEvent)
f:SetScript("OnUpdate", OnUpdate)
