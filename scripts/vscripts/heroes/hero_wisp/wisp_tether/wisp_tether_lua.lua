wisp_tether_lua = class({})

LinkLuaModifier("modifier_wisp_tether_lua", "heroes/hero_wisp/wisp_tether/wisp_tether_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_tether_lua_ally", "heroes/hero_wisp/wisp_tether/wisp_tether_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_tether_lua_latch", "heroes/hero_wisp/wisp_tether/wisp_tether_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_spell_ampl_tether", "heroes/hero_wisp/wisp_tether/wisp_tether_lua.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_wisp_tether_lua_attributes", "heroes/hero_wisp/wisp_tether/wisp_tether_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_tether_lua_bonus_strength", "heroes/hero_wisp/wisp_tether/wisp_tether_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_tether_lua_bonus_intellect", "heroes/hero_wisp/wisp_tether/wisp_tether_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_wisp_tether_lua_bonus_agility", "heroes/hero_wisp/wisp_tether/wisp_tether_lua.lua", LUA_MODIFIER_MOTION_NONE)

LinkLuaModifier("modifier_wisp_tether_lua_ally_attack", "heroes/hero_wisp/wisp_tether/wisp_tether_lua.lua", LUA_MODIFIER_MOTION_NONE)

function wisp_tether_lua:GetManaCost(iLevel)
    return 100 + math.min(65000, self:GetCaster():GetIntellect() /100)
end

function wisp_tether_lua:GetCastRange(vLocation, hTarget)
	-- if self:GetCaster():FindAbilityByName("npc_dota_hero_wisp_agi10") then
	-- 	return self:GetSpecialValueFor("radius") + 1500
	-- end
	return self:GetSpecialValueFor("radius")
end


function wisp_tether_lua:GetCustomCastErrorTarget(target)
	if target == self:GetCaster() then
		return "dota_hud_error_cant_cast_on_self"
	elseif target:HasModifier("modifier_wisp_tether_lua") and self:GetCaster():HasModifier("modifier_wisp_tether_lua_ally") then
		return "WHY WOULD YOU DO THIS"
	end
end

function wisp_tether_lua:CastFilterResultTarget(target)
	if IsServer() then
		local caster = self:GetCaster()
		local casterID = caster:GetPlayerOwnerID()
		local targetID = target:GetPlayerOwnerID()

		if target == caster then
			return UF_FAIL_CUSTOM
		end

		if target:IsCourier() then
			return UF_FAIL_COURIER
		end

		if target:HasModifier("modifier_wisp_tether_lua") and self:GetCaster():HasModifier("modifier_wisp_tether_lua_ally") then
			return UF_FAIL_CUSTOM
		end
		
		local nResult = UnitFilter(target, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), caster:GetTeamNumber())
		return nResult
	end
end

function wisp_tether_lua:OnSpellStart()
	local ability 				= self:GetCaster():FindAbilityByName("wisp_tether_lua")
	local caster 				= self:GetCaster()
	local destroy_tree_radius 	= ability:GetSpecialValueFor("destroy_tree_radius")
	local movespeed 			= ability:GetSpecialValueFor("movespeed")
	local latch_distance 		= self:GetSpecialValueFor("latch_distance")

	self.caster_origin 			= self:GetCaster():GetAbsOrigin()
	self.target_origin 			= self:GetCursorTarget():GetAbsOrigin()
	self.tether_ally 			= self:GetCursorTarget()
	self.target 				= self:GetCursorTarget()

	if self:GetCaster():FindAbilityByName("npc_dota_hero_wisp_agi_last") ~= nil then
		self.target:AddNewModifier(caster, self, "modifier_wisp_tether_lua_ally_attack", {})
	end
	if self:GetCaster():FindAbilityByName("special_bonus_unique_npc_dota_hero_wisp_agi50") then
		self.target:AddNewModifier(caster, self, "modifier_wisp_tether_lua_attributes", {})
	end
	local radius 			= self:GetSpecialValueFor("radius")
	if caster:FindAbilityByName("npc_dota_hero_wisp_agi10") then
		radius = radius + 1500
	end
	caster:AddNewModifier(self.target, self, "modifier_wisp_tether_lua", {radius = radius})


	local tether_modifier = self:GetCursorTarget():AddNewModifier(self:GetCaster(), ability, "modifier_wisp_tether_lua_ally", {})

	if not caster:HasAbility("wisp_tether_break_lua") then
		caster:AddAbility("wisp_tether_break_lua")
	end

	caster:SwapAbilities("wisp_tether_lua", "wisp_tether_break_lua", false, true)
	caster:FindAbilityByName("wisp_tether_break_lua"):SetLevel(1)
	caster:FindAbilityByName("wisp_tether_break_lua"):StartCooldown(0.25)
