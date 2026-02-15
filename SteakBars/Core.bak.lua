local BUTTON_SIZE = 24

local bindings = {
	['SteakBar1'] = {
		[1] = '1',
		[2] = '2',
		[3] = '3',
		[4] = '4',
		[5] = '5',
		[6] = '6',
		[7] = '7',
		[8] = '8',
		[9] = '9',
		[10] = '0',
		[11] = '-',
		[12] = '='
	},
	['SteakBar2'] = {
		[1] = '`',
		[2] = 'q',
		[3] = 'e',
		[4] = 'f'
	},
	['SteakBar3'] = {
		[1] = 'shift-1',
		[2] = 'shift-2',
		[3] = 'shift-3',
		[4] = 'shift-4',
		[5] = 'shift-5',
		[6] = 'shift-6',
		[7] = 'shift-7',
		[8] = 'shift-8',
		[9] = 'shift-9',
		[10] = 'shift-0',
		[11] = 'shift--',
		[12] = 'shift-='
	}
}

local function CreateBar(id)
	if _G["SteakBar"..id] then return _G["SteakBar"..id] end

	local bar = CreateFrame("Frame", "SteakBar"..id, UIParent, "SecureHandlerStateTemplate")

	bar:SetSize(BUTTON_SIZE * 12, BUTTON_SIZE)

	if id == 1 then
		bar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 0, 20)
	elseif id % 2 > 0 then
		bar:SetPoint("LEFT", _G["SteakBar"..(id-1)], "RIGHT", 0, 0)
	else
		bar:SetPoint("BOTTOM", _G["SteakBar"..(id-2)], "TOP", 0, 0)
	end

	bar:Show()
end

local function CreateButton(bar, id)
	if _G[bar:GetName().."Button"..id] then return _G[bar:GetName().."Button"..id] end

	local btn = CreateFrame("CheckButton", bar:GetName().."Button"..id, bar, "ActionBarButtonTemplate")

	if id == 1 then
		btn:SetPoint("LEFT", bar, "LEFT", 0, 0)
	else
		btn:SetPoint("LEFT", _G[bar:GetName().."Button"..(id-1)], "RIGHT", 0, 0)
	end

	btn:SetAttribute("type", "action")
	btn:SetID(id + (id * 12) - 12)

	if bindings and bindings[bar:GetName()] then
		SetBindingClick(bindings[bar:GetName()][id] or "", btn:GetName())
	end

	btn:Show()
end

--[[
for i=1,3,1 do
	local bar = CreateFrame("Frame", "SteakBar"..i)

	bar:SetSize(32*24, 32)

	if i == 1 then
		bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
	else
		bar:SetPoint("BOTTOM", _G["SteakBar"..(i-1)], "TOP", 0, 4)
	end

	for a=1,24,1 do
		local btn = CreateFrame("CheckButton", bar:GetName().."Button"..a, bar, "ActionBarButtonTemplate")

		--btn:SetAttribute("type", "macro")

		if a == 1 then
			btn:SetPoint("LEFT", bar, "LEFT", 0, 0)
		else
			btn:SetPoint("LEFT", _G[bar:GetName().."Button"..(a-1)], "RIGHT", 0, 0)
		end

		btn:Show()
	end

	bar:Show()
end
]]

local f = CreateFrame("Frame")

f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LEAVING_COMBAT")

f:SetScript("OnEvent", function()
	if InCombatLockdown() then return end

	for i=1,6,1 do
		local bar = CreateBar(i) or _G["SteakBar"..i]

		for a=1,12,1 do
			local btn = CreateButton(bar, a)
		end
	end
end)
-- 4. Optional: Save the binding so it persists after logout
--SaveBindings(GetCurrentBindingSet())

-- Events that change macro conditions
--local updater = CreateFrame("Frame")
--updater:RegisterEvent("MODIFIER_STATE_CHANGED")
--updater:RegisterEvent("PLAYER_TARGET_CHANGED")
--updater:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
--updater:RegisterEvent("PLAYER_REGEN_DISABLED")
--updater:RegisterEvent("PLAYER_REGEN_ENABLED")
--updater:RegisterEvent("UNIT_AURA") -- Stealth/Buffs

--updater:SetScript("OnEvent", UpdateAllIcons)

MainMenuBar:HookScript("OnShow", function(self)
	self:Hide()
end)

MainMenuBar:UnregisterAllEvents()

MainMenuBar:Hide()
