modifier_the_swarm_intrinsic = class({})

function modifier_the_swarm_intrinsic:IsHidden()
	return true
end

function modifier_the_swarm_intrinsic:IsPurgable()
	return false
end

function modifier_the_swarm_intrinsic:RemoveOnDeath()
	return false
end


function modifier_the_swarm_intrinsic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

function modifier_the_swarm_intrinsic:GetModifierOverrideAbilitySpecial(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "attack_rate" then
			return 1
		end
        if data.ability_special_value == "armor_reduction" then
			return 1
		end
        if data.ability_special_value == "damage" then
			return 1
		end
	end
	return 0
end

function modifier_the_swarm_intrinsic:GetModifierOverrideAbilitySpecialValue(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "attack_rate" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "attack_rate", data.ability_special_level )
            if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_str8") then
                value = value - 0.3
            end
            return value
		end
        if data.ability_special_value == "armor_reduction" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "armor_reduction", data.ability_special_level )
            if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_agi9") then
                value = value * 2
            end
            return value
		end
        if data.ability_special_value == "damage" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "damage", data.ability_special_level )
            if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_int10") then
                value = value + self:GetCaster():GetIntellect() * 0.5
            end
            return value
		end
	end
	return 0
end

function modifier_the_swarm_intrinsic:OnAttackLanded(params)
    local target = params.target
	if params.attacker ~= self:GetParent() then return end
    if not self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_str11") then return end
    if not target:HasModifier("modifier_the_swarm_debuff") and target ~= nil and target:IsAlive() then
        target:EmitSound("Hero_Weaver.SwarmAttach")
            local target_position = target:GetAbsOrigin()
            local beetle = CreateUnitByName(
                    "npc_dota_weaver_swarm",
                    target_position + target:GetForwardVector() * 64,
                    false,
                    self:GetCaster(),
                    self:GetCaster(),
                    self:GetCaster():GetTeamNumber()
            )
            beetle:AddNewModifier(
                    self:GetCaster(),
                    self:GetAbility(),
                    "modifier_the_swarm_beetle",
                    {
                        target_entindex = target:entindex()
                    }
            )
            beetle:AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_pips", {pips_count = 8})
            target:AddNewModifier(
                    self:GetCaster(),
                    self:GetAbility(),
                    "modifier_the_swarm_debuff",
                    {
                        beetle_entindex = beetle:entindex(),
                        duration = self:GetAbility():GetSpecialValueFor("duration")
                    }
            )
            beetle:SetMaxHealth(8)
            if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_int11") then
                local damage_table = {
                    victim = target,
                    damage = self:GetCaster():GetIntellect() * 1.5,
                    damage_type = DAMAGE_TYPE_MAGICAL,
                    damage_flags = DOTA_DAMAGE_FLAG_NONE,
                    attacker = self:GetCaster(),
                    ability = self:GetAbility(),
                }
                ApplyDamage(damage_table)
            end
    end
end