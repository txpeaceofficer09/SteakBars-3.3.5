local bars = {}
local keys = {
    {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "="},
    {"`", "q", "e", "f"},
    {"SHIFT-1", "SHIFT-2", "SHIFT-3", "SHIFT-4", "SHIFT-5", "SHIFT-6", "SHIFT-7", "SHIFT-8", "SHIFT-9", "SHIFT-0", "SHIFT--", "SHIFT-="}
}

local barOffsets = {0, 36, 60, 48, 12, 24}

for index=1,6 do
    local bar = CreateFrame("Frame", "SteakBar"..index, UIParent, "SecureHandlerStateTemplate")
    bar:SetSize((12*28)+(11*4), 28)
    bar:SetFrameStrata("MEDIUM")

    -- Your Positioning - Maintained exactly
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
        --local btn = CreateFrame("CheckButton", "SteakBar"..index.."Button"..i, bar, "SecureActionButtonTemplate, ActionButtonTemplate")

        btn:SetSize(28, 28)
        btn:SetID(i)
        btn.action = actionID 

        btn:SetAttribute("action", actionID)
        btn:SetAttribute("buttonlock", true)
        btn:SetAttribute("showgrid", 0)

        -- FIX: Remove the "Normal" texture which often causes the weird borders/scaling issues
        local nt = _G[btn:GetName().."NormalTexture"]
        if nt then
            nt:SetAllPoints(btn)
            nt:Hide() -- Hides the bulky default border
            btn:SetNormalTexture("") -- Clears the default texture reference
        end

        if i == 1 then
            btn:SetPoint("LEFT", bar, "LEFT", 0, 0)
        else
            btn:SetPoint("LEFT", _G["SteakBar"..index.."Button"..(i-1)], "RIGHT", 4, 0)
        end

        if index == 1 then
            bar:SetFrameRef("Btn"..i, btn)
            btn:SetScript("OnAttributeChanged", function(self, name, value)
                if name == "action" then
                    self.action = value
                    ActionButton_Update(self)
                end
            end)
        else
            btn.buttonType = "MULTIBAR" 
            btn:UnregisterEvent("ACTIONBAR_PAGE_CHANGED")
        end
        btn:Show() -- Force the button to show
    end

    if index > 1 then
        RegisterStateDriver(bar, "visibility", "[bonusbar:5] hide; show")
    end
    bars[index] = bar
    bar:Show() -- Force the bar container to show
end

-- Bar 1 Paging Logic
bars[1]:SetAttribute("_onstate-page", [[
    local page = newstate
    for i = 1, 12 do
        local btn = self:GetFrameRef("Btn"..i)
        if btn then
            btn:SetAttribute("action", ((page - 1) * 12) + i)
        end
    end
]])

local class = select(2, UnitClass("player"))
local driver = "[bonusbar:5] 11; "
if class == "DRUID" then
    -- Correcting form logic for 3.3.5a
    driver = driver .. "[stance:3, stealth] 8; [bonusbar:1] 7; [bonusbar:3] 9; [bonusbar:4] 10; [bonusbar:2] 11; 1"
elseif class == "WARRIOR" then
    driver = driver .. "[bonusbar:1] 1; [bonusbar:2] 2; [bonusbar:3] 3; 1"
elseif class == "ROGUE" then
    driver = driver .. "[bonusbar:1] 7; 1"
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
    --[[for b = 1, 6 do
        for i = 1, 12 do
            local btn = _G["SteakBar"..b.."Button"..i]
            if btn then
                ActionButton_Update(btn)
                if b == 1 and event == "PLAYER_ENTERING_WORLD" then
                    --SetOverrideBinding(bars[1], true, keys[i], "CLICK "..btn:GetName()..":LeftButton")
                end
            end
        end
    end]]
    if event == "PLAYER_ENTERING_WORLD" then
        for b, bar in ipairs(keys) do
            for i, binding in ipairs(bar) do
                local btn = _G["SteakBar"..b.."Button"..i]
                SetOverrideBinding(bars[b], true, keys[b][i], "CLICK "..btn:GetName()..":LeftButton")
                --SetBindingClick(binding, "SteakBar"..b.."Button"..i)
            end
        end
    end

    for b=1,6 do
        for i=1,12 do
            ActionButton_Update(_G["SteakBar"..b.."Button"..i])
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
RegisterStateDriver(LeaveBtn, "visibility", "[bonusbar:5] show; hide")

-- Final UI Hiding
for _, frame in ipairs({MainMenuBar, VehicleMenuBar}) do
    frame:Hide()
    frame:HookScript("OnShow", function(self) self:Hide() end)
    --frame:UnregisterAllEvents()
end