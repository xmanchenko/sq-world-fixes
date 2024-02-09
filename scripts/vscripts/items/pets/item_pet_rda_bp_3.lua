LinkLuaModifier( "modifier_pet_rda_bp_3", "items/pets/item_pet_rda_bp_3", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_pet_rda_bp_3", "items/pets/item_pet_rda_bp_3", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_pet_rda_bp_3_split_damage_reduction", "items/pets/item_pet_rda_bp_3", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_take_drop_gem", "modifiers/modifier_take_drop_gem", LUA_MODIFIER_MOTION_NONE )

spell_item_pet_rda_bp_3 = class({})

function spell_item_pet_rda_bp_3:OnSpellStart()
	if IsServer() then
		self.caster = self:GetCaster()
		
		self.caster:AddNewModifier(
		self.caster,
		self,
		"modifier_pet_rda_bp_3", 
		{})
		EmitSoundOn( "Hero_Lion.Voodoo", self:GetCaster() )
	end
end

function spell_item_pet_rda_bp_3:GetIntrinsicModifierName()
	return "modifier_item_pet_rda_bp_3"
end

modifier_item_pet_rda_bp_3 = class({})

function modifier_item_pet_rda_bp_3:IsHidden()
	return true
end

function modifier_item_pet_rda_bp_3:IsPurgable()
	return false
end

function modifier_item_pet_rda_bp_3:OnCreated( kv )
	if IsServer() then
		local point = self:GetCaster():GetAbsOrigin()
		if not self:GetCaster():IsIllusion() then
			self.pet = CreateUnitByName("pet_rda_bp_3", point, true, nil, nil, DOTA_TEAM_GOODGUYS)
			self.pet:AddNewModifier(self:GetParent(),nil,"modifier_take_drop_gem",{})
			self.pet:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
			self.pet:SetOwner(self:GetCaster())
		end
	end
end
function modifier_item_pet_rda_bp_3:OnDestroy()
	UTIL_Remove(self.pet)
end

function modifier_item_pet_rda_bp_3:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MODEL_SCALE_ANIMATE_TIME,
		MODIFIER_PROPERTY_MODEL_SCALE_USE_IN_OUT_EASE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
	}
end

function modifier_item_pet_rda_bp_3:GetModifierModelScaleAnimateTime()
	return 0
end

function modifier_item_pet_rda_bp_3:GetModifierModelScaleUseInOutEase()
	return false
end

function modifier_item_pet_rda_bp_3:GetModifierAttackSpeedBonus_Constant()
	return self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_item_pet_rda_bp_3:OnAttackLanded( params )
	if params.attacker ~= self:GetParent() then return end
	local parent = self:GetParent()
	local heal_amount = params.damage / 100 * self:GetAbility():GetSpecialValueFor("attack_lifesteal")
	parent:Heal(math.min(heal_amount, 2^30), self:GetAbility())
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, parent )
	ParticleManager:SetParticleControl( effect_cast, 1, parent:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end

function modifier_item_pet_rda_bp_3:OnAttack(keys)
	if not IsServer() then return end
	if keys.attacker == self:GetParent() and keys.target and keys.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() and not keys.no_attack_cooldown and not self:GetParent():PassivesDisabled() and self:GetAbility():IsTrained() and self:GetParent():IsRangedAttacker() then	
		local enemies = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self:GetParent():Script_GetAttackRange() + 100, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_ANY_ORDER, false)
		local target_number = 0
		for _, enemy in pairs(enemies) do
			if enemy ~= keys.target then
				self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_item_pet_rda_bp_3_split_damage_reduction", {})
				self:GetParent():PerformAttack(enemy, false, true, true, true, true, false, false)
				self:GetParent():RemoveModifierByName("modifier_item_pet_rda_bp_3_split_damage_reduction")
				target_number = target_number + 1
				
				if target_number >= self:GetAbility():GetSpecialValueFor("attack_targets")-1 then
					break
				end
			end
		end
	end
end

function modifier_item_pet_rda_bp_3:OnAttackLanded( keys )
	if keys.attacker == self:GetParent() and ( not self:GetParent():IsIllusion() ) and not self:GetParent():IsRangedAttacker() then
		local target = keys.target
		if target ~= nil and target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
		
			local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_sven_int7")
			if abil ~= nil then 
				keys.target:AddNewModifier(self:GetCaster(), ability, "modifier_magic_debuff", {duration = 2})
			end
			
			DoCleaveAttack( self:GetParent(), target, self:GetAbility(), keys.damage / 100 * self:GetAbility():GetSpecialValueFor("cleave_damage"), 440, 150, 360, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf" )
		end
	end
end

modifier_item_pet_rda_bp_3_split_damage_reduction = class({})

function modifier_item_pet_rda_bp_3_split_damage_reduction:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
	}
end

function modifier_item_pet_rda_bp_3_split_damage_reduction:GetModifierDamageOutgoing_Percentage()
	return -100 + self:GetAbility():GetSpecialValueFor("second_target_damage")
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
modifier_pet_rda_bp_3 = class({})

function modifier_pet_rda_bp_3:IsHidden()
	return true
end

function modifier_pet_rda_bp_3:IsDebuff()
	return false
end

function modifier_pet_rda_bp_3:IsPurgable()
	return false
end

function modifier_pet_rda_bp_3:OnCreated( kv ) 
	self.caster = self:GetCaster()
	
	self.speed = self:GetAbility():GetSpecialValueFor( "speed" )

end

function modifier_pet_rda_bp_3:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

function modifier_pet_rda_bp_3:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_SPENT_MANA,
		MODIFIER_PROPERTY_MODEL_SCALE,
	}
	return funcs
end

function modifier_pet_rda_bp_3:GetModifierModelScale()
	return 50
end

function modifier_pet_rda_bp_3:GetModifierModelChange(params)
 return "models/items/courier/autumn_wards_courier/autumn_wards_courier.vmdl"
end

function modifier_pet_rda_bp_3:GetModifierMoveSpeed_Absolute()
	return self.speed
end

function modifier_pet_rda_bp_3:GetModifierIncomingDamage_Percentage()
	return 300
end

function modifier_pet_rda_bp_3:OnAttack( params )
	if IsServer() then
	if params.attacker~=self:GetParent() then return end
	--if params.target:GetTeamNumber()==self:GetParent():GetTeamNumber() then return end

	local modifier = self:GetParent():FindModifierByNameAndCaster( "modifier_pet_rda_bp_3", self:GetParent() )
	if not modifier then return end
	
	modifier:Destroy()
end
end

function modifier_pet_rda_bp_3:OnSpentMana( params )
	if IsServer() then
	local ability = self:GetAbility()
	local parent = self:GetParent()

	local cost = params.cost
	local unit = params.unit
			
	if unit == parent then
	
	self.mana_loss = 0
	
    self.mana_loss = self.mana_loss + params.cost
	if self.mana_loss >= 10 then

	local modifier = self:GetParent():FindModifierByNameAndCaster( "modifier_pet_rda_bp_3", self:GetParent() )
	if not modifier then return end
	
	modifier:Destroy()
end
end
end
end