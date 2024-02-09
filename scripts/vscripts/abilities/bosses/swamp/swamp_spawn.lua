swamp_spawn = class({})

function swamp_spawn:OnSpellStart()
	local caster_pos = self:GetCaster():GetAbsOrigin()
	for i = 1, 4 do
		local angle = RandomInt(0, 360)
		local variance = RandomInt(-700, 700)
		local dy = math.sin(angle) * variance
		local dx = math.cos(angle) * variance
		local target_point = Vector(caster_pos.x + dx, caster_pos.y + dy, caster_pos.z)
		
		local creep = CreateUnitByName( "medusa_ward", target_point, true, nil, nil, DOTA_TEAM_BADGUYS )
		creep:AddNewModifier(creep, nil, "modifier_kill", {duration = 7})
		add_modifier(creep)
	end
end

function add_modifier(unit)
	if diff_wave.wavedef == "Easy" then
		unit:AddNewModifier(unit, nil, "modifier_easy", {})
	end
	if diff_wave.wavedef == "Normal" then
		unit:AddNewModifier(unit, nil, "modifier_normal", {})
	end
	if diff_wave.wavedef == "Hard" then
		unit:AddNewModifier(unit, nil, "modifier_hard", {})
	end	
	if diff_wave.wavedef == "Ultra" then
		unit:AddNewModifier(unit, nil, "modifier_ultra", {})
	end	
	if diff_wave.wavedef == "Insane" then
		unit:AddNewModifier(unit, nil, "modifier_insane", {})
		new_abil_passive = abiility_passive[RandomInt(1,#abiility_passive)]
		unit:AddAbility(new_abil_passive):SetLevel(4)
	end	
	if diff_wave.wavedef == "Impossible" then
		unit:AddNewModifier(unit, nil, "modifier_impossible", {})
		local ability_1 = abiility_passive[RandomInt(1,#abiility_passive)]
		unit:AddAbility(ability_1):SetLevel(4)
		local abilityes = GetRandomAbilities()
		local keys = table.make_key_table(abilityes)
		local GetTalents = function(amount, ability)
			local count = table.count(abilityes[ability])
			if count < amount then
				amount = count
			end
			local talents = {}
			while table.count(talents) < amount do
				local talent, _ = table.random(abilityes[ability])
				if not table.has_value(talents, talent) then
					table.insert(talents, talent)
				end
			end
			return talents
		end
		local GetRandomItems = function(amount)
			local items = {}
			while table.count(items) < amount do
				local item, _ = table.random(avaliable_creeps_items)
				if not table.has_value(items, item) then
					table.insert(items, item)
				end
			end
			return items
		end
		for _, location in pairs(Ability_Impossible_Settings) do
			if table.has_value(location.creeps, unit:GetUnitName()) then
				for i = 1, location.abilityes do
					unit:AddAbility(keys[i]):SetLevel(location.level)
					for _, talent in pairs(GetTalents(location.talents, keys[i])) do
						unit:AddAbility(talent):SetLevel(1)
					end
				end
				for _, item in pairs(GetRandomItems(location.items)) do
					unit:AddItemByName(item):SetLevel(location.items_level)
				end
				unit.bSearchedForItems = false
				unit.bSearchedForSpells = false
				break
			end
		end
	end
end	





