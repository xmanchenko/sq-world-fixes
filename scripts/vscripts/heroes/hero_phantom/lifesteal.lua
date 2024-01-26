npc_dota_hero_phantom_assassin_str9 = class({})

function npc_dota_hero_phantom_assassin_str9:GetIntrinsicModifierName()
	return "modifier_phantom_assassin_lifesteal"
end

LinkLuaModifier( "modifier_phantom_assassin_lifesteal", "heroes/hero_phantom/lifesteal", LUA_MODIFIER_MOTION_NONE )

modifier_phantom_assassin_lifesteal = class({})

function modifier_phantom_assassin_lifesteal:IsHidden()
	return false
end

function modifier_phantom_assassin_lifesteal:OnCreated( kv )
end

function modifier_phantom_assassin_lifesteal:OnRefresh( kv )
end

function modifier_phantom_assassin_lifesteal:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end


function modifier_phantom_assassin_lifesteal:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		local pass = false
		if params.target:GetTeamNumber()~=self:GetParent():GetTeamNumber() then
			if (not params.target:IsBuilding()) and (not params.target:IsOther()) then
				pass = true
			end
		end

		if pass then
			self.attack_record = params.record
		end
	end
end

function modifier_phantom_assassin_lifesteal:OnTakeDamage( params )
	if IsServer() then

		local pass = false
		if self.attack_record and params.record == self.attack_record then
			pass = true
			self.attack_record = nil
		end

		if pass then
			local heal = params.damage * 20/100
			self:GetParent():Heal( math.min(heal, 2^30), self:GetAbility() )
			self:PlayEffects( self:GetParent() )
		end
	end
end

function modifier_phantom_assassin_lifesteal:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end