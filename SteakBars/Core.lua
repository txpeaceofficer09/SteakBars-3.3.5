local f = CreateFrame("Frame", nil, UIParent)

local BTN_SIZE = 28
local buttonOffsets = {0, 36, 60, 48, 12, 24}
local bindings = {
    [2] = {
        [1] = "SHIFT-1",
        [2] = "SHIFT-2",
        [3] = "SHIFT-3",
        [4] = "SHIFT-4",
        [5] = "SHIFT-5",
        [6] = "SHIFT-6",
        [7] = "SHIFT-7",
        [8] = "SHIFT-8",
        [9] = "SHIFT-9",
        [10] = "SHIFT-0",
        [11] = "SHIFT--",
        [12] = "SHIFT-="
    },
    [3] = {
        [1] = "`",
        [2] = "q",
        [3] = "e",
        [4] = "f"
    }
}

for i=1,6 do
    local bar = CreateFrame("Frame", "SteakBar"..i, UIParent, "SecureHandlerStateTemplate")

    bar:SetSize((BTN_SIZE * 12)+(4 * 11), BTN_SIZE)

    if i == 1 then
        bar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 90, 20)
    elseif i % 2 == 0 then
        bar:SetPoint("LEFT", _G["SteakBar"..(i-1)], "RIGHT", 4, 0)
    else
        bar:SetPoint("BOTTOM", _G["SteakBar"..(i-2)], "TOP", 0, 4)
    end

    if i == 1 then
        RegisterStateDriver(bar, "visibility", "[bonusbar:1][bonusbar:2][bonusbar:3][bonusbar:4][bonusbar:5] hide; show")
    else
        RegisterStateDriver(bar, "visibility", "[bonusbar:5] hide; show")
    end
end

local prefixes = {
	--"ActionButton",
	"SteakBar1Button",
	"SteakBar2Button",
	"SteakBar3Button",
	"SteakBar4Button",
	"SteakBar5Button",
	"SteakBar6Button",
}

for a, prefix in ipairs(prefixes) do
	for b=1,12 do
		local btn = _G[prefix..b]
		local bar = _G["SteakBar"..a]

	if not btn then
		local actionID = buttonOffsets[a]+b

		btn = CreateFrame("CheckButton", prefix..b, bar, "ActionBarButtonTemplate")

		btn:SetSize(BTN_SIZE, BTN_SIZE)
		btn:SetAttribute("action", actionID)
		btn.action = actionID
		btn:SetID(actionID)

		btn:Show()
	end

        btn:SetParent(bar)
        btn:SetSize(BTN_SIZE, BTN_SIZE)
        btn:ClearAllPoints()
        btn:SetAttribute("buttonlock", true)
        btn:SetAttribute("showgrid", 0)
        btn:SetAttribute("statehidden", false)

        local key = bindings[a] and bindings[a][b]
        local hotkey = _G[btn:GetName().."HotKey"]

        if key then
            SetBindingClick(key, btn:GetName())
            --SetOverrideBindingClick(btn, true, key, btn:GetName(), "LeftButton")

            local text = key:gsub("SHIFT", "s")

            hotkey:SetText(text)
            hotkey:SetPoint("TOPLEFT", btn, "TOPLEFT", -2, -2)
            hotkey:Show()
        else
            hotkey:SetText(RANGE_INDICATOR)
            hotkey:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -2)
            hotkey:Show()
        end

	--btn:SetNormalTexture(nil)
	local nt = _G[btn:GetName().."NormalTexture"]
	if nt then
		nt:SetAllPoints(btn)
		nt:Hide()
		nt:SetAlpha(0)
		btn:SetNormalTexture("")
	end

	if b == 1 then
            btn:SetPoint("LEFT", bar, "LEFT", 0, 0)
        else
            btn:SetPoint("LEFT", _G[prefix..(b-1)], "RIGHT", 4, 0)
        end

        btn:Show()
    end
end

local bonusbar = CreateFrame("Frame", "SteakBonusBar", UIParent, "SecureHandlerStateTemplate")

bonusbar:SetSize((BTN_SIZE * 12) + (4 * 11), BTN_SIZE)
bonusbar:SetPoint("LEFT", SteakBar1, "LEFT", 0, 0)
RegisterStateDriver(bonusbar, "visibility", "[bonusbar:1][bonusbar:2][bonusbar:3][bonusbar:4] show; hide")

