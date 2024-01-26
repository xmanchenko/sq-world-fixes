modifier_following_effect_4 = class({})

function modifier_following_effect_4:IsHidden()
	return true
end

function modifier_following_effect_4:IsPurgable()
	return false
end

function modifier_following_effect_4:IsPermanent()
	return true
end

function modifier_following_effect_4:OnCreated( kv )
	if not IsServer() then
		return
	end
	self.caster = self:GetCaster()
	self.particleLeader = ParticleManager:CreateParticle( "particles/econ/courier/courier_axolotl_ambient/courier_axolotl_ambient_lvl4_trail_steam.vpcf", PATTACH_POINT_FOLLOW, self.caster )
	self:AddParticle(self.particleLeader, false, false, -1, false, false )
end