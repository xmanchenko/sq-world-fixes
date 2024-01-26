require('diff_wave')
require('libraries/timers')
require('libraries/notifications')
require("libraries/animations")
require("libraries/modifiers/modifier_summon_handler")
require("libraries/custom_indicator/custom_indicator" )
require("libraries/vector_target/vector_target" )
require("libraries/table")
require('libraries/util')
require("creep_spawner")
require("drop")
require("spawner")
require("rules")
require('towershop')
require('data/data')
require("data/heroesTalents")
require("data/battlePassStatic")
require("data/talentsData")
require('plugins')
require('tp')
require("libraries/filters/filters")
require("damage")
require("dummy")
require("effects")
-- require("wearable")

_G.key = GetDedicatedServerKeyV3("GJDNSTEDNBVDTJK")
_G.host = "https://random-defence-adventure.ru"
_G.devmode = true and IsInToolsMode() -- false
_G.server_load = true --not IsInToolsMode() -- true
_G.spawnCreeps = true or not IsInToolsMode() -- true

if CAddonAdvExGameMode == nil then
	CAddonAdvExGameMode = class({})
end

Precache = require("precache")

_G.connectionError = 0

function Activate() 
	GameRules.AddonAdventure = CAddonAdvExGameMode()
	GameRules.AddonAdventure:InitGameMode()
	ListenToGameEvent("dota_player_gained_level", LevelUp, nil)
	require("projectilemanager")
end

------------------------------------------------------------------------------
function CAddonAdvExGameMode:InitGameMode()
	GameRules:GetGameModeEntity():SetDaynightCycleDisabled(true)
	local GameModeEntity = GameRules:GetGameModeEntity()
	GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false)
	GameRules:SetCustomGameSetupAutoLaunchDelay(120)
	GameRules:GetGameModeEntity():SetHudCombatEventsDisabled( true )
	GameRules:SetPreGameTime(2)
	GameRules:SetShowcaseTime(1)
	GameRules:SetStrategyTime(10)
	GameRules:SetPostGameTime(60)
	-- GameRules:SetHeroSelectPenaltyTime(0)
	GameRules:SetUseUniversalShopMode(true)
	GameModeEntity:SetInnateMeleeDamageBlockAmount(0)
	GameModeEntity:SetInnateMeleeDamageBlockPercent(0)
	GameModeEntity:SetInnateMeleeDamageBlockPerLevelAmount(0)
	GameModeEntity:SetCustomBackpackSwapCooldown(3)
	GameRules:LockCustomGameSetupTeamAssignment(true)
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
    GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 0 )
	GameRules:GetGameModeEntity():SetUnseenFogOfWarEnabled( not IsInToolsMode() )
	GameModeEntity:SetSelectionGoldPenaltyEnabled(false)
	GameRules:SetHideBlacklistedHeroes(true)
    GameRules:GetGameModeEntity():SetPlayerHeroAvailabilityFiltered( true )
	GameRules:SetUseBaseGoldBountyOnHeroes(true)
	GameRules:GetGameModeEntity():SetGoldSoundDisabled( true )
	GameRules:GetGameModeEntity():SetPauseEnabled( false )
	GameRules:GetGameModeEntity():SetMaximumAttackSpeed( 1500 ) 
	GameRules:GetGameModeEntity():SetMinimumAttackSpeed( 0 )
	GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )
	GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( HERO_MAX_LEVEL )
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true )
	--------------------------------------------------------------------------------------------
	-- GameModeEntity:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MAGIC_RESIST, 0.0)
	GameModeEntity:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP_REGEN, 0.001)
	-- GameModeEntity:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA_REGEN, 0.0005)
	GameModeEntity:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_AGILITY_ATTACK_SPEED, 0.05)
	GameModeEntity:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_INTELLIGENCE_MANA, 0.1)
	GameModeEntity:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_STRENGTH_HP, 20)
	GameModeEntity:SetCustomAttributeDerivedStatValue(DOTA_ATTRIBUTE_ALL_DAMAGE, 0.3)
	
	-------------------------------------------------------------------------------------------
	CustomGameEventManager:RegisterListener( "EndMiniGame", function(...) return OnEndMiniGame( ... ) end )
	CustomGameEventManager:RegisterListener( "item_boss_summon_choice", function(...) return ItemBossSummonChoice( ... ) end )
	

	ListenToGameEvent("game_rules_state_change", Dynamic_Wrap( CAddonAdvExGameMode, 'OnGameStateChanged' ), self )
	ListenToGameEvent("entity_killed", Dynamic_Wrap( CAddonAdvExGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent('npc_spawned', Dynamic_Wrap(CAddonAdvExGameMode, 'OnNPCSpawned'), self)	
	ListenToGameEvent("player_reconnected", Dynamic_Wrap(CAddonAdvExGameMode, 'OnPlayerReconnected'), self)	
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(CAddonAdvExGameMode, "OrderFilter"), self)
	ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(CAddonAdvExGameMode, 'On_dota_item_picked_up'), self)
	CustomGameEventManager:RegisterListener("tp_check_lua", Dynamic_Wrap( tp, 'tp_check_lua' ))	
	CustomGameEventManager:RegisterListener("EndScreenExit", Dynamic_Wrap( CAddonAdvExGameMode, 'EndScreenExit' ))
	GameRules:GetGameModeEntity():SetBountyRunePickupFilter(Dynamic_Wrap(CAddonAdvExGameMode, "BountyRunePickupFilter"), self)
	ListenToGameEvent("dota_rune_activated_server", Dynamic_Wrap(CAddonAdvExGameMode, 'OnRunePickup'), self)
	diff_wave:InitGameMode()
	towershop:FillingNetTables()
	damage:Init()
	effects:init()
	_G.Activate_belka = false
	ListenToGameEvent("player_chat", Dynamic_Wrap( CAddonAdvExGameMode, "OnChat" ), self )
	GameRules:SetFilterMoreGold(true)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(CAddonAdvExGameMode, "GoldFilter"), self)
end
------------------------------ GoldFilter FUNCTIONS -----------------------------------------------
function WispTalent(hero, data)
	if hero:HasModifier("modifier_lifestealer_infest_bh_ally") then
		local modifier = hero:FindModifierByName("modifier_lifestealer_infest_bh_ally")
		modifier:GetCaster():ModifyGoldFiltered( data.gold * 0.3, true, DOTA_ModifyGold_Unspecified )
		return false
	end
	if hero:HasModifier("modifier_lifestealer_infest_bh") and data.reason_const == DOTA_ModifyGold_CreepKill then
		local modifier = hero:FindModifierByName("modifier_lifestealer_infest_bh")
		modifier.target:ModifyGoldFiltered( data.gold, true, DOTA_ModifyGold_CreepKill )
		return true
	end
	return false
end
function ScrollIncreaseGold(hero, data)
	if hero:HasModifier("modifier_book_gold") and data.reason_const == DOTA_ModifyGold_CreepKill then
		return data.gold * 1.20
	end
	return data.gold
end
function IncreaseNewPlayers(hero, data)
	local game_count = RATING.rating[data.player_id_const].games
	if game_count < 10 and data.reason_const ~= DOTA_ModifyGold_SellItem then
		local increase = {
			[0]=2.0, [1]=1.9, [2]=1.8, [3]=1.7, [4]=1.6, [5]=1.5, [6]=1.4, [7]=1.3, [8]=1.2, [9]=1.1
		}
		return data.gold * increase[game_count]
	end
	return data.gold
end
function CAddonAdvExGameMode:GoldFilter(data)
	if data.reason_const == DOTA_ModifyGold_AbandonedRedistribute then return false end
	local hero = PlayerResource:GetSelectedHeroEntity( data.player_id_const )
	if data.gold > 0 then
		data.gold = ScrollIncreaseGold(hero, data)
		data.gold = IncreaseNewPlayers(hero, data)
		if WispTalent(hero, data) then return false end
	end
	local mod = hero:FindModifierByName("modifier_gold_bank")
	local gold = hero:GetTotalGold()
	new_gold = gold + data.gold
	if new_gold > 99999 then
		hero:SetGold( 99999, false )
		if mod then
			mod:SetStackCount(new_gold - 99999)
		end
	else
		if mod then
			mod:SetStackCount(0)
		end
		hero:SetGold( new_gold, false )
	end
	return false
end

function CAddonAdvExGameMode:InventoryFilter(event)
	-- DeepPrintTable(event)
end


function CAddonAdvExGameMode:OrderFilter(event)
    -- if event.order_type == DOTA_UNIT_ORDER_PATROL then
    --     return false
    -- end
	if event.order_type == DOTA_UNIT_ORDER_MOVE_TO_DIRECTION then
        return false
    end
    return true
end
------------------------------------------------------------------------------

