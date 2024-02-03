item_golden_egg_lua = class({})

LinkLuaModifier("modifier_item_golden_egg_lua", 'items/custom_items/item_golden_egg_lua.lua', LUA_MODIFIER_MOTION_NONE)

function item_golden_egg_lua:GetAbilityTextureName()
	local level = self:GetLevel()
	if self:GetSecondaryCharges() == 0 then
		return "all/item_golden_egg_lua" .. level
	else
		return "gem" .. self:GetSecondaryCharges() .. "/item_golden_egg_lua" .. level
	end
end

function item_golden_egg_lua:OnUpgrade()
	Timers:CreateTimer(0.03,function()
		if (self:GetItemSlot() > 5 or self:GetItemSlot() == -1) then
			local m = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
			if m then
				m:Destroy()
			end
		end
	end)
end

function item_golden_egg_lua:GetIntrinsicModifierName()
    return "modifier_item_golden_egg_lua"
end

modifier_item_golden_egg_lua = class({})
--Classifications template
function modifier_item_golden_egg_lua:IsHidden()
    return true
end

function modifier_item_golden_egg_lua:IsDebuff()
    return false
end

function modifier_item_golden_egg_lua:IsPurgable()
    return false
end

function modifier_item_golden_egg_lua:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_item_golden_egg_lua:IsStunDebuff()
    return false
end

function modifier_item_golden_egg_lua:RemoveOnDeath()
    return false
end

function modifier_item_golden_egg_lua:DestroyOnExpire()
    return false
end

function modifier_item_golden_egg_lua:OnCreated()
    self.armor = self:GetAbility():GetSpecialValueFor("armor")
    self.mana_regen = self:GetAbility():GetSpecialValueFor("mana_regen")
    self.int = self:GetAbility():GetSpecialValueFor("int")
    self.no_primary = self:GetAbility():GetSpecialValueFor("no_primary")
    self.gold_per_second = self:GetAbility():GetSpecialValueFor("gold_per_second")
    -- self.interval = 60 / self:GetAbility():GetSpecialValueFor("gold_per_second")
    if not IsServer() then
        return
    end
    if self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
        self.primary_type = DOTA_ATTRIBUTE_STRENGTH
    elseif self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY  then
        self.primary_type = DOTA_ATTRIBUTE_AGILITY
    elseif self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
        self.primary_type = DOTA_ATTRIBUTE_INTELLECT
    elseif self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then
        self.primary_type = DOTA_ATTRIBUTE_ALL
        self.no_primary = self.no_primary / 2
    end
    self:SetHasCustomTransmitterData( true )
    self:StartIntervalThink(1)
end

function modifier_item_golden_egg_lua:AddCustomTransmitterData()
    return {
        primary_type = self.primary_type,
    }
end

function modifier_item_golden_egg_lua:HandleCustomTransmitterData( data )
    self.primary_type = data.primary_type
end

function modifier_item_golden_egg_lua:OnRefresh()
    self.armor = self:GetAbility():GetSpecialValueFor("armor")
    self.mana_regen = self:GetAbility():GetSpecialValueFor("mana_regen")
    self.int = self:GetAbility():GetSpecialValueFor("int")
    self.no_primary = self:GetAbility():GetSpecialValueFor("no_primary")
    self.gold_per_second = self:GetAbility():GetSpecialValueFor("gold_per_second")
    -- self.interval = 60 / self:GetAbility():GetSpecialValueFor("gold_per_second")
    if not IsServer() then
        return
    end
    if self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_STRENGTH then
        self.primary_type = DOTA_ATTRIBUTE_STRENGTH
    elseif self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_AGILITY  then
        self.primary_type = DOTA_ATTRIBUTE_AGILITY
    elseif self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_INTELLECT then
        self.primary_type = DOTA_ATTRIBUTE_INTELLECT
    elseif self:GetParent():GetPrimaryAttribute() == DOTA_ATTRIBUTE_ALL then
        self.primary_type = DOTA_ATTRIBUTE_ALL
        self.no_primary = self.no_primary / 2
    end
    self:SendBuffRefreshToClients()
    self:StartIntervalThink(1)
end

function modifier_item_golden_egg_lua:OnIntervalThink()
    self:GetCaster():ModifyGoldFiltered(self.gold_per_second, true, DOTA_ModifyGold_SharedGold)
end

function modifier_item_golden_egg_lua:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
end

function modifier_item_golden_egg_lua:GetModifierPhysicalArmorBonus()
    return self.armor
end

function modifier_item_golden_egg_lua:GetModifierConstantManaRegen()
    return self.mana_regen
end

function modifier_item_golden_egg_lua:GetModifierBonusStats_Intellect()
    return self.primary_type ~= DOTA_ATTRIBUTE_ALL and self.primary_type ~= DOTA_ATTRIBUTE_INTELLECT and self.no_primary + self.int or self.int
end

function modifier_item_golden_egg_lua:GetModifierBonusStats_Strength()
    return self.primary_type ~= DOTA_ATTRIBUTE_ALL and self.primary_type ~= DOTA_ATTRIBUTE_STRENGTH and self.no_primary or 0
end

function modifier_item_golden_egg_lua:GetModifierBonusStats_Agility()
    return self.primary_type ~= DOTA_ATTRIBUTE_ALL and self.primary_type ~= DOTA_ATTRIBUTE_AGILITY and self.no_primary or 0
end