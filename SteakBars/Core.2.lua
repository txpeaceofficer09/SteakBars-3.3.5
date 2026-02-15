local bars = {}
local keys = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "="}

for index=1,6 do
	local bar = CreateFrame("Frame", "SteakBar"..index, UIParent, "SecureHandlerStateTemplate")

	bar:SetSize((12*28)+(11*4), 28)

	if index == 1 then
		bar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 0, 20)
	elseif index % 2 > 0 then
		bar:SetPoint("LEFT", _G["SteakBar"..(index - 1)], "RIGHT", 4, 0)
	else
		bar:SetPoint("BOTTOM", _G["SteakBar"..(index - 2)], "TOP", 0, 4)
	end

	for i=1,12 do
		local actionID = ((index - 1) * 12) + i
		local btn = CreateFrame("CheckButton", "SteakBar"..index.."Button"..i, bar, "ActionBarButtonTemplate")

		btn:SetSize(28, 28)

		if i == 1 then
			btn:SetPoint("LEFT", bar, "LEFT", 0, 0)
		else
			btn:SetPoint("LEFT", _G["SteakBar"..index.."Button"..(i-1)], "RIGHT", 4, 0)
		end

		btn:SetID(i)
		btn:SetAttribute("action", actionID)
		btn:SetAttribute("buttonlock", true)

		if index == 1 then
			bar:SetFrameRef("Btn"..i, btn)
			btn:SetAttribute("parameter", "PAGE")
		end
	end

	if index > 1 then
		RegisterStateDriver(bar, "visibility", "[bonusbar:1] hide; [bonusbar:5] hide; show")
	end

	bars[index] = bar
end

bars[1]:SetAttribute("_onstate-page", [[
    local page = newstate
    for i = 1, 12 do
        local btn = self:GetFrameRef("Btn"..i)
	if btn then
	        btn:SetAttribute("action", (page - 1) * 12 + i)
	end
    end
]])

local class = select(2, UnitClass("player"))
local driver = ""

-- Priority logic for all classes
-- [bonusbar:5] = Vehicles (Grand Black War Bear, Siege Engines, etc.)
-- [bonusbar:1] = Possess / Mind Control / Certain Quest Vehicles
-- Page 11 = Action IDs 121-132 (Standard for Vehicle/Possess)

if class == "DRUID" then
    -- Vehicle/Possess > Prowl > Cat > Bear > Default
    driver = "[bonusbar:5] 11; [bonusbar:1] 11; [form:3, stealth] 8; [form:3] 7; [form:1] 9; 1"
elseif class == "WARRIOR" then
    -- Vehicle/Possess > Stances
    driver = "[bonusbar:5] 11; [bonusbar:1] 11; [form:3] 3; [form:2] 2; [form:1] 1; 1"
elseif class == "ROGUE" then
    -- Vehicle/Possess > Stealth
    driver = "[bonusbar:5] 11; [bonusbar:1] 11; [stealth] 7; [form:1] 7; 1"
elseif class == "PRIEST" then
    -- Vehicle/Possess > Shadowform
    driver = "[bonusbar:5] 11; [bonusbar:1] 11; [form:1] 7; 1"
else
    -- Standard classes
    driver = "[bonusbar:5] 11; [bonusbar:1] 11; 1"
end

RegisterStateDriver(bars[1], "page", driver)

local f = CreateFrame("Frame")

f:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
f:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

f:SetScript("OnEvent", function()
	for i = 1, 12 do
		local btn = _G["SteakBar1Button"..i]
		if btn then
			-- This forces the Blizzard engine to redraw the icon and range check
			ActionButton_Update(btn)
		end
	end

	if event == "PLAYER_ENTERING_WORLD" then
        for b = 2, 6 do
            for i = 1, 12 do
                local btn = _G["SteakBar"..b.."Button"..i]
                if btn then ActionButton_Update(btn) end
            end
        end
    end
	--if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN" then
	--	for i=1,12 do
	--		SetOverrideBinding(MainBar, true, keys[i], "CLICK "..btn:GetName()..":LeftButton")
	--	end
	--end
end)

local LeaveBtn = CreateFrame("Button", "SteakLeaveVehicleButton", UIParent, "SecureActionButtonTemplate, SecureHandlerStateTemplate")
LeaveBtn:SetSize(36, 36)
-- Position it to the right of your 12th button
LeaveBtn:SetPoint("TOPLEFT", _G["SteakBar1"], "TOPLEFT", 0, 4)

-- Appearance
LeaveBtn:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
LeaveBtn:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
LeaveBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")

-- Logic: Execute the leave command
LeaveBtn:SetAttribute("type", "macro")
LeaveBtn:SetAttribute("macrotext", "/leavevehicle\n/dismiss")

-- 2. Setup the Visibility Driver
-- This button only shows if bonusbar 1 (Possess) or 5 (Vehicle) is active
RegisterStateDriver(LeaveBtn, "visibility", "[bonusbar:1] show; [bonusbar:5] show; hide")

MainMenuBar:HookScript("OnShow", function(self) self:Hide() end)
MainMenuBar:Hide()