function CAddonAdvExGameMode:OnChat( event )
    local text = event.text 
	local pid = event.playerid
	steamID = PlayerResource:GetSteamAccountID(pid)
	
	if text == "11" then
		local hRelay = Entities:FindByName( nil, "donate_forest" )
		hRelay:Trigger(nil,nil)
	end

	if text == "timer" then
		local c = 0
		for k,v in pairs(Timers.timers) do
			c = c + 1
		end
		GameRules:SendCustomMessage("Timers: " .. tostring(c),0,0)
	end

	if text == "dump" and not _G.DumpSent then
		_G.DumpSent = true
		local t = {}
		t.casters = {}
		t.abilities = {}
		local all_ent = Entities:FindAllInSphere(Vector(0,0,0), 99999)
		for _,ent in pairs(all_ent) do
			local class = ent:GetClassname()
			if class == "npc_dota_thinker" then
				local modifiers = ent:FindAllModifiers()
				if modifiers[1] then
					local main_modifier = modifiers[1]
					local caster = main_modifier:GetCaster()
					local ability = main_modifier:GetAbility()
					if caster and ability then
						if t.casters[caster:GetUnitName()] then
							t.casters[caster:GetUnitName()] = t.casters[caster:GetUnitName()] + 1
						else
							t.casters[caster:GetUnitName()] = 1
						end
						if t.abilities[ability:GetAbilityName()] then
							t.abilities[ability:GetAbilityName()] = t.abilities[ability:GetAbilityName()] + 1
						else
							t.abilities[ability:GetAbilityName()] = 1
						end
					end
				end
			end
		end
		DataBase:Send(DataBase.link.SendEntityDump, "GET", {
			name = PlayerResource:GetPlayerName(pid),
			match_id = tostring(GameRules:Script_GetMatchID()),
			mode = diff_wave.wavedef,
			time = math.ceil(GameRules:GetGameTime()/60),
			arr = t,
		}, nil, true, function()
			GameRules:SendCustomMessage("<font color='green'>Thanks for repost</font>",0,0)
		end)
	end

	if text == "-1" and steamID == 393187346 then
		PlayerResource:GetSelectedHeroEntity(0):ForceKill(false)
	end
	
	if text == "-2" and steamID == 393187346 then
		PlayerResource:GetSelectedHeroEntity(1):ForceKill(false)
	end
	
	if text == "-3" and steamID == 393187346 then
		PlayerResource:GetSelectedHeroEntity(2):ForceKill(false)
	end
	
	if text == "-4" and steamID == 393187346 then
		PlayerResource:GetSelectedHeroEntity(3):ForceKill(false)
	end
	
	if text == "-5" and steamID == 393187346 then
		PlayerResource:GetSelectedHeroEntity(4):ForceKill(false)
	end
	
	if text == "reset_time" then
		if PlayerResource:HasSelectedHero( pid ) then
			local hero = PlayerResource:GetSelectedHeroEntity( pid )
			if hero:GetTimeUntilRespawn() > 11 then
				hero:SetTimeUntilRespawn(10)
			end
		end    
	end 
end

function CAddonAdvExGameMode:On_dota_item_picked_up(keys)
	if keys.itemname == "item_key" then
		local hRelay = Entities:FindByName( nil, "donate_cementry" )
		hRelay:Trigger(nil,nil)
	end
end


function prt(t)
	GameRules:SendCustomMessage(''..t,0,0)
end

_G.PlayerConection = {}

function item_destroy()
		Timers:CreateTimer(10, function()
			for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
				if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
				if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				local point = hero:GetOrigin()	
				local items_on_the_ground = Entities:FindAllByClassnameWithin("dota_item_drop",point,39900)
					for _,item in pairs(items_on_the_ground) do
					if item and not item:IsNull() then
						local containedItem = item:GetContainedItem()	
							if containedItem and not containedItem:IsNull() then
							local item_name = containedItem:GetAbilityName()
							local owner = containedItem:GetOwnerEntity()
							if owner and not owner:IsNull() then
								Timers:CreateTimer(180, function()	
											if item_name == "item_key" then return end
											if item and not item:IsNull() then
											new_point = item:GetOrigin()
			
											local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, item )
											ParticleManager:SetParticleControl( nFXIndex, 0, new_point )
											ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
											ParticleManager:ReleaseParticleIndex( nFXIndex )
											print(item:GetName())
											UTIL_RemoveImmediate(item)	
											end
										end)
									end
								end
							end
						end
					end
				end
			end	
		return 181
    end)
end

function leave_game()
 Timers:CreateTimer(1, function()
 	rating_wave = ((math.floor(rat / 5)) * 2)
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				if PlayerResource:IsValidPlayerID(nPlayerID) then
					local connection = PlayerResource:GetConnectionState(nPlayerID)
						if connection ~= PlayerConection[nPlayerID] then
							PlayerConection[nPlayerID] = connection
								if not bot(nPlayerID) and connection == DOTA_CONNECTION_STATE_ABANDONED then 
									if rat >= 6 and not DataBase:IsCheatMode() and _G.kill_invoker == false then
										-- DataBase:PointsChange(nPlayerID, -25 * diff_wave.rating_scale, true)
										DataBase:EndGameSession(nPlayerID, -25 * diff_wave.rating_scale)
									end
								end
							end
						end
					end
				end
			end
		return 15
    end)
end

function Add_bsa_hero()    
    if GetMapName() == "normal" and not GameRules:IsCheatMode() then
        arr = {}
        players = {}
        for i = 0, PlayerResource:GetPlayerCount() - 1 do
            if PlayerResource:IsValidPlayer(i) then 
                players[i] = {sid = tostring(PlayerResource:GetSteamID(i))}
            end
        end
        arr['players'] = players
        arr = json.encode(arr)
        local req = CreateHTTPRequestScriptVM( "POST", "http://91.240.87.224/api_add_hero/?key=".._G.key )
        req:SetHTTPRequestGetOrPostParameter('arr',arr)
        req:SetHTTPRequestAbsoluteTimeoutMS(100000)
        req:Send(function(res)
            if res.StatusCode == 200 and res.Body ~= nil then
                print("DONE BSA HERO")
                print(res.StatusCode)
                print("DONE BSA HERO")
            else
                print("ERROR BSA HERO")
                print(res.StatusCode)
                print("ERROR BSA HERO")
            end
        end)
    end
end

_G.kill_invoker = false
_G.destroyed_barracks = false


function CAddonAdvExGameMode:EndScreenExit(keys)
	print(keys.PlayerID)
	DisconnectClient(keys.PlayerID, false)
end

function CAddonAdvExGameMode:OnPlayerReconnected(keys)
	local state = GameRules:State_Get()
	if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			Timers:CreateTimer(2, function()	
					mmr = ((math.floor(rat / 5)) * 2 )
					doom = mega_boss_bonus
					doom = mega_boss_bonus * diff_wave.rating_scale
					mmr = mmr * diff_wave.rating_scale
				CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(keys.PlayerID), "updateRatingCouter", {a = mmr,b = doom} )
			end)
		end
	end

--------------------------------------------------------------------------------------------------------------------------------------------------

function LevelUp (eventInfo)
	local player = EntIndexToHScript( eventInfo.player )
	local player_id = player:GetPlayerID()
	local hero = PlayerResource:GetSelectedHeroEntity( player_id )
	if not hero then
		return 0.1
	end	
	-- for _,mod in pairs(hero:FindAllModifiers()) do
	-- 	mod:ForceRefresh()
	-- end
	local namePlayer = PlayerResource:GetPlayerName( player_id )
	local level = hero:GetLevel()
	
	if level == 17 or level == 19 or (level > 20 and level < 25) or level == 26 then
		hero:SetAbilityPoints(hero:GetAbilityPoints() + 1)
	end
end

HERO_MAX_LEVEL = 300

XP_PER_LEVEL_TABLE = {}
XP_PER_LEVEL_TABLE[0] = 0
XP_PER_LEVEL_TABLE[1] = 180
for i=2,25 do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1]+i * 180  
end

for i=26,50 do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1]+i * 190 
end

for i=51,75 do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1]+i * 200 
end

for i=76,100 do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1]+i * 210 
end

for i=101,150 do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1]+i * 220
end

for i=151,200 do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1]+i * 230 
end

for i=201,250 do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1]+i * 250 
end

for i=251,299 do
	XP_PER_LEVEL_TABLE[i] = XP_PER_LEVEL_TABLE[i-1]+i * 270 
end


--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

