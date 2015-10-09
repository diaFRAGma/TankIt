local stance = nil
local go = true
local actionSlotWithShieldSlam = 0
local actionSlotWithRevenge = 0
local actionSlotWithCharge = 0
local actionSlotWithExecute = 0
local actionSlotWithOverpower = 0
local rageHeroicStrike = 15
local rageThunderClap = 20
local rageExecute = 15
local rageSunderArmor = 15

function TankIt()
	go = true
	name, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(1, 1);
	rageHeroicStrike = rageHeroicStrike - currentRank
	name, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(1, 6);
	if currentRank == 3 then currentRank = 4 end
	rageThunderClap = rageThunderClap - currentRank
	name, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(2, 10);
	if currentRank == 1 then rageExecute = 13 end
	if currentRank == 2 then rageExecute = 10 end
	name, iconPath, tier, column, currentRank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(3, 10);
	rageSunderArmor = rageSunderArmor - currentRank

	-- Stance auslesen
	for index = 1, GetNumShapeshiftForms() do
		icon, name, active, castable, spellId = GetShapeshiftFormInfo(index)
		if active then
			stance = name
		end
	end
	
	-- 1 Kampfhaltung
	-- 2 Verteidigungshaltung
	-- 3 Berserkerhaltung
	
	if stance == "Kampfhaltung" then
		if setOffSlots() == true then
			useSturmangriff()
			useBlutrausch()
			useSchlachtruf()
			useHinrichten()
			useUeberwaeltigen()
			useVerwunden()
			useHeldenhafterStoss()
		end
	end
	
	if stance == "Verteidigungshaltung" then
		if setDefSlots() == true then
			useBlutrausch()
			useSchlachtruf()
			--useSchildschlag()
			useRache()
			useHeldenhafterStoss()
			--useDemoralisierungsruf()
			--useSchildblock()
			useRuestungZerreissen()
		end
	end

	if stance == "Berserkerhaltung" then
		--todo
	end
end

function switchToNextTarget()
	TargetNearestEnemy()
	local i = 0
	while IsActionInRange(actionSlotWithRevenge) == 0 do
		TargetNearestEnemy()
		i = i + 1
		if i == 10 then
			do break end
		end
	end
end

function getCooldown(pSpell)
	local i = 1
	while true do
		local spellName, spellRank = GetSpellName(i, BOOKTYPE_SPELL)
		if not spellName then
			do break end
		end
		if spellName == pSpell then
			local start, duration, enabled = GetSpellCooldown(i, BOOKTYPE_SPELL)
			if enabled == 0 then
				-- Der Zauber ist gerade aktiv. Der CD startet erst wenn er verbraucht wurde.
				return -1
			elseif ( start > 0 and duration > 0) then
				-- Der Zauber hat CD.
				return start + duration - GetTime()
			else
				-- Der Zauber hat keinen CD und kann genutzt werden.
				return 0
			end
		end
		i = i + 1
	end
end

function setDefSlots()
	actionSlotWithRevenge = 0
	actionSlotWithShieldSlam = 0
	for i = 1, 108 do
		if GetActionTexture(i) == "Interface\\Icons\\Inv_Shield_05" and GetActionText(i) == nil then
			actionSlotWithShieldSlam = i
		end
		if GetActionTexture(i) == "Interface\\Icons\\Ability_Warrior_Revenge" and GetActionText(i) == nil then
			actionSlotWithRevenge = i
		end
	end
	if actionSlotWithShieldSlam == 0 then
		--DEFAULT_CHAT_FRAME:AddMessage("TankIt konnte Schildschlag nicht in der Aktionsleiste finden.", 1.0, 0.0, 0.0)
		--return false
	end
	if actionSlotWithRevenge == 0 then
		DEFAULT_CHAT_FRAME:AddMessage("TankIt konnte Rache nicht in der Aktionsleiste finden.", 1.0, 0.0, 0.0)
		return false
	end
	return true
end

