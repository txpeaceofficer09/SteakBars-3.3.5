local bars = {}
local keys = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "="}
local barOffsets = {0, 36, 60, 48, 12, 24}

for index=1,6 do
    local bar = CreateFrame("Frame", "SteakBar"..index, UIParent, "SecureHandlerStateTemplate")
    bar:SetSize((12*28)+(11*4), 28)

    -- Your Positioning
    if index == 1 then
        bar:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOM", 0, 20)
    elseif index % 2 > 0 then
        bar:SetPoint("LEFT", _G["SteakBar"..(index - 1)], "RIGHT", 4, 0)
    else
        bar:SetPoint("BOTTOM", _G["SteakBar"..(index - 2)], "TOP", 0, 4)
    end

    for i=1,12 do
        local actionID = barOffsets[index] + i
        local btn = CreateFrame("CheckButton", "SteakBar"..index.."Button"..i, bar, "ActionBarButtonTemplate")

        btn:SetSize(28, 28)
        btn:SetID(actionID)
        btn.action = actionID -- Initialize Lua property

        btn:SetAttribute("action", actionID)
        btn:SetAttribute("buttonlock", true)
        btn:SetAttribute("showgrid", 1)

        if i == 1 then
            btn:SetPoint("LEFT", bar, "LEFT", 0, 0)
        else
            btn:SetPoint("LEFT", _G["SteakBar"..index.."Button"..(i-1)], "RIGHT", 4, 0)
        end

        if index == 1 then
            bar:SetFrameRef("Btn"..i, btn)
            -- Use a script to sync the Lua .action property whenever the attribute changes
            btn:SetScript("OnAttributeChanged", function(self, name, value)
                if name == "action" then
                    self.action = value
                    ActionButton_Update(self)
                end
            end)
        else
            btn:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
        end
    end

    if index > 1 then
        RegisterStateDriver(bar, "visibility", "[bonusbar:1] hide; [bonusbar:5] hide; show")
    end
    bars[index] = bar
end

-- Bar 1 Paging Logic (Simplified to avoid CallMethod crash)
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
local driver = "[bonusbar:5] 11; [bonusbar:1] 11; "
if class == "DRUID" then
    if IsSpellKnown(24858) then
        driver = driver .. "[stance:3, stealth] 8; [stance:3] 7; [stance:1] 9; [stance:5] 10; 1"
    else
        driver = driver .. "[form:3, stealth] 8; [form:3] 7; [form:1] 9; 1"
    end
elseif class == "WARRIOR" then
    driver = driver .. "[form:3] 3; [form:2] 2; [form:1] 1; 1"
elseif class == "ROGUE" then
    driver = driver .. "[stealth] 7; [form:1] 7; 1"
else
    driver = driver .. "1"
end

RegisterStateDriver(bars[1], "page", driver)

local f = CreateFrame("Frame")
f:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
f:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")

f:SetScript("OnEvent", function(self, event)
    for b = 1, 6 do
        for i = 1, 12 do
            local btn = _G["SteakBar"..b.."Button"..i]
            if btn then
                ActionButton_Update(btn)
                if b == 1 and event == "PLAYER_ENTERING_WORLD" then
                    SetOverrideBinding(bars[1], true, keys[i], "CLICK "..btn:GetName()..":LeftButton")
                end
            end
        end
    end
end)

-- Leave Button
local LeaveBtn = CreateFrame("Button", "SteakLeaveVehicleButton", UIParent, "SecureActionButtonTemplate, SecureHandlerStateTemplate")
LeaveBtn:SetSize(32, 32)
LeaveBtn:SetPoint("LEFT", _G["SteakBar1Button12"], "RIGHT", 10, 0)
LeaveBtn:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
LeaveBtn:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
LeaveBtn:SetAttribute("type", "macro")
LeaveBtn:SetAttribute("macrotext", "/leavevehicle\n/dismiss")
RegisterStateDriver(LeaveBtn, "visibility", "[bonusbar:1] show; [bonusbar:5] show; hide")

MainMenuBar:Hide()