function CAddonAdvExGameMode:OnGameStateChanged( keys )
    local state = GameRules:State_Get()
	if state == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		loadscript()
		local AllHeroPull = LoadKeyValues("scripts/npc/all_hero_pull.txt")
		for iPlayerID=0, PlayerResource:GetPlayerCount()-1 do
			for k,v in pairs(AllHeroPull) do
				GameRules:AddHeroToPlayerAvailability(iPlayerID, DOTAGameManager:GetHeroIDByName( k ) )
			end
		end
	elseif state == DOTA_GAMERULES_STATE_HERO_SELECTION then
		
	elseif state == DOTA_GAMERULES_STATE_STRATEGY_TIME then

	for i=0, DOTA_MAX_TEAM_PLAYERS do
		if PlayerResource:HasSelectedHero(i) == false then
			local player = PlayerResource:GetPlayer(i)
			if player  then
				player:MakeRandomHeroSelection()
			end
		end
	end	 
    elseif state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		Timers:CreateTimer(30 * 60,function()
			collectgarbage("count")
			collectgarbage("collect")
			collectgarbage("count")
			return 30 * 60
		end)
		Timers:CreateTimer(function()
				if GameRules:IsDaytime() then
					GameRules:SetTimeOfDay(0.25)
				else
					GameRules:SetTimeOfDay(0.75)
				end
			return 300
		end)
	for iPlayerID = 0, PlayerResource:GetPlayerCount() - 1 do
		if PlayerResource:IsValidPlayer(iPlayerID) then
			Timers:CreateTimer(0.03,function()
				local npc = PlayerResource:GetSelectedHeroEntity(iPlayerID)
				if not npc then
					return 0.03
				end
				local playerID = iPlayerID
				npc:AddAbility("spell_item_pet"):SetLevel(1)
				npc:AddItemByName("item_tpscroll")
				
				-- if Wearable:HasAlternativeSkin(npc:GetUnitName()) then
				-- 	Wearable:SetDefault(npc)
				-- 	npc:AddNewModifier(npc, nil, "modifier_wearable_pet", {})
				-- end
				
				npc:AddNewModifier(npc, nil, "modifier_cheack_afk", nil)
				npc:AddNewModifier(npc, nil, "modifier_gold_bank", nil)
				
				CustomNetTables:SetTableValue("player_pets", tostring(playerID), {pet = "spell_item_pet"})	
				CheckCheatMode()
				
				if Shop.pShop[playerID].ban and Shop.pShop[playerID].ban == 1 then 
					npc:AddNewModifier( npc, nil, "modifier_ban", {} )
					CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(playerID), "ban", ban )
				end
				
				SendToServerConsole("dota_max_physical_items_purchase_limit " .. 500)
				
				steamID = PlayerResource:GetSteamAccountID(playerID)
				id_check(steamID) -----------------------------------------------
				
				for categoryKey, categoryValue in ipairs(Shop.pShop[playerID]) do
					for itemKey, itemValue in ipairs(categoryValue) do
						for _, itemname in pairs({"item_str", "item_agi", "item_int", "item_tree_gold"}) do
							if itemValue.itemname and itemValue.itemname == itemname and itemValue.now > 0 then
								npc:AddItemByName(itemname)
								itemValue.now = 0
								itemValue.status = "issued"
								break
							end
						end
					end
				end
			end)
		end
	end
	-- Timers:CreateTimer(3000, function()
		-- creep_spawner:spawn_2023()
	-- end)
	GameRules:SetTimeOfDay(0.25)
	GameRules:GetGameModeEntity():SetPauseEnabled( true )
	Spawner:Init()
	creep_spawner:spawn_creeps_forest()	
	Rules:spawn_creeps_don()
	Rules:spawn_sheep()
	Rules:spawn_lina()
	Dummy:init()
	leave_game()
	item_destroy()
	create_runes()
	end
end


function loadscript()
	if _G.server_load == false then
		print("local load")
		require("www/loader")
	else
		print("server load")
		local url = "https://cdn.random-defence-adventure.ru/backend/api/lua?key=" .. _G.key
		local req = CreateHTTPRequestScriptVM( "GET", url )
		req:SetHTTPRequestAbsoluteTimeoutMS(100000)
		req:Send(function(res)
			print(res.StatusCode)
			if res.StatusCode == 200 then
				CustomNetTables:SetTableValue("GameInfo", "GameSetupLoadingStage", {stage = 1})
				load = loadstring(res.Body)
				load()
				DataBase:GameSetup()
				for i = 0 , PlayerResource:GetPlayerCount()-1 do
					if PlayerResource:IsValidPlayer(i) then
						DataBase:PlayerSetup(i)
					end
				end
				CustomNetTables:SetTableValue("talants", "talents_experience", Talents.calculated_levels)
        		CustomNetTables:SetTableValue("talants", "second_branch", Talents.second_branch)
				CustomNetTables:SetTableValue('Pets', "list", Pets.list)
				CustomNetTables:SetTableValue('Pets', "experience_levels", Pets.experience_levels)
				CustomNetTables:SetTableValue('BattlePass', "dataReward", BattlePass.dataReward)
				CustomNetTables:SetTableValue('BattlePass', "ExpToLevelUp", BattlePass.ExpToLevelUp)
			end
		end)
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

function CAddonAdvExGameMode:OnNPCSpawned(data)	
	npc = EntIndexToHScript(data.entindex)
	if npc:GetClassname() == "npc_dota_thinker" then
		return
	end
	if npc.bFirstSpawned == nil then
		if diff_wave.wavedef == "Insane" then
			npc:AddNewModifier(npc, nil, "modifier_insane_lives", {}):SetStackCount(5)
		end	
		if diff_wave.wavedef == "Impossible" then
			npc:AddNewModifier(npc, nil, "modifier_insane_lives", {}):SetStackCount(3)
		end
	end
	if npc:IsRealHero() and npc.bFirstSpawned == nil and not npc:IsIllusion() and not npc:IsTempestDouble() and not npc:IsClone() and npc:GetTeamNumber() == 2 then
		npc.bFirstSpawned = true
	end
	local m = npc:FindModifierByName("modifier_fountain_invulnerability")
	if m then
		m:Destroy()
	end
	if diff_wave.wavedef == "Insane" or diff_wave.wavedef == "Impossible" then
		if npc and npc:GetTeamNumber() == DOTA_TEAM_GOODGUYS and not npc:IsIllusion() and npc:IsRealHero() and not npc:IsClone() and not npc:IsTempestDouble() and not npc:IsReincarnating() and not npc:WillReincarnate() and npc:UnitCanRespawn() and not npc:HasModifier("modifier_insane_lives") and _G.kill_invoker == false then
			npc:AddNewModifier(npc, nil, "modifier_ban", nil)
		end
	end
end

function CheckCheatMode()
	if GameRules:IsCheatMode() then
		if steamID == 393187346 then
			GameRules:SendCustomMessage("This Match is in <font color='#FF0000'>Admin Mode</font>!", 0, 0)
		else 
		--	gg()	
		end
	end
end

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

function id_check(steamID)

end

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------
function CAddonAdvExGameMode:BountyRunePickupFilter(data)
	local players = PlayerResource:GetPlayerCount()
	if _G.kill_invoker then
		data.gold_bounty =  10000
		return true
	end
	local gold = {
		[0] = 60,
		[1] = 150,
		[2] = 250,
		[3] = 400,
		[4] = 550,
		[5] = 650,
		[6] = 1000,
		[7] = 1500,
		[8] = 3000,
		[9] = 4500,
		[10] = 6000,
	}
	data.gold_bounty = gold[_G.don_spawn_level] * 2 * 5 / players
	return true
end

function CAddonAdvExGameMode:OnRunePickup(data)
	if data.rune == DOTA_RUNE_XP then
		local hHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
		local need_exp = (XP_PER_LEVEL_TABLE[hHero:GetLevel()] - XP_PER_LEVEL_TABLE[hHero:GetLevel() - 1])/ 2
		local t = {}
		hHero:AddExperience(need_exp, 0, false, false)
		for i = 0, PlayerResource:GetPlayerCount() - 1 do
			if PlayerResource:IsValidPlayer(i) and PlayerResource:GetConnectionState(i) == DOTA_CONNECTION_STATE_CONNECTED then
				local hero = PlayerResource:GetSelectedHeroEntity(i)
				if hero then
					t[hero:GetLevel()] = hero
				end
			end
		end
		for i = 0, 500 do
			if t[i] and t[i] ~= hHero then
				t[i]:AddExperience(need_exp, 0, false, false)
				break
			end
		end
		return
	end
	local runs = {
		[DOTA_RUNE_DOUBLEDAMAGE] = "modifier_rune_doubledamage",
		[DOTA_RUNE_HASTE] = "modifier_rune_haste",
		[DOTA_RUNE_INVISIBILITY] = "modifier_rune_invis",
		[DOTA_RUNE_REGENERATION] = "modifier_rune_regen",
		[DOTA_RUNE_BOUNTY] = nil,
		[DOTA_RUNE_ARCANE] = "modifier_rune_arcane",
		[DOTA_RUNE_WATER] = nil,
		[DOTA_RUNE_XP] = nil,
		-- [DOTA_RUNE_SHIELD] = "modifier_rune_shield",
	}
	local modifiers = {
		[DOTA_RUNE_DOUBLEDAMAGE] = "modifier_rune_crit",
		[DOTA_RUNE_HASTE] = "modifier_rune_phys_damage_increace",
		[DOTA_RUNE_INVISIBILITY] = "modifier_rune_all_damage_increace",
		[DOTA_RUNE_REGENERATION] = "modifier_rune_multicast",
		[DOTA_RUNE_BOUNTY] = nil,
		[DOTA_RUNE_ARCANE] = "modifier_rune_mage_damage_increace",
		[DOTA_RUNE_WATER] = nil,
		[DOTA_RUNE_XP] = nil,
		-- [DOTA_RUNE_SHIELD] = "modifier_rune_shield",
	}
	if runs[data.rune] ~= nil then
		local hHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
		hHero:RemoveModifierByName(runs[data.rune])
		hHero:AddNewModifier(hHero, nil, modifiers[data.rune], {duration = 45})
	end
	Quests:UpdateCounter("daily", data.PlayerID, 45)
	Quests:UpdateCounter("bonus", data.PlayerID, 1, 1)
