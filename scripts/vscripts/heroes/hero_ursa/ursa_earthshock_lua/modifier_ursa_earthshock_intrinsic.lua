modifier_ursa_earthshock_intrinsic = class({})

function modifier_ursa_earthshock_intrinsic:IsHidden()
	return true
end

function modifier_ursa_earthshock_intrinsic:IsPurgable()
	return false
end

function modifier_ursa_earthshock_intrinsic:RemoveOnDeath()
	return false
end

function modifier_ursa_earthshock_intrinsic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
		MODIFIER_EVENT_ON_ATTACK,
	}
	return funcs
end

function modifier_ursa_earthshock_intrinsic:GetModifierOverrideAbilitySpecial(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "damage" then
			return 1
		end
		if data.ability_special_value == "shock_radius" then
			return 1
		end
	end
	return 0
end

function modifier_ursa_earthshock_intrinsic:GetModifierOverrideAbilitySpecialValue(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "damage" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "damage", data.ability_special_level )
            if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_int8") then
                value = value + self:GetCaster():GetIntellect() * 0.5
            end
            return value
		end
		if data.ability_special_value == "shock_radius" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "shock_radius", data.ability_special_level )
            if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_int11") then
                value = 800
            end
            return value
		end
	end
	return 0
end

function modifier_ursa_earthshock_intrinsic:OnAttack(params)
    self.caster = self:GetCaster()
    self.ability = self:GetAbility()
    if params.attacker == self:GetParent() and self.caster:FindAbilityByName("npc_dota_hero_ursa_str12") and not params.target:IsBuilding() and RollPercentage(12) then
        self.ability:EarthShock()
		self.ability:Enrage(0.7)
    end
end