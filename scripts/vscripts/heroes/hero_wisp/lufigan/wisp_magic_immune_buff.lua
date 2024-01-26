if wisp_magic_immune_buff == nil then
	wisp_magic_immune_buff = class({})
end
function wisp_magic_immune_buff:Spawn()
	if not IsServer() then return end
	self:SetLevel(1)
end
function wisp_magic_immune_buff:OnOwnerSpawned()
	if self.toggle_state then
		self:ToggleAbility()
	end
end
function wisp_magic_immune_buff:OnOwnerDied()
	self.toggle_state = self:GetToggleState()
end
function wisp_magic_immune_buff:OnToggle()
	if not IsServer() then return end
end
---------------------------------------------------------------------
--Modifiers
if modifier_wisp_magic_immune_buff == nil then
	modifier_wisp_magic_immune_buff = class({})
end
function modifier_wisp_magic_immune_buff:IsHidden()
	return true
end
function modifier_wisp_magic_immune_buff:IsPurgable()
	return false
end
function modifier_wisp_magic_immune_buff:CheckState()
    local state = {
        [MODIFIER_STATE_MAGIC_IMMUNE] = true,
    }
    return state
end