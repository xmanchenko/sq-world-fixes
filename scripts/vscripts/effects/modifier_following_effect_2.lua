modifier_following_effect_2 = class({})

function modifier_following_effect_2:IsHidden()
	return true
end

function modifier_following_effect_2:IsPurgable()
	return false
end

function modifier_following_effect_2:IsPermanent()
	return true
end

function modifier_following_effect_2:OnCreated( kv )
	if not IsServer() then
		return
	end
	self.caster = self:GetCaster()
	self.particleLeader = ParticleManager:CreateParticle( "particles/econ/courier/courier_babyroshan_ti9/courier_babyroshan_ti9_ambient_bees.vpcf", PATTACH_POINT_FOLLOW, self.caster )
	self:AddParticle(self.particleLeader, false, false, -1, false, false )
end