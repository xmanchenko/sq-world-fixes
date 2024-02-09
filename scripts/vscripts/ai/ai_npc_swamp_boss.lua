function Spawn( entityKeyValues )    -- вызывается когда юнит появляется
    if not IsServer() then        -- если сервер не отвечает
        return
    end
    if thisEntity == nil then    -- если данного юнита не существует
        return
    end
    
    NoTargetAbility = thisEntity:FindAbilityByName( "swamp_spawn" )
	NoTargetAbility2 = thisEntity:FindAbilityByName( "lich_sinister_gaze_custom" )
	NoTargetAbility3 = thisEntity:FindAbilityByName( "ability_npc_swamp_boss" )

    thisEntity:SetContextThink( "NecroLordThink", NecroLordThink, 0.5 )    -- поведение юнита каждую секунду
end

function NecroLordThink()

		if ( not thisEntity:IsAlive() ) then
			return -1
		end	

		if GameRules:IsGamePaused() == true then
			return 1
		end
		
		if thisEntity:IsChanneling() then    -- если юнит кастует скил
			return 1 
		end
		
		local npc = thisEntity
		 if not thisEntity.bInitialized then
			npc.vInitialSpawnPos = npc:GetOrigin()
			npc.fMaxDist = npc:GetAcquisitionRange()
			npc.bInitialized = true
			npc.agro = false
		  
		end

	search_radius = npc.fMaxDist
	  
    local fDist = ( npc:GetOrigin() - npc.vInitialSpawnPos ):Length2D()
    if fDist > search_radius then
        RetreatHome()
        return 3
    end
	
	local hp = thisEntity:GetHealthPercent()
	
    local enemies = FindUnitsInRadius(
                        thisEntity:GetTeamNumber(),    --команда юнита
                        thisEntity:GetOrigin(),        --местоположение юнита
                        nil,    --айди юнита (необязательно)
                        1000,    --радиус поиска
                        DOTA_UNIT_TARGET_TEAM_ENEMY,    -- юнитов чьей команды ищем вражеской/дружественной
                        DOTA_UNIT_TARGET_HERO,    --юнитов какого типа ищем
                        DOTA_UNIT_TARGET_FLAG_NONE,    --поиск по флагам
                        FIND_CLOSEST,    --сортировка от ближнего к дальнему или от дальнего к ближнему
                        false )
		if #enemies > 0 then
		if not thisEntity.bSearchedForItems then
		SearchForItems()
		thisEntity.bSearchedForItems = true
		end
		local enemy = enemies[1]  
		for _, T in ipairs(creep_ability) do
			local ability = thisEntity:FindAbilityByName(T)
			if ability then
				behavior = ability:GetBehaviorInt()
				if bit.band(behavior, DOTA_ABILITY_BEHAVIOR_AUTOCAST) == DOTA_ABILITY_BEHAVIOR_AUTOCAST then
					ability.Behavior = "auto"
					if not ability:GetAutoCastState() then 
						ability:ToggleAutoCast()
					end
					return 0.5
				elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_UNIT_TARGET) == DOTA_ABILITY_BEHAVIOR_UNIT_TARGET then
					ability.Behavior = "target"
					if ability:GetAbilityTargetTeam() == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
						local friendly = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, thisEntity:GetAcquisitionRange(), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
						local target = friendly[RandomInt(1, #friendly)]
						Cast(ability, target)
					else
						if enemy and not enemy:HasModifier("modifier_item_lotus_orb_active") then
							Cast(ability, enemy)
						end
					end
				elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_NO_TARGET) == DOTA_ABILITY_BEHAVIOR_NO_TARGET then
					ability.Behavior = "no_target"
					if enemy then
						Cast(ability, enemy)
					end
				elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_POINT) == DOTA_ABILITY_BEHAVIOR_POINT then
					ability.Behavior = "point"
					if enemy then
						Cast(ability, enemy)
					end
				elseif bit.band(behavior, DOTA_ABILITY_BEHAVIOR_TOGGLE) == DOTA_ABILITY_BEHAVIOR_TOGGLE then
					ability.Behavior = "toggle"		
					if not ability:GetToggleState() then 
						ability:ToggleAbility()
					end
				end
			end
		end	
		if NoTargetAbility3 ~= nil and NoTargetAbility3:IsFullyCastable()  then    --если абилка существует и её можно использовать
			for _,unit in pairs(enemies) do
				if unit then
				NoTargetAbilityCast3(unit)
				local venom =  {"venomancer_venm_ability_nova_02","venomancer_venm_ability_nova_01","venomancer_venm_ability_nova_07"}
				thisEntity:EmitSound(venom[RandomInt(1, #venom)])
				end
			end
		end	
	
			if NoTargetAbility ~= nil and NoTargetAbility:IsFullyCastable()  then
					NoTargetAbilityCast()
					local venom =  {"venomancer_venm_ability_ward_01","venomancer_venm_ability_ward_06","venomancer_venm_ability_ward_03"}
					thisEntity:EmitSound(venom[RandomInt(1, #venom)])
				return 1
			end
	
		if hp < 100 then
			if NoTargetAbility2 ~= nil and NoTargetAbility2:IsFullyCastable()  then    --если абилка существует и её можно использовать
				for _,unit in pairs(enemies) do
					if unit then
					NoTargetAbilityCast2(unit)
					local venom =  {"venomancer_venm_ability_nova_02","venomancer_venm_ability_nova_01","venomancer_venm_ability_nova_07"}
					thisEntity:EmitSound(venom[RandomInt(1, #venom)])
					end
				end
			end
		end
		if hp == 100 then
			local venom =  {"venomancer_venm_attack_02","venomancer_venm_attack_11","venomancer_venm_move_16"}
			thisEntity:EmitSound(venom[RandomInt(1, #venom)])
			return 5
		end
		if thisEntity.item_shivas_guard and thisEntity.item_shivas_guard:IsFullyCastable() then
			return UseNoTarget( enemies[ RandomInt( 1, #enemies ) ] )	
		end
		
		if thisEntity.item_crimson_guard and thisEntity.item_crimson_guard:IsFullyCastable() then
			return UseNoTarget2( enemies[ RandomInt( 1, #enemies ) ] )	
		end
		
		if thisEntity.item_pipe and thisEntity.item_pipe:IsFullyCastable() then
			return UseNoTarget3( enemies[ RandomInt( 1, #enemies ) ] )	
		end
			
		if thisEntity.item_veil_of_discord and thisEntity.item_veil_of_discord:IsFullyCastable() then
			return UsePoint( enemies[ RandomInt( 1, #enemies ) ] )
		end
		
		if thisEntity.item_ethereal_blade and thisEntity.item_ethereal_blade:IsFullyCastable() then
			return UseTraget( enemies[ RandomInt( 1, #enemies ) ] )
		end
		return 1
		end
		
	return 0.5 
end


function RetreatHome()
    thisEntity.agro = false  

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = thisEntity.vInitialSpawnPos     
    })
end


function NoTargetAbilityCast(unit)
      ExecuteOrderFromTable({
            UnitIndex = thisEntity:entindex(),    --индекс кастера
            OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,    -- тип приказа
            AbilityIndex = NoTargetAbility:entindex(), -- индекс способности
            Queue = false,
        })
    return 1
end

function NoTargetAbilityCast2(unit)
      ExecuteOrderFromTable({
            UnitIndex = thisEntity:entindex(),    --индекс кастера
            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,  
			TargetIndex = unit:entindex(),			-- тип приказа
            AbilityIndex = NoTargetAbility2:entindex(), -- индекс способности
            Queue = false,
        })
    return 1
end

function NoTargetAbilityCast3(unit)
	ExecuteOrderFromTable({
		  UnitIndex = thisEntity:entindex(),    --индекс кастера
		  OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,  
		  TargetIndex = unit:entindex(),			-- тип приказа
		  AbilityIndex = NoTargetAbility3:entindex(), -- индекс способности
		  Queue = false,
	  })
  return 1
end

---------------------------------------------------------------------------------
function SearchForItems()
	for i = 0, 5 do
		local item = thisEntity:GetItemInSlot( i )
		if item then
			if item:GetAbilityName() == "item_shivas_guard4" then
				thisEntity.item_shivas_guard = item
			end
			if item:GetAbilityName() == "item_crimson_guard4" then
				thisEntity.item_crimson_guard = item
			end
			if item:GetAbilityName() == "item_veil_of_discord4" then
				thisEntity.item_veil_of_discord = item
			end
			if item:GetAbilityName() == "item_ethereal_blade4" then
				thisEntity.item_ethereal_blade = item
			end
			if item:GetAbilityName() == "item_pipe4" then
				thisEntity.item_pipe = item
			end
		end
	end
end

function UsePoint( hEnemy )
local vTargetPos = hEnemy:GetOrigin()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = vTargetPos,
		AbilityIndex = thisEntity.item_veil_of_discord:entindex(),
		Queue = false,
	})
    return 1.5
end

function UseTraget( hEnemy )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = hEnemy:entindex(),
		AbilityIndex = thisEntity.item_ethereal_blade:entindex(),
		Queue = false,
	})
	return 2
end

function UseNoTarget()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.item_shivas_guard:entindex(),
		Queue = false,
	})
	return 2
end

function UseNoTarget2()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.item_crimson_guard:entindex(),
		Queue = false,
	})
	return 2
end

function UseNoTarget3()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.item_pipe:entindex(),
		Queue = false,
	})
	return 2
end

function Cast( Spell , enemy )
	local order_type
	local vTargetPos = enemy:GetOrigin()
	
    if Spell.Behavior == "target" then
        order_type = DOTA_UNIT_ORDER_CAST_TARGET
    elseif Spell.Behavior == "no_target" then
        order_type = DOTA_UNIT_ORDER_CAST_NO_TARGET
    elseif Spell.Behavior == "point" then
        order_type = DOTA_UNIT_ORDER_CAST_POSITION
    elseif Spell.Behavior == "passive" then
        return
    end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = order_type,
		Position = vTargetPos,
		TargetIndex = enemy:entindex(),  
		AbilityIndex = Spell:entindex(),
		Queue = false,
	})
end