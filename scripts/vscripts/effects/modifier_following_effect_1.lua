modifier_following_effect_1 = class({})

function modifier_following_effect_1:IsHidden()
	return true
end

function modifier_following_effect_1:IsPurgable()
	return false
end

function modifier_following_effect_1:IsPermanent()
	return true
end

function modifier_following_effect_1:OnCreated( kv )
	if not IsServer() then
		return
	end
	self.caster = self:GetCaster()
	self.particleLeader = ParticleManager:CreateParticle( "models/heroes/phantom_assassin_persona/debut/particles/pa_env_lanterns/pa_env_lanterns.vpcf", PATTACH_POINT_FOLLOW, self.caster )
	self:AddParticle(self.particleLeader, false, false, -1, false, false )
end
