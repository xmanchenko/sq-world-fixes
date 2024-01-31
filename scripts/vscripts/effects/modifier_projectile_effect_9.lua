modifier_projectile_effect_9 = class({})
--Classifications template
function modifier_projectile_effect_9:IsHidden()
    return true
end

function modifier_projectile_effect_9:IsDebuff()
    return false
end

function modifier_projectile_effect_9:IsPurgable()
    return false
end

function modifier_projectile_effect_9:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_projectile_effect_9:IsStunDebuff()
    return false
end

function modifier_projectile_effect_9:RemoveOnDeath()
    return false
end

function modifier_projectile_effect_9:DestroyOnExpire()
    return false
end

function modifier_projectile_effect_9:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROJECTILE_NAME
    }
end

function modifier_projectile_effect_9:GetModifierProjectileName()
    return "particles/neutral_fx/black_dragon_attack.vpcf"
end

function modifier_projectile_effect_9:GetPriority()
    return 10
end