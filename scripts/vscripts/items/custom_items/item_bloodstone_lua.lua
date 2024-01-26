item_bloodstone_lua = class({})

LinkLuaModifier("modifier_item_bloodstone_lua", 'items/custom_items/item_bloodstone_lua.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_blodstone_active_lua", 'items/custom_items/item_bloodstone_lua.lua', LUA_MODIFIER_MOTION_NONE)

function item_bloodstone_lua:GetAbilityTextureName()
	local level = self:GetLevel()
	if self:GetSecondaryCharges() == 0 then
		return "all/bloodstone_" .. level
	else
		return "gem" .. self:GetSecondaryCharges() .. "/item_bloodstone_lua" .. level
	end
end

function item_bloodstone_lua:OnUpgrade()
	Timers:CreateTimer(0.03,function()
		if (self:GetItemSlot() > 5 or self:GetItemSlot() == -1) then
			local m = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
			if m then
				m:Destroy()
			end
		end
	end)
end

function item_bloodstone_lua:GetIntrinsicModifierName()
	return "modifier_item_bloodstone_lua"
end

function item_bloodstone_lua:GetManaCost()
	if self and not self:IsNull() and self.GetCaster and self:GetCaster() ~= nil then
		return self:GetCaster():GetMaxMana() * 0.3
	end
end

function item_bloodstone_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_blodstone_active_lua", {duration = 2})
end

----------------------------------------------------------------------------------

modifier_item_bloodstone_lua = class({})

function modifier_item_bloodstone_lua:IsHidden()
	return true
end

function modifier_item_bloodstone_lua:IsPurgable()
	return false
end

function modifier_item_bloodstone_lua:RemoveOnDeath()	
	return false 
end

function modifier_item_bloodstone_lua:OnCreated()
	self.parent = self:GetParent()
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.bonus_mana = self:GetAbility():GetSpecialValueFor("bonus_mana")
	self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health")
	self.mana_regen_multiplier = self:GetAbility():GetSpecialValueFor("mana_regen_multiplier")
	self.spell_amp = self:GetAbility():GetSpecialValueFor("spell_amp")
	self.creep_lifesteal= self:GetAbility():GetSpecialValueFor("creep_lifesteal")
end

function modifier_item_bloodstone_lua:OnRefresh()
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.bonus_mana = self:GetAbility():GetSpecialValueFor("bonus_mana")
	self.bonus_health = self:GetAbility():GetSpecialValueFor("bonus_health")
	self.mana_regen_multiplier = self:GetAbility():GetSpecialValueFor("mana_regen_multiplier")
	self.spell_amp = self:GetAbility():GetSpecialValueFor("spell_amp")
	self.creep_lifesteal= self:GetAbility():GetSpecialValueFor("creep_lifesteal")
end

function modifier_item_bloodstone_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_HEALTH_BONUS,
		MODIFIER_PROPERTY_MANA_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_MP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,

		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
end

function modifier_item_bloodstone_lua:GetModifierHealthBonus()
	return self.bonus_health
end

function modifier_item_bloodstone_lua:GetModifierManaBonus()
	return self.bonus_mana
end

function modifier_item_bloodstone_lua:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end

function modifier_item_bloodstone_lua:GetModifierSpellAmplify_Percentage()
	return self.spell_amp
end

function modifier_item_bloodstone_lua:GetModifierMPRegenAmplify_Percentage()
	return self.mana_regen_multiplier
end

function modifier_item_bloodstone_lua:OnTakeDamage(keys)
	if keys.attacker == self:GetParent() and not keys.unit:IsBuilding() and not keys.unit:IsOther() then		
		if self:GetParent():FindAllModifiersByName(self:GetName())[1] == self and keys.damage_category == 0 and keys.inflictor and bit.band(keys.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) ~= DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
		
			-- Particle effect
			self.lifesteal_pfx = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, keys.attacker)
			ParticleManager:SetParticleControl(self.lifesteal_pfx, 0, keys.attacker:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(self.lifesteal_pfx)
			heal = keys.damage * (self.creep_lifesteal / 100)
			keys.attacker:HealWithParams(math.min(heal, 2^30), self:GetAbility(), true, true, self:GetParent(), true)
			if self:GetParent():HasModifier("modifier_wisp_tether_lua") then
				local modifier = self:GetParent():FindModifierByName("modifier_wisp_tether_lua")
				modifier.heal = math.min(modifier.heal + heal, 2^30)
			end
		end
	end
end

-----------------------------------------------------------------------

modifier_item_blodstone_active_lua = class({})

function modifier_item_blodstone_active_lua:OnCreated()
	EmitSoundOn("DOTA_Item.Bloodstone.Cast",self:GetCaster())
	self.particle = ParticleManager:CreateParticle("particles/items_fx/bloodstone_heal.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControlEnt(self.particle, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_hitloc", self:GetCaster():GetAbsOrigin(), true)
	self:AddParticle(self.particle, false, false, -1, false, false)

	
	self.caster = self:GetCaster()
	self.regen = self:GetCaster():GetMaxMana() * 0.15 

end

function modifier_item_blodstone_active_lua:DeclareFunctions()
	return{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}
end

function modifier_item_blodstone_active_lua:GetModifierConstantHealthRegen()
	return self.regen
end