LinkLuaModifier( "modifier_wisp_switch", "heroes/hero_wisp/lufigan/wisp_switch.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_wisp_strength_buff", "heroes/hero_wisp/lufigan/wisp_attribute_buff.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_wisp_intellect_buff", "heroes/hero_wisp/lufigan/wisp_attribute_buff.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_wisp_agility_buff", "heroes/hero_wisp/lufigan/wisp_attribute_buff.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_wisp_grave_buff", "heroes/hero_wisp/lufigan/wisp_grave_buff.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_wisp_magic_immune_buff", "heroes/hero_wisp/lufigan/wisp_magic_immune_buff.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_wisp_splitshot_buff", "heroes/hero_wisp/lufigan/wisp_splitshot_buff.lua", LUA_MODIFIER_MOTION_NONE )

if wisp_switch == nil then
	wisp_switch = class({})
end
function wisp_switch:Spawn()
	if not IsServer() then return end
	self:SetLevel(1)
end
function wisp_switch:OnOwnerSpawned()
	if self.toggle_state then
		self:ToggleAbility()
	end
end
function wisp_switch:OnOwnerDied()
	self.toggle_state = self:GetToggleState()
end
function wisp_switch:OnToggle()
	if not IsServer() then return end
	local caster = self:GetCaster()
	
	self.relocate = caster:FindAbilityByName("wisp_relocate_lua")
	self.spirits = caster:FindAbilityByName("wisp_spirits_bh")
	self.wisp_attribute_buff = caster:FindAbilityByName("wisp_attribute_buff")
	self.wisp_grave_buff = caster:FindAbilityByName("wisp_grave_buff")
	self.wisp_magic_immune_buff = caster:FindAbilityByName("wisp_magic_immune_buff")
	self.wisp_splitshot_buff = caster:FindAbilityByName("wisp_splitshot_buff")

	if self:GetToggleState() then
		self.relocate:SetHidden(true)
		self.spirits:SetHidden(true)
		self.wisp_attribute_buff:SetHidden(false)
		self.wisp_grave_buff:SetHidden(false)
		self.wisp_magic_immune_buff:SetHidden(false)
		self.wisp_splitshot_buff:SetHidden(false)
		self:SetHidden(false)
	else
		self.relocate:SetHidden(false)
		self.spirits:SetHidden(false)
		self.wisp_attribute_buff:SetHidden(true)
		self.wisp_grave_buff:SetHidden(true)
		self.wisp_magic_immune_buff:SetHidden(true)
		self.wisp_splitshot_buff:SetHidden(true)
		self:SetHidden(true)
	end
end
function wisp_switch:GetIntrinsicModifierName()
	return "modifier_wisp_switch"
end
---------------------------------------------------------------------
--Modifiers
if modifier_wisp_switch == nil then
	modifier_wisp_switch = class({})
end
function modifier_wisp_switch:IsHidden()
	return true
end
function modifier_wisp_switch:IsPurgable()
	return false
end
function modifier_wisp_switch:RemoveOnDeath()
	return false
end
function modifier_wisp_switch:OnCreated(params)
	if IsServer() then
		local caster = self:GetCaster()

		self.tether = caster:FindAbilityByName("wisp_tether_lua")
		self:StartIntervalThink(0.2)
	end
end
function modifier_wisp_switch:OnRefresh( kv )
	if not IsServer() then return end
	local caster = self:GetCaster()

	self.wisp_attribute_buff = caster:FindAbilityByName("wisp_attribute_buff")
	self.wisp_grave_buff = caster:FindAbilityByName("wisp_grave_buff")
	self.wisp_magic_immune_buff = caster:FindAbilityByName("wisp_magic_immune_buff")
	self.wisp_splitshot_buff = caster:FindAbilityByName("wisp_splitshot_buff")
end
function modifier_wisp_switch:OnIntervalThink()
	if self:GetAbility():GetToggleState() == false then return end
	if not self.tether.target then return end
	if self.wisp_attribute_buff == nil or self.wisp_grave_buff == nil or self.wisp_magic_immune_buff == nil or self.wisp_splitshot_buff == nil then self:ForceRefresh() return end

	local caster = self:GetCaster()
	local target = self.tether.target
	local ability = self:GetAbility()
	local duration = 0.25

	if self.wisp_magic_immune_buff:GetToggleState() then
		target:AddNewModifier(caster, ability, "modifier_wisp_magic_immune_buff", {duration = duration})
	end
	if self.wisp_grave_buff:GetToggleState() then
		target:AddNewModifier(caster, ability, "modifier_wisp_grave_buff", {duration = duration})
	end
	if self.wisp_attribute_buff:GetToggleState() then
		target:AddNewModifier(caster, ability, "modifier_wisp_strength_buff", {duration = duration}):SetStackCount(caster:GetStrength())
		target:AddNewModifier(caster, ability, "modifier_wisp_intellect_buff", {duration = duration}):SetStackCount(caster:GetIntellect())
		target:AddNewModifier(caster, ability, "modifier_wisp_agility_buff", {duration = duration}):SetStackCount(caster:GetAgility())
	end
	if self.wisp_splitshot_buff:GetToggleState() then
		target:AddNewModifier(caster, ability, "modifier_wisp_splitshot_buff", {duration = duration})
	end
end