for i=1,12 do
    local btn = _G["BonusActionButton"..i]

    btn:SetParent(SteakBonusBar)
    btn:SetSize(BTN_SIZE, BTN_SIZE)
    btn:ClearAllPoints()
    btn:SetAttribute("buttonlock", true)
    btn:SetAttribute("showgrid", 0)

    local nt = _G[btn:GetName().."NormalTexture"]
    if nt then
        nt:SetAllPoints(btn)
        nt:Hide()
	nt:SetAlpha(0)
        btn:SetNormalTexture("")
    end

    if i == 1 then
        btn:SetPoint("LEFT", bonusbar, "LEFT", 0, 0)
    else
        btn:SetPoint("LEFT", _G["BonusActionButton"..(i-1)], "RIGHT", 4, 0)
    end
end

local petbar = CreateFrame("Frame", "SteakPetBar", UIParent, "SecureHandlerStateTemplate")

petbar:SetSize((BTN_SIZE * 10) + (4 * 9), BTN_SIZE)
petbar:SetPoint("BOTTOM", SteakBar6, "TOP", 0, 4)

RegisterStateDriver(petbar, "visibility", "[@pet,exists] show; hide")

for i=1,10 do
	--local btn = _G["PetActionButton"..i]
	local btn = CreateFrame("CheckButton", "SteakPetBarButton"..i, SteakPetBar, "PetActionButtonTemplate", i)

	--btn:SetParent(SteakPetBar)
	btn:SetSize(BTN_SIZE, BTN_SIZE)
	--btn:ClearAllPoints()

	local nt = _G[btn:GetName().."NormalTexture"]
	if nt then
		nt:SetAllPoints(btn)
		nt:Hide()
		nt:SetAlpha(0)
		btn:SetNormalTexture("")
	end
    
	if i == 1 then
		btn:SetPoint("LEFT", SteakPetBar, "LEFT", 0, 0)
	else
		btn:SetPoint("LEFT", _G["PetActionButton"..(i-1)], "RIGHT", 4, 0)
	end
end

local stancebar = CreateFrame("Frame", "SteakStanceBar", UIParent, "SecureHandlerStateTemplate")

stancebar:SetSize((BTN_SIZE * 10) + (4 * 9), BTN_SIZE)
stancebar:SetPoint("BOTTOM", SteakBar5, "TOP", 0, 4)

for i=1,10 do
	local btn = _G["ShapeshiftButton"..i]
	--local btn = CreateFrame("CheckButton", "SteakStanceBarButton"..i, SteakStanceBar, "ShapeshiftButtonTemplate", i)

	btn:SetParent(SteakStanceBar)
	btn:SetSize(BTN_SIZE, BTN_SIZE)
	btn:ClearAllPoints()

	local nt = _G[btn:GetName().."NormalTexture"]
	if nt then
		nt:SetAllPoints(btn)
		nt:Hide()
		nt:SetAlpha(0)
		btn:SetNormalTexture("")
	end

	if i == 1 then
		btn:SetPoint("LEFT", SteakStanceBar, "LEFT", 0, 0)
	else
		btn:SetPoint("LEFT", _G["ShapeshiftButton"..(i-1)], "RIGHT", 4, 0)
		--btn:SetPoint("LEFT", _G["SteakStanceBarButton"..(i-1)], "RIGHT", 4, 0)
	end
end

local vehiclebar = CreateFrame("Frame", "SteakVehicleBar", UIParent, "SecureHandlerStateTemplate")

vehiclebar:SetPoint("LEFT", SteakBar1, "LEFT", 0, 0)
vehiclebar:SetSize((BTN_SIZE * 6) + (4 * 5), BTN_SIZE)

RegisterStateDriver(vehiclebar, "visibility", "[bonusbar:5] show; hide")

for i=1,6 do
    local btn = _G["VehicleMenuBarActionButton"..i]

    btn:SetParent(SteakVehicleBar)
    btn:SetSize(BTN_SIZE, BTN_SIZE)
    btn:ClearAllPoints()

    local nt = _G[btn:GetName().."NormalTexture"]
    if nt then
        nt:SetAllPoints(btn)
        nt:Hide()
	nt:SetAlpha(0)
        btn:SetNormalTexture("")
    end

    if i == 1 then
        btn:SetPoint("LEFT", vehiclebar, "LEFT", 0, 0)
    else
        btn:SetPoint("LEFT", _G["VehicleMenuBarActionButton"..(i-1)], "RIGHT", 4, 0)
    end
