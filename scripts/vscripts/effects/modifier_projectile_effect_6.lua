modifier_projectile_effect_6 = class({})
--Classifications template
function modifier_projectile_effect_6:IsHidden()
    return true
end

function modifier_projectile_effect_6:IsDebuff()
    return false
end

function modifier_projectile_effect_6:IsPurgable()
    return false
end

function modifier_projectile_effect_6:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_projectile_effect_6:IsStunDebuff()
    return false
end

function modifier_projectile_effect_6:RemoveOnDeath()
    return false
end

function modifier_projectile_effect_6:DestroyOnExpire()
    return false
end

function modifier_projectile_effect_6:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROJECTILE_NAME
    }
end

function modifier_projectile_effect_6:GetModifierProjectileName()
    return "particles/econ/events/fall_2022/attack2/attack2_modifier_fall2022_base.vpcf"
end

function modifier_projectile_effect_6:GetPriority()
    return 10
end