function setOffSlots()
	actionSlotWithCharge = 0
	actionSlotWithExecute = 0
	actionSlotWithOverpower = 0
	for i = 1, 108 do
		if GetActionTexture(i) == "Interface\\Icons\\Ability_Warrior_Charge" and GetActionText(i) == nil then
			actionSlotWithCharge = i
		end
		if GetActionTexture(i) == "Interface\\Icons\\INV_Sword_48" and GetActionText(i) == nil then
			actionSlotWithExecute = i
		end
		if GetActionTexture(i) == "Interface\\Icons\\Ability_MeleeDamage" and GetActionText(i) == nil then
			actionSlotWithOverpower = i
		end		
	end
	if actionSlotWithCharge == 0 then
		DEFAULT_CHAT_FRAME:AddMessage("TankIt konnte Sturmangriff nicht in der Aktionsleiste finden.", 1.0, 0.0, 0.0)
		return false
	end
	if actionSlotWithExecute == 0 then
		DEFAULT_CHAT_FRAME:AddMessage("TankIt konnte Hinrichten nicht in der Aktionsleiste finden.", 1.0, 0.0, 0.0)
		return false
	end
	if actionSlotWithOverpower == 0 then
		DEFAULT_CHAT_FRAME:AddMessage("TankIt konnte Überwältigen nicht in der Aktionsleiste finden.", 1.0, 0.0, 0.0)
		return false
	end
	return true	
end

function useBlutrausch()
	if stance == "Kampfhaltung" then
		if go and UnitMana("player") < 15 and getCooldown("Blutrausch") == 0 and UnitAffectingCombat("player") == 1 then
			CastSpellByName("Blutrausch")
			go = false
		end
	end
	if stance == "Verteidigungshaltung" then
		if go and UnitMana("player") < 5 and getCooldown("Blutrausch") == 0 then
			CastSpellByName("Blutrausch")
			go = false
		end
	end
end

function useSchlachtruf()
	if go and UnitMana("player") >= 10 and not IsBuffActive("Schlachtruf") then
		CastSpellByName("Schlachtruf")
		go = false
	end
end

function useSchildschlag()
	if go and UnitMana("player") >= 20 and IsUsableAction(actionSlotWithShieldSlam) ~= nil and getCooldown("Schildschlag") == 0 then
		CastSpellByName("Schildschlag")
		switchToNextTarget()
		go = false
	end
end

function useRache()
	if go and UnitMana("player") >= 5 and IsUsableAction(actionSlotWithRevenge) ~= nil and getCooldown("Rache") == 0 then
		CastSpellByName("Rache")
		switchToNextTarget()
		go = false
	end
end

function useHeldenhafterStoss()
	if stance == "Kampfhaltung" then
		if go and UnitMana("player") >= rageHeroicStrike then
			CastSpellByName("Heldenhafter Sto\195\159")
			go = false
		end
	end
	if stance == "Verteidigungshaltung" then
		if go and UnitMana("player") >= 50 then
			CastSpellByName("Heldenhafter Sto\195\159")
			go = false
		end
	end
end

function useDemoralisierungsruf()
	if go and UnitMana("player") >= 10 and UnitName("target") ~= nil and UnitAffectingCombat("player") and not IsBuffActive("Demoralisierungsruf", "target") then
		CastSpellByName("Demoralisierungsruf")
		go = false
	end
end

function useSchildblock()
	if go and UnitMana("player") >= 10 and not IsBuffActive("Schildblock") and getCooldown("Schildblock") == 0 then
		CastSpellByName("Schildblock")
		go = false
	end
end

function useRuestungZerreissen()
	if go and UnitMana("player") >= rageSunderArmor then
		CastSpellByName("R\195\188stung zerrei\195\159en")
		switchToNextTarget()
		go = false
	end
end

function useSturmangriff()
	if go and IsUsableAction(actionSlotWithCharge) ~= nil and getCooldown("Sturmangriff") == 0 and IsActionInRange(actionSlotWithCharge) == 1 then
		CastSpellByName("Sturmangriff")
		go = false
	end
end

function useHinrichten()
	if go and UnitMana("player") >= rageExecute and IsUsableAction(actionSlotWithExecute) ~= nil and IsActionInRange(actionSlotWithExecute) == 1 then
		CastSpellByName("Hinrichten")
		go = false
	end
end

function useUeberwaeltigen()
	if go and UnitMana("player") >= 5 and IsUsableAction(actionSlotWithOverpower) ~= nil and getCooldown("\195\156berw\195\164ltigen") == 0 and IsActionInRange(actionSlotWithOverpower) == 1 then
		CastSpellByName("\195\156berw\195\164ltigen")
		go = false
	end	
end

function useVerwunden()
	if go and UnitMana("player") >= 10 and UnitName("target") ~= nil and UnitAffectingCombat("player") and not IsBuffActive("Verwunden", "target") then
		CastSpellByName("Verwunden")
		go = false
	end
end