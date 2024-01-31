item_disperser_lua = class({})

LinkLuaModifier("modifier_item_disperser_lua", 'items/custom_items/item_disperser_lua.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_disperser_lua_active", 'items/custom_items/item_disperser_lua.lua', LUA_MODIFIER_MOTION_NONE)

function item_disperser_lua:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function item_disperser_lua:GetAbilityTextureName()
	local level = self:GetLevel()
	if self:GetSecondaryCharges() == 0 then
		return "all/item_disperser_lua" .. level
	else
		return "gem" .. self:GetSecondaryCharges() .. "/item_disperser_lua" .. level
	end
end

function item_disperser_lua:OnUpgrade()
	Timers:CreateTimer(0.03,function()
		if (self:GetItemSlot() > 5 or self:GetItemSlot() == -1) then
			local m = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
			if m then
				m:Destroy()
			end
		end
	end)
end

function item_disperser_lua:GetIntrinsicModifierName()
    return "modifier_item_disperser_lua"
end

function item_disperser_lua:OnSpellStart()
    EmitSoundOn("Item.Disperser.Cast", self:GetCaster())
    local units = FindUnitsInRadius(self:GetCursorTarget():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, self:GetSpecialValueFor("radius"), DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
    for _,unit in pairs(units) do
        unit:AddNewModifier(self:GetCaster(), self, "modifier_item_disperser_lua_active", {duration = self:GetSpecialValueFor("duration")})
    end
    if self:GetCursorTarget():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
        EmitSoundOn("Item.Disperser.Target.Ally", self:GetCursorTarget())
    else
        EmitSoundOn("Item.Disperser.Target.Enemy", self:GetCursorTarget())
    end
end

modifier_item_disperser_lua = class({})
--Classifications template
function modifier_item_disperser_lua:IsHidden()
    return true
end

function modifier_item_disperser_lua:IsDebuff()
    return false
end

function modifier_item_disperser_lua:IsPurgable()
    return false
end

function modifier_item_disperser_lua:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_item_disperser_lua:IsStunDebuff()
    return false
end

function modifier_item_disperser_lua:RemoveOnDeath()
    return false
end

function modifier_item_disperser_lua:DestroyOnExpire()
    return false
end

function modifier_item_disperser_lua:OnCreated()
    self.bonus_agility = self:GetAbility():GetSpecialValueFor("bonus_agility")
    self.bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
    self.chance = self:GetAbility():GetSpecialValueFor("chance")
    self.damage = self:GetAbility():GetSpecialValueFor("damage") / 100
end

function modifier_item_disperser_lua:OnRefresh()
    self.bonus_agility = self:GetAbility():GetSpecialValueFor("bonus_agility")
    self.bonus_intellect = self:GetAbility():GetSpecialValueFor("bonus_intellect")
    self.chance = self:GetAbility():GetSpecialValueFor("chance")
    self.damage = self:GetAbility():GetSpecialValueFor("damage") / 100
end

function modifier_item_disperser_lua:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_EVENT_ON_ATTACK_LANDED
    }
end

function modifier_item_disperser_lua:GetModifierBonusStats_Agility()
    return self.bonus_agility
end

function modifier_item_disperser_lua:GetModifierBonusStats_Intellect()
    return self.bonus_intellect
end

function modifier_item_disperser_lua:OnAttackLanded(data)
    if data.attacker ~= self:GetParent() then
        return
    end
    if data.target:IsBuilding() then
        return
    end
    if RollPercentage(self.chance) then
        local damage = self.damage * self:GetParent():GetAgility()
        ApplyDamage({
            victim = data.target,
            attacker = data.attacker,
            damage = damage,
            damage_type = DAMAGE_TYPE_PURE,
            damage_flags = DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
            ability = self:GetAbility()
        })
    end
end

modifier_item_disperser_lua_active = class({})
--Classifications template
function modifier_item_disperser_lua_active:IsHidden()
    return false
end

function modifier_item_disperser_lua_active:IsDebuff()
    return self:GetCaster():GetTeamNumber() ~= self:GetParent():GetTeamNumber()
end

function modifier_item_disperser_lua_active:IsPurgable()
    return true
end

function modifier_item_disperser_lua_active:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_item_disperser_lua_active:IsStunDebuff()
    return false
end

function modifier_item_disperser_lua_active:RemoveOnDeath()
    return true
end

function modifier_item_disperser_lua_active:DestroyOnExpire()
    return true
end

function modifier_item_disperser_lua_active:OnCreated()
    self.ms = 550
end

function modifier_item_disperser_lua_active:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
    }
end

function modifier_item_disperser_lua_active:GetModifierMoveSpeedBonus_Constant()
    if self:IsDebuff() then
        return self:GetRemainingTime() / self:GetDuration() * self.ms / 3 * -1
    else
        return self:GetRemainingTime() / self:GetDuration() * self.ms / 3
    end
end

function modifier_item_disperser_lua_active:CheckState()
    return {
        [MODIFIER_STATE_UNSLOWABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }
end

function modifier_item_disperser_lua_active:GetEffectName()
    return "particles/items_fx/disperser_buff.vpcf"
end

function modifier_item_disperser_lua_active:GetEffectAttachType()
    return PATTACH_POINT_FOLLOW
end