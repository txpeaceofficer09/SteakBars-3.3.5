local vehiclebar = CreateFrame("Frame", "SteakVehicleBar", UIParent, "SecureHandlerStateTemplate")

local BTN_SIZE = 28

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
LeaveBtn:SetSize(BTN_SIZE+14, BTN_SIZE+14)
LeaveBtn:SetPoint("RIGHT", SteakPlayerFrame, "LEFT", -4, 0)
LeaveBtn:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
LeaveBtn:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
LeaveBtn:SetAttribute("type", "macro")
LeaveBtn:SetAttribute("macrotext", "/leavevehicle\n/dismiss")

LeaveBtn:RegisterEvent("UNIT_ENTERED_VEHICLE")
LeaveBtn:RegisterEvent("UNIT_EXITED_VEHICLE")
LeaveBtn:RegisterEvent("PLAYER_ENTERING_WORLD")
LeaveBtn:RegisterEvent("PLAYER_LOSES_VEHICLE_DATA")
LeaveBtn:RegisterEvent("PLAYER_GAINS_VEHICLE_DATA")

LeaveBtn:SetScript("OnEvent", function(self, event, ...)
	if CanExitVehicle() then
		self:ClearAllPoints()
		if SteakPetFrame then
			self:SetPoint("RIGHT", SteakPetFrame, "LEFT", -4, 0)
		else
			self:SetPoint("RIGHT", SteakPlayerFrame, "LEFT", -4, 0)
		end
		self:Show()
	else
		self:Hide()
	end
end)
