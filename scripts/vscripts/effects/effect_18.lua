modifier_effect_18 = class({})

function modifier_effect_18:IsHidden()
	return true
end

function modifier_effect_18:IsPurgable()
	return false
end

function modifier_effect_18:IsPermanent()
	return true
end

function modifier_effect_18:OnCreated( kv )
	self.caster = self:GetCaster()
	self.particleLeader = ParticleManager:CreateParticle( "particles/econ/items/queen_of_pain/qop_arcana/qop_arcana_wings_ambient.vpcf", PATTACH_POINT_FOLLOW, self.caster )
	ParticleManager:SetParticleControlEnt( self.particleLeader, PATTACH_OVERHEAD_FOLLOW, self.caster, PATTACH_OVERHEAD_FOLLOW, "PATTACH_OVERHEAD_FOLLOW", self.caster:GetAbsOrigin(), true )
end

function modifier_effect_18:OnDestroy( kv )
	ParticleManager:DestroyParticle(self.particleLeader, true)
    ParticleManager:ReleaseParticleIndex(self.particleLeader)
end
