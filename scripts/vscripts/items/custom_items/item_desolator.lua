if item_blight_stone_lua == nil then item_blight_stone_lua = class({}) end
LinkLuaModifier( "modifier_item_blight_stone_lua", "items/custom_items/item_desolator.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_curruption_armor_debuff", "items/custom_items/item_desolator.lua", LUA_MODIFIER_MOTION_NONE )

function item_blight_stone_lua:OnUpgrade()
	Timers:CreateTimer(0.03,function()
		if (self:GetItemSlot() > 5 or self:GetItemSlot() == -1) then
			local m = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
			if m then
				m:Destroy()
			end
		end
	end)
end

function item_blight_stone_lua:GetIntrinsicModifierName()
	return "modifier_item_blight_stone_lua"
end

if modifier_item_blight_stone_lua == nil then modifier_item_blight_stone_lua = class({}) end

function modifier_item_blight_stone_lua:IsHidden()		
	return true 
end

function modifier_item_blight_stone_lua:IsPurgable()		
	return false 
end

function modifier_item_blight_stone_lua:RemoveOnDeath()	
	return false 
end

function modifier_item_blight_stone_lua:GetAttributes()	
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_item_blight_stone_lua:OnCreated()	
	self.armor_reduction = self:GetAbility():GetSpecialValueFor("armor_reduction")
end

function modifier_item_blight_stone_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
	}
end

function modifier_item_blight_stone_lua:GetModifierProcAttack_Feedback( data )
	data.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_curruption_armor_debuff", {duration = 5, armor_reduction = self.armor_reduction})
end
----------------------------------------------------------------------
--Оптимизированный код дезоляторов
----------------------------------------------------------------------
item_desolator_lua = class({})

LinkLuaModifier( "modifier_item_desolator_lua", "items/custom_items/item_desolator.lua", LUA_MODIFIER_MOTION_NONE )

function item_desolator_lua:GetAbilityTextureName()
	local level = self:GetLevel()
	if self:GetSecondaryCharges() == 0 then
		return "all/desolator_" .. level
	else
		return "gem" .. self:GetSecondaryCharges() .. "/item_desolator_lua" .. level
	end
end

function item_desolator_lua:OnUpgrade()
	Timers:CreateTimer(0.03,function()
		if (self:GetItemSlot() > 5 or self:GetItemSlot() == -1) then
			local m = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
			if m then
				m:Destroy()
			end
		end
	end)
end

function item_desolator_lua:GetIntrinsicModifierName()
	return "modifier_item_desolator_lua" 
end

modifier_item_desolator_lua = class({})

function modifier_item_desolator_lua:IsHidden()		
	return true 
end

function modifier_item_desolator_lua:IsPurgable()		
	return false 
end

function modifier_item_desolator_lua:RemoveOnDeath()	
	return false 
end

-- function modifier_item_desolator_lua:GetAttributes()	
-- 	return MODIFIER_ATTRIBUTE_MULTIPLE
-- end

function modifier_item_desolator_lua:OnCreated()
	self.parent = self:GetParent()
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_desolator_lua:OnRefresh()
	self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_desolator_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
		-- MODIFIER_PROPERTY_PROJECTILE_NAME,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK
	}
end

-- function modifier_item_desolator_lua:GetModifierProjectileName()
-- 	return "particles/items_fx/desolator_projectile.vpcf"
-- end

function modifier_item_desolator_lua:GetModifierPreAttack_BonusDamage()
	return self.bonus_damage 
end

function modifier_item_desolator_lua:GetModifierProcAttack_Feedback(data)
	data.target:AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_curruption_armor_debuff", {duration = 5})
end

modifier_curruption_armor_debuff = class({})

function modifier_curruption_armor_debuff:IsHidden() 
	return false 
end

function modifier_curruption_armor_debuff:IsDebuff() 
	return true 
end

function modifier_curruption_armor_debuff:IsPurgable() 
	return true 
end

function modifier_curruption_armor_debuff:OnCreated(data)
	self.interval = false
	self.armor_reduction = 0
	self.armor_reduction = self:GetAbility():GetSpecialValueFor("corruption_armor")
end

function modifier_curruption_armor_debuff:OnRefresh(data)
	local new_value = self:GetAbility():GetSpecialValueFor("corruption_armor")
	if self.armor_reduction < new_value then
		self.armor_reduction = new_value
		self.caster = self:GetCaster()
	end
	if self.interval and self.armor_reduction == new_value then
		self:StartIntervalThink(5)
	end
	if self.armor_reduction > new_value and self.caster ~= self:GetCaster() and not self.interval then
		self.interval = true
		self:StartIntervalThink(5)
	end
end

function modifier_curruption_armor_debuff:OnIntervalThink()
	self:Destroy()
end

function modifier_curruption_armor_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_curruption_armor_debuff:GetModifierPhysicalArmorBonus()
	return self.armor_reduction * -1
end