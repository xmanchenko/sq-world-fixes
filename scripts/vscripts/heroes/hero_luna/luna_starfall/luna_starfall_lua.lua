LinkLuaModifier( "modifier_generic_stunned_lua", "heroes/generic/modifier_generic_stunned_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_luna_starfall_lua", "heroes/hero_luna/luna_starfall/luna_starfall_lua.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_luna_starfall_lua_aura", "heroes/hero_luna/luna_starfall/luna_starfall_lua.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_luna_starfall_lua_aura_cd", "heroes/hero_luna/luna_starfall/luna_starfall_lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if luna_starfall_lua == nil then
	luna_starfall_lua = class({})
end
function luna_starfall_lua:GetIntrinsicModifierName()
	return "modifier_luna_starfall_lua"
end
function luna_starfall_lua:PlayEffect(target)
	local caster = self:GetCaster()
	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_luna/luna_lucent_beam.vpcf", PATTACH_POINT_FOLLOW, caster)
	ParticleManager:SetParticleControl(particle, 1, target:GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(particle,	5, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
	ParticleManager:SetParticleControlEnt(particle,	6, caster, PATTACH_POINT_FOLLOW, "attach_attack1", caster:GetAbsOrigin(), true)
	ParticleManager:ReleaseParticleIndex(particle)
	target:EmitSound("Hero_Luna.LucentBeam.Target")
end
function luna_starfall_lua:GetCooldown( level )
	if self:GetCaster():FindAbilityByName("special_bonus_unique_npc_dota_hero_luna_int50") then
		return 1.0
	end
	return self.BaseClass.GetCooldown( self, level )
end
function luna_starfall_lua:HitTheEnemy(target)
	local caster = self:GetCaster()
	local damage = self:GetSpecialValueFor("damage")
	local damageTable = {
		victim 			= target,
		damage 			= damage,
		damage_type		= DAMAGE_TYPE_MAGICAL,
		damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
		attacker 		= caster,
		ability 		= self
	}
	ApplyDamage(damageTable)
	if caster:FindAbilityByName("npc_dota_hero_luna_int7") and not caster:FindAbilityByName("special_bonus_unique_npc_dota_hero_luna_int50") then 
		target:AddNewModifier(caster,self,"modifier_generic_stunned_lua",{ duration = 1 })
	end
	self:PlayEffect(target)
end
function luna_starfall_lua:GetCastRange(vLocation, hTarget)
	return self:GetSpecialValueFor("radius")
end
---------------------------------------------------------------------
--Modifiers
if modifier_luna_starfall_lua == nil then
	modifier_luna_starfall_lua = class({})
end
function modifier_luna_starfall_lua:IsHidden()
	return true
end
function modifier_luna_starfall_lua:OnCreated(params)
	self.ability = self:GetAbility()
	self.caster = self:GetCaster()
	if not IsServer() then return end
	self.radius = self.ability:GetSpecialValueFor("radius")
	self:StartIntervalThink(0.1)
end
function modifier_luna_starfall_lua:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_luna_starfall_lua:OnDestroy()
	if IsServer() then
	end
end
function modifier_luna_starfall_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
	}
end

function modifier_luna_starfall_lua:GetModifierOverrideAbilitySpecial(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "damage" then
			return 1
		end
	end
	return 0
end

function modifier_luna_starfall_lua:GetModifierOverrideAbilitySpecialValue(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "damage" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "damage", data.ability_special_level )
            if self.caster:FindAbilityByName("npc_dota_hero_luna_int6") then
				value = value + self.caster:GetIntellect() / 2
			end
			if self.caster:FindAbilityByName("npc_dota_hero_luna_str6") then
				value = value + self.caster:GetStrength()
			end
			if self.caster:FindAbilityByName("special_bonus_unique_npc_dota_hero_luna_int50") then
				value = value + self.caster:GetIntellect() * 0.5
			end
            return value
		end
	end
	return 0
end

function modifier_luna_starfall_lua:OnIntervalThink()
	if self.ability:IsFullyCastable() and not self.caster:IsSilenced() and not self.caster:FindAbilityByName("special_bonus_unique_npc_dota_hero_luna_int50") then
		local enemies = FindUnitsInRadius(self.caster:GetTeam(),self.caster:GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
		if #enemies > 0 then
			local target = enemies[1]
			self.caster:EmitSound("Hero_Luna.LucentBeam.Cast")
			self.ability:HitTheEnemy(target)
			self.ability:UseResources(true, true, true, true)
		end
	end
end

function modifier_luna_starfall_lua:IsAura() 
	return self:GetCaster():FindAbilityByName("special_bonus_unique_npc_dota_hero_luna_int50") ~= nil
end

function modifier_luna_starfall_lua:GetModifierAura() 
	return "modifier_luna_starfall_lua_aura" 
end

function modifier_luna_starfall_lua:GetAuraRadius()
	return self.ability:GetSpecialValueFor("radius")
end

function modifier_luna_starfall_lua:GetAuraSearchFlags() 
	return DOTA_UNIT_TARGET_FLAG_NONE 
end

function modifier_luna_starfall_lua:GetAuraSearchTeam() 
	return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function modifier_luna_starfall_lua:GetAuraSearchType() 
	return DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO
end

modifier_luna_starfall_lua_aura = class({})

function modifier_luna_starfall_lua_aura:IsDebuff()
	return true
end

function modifier_luna_starfall_lua_aura:OnCreated( kv )
	if not IsServer() then return end
	self.ability = self:GetAbility()
	local interval = 0.2
	local modifier_cd = self:GetParent():FindAbilityByName("modifier_luna_starfall_lua_aura_cd")
	if modifier_cd then
		interval = modifier_cd:GetRemainingTime()
	end
	self:StartIntervalThink(interval)
end

function modifier_luna_starfall_lua_aura:OnIntervalThink()
	self.ability:HitTheEnemy(self:GetParent())
	local cooldown = self.ability:GetCooldown( self.ability:GetLevel() ) * self:GetCaster():GetCooldownReduction()
	self:GetParent():AddNewModifier(self:GetCaster(), self.ability, "modifier_luna_starfall_lua_aura_cd", {duration = cooldown})
	self:StartIntervalThink(cooldown)
end

modifier_luna_starfall_lua_aura_cd = class({})

function modifier_luna_starfall_lua_aura_cd:IsPurgable()
	return false
end

