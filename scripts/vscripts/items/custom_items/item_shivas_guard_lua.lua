item_shivas_guard_lua = class({})

LinkLuaModifier("modifier_item_shivas_guard_lua", 'items/custom_items/item_shivas_guard_lua.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_shivas_guard_lua_active", 'items/custom_items/item_shivas_guard_lua.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_shivas_guard_aura_lua", 'items/custom_items/item_shivas_guard_lua.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_shivas_guard_slow_lua", 'items/custom_items/item_shivas_guard_lua.lua', LUA_MODIFIER_MOTION_NONE)

function item_shivas_guard_lua:GetAbilityTextureName()
	local level = self:GetLevel()
	if self:GetSecondaryCharges() == 0 then
		return "all/shivas_" .. level
	else
		return "gem" .. self:GetSecondaryCharges() .. "/item_shivas_guard_lua" .. level
	end
end

function item_shivas_guard_lua:OnUpgrade()
	Timers:CreateTimer(0.03,function()
		if (self:GetItemSlot() > 5 or self:GetItemSlot() == -1) then
			local m = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
			if m then
				m:Destroy()
			end
		end
	end)
end

function item_shivas_guard_lua:GetIntrinsicModifierName()
	return "modifier_item_shivas_guard_lua"
end

function item_shivas_guard_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_item_shivas_guard_lua_active", {})
end

-------------------------------------------------------------------------------------

modifier_item_shivas_guard_slow_lua = class({})

function modifier_item_shivas_guard_slow_lua:OnCreated()
	self.blast_movement_speed = self:GetAbility():GetSpecialValueFor("blast_movement_speed")
end

function modifier_item_shivas_guard_slow_lua:DeclareFunctions()
	return{
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
	}
end

function modifier_item_shivas_guard_slow_lua:GetModifierMoveSpeedBonus_Percentage()
	return self.blast_movement_speed
end



-------------------------------------------------------------------------------------
modifier_item_shivas_guard_aura_lua = class({})

function modifier_item_shivas_guard_aura_lua:IsHidden() return false end
function modifier_item_shivas_guard_aura_lua:IsPurgable() return false end
function modifier_item_shivas_guard_aura_lua:RemoveOnDeath() return false end
function modifier_item_shivas_guard_aura_lua:IsAuraActiveOnDeath() return false end

