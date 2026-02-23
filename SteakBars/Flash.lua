local f = CreateFrame("Frame")

local SPELL_MOONFIRE      = 48462
local SPELL_INSECT_SWARM  = 48468
local SPELL_FAERIE_FIRE   = 770
local SPELL_STARFALL      = 53201
local SPELL_FORCE_OF_NATURE = 33831
local SPELL_WRATH         = 48461
local SPELL_STARFIRE      = 48465

local ECLIPSE_SOLAR       = 48517
local ECLIPSE_LUNAR       = 48518

local function CreateFlashOverlay(button)
	if button.FlashOverlay then return button.FlashOverlay end

	local glow = button:CreateTexture(nil, "OVERLAY")
	glow:SetTexture("Interface\\SpellActivationOverlay\\IconAlert")
	glow:SetBlendMode("ADD")
	glow:SetAllPoints(button)
	glow:SetAlpha(0)

	button.FlashOverlay = glow
	return glow
end

function FlashButton(button)
	local glow = CreateFlashOverlay(button)
	UIFrameFadeIn(glow, 0.2, glow:GetAlpha(), 1)
end

function StopFlash(button)
	if button.FlashOverlay then
		UIFrameFadeOut(button.FlashOverlay, 0.2, button.FlashOverlay:GetAlpha(), 0)
	end
end

local function GetAllActionButtons()
	local buttons = {}

	for a=1,6 do
		for b=1,12 do
			table.insert(buttons, _G["SteakBar"..a.."Button"..b])
		end
	end

	return buttons
end

local function TargetHasDebuff(spellID)
	for i = 1, 40 do
		local id = select(10, UnitDebuff("target", i))
		if id == spellID then return true end
	end
	return false
end

local function SpellReady(spellID)
	local start, duration = GetSpellCooldown(spellID)
	return (start == 0 or (start + duration) <= GetTime())
end

local function GetEclipseState()
	for i = 1, 40 do
		local _, _, _, _, _, _, _, _, _, id = UnitBuff("player", i)
		if id == ECLIPSE_SOLAR then return "SOLAR" end
		if id == ECLIPSE_LUNAR then return "LUNAR" end
	end
	return nil
end

local function ShouldFlashSpell(spellID)
    local eclipse = GetEclipseState()

    -- DOT maintenance
    if spellID == SPELL_MOONFIRE then
        return not TargetHasDebuff(SPELL_MOONFIRE)
    end

    if spellID == SPELL_INSECT_SWARM then
        return not TargetHasDebuff(SPELL_INSECT_SWARM)
    end

    if spellID == SPELL_FAERIE_FIRE then
        return not TargetHasDebuff(SPELL_FAERIE_FIRE)
    end

    -- Cooldowns
    if spellID == SPELL_STARFALL then
        return SpellReady(SPELL_STARFALL)
    end

    if spellID == SPELL_FORCE_OF_NATURE then
        return SpellReady(SPELL_FORCE_OF_NATURE)
    end

	-- Eclipse rotation
	if spellID == SPELL_WRATH then
		-- Cast Wrath during Lunar Eclipse OR when building toward Lunar
		return eclipse == "LUNAR" or eclipse == nil
	end

	if spellID == SPELL_STARFIRE then
		-- Cast Starfire during Solar Eclipse OR when building toward Solar
		return eclipse == "SOLAR"
	end

	return false
end

local function OnEvent(self, event, ...)
	for _, button in ipairs(GetAllActionButtons()) do
		local action = button.action
		if action then
			local spellID = select(7, GetActionInfo(action))
			if spellID and ShouldFlashSpell(spellID) then
				FlashButton(button)
				print("flash", button:GetName(), spellID)
			else
				StopFlash(button)
			end
		end
	end
end

local function OnUpdate(self, elapsed)
	for _, button in ipairs(GetAllActionButtons()) do
		local action = button.action
		if action then
			local spellID = select(4, GetActionInfo(action))
			if spellID and ShouldFlashSpell(spellID) then
				FlashButton(button)
			else
				StopFlash(button)
			end
		end
	end
end

f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("UNIT_AURA")
f:RegisterEvent("ACTIONBAR_UPDATE_USABLE")
f:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")

--f:SetScript("OnUpdate", OnUpdate)
f:SetScript("OnEvent", OnEvent)
