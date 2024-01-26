if wisp_attribute_buff == nil then
	wisp_attribute_buff = class({})
end
function wisp_attribute_buff:Spawn()
	if not IsServer() then return end
	self:SetLevel(1)
end
function wisp_attribute_buff:OnOwnerSpawned()
	if self.toggle_state then
		self:ToggleAbility()
	end
end
function wisp_attribute_buff:OnOwnerDied()
	self.toggle_state = self:GetToggleState()
end
function wisp_attribute_buff:OnToggle()
	if not IsServer() then return end
end
---------------------------------------------------------------------
--Modifiers
modifier_wisp_strength_buff = class({
    IsHidden                 = function(self) return true end,
    IsPurgable                 = function(self) return false end,
    IsDebuff                 = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath             = function(self) return true end,
    DeclareFunctions             = function(self) return {MODIFIER_PROPERTY_STATS_STRENGTH_BONUS} end,
	GetModifierBonusStats_Strength = function(self) return self:GetStackCount() end
})
modifier_wisp_intellect_buff = class({
    IsHidden                 = function(self) return true end,
    IsPurgable                 = function(self) return false end,
    IsDebuff                 = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath             = function(self) return true end,
    DeclareFunctions             = function(self) return {MODIFIER_PROPERTY_STATS_INTELLECT_BONUS} end,
	GetModifierBonusStats_Intellect = function(self) return self:GetStackCount() end
})
modifier_wisp_agility_buff = class({
    IsHidden                 = function(self) return true end,
    IsPurgable                 = function(self) return false end,
    IsDebuff                 = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath             = function(self) return true end,
    DeclareFunctions             = function(self) return {MODIFIER_PROPERTY_STATS_AGILITY_BONUS} end,
	GetModifierBonusStats_Agility = function(self) return self:GetStackCount() end
})