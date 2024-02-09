if Rules == nil then
	Rules = class({})
end

function Rules:difficality_modifier(unit)
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
		add_impossible_abilityes(unit)
	end		
end	

timer_spawn_time_don = 2

function Rules:spawn_creeps_don()
	Timers:CreateTimer(function()
		for i= 0,4 do
			check_trigger_actiate("point_donate_creeps_".. i)
		end
		return timer_spawn_time_don
	end)
end

function Rules:spawn_sheep()
t_sheep = {"sheep_point_1","sheep_point_2","sheep_point_4"}
local ent = t_sheep[RandomInt(1,#t_sheep)]
local point = Entities:FindByName(nil,ent):GetAbsOrigin()
local sheep = CreateUnitByName("sheep", point, false, nil, nil, DOTA_TEAM_GOODGUYS)
sheep:AddNewModifier( sheep, nil, "modifier_invulnerable", { } )
sheep:AddNewModifier( sheep, nil, "modifier_hide_on_minimap", { } )
end

function Rules:spawn_lina()
	t_lina = {"lina_point_1","lina_point_2","lina_point_3","lina_point_4","lina_point_5","lina_point_6","lina_point_7"}
	local ent = t_lina[RandomInt(1,#t_lina)]
	local point = Entities:FindByName(nil,ent):GetAbsOrigin()
	local lina = CreateUnitByName("lina", point, false, nil, nil, DOTA_TEAM_GOODGUYS)
	lina:AddNewModifier( lina, nil, "modifier_invulnerable", { } )
	lina:AddNewModifier( lina, nil, "modifier_hide_on_minimap", { } )
	invulnerable()
end


function invulnerable()
	local unit = Entities:FindByName(nil,"npc_boss_plague_squirrel")
	unit:AddNewModifier( unit, nil, "modifier_invulnerable", {} )
	unit:AddNewModifier( unit, nil, "modifier_medusa_stone_gaze_stone", {} )
	unit:AddNewModifier( unit, nil, "modifier_magic_immune", {} )
end

function invulnerable_off()
	local unit = Entities:FindByName(nil,"npc_boss_plague_squirrel")
	unit:RemoveModifierByName( "modifier_invulnerable")
	unit:RemoveModifierByName("modifier_medusa_stone_gaze_stone")
	unit:RemoveModifierByName("modifier_magic_immune")
	_G.Activate_belka = true
	creep_spawner:spawn_farm_zones()
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

_G.necronomicon = 1