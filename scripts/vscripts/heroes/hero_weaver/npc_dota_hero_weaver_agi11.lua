LinkLuaModifier( "modifier_npc_dota_hero_weaver_agi11", "heroes/hero_weaver/npc_dota_hero_weaver_agi11", LUA_MODIFIER_MOTION_NONE )

npc_dota_hero_weaver_agi11 = class({})

function npc_dota_hero_weaver_agi11:GetIntrinsicModifierName()
    return "modifier_npc_dota_hero_weaver_agi11"
end

modifier_npc_dota_hero_weaver_agi11 = class({})

function modifier_npc_dota_hero_weaver_agi11:IsHidden()
	return true
end

function modifier_npc_dota_hero_weaver_agi11:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_CRITICALSTRIKE,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

function modifier_npc_dota_hero_weaver_agi11:OnTakeDamage(params)
	if params.attacker==self:GetParent() then 
        self.reduction = params.damage
    end
end


function modifier_npc_dota_hero_weaver_agi11:GetModifierPreAttack_CriticalStrike( params )
    if params.attacker == self:GetCaster() then
        local health = params.target:GetHealth()
        if health > 0 then
            -- local armor = params.target:GetPhysicalArmorValue(false)
            -- ApplyDamage({
            --     victim = params.target,
            --     attacker = params.attacker,
            --     damage = 1,
            --     damage_type = DAMAGE_TYPE_PHYSICAL,
            --     damage_flags = 0,
            -- })
            -- local reduction = (0.06 * armor) / (1.0 + 0.06 * math.abs(armor))
            -- local baseDamage = self:GetCaster():GetAverageTrueAttackDamage(params.target)
            -- local damage = baseDamage * (1 - reduction)
            -- local trueDamage = damage
            -- for i = 0, params.attacker:GetModifierCount() -1 do
            --     local name = params.attacker:GetModifierNameByIndex(i)
            --     local modifier = params.attacker:FindModifierByName(name)
            --     if modifier and modifier.GetModifierTotalDamageOutgoing_Percentage then
            --         local value = modifier:GetModifierTotalDamageOutgoing_Percentage({damage_type = DAMAGE_TYPE_PHYSICAL})
            --         if not value then
            --             value = 0
            --         end
            --         trueDamage = trueDamage + trueDamage * (value / 100)
            --     end
            -- end
            -- for i = 0, params.target:GetModifierCount() -1 do
            --     local name = params.target:GetModifierNameByIndex(i)
            --     local modifier = params.target:FindModifierByName(name)
            --     if modifier and modifier.GetModifierIncomingDamage_Percentage then
            --         local value = modifier:GetModifierIncomingDamage_Percentage()
            --         if not value then
            --             value = 0
            --         end
            --         trueDamage = trueDamage * ((100 + value) / 100)
            --     end
            -- end
            ApplyDamage({
                victim = params.target,
                attacker = params.attacker,
                damage = 1,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL,
                ability = self:GetAbility(),
            })
            local baseDamage = self:GetCaster():GetAverageTrueAttackDamage(params.target)
            if health <= baseDamage * self.reduction * 7.5 then
                return 750
            end
        end
    end
    return 0
end