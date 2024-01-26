LinkLuaModifier( "modifier_pet_rda_armor_passive", "items/pets/pet_rda_armor", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_pet_rda_armor_pet_form", "items/pets/pet_rda_armor", LUA_MODIFIER_MOTION_NONE )

spell_pet_rda_armor = class({})

function spell_pet_rda_armor:OnSpellStart()
	if IsServer() then
		self.caster = self:GetCaster()
		
		self.caster:AddNewModifier(
		self.caster,
		self,
		"modifier_pet_rda_armor_pet_form", 
		{})
		EmitSoundOn( "Hero_Lion.Voodoo", self:GetCaster() )
	end
end

function spell_pet_rda_armor:GetIntrinsicModifierName()
	return "modifier_pet_rda_armor_passive"
end

modifier_pet_rda_armor_passive = class({})

function modifier_pet_rda_armor_passive:IsHidden()
	return true
end

function modifier_pet_rda_armor_passive:IsPurgable()
	return false
end

function modifier_pet_rda_armor_passive:OnCreated( kv )
	if not IsServer() then
		return
	end
	if not self:GetCaster():IsIllusion() then
	local pet = CreateUnitByName("pet_rda_armor", self:GetCaster():GetAbsOrigin(), true, self:GetCaster(), self:GetCaster(), DOTA_TEAM_GOODGUYS)
	pet:SetControllableByPlayer(self:GetCaster():GetPlayerID(), true)
	pet:SetOwner(self:GetCaster())
	end
end

function modifier_pet_rda_armor_passive:OnDestroy()
	if not IsServer() then
		return
	end
	UTIL_Remove(self.pet)
end

function modifier_pet_rda_armor_passive:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_pet_rda_armor_passive:GetModifierMagicalResistanceBonus()
	return self:GetAbility():GetSpecialValueFor( "magic_resist" ) * self:GetAbility():GetLevel()
end

function modifier_pet_rda_armor_passive:GetModifierPhysicalArmorBonus()
	return self:GetAbility():GetSpecialValueFor( "armor" ) * self:GetCaster():GetLevel()
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
modifier_pet_rda_armor_pet_form = class({})

function modifier_pet_rda_armor_pet_form:IsHidden()
	return true
end

function modifier_pet_rda_armor_pet_form:IsDebuff()
	return false
end

function modifier_pet_rda_armor_pet_form:IsPurgable()
	return false
end

function modifier_pet_rda_armor_pet_form:OnCreated( kv )
	self.caster = self:GetCaster()
	
	self.speed = self:GetAbility():GetSpecialValueFor( "speed" )

end

function modifier_pet_rda_armor_pet_form:CheckState()
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

function modifier_pet_rda_armor_pet_form:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_SPENT_MANA,
	}
	return funcs
end

function modifier_pet_rda_armor_pet_form:GetModifierModelChange(params)
 return "models/items/courier/amphibian_kid/amphibian_kid.vmdl"
end

function modifier_pet_rda_armor_pet_form:GetModifierMoveSpeed_Absolute()
	return self.speed
end

function modifier_pet_rda_armor_pet_form:GetModifierIncomingDamage_Percentage()
	return 300
end

function modifier_pet_rda_armor_pet_form:OnAttack( params )
	if not IsServer() then
		return
	end
	if params.attacker~=self:GetParent() then return end
	--if params.target:GetTeamNumber()==self:GetParent():GetTeamNumber() then return end
	
	self:Destroy()
end

function modifier_pet_rda_armor_pet_form:OnSpentMana( params )
	if not IsServer() then
		return
	end
	local ability = self:GetAbility()
	local parent = self:GetParent()

	local cost = params.cost
	local unit = params.unit
			
	if unit == parent then
	
		self.mana_loss = 0
		
		self.mana_loss = self.mana_loss + params.cost
		if self.mana_loss >= 10 then
		
			self:Destroy()
		end
	end
end