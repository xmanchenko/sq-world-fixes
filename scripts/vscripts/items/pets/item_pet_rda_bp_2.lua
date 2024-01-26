LinkLuaModifier( "modifier_pet_rda_bp_2", "items/pets/item_pet_rda_bp_2", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_pet_rda_bp_2", "items/pets/item_pet_rda_bp_2", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_take_drop_gem", "modifiers/modifier_take_drop_gem", LUA_MODIFIER_MOTION_NONE )

spell_item_pet_rda_bp_2 = class({})

function spell_item_pet_rda_bp_2:OnSpellStart()
	if IsServer() then
		self.caster = self:GetCaster()
		
		self.caster:AddNewModifier(
		self.caster,
		self,
		"modifier_pet_rda_bp_2", 
		{})
		EmitSoundOn( "Hero_Lion.Voodoo", self:GetCaster() )
	end
end

function spell_item_pet_rda_bp_2:GetIntrinsicModifierName()
	return "modifier_item_pet_rda_bp_2"
end

modifier_item_pet_rda_bp_2 = class({})

function modifier_item_pet_rda_bp_2:IsHidden()
	return true
end

function modifier_item_pet_rda_bp_2:IsPurgable()
	return false
end

function modifier_item_pet_rda_bp_2:OnCreated( kv )
	if IsServer() then
		local point = self:GetCaster():GetAbsOrigin()
		if not self:GetCaster():IsIllusion() then
			self.pet = CreateUnitByName("pet_rda_bp_2", point, true, nil, nil, DOTA_TEAM_GOODGUYS)
			self.pet:AddNewModifier(self:GetParent(),nil,"modifier_take_drop_gem",{})
			self.pet:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
			self.pet:SetOwner(self:GetCaster())
		end
		self:StartIntervalThink(60)
	end
end
function modifier_item_pet_rda_bp_2:OnDestroy()
	UTIL_Remove(self.pet)
end

function modifier_item_pet_rda_bp_2:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_MODEL_SCALE_ANIMATE_TIME,
		MODIFIER_PROPERTY_MODEL_SCALE_USE_IN_OUT_EASE,
		MODIFIER_PROPERTY_VISUAL_Z_DELTA,
	}
end

function modifier_item_pet_rda_bp_2:GetVisualZDelta()
	if self:GetParent():HasModifier("modifier_pet_rda_roshan_1") then
		return 100
	end
	return 0
end

function modifier_item_pet_rda_bp_2:GetModifierModelScaleAnimateTime()
	return 0
end

function modifier_item_pet_rda_bp_2:GetModifierModelScaleUseInOutEase()
	return false
end

function modifier_item_pet_rda_bp_2:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor("armor_per_level") * self:GetParent():GetLevel()
end

function modifier_item_pet_rda_bp_2:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor("magic_resistance")
end

function modifier_item_pet_rda_bp_2:OnIntervalThink()
	if IsServer() then
		local totalgold = self:GetParent():GetTotalGold()
		self:GetParent():ModifyGoldFiltered(totalgold/100*self:GetAbility():GetSpecialValueFor("gold"), true, 0)
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
modifier_pet_rda_bp_2 = class({})

function modifier_pet_rda_bp_2:IsHidden()
	return true
end

function modifier_pet_rda_bp_2:IsDebuff()
	return false
end

function modifier_pet_rda_bp_2:IsPurgable()
	return false
end

function modifier_pet_rda_bp_2:OnCreated( kv ) 
	self.caster = self:GetCaster()
	
	self.speed = self:GetAbility():GetSpecialValueFor( "speed" )

end

function modifier_pet_rda_bp_2:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

function modifier_pet_rda_bp_2:DeclareFunctions()
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

function modifier_pet_rda_bp_2:GetModifierModelScale()
	return 50
end

function modifier_pet_rda_bp_2:GetModifierModelChange(params)
 return "models/items/courier/beaverknight/beaverknight_flying.vmdl"
end

function modifier_pet_rda_bp_2:GetModifierMoveSpeed_Absolute()
	return self.speed
end

function modifier_pet_rda_bp_2:GetModifierIncomingDamage_Percentage()
	return 300
end

function modifier_pet_rda_bp_2:OnAttack( params )
	if IsServer() then
	if params.attacker~=self:GetParent() then return end
	--if params.target:GetTeamNumber()==self:GetParent():GetTeamNumber() then return end

	local modifier = self:GetParent():FindModifierByNameAndCaster( "modifier_pet_rda_bp_2", self:GetParent() )
	if not modifier then return end
	
	modifier:Destroy()
end
end

function modifier_pet_rda_bp_2:OnSpentMana( params )
	if IsServer() then
	local ability = self:GetAbility()
	local parent = self:GetParent()

	local cost = params.cost
	local unit = params.unit
			
	if unit == parent then
	
	self.mana_loss = 0
	
    self.mana_loss = self.mana_loss + params.cost
	if self.mana_loss >= 10 then

	local modifier = self:GetParent():FindModifierByNameAndCaster( "modifier_pet_rda_bp_2", self:GetParent() )
	if not modifier then return end
	
	modifier:Destroy()
end
end
end
end