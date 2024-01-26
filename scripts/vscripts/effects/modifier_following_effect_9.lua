modifier_following_effect_9 = class({})

function modifier_following_effect_9:IsHidden()
	return true
end

function modifier_following_effect_9:IsPurgable()
	return false
end

function modifier_following_effect_9:IsPermanent()
	return true
end

function modifier_following_effect_9:OnCreated( kv )
	self.caster = self:GetCaster()
	self.particleLeader = ParticleManager:CreateParticle( "particles/econ/courier/courier_polycount_01/courier_trail_polycount_01.vpcf", PATTACH_POINT_FOLLOW, self.caster )
	ParticleManager:SetParticleControlEnt( self.particleLeader, PATTACH_OVERHEAD_FOLLOW, self.caster, PATTACH_OVERHEAD_FOLLOW, "PATTACH_OVERHEAD_FOLLOW", self.caster:GetAbsOrigin(), true )
end

function modifier_following_effect_9:OnDestroy( kv )
	ParticleManager:DestroyParticle(self.particleLeader, true)
    ParticleManager:ReleaseParticleIndex(self.particleLeader)
end
