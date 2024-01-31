modifier_projectile_effect_8 = class({})
--Classifications template
function modifier_projectile_effect_8:IsHidden()
    return true
end

function modifier_projectile_effect_8:IsDebuff()
    return false
end

function modifier_projectile_effect_8:IsPurgable()
    return false
end

function modifier_projectile_effect_8:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_projectile_effect_8:IsStunDebuff()
    return false
end

function modifier_projectile_effect_8:RemoveOnDeath()
    return false
end

function modifier_projectile_effect_8:DestroyOnExpire()
    return false
end

function modifier_projectile_effect_8:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROJECTILE_NAME
    }
end

function modifier_projectile_effect_8:GetModifierProjectileName()
    return "particles/base_attacks/ranged_tower_good.vpcf"
end

function modifier_projectile_effect_8:GetPriority()
    return 10
end