end

function wisp_tether_lua:OnUnStolen()
	if self:GetCaster():HasAbility("wisp_tether_break_lua") then
		self:GetCaster():RemoveAbility("wisp_tether_break_lua")
	end
end


-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

modifier_wisp_tether_lua = class({})

function modifier_wisp_tether_lua:IsHidden() return false end
function modifier_wisp_tether_lua:IsPurgable() return false end
function modifier_wisp_tether_lua:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end

function modifier_wisp_tether_lua:OnCreated(params)
	self.parent 			= self:GetParent()
	self.target 			= self:GetCaster()
	self.original_speed		= self:GetParent():GetMoveSpeedModifier(self:GetParent():GetBaseMoveSpeed(), false)
	self.target_speed		= self.target:GetMoveSpeedModifier(self.target:GetBaseMoveSpeed(), true)
	self.difference			= self.target_speed - self.original_speed
	self.heal 				= 0
	self.mana 				= 0
	if IsServer() then 
		self.tether_heal_amp 	= self:GetAbility():GetSpecialValueFor("tether_heal_amp")	
		
		if self:GetParent():FindAbilityByName("npc_dota_hero_wisp_str6") ~= nil then 
		self.tether_heal_amp = self:GetAbility():GetSpecialValueFor("tether_heal_amp") * 1.3
		end
		
		self.total_gained_mana 		= 0
		self.total_gained_health 	= 0
		self.update_timer 			= 0
		self.time_to_send 			= 1
		self.radius = params.radius
		self:GetCaster():EmitSound("Hero_Wisp.Tether")
	end
	self.interval = 0.5
	self:StartIntervalThink(self.interval)
end

