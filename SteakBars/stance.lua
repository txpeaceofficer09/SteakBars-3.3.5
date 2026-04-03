local stancebar = CreateFrame("Frame", "SteakStanceBar", UIParent, "SecureHandlerStateTemplate")

local BTN_SIZE = 28

stancebar:SetSize((BTN_SIZE * 10) + (4 * 9), BTN_SIZE)
stancebar:SetPoint("BOTTOM", SteakBar5, "TOP", 0, 4)

RegisterStateDriver(stancebar, "visibility", "[bonusbar:5] hide; show")

for i=1,10 do
	local btn = _G["ShapeshiftButton"..i]

	btn:SetParent(SteakStanceBar)
	btn:SetSize(BTN_SIZE, BTN_SIZE)
	btn:ClearAllPoints()
	btn.ignoreFramePositionManager = true

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
	end
end
