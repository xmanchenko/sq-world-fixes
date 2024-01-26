modifier_following_effect_5 = class({})

function modifier_following_effect_5:IsHidden()
	return true
end

function modifier_following_effect_5:IsPurgable()
	return false
end

function modifier_following_effect_5:IsPermanent()
	return true
end

function modifier_following_effect_5:OnCreated( kv )
	if not IsServer() then
		return
	end
	self.caster = self:GetCaster()
	self.particleLeader = ParticleManager:CreateParticle( "particles/econ/courier/courier_greevil_black/courier_greevil_black_ambient_3.vpcf", PATTACH_POINT_FOLLOW, self.caster )
	ParticleManager:SetParticleControlEnt( self.particleLeader, 0, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( self.particleLeader, 1, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( self.particleLeader, 3, self.caster, PATTACH_POINT_FOLLOW, "attach_hitloc", self.caster:GetAbsOrigin(), true )
	self:AddParticle(self.particleLeader, false, false, -1, false, false )
end

