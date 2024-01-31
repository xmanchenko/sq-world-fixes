modifier_projectile_effect_7 = class({})
--Classifications template
function modifier_projectile_effect_7:IsHidden()
    return true
end

function modifier_projectile_effect_7:IsDebuff()
    return false
end

function modifier_projectile_effect_7:IsPurgable()
    return false
end

function modifier_projectile_effect_7:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_projectile_effect_7:IsStunDebuff()
    return false
end

function modifier_projectile_effect_7:RemoveOnDeath()
    return false
end

function modifier_projectile_effect_7:DestroyOnExpire()
    return false
end

function modifier_projectile_effect_7:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROJECTILE_NAME
    }
end

function modifier_projectile_effect_7:GetModifierProjectileName()
    return "particles/base_attacks/ranged_tower_bad.vpcf"
end

function modifier_projectile_effect_7:GetPriority()
    return 10
end