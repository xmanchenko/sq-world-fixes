require("data/data")
if Spawner == nil then
	Spawner = class({})
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
		new_abil_passive = abiility_passive[RandomInt(1,#abiility_passive)]
		unit:AddAbility(new_abil_passive):SetLevel(4)
	end	
	unit:AddNewModifier(unit, nil, "modifier_unit_on_death2", {})
end	

wave = 0
_G.wave_count = 1
rat = 0

count_comandir = 5
count_creeps = 25

line_time = 60

damage_creeps = 6
health = 110
armor = 0.001
magermor = 10
golddrop = 1.5
xp = 2


t_creeps = {"creep_1","creep_2","creep_3","creep_4","creep_5","creep_6","creep_7","creep_8","creep_9","creep_10"}
t_boss = {"boss_1","boss_2","boss_3","boss_5","boss_7","boss_10","boss_6","boss_4","boss_8","boss_9"}  --  порядок боссов!!!!!!!!!
actual_t_boss = {}

function Spawner:Init()
	StartSpawnSchedule()
	StartSpawnSchedule_Lane()
	_G.point_line_spawner = Entities:FindByName( nil, "line_spawner"):GetAbsOrigin()
	if not _G.point_line_spawner then
		_G.point_line_spawner = Vector( -1292, -9245,0)
	end
	Timers:CreateTimer(120,function()
		if spawnCreeps and not _G.kill_invoker then
			Spawn_system()
		end
	end)

	Timers:CreateTimer(RandomInt(150, 300),function()
		if spawnCreeps and not _G.kill_invoker and Spawner:CheckBarracks() then
			CreatePatroolWave()
		end
		return RandomInt(120,300)
	end)
end

function Spawner:CheckBarracks()
	local barack1 = Entities:FindByName( nil, "badguys_creeps")
	local barack2 = Entities:FindByName( nil, "badguys_comandirs")
	local barack3 = Entities:FindByName( nil, "badguys_boss")
	return barack1 ~= nil and barack2 ~= nil and barack3 ~= nil
end
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Spawn_system()
	Timers:CreateTimer(function()
		local barack = Entities:FindByName( nil, "badguys_creeps")  
		if barack == nil then 
			Talents.barakDestroy = true
			wave_count = 0
		end
		
		local barack = Entities:FindByName( nil, "badguys_comandirs")  
		if barack == nil then 
			wave_count = 0
			Talents.barakDestroy = true
		end
		
		local barack = Entities:FindByName( nil, "badguys_boss")  
		if barack == nil then 
			wave_count = 0
			Talents.barakDestroy = true
		end
		wave = wave + 1
		if GameRules:GetGameTime() / 60 < 90 then
			rat = rat + wave_count * 2
		end
		for i = 0, 4 do
			Quests:UpdateCounter("bonus", i, 17, 1)
			Quests:UpdateCounter("bonus", i, 15, 1)
		end
		if wave ~= 0 and wave % 10 == 0 then 
			Spawner:SpawnBosses()
			return line_time
		else
			Spawner:settings()																				
		  return line_time
		end
	end)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Spawner:settings()
	if set_health == 1000000000 and set_damage == 1000000000 then
		goto continue
	end
	wave_new = wave/2
	creeps_name = t_creeps[RandomInt(1,#t_creeps)]	
	health = health * 1.08
	damage_creeps = damage_creeps * 1.08

	set_health = math.floor(health + health*(wave_new/2))
	
	set_health_commandir = set_health * 2
	set_health_boss = set_health * 50
	
	if set_health >= 1000000000 then
		set_health = 1000000000
	end
	
	if set_health_commandir >= 1000000000 then
		set_health_commandir = 1000000000
	end
	
	if set_health_boss >= 2000000000 then
		set_health_boss = 2000000000
	end		
	
	set_damage = math.floor(damage_creeps + damage_creeps*(wave_new/2))
	
	set_damage_commandir = set_damage * 2
	set_damage_boss = set_damage * 20
	
	if set_damage >= 1000000000 then
		set_damage = 1000000000
	end
	
	if set_damage_commandir >= 1000000000 then
		set_damage_commandir = 1000000000
	end
	
	if set_damage_boss >= 2000000000 then
		set_damage_boss = 2000000000
	end		
		
	set_armor = math.floor(wave_new*2^(1.02+wave_new*2*armor) * 1.25 )
 	set_armor_commandir = set_armor * 1.5
	set_armor_boss = set_armor * 2
	
	set_mag_resist = math.floor(magermor + wave_new) * 2
	set_mag_resist_creep = math.min(set_mag_resist / 3, 90)
	set_mag_resist_commandir =  math.min(set_mag_resist / 2.5, 90)
	set_mag_resist_boss =  math.min(set_mag_resist / 2, 90)
	
	xp = xp + 8
	golddrop = golddrop + 5
	::continue::
	Spawner:SpawnCreeps(creeps_name)					
	Spawner:SpawnCommandirs(creeps_name)	
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Spawner:SpawnCreeps(name)
	local barack = Entities:FindByName( nil, "badguys_creeps")  
	if barack ~= nil then 		
		local point = _G.point_line_spawner
		for i = 1, count_creeps do
			local creep = CreateUnitByName_WithoutLags_Lane( name, point, true, nil, nil, DOTA_TEAM_BADGUYS, false )
		end
		creeps_line_notification() 
	end
end

function Spawner:SpawnCommandirs(name)
	local barack = Entities:FindByName( nil, "badguys_comandirs")  
	if barack ~= nil then
		local point = _G.point_line_spawner
		for i = 1, count_comandir do
			local creep = CreateUnitByName_WithoutLags_Lane( "comandir_"..name, point, true, nil, nil, DOTA_TEAM_BADGUYS, true )			
		end
	end
end

function table.copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

function Spawner:SpawnBosses()
	local barack = Entities:FindByName( nil, "badguys_boss")  
	if barack ~= nil then
	
		if #actual_t_boss == 0 then
			actual_t_boss = table.copy(t_boss)
		end
		name = actual_t_boss[1]	
		for i,k in pairs(actual_t_boss) do
			if name == k then
				table.remove(actual_t_boss, i)
			end
		end

		local point = _G.point_line_spawner + RandomVector(RandomInt(50, 250))
		local creep = CreateUnitByName( name, point, true, nil, nil, DOTA_TEAM_BADGUYS )
		FindClearSpaceForUnit(creep, point, false)
		creep:SetBaseDamageMin(set_damage_boss)
		creep:SetBaseDamageMax(set_damage_boss)
		creep:SetPhysicalArmorBaseValue(set_armor_boss)
		creep:SetBaseMagicalResistanceValue(set_mag_resist_boss)
		creep:SetMaxHealth(set_health_boss)
		creep:SetBaseMaxHealth(set_health_boss)
		creep:SetHealth(set_health_boss)		
		creep:SetDeathXP(xp*3)
		
		local total_hp = creep:GetMaxHealth()
		local porog_hp = 20000000
		local stack_modifier = math.floor(total_hp/porog_hp)
		
		if total_hp >= porog_hp then
			total_hp = porog_hp
			creep:SetBaseMaxHealth(total_hp)
			creep:SetMaxHealth(total_hp)
			creep:SetHealth(total_hp)
			creep:AddNewModifier(creep, nil, "modifier_health", nil):SetStackCount(stack_modifier)
		end      

		creep:AddNewModifier(creep, nil, "modifier_attack_speed", nil):SetStackCount(wave * 2)
		creep:AddNewModifier(creep, nil, "modifier_spell_ampl_creep", nil):SetStackCount(wave * 2)
		creep:AddNewModifier(creep, nil, "modifier_hp_regen_boss", nil)
		add_modifier(creep)
		bosses_line_notification(name)  
	end
end

function Spawner:SpawnBaracksBosses(name, position)
	local point
	if position then
		point = position
	else
		point = _G.point_line_spawner + RandomVector(RandomInt(50, 250))
	end
	local creep = CreateUnitByName( name, point, true, nil, nil, DOTA_TEAM_BADGUYS )
	FindClearSpaceForUnit(creep, point, false)
	creep:SetBaseDamageMin(set_damage_boss)
	creep:SetBaseDamageMax(set_damage_boss)
	creep:SetPhysicalArmorBaseValue(set_armor_boss)
	creep:SetBaseMagicalResistanceValue(set_mag_resist_boss)
	creep:SetMaxHealth(set_health_boss)
	creep:SetBaseMaxHealth(set_health_boss)
	creep:SetHealth(set_health_boss)		
	creep:SetDeathXP(xp*3)
	
	local total_hp = creep:GetMaxHealth()
	local porog_hp = 20000000
	local stack_modifier = math.floor(total_hp/porog_hp)
	
	if total_hp >= porog_hp then
		total_hp = porog_hp
		creep:SetBaseMaxHealth(total_hp)
		creep:SetMaxHealth(total_hp)
		creep:SetHealth(total_hp)
		creep:AddNewModifier(creep, nil, "modifier_health", nil):SetStackCount(stack_modifier)
	end      

	creep:AddNewModifier(creep, nil, "modifier_attack_speed", nil):SetStackCount(wave * 2)
	creep:AddNewModifier(creep, nil, "modifier_spell_ampl_creep", nil):SetStackCount(wave * 2)
	creep:AddNewModifier(creep, nil, "modifier_hp_regen_boss", nil)
	add_modifier(creep)
end

------------------------------------------------------------------------------------------------------

function creeps_line_notification()
	for nPlayerID = 0, DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer(nPlayerID) then
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer( nPlayerID ), "WaveNotification", {
			number = wave,
			name = creeps_name,
			description = creeps_name,
			img = "/wave/"..creeps_name..".png",
			})
		end
	end
	rating.wave_name = creeps_name
	rating.wave_count = 0
	rating.wave_need = count_creeps + count_comandir
	CustomGameEventManager:Send_ServerToAllClients( "updateWaveCounter", {need = rating.wave_need, count = rating.wave_count} )
end

function bosses_line_notification(creeps_name)
	for nPlayerID = 0, DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer(nPlayerID) then
			CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer( nPlayerID ), "WaveNotification", {
			number = wave,
			name = creeps_name,
			description = creeps_name,
			img = "/wave/bosses/"..creeps_name..".png",
			})
		end
	end
	rating.wave_name = creeps_name
	rating.wave_count = 0
	rating.wave_need = 1
	CustomGameEventManager:Send_ServerToAllClients( "updateWaveCounter", {need = rating.wave_need, count = rating.wave_count} )
end

function CreatePatroolWave()
	local gold = {[0] = 60,[1] = 150,[2] = 250,[3] = 400,[4] = 550,[5] = 650,[6] = 1000,[7] = 1500,[8] = 2000,[9] = 2500}
	local corners = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(-1376, -3935,0), nil, 99999, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
	local points = {}
	for i=0,(_G.don_spawn_level + 1) do
		table.insert(points, PatroolPoints[i])
	end
	local r = points[RandomInt(1, #points)]
	local rand = r[RandomInt(1, #r)]
	local pos = Vector(rand[1], rand[2], rand[3])
	GameRules:ExecuteTeamPing( DOTA_TEAM_GOODGUYS, pos.x, pos.y, nil, 0 )
	if not _G.kill_invoker then
		Notifications:TopToAll({text="random_wave_notification",style={color="red",["font-size"]="60px"}, duration=10})
		
		for k,name in pairs(PatroolWave[_G.don_spawn_level]) do
			local unit = CreateUnitByName(name, pos, true, nil, nil, DOTA_TEAM_BADGUYS)
			unit:AddNewModifier(unit, nil, "modifier_custom_vision", {})
			unit:SetBaseMaxHealth(set_health)
			unit:SetMaxHealth(set_health)
			unit:SetHealth(set_health)
			unit:SetBaseDamageMin(set_damage)
			unit:SetBaseDamageMin(set_damage)
			unit:SetPhysicalArmorBaseValue(set_armor)
			unit:SetBaseMagicalResistanceValue(set_mag_resist_creep)
			unit:SetMaximumGoldBounty(gold[_G.don_spawn_level] * RandomFloat(1, 1.4))
			unit:SetMinimumGoldBounty(gold[_G.don_spawn_level] * RandomFloat(1, 1.4))
			add_modifier(unit)
			unit.corners = corners
			unit.CornerID = 1
			unit:SetContextThink( "Think", function()
				if _G.kill_invoker or not Spawner:CheckBarracks() or not unit:IsAlive() then
					UTIL_Remove(unit)
					return
				end
				MoveToNextCornerThink(unit, unit.CornerID)
				return 0.1
			end, 0.1 )
		end
	end
end

function MoveToNextCornerThink(unit, CornerID)
    if unit:IsNull() or not unit:IsAlive() then
		return 
	end
    if unit.corners[unit.CornerID + 1] then
		if not unit.corners[unit.CornerID]:IsAlive() or not unit.corners[unit.CornerID]:IsAttackImmune() then     
			unit.CornerID = unit.CornerID + 1
		end
	end
	if unit:GetAggroTarget() == nil or (unit:GetAggroTarget() and not unit:GetAggroTarget():IsAlive()) then
		point_corner = unit.corners[unit.CornerID]:GetAbsOrigin()
		unit:MoveToPositionAggressive(point_corner)
	end
end
---------------------------------------------------------------------------------------------------
-------------------------- function to fix lag when wave spawn
---------------------------------------------------------------------------------------------------
_G.CreateUnitByName_WithoutLags_UnitsTable_Lane = {}
function StartSpawnSchedule_Lane()
	Timers:CreateTimer(1,function()
		if _G.CreateUnitByName_WithoutLags_UnitsTable_Lane[1] then
			--Get params to spawn from table
			local UnitName = _G.CreateUnitByName_WithoutLags_UnitsTable_Lane[1]["unitName"]
			local vLocation = _G.CreateUnitByName_WithoutLags_UnitsTable_Lane[1]["vLocation"]
			local bFindClearSpace = _G.CreateUnitByName_WithoutLags_UnitsTable_Lane[1]["bFindClearSpace"]
			local team = _G.CreateUnitByName_WithoutLags_UnitsTable_Lane[1]["team"]
			local IsComander = _G.CreateUnitByName_WithoutLags_UnitsTable_Lane[1]["IsComander"]

			local creep = CreateUnitByName(UnitName, vLocation, bFindClearSpace, nil, nil, team)
			if IsComander then
				creep:SetBaseDamageMin(set_damage_commandir)
				creep:SetBaseDamageMax(set_damage_commandir)
				creep:SetPhysicalArmorBaseValue(set_armor_commandir)
				creep:SetBaseMagicalResistanceValue(set_mag_resist_commandir)
				creep:SetMaxHealth(set_health_commandir)
				creep:SetBaseMaxHealth(set_health_commandir)
				creep:SetHealth(set_health_commandir)		
				creep:SetDeathXP(xp*2)
	
				creep:AddNewModifier(creep, nil, "modifier_attack_speed", nil):SetStackCount(wave * 2)
				creep:AddNewModifier(creep, nil, "modifier_spell_ampl_creep", nil):SetStackCount(wave * 2)
				creep:AddNewModifier(creep, nil, "modifier_hp_regen_commandir", nil)
				add_modifier(creep)
			else
				creep:SetBaseDamageMin(set_damage)
				creep:SetBaseDamageMax(set_damage)
				creep:SetPhysicalArmorBaseValue(set_armor)
				creep:SetBaseMagicalResistanceValue(set_mag_resist_creep)
				creep:SetMaxHealth(set_health)
				creep:SetBaseMaxHealth(set_health)
				creep:SetHealth(set_health)	
				creep:SetDeathXP(xp)
								
				creep:AddNewModifier(creep, nil, "modifier_attack_speed", nil):SetStackCount(wave)
				creep:AddNewModifier(creep, nil, "modifier_hp_regen_creep", nil)
				add_modifier(creep)
			end
			table.remove(_G.CreateUnitByName_WithoutLags_UnitsTable_Lane, 1)
		end
		return FrameTime() * 5
	end)
end

function CreateUnitByName_WithoutLags_Lane(unitName, vLocation, bFindClearSpace, npcOwner, entityOwner, team, IsComander)
	table.insert( _G.CreateUnitByName_WithoutLags_UnitsTable_Lane, {unitName = unitName, vLocation = vLocation, bFindClearSpace = bFindClearSpace, team = team, IsComander = IsComander})
end