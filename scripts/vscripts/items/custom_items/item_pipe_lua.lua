item_pipe_lua = class({})

LinkLuaModifier("modifier_item_pipe_lua", 'items/custom_items/item_pipe_lua.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_pipe_aura_lua", 'items/custom_items/item_pipe_lua.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_pipe_active_lua", 'items/custom_items/item_pipe_lua.lua', LUA_MODIFIER_MOTION_NONE)

function item_pipe_lua:GetAbilityTextureName()
	local level = self:GetLevel()
	if self:GetSecondaryCharges() == 0 then
		return "all/pipe_" .. level
	else
		return "gem" .. self:GetSecondaryCharges() .. "/item_pipe_lua" .. level
	end
end

function item_pipe_lua:OnUpgrade()
	Timers:CreateTimer(0.03,function()
		if (self:GetItemSlot() > 5 or self:GetItemSlot() == -1) then
			local m = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
			if m then
				m:Destroy()
			end
		end
	end)
end

function item_pipe_lua:GetIntrinsicModifierName()
	return "modifier_item_pipe_lua"
end

function item_pipe_lua:OnSpellStart()
	EmitSoundOn("DOTA_Item.Pipe.Activate", self:GetCaster())
	local allys = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,units in pairs(allys) do
		units:AddNewModifier(self:GetCaster(), self, "modifier_item_pipe_active_lua", {duration = 12})
	end
end

-------------------------------------------------------------------------------------

modifier_item_pipe_active_lua = class({})

function modifier_item_pipe_active_lua:OnCreated()


	self.particle = ParticleManager:CreateParticle("particles/items2_fx/pipe_of_insight.vpcf", PATTACH_OVERHEAD_FOLLOW, self:GetParent())
	ParticleManager:SetParticleControl(self.particle, 0, self:GetParent():GetAbsOrigin())
	ParticleManager:SetParticleControlEnt(self.particle, 1, self:GetParent(), PATTACH_POINT_FOLLOW, "attach_origin", self:GetParent():GetAbsOrigin(), true)
	ParticleManager:SetParticleControl(self.particle, 2, Vector(self:GetParent():GetModelRadius() * 1.2, 0, 0))
	self:AddParticle(self.particle, false, false, -1, false, false)

	self.barrier_block = self:GetAbility():GetSpecialValueFor("barrier_block")
	self.barrier_max = self:GetAbility():GetSpecialValueFor("barrier_block")
end

function modifier_item_pipe_active_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT
	}
end

function modifier_item_pipe_active_lua:GetModifierIncomingSpellDamageConstant(keys)
	if IsClient() then
		if keys.report_max then
			return self.barrier_max
		else
			return self.barrier_block
		end
	end
	if keys.damage_type == DAMAGE_TYPE_MAGICAL then
		if keys.original_damage >= self.barrier_block then
			self:Destroy()
			return self.barrier_block * (-1)
		else
			self.barrier_block = self.barrier_block - keys.original_damage
			return keys.original_damage * (-1)
		end
	end
end

----------------------------------------------------------------------------------

modifier_item_pipe_lua = class({})

function modifier_item_pipe_lua:IsHidden()
	return true
end

function modifier_item_pipe_lua:IsPurgable()
	return false
end

function modifier_item_pipe_lua:RemoveOnDeath()	
	return false 
end

function modifier_item_pipe_lua:GetIntrinsicModifierName()
	return "modifier_item_pipe_aura_lua"
end

function modifier_item_pipe_lua:OnCreated()
	self.parent = self:GetParent()
	self.health_regen = self:GetAbility():GetSpecialValueFor("health_regen")
	self.magic_resistance = self:GetAbility():GetSpecialValueFor("magic_resistance")
end

function modifier_item_pipe_lua:OnRefresh()
	self.health_regen = self:GetAbility():GetSpecialValueFor("health_regen")
	self.magic_resistance = self:GetAbility():GetSpecialValueFor("magic_resistance")
end

function modifier_item_pipe_lua:DeclareFunctions()
	return{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_item_pipe_lua:GetModifierConstantHealthRegen()
	return self.health_regen
end

function modifier_item_pipe_lua:GetModifierMagicalResistanceBonus()
	return self.magic_resistance
end

function modifier_item_pipe_lua:IsAura()						return true end
function modifier_item_pipe_lua:IsAuraActiveOnDeath() 			return false end

function modifier_item_pipe_lua:GetAuraRadius()				return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_item_pipe_lua:GetAuraSearchFlags()			return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_item_pipe_lua:GetAuraSearchTeam()			return DOTA_UNIT_TARGET_TEAM_FRIENDLY end
function modifier_item_pipe_lua:GetAuraSearchType()			return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_pipe_lua:GetModifierAura()				return "modifier_item_pipe_aura_lua" end

-------------------------------------------------------------------------------------------

modifier_item_pipe_aura_lua = class({})

function modifier_item_pipe_aura_lua:OnCreated()
	self.aura_health_regen = self:GetAbility():GetSpecialValueFor("aura_health_regen")
	self.magic_resistance_aura = self:GetAbility():GetSpecialValueFor("magic_resistance_aura")
end

function modifier_item_pipe_aura_lua:OnRefresh()
	self.aura_health_regen = self:GetAbility():GetSpecialValueFor("aura_health_regen")
	self.magic_resistance_aura = self:GetAbility():GetSpecialValueFor("magic_resistance_aura")
end

function modifier_item_pipe_aura_lua:DeclareFunctions()
	return{
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}
end

function modifier_item_pipe_aura_lua:GetModifierConstantHealthRegen()
	return self.aura_health_regen
end

function modifier_item_pipe_aura_lua:GetModifierMagicalResistanceBonus()
	return self.magic_resistance_aura
end