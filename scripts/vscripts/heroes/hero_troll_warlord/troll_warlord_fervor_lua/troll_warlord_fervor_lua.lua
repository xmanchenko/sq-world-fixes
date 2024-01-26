LinkLuaModifier('modifier_troll_warlord_fervor_lua', "heroes/hero_troll_warlord/troll_warlord_fervor_lua/troll_warlord_fervor_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_troll_warlord_fervor_lua_debuff', "heroes/hero_troll_warlord/troll_warlord_fervor_lua/troll_warlord_fervor_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_troll_warlord_fervor_lua_debuff_2', "heroes/hero_troll_warlord/troll_warlord_fervor_lua/troll_warlord_fervor_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier('modifier_troll_warlord_fervor_lua_buff', "heroes/hero_troll_warlord/troll_warlord_fervor_lua/troll_warlord_fervor_lua", LUA_MODIFIER_MOTION_NONE)

troll_warlord_fervor_lua = class({})

function troll_warlord_fervor_lua:GetIntrinsicModifierName() 
    return 'modifier_troll_warlord_fervor_lua'
end

----------------------------------------------------------------

modifier_troll_warlord_fervor_lua = class({})

function modifier_troll_warlord_fervor_lua:IsHidden()
	return false
end

function modifier_troll_warlord_fervor_lua:OnCreated()
	if not IsServer() then
		return
	end
	self:SetStackCount(1)
	self.dmg = self:GetAbility():GetSpecialValueFor("dmg")
	self.currentTarget = {}
end

function modifier_troll_warlord_fervor_lua:OnRefresh()
	self:OnCreated()
end

function modifier_troll_warlord_fervor_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_CASTTIME_PERCENTAGE
	}
	return funcs
end

function modifier_troll_warlord_fervor_lua:GetModifierPercentageCasttime()
	if self:GetCaster():FindAbilityByName("special_bonus_unique_npc_dota_hero_troll_warlord_agi50") then
		return 100
	end
end

function modifier_troll_warlord_fervor_lua:OnAttackLanded( params )
	if params.attacker~=self:GetParent() then
		return
	end
	self:AddStack(params.target, params.original_damage, params.attacker)
	if self:GetCaster():FindAbilityByName("special_bonus_unique_npc_dota_hero_troll_warlord_agi50") then
		if self:GetCaster():IsRangedAttacker() and RollPercentage(15) then
			local abi = self:GetCaster():FindAbilityByName("troll_warlord_whirling_axes_ranged_lua")
			if abi:IsFullyCastable() then
				abi:SetOverrideCastPoint(0)
				self:GetCaster():CastAbilityOnPosition(params.target:GetAbsOrigin(), abi, -1)
				abi:EndCooldown()
			end
		end
	end
end

function modifier_troll_warlord_fervor_lua:AddStack(target, original_damage, attacker)
	self.count = self:GetAbility():GetSpecialValueFor("count") + 1
	local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_troll_warlord_agi10")
	if abil ~= nil	then 
		self.count = self.count - 2
	end
	
	if not self:GetParent():PassivesDisabled() then
		if self:GetStackCount() < self.count then
			self:SetStackCount(self:GetStackCount() + 1)
			return
		end
		if self:GetCaster():FindAbilityByName("npc_dota_hero_troll_warlord_agi_last") ~= nil then 
			target:AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_troll_warlord_fervor_lua_debuff",{duration = 5})
			local mod = target:FindModifierByName("modifier_troll_warlord_fervor_lua_debuff")
			mod:SetStackCount(mod:GetStackCount()+1)
		end
		
		if self:GetCaster():FindAbilityByName("npc_dota_hero_troll_warlord_int10") ~= nil then 
			target:AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_troll_warlord_fervor_lua_debuff_2",{duration = 5})
			local mod = target:FindModifierByName("modifier_troll_warlord_fervor_lua_debuff_2")
			mod:SetStackCount(mod:GetStackCount()+1)
		end
		
		if self:GetCaster():FindAbilityByName("npc_dota_hero_troll_warlord_agi9") ~= nil then 
			self:GetParent():AddNewModifier(self:GetParent(),self:GetAbility(),"modifier_troll_warlord_fervor_lua_buff",{duration = 5})
			local mod = self:GetParent():FindModifierByName("modifier_troll_warlord_fervor_lua_buff")
			mod:SetStackCount(mod:GetStackCount()+1)
		end
		
		if self:GetParent():GetAttackCapability() == DOTA_UNIT_CAP_MELEE_ATTACK then
			local damage = original_damage * (self.dmg / 100)
			local direction = (target:GetAbsOrigin() - self:GetParent():GetAbsOrigin()):Normalized()
			local enemies = FindUnitsInCone( self:GetParent():GetTeamNumber(), target:GetOrigin(), self:GetParent():GetOrigin(), self:GetParent():GetOrigin() + direction*650/2, 150, 360, nil, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
			for _,enemy in pairs(enemies) do
				if enemy ~= target then
					ApplyDamage({victim = enemy, attacker = self:GetParent(), damage = damage, damage_type = DAMAGE_TYPE_PHYSICAL, damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION})
				end
			end
			local effect_cast = ParticleManager:CreateParticle( "particles/econ/items/sven/sven_ti7_sword/sven_ti7_sword_spell_great_cleave.vpcf", PATTACH_WORLDORIGIN, self:GetCaster() )
			ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
			ParticleManager:SetParticleControlForward( effect_cast, 0, direction )
			ParticleManager:ReleaseParticleIndex( effect_cast )
		else
			if attacker == self:GetParent() and target and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and not self:GetParent():PassivesDisabled() then	
				local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetParent():Script_GetAttackRange() + 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)
				local target_number = 0
				for _, enemy in pairs(enemies) do
					if enemy ~= target then
			
						self:GetParent():PerformAttack(enemy, false, true, true, true, true, false, false)

						target_number = target_number + 1
						
						if target_number >= 2 then
							break
						end
					end
				end
			end
		end
		self:ResetStack()
	end
