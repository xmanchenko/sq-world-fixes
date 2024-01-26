modifier_following_effect_7 = class({})

function modifier_following_effect_7:IsHidden()
	return true
end

function modifier_following_effect_7:IsPurgable()
	return false
end

function modifier_following_effect_7:IsPermanent()
	return true
end

function modifier_following_effect_7:OnCreated( kv )
	if not IsServer() then
		return
	end
	self.caster = self:GetCaster()
	self.particleLeader = ParticleManager:CreateParticle( "particles/econ/courier/courier_faceless_rex/cour_rex_ground_a.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.caster )
	self:AddParticle(self.particleLeader, false, false, -1, false, false )
end