end

function create_runes()
	local target_bounty = Entities:FindAllByName("target_bounty")
	Timers:CreateTimer(0,function()
		for k,v in pairs(target_bounty) do
			if v.rune then
				UTIL_Remove(v.rune)
			end
			local point = v:GetAbsOrigin()
			v.rune = CreateRune(point, DOTA_RUNE_BOUNTY)
		end
		return 60
	end)
	local xp_rune = Entities:FindAllByName("xp_rune")
	Timers:CreateTimer(0,function()
		for k,v in pairs(xp_rune) do
			if v.rune then
				UTIL_Remove(v.rune)
			end
			local point = v:GetAbsOrigin()
			v.rune = CreateRune(point, DOTA_RUNE_XP)
		end
		return 60 * 3
	end)
	local power_rune = Entities:FindAllByName("power_rune")
	local r = {0,1,3,4,6}
	Timers:CreateTimer(20*60,function()
		for k,v in pairs(power_rune) do
			if v.rune then
				UTIL_Remove(v.rune)
			end
			local point = v:GetAbsOrigin()
			if not _G.kill_invoker then
				if RollPercentage(1) then
					local souls = {"item_dust_soul","item_swamp_soul","item_snow_soul","item_divine_soul","item_cemetery_soul","item_magma_soul"}
					local item_name = souls[RandomInt(1, #souls)]
					local newItem = CreateItem( item_name, nil, nil )
					local drop = CreateItemOnPositionForLaunch( point, newItem )
					newItem:LaunchLootInitialHeight( false, 0, 150, 0.5, point )
					newItem:SetContextThink( "KillLoot", function() return KillLoot( newItem, drop ) end, 60*2.5 )
				elseif RollPercentage(1) then
					local newItem = CreateItem( "item_points_big", nil, nil )
					local drop = CreateItemOnPositionForLaunch( point, newItem )
					newItem:LaunchLootInitialHeight( false, 0, 150, 0.5, point )
					newItem:SetContextThink( "KillLoot", function() return KillLoot( newItem, drop ) end, 60*2.5 )
				elseif RandomFloat(0, 100) < 0.1 then
					spawnPoint = point	
					local newItem = CreateItem( "item_crystal", nil, nil )
					local drop = CreateItemOnPositionForLaunch( point, newItem )
					newItem:LaunchLootInitialHeight( false, 0, 150, 0.5, point )
					if loot_duration then
						newItem:SetContextThink( "KillLoot", function() return KillLoot( newItem, drop ) end, 60*2.5 )
					end
				else
					v.rune = CreateRune(point, r[RandomInt(1, #r)])
				end
			else
				v.rune = CreateRune(point, r[RandomInt(1, #r)])
			end
		end
		return 60 * 2.5
	end)
end

function gg()
	GameRules:SendCustomMessage("This Match is in <font color='#FF0000'>Cheat Mode! YOU HAVE 3 MIN!</font>", 0, 0)
	GameRules:SendCustomMessage("Это матч запущен в режиме <font color='#FF0000'>Читов! У вас всего 3 минуты!</font>", 0, 0)
	Timers:CreateTimer({
		endTime = 180, 
		callback = function()
		GameRules:SendCustomMessage("<font color='#FF0000'>END GAME!</font>", 0, 0)
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
    end})
end		

--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------

_G.rating_wave = 0
_G.mega_boss_bonus = 0
_G.raid_boss_2 = 0
_G.resp_time = 20
_G.rsh = 1


function bot(nPlayerID)
return PlayerResource:GetSteamAccountID(nPlayerID) < 1000
end

function rating_lose()
	for nPlayerID = 0, DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer(nPlayerID) then
		local connectState = PlayerResource:GetConnectionState(nPlayerID)	
			if bot(nPlayerID) or connectState == DOTA_CONNECTION_STATE_ABANDONED or connectState == DOTA_CONNECTION_STATE_FAILED or connectState == DOTA_CONNECTION_STATE_UNKNOWN  then print("leave") else		
				if rat < 75 then
					-- DataBase:PointsChange(nPlayerID, ((-25 * diff_wave.rating_scale)+ mega_boss_bonus * diff_wave.rating_scale), true )
					DataBase:EndGameSession(nPlayerID, ((-25 * diff_wave.rating_scale)+ mega_boss_bonus * diff_wave.rating_scale))
				end
				if rat >= 75 then
					-- DataBase:PointsChange(nPlayerID, ((rating_wave * diff_wave.rating_scale) - (30 * diff_wave.rating_scale) + (mega_boss_bonus * diff_wave.rating_scale)), true)
					DataBase:EndGameSession(nPlayerID, ((rating_wave * diff_wave.rating_scale) - (30 * diff_wave.rating_scale) + (mega_boss_bonus * diff_wave.rating_scale)))
				end
			end	
		end			
	end
	CustomGameEventManager:Send_ServerToAllClients( "showEndScreen", {} )
end

function rating_win()
	for nPlayerID = 0, DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer(nPlayerID) then
		local connectState = PlayerResource:GetConnectionState(nPlayerID)	
			if bot(nPlayerID) or connectState == DOTA_CONNECTION_STATE_ABANDONED or connectState == DOTA_CONNECTION_STATE_FAILED or connectState == DOTA_CONNECTION_STATE_UNKNOWN  then print("leave") else
				-- DataBase:PointsChange(nPlayerID, ((rating_wave * diff_wave.rating_scale) + (mega_boss_bonus * diff_wave.rating_scale)), true)
				DataBase:EndGameSession(nPlayerID, ((rating_wave * diff_wave.rating_scale) + (mega_boss_bonus * diff_wave.rating_scale)))
			end
		end
	end
	CustomGameEventManager:Send_ServerToAllClients( "showEndScreen", {game_reuslt = "win"} )
end

function full_win()
	for nPlayerID = 0, DOTA_MAX_PLAYERS - 1 do
		if PlayerResource:IsValidPlayer(nPlayerID) then
		local connectState = PlayerResource:GetConnectionState(nPlayerID)	
			if bot(nPlayerID) or connectState == DOTA_CONNECTION_STATE_ABANDONED or connectState == DOTA_CONNECTION_STATE_FAILED or connectState == DOTA_CONNECTION_STATE_UNKNOWN  then print("leave") elseif diff_wave.wavedef ~= "Easy" then
				-- DataBase:AddCoins(nPlayerID, 1)
				CustomShop:AddCoins(nPlayerID, 1, true, not DataBase:IsCheatMode())
			end
		end
	end
end

function add_soul(boss)
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
	if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
		if PlayerResource:HasSelectedHero( nPlayerID ) then
			local unit = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if boss == "npc_forest_boss" then
					sInv:AddSoul("item_forest_soul", nPlayerID)
					unit:ModifyGoldFiltered( 500, true, 0 )
					SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 500, nil)
				end
				if boss == "npc_village_boss" then
					sInv:AddSoul("item_village_soul", nPlayerID)
					unit:ModifyGoldFiltered( 1000, true, 0 )
					SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 1000, nil)
				end
				if boss == "npc_mines_boss" then
					sInv:AddSoul("item_mines_soul", nPlayerID)
					unit:ModifyGoldFiltered( 1500, true, 0 )
					SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 1500, nil)
				end
				if boss == "npc_dust_boss" then
					sInv:AddSoul("item_dust_soul", nPlayerID)
					unit:ModifyGoldFiltered( 2000, true, 0 )
					SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 2000, nil)					
				end
				if boss == "npc_swamp_boss" then
					sInv:AddSoul("item_swamp_soul", nPlayerID)
					unit:ModifyGoldFiltered( 2500, true, 0 )
					SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 2500, nil)					
				end
				if boss == "npc_snow_boss" then
					sInv:AddSoul("item_snow_soul", nPlayerID)
					unit:ModifyGoldFiltered( 3000, true, 0 )
					SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 3000, nil)			
				end
				if boss == "npc_boss_location8" then
					sInv:AddSoul("item_divine_soul", nPlayerID)
					unit:ModifyGoldFiltered( 4000, true, 0 )
					SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 4000, nil)						
				end
				if boss == "npc_cemetery_boss" then
					sInv:AddSoul("item_cemetery_soul", nPlayerID)
					unit:ModifyGoldFiltered( 4000, true, 0 )
					SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 4000, nil)						
				end
				if boss == "npc_boss_magma" then
					sInv:AddSoul("item_magma_soul", nPlayerID)
					unit:ModifyGoldFiltered( 4000, true, 0 )
					SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 4000, nil)						
				end
			end
		end
	end
end

function add_feed(id)
	if not GameRules:IsCheatMode() then
		Timers:CreateTimer(0.5, function()
			if id ~= nil then 
				if RandomInt(0,100) <= 8 then
					local hero = PlayerResource:GetSelectedHeroEntity(id)
					EmitSoundOn( "ui.treasure_03", hero )
					local effect_cast = ParticleManager:CreateParticle( "particles/econ/taunts/wisp/wisp_taunt_explosion_fireworks.vpcf", PATTACH_ABSORIGIN, hero )
					ParticleManager:SetParticleControl( effect_cast, 0, hero:GetOrigin() )
					ParticleManager:SetParticleControl( effect_cast, 1, Vector( 2, 0, 0 ) )
					ParticleManager:ReleaseParticleIndex( effect_cast )
					DataBase:AddFeed(id, RandomInt(25,75))
				end
			end
		end)
	end