end


function modifier_troll_warlord_fervor_lua:ResetStack()
	if not self:GetParent():PassivesDisabled() then
		self:SetStackCount(1)
	end
end


-----------------------------------------------------------


modifier_troll_warlord_fervor_lua_debuff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	} end,
})

function modifier_troll_warlord_fervor_lua_debuff:OnCreated()
	self:SetStackCount(1)
end

function modifier_troll_warlord_fervor_lua_debuff:GetModifierPhysicalArmorBonus()
	return self:GetStackCount() * (-1)
end


-----------------------------------------------------------
modifier_troll_warlord_fervor_lua_debuff_2 = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	} end,
})

function modifier_troll_warlord_fervor_lua_debuff_2:OnCreated()
	self:SetStackCount(1)
end

function modifier_troll_warlord_fervor_lua_debuff_2:GetModifierMagicalResistanceBonus()
	return (self:GetStackCount() * (-1)) / 5
end


-----------------------------------------------------------


modifier_troll_warlord_fervor_lua_buff = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return true end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
	DeclareFunctions = function() return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	} end,
})

function modifier_troll_warlord_fervor_lua_buff:OnCreated()
	self:SetStackCount(1)
end

function modifier_troll_warlord_fervor_lua_buff:GetModifierAttackSpeedBonus_Constant()
	return self:GetStackCount() * 10
end

function FindUnitsInCone( nTeamNumber, vCenterPos, vStartPos, vEndPos, fStartRadius, fEndRadius, hCacheUnit, nTeamFilter, nTypeFilter, nFlagFilter, nOrderFilter, bCanGrowCache )
	local direction = vEndPos-vStartPos
	direction.z = 0

	local distance = direction:Length2D()
	direction = direction:Normalized()

	local big_radius = distance + math.max(fStartRadius, fEndRadius)

	local units = FindUnitsInRadius(
		nTeamNumber,	-- int, your team number
		vCenterPos,	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		big_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		nTeamFilter,	-- int, team filter
		nTypeFilter,	-- int, type filter
		nFlagFilter,	-- int, flag filter
		nOrderFilter,	-- int, order filter
		bCanGrowCache	-- bool, can grow cache
	)

	local targets = {}
	for _,unit in pairs(units) do
		local vUnitPos = unit:GetOrigin()-vStartPos
		local fProjection = vUnitPos.x*direction.x + vUnitPos.y*direction.y + vUnitPos.z*direction.z
		fProjection = math.max(math.min(fProjection,distance),0)
		local vProjection = direction*fProjection
		local fUnitRadius = (vUnitPos - vProjection):Length2D()
		local fInterpRadius = (fProjection/distance)*(fEndRadius-fStartRadius) + fStartRadius
		if fUnitRadius<=fInterpRadius then
			table.insert( targets, unit )
		end
	end
	return targets
end