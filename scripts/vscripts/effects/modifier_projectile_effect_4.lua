modifier_projectile_effect_4 = class({})
--Classifications template
function modifier_projectile_effect_4:IsHidden()
    return true
end

function modifier_projectile_effect_4:IsDebuff()
    return false
end

function modifier_projectile_effect_4:IsPurgable()
    return false
end

function modifier_projectile_effect_4:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_projectile_effect_4:IsStunDebuff()
    return false
end

function modifier_projectile_effect_4:RemoveOnDeath()
    return false
end

function modifier_projectile_effect_4:DestroyOnExpire()
    return false
end

function modifier_projectile_effect_4:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROJECTILE_NAME
    }
end

function modifier_projectile_effect_4:GetModifierProjectileName()
    return "particles/econ/events/spring_2021/attack_modifier_spring_2021.vpcf"
end

function modifier_projectile_effect_4:GetPriority()
    return 10
end