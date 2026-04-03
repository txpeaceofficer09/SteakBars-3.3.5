local petbar = CreateFrame("Frame", "SteakPetBar", UIParent, "SecureHandlerStateTemplate")

local BTN_SIZE = 28

petbar:SetSize((BTN_SIZE * 10) + (4 * 9), BTN_SIZE)
petbar:SetPoint("BOTTOM", SteakBar6, "TOP", 0, 4)

RegisterStateDriver(petbar, "visibility", "[bonusbar:5] hide; [@pet,exists] show; hide")

for i=1,10 do
	local btn = _G["PetActionButton"..i]

	btn:SetParent(SteakPetBar)
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
		btn:SetPoint("LEFT", SteakPetBar, "LEFT", 0, 0)
	else
		btn:SetPoint("LEFT", _G["PetActionButton"..(i-1)], "RIGHT", 4, 0)
	end
end