function modifier_wisp_tether_lua:OnIntervalThink()
	self.difference			= 0

	self.original_speed		= self:GetParent():GetMoveSpeedModifier(self:GetParent():GetBaseMoveSpeed(), false)
	self.target_speed		= self.target:GetMoveSpeedModifier(self.target:GetBaseMoveSpeed(), true)
	self.difference			= self.target_speed - self.original_speed
	
	

	if not IsServer() then return end
	
	if not self:GetAbility() or not self:GetAbility().tether_ally then
		self:Destroy()
		return
	end
	self.heal = self.heal + self.parent:GetHealthRegen() * self.interval
	self.mana = self.mana + self.parent:GetManaRegen() * self.interval
	SendOverheadEventMessage( self:GetCaster(), OVERHEAD_ALERT_HEAL , self.target, math.min(self.heal * self.tether_heal_amp, 2^30), nil )
	self.target:Heal(math.min(self.heal * self.tether_heal_amp, 2^30), self:GetAbility())
	self.heal = 0
	SendOverheadEventMessage( self:GetCaster(), OVERHEAD_ALERT_MANA_ADD , self.target, self.mana * self.tether_heal_amp, nil )
	self.target:GiveMana(self.mana * self.tether_heal_amp)
	self.mana = 0
	-- self.update_timer = self.update_timer + FrameTime()

	-- handle health and mana
	-- if self.update_timer > self.time_to_send then 
		-- SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, self.target, self.total_gained_health * self.tether_heal_amp, nil)	
		-- SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self.target, self.total_gained_mana * self.tether_heal_amp, nil)

		-- self.total_gained_mana 		= 0
		-- self.total_gained_health 	= 0
		-- self.update_timer 			= 0
	-- end
	
	if (self:GetParent():IsOutOfGame()) then
		self:GetParent():RemoveModifierByName("modifier_wisp_tether_lua")
		return
	end
	
	if self:GetParent():HasModifier("modifier_wisp_tether_lua_latch") then
		return
	end

	if (self:GetAbility().tether_ally:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Length2D() <= self.radius then
		return
	end
	self:GetParent():RemoveModifierByName("modifier_wisp_tether_lua")
end

function modifier_wisp_tether_lua:DeclareFunctions()
	local decFuncs = {
		MODIFIER_PROPERTY_MOVESPEED_BASE_OVERRIDE,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
	}

	return decFuncs
end

function modifier_wisp_tether_lua:GetModifierMoveSpeedOverride()
	if self.target and self.target.GetBaseMoveSpeed then
		return self.target:GetBaseMoveSpeed()
	end
end

function modifier_wisp_tether_lua:GetModifierMoveSpeedBonus_Constant()
	if self.original_speed and self.target:GetMoveSpeedModifier(self.target:GetBaseMoveSpeed(), true) >= self.original_speed and self.difference then
		return self.difference
	end
end

function modifier_wisp_tether_lua:GetModifierMoveSpeed_Limit()
	return self.target_speed
end

function modifier_wisp_tether_lua:GetModifierIgnoreMovespeedLimit()
	return 1
end

function modifier_wisp_tether_lua:OnRemoved()
	if IsServer() then
		if self:GetParent():HasModifier("modifier_wisp_tether_lua_latch") then
			self:GetParent():RemoveModifierByName("modifier_wisp_tether_lua_latch")
		end
		
		if self:GetParent():HasModifier("modifier_wisp_tether_lua_agi_talant") then
			self:GetParent():RemoveModifierByName("modifier_wisp_tether_lua_agi_talant")
		end

		if self.target:HasModifier("modifier_wisp_tether_lua_ally") then
			self.target:RemoveModifierByName("modifier_wisp_tether_lua_ally")
		end

		self:GetCaster():EmitSound("Hero_Wisp.Tether.Stop")
		self:GetCaster():StopSound("Hero_Wisp.Tether")
		self:GetParent():SwapAbilities("wisp_tether_break_lua", "wisp_tether_lua", false, true)
	end
end

----------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------

modifier_wisp_tether_lua_ally = class({})

function modifier_wisp_tether_lua_ally:IsHidden() return false end
function modifier_wisp_tether_lua_ally:IsPurgable() return false end

function modifier_wisp_tether_lua_ally:OnCreated()
	if IsServer() then
		self.pfx = ParticleManager:CreateParticle("particles/units/heroes/hero_wisp/wisp_tether.vpcf", PATTACH_ABSORIGIN_FOLLOW,  self:GetCaster())
		ParticleManager:SetParticleControlEnt(self.pfx, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
		ParticleManager:SetParticleControlEnt(self.pfx, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetAbsOrigin(), true)

		EmitSoundOn("Hero_Wisp.Tether.Target", self:GetParent())
		
	--	self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_spell_ampl_tether", {})
		
		-- self:StartIntervalThink(FrameTime())
		self.atr = self:GetCaster():GetPrimaryAttribute()
		if self.atr == DOTA_ATTRIBUTE_AGILITY then
			self.atr_bonus = self:GetCaster():GetAgility()
		elseif self.atr == DOTA_ATTRIBUTE_INTELLECT then
			self.atr_bonus = self:GetCaster():GetIntellect()
		elseif self.atr == DOTA_ATTRIBUTE_STRENGTH then
			self.atr_bonus = self:GetCaster():GetStrength()
		end
	end
end

function modifier_wisp_tether_lua_ally:OnIntervalThink()
	if IsServer() then
		if not self:GetAbility() then
			self:Destroy()
			return
		end
	
		local velocity = self:GetParent():GetAbsOrigin() - self:GetCaster():GetAbsOrigin()
		local vVelocity = velocity / FrameTime()
		vVelocity.z = 0

		local projectile = 
		{
			Ability				= self:GetAbility(),
--			EffectName			= "particles/hero/ghost_revenant/blackjack_projectile.vpcf",
			vSpawnOrigin		= self:GetCaster():GetAbsOrigin(),
			fDistance			= velocity:Length2D(),
			fStartRadius		= 100,
			fEndRadius			= 100,
			bReplaceExisting 	= false,
			iMoveSpeed			= vVelocity,
			Source				= self:GetCaster(),
			iUnitTargetTeam		= DOTA_UNIT_TARGET_TEAM_ENEMY,
			iUnitTargetFlags	= DOTA_UNIT_TARGET_FLAG_NONE,
			iUnitTargetType		= DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
			fExpireTime			= GameRules:GetGameTime() + 1,
			bDeleteOnHit		= false,
			vVelocity			= vVelocity / 3, 
			ExtraData 			= {
			}
		}

		ProjectileManager:CreateLinearProjectile(projectile)
	end
end



function modifier_wisp_tether_lua_ally:OnRemoved() 
	if IsServer() then
		self:GetParent():StopSound("Hero_Wisp.Tether.Target")
		ParticleManager:DestroyParticle(self.pfx, false)
		ParticleManager:ReleaseParticleIndex(self.pfx)
	
		if self:GetAbility() then
			self:GetAbility().target = nil
		end
		
		self:GetParent():RemoveModifierByName("modifier_wisp_tether_lua_ally_attack")
		self:GetParent():RemoveModifierByName("modifier_wisp_tether_lua_attributes")
		self:GetParent():RemoveModifierByName("modifier_spell_ampl_tether")
		self:GetCaster():RemoveModifierByName("modifier_wisp_tether_lua")
	end
end

function modifier_wisp_tether_lua_ally:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,

		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
	}
end

function modifier_wisp_tether_lua_ally:GetModifierBonusStats_Strength()
	if self.atr == DOTA_ATTRIBUTE_STRENGTH then
		return self.atr_bonus
	end
	return 0
end

function modifier_wisp_tether_lua_ally:GetModifierBonusStats_Agility()
	if self.atr == DOTA_ATTRIBUTE_AGILITY then
		return self.atr_bonus
	end
	return 0
end

function modifier_wisp_tether_lua_ally:GetModifierBonusStats_Intellect()
	if self.atr == DOTA_ATTRIBUTE_INTELLECT then
		return self.atr_bonus
	end
	return 0
end

function modifier_wisp_tether_lua_ally:GetModifierAttackSpeedBonus_Constant()
-- local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_wisp_agi10")	
-- 				if abil ~= nil then 
-- 	return self:GetCaster():GetAgility()/4 
-- 	end
	return 0
end


function modifier_wisp_tether_lua_ally:GetModifierMoveSpeedBonus_Percentage()
	if self:GetAbility() then
		if self:GetCaster():FindAbilityByName("npc_dota_hero_wisp_str9") then
			return self:GetAbility():GetSpecialValueFor("movespeed") * 2
		end
		return self:GetAbility():GetSpecialValueFor("movespeed")
	end
end

function modifier_wisp_tether_lua_ally:GetModifierIgnoreMovespeedLimit()
	if self:GetCaster():FindAbilityByName("npc_dota_hero_wisp_str9") then
		return 1
	end
	return 0
end

function modifier_wisp_tether_lua_ally:GetModifierBonusStats_Intellect()
	local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_wisp_int8")	
		if abil ~= nil then 
		return self:GetCaster():GetIntellect()/2
	end
	return 0
end



modifier_wisp_tether_lua_ally_attack = class({})
function modifier_wisp_tether_lua_ally_attack:IsHidden() return true end
function modifier_wisp_tether_lua_ally_attack:IsPurgable() return false end
function modifier_wisp_tether_lua_ally_attack:DeclareFunctions()
	local decFuncs = {
		MODIFIER_EVENT_ON_ATTACK,
	}
	return decFuncs
end

function modifier_wisp_tether_lua_ally_attack:OnAttack(params)
	if IsServer() then
		if params.attacker == self:GetParent() then
			self:GetCaster():PerformAttack(params.target, true, true, true, false, true, false, false)
		end
	end
end

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

modifier_wisp_tether_lua_latch = class({})

function modifier_wisp_tether_lua_latch:IsHidden()	return true end
function modifier_wisp_tether_lua_latch:IsPurgable()	return false end

function modifier_wisp_tether_lua_latch:OnCreated(params)
	if IsServer() then
		self.target 				= self:GetAbility().target
		self.destroy_tree_radius 	= params.destroy_tree_radius
		self.final_latch_distance	= 300
		self:StartIntervalThink(FrameTime())
	end
end

function modifier_wisp_tether_lua_latch:OnIntervalThink()
	if IsServer() then
		if self:GetParent():IsStunned() or self:GetParent():IsHexed() or self:GetParent():IsOutOfGame() or (self:GetParent().IsFeared and self:GetParent():IsFeared()) or (self:GetParent().IsHypnotized and self:GetParent():IsHypnotized()) or self:GetParent():IsRooted() then
			self:StartIntervalThink(-1)
			self:Destroy()
			return
		end
	
		local casterDir = self:GetCaster():GetAbsOrigin() - self.target:GetAbsOrigin()
		local distToAlly = casterDir:Length2D()
		casterDir = casterDir:Normalized()
		if distToAlly > self.final_latch_distance then
			distToAlly = distToAlly - self:GetAbility():GetSpecialValueFor("latch_speed") * FrameTime()
			distToAlly = math.max( distToAlly, self.final_latch_distance )	-- Clamp this value

			local pos = self.target:GetAbsOrigin() + casterDir * distToAlly
			pos = GetGroundPosition(pos, self:GetCaster())

			self:GetCaster():SetAbsOrigin(pos)
		end

		
		if distToAlly <= self.final_latch_distance then
			GridNav:DestroyTreesAroundPoint(self:GetCaster():GetAbsOrigin(), self.destroy_tree_radius, false)
			ResolveNPCPositions(self:GetCaster():GetAbsOrigin(), 128)
			self:GetCaster():RemoveModifierByName("modifier_wisp_tether_lua_latch")
		end
	end
end

function modifier_wisp_tether_lua_latch:OnDestroy()
	if not IsServer() then return end
	
	FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), false)
