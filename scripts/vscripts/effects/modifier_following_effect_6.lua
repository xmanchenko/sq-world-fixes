modifier_following_effect_6 = class({})

function modifier_following_effect_6:IsHidden()
	return true
end

function modifier_following_effect_6:IsPurgable()
	return false
end

function modifier_following_effect_6:IsPermanent()
	return true
end

function modifier_following_effect_6:OnCreated( kv )
	if not IsServer() then
		return
	end
	self.caster = self:GetCaster()
	self.particleLeader = ParticleManager:CreateParticle( "particles/fountain_regen_fall_2021_lvl2.vpcf", PATTACH_POINT_FOLLOW, self.caster )
	self:AddParticle(self.particleLeader, false, false, -1, false, false )
end