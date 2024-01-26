item_vladmir_lua = class({})

LinkLuaModifier("modifier_item_vladmir_lua", 'items/custom_items/item_vladmir_lua.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_vladmir_aura_lua", 'items/custom_items/item_vladmir_lua.lua', LUA_MODIFIER_MOTION_NONE)

modifier_item_vladmir_lua = class({})

function item_vladmir_lua:GetAbilityTextureName()
	local level = self:GetLevel()
	if self:GetSecondaryCharges() == 0 then
		return "all/vladmir_" .. level
	else
		return "gem" .. self:GetSecondaryCharges() .. "/item_vladmir_lua" .. level
	end
end

function item_vladmir_lua:OnUpgrade()
	Timers:CreateTimer(0.03,function()
		if (self:GetItemSlot() > 5 or self:GetItemSlot() == -1) then
			local m = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
			if m then
				m:Destroy()
			end
		end
	end)
end

function item_vladmir_lua:GetIntrinsicModifierName()
	return "modifier_item_vladmir_lua"
end

function modifier_item_vladmir_lua:IsHidden() return true end
function modifier_item_vladmir_lua:IsPurgable() return false end
function modifier_item_vladmir_lua:RemoveOnDeath() return false end

function modifier_item_vladmir_lua:OnCreated()
	self.aura_radius = self:GetAbility():GetSpecialValueFor("aura_radius")
end

function modifier_item_vladmir_lua:GetAuraRadius()
	return self.aura_radius
end

function modifier_item_vladmir_lua:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_vladmir_lua:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_vladmir_lua:GetModifierAura()
	return "modifier_item_vladmir_aura_lua"
end

function modifier_item_vladmir_lua:IsAura()
	return true
end

------------------------------------------------------------------------------------------------

modifier_item_vladmir_aura_lua = class({})

function modifier_item_vladmir_aura_lua:IsHidden() 
	return false 
end

function modifier_item_vladmir_aura_lua:IsPurgable() 
	return false 
end

function modifier_item_vladmir_aura_lua:RemoveOnDeath() 
	return false 
end

function modifier_item_vladmir_aura_lua:IsAuraActiveOnDeath() 
	return false 
end

function modifier_item_vladmir_aura_lua:OnCreated()
	self.parent = self:GetParent()
	self.armor_aura = self:GetAbility():GetSpecialValueFor("armor_aura")
	self.mana_regen_aura = self:GetAbility():GetSpecialValueFor("mana_regen_aura")
	self.lifesteal_aura = self:GetAbility():GetSpecialValueFor("lifesteal_aura")
	self.damage_aura = self:GetAbility():GetSpecialValueFor("damage_aura")
end

function modifier_item_vladmir_aura_lua:OnRefresh()
	self.parent = self:GetParent()
	self.armor_aura = self:GetAbility():GetSpecialValueFor("armor_aura")
	self.mana_regen_aura = self:GetAbility():GetSpecialValueFor("mana_regen_aura")
	self.lifesteal_aura = self:GetAbility():GetSpecialValueFor("lifesteal_aura")
	self.damage_aura = self:GetAbility():GetSpecialValueFor("damage_aura")
end

function modifier_item_vladmir_aura_lua:DeclareFunctions()
	return {

		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS_UNIQUE,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
	}
end

function modifier_item_vladmir_aura_lua:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage_aura
end

function modifier_item_vladmir_aura_lua:GetModifierPhysicalArmorBonusUnique()
	return self.armor_aura 
end

function modifier_item_vladmir_aura_lua:GetModifierConstantManaRegen()
	return self.mana_regen_aura
end

function modifier_item_vladmir_aura_lua:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		local pass = false
		if params.target:GetTeamNumber()~=self:GetParent():GetTeamNumber() then
			if (not params.target:IsBuilding()) and (not params.target:IsOther()) then
				local heal = params.damage * self.lifesteal_aura/100
				self:GetParent():HealWithParams(math.min(heal, 2^30), self:GetAbility(), true, true, self:GetParent(), false)
				self:PlayEffects( self:GetParent() )
				if self:GetParent():HasModifier("modifier_wisp_tether_lua") then
					local modifier = self:GetParent():FindModifierByName("modifier_wisp_tether_lua")
					modifier.heal = modifier.heal + heal
				end
			end
		end
	end
end

function modifier_item_vladmir_aura_lua:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