end

------------------------------
--		 BREAK TETHER 		--
------------------------------
wisp_tether_break_lua = class({})
function wisp_tether_break_lua:IsInnateAbility() return true end
function wisp_tether_break_lua:IsStealable() return false end
function wisp_tether_break_lua:ProcsMagicStick() return false end

function wisp_tether_break_lua:OnSpellStart()
	if not self:GetCaster():HasAbility("wisp_tether_lua") then
		local stolenAbility = self:GetCaster():AddAbility("wisp_tether_lua")
		stolenAbility:SetLevel(min((self:GetCaster():GetLevel() / 2) - 1, 4))
		self:GetCaster():SwapAbilities("wisp_tether_break_lua", "wisp_tether_lua", false, true)
	end

	self:GetCaster():RemoveModifierByName("modifier_wisp_tether_lua")
	local target = self:GetCaster():FindAbilityByName("wisp_tether_lua").target
end

function wisp_tether_break_lua:OnUnStolen()
	if self:GetCaster():HasAbility("wisp_tether_lua") then
		self:GetCaster():RemoveAbility("wisp_tether_lua")
	end
end

-----------------------------------------------------------------


modifier_spell_ampl_tether = class({})

function modifier_spell_ampl_tether:IsHidden()
	return false
end

function modifier_spell_ampl_tether:IsPurgable()
	return false