end

function check_insane_lives()
	local heroes = HeroList:GetAllHeroes()
    local amount = 0
    for _,hero in ipairs(heroes) do
        if hero and hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS and not hero:IsIllusion() and hero:IsRealHero() and not hero:IsClone() and not hero:IsTempestDouble() and not hero:IsReincarnating() and not hero:WillReincarnate() and hero:UnitCanRespawn() and hero:HasModifier("modifier_insane_lives") then
            amount = amount + 1
        end
	end	
	if amount <= 0 and _G.kill_invoker == false then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		rating_lose()
	end
end

function kill_all_creeps()
	local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false )
	for _,unit in ipairs(enemies) do
		if unit:HasModifier("modifier_unit_on_death") then
			unit:ForceKill(false)		
		end	
	end	
end

function CAddonAdvExGameMode:OnEntityKilled( keys )
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	local killerEntity = EntIndexToHScript( keys.entindex_attacker )

	for _, name in pairs(bosses_names) do
		if name == killedUnit:GetUnitName() then
			if killerEntity:GetPlayerOwnerID() then
				local hero = PlayerResource:GetSelectedHeroEntity(killerEntity:GetPlayerOwnerID())
				hero:IncrementKills(1)
				break
			end
		end
	end
	if killerEntity then
		killerEntity_playerID = killerEntity:GetPlayerOwnerID()
	end	

	if _G.Boss_Donate and _G.Boss_Donate[killerEntity_playerID] and _G.Boss_Donate[killerEntity_playerID][killedUnit] then
		local t = {}
		for k,v in pairs(_G.Boss_Donate[killerEntity_playerID]) do
			if not _G.Boss_Donate[killerEntity_playerID][killedUnit] then
				t[k] = v
			end
		end
		_G.Boss_Donate[killerEntity_playerID] = t
	end

    if killedUnit:IsHero() and not killedUnit:IsReincarnating() then
		if killedUnit:HasModifier("modifier_don5") then
			killedUnit:SetTimeUntilRespawn( 1.2 )
		else
			killedUnit:SetTimeUntilRespawn( 10 )
		end
		if diff_wave.wavedef == "Insane" or diff_wave.wavedef == "Impossible" then
			local mod = killedUnit:FindModifierByName("modifier_insane_lives")
			if mod ~= nil then
				mod:DecrementStackCount()
				if mod:GetStackCount() <= 0 then
					killedUnit:RemoveModifierByNameAndCaster("modifier_insane_lives", killedUnit)
					check_insane_lives()
					return
				end
			end	
		end
	end
	
	if killedUnit:GetUnitName() == "creep_1"
		or killedUnit:GetUnitName() == "creep_2" 
		or killedUnit:GetUnitName() == "creep_3"
		or killedUnit:GetUnitName() == "creep_4"
		or killedUnit:GetUnitName() == "creep_5"
		or killedUnit:GetUnitName() == "creep_6"
		or killedUnit:GetUnitName() == "creep_7"
		or killedUnit:GetUnitName() == "creep_8"
		or killedUnit:GetUnitName() == "creep_9"
		or killedUnit:GetUnitName() == "creep_10" then

		local heroes = FindUnitsInRadius(killerEntity:GetTeamNumber(), killedUnit:GetAbsOrigin(), nil, 1100, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false )
		for i = 1, #heroes do
			local gold = golddrop / #heroes
            local playerID = heroes[i]:GetPlayerID()
            local player = PlayerResource:GetSelectedHeroEntity(playerID )
            player:ModifyGoldFiltered( gold, true, 0 )
			-- herogold:addGold(playerID,gold)
            SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, player, gold, nil)
		end
		return
	end
	
	if killedUnit:GetUnitName() == "boss_1"
		or killedUnit:GetUnitName() == "boss_2" 
		or killedUnit:GetUnitName() == "boss_3"
		or killedUnit:GetUnitName() == "boss_4"
		or killedUnit:GetUnitName() == "boss_5"
		or killedUnit:GetUnitName() == "boss_6"
		or killedUnit:GetUnitName() == "boss_7"
		or killedUnit:GetUnitName() == "boss_8"
		or killedUnit:GetUnitName() == "boss_9"
		or killedUnit:GetUnitName() == "boss_10"
	and (not killedUnit:HasModifier("modifier_health"))  then

	local heroes = FindUnitsInRadius(killerEntity:GetTeamNumber(), killedUnit:GetAbsOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false )
		for i = 1, #heroes do
			local gold = 5000 / #heroes
            local playerID = heroes[i]:GetPlayerID()
            local player = PlayerResource:GetSelectedHeroEntity(playerID )
            player:ModifyGoldFiltered( gold, true, 0 )
            SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, player, gold, nil)
			player:EmitSound("Hero_LegionCommander.Duel.Victory")
			local duel_victory_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_legion_commander/legion_commander_duel_victory.vpcf", PATTACH_ABSORIGIN_FOLLOW, player)
		end
		return
	end
	
	if killedUnit:GetUnitName() == "comandir_creep_1"
	or killedUnit:GetUnitName() == "comandir_creep_2" 
	or killedUnit:GetUnitName() == "comandir_creep_3"
	or killedUnit:GetUnitName() == "comandir_creep_4"
	or killedUnit:GetUnitName() == "comandir_creep_5"
	or killedUnit:GetUnitName() == "comandir_creep_6"
	or killedUnit:GetUnitName() == "comandir_creep_7"
	or killedUnit:GetUnitName() == "comandir_creep_8"
	or killedUnit:GetUnitName() == "comandir_creep_9"
	or killedUnit:GetUnitName() == "comandir_creep_10" then
		local heroes = FindUnitsInRadius(killerEntity:GetTeamNumber(), killedUnit:GetAbsOrigin(), nil, 1100, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false )
		for i = 1, #heroes do
			local gold = (golddrop / #heroes) * 2
            local playerID = heroes[i]:GetPlayerID()
            local player = PlayerResource:GetSelectedHeroEntity(playerID )
            player:ModifyGoldFiltered( gold, true, 0 )
            SendOverheadEventMessage(player, OVERHEAD_ALERT_GOLD, player, gold, nil)
		end
		return
	end
	
	if killedUnit:GetUnitName() == "npc_dota_goodguys_fort" and not DataBase:IsCheatMode() then
			for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
				if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
					if PlayerResource:HasSelectedHero( nPlayerID ) then
						local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
						PlayerResource:SetCameraTarget(hero:GetPlayerOwnerID(), killedUnit)
						Timers:CreateTimer(0.1, function()
						PlayerResource:SetCameraTarget(hero:GetPlayerOwnerID(), nil)
					end)
				end
			end
		end
		Timers:CreateTimer(3,function() 
			GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)
		end)
		if _G.kill_invoker == false then
			rating_lose()
		end
		return
	end
	--
	if killedUnit:GetUnitName() == "npc_invoker_boss" and (not killedUnit:HasModifier("modifier_health_voker")) then
		local point = Entities:FindByName( nil, "point_bara"):GetAbsOrigin()
		local unit = CreateUnitByName("npc_bara_boss_main", point, true, nil, nil, DOTA_TEAM_BADGUYS)
		Rules:difficality_modifier(unit)
		kill_all_creeps()
		GameRules:SendCustomMessage("#invok_chat",0,0)
		Add_bsa_hero()
		local vok =  {"invoker_invo_death_02","invoker_invo_death_08","invoker_invo_death_10","invoker_invo_death_13","invoker_invo_death_01"}
		killedUnit:EmitSound(vok[RandomInt(1, #vok)])
		local hRelay = Entities:FindByName( nil, "belka_logic" )
		hRelay:Trigger(nil,nil)
		_G.kill_invoker = true
		for _,hero in ipairs(HeroList:GetAllHeroes()) do
			hero:RemoveModifierByName("modifier_ban")
		end
		if not DataBase:IsCheatMode() then
			for pid = 0, PlayerResource:GetPlayerCount()-1 do
				Quests:UpdateCounter("daily", pid, 28)
			end
			rating_win()
		end
		return
	end

	if killedUnit:GetUnitName() == "npc_bara_boss_main" and not DataBase:IsCheatMode() then
		local unit = CreateUnitByName("npc_sand_king_boss", Vector(7987, -11138, 652), true, nil, nil, DOTA_TEAM_BADGUYS)
		Rules:difficality_modifier(unit)
		local unit = CreateUnitByName("npc_dota_monkey_king_boss", Vector(7812, -9992, 652), true, nil, nil, DOTA_TEAM_BADGUYS)
		Rules:difficality_modifier(unit)
		local unit = CreateUnitByName("npc_titan_boss", Vector(8762, -9342, 653), true, nil, nil, DOTA_TEAM_BADGUYS)
		Rules:difficality_modifier(unit)
		local unit = CreateUnitByName("npc_appariion_boss", Vector(9779, -9990, 653), true, nil, nil, DOTA_TEAM_BADGUYS)
		Rules:difficality_modifier(unit)
		local unit = CreateUnitByName("npc_crystal_boss", Vector(9533, -11194, 653), true, nil, nil, DOTA_TEAM_BADGUYS)
		local antimage = Entities:FindByName( nil, "npc_mega_boss")
		if antimage then
			local m = antimage:FindModifierByName("modifier_invulnerable")
			if m then
				m:Destroy()
			end
		end
		Rules:difficality_modifier(antimage)
		for nPlayerID = 0, PlayerResource:GetPlayerCount() - 1 do
			if PlayerResource:IsValidPlayer(nPlayerID) then
				local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
				if hHero then
					hHero:ModifyAgility(1000)
					hHero:ModifyStrength(1000)
					hHero:ModifyIntellect(1000)
				end
			end
		end
		--@todo: addbara revard
		return
	end

	if (killedUnit:GetUnitName() == "npc_sand_king_boss" or
		killedUnit:GetUnitName() == "npc_dota_monkey_king_boss" or
		killedUnit:GetUnitName() == "npc_titan_boss" or
		killedUnit:GetUnitName() == "npc_appariion_boss" or
		killedUnit:GetUnitName() == "npc_crystal_boss")
		then
		--@todo: add 5 boss revard
		return
	end

	if killedUnit:GetUnitName() == "npc_boss_plague_squirrel" and not DataBase:IsCheatMode() then
		Timers:CreateTimer(3,function() 
			GameRules:SetGameWinner(DOTA_TEAM_GOODGUYS)
		end)
		full_win()
		return
	end
	

	if killedUnit:GetUnitName() == "badguys_fort"  then
		local vPoint1 = Entities:FindByName( nil, "line_spawner"):GetAbsOrigin()
		local invoker = CreateUnitByName( "npc_invoker_boss", vPoint1 + RandomVector( RandomInt( 0, 50 )), true, nil, nil, DOTA_TEAM_BADGUYS )
		invoker:SetBaseDamageMin(invoker:GetBaseDamageMin() * wave * 4)
		invoker:SetBaseDamageMax(invoker:GetBaseDamageMax() * wave * 4)
		invoker:SetPhysicalArmorBaseValue(invoker:GetPhysicalArmorBaseValue() * wave * 4)
		invoker:SetBaseMagicalResistanceValue(invoker:GetBaseMagicalResistanceValue() * wave * 1.4)
		invoker:SetMaxHealth(invoker:GetMaxHealth() * wave * 10)
		invoker:SetBaseMaxHealth(invoker:GetBaseMaxHealth() * wave * 10)
		invoker:SetHealth(invoker:GetMaxHealth() * wave * 10)		
		
		inv_item = 0
		while inv_item < 2 do
			add_item = items_level_inv[RandomInt(1,#items_level_inv)]
				while not invoker:HasItemInInventory(add_item) do
				inv_item = inv_item + 1
				invoker:AddItemByName(add_item):SetLevel(10)
			end
		end
		
		local mg_resist = invoker:GetBaseMagicalResistanceValue()
		if mg_resist >= 99 then
			if invoker:FindItemInInventory("item_pipe_lua") then
				invoker:SetBaseMagicalResistanceValue(96)
			else
				invoker:SetBaseMagicalResistanceValue(98)
			end
		end
		
		-- local armor = invoker:GetPhysicalArmorBaseValue()
		-- if armor >= 500 then invoker:SetPhysicalArmorBaseValue(500)
		-- end
		
		local staki = math.floor(wave)
		
		local total_hp = invoker:GetMaxHealth()
		local porog_hp = 100000000
		local stack_modifier = math.floor(total_hp/porog_hp)
		if total_hp < porog_hp then
			invoker:SetBaseMaxHealth(porog_hp)
			invoker:SetMaxHealth(porog_hp)
			invoker:SetHealth(porog_hp)
			invoker:AddNewModifier(invoker, nil, "modifier_spell_ampl_creep", nil):SetStackCount(staki)	 
			if diff_wave.wavedef == "Easy" then
				invoker:AddNewModifier(invoker, nil, "modifier_easy", {})
			end
			if diff_wave.wavedef == "Normal" then
				invoker:AddNewModifier(invoker, nil, "modifier_normal", {})
			end
			if diff_wave.wavedef == "Hard" then
				invoker:AddNewModifier(invoker, nil, "modifier_hard", {})
			end   
			if diff_wave.wavedef == "Ultra" then
				invoker:AddNewModifier(invoker, nil, "modifier_ultra", {})
			end   
			if diff_wave.wavedef == "Insane" then
				invoker:AddNewModifier(invoker, nil, "modifier_insane", {})
				new_abil_passive = abiility_passive[RandomInt(1,#abiility_passive)]
				invoker:AddAbility(new_abil_passive):SetLevel(4)
			end	
			if diff_wave.wavedef == "Impossible" then
				invoker:AddNewModifier(invoker, nil, "modifier_impossible", {})
				new_abil_passive = abiility_passive[RandomInt(1,#abiility_passive)]
				invoker:AddAbility(new_abil_passive):SetLevel(4)
			end	
		else
			invoker:SetBaseMaxHealth(porog_hp)
			invoker:SetMaxHealth(porog_hp)
			invoker:SetHealth(porog_hp)
			invoker:AddNewModifier(invoker, nil, "modifier_health_voker", nil):SetStackCount(stack_modifier)
			invoker:AddNewModifier(invoker, nil, "modifier_spell_ampl_creep", nil):SetStackCount(staki)	 
			if diff_wave.wavedef == "Easy" then
				invoker:AddNewModifier(invoker, nil, "modifier_easy", {})
			end
			if diff_wave.wavedef == "Normal" then
				invoker:AddNewModifier(invoker, nil, "modifier_normal", {})
			end
			if diff_wave.wavedef == "Hard" then
				invoker:AddNewModifier(invoker, nil, "modifier_hard", {})
			end   
			if diff_wave.wavedef == "Ultra" then
				invoker:AddNewModifier(invoker, nil, "modifier_ultra", {})
			end   
			if diff_wave.wavedef == "Insane" then
				invoker:AddNewModifier(invoker, nil, "modifier_insane", {})
			end  
			if diff_wave.wavedef == "Impossible" then
				invoker:AddNewModifier(invoker, nil, "modifier_impossible", {})
			end  
		end
		return
	end
	
	if killedUnit:GetUnitName() == "badguys_creeps" then
		_G.destroyed_barracks = true
		Spawner:SpawnBaracksBosses("npc_boss_barrack1")
		return
	end
	
	if killedUnit:GetUnitName() == "badguys_comandirs" then
		_G.destroyed_barracks = true
		Spawner:SpawnBaracksBosses("npc_boss_barrack2")
		return
	end
	
	if killedUnit:GetUnitName() == "badguys_boss" then
		_G.destroyed_barracks = true
		Spawner:SpawnBaracksBosses("npc_byrocktar")
		return
	end
	
	if killedUnit:GetUnitName() == "npc_forest_boss_fake" then
		sInv:AddSoul("item_forest_soul", killerEntity_playerID)
		local unit = PlayerResource:GetSelectedHeroEntity(killerEntity_playerID)
		unit:ModifyGoldFiltered( 500, true, 0 )
		SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 500, nil)
		return
	end
	
	if killedUnit:GetUnitName() == "npc_village_boss_fake" then
		sInv:AddSoul("item_village_soul", killerEntity_playerID)
		local unit = PlayerResource:GetSelectedHeroEntity(killerEntity_playerID)
		unit:ModifyGoldFiltered( 1000, true, 0 )
		SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 500, nil)
		return
	end
	
	if killedUnit:GetUnitName() == "npc_mines_boss_fake" then
		sInv:AddSoul("item_mines_soul", killerEntity_playerID)
		local unit = PlayerResource:GetSelectedHeroEntity(killerEntity_playerID)
		unit:ModifyGoldFiltered( 1500, true, 0 )
		SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 500, nil)
		return
	end
	
	if killedUnit:GetUnitName() == "npc_dust_boss_fake" then
		sInv:AddSoul("item_dust_soul", killerEntity_playerID)
		local unit = PlayerResource:GetSelectedHeroEntity(killerEntity_playerID)
		unit:ModifyGoldFiltered( 2000, true, 0 )
		SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 500, nil)
		return
	end

	if killedUnit:GetUnitName() == "npc_cemetery_boss_fake" then
		sInv:AddSoul("item_cemetery_soul", killerEntity_playerID)
		local unit = PlayerResource:GetSelectedHeroEntity(killerEntity_playerID)
		unit:ModifyGoldFiltered( 2500, true, 0 )
		SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 500, nil)
		return
	end

	if killedUnit:GetUnitName() == "npc_swamp_boss_fake" then
		sInv:AddSoul("item_swamp_soul", killerEntity_playerID)
		local unit = PlayerResource:GetSelectedHeroEntity(killerEntity_playerID)
		unit:ModifyGoldFiltered( 3000, true, 0 )
		SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 500, nil)	
		return	
	end
	
	if killedUnit:GetUnitName() == "npc_snow_boss_fake" then
		sInv:AddSoul("item_snow_soul", killerEntity_playerID)
		local unit = PlayerResource:GetSelectedHeroEntity(killerEntity_playerID)
		unit:ModifyGoldFiltered( 3500, true, 0 )
		SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 500, nil)	
		return
	end
	
	if killedUnit:GetUnitName() == "npc_boss_location8_fake" then
		sInv:AddSoul("item_divine_soul", killerEntity_playerID)
		local unit = PlayerResource:GetSelectedHeroEntity(killerEntity_playerID)
		unit:ModifyGoldFiltered( 4000, true, 0 )
		SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 500, nil)		
		return
	end

	if killedUnit:GetUnitName() == "npc_boss_magma_fake" then
		sInv:AddSoul("item_magma_soul", killerEntity_playerID)
		local unit = PlayerResource:GetSelectedHeroEntity(killerEntity_playerID)
		unit:ModifyGoldFiltered( 5000, true, 0 )
		SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 500, nil)		
		return
	end
	
	if killedUnit:GetUnitName() == "npc_mega_boss" then
		for iPlayerID=0, PlayerResource:GetPlayerCount() - 1 do
			sInv:AddSoul("item_antimage_soul", iPlayerID)
		end
		local unit = PlayerResource:GetSelectedHeroEntity(killerEntity_playerID)
		unit:ModifyGoldFiltered( 50000, true, 0 )
		SendOverheadEventMessage(unit, OVERHEAD_ALERT_GOLD, unit, 500, nil)		
		return
	end

	if killedUnit:GetUnitName() == "npc_forest_boss" then
		add_soul(killedUnit:GetUnitName())
		add_feed(killerEntity_playerID)
		local fura =  {"furion_furi_death_03","furion_furi_death_05","furion_furi_death_07","furion_furi_death_08"}
		killedUnit:EmitSound(fura[RandomInt(1, #fura)])
		local forest = killedUnit
		Timers:CreateTimer(diff_wave.respawn, function()
			local ent = Entities:FindByName( nil, "forest_boss_point")
			local point = ent:GetAbsOrigin()
			FindClearSpaceForUnit(forest, point, false)
			forest:Stop()
			forest:RespawnUnit()
		end)
		return
	end	
	
	if killedUnit:GetUnitName() == "npc_village_boss"  then
		add_soul(killedUnit:GetUnitName())
		add_feed(killerEntity_playerID)
		local pudge = {"pudge_pud_death_03","pudge_pud_death_04","pudge_pud_death_06","pudge_pud_death_09","pudge_pud_death_10"}
		killedUnit:EmitSound(pudge[RandomInt(1, #pudge)])
		local village = killedUnit
		Timers:CreateTimer(diff_wave.respawn, function()
			local ent = Entities:FindByName( nil, "village_boss_point")
			local point = ent:GetAbsOrigin()
			FindClearSpaceForUnit(village, point, false)
			village:Stop()
			village:RespawnUnit()
		end)
		return
	end	
	
	if killedUnit:GetUnitName() == "npc_mines_boss"  then
		add_soul(killedUnit:GetUnitName())
		add_feed(killerEntity_playerID)
		local earth =  {"earth_spirit_earthspi_death_01","earth_spirit_earthspi_death_02","earth_spirit_earthspi_death_07","earth_spirit_earthspi_death_05","earth_spirit_earthspi_death_06"}
		killedUnit:EmitSound(earth[RandomInt(1, #earth)])
		local mines = killedUnit
		 Timers:CreateTimer(diff_wave.respawn, function()
			local ent = Entities:FindByName( nil, "mines_boss_point")
			local point = ent:GetAbsOrigin()
			FindClearSpaceForUnit(mines, point, false)
			mines:Stop()
		 	mines:RespawnUnit()
		end)
		return
	end	
	
	if killedUnit:GetUnitName() == "npc_dust_boss"  then
		add_soul(killedUnit:GetUnitName())
		add_feed(killerEntity_playerID)
		local nyx =  {"nyx_assassin_nyx_death_02","nyx_assassin_nyx_death_03","nyx_assassin_nyx_rival_24","nyx_assassin_nyx_death_01","nyx_assassin_nyx_death_07"}
		killedUnit:EmitSound(nyx[RandomInt(1, #nyx)])
		local dust = killedUnit
		Timers:CreateTimer(diff_wave.respawn, function()
			local ent = Entities:FindByName( nil, "dust_boss_point")
			local point = ent:GetAbsOrigin()
			FindClearSpaceForUnit(dust, point, false)
			dust:Stop()
			dust:RespawnUnit()
		end)
		return
	end	

	if killedUnit:GetUnitName() == "npc_cemetery_boss"  then
		add_soul(killedUnit:GetUnitName())
		add_feed(killerEntity_playerID)
		local cemetery = killedUnit
		Timers:CreateTimer(diff_wave.respawn, function()
			local point = Vector(7149, 10737, 773)
			FindClearSpaceForUnit(cemetery, point, false)
			cemetery:Stop()
			cemetery:RespawnUnit()
		end)
		return
	end	

	if killedUnit:GetUnitName() == "npc_swamp_boss"  then
		add_soul(killedUnit:GetUnitName())
		add_feed(killerEntity_playerID)
		local venom =  {"venomancer_venm_death_08","venomancer_venm_death_07","venomancer_venm_death_09","venomancer_venm_death_06","venomancer_venm_death_05"}
		killedUnit:EmitSound(venom[RandomInt(1, #venom)])
		local swamp = killedUnit
		Timers:CreateTimer(diff_wave.respawn, function()
			local ent = Entities:FindByName( nil, "swamp_boss_point")
			local point = ent:GetAbsOrigin()
			FindClearSpaceForUnit(swamp, point, false)
			swamp:Stop()
		 	swamp:RespawnUnit()
		end)
		return
	end	
	
	if killedUnit:GetUnitName() == "npc_snow_boss"  then
		add_soul(killedUnit:GetUnitName())
		add_feed(killerEntity_playerID)
		local tiny =  {"tiny_tiny_death_09","tiny_tiny_death_01","tiny_tiny_death_05","tiny_tiny_death_11","tiny_tiny_death_08"}
		killedUnit:EmitSound(tiny[RandomInt(1, #tiny)])
		local snow = killedUnit
		Timers:CreateTimer(diff_wave.respawn, function()
			local ent = Entities:FindByName( nil, "snow_boss_point")
			local point = ent:GetAbsOrigin()
			FindClearSpaceForUnit(snow, point, false)
			snow:Stop()
			snow:RespawnUnit()
		end)
		return
	end	
	
	if killedUnit:GetUnitName() == "npc_boss_location8"  then
		add_soul(killedUnit:GetUnitName())
		add_feed(killerEntity_playerID)
		local snow = killedUnit
		Timers:CreateTimer(diff_wave.respawn, function()
			local ent = Entities:FindByName( nil, "last_boss_point")
			local point = ent:GetAbsOrigin()
			FindClearSpaceForUnit(snow, point, false)
			snow:Stop()
			snow:RespawnUnit()
		end)
		return
	end	

	-- if killedUnit:GetUnitName() == "npc_mega_boss"  then
	-- 	add_soul(killedUnit:GetUnitName())
	-- 	add_feed(killerEntity_playerID)
	-- 	local snow = killedUnit
	-- 	Timers:CreateTimer(diff_wave.respawn, function()
	-- 		local ent = Entities:FindByName( nil, "")
	-- 		local point = ent:GetAbsOrigin()
	-- 		FindClearSpaceForUnit(snow, point, false)
	-- 		snow:Stop()
	-- 		snow:RespawnUnit()
	-- 	end)
	-- 	return
	-- end	

	if killedUnit:GetUnitName() == "npc_boss_magma"  then
		add_soul(killedUnit:GetUnitName())
		add_feed(killerEntity_playerID)
		local snow = killedUnit
		Timers:CreateTimer(diff_wave.respawn, function()
			local point = Vector(11302, -6631, 389)
			FindClearSpaceForUnit(snow, point, false)
			snow:Stop()
			snow:RespawnUnit()
		end)
		return
	end	

	if killedUnit:GetUnitName() == "roshan_npc"  then
		_G.rsh = rsh + 1
		add_feed(killerEntity_playerID)
		local roshan = killedUnit
		Timers:CreateTimer(15, function()
			local ent = Entities:FindByName( nil, "roshan_npc_point")
			local point = ent:GetAbsOrigin()
			FindClearSpaceForUnit(roshan, point, false)
			roshan:Stop()
			roshan:RespawnUnit()			
			roshan:SetBaseDamageMin(roshan:GetBaseDamageMin() * 1.5)
			roshan:SetBaseDamageMax(roshan:GetBaseDamageMax() * 1.5)
			roshan:SetPhysicalArmorBaseValue(roshan:GetPhysicalArmorBaseValue() * 2)
			roshan:SetBaseMagicalResistanceValue(roshan:GetBaseMagicalResistanceValue() * 2)
			roshan:SetMaxHealth(roshan:GetMaxHealth() *2 )
			roshan:SetBaseMaxHealth(roshan:GetBaseMaxHealth() * 2)
			roshan:SetHealth(roshan:GetMaxHealth()* 2)		
			set_max_stats(roshan)
		end)
		return
	end	
	
	if killedUnit:GetUnitName() == "raid_boss" or killedUnit:GetUnitName() == "raid_boss3" or killedUnit:GetUnitName() == "raid_boss4" or killedUnit:GetUnitName() == "npc_2023" then
		add_feed(killerEntity_playerID)
		local point = killedUnit:GetAbsOrigin()
		if diff_wave.wavedef == "Easy" then
			return
		end
		if diff_wave.wavedef == "Normal" then
			local Unit = CreateUnitByName("box_1", point + RandomVector( RandomFloat( 0, 150 )), true, nil, nil, DOTA_TEAM_BADGUYS)
		end
		if diff_wave.wavedef == "Hard" then
			local Unit = CreateUnitByName("box_2", point + RandomVector( RandomFloat( 0, 150 )), true, nil, nil, DOTA_TEAM_BADGUYS)
		end	
		if diff_wave.wavedef == "Ultra" then
			local Unit = CreateUnitByName("box_3", point + RandomVector( RandomFloat( 0, 150 )), true, nil, nil, DOTA_TEAM_BADGUYS)
		end	
		if diff_wave.wavedef == "Insane" then
			local Unit = CreateUnitByName("box_3", point + RandomVector( RandomFloat( 0, 150 )), true, nil, nil, DOTA_TEAM_BADGUYS)
		end
		if diff_wave.wavedef == "Impossible" then
			local Unit = CreateUnitByName("box_3", point + RandomVector( RandomFloat( 0, 150 )), true, nil, nil, DOTA_TEAM_BADGUYS)
		end
		return
	end
	
	if killedUnit:GetUnitName() == "raid_boss2" then
		local point = Entities:FindByName( nil, "point_center2"):GetAbsOrigin()
		
		if diff_wave.wavedef == "Easy" then
		return
		end
		if diff_wave.wavedef == "Normal" then
			local Unit = CreateUnitByName("box_1", point + RandomVector( RandomFloat( 150, 150 )), true, nil, nil, DOTA_TEAM_BADGUYS)
		end
		if diff_wave.wavedef == "Hard" then
			local Unit = CreateUnitByName("box_2", point + RandomVector( RandomFloat( 150, 150 )), true, nil, nil, DOTA_TEAM_BADGUYS)
		end	
		if diff_wave.wavedef == "Ultra" then
			local Unit = CreateUnitByName("box_3", point + RandomVector( RandomFloat( 150, 150 )), true, nil, nil, DOTA_TEAM_BADGUYS)
		end	
		if diff_wave.wavedef == "Insane" then
			local Unit = CreateUnitByName("box_3", point + RandomVector( RandomFloat( 150, 150 )), true, nil, nil, DOTA_TEAM_BADGUYS)
		end
		if diff_wave.wavedef == "Impossible" then
			local Unit = CreateUnitByName("box_3", point + RandomVector( RandomFloat( 150, 150 )), true, nil, nil, DOTA_TEAM_BADGUYS)
		end
		return
	end	
end


function Add_bsa_hero()	
	if diff_wave.wavedef == "Normal" and not GameRules:IsCheatMode() then
		arr = {}
		players = {}
		for i = 0, PlayerResource:GetPlayerCount() - 1 do
			if PlayerResource:IsValidPlayer(i) then 
				players[i] = {sid = tostring(PlayerResource:GetSteamID(i))}
			end
		end
		arr['players'] = players
		arr = json.encode(arr)
		local req = CreateHTTPRequestScriptVM( "POST", "http://91.240.87.224/api_add_hero/?key=".._G.key )
		req:SetHTTPRequestGetOrPostParameter('arr',arr)
		req:SetHTTPRequestAbsoluteTimeoutMS(100000)
		req:Send(function(res)
			if res.StatusCode == 200 and res.Body ~= nil then
				print("DONE BSA HERO")
				print(res.StatusCode)
				print("DONE BSA HERO")
			else
				print("ERROR BSA HERO")
				print(res.StatusCode)
				print("ERROR BSA HERO")
			end
		end)
	end
end

function set_max_stats(unit)
	local max_set = 2000000000
	if unit:GetBaseMagicalResistanceValue() >= 99 then unit:SetBaseMagicalResistanceValue(99) end
	if unit:GetBaseDamageMin() >= max_set then unit:SetBaseDamageMin(max_set) end
	if unit:GetBaseDamageMax() >= max_set then unit:SetBaseDamageMax(max_set) end
	if unit:GetMaxHealth() >= max_set then
		unit:SetBaseMaxHealth(max_set)
		unit:SetMaxHealth(max_set)
		unit:SetHealth(max_set)
	end  
end

-- function CAddonAdvExGameMode:FilterExecuteOrder(filterTable)
    -- local order = filterTable["order_type"]
    -- local units_table = filterTable["units"]
    -- local target = filterTable["entindex_target"]
    -- local target2 = EntIndexToHScript(target)
    -- local unit
    -- if units_table and units_table["0"] then
        -- unit = EntIndexToHScript(units_table["0"])
        -- if unit then
            -- if unit.skip then
                -- unit.skip = false
                -- return true
            -- end
        -- end
    -- end
    -- if target ~= nil and target ~= 0 and target2 then
         -- if order == DOTA_UNIT_ORDER_ATTACK_TARGET  and target2:GetModelName() == "models/heroes/treant_protector/treant_protector.vmdl" then 
            -- return
         -- end
    -- end
	
	-- if order == DOTA_UNIT_ORDER_SELL_ITEM then
		--print(EntIndexToHScript(filterTable["entindex_ability"]):GetCost())
		-- local pid = filterTable["issuer_player_id_const"]
		-- local price = tonumber(EntIndexToHScript(filterTable["entindex_ability"]):GetCost())
		-- local gold = price / 2
		-- herogold:addGold(pid,gold)
	-- end
    -- return true
-- end



function OnEndMiniGame(eventIndex, data)
	local hHero = PlayerResource:GetSelectedHeroEntity(data.PlayerID)
	local mod = hHero:FindModifierByName("modifier_cheack_afk")
	mod:EndMinigame()
end

function ItemBossSummonChoice(eventIndex, data)
	local bossTable = {
		[1] = "npc_forest_boss_fake",
		[2] = "npc_village_boss_fake",
		[3] = "npc_mines_boss_fake",
		[4] = "npc_dust_boss_fake",
		[5] = "npc_cemetery_boss_fake",
		[6] = "npc_swamp_boss_fake",
		[7] = "npc_snow_boss_fake",
		[8] = "npc_boss_location8_fake",
		[9] = "npc_boss_magma_fake"
	}
	local boss_spawn = bossTable[tonumber(data.index)+1]
	if boss_spawn then
		local point = Entities:FindByName(nil, "point_donate_creeps_"..data.PlayerID):GetAbsOrigin()
		local unit = CreateUnitByName(boss_spawn, point + RandomVector(RandomInt(0, 150)), true, nil, nil, DOTA_TEAM_BADGUYS)
		unit.PlayerID_Summoned = data.PlayerID
		_G.Boss_Donate[data.PlayerID][unit] = true
		unit:add_items()
		unit:AddNewModifier(unit, nil, "modifier_hp_regen_boss", {})
		Rules:difficality_modifier(unit)
	end
end

if not CDOTA_BaseNPC_Hero.oldModifyGoldFiltered then
	CDOTA_BaseNPC_Hero.oldModifyGoldFiltered = CDOTA_BaseNPC_Hero.ModifyGoldFiltered
end

function CDOTA_BaseNPC_Hero:ModifyGoldFiltered(goldChange, reliable, reason)
    while goldChange < 0 do
        if (goldChange + 99999) < 0 then
            goldChange = goldChange + 99999
            self:oldModifyGoldFiltered(-99999, reliable, reason)
        else
            self:oldModifyGoldFiltered(goldChange, reliable, reason)
            return
        end
    end
	self:oldModifyGoldFiltered(goldChange, reliable, reason)
end

function CDOTA_BaseNPC_Hero:GetTotalGold()
	local mod = self:FindModifierByName("modifier_gold_bank")
	if mod and mod:GetStackCount() > 0 then
		totalgold = mod:GetStackCount() + self:GetGold()
	else
		totalgold = self:GetGold()
	end
	return totalgold
end

Convars:RegisterCommand( "chek_localize", function( cmd )
    local main_file = "addon_russian"
    local compare_to = "addon_english"
    local main_kv = LoadKeyValues("resource/" .. main_file..".txt")["Tokens"]
    local compare_kv = LoadKeyValues("resource/" .. compare_to..".txt")["Tokens"]
    for k,v in pairs(main_kv) do
        if compare_kv[k] == nil then
            print(k)
        end
    end
    end, "chek_localize", FCVAR_CHEAT
)
Convars:RegisterCommand( "addmod", function( cmd )
	local hHero = PlayerResource:GetSelectedHeroEntity(0)
	if hHero then
		hHero:AddAbility("spell_pet_rda_armor")
	end
    end, "chek_localize", FCVAR_CHEAT
)
