modifier_ursa_overpower_lua = class({})

--------------------------------------------------------------------------------

function modifier_ursa_overpower_lua:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function modifier_ursa_overpower_lua:OnCreated( kv )
	-- get reference
	self.bonus = self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
	self.max_attacks = self:GetAbility():GetSpecialValueFor("max_attacks")
	-- Increase stack

	if IsServer() then
		self:SetStackCount(self.max_attacks)

		self:AddEffects()
	end
end

function modifier_ursa_overpower_lua:OnRefresh( kv )
	-- get reference
	self.bonus = self:GetAbility():GetSpecialValueFor("attack_speed_bonus")
	self.max_attacks = self:GetAbility():GetSpecialValueFor("max_attacks")

	-- Increase stack
	if IsServer() then
		self:SetStackCount(self.max_attacks)
	end
end

function modifier_ursa_overpower_lua:OnDestroy( kv )
	if IsServer() then
		self:RemoveEffects()
		if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_int10") and self:GetAbility():GetCooldownTimeRemaining() > 2 then
			self:GetAbility():EndCooldown()
			self:GetAbility():StartCooldown(2.0)
		end
	end
end
--------------------------------------------------------------------------------

function modifier_ursa_overpower_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_ursa_overpower_lua:GetModifierAttackSpeedBonus_Constant()
	return self.bonus
end

function modifier_ursa_overpower_lua:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_int6") then
			local damage = self:GetCaster():GetIntellect() * 0.5
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, params.target, damage, nil)
			ApplyDamage({victim = params.target, attacker = self:GetCaster(), damage = damage, damage_flags = 0, damage_type = DAMAGE_TYPE_MAGICAL, ability = self:GetAbility()})
		end
		-- decrement stack
		if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_agi11") and self:GetRemainingTime() >= self:GetAbility():GetSpecialValueFor("duration_tooltip") -2 then return end

		self:DecrementStackCount()

		-- destroy if reach zero
		if self:GetStackCount() < 1 then
			self:Destroy()
		end
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ursa_overpower_lua:AddEffects()
	-- get resources
	local particle_buff = "particles/units/heroes/hero_ursa/ursa_overpower_buff.vpcf"

	-- Create particle
	self.effect_cast = ParticleManager:CreateParticle( particle_buff, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControlEnt( self.effect_cast, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_head", self:GetParent():GetOrigin(), true)
	ParticleManager:SetParticleControlEnt( self.effect_cast, 3, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetParent():GetOrigin(), true)
	
	-- Apply particle
	self:AddParticle(
		self.effect_cast,
		false,
		false,
		-1,
		false,
		false
	)
end

function modifier_ursa_overpower_lua:RemoveEffects()
	ParticleManager:DestroyParticle( self.effect_cast, false )
	ParticleManager:ReleaseParticleIndex( self.effect_cast )
end