end

function modifier_spell_ampl_tether:OnCreated()
if IsServer() then
	caster = self:GetCaster()
    player = Entities:FindByName( nil, "npc_dota_hero_wisp")
	spell_amp = player:GetSpellAmplification(false) * 25
	end
end

function modifier_spell_ampl_tether:DeclareFunctions()
	return {MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE}
end

function modifier_spell_ampl_tether:GetModifierSpellAmplify_Percentage()
	return spell_amp
end

--------------------------------------------------------------------------------

modifier_wisp_tether_lua_attributes = class({
	IsHidden                 = function(self) return true end,
    IsPurgable                 = function(self) return false end,
    IsDebuff                 = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath             = function(self) return true end,
})

function modifier_wisp_tether_lua_attributes:OnCreated()
	if IsServer() then
		self.bonus_strength = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_wisp_tether_lua_bonus_strength", {})
		self.bonus_intellect = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_wisp_tether_lua_bonus_intellect", {})
		self.bonus_agility = self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_wisp_tether_lua_bonus_agility", {})
		self:StartIntervalThink(1)
		self:OnIntervalThink()
	end
end

function modifier_wisp_tether_lua_attributes:OnDestroy()
	if IsServer() then
		self.bonus_strength:Destroy()
		self.bonus_intellect:Destroy()
		self.bonus_agility:Destroy()
	end
