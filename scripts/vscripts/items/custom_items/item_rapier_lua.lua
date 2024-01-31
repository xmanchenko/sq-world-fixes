item_rapier_lua = class({})

function item_rapier_lua:GetAbilityTextureName()
	local level = self:GetLevel()
	if self:GetSecondaryCharges() == 0 then
		return "all/item_rapier_lua" .. level
	else
		return "gem" .. self:GetSecondaryCharges() .. "/item_rapier_lua" .. level
	end
end

function item_rapier_lua:OnUpgrade()
	Timers:CreateTimer(0.03,function()
		if (self:GetItemSlot() > 5 or self:GetItemSlot() == -1) then
			local m = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
			if m then
				m:Destroy()
			end
		end
	end)
end

function item_rapier_lua:GetIntrinsicModifierName()
    return "modifier_item_rapier_lua"
end

LinkLuaModifier("modifier_item_rapier_lua", "items/custom_items/item_rapier_lua.lua", LUA_MODIFIER_MOTION_NONE)

modifier_item_rapier_lua = class({})
--Classifications template
function modifier_item_rapier_lua:IsHidden()
    return true
end

function modifier_item_rapier_lua:IsDebuff()
    return false
end

function modifier_item_rapier_lua:IsPurgable()
    return false
end

function modifier_item_rapier_lua:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_item_rapier_lua:IsStunDebuff()
    return false
end

function modifier_item_rapier_lua:RemoveOnDeath()
    return false
end

function modifier_item_rapier_lua:DestroyOnExpire()
    return false
end

function modifier_item_rapier_lua:OnCreated()
    self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_rapier_lua:OnRefresh()
    self.damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
end

function modifier_item_rapier_lua:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
end

function modifier_item_rapier_lua:GetModifierPreAttack_BonusDamage()
    return self.damage
end