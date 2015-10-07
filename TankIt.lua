local actionSlotWithRevenge = 0

function TankIt()
	local actionSlotWithShieldSlam = 0
	actionSlotWithRevenge = 0
	for i = 1, 108 do
		if GetActionTexture(i) == "Interface\\Icons\\Inv_Shield_05" then
			actionSlotWithShieldSlam = i
		end
		if GetActionTexture(i) == "Interface\\Icons\\Ability_Warrior_Revenge" then
			actionSlotWithRevenge = i
		end
	end
	if actionSlotWithShieldSlam == 0 then
		--DEFAULT_CHAT_FRAME:AddMessage("TankIt konnte Schildschlag nicht in der Aktionsleiste finden.", 1.0, 0.0, 0.0)
		--return
	end
	if actionSlotWithRevenge == 0 then
		DEFAULT_CHAT_FRAME:AddMessage("TankIt konnte Rache nicht in der Aktionsleiste finden.", 1.0, 0.0, 0.0)
		return
	end
	
	-- Blutrausch
	if UnitMana("player") <= 5 and getCooldown("Blutrausch") == 0 then
		CastSpellByName("Blutrausch")
		return
	end
	
	-- Schlachtruf
	if UnitMana("player") >= 10 and not IsBuffActive("Schlachtruf") then
		CastSpellByName("Schlachtruf")
		return
	end
	
	-- Schildschlag
	--if UnitMana("player") >= 20 and IsUsableAction(actionSlotWithShieldSlam) ~= nil and getCooldown("Schildschlag") == 0 then
		--CastSpellByName("Schildschlag")
		--switchToNextTarget()
		--return
	--end
	
	-- Rache
	if UnitMana("player") >= 5 and IsUsableAction(actionSlotWithRevenge) ~= nil and getCooldown("Rache") == 0 then
		CastSpellByName("Rache")
		switchToNextTarget()
		return
	end
	
	-- Heldenhafter Stoß
	if UnitMana("player") >= 50 then
		CastSpellByName("Heldenhafter Sto\195\159")
		return
	end
	
	-- Demoralisierungsruf
	--if UnitMana("player") >= 10 and UnitName("target") ~= nil and UnitAffectingCombat("player") and not IsBuffActive("Demoralisierungsruf", "target") then
		--CastSpellByName("Demoralisierungsruf")
		--return
	--end
	
	-- Schildblock
	--if UnitMana("player") >= 10 and not IsBuffActive("Schildblock") and getCooldown("Schildblock") == 0 then
		--CastSpellByName("Schildblock")
		--return
	--end
	
	-- Rüstung zerreißen
	if UnitMana("player") >= 15 then
		CastSpellByName("R\195\188stung zerrei\195\159en")
		switchToNextTarget()
		return
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