end

function modifier_wisp_tether_lua_attributes:OnIntervalThink()
	local parent = self:GetParent()
	if parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then
		self.bonus_strength:SetStackCount( (parent:GetStrength() - self.bonus_strength:GetStackCount()) / 2 )
		self.bonus_intellect:SetStackCount( (parent:GetIntellect() - self.bonus_intellect:GetStackCount()) / 2 )
		self.bonus_agility:SetStackCount( (parent:GetAgility() - self.bonus_agility:GetStackCount()) / 2 )
	elseif parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
		self.bonus_strength:SetStackCount( parent:GetStrength() - self.bonus_strength:GetStackCount() )
	elseif parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY then
		self.bonus_agility:SetStackCount( parent:GetAgility() - self.bonus_agility:GetStackCount() )
	elseif parent:GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
		self.bonus_intellect:SetStackCount( parent:GetIntellect() - self.bonus_intellect:GetStackCount() )
	end
	self:StartIntervalThink(-1)
end

modifier_wisp_tether_lua_bonus_strength = class({
    IsHidden                 = function(self) return self:GetStackCount() == 0 end,
    IsPurgable                 = function(self) return false end,
    IsDebuff                 = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath             = function(self) return true end,
    DeclareFunctions             = function(self) return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end,
	GetModifierBonusStats_Strength = function(self) return self:GetStackCount() end
})
modifier_wisp_tether_lua_bonus_intellect = class({
    IsHidden                 = function(self) return self:GetStackCount() == 0 end,
    IsPurgable                 = function(self) return false end,
    IsDebuff                 = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath             = function(self) return true end,
    DeclareFunctions             = function(self) return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end,
	GetModifierBonusStats_Intellect = function(self) return self:GetStackCount() end
})
modifier_wisp_tether_lua_bonus_agility = class({
    IsHidden                 = function(self) return self:GetStackCount() == 0 end,
    IsPurgable                 = function(self) return false end,
    IsDebuff                 = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath             = function(self) return true end,
    DeclareFunctions             = function(self) return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end,
	GetModifierBonusStats_Agility = function(self) return self:GetStackCount() end
})