function modifier_item_shivas_guard_aura_lua:DeclareFunctions()
	return{
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_item_shivas_guard_aura_lua:GetModifierHPRegenAmplify_Percentage()
	return ( self:GetAbility():GetSpecialValueFor("hp_regen_degen_aura") * (-1) )
end

function modifier_item_shivas_guard_aura_lua:GetModifierAttackSpeedBonus_Constant()
	return (self:GetAbility():GetSpecialValueFor("aura_attack_speed"))
end

-------------------------------------------------------------------------------------

modifier_item_shivas_guard_lua = class({})

function modifier_item_shivas_guard_lua:IsHidden()
	return true
end

function modifier_item_shivas_guard_lua:IsPurgable()
	return false
end

function modifier_item_shivas_guard_lua:RemoveOnDeath()	
	return false 
end

function modifier_item_shivas_guard_lua:OnCreated()
	self.parent = self:GetParent()
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_shivas_guard_lua:OnRefresh()
	self.parent = self:GetParent()
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
	self.bonus_armor = self:GetAbility():GetSpecialValueFor("bonus_armor")
end

function modifier_item_shivas_guard_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
end

function modifier_item_shivas_guard_lua:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end

function modifier_item_shivas_guard_lua:GetModifierPhysicalArmorBonus()
	return self.bonus_armor
end

function modifier_item_shivas_guard_lua:IsAura()					return true end
function modifier_item_shivas_guard_lua:IsAuraActiveOnDeath() 		return false end
function modifier_item_shivas_guard_lua:GetAuraRadius()				return self:GetAbility():GetSpecialValueFor("aura_radius") end
function modifier_item_shivas_guard_lua:GetAuraSearchFlags()		return DOTA_UNIT_TARGET_FLAG_NONE end
function modifier_item_shivas_guard_lua:GetAuraSearchTeam()			return DOTA_UNIT_TARGET_TEAM_ENEMY end
function modifier_item_shivas_guard_lua:GetAuraSearchType()			return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC end
function modifier_item_shivas_guard_lua:GetModifierAura()			return "modifier_item_shivas_guard_aura_lua" end


modifier_item_shivas_guard_lua_active = class({})
--Classifications template
function modifier_item_shivas_guard_lua_active:IsHidden()
	return true
end

function modifier_item_shivas_guard_lua_active:IsDebuff()
	return false
end

function modifier_item_shivas_guard_lua_active:IsPurgable()
	return false
end

function modifier_item_shivas_guard_lua_active:IsPurgeException()
	return false
end

-- Optional Classifications
function modifier_item_shivas_guard_lua_active:IsStunDebuff()
	return false
end

function modifier_item_shivas_guard_lua_active:RemoveOnDeath()
	return false
end

function modifier_item_shivas_guard_lua_active:DestroyOnExpire()
	return false
end

function modifier_item_shivas_guard_lua_active:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_shivas_guard_lua_active:OnCreated()
	if not IsServer() then
		return
	end
	self.caster	= self:GetCaster()
	self.ability	= self:GetAbility()
	self.blast_radius = self.ability:GetSpecialValueFor("blast_radius")
	self.blast_speed = self.ability:GetSpecialValueFor("blast_speed")
	self.damage = self.ability:GetSpecialValueFor("blast_damage")
	self.blast_duration = self.blast_radius / self.blast_speed
	self.current_loc = self:GetCaster():GetAbsOrigin()
	
	self.slow_duration_tooltip	= self.ability:GetSpecialValueFor("slow_duration_tooltip")


	self:GetCaster():EmitSound("DOTA_Item.ShivasGuard.Activate")

	local blast_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
	ParticleManager:SetParticleControl(blast_pfx, 0, self:GetCaster():GetAbsOrigin())
	ParticleManager:SetParticleControl(blast_pfx, 1, Vector(self.blast_radius, self.blast_duration * 1.33, self.blast_speed))
	ParticleManager:ReleaseParticleIndex(blast_pfx)

	self.targets_hit = {}

	self.current_radius = 0
	self.tick_interval = 0.1
	self:StartIntervalThink(0.1)
end

function modifier_item_shivas_guard_lua_active:OnIntervalThink()
	AddFOWViewer(self:GetCaster():GetTeamNumber(), self.current_loc, self.current_radius, 0.1, false)

	self.current_radius = self.current_radius + self.blast_speed * self.tick_interval
	self.current_loc = self:GetCaster():GetAbsOrigin()

	local nearby_enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self.current_loc, nil, self.current_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
	for _,enemy in pairs(nearby_enemies) do
		local enemy_has_been_hit = false
		for _,enemy_hit in pairs(self.targets_hit) do
			if enemy == enemy_hit then enemy_has_been_hit = true end
		end

		if not enemy_has_been_hit then
			local hit_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
			ParticleManager:SetParticleControl(hit_pfx, 0, enemy:GetAbsOrigin())
			ParticleManager:SetParticleControl(hit_pfx, 1, enemy:GetAbsOrigin())
			ParticleManager:ReleaseParticleIndex(hit_pfx)

			ApplyDamage({attacker = self.caster, victim = enemy, ability = self.ability, damage = self.damage, damage_type = DAMAGE_TYPE_MAGICAL})

			enemy:AddNewModifier(self.caster, self.ability, "modifier_item_shivas_guard_slow_lua", {duration = 4})
			self.targets_hit[#self.targets_hit + 1] = enemy
		end
	end
	if self.current_radius > self.blast_radius then
		self:Destroy()
	end
end