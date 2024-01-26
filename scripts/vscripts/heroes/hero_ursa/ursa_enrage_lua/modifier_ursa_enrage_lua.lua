modifier_ursa_enrage_lua = class({})

--------------------------------------------------------------------------------

function modifier_ursa_enrage_lua:IsHidden()
	return false
end

function modifier_ursa_enrage_lua:IsDebuff()
	return false
end

function modifier_ursa_enrage_lua:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_ursa_enrage_lua:OnCreated( kv )
	-- get reference
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
	self.status_resistance = self:GetAbility():GetSpecialValueFor("status_resistance")
	self.stack_multiplier = 1
	if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_str13") then
		self.stack_multiplier = 2
	end

	-- change fury swipes modifier
	if IsServer() then
		local modifier = self:GetParent():FindModifierByNameAndCaster("modifier_ursa_fury_swipes_lua", self:GetAbility():GetCaster())
		if modifier~=nil then
			modifier.damage_per_stack = modifier:GetAbility():GetSpecialValueFor("damage_per_stack") * self.stack_multiplier
		end
        self:GetParent():SetRenderColor(255,0,0)
	end
end

function modifier_ursa_enrage_lua:OnRefresh( kv )
	-- get reference
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
    self.status_resistance = self:GetAbility():GetSpecialValueFor("status_resistance")
	self.stack_multiplier = 1
	if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_str13") then
		self.stack_multiplier = 2
	end

	-- change fury swipes modifier
	if IsServer() then
		local modifier = self:GetParent():FindModifierByNameAndCaster("modifier_ursa_fury_swipes_lua", self:GetAbility():GetCaster())
		if modifier~=nil then
			modifier.damage_per_stack = modifier:GetAbility():GetSpecialValueFor("damage_per_stack") * self.stack_multiplier
		end
	end
end

function modifier_ursa_enrage_lua:OnDestroy( kv )
	-- get reference
	self.damage_reduction = self:GetAbility():GetSpecialValueFor("damage_reduction")
    self.status_resistance = self:GetAbility():GetSpecialValueFor("status_resistance")
	self.stack_multiplier = self:GetAbility():GetSpecialValueFor("enrage_multiplier")

	-- change fury swipes modifier
	if IsServer() then
		local modifier = self:GetParent():FindModifierByNameAndCaster("modifier_ursa_fury_swipes_lua", self:GetAbility():GetCaster())
		if modifier~=nil then
			modifier.damage_per_stack = modifier:GetAbility():GetSpecialValueFor("damage_per_stack")
		end
        self:GetParent():SetRenderColor(255,255,255)
	end
end
--------------------------------------------------------------------------------

function modifier_ursa_enrage_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_PROPERTY_STATUS_RESISTANCE,

		MODIFIER_PROPERTY_MODEL_SCALE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_ursa_enrage_lua:GetModifierIncomingDamage_Percentage( params )
	return -self.damage_reduction
end

function modifier_ursa_enrage_lua:GetModifierStatusResistance( params )
	return self.status_resistance
end

function modifier_ursa_enrage_lua:GetModifierModelScale( params )
	return 30
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ursa_enrage_lua:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_enrage_buff.vpcf"
end

function modifier_ursa_enrage_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_ursa_enrage_lua:OnAttackLanded( params )
	if not IsServer() then return end
	if self:GetParent() ~= params.attacker then return end
	if not self:GetParent():FindAbilityByName("npc_dota_hero_ursa_agi9") then return end
	if params.target ~= nil and params.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		DoCleaveAttack( self:GetParent(), params.target, self:GetAbility(), params.damage, 440, 150, 360, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf" )
	end
end