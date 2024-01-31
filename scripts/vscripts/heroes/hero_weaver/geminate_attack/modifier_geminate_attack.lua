modifier_geminate_attack = class({
    IsHidden = function()
        return true
    end,
    DeclareFunctions = function()
        return {
            MODIFIER_EVENT_ON_ATTACK,
            MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
            MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        }
    end
})

function modifier_geminate_attack:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.parent = self:GetParent()
end

function modifier_geminate_attack:OnAttack(keys)
    if (not IsServer()) then
        return
    end
    if (keys.attacker ~= self.parent or not self.ability:IsFullyCastable()) then
        return
    end
    if (keys.no_attack_cooldown or self.parent:IsIllusion() or self.parent:PassivesDisabled()) then
        return
    end
    if (self:GetAbility():GetAutoCastState() == false) then
        return
    end
    local modifier = keys.target:AddNewModifier(
            self.parent,
            self.ability,
            "modifier_geminate_attack_handler",
            {}
    )
    modifier:SetStackCount(self.ability:GetSpecialValueFor("tooltip_attack"))
    self.ability:UseResources(true, true, true, true)
end

function modifier_geminate_attack:GetModifierOverrideAbilitySpecial(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "tooltip_attack" then
			return 1
		end
	end
	return 0
end

function modifier_geminate_attack:GetModifierOverrideAbilitySpecialValue(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "tooltip_attack" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "tooltip_attack", data.ability_special_level )
            if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_agi12") then
                value = value + 1
            end
            return value
		end
	end
	return 0
end