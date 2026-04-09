local stancebar = CreateFrame("Frame", "SteakStanceBar", UIParent, "SecureHandlerStateTemplate")

local BTN_SIZE = 28

stancebar:SetSize((BTN_SIZE * 10) + (4 * 9), BTN_SIZE)
stancebar:SetPoint("BOTTOM", SteakBar5, "TOP", 0, 4)

RegisterStateDriver(stancebar, "visibility", "[bonusbar:5] hide; show")

for i=1,10 do
	local btn = CreateFrame("CheckButton", "SteakStanceButton"..i, bar, "ActionButtonTemplate, SecureActionButtonTemplate")
	local spell = select(2, GetShapeshiftFormInfo(i))

	btn:SetParent(SteakStanceBar)
	btn:SetSize(BTN_SIZE, BTN_SIZE)
	btn:SetID(i)
	btn:SetAttribute("type", "spell")
	btn:SetAttribute("spell", spell)
	btn:ClearAllPoints()

	local name = _G[btn:GetName().."Name"]
	if name then name:SetAlpha(0) end

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
		btn:SetPoint("LEFT", _G["SteakStanceButton"..(i-1)], "RIGHT", 4, 0)
	end

	btn:SetScript("OnEvent", function(self)
		if InCombatLockdown() then return end

		local icon = _G[self:GetName().."Icon"]
		local texture, _, active = GetShapeshiftFormInfo(self:GetID())

		if texture then
			icon:SetTexture(texture)
			self:Show()
		else
			icon:SetTexture(nil)
			self:Hide()
		end

		local spell = select(2, GetShapeshiftFormInfo(self:GetID()))
		self:SetAttribute("spell", spell)

		self:SetChecked(active)
	end)

	btn:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
	btn:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	btn:RegisterEvent("PLAYER_ENTERING_WORLD")
end
