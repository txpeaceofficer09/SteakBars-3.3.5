local BTN_SIZE = 28
local BTN_SCALE = BTN_SIZE / 36
local BTN_SPACING = 4
local buttonOffsets = {0, 36, 60, 48, 12, 24}

local _, class = UnitClass("player")

local bonusbar = CreateFrame("Frame", "SteakBonusBar", UIParent, "SecureHandlerStateTemplate")

bonusbar:SetSize((BTN_SIZE * 12) + (4 * 11), BTN_SIZE)
bonusbar:SetPoint("LEFT", SteakBar1, "LEFT", 0, 0)
RegisterStateDriver(bonusbar, "visibility", "[bonusbar:1][bonusbar:2][bonusbar:3][bonusbar:4] show; hide")

for i=1,12 do
	local btn = _G["BonusActionButton"..i]

	btn:SetParent(SteakBonusBar)
	--btn:SetSize(BTN_SIZE, BTN_SIZE)
	btn:SetSize(36, 36)
	btn:SetScale(BTN_SCALE)
	btn:ClearAllPoints()
	btn:SetAttribute("buttonlock", true)
	btn:SetAttribute("showgrid", 0)

	--[[
	local nt = _G[btn:GetName().."NormalTexture"]
	if nt then
		nt:SetAllPoints(btn)
		nt:Hide()
		nt:SetAlpha(0)
		btn:SetNormalTexture("")
	end
	]]

	if i == 1 then
		btn:SetPoint("LEFT", bonusbar, "LEFT", 0, 0)
	else
		btn:SetPoint("LEFT", _G["BonusActionButton"..(i-1)], "RIGHT", 4, 0)
	end
end
