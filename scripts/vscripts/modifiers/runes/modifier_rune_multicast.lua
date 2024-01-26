modifier_rune_multicast = class({})
--Classifications template
function modifier_rune_multicast:GetTexture()
    return "rune_regen"
end

function modifier_rune_multicast:IsHidden()
    return false
end

function modifier_rune_multicast:IsDebuff()
    return false
end

function modifier_rune_multicast:IsPurgable()
    return false
end

function modifier_rune_multicast:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_rune_multicast:IsStunDebuff()
    return false
end

function modifier_rune_multicast:RemoveOnDeath()
    return true
end

function modifier_rune_multicast:DestroyOnExpire()
    return true
end

function modifier_rune_multicast:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
	}
end

function modifier_rune_multicast:OnAbilityFullyCast( data )
    if data.unit ~= self:GetParent() then
        return 0
    end
    if RollPercentage(5) then
        if data.ability:GetAbilityChargeRestoreTime(data.ability:GetLevel()) > 0 then
            data.ability:SetCurrentAbilityCharges(ability:GetCurrentAbilityCharges() + 1)
        else
            data.ability:EndCooldown()
        end
        local pcf = ParticleManager:CreateParticle( "particles/units/heroes/hero_ogre_magi/ogre_magi_multicast.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent() )
        ParticleManager:SetParticleControl(pcf, 1, Vector(1,0,0))
        ParticleManager:ReleaseParticleIndex(pcf)
        EmitSoundOn("Bogduggs.LuckyFemur", self:GetParent())
    end
end