end

local LeaveBtn = CreateFrame("Button", "SteakLeaveVehicleButton", UIParent, "SecureActionButtonTemplate, SecureHandlerStateTemplate")
LeaveBtn:SetSize(BTN_SIZE, BTN_SIZE)
LeaveBtn:SetPoint("LEFT", SteakVehicleBar, "RIGHT", 4, 0)
LeaveBtn:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
LeaveBtn:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
LeaveBtn:SetAttribute("type", "macro")
LeaveBtn:SetAttribute("macrotext", "/leavevehicle\n/dismiss")
RegisterStateDriver(LeaveBtn, "visibility", "[bonusbar:5] show; hide")

local function UpdateBindings()
    for a=2,6 do
        for i=1,12,1 do
            local btn = _G["SteakBar"..a.."Button"..i]
            if btn then
                local id = btn:GetID()

                local hotkey = _G[btn:GetName().."HotKey"]
                local key = GetBindingKey("STEAKBAR"..a.."BUTTON"..i)
                local text = GetBindingText(key, "KEY_", 1)

                if text == "" then
                    hotkey:SetText(RANGE_INDICATOR)
                    hotkey:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -2)
                    --hotkey:Hide()
                    hotkey:Show()
                else
                    hotkey:SetText(text)
                    hotkey:SetPoint("TOPLEFT", btn, "TOPLEFT", -2, -2)
                    hotkey:Show()
                    SetOverrideBindingClick(btn, true, key, btn:GetName(), "LeftButton")
                end
            end
        end
    end
end

local function OnEvent(self, event, ...)
    if event == "ACTIONBAR_PAGE_CHANGED" then
        if GetActionBarPage() ~= 1 then ChangeActionBarPage(1) end
    elseif event == "UPDATE_BINDINGS" then
        UpdateBindings()
    elseif event == "VARIABLES_LOADED" or event == "PLAYER_ENTERING_WORLD" then
        SetActionBarToggles(0, 0, 0, 0, 0)
        SHOW_MULTI_ACTIONBAR_1 = 0
        SHOW_MULTI_ACTIONBAR_2 = 0
        SHOW_MULTI_ACTIONBAR_3 = 0
        SHOW_MULTI_ACTIONBAR_4 = 0
        MultiActionBar_Update()
    elseif event == "PLAYER_LOGIN" then
        for a=2,6 do
            _G["BINDING_HEADER_STEAKBAR"..a] = "SteakBar "..a

            for b=1,12 do
                _G["BINDING_NAME_STEAKBAR"..a.."BUTTON"..b] = "Bar "..a.." Button "..b
            end
        end
        --[[
        BINDING_HEADER_EXTRABAR = "ExtraBar"
        BINDING_NAME_EXTRABARBUTTON1 = "Button 1"
        BINDING_NAME_EXTRABARBUTTON2 = "Button 2"
        BINDING_NAME_EXTRABARBUTTON3 = "Button 3"
        BINDING_NAME_EXTRABARBUTTON4 = "Button 4"
        BINDING_NAME_EXTRABARBUTTON5 = "Button 5"
        BINDING_NAME_EXTRABARBUTTON6 = "Button 6"
        BINDING_NAME_EXTRABARBUTTON7 = "Button 7"
        BINDING_NAME_EXTRABARBUTTON8 = "Button 8"
        BINDING_NAME_EXTRABARBUTTON9 = "Button 9"
        BINDING_NAME_EXTRABARBUTTON10 = "Button 10"
        BINDING_NAME_EXTRABARBUTTON11 = "Button 11"
        BINDING_NAME_EXTRABARBUTTON12 = "Button 12"
        ]]
    end
end

f:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
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

f:SetScript("OnEvent", OnEvent)

for _, frame in ipairs({MainMenuBar, VehicleMenuBar, MultiBarLeft, MultiBarRight, MultiBarBottomLeft, MultiBarBottomRight}) do
    frame:HookScript("OnShow", function(self) self:Hide() end)
    frame:Hide()
    frame:UnregisterAllEvents()
end
