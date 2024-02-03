modifier_geminate_attack = class({
    IsHidden = function()
        return true
    end,
    DeclareFunctions = function()
        return {
            MODIFIER_EVENT_ON_ATTACK,
            MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
            MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
            MODIFIER_EVENT_ON_ATTACK_LANDED,
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
    if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_agi13") then
        if (keys.attacker ~= self.parent) then
            return
        end
        if (keys.no_attack_cooldown or self.parent:IsIllusion() or self.parent:PassivesDisabled()) then
            return
        end
        self:IncrementStackCount()
        if self.ability:IsFullyCastable() and self.ability:GetAutoCastState() then
            self:DecrementStackCount()
            self.ability:UseResources(true, true, true, true)
        else
            if self:GetStackCount() < 3 then
                return
            else
                self:SetStackCount(0)
            end
        end
    else
        if (keys.attacker ~= self.parent or not self.ability:IsFullyCastable()) then
            return
        end
        if (keys.no_attack_cooldown or self.parent:IsIllusion() or self.parent:PassivesDisabled()) then
            return
        end
        if (self:GetAbility():GetAutoCastState() == false) then
            return
        end
        self.ability:UseResources(true, true, true, true)
    end
    local modifier = keys.target:AddNewModifier(
        self.parent,
        self.ability,
        "modifier_geminate_attack_handler",
        {}
    ):SetStackCount(self.ability:GetSpecialValueFor("tooltip_attack"))
    if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_agi8") then
        local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetParent():Script_GetAttackRange() + 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)
        local target_number = 0
        for _, enemy in pairs(enemies) do
            if enemy ~= keys.target then

                local modifier = enemy:AddNewModifier(
                    self.parent,
                    self.ability,
                    "modifier_geminate_attack_handler",
                    {}
                ):SetStackCount(self.ability:GetSpecialValueFor("tooltip_attack"))

                target_number = target_number + 1
                
                if target_number >= 2 then
                    break
                end
            end
        end
    end
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

function modifier_geminate_attack:OnAttackLanded(keys)
    if keys.no_attack_cooldown then
        -- print(keys.inflictor)
    end
end