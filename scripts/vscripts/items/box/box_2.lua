LinkLuaModifier( "modifier_unselect", "modifiers/modifier_unselect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_spawn_creeps", "items/box/box_2", LUA_MODIFIER_MOTION_NONE )

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
		new_abil_passive = abiility_passive[RandomInt(1,#abiility_passive)]
		unit:AddAbility(new_abil_passive):SetLevel(4)
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
end	

item_box_2 = class({})
--------------------------------------------------------------------------------
function item_box_2:OnSpellStart(cheat_target)
	-- if _G.box_plased then
	-- 	local player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerOwnerID())
	-- 	CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message="dota_hud_error_only_one_box"})
	-- 	return
	-- end
	for i=0,5 do
		local ent = Entities:FindByName( nil, "point_donate_creeps_" .. i )
		if ent then
			local pos = ent:GetAbsOrigin()
			local len = (pos - self:GetCursorPosition()):Length2D()
			if len < 1000 then
				local player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerOwnerID())
				CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message="dota_hud_error_no_box_in_donate"})
				self:EndCooldown()
				return
			end
		end
	end
		self.caster = self:GetCaster()
		vTargetPosition = cheat_target
		if vTargetPosition == nil then 
			vTargetPosition = self:GetCursorPosition()
		end
		
		local point_closed_zone = Entities:FindByName( nil, "main_base_location") 
		local closed_zone_point = point_closed_zone:GetAbsOrigin()
					
		local flDist = (vTargetPosition - closed_zone_point):Length2D()
		if flDist < 1400 then return end
		
		local nFXIndex = ParticleManager:CreateParticle( "particles/ui/ui_generic_treasure_impact.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, vTargetPosition )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 0.0, r, 0.0 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )		
		
		
		local unit = CreateUnitByName("npc_box_2", vTargetPosition, true, nil, nil, DOTA_TEAM_GOODGUYS)
		unit:SetModel("models/props_generic/chest_treasure_02.vmdl")
		unit:SetOwner(self.caster)
		unit:AddNewModifier( unit, nil, "modifier_invulnerable", { } )
		unit:AddNewModifier( unit, nil, "modifier_no_healthbar", { } )
		unit:AddNewModifier( unit, nil, "modifier_unselect", { } )
		unit:AddNewModifier( unit, nil, "modifier_spawn_creeps", { duration = 120 } )
		
		EmitSoundOnLocationWithCaster( vTargetPosition, "ui.treasure_reveal", self:GetCaster() )
	
		self:SetCurrentCharges( self:GetCurrentCharges() -1)
		if self:GetCurrentCharges() < 1 then
			self.caster:RemoveItem(self)
		end
		_G.box_plased = true
end

------------------------------------------------------------------------------------------

modifier_spawn_creeps = class({})

--------------------------------------------------------------------------------
function modifier_spawn_creeps:IsHidden()
	return true
end

function modifier_spawn_creeps:IsPurgable()
	return false
end

function modifier_spawn_creeps:OnCreated( kv )
	if not IsServer() then return end

	spawn(self:GetCaster())

	self:StartIntervalThink(2)
end

function modifier_spawn_creeps:OnDestroy()
	_G.box_plased = false
	if not IsServer() then
		return
	end
	UTIL_Remove(self:GetParent())
end

function modifier_spawn_creeps:OnIntervalThink()

spawn(self:GetCaster())
end

--------------------------------------------------------------------------------
t = {"creep_1","creep_2","creep_3","creep_4","creep_5","creep_6","creep_7","creep_8","creep_9","creep_10"}

function spawn(keys)
	position =  keys:GetOrigin()
	name_creep_box = t[RandomInt(1,#t)]
	local unit = CreateUnitByName(name_creep_box, position + RandomVector( RandomFloat( 150, 150 )), true, nil, nil, DOTA_TEAM_BADGUYS)
	add_modifier(unit)
	FindClearSpaceForUnit(unit, position, false)
	unit:SetUnitName("creep_box_2")
	unit:SetBaseDamageMin(150)
	unit:SetBaseDamageMax(150)
	unit:SetPhysicalArmorBaseValue(2)
	unit:SetBaseMagicalResistanceValue(10)
	unit:SetMaxHealth(4000)
	unit:SetBaseMaxHealth(4000)
	unit:SetHealth(4000)	
	unit:SetDeathXP(xp)
end