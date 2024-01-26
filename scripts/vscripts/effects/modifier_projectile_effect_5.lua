modifier_projectile_effect_5 = class({})
--Classifications template
function modifier_projectile_effect_5:IsHidden()
    return true
end

function modifier_projectile_effect_5:IsDebuff()
    return false
end

function modifier_projectile_effect_5:IsPurgable()
    return false
end

function modifier_projectile_effect_5:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_projectile_effect_5:IsStunDebuff()
    return false
end

function modifier_projectile_effect_5:RemoveOnDeath()
    return false
end

function modifier_projectile_effect_5:DestroyOnExpire()
    return false
end

function modifier_projectile_effect_5:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROJECTILE_NAME
    }
end

function modifier_projectile_effect_5:GetModifierProjectileName()
    return "particles/econ/events/fall_2021/attack_modifier_fall_2021.vpcf"
end

function modifier_projectile_effect_5:GetPriority()
    return 10
end