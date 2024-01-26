item_ethereal_blade_lua = class({})

LinkLuaModifier("modifier_item_ethereal_blade_lua", 'items/custom_items/item_ethereal_blade_lua.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ethereal_blade_ally", 'items/custom_items/item_ethereal_blade_lua.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_ethereal_blade_enemy", 'items/custom_items/item_ethereal_blade_lua.lua', LUA_MODIFIER_MOTION_NONE)

function item_ethereal_blade_lua:GetAbilityTextureName()
	local level = self:GetLevel()
	if self:GetSecondaryCharges() == 0 then
		return "all/ethereal_" .. level
	else
		return "gem" .. self:GetSecondaryCharges() .. "/item_ethereal_blade_lua" .. level
	end
end

function item_ethereal_blade_lua:OnUpgrade()
	Timers:CreateTimer(0.03,function()
		if (self:GetItemSlot() > 5 or self:GetItemSlot() == -1) then
			local m = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
			if m then
				m:Destroy()
			end
		end
	end)
end

function item_ethereal_blade_lua:GetIntrinsicModifierName()
	return "modifier_item_ethereal_blade_lua"
end

function item_ethereal_blade_lua:OnSpellStart()
	self.caster = self:GetCaster()
	local target = self:GetCursorTarget()
	if self.caster:IsRealHero() and PlayerResource:IsDisableHelpSetForPlayerID(self.caster:GetPlayerOwnerID(), target:GetPlayerOwnerID()) then
		self:GetAbility():EndCooldown()
		self:GetAbility():RefundManaCost()
		return
	end

	-- AbilitySpecials
	self.blast_movement_slow		=	self:GetSpecialValueFor("blast_movement_slow")
	self.duration					=	self:GetSpecialValueFor("duration")
	self.blast_agility_multiplier	=	self:GetSpecialValueFor("blast_agility_multiplier")

	self.blast_damage_base			=	self:GetSpecialValueFor("blast_damage_base")
	self.duration_ally				=	self:GetSpecialValueFor("duration_ally")
	self.ethereal_damage_bonus		=	self:GetSpecialValueFor("ethereal_damage_bonus")
	self.projectile_speed			=	self:GetSpecialValueFor("projectile_speed")
	

	-- Play the cast sound
	self.caster:EmitSound("DOTA_Item.EtherealBlade.Activate")

	-- Fire the projectile
	local projectile = {
		Target 				= target,
		Source 				= self.caster,
		Ability 			= self,
		EffectName 			= "particles/items_fx/ethereal_blade.vpcf",
		iMoveSpeed			= self.projectile_speed,
		vSourceLoc 			= caster_location,
		bDrawsOnMinimap 	= false,
		bDodgeable 			= true,
		bIsAttack 			= false,
		bVisibleToEnemies 	= true,
		bReplaceExisting 	= false,
		flExpireTime 		= GameRules:GetGameTime() + 20,
		bProvidesVision 	= false,
	}	
	ProjectileManager:CreateTrackingProjectile(projectile)
end

function item_ethereal_blade_lua:OnProjectileHit(target, location)
	if not IsServer() then return end
	if target and not target:IsMagicImmune() then
		if target:TriggerSpellAbsorb(self) then return nil end
		target:EmitSound("DOTA_Item.EtherealBlade.Target")

		if target:GetTeam() == self.caster:GetTeam() then
			target:AddNewModifier(self.caster, self, "modifier_item_ethereal_blade_ally", {duration = self.duration_ally})
		else
			target:AddNewModifier(self.caster, self, "modifier_item_ethereal_blade_enemy", {duration = self.duration * (1 - target:GetStatusResistance())})
			
			attr = 10000
			if self.caster:IsRealHero() then 
				attr = self.caster:GetPrimaryStatValue()
			end
			
			local damageTable = {
				victim 			= target,
				damage 			= attr * self.blast_agility_multiplier + self.blast_damage_base,
				damage_type		= DAMAGE_TYPE_MAGICAL,
				damage_flags 	= DOTA_DAMAGE_FLAG_NONE,
				attacker 		= self.caster,
				ability 		= self
			}
									
			ApplyDamage(damageTable)		
		end
	end
end	

----------------------------------------------------------------------------------

modifier_item_ethereal_blade_enemy = class({})

function modifier_item_ethereal_blade_enemy:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_item_ethereal_blade_enemy:OnCreated()
	self.ethereal_damage_bonus		= self:GetAbility():GetSpecialValueFor("ethereal_damage_bonus")
end

function modifier_item_ethereal_blade_enemy:CheckState()
	local state = {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true
	}
	
	return state
end

function modifier_item_ethereal_blade_enemy:DeclareFunctions()
	return{
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DECREPIFY_UNIQUE,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		
		-- IMBAfication: Extrasensory
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE
	}
end

function modifier_item_ethereal_blade_enemy:GetModifierMagicalResistanceDecrepifyUnique()
    return self.ethereal_damage_bonus
end

function modifier_item_ethereal_blade_enemy:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_item_ethereal_blade_enemy:GetModifierIgnoreCastAngle()
	if self:GetParent():GetTeam() == self:GetCaster():GetTeam() then
		return 1
	end
end

function modifier_item_ethereal_blade_enemy:GetModifierMoveSpeed_Absolute()
	return 100
end
----------------------------------------------------------------------------------
modifier_item_ethereal_blade_ally = class({})

function modifier_item_ethereal_blade_ally:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end

function modifier_item_ethereal_blade_ally:OnCreated()
	self.ethereal_damage_bonus		= self:GetAbility():GetSpecialValueFor("ethereal_damage_bonus")
end

function modifier_item_ethereal_blade_ally:CheckState()
	local state = {
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true
	}
	
	return state
end

function modifier_item_ethereal_blade_ally:DeclareFunctions()
	return{
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DECREPIFY_UNIQUE,
		MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
		
		-- IMBAfication: Extrasensory
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE
	}
end

function modifier_item_ethereal_blade_ally:GetModifierMagicalResistanceDecrepifyUnique()
    return self.ethereal_damage_bonus
end

function modifier_item_ethereal_blade_ally:GetAbsoluteNoDamagePhysical()
	return 1
end

function modifier_item_ethereal_blade_ally:GetModifierIgnoreCastAngle()
	if self:GetParent():GetTeam() == self:GetCaster():GetTeam() then
		return 1
	end
end
----------------------------------------------------------------------------------

modifier_item_ethereal_blade_lua = class({})

function modifier_item_ethereal_blade_lua:IsHidden()
	return true
end

function modifier_item_ethereal_blade_lua:IsPurgable()
	return false
end

function modifier_item_ethereal_blade_lua:RemoveOnDeath()	
	return false 
end

function modifier_item_ethereal_blade_lua:OnCreated()
	self.parent = self:GetParent()
	self.bonus_strength = self:GetAbility():GetSpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbility():GetSpecialValueFor("bonus_agility")
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_ethereal_blade_lua:OnRefresh()
	self.bonus_strength = self:GetAbility():GetSpecialValueFor("bonus_strength")
	self.bonus_agility = self:GetAbility():GetSpecialValueFor("bonus_agility")
	self.bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
end

function modifier_item_ethereal_blade_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
end

function modifier_item_ethereal_blade_lua:GetModifierBonusStats_Strength()
	return self.bonus_strength
end

function modifier_item_ethereal_blade_lua:GetModifierBonusStats_Agility()
	return self.bonus_agility
end

function modifier_item_ethereal_blade_lua:GetModifierBonusStats_Intellect()
	return self.bonus_intellect
end