modifier_ursa_overpower_intrinsic = class({})

function modifier_ursa_overpower_intrinsic:IsHidden()
	return true
end

function modifier_ursa_overpower_intrinsic:IsPurgable()
	return false
end

function modifier_ursa_overpower_intrinsic:RemoveOnDeath()
	return false
end

function modifier_ursa_overpower_intrinsic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
	}
	return funcs
end

function modifier_ursa_overpower_intrinsic:GetModifierOverrideAbilitySpecial(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "attack_speed_bonus" then
			return 1
		end
		if data.ability_special_value == "duration_tooltip" then
			return 1
		end
		if data.ability_special_value == "max_attacks" then
			return 1
		end
	end
	return 0
end

function modifier_ursa_overpower_intrinsic:GetModifierOverrideAbilitySpecialValue(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "attack_speed_bonus" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "attack_speed_bonus", data.ability_special_level )
            if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_agi8") then
                value = value + 250
            end
            return value
		end
		if data.ability_special_value == "duration_tooltip" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "duration_tooltip", data.ability_special_level )
            if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_int9") then
                value = value * 1.5
            end
            return value
		end
		if data.ability_special_value == "max_attacks" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "max_attacks", data.ability_special_level )
            if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_int9") then
                value = value * 2
            end
            return value
		end
	end
	return 0
end

function modifier_ursa_overpower_intrinsic:OnCreated( kv )
	if not IsServer() then return end
	self:StartIntervalThink(0.1)
end

function modifier_ursa_overpower_intrinsic:OnIntervalThink()
	if not self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_int7") then return end
	local caster = self:GetCaster()
	if self:GetAbility():GetAutoCastState() and self:GetAbility():IsFullyCastable() and caster:IsAlive() and not caster:IsSilenced() and not caster:IsStunned() then
		self:GetAbility():OnSpellStart()
		self:GetAbility():UseResources(true, false, false, true)
	end
end