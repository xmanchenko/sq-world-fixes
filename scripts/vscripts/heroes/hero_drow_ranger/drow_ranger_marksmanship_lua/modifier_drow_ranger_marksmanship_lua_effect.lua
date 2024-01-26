modifier_drow_ranger_marksmanship_lua_effect = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_drow_ranger_marksmanship_lua_effect:IsHidden()
	return false
end

function modifier_drow_ranger_marksmanship_lua_effect:IsDebuff()
	return false
end

function modifier_drow_ranger_marksmanship_lua_effect:IsPurgable()
	return false
end

function modifier_drow_ranger_marksmanship_lua_effect:OnCreated( kv )
	self.multip = self:GetAbility():GetSpecialValueFor( "agility_multiplier" )
	self.npc_dota_hero_drow_ranger_str6 = self:GetCaster():FindAbilityByName("npc_dota_hero_drow_ranger_str6") ~= nil
	if self:GetParent():FindAbilityByName("npc_dota_hero_drow_ranger_agi8") ~= nil then 
		self.multip = self.multip + 10
	end
	if self:GetCaster():FindAbilityByName("npc_dota_hero_drow_ranger_str_last") ~= nil then
		self.multip = self.multip * 2
	end
	if self:GetCaster():FindAbilityByName("special_bonus_unique_npc_dota_hero_drow_ranger_str50") ~= nil then
		self.multip =  self.multip * 3
	end
	
	self:StartIntervalThink(1)
end

function modifier_drow_ranger_marksmanship_lua_effect:OnIntervalThink()
	self:OnRefresh()
end

function modifier_drow_ranger_marksmanship_lua_effect:OnRefresh( kv )
	self.multip = self:GetAbility():GetSpecialValueFor( "agility_multiplier" )
	self.npc_dota_hero_drow_ranger_str6 = self:GetCaster():FindAbilityByName("npc_dota_hero_drow_ranger_str6") ~= nil
	if self:GetParent():FindAbilityByName("npc_dota_hero_drow_ranger_agi8") ~= nil then 
		self.multip = self.multip + 10
	end
	if self:GetCaster():FindAbilityByName("npc_dota_hero_drow_ranger_str_last") ~= nil then
		self.multip = self.multip * 2
	end
	if self:GetCaster():FindAbilityByName("special_bonus_unique_npc_dota_hero_drow_ranger_str50") ~= nil then
		self.multip =  self.multip * 3
	end
end

function modifier_drow_ranger_marksmanship_lua_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
	}
end

function modifier_drow_ranger_marksmanship_lua_effect:GetModifierBonusStats_Agility()
	if self:GetCaster()==self:GetParent() then
		if self.lock1 then return end
		self.lock1 = true
		local val = self:GetCaster():GetAgility()
		self.lock1 = false
		return self.multip*val/100
	else
		local val = self:GetCaster():GetAgility()
		val = 100/(100+self.multip)*val
		return self.multip*val/100 / 3 --less bonus for allies
	end
end


function modifier_drow_ranger_marksmanship_lua_effect:GetModifierBonusStats_Strength()
	if not self.npc_dota_hero_drow_ranger_str6 then
		return
	end
	if self:GetCaster()==self:GetParent() then
		if self.lock2 then return end
		self.lock2 = true
		local val = self:GetCaster():GetStrength()
		self.lock2 = false

		return self.multip*val/100
	else
		local val = self:GetCaster():GetStrength()
		val = 100/(100+self.multip)*val
		return self.multip*val/100 / 3 --less bonus for allies
	end
end

function modifier_drow_ranger_marksmanship_lua_effect:GetModifierPreAttack_BonusDamage()
	if self:GetParent():FindAbilityByName("special_bonus_unique_npc_dota_hero_drow_ranger_agi50") ~= nil then 
		return self:GetCaster():GetAgility() * 5
	end
	return 0
end