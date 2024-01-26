if wisp_grave_buff == nil then
	wisp_grave_buff = class({})
end
function wisp_grave_buff:Spawn()
	if not IsServer() then return end
	self:SetLevel(1)
end
function wisp_grave_buff:OnOwnerSpawned()
	if self.toggle_state then
		self:ToggleAbility()
	end
end
function wisp_grave_buff:OnOwnerDied()
	self.toggle_state = self:GetToggleState()
end
function wisp_grave_buff:OnToggle()
	if not IsServer() then return end
end
---------------------------------------------------------------------
--Modifiers
if modifier_wisp_grave_buff == nil then
	modifier_wisp_grave_buff = class({})
end
function modifier_wisp_grave_buff:IsHidden()
	return true
end
function modifier_wisp_grave_buff:IsPurgable()
	return false
end
function modifier_wisp_grave_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MIN_HEALTH,
	}
	return funcs
end
function modifier_wisp_grave_buff:GetMinHealth()
	return 1
end