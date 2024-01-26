item_veil_of_discord_lua = class({})

LinkLuaModifier("modifier_item_veil_of_discord_lua", 'items/custom_items/item_veil_of_discord_lua.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_veil_of_discord_active_lua", 'items/custom_items/item_veil_of_discord_lua.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_veil_of_discord_aura_lua", 'items/custom_items/item_veil_of_discord_lua.lua', LUA_MODIFIER_MOTION_NONE)

function item_veil_of_discord_lua:GetAbilityTextureName()
	local level = self:GetLevel()
	if self:GetSecondaryCharges() == 0 then
		return "all/veil_" .. level
	else
		return "gem" .. self:GetSecondaryCharges() .. "/item_veil_of_discord_lua" .. level
	end
end

function item_veil_of_discord_lua:OnUpgrade()
	Timers:CreateTimer(0.03,function()
		if (self:GetItemSlot() > 5 or self:GetItemSlot() == -1) then
			local m = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
			if m then
				m:Destroy()
			end
		end
	end)
end

function item_veil_of_discord_lua:GetIntrinsicModifierName()
	return "modifier_item_veil_of_discord_lua"
end

function item_veil_of_discord_lua:OnSpellStart()
	local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCursorPosition(), nil, self:GetSpecialValueFor("debuff_radius"), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP, 0, FIND_ANY_ORDER, false)
	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(self:GetCaster(), self, "modifier_item_veil_of_discord_active_lua", {duration = self:GetSpecialValueFor("resist_debuff_duration")})
	end	

	local particle_fx = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf", PATTACH_ABSORIGIN, self:GetCaster())
	ParticleManager:SetParticleControl(particle_fx, 0, self:GetCursorPosition())
	ParticleManager:SetParticleControl(particle_fx, 1, Vector(self:GetSpecialValueFor("debuff_radius"), 1, 1))
	ParticleManager:ReleaseParticleIndex(particle_fx)
	self:GetCaster():EmitSound("DOTA_Item.VeilofDiscord.Activate")
end
-----------------------------------------------------------------------------------
modifier_item_veil_of_discord_active_lua = class({})

function modifier_item_veil_of_discord_active_lua:IsDebuff() return true end
function modifier_item_veil_of_discord_active_lua:IsHidden() return false end
function modifier_item_veil_of_discord_active_lua:IsPurgable() return true end

function modifier_item_veil_of_discord_active_lua:OnCreated()
	self.spell_amp = self:GetAbility():GetSpecialValueFor("spell_amp")
end

function modifier_item_veil_of_discord_active_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}
end

function modifier_item_veil_of_discord_active_lua:GetModifierIncomingDamage_Percentage(keys)
	if keys.damage_category == DOTA_DAMAGE_CATEGORY_SPELL then
		return self.spell_amp
	end
end

function modifier_item_veil_of_discord_active_lua:GetEffectName()
	return "particles/items2_fx/veil_of_discord_debuff.vpcf"
end

-----------------------------------------------------------------------------------

modifier_item_veil_of_discord_lua = class({})

function modifier_item_veil_of_discord_lua:IsDebuff() return false end
function modifier_item_veil_of_discord_lua:IsHidden() return true end
function modifier_item_veil_of_discord_lua:IsPurgable() return false end

function modifier_item_veil_of_discord_lua:OnCreated()
	self.parent = self:GetParent()
	self.bonus_all_stats = self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_veil_of_discord_lua:OnRefresh()
	self.parent = self:GetParent()
	self.bonus_all_stats = self:GetAbility():GetSpecialValueFor("bonus_all_stats")
end

function modifier_item_veil_of_discord_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
	}
end

function modifier_item_veil_of_discord_lua:GetModifierBonusStats_Strength()
	return self.bonus_all_stats
end

function modifier_item_veil_of_discord_lua:GetModifierBonusStats_Agility()
	return self.bonus_all_stats
end

function modifier_item_veil_of_discord_lua:GetModifierBonusStats_Intellect()
	return self.bonus_all_stats
end

-------------------------------------------------------------------------------

function modifier_item_veil_of_discord_lua:GetModifierAura()
	return "modifier_item_veil_of_discord_aura_lua"
end

function modifier_item_veil_of_discord_lua:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_item_veil_of_discord_lua:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function modifier_item_veil_of_discord_lua:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_item_veil_of_discord_lua:IsAura()
	return true
end

function modifier_item_veil_of_discord_lua:GetAuraRadius()
	if self:GetAbility() then
		return self:GetAbility():GetSpecialValueFor("aura_radius")
	end
end

------------------------------------------------------------------------------

modifier_item_veil_of_discord_aura_lua = class({})

function modifier_item_veil_of_discord_aura_lua:IsHidden() return false end
function modifier_item_veil_of_discord_aura_lua:IsPurgable() return false end
function modifier_item_veil_of_discord_aura_lua:RemoveOnDeath() return false end
function modifier_item_veil_of_discord_aura_lua:IsAuraActiveOnDeath() return false end

function modifier_item_veil_of_discord_aura_lua:OnCreated()
	if not IsServer() then
		return
	end
	self.aura_mana_regen = self:GetAbility():GetSpecialValueFor("aura_mana_regen")
	self:SetHasCustomTransmitterData( true )
end

function modifier_item_veil_of_discord_aura_lua:OnRefresh()
	if not IsServer() then
		return
	end
	self.aura_mana_regen = self:GetAbility():GetSpecialValueFor("aura_mana_regen")
	self:SendBuffRefreshToClients()
end

function modifier_item_veil_of_discord_aura_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
end

function modifier_item_veil_of_discord_aura_lua:GetModifierConstantManaRegen()
	return self.aura_mana_regen
end

function modifier_item_veil_of_discord_aura_lua:AddCustomTransmitterData()
	return {
		aura_mana_regen = self.aura_mana_regen,
	}
end

function modifier_item_veil_of_discord_aura_lua:HandleCustomTransmitterData( data )
	self.aura_mana_regen = data.aura_mana_regen
end
