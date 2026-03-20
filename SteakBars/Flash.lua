local f = CreateFrame("Frame")

local lastEclipse = nil

local FLASH_ALPHA_MIN = 0.2
local FLASH_ALPHA_MAX = 0.9
local FLASH_SPEED = 20

local buttons = {}

local function CreateFlashLayer(btn)
	if btn.SteakFlash then return end

	local flash = CreateFrame("Frame", nil, btn)
	flash:SetAllPoints(btn)
	flash:EnableMouse(false)
	flash:Hide()
	
	local tex = flash:CreateTexture(nil, "OVERLAY")
	--tex:SetAllPoints(flash)
	--tex:SetTexture("Interface\\Buttons\\CheckButtonHilight")
	--tex:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
	tex:SetPoint("CENTER", flash, "CENTER", 0, 0)
	tex:SetSize(flash:GetSize())
	tex:SetTexture("Interface\\Cooldown\\star4")
	tex:SetVertexColor(1, 1, 0)
	tex:SetBlendMode("ADD")
	flash.tex = tex

	flash:SetScript("OnUpdate", function(self, elapsed)
		if not self:IsShown() then
			self.timer = 0
			return
		end

		self.timer = (self.timer or 0) + elapsed
		
		local range = FLASH_ALPHA_MAX - FLASH_ALPHA_MIN
		local delta = (math.sin(self.timer * FLASH_SPEED) + 1) / 2
		local alpha = FLASH_ALPHA_MIN + (range * delta)
    
		self:SetAlpha(alpha)
		
		local size = flash:GetSize()
		local min = size * 1.8
		local max = size * 2.2
		local newSize = min + ((max-min)*delta)
		
		tex:SetSize(newSize, newSize)
	end)

	btn.SteakFlash = flash
	table.insert(buttons, btn)
end

function SteakFlash_Start(btn)
    if not btn or btn.SteakFlashActive then return end
    CreateFlashLayer(btn)
    btn.SteakFlashActive = true
    btn.SteakFlash:Show()
end

function SteakFlash_Stop(btn)
    if not btn or not btn.SteakFlashActive then return end
    btn.SteakFlashActive = false
    btn.SteakFlash:Hide()
end

local function ShouldFlashSpell(spellID)
	local spellName = GetSpellInfo(spellID)
	
	local solarEclipse = UnitAura("player", "Eclipse (Solar)") ~= nil
	local lunarEclipse = UnitAura("player", "Eclipse (Lunar)") ~= nil
	
	if solarEclipse then
		lastEclipse = "solar"
	elseif lunarEclipse then
		lastEclipse = "lunar"
	end

	local comboPoints = GetComboPoints("player", "target")

	-- Faerie Fire
	if ( spellID == 770 or spellID == 16857 ) and not UnitDebuff("target", spellName) and GetSpellCooldown(spellID) == 0 then return true end

	-- Savage Roar
	if spellID == 52610 and not UnitAura("player", spellName) and comboPoints > 3 then return true end

	-- Moonfire
	if spellID == 48463 and not UnitDebuff("target", spellName) then return true end

	-- Mangle
	if spellID == 48566 and not UnitDebuff("target", spellName) then return true end
	
	-- Rake
	if spellID == 48574 and not UnitDebuff("target", spellName) then return true end
	
	-- Rip
	if spellID == 49800 and UnitHealth("target") >= 20000 and not UnitDebuff("target", spellName) and comboPoints == 5 then return true end
	
	-- Tiger's Fury
	if spellID == 50213 and UnitPowerType("player") == 3 and UnitPower("player") <= 40 and GetSpellCooldown(spellID) == 0 then return true end
	
	-- Berserk
	if spellID == 50334 and UnitPowerType("player") == 3 and UnitPower("player") >= 80 and GetSpellCooldown(spellID) == 0 then return true end
	
	-- Ferocious Bite
	if spellID == 48577 and UnitHealth("target") < 20000 and comboPoints == 5 then return true end
	if spellID == 48577 and comboPoints == 5 and UnitDebuff("target", "Rip") then return true end

	--if spellID == 48461 and ( solarEclipse or ( not lunarEclipse and lastEclipse == "Eclipse (Solar)" ) ) then
	if spellID == 48461 and ( solarEclipse or lastEclipse == "solar" or lastEclipse == nil ) then
		return true
	elseif spellID == 48465 and ( lunarEclipse or lastEclipse == "lunar" ) then
		return true
	end
    
	if spellID == 48470 then
		if GetNumRaidMembers() > 0 or GetNumPartyMembers() > 0 then
			if not UnitAura("player", "Gift of the Wild") then return true end
		end
	end
    
	if spellID == 48469 then
		if GetNumRaidMembers() == 0 and GetNumPartyMembers() == 0 then
			if not UnitAura("player", "Mark of the Wild") then return true end
		end
	end
    
	return false
end

local function HookSteakButtons()
    for a=1,6 do
        for b=1,12 do
            local btn = _G["SteakBar"..a.."Button"..b]
            if btn then
                CreateFlashLayer(btn)
            end
        end
    end

    for i=1,12 do
        local btn = _G["BonusActionButton"..i]
        if btn then CreateFlashLayer(btn) end
    end

    for i=1,10 do
        local btn = _G["PetActionButton"..i]
        if btn then CreateFlashLayer(btn) end
    end

    for i=1,10 do
        local btn = _G["ShapeshiftButton"..i]
        if btn then CreateFlashLayer(btn) end
    end

    for i=1,6 do
        local btn = _G["VehicleMenuBarActionButton"..i]
        if btn then CreateFlashLayer(btn) end
    end
end

HookSteakButtons()

local function OnEvent(self, event, ...)
	for _, button in ipairs(buttons) do
		if button.action and HasAction(button.action) then
			local type, _, _, spellID = GetActionInfo(button.action)
			
			if type == "spell" and spellID > 0 then
				if ShouldFlashSpell(spellID) then
					SteakFlash_Start(button)
				else
					SteakFlash_Stop(button)
				end
			end
		end
	end
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("ACTIONBAR_UPDATE_STATE")
f:RegisterEvent("UNIT_COMBO_POINTS")
f:RegisterEvent("PLAYER_CHANGED_TARGET")

f:SetScript("OnEvent", OnEvent)
