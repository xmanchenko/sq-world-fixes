modifier_ursa_fury_swipes_debuff_lua = class({})

--------------------------------------------------------------------------------

function modifier_ursa_fury_swipes_debuff_lua:IsHidden()
	return false
end

function modifier_ursa_fury_swipes_debuff_lua:IsDebuff()
	return true
end

function modifier_ursa_fury_swipes_debuff_lua:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_ursa_fury_swipes_debuff_lua:OnCreated( kv )
	if not IsServer() then return end
	if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_int12") then 
		self:StartIntervalThink(1)
	end
end

function modifier_ursa_fury_swipes_debuff_lua:OnRefresh( kv )
end

function modifier_ursa_fury_swipes_debuff_lua:OnStackCountChanged(prev_stacks)
	if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_str9") and self:GetStackCount() > 500 then
		self:SetStackCount(500)
	end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_ursa_fury_swipes_debuff_lua:GetEffectName()
	return "particles/units/heroes/hero_ursa/ursa_fury_swipes_debuff.vpcf"
end

function modifier_ursa_fury_swipes_debuff_lua:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_ursa_fury_swipes_debuff_lua:OnIntervalThink()
	local damage = self:GetAbility():GetSpecialValueFor("damage_per_stack") * self:GetStackCount()
	if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_int13") then
		damage = damage * 2
	end
	ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = DAMAGE_TYPE_PHYSICAL,
        damage_flags = 0,
        ability = self:GetAbility()
    })
end

function modifier_ursa_fury_swipes_debuff_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOOLTIP,
	}

	return funcs
end

function modifier_ursa_fury_swipes_debuff_lua:OnTooltip()
	return self:GetAbility():GetSpecialValueFor("damage_per_stack") * self:GetStackCount()
end