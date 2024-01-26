item_midas_lua = class({})

LinkLuaModifier("modifier_item_midas_lua", 'items/custom_items/item_midas_lua.lua', LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_midas_lua_shareable_gold", 'items/custom_items/item_midas_lua.lua', LUA_MODIFIER_MOTION_NONE)

function item_midas_lua:GetAbilityTextureName()
	local level = self:GetLevel()
	if self:GetSecondaryCharges() == 0 then
		return "all/item_midas" .. level
	else
		return "gem" .. self:GetSecondaryCharges() .. "/item_midas" .. level .. "_gem" .. self:GetSecondaryCharges()
	end
end

function item_midas_lua:OnUpgrade()
	Timers:CreateTimer(0.03,function()
		if (self:GetItemSlot() > 5 or self:GetItemSlot() == -1) then
			local m = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
			if m then
				m:Destroy()
			end
		end
	end)
end

function item_midas_lua:GetIntrinsicModifierName()
    return "modifier_item_midas_lua"
end

function item_midas_lua:CastFilterResultTarget(hTarget)
    if hTarget:HasModifier("modifier_item_midas_lua_shareable_gold") then
        return UF_FAIL_CUSTOM
    end
    return UnitFilter(hTarget, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), self:GetCaster():GetTeamNumber())
end

function item_midas_lua:GetCustomCastErrorTarget(hTarget)
    if hTarget:HasModifier("modifier_item_midas_lua_shareable_gold") then
        return "#dota_hud_error_already_has_midas"
    end
end

function item_midas_lua:OnSpellStart()
    if self.mod then
        self.mod:Destroy()
    end
    local target = self:GetCursorTarget()
    self.mod = target:AddNewModifier(self:GetCaster(), self, "modifier_item_midas_lua_shareable_gold", {})
end

modifier_item_midas_lua = class({})

--Classifications template
function modifier_item_midas_lua:IsHidden()
    return true
end

function modifier_item_midas_lua:IsDebuff()
    return false
end

function modifier_item_midas_lua:IsPurgable()
    return false
end

function modifier_item_midas_lua:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_item_midas_lua:IsStunDebuff()
    return false
end

function modifier_item_midas_lua:RemoveOnDeath()
    return false
end

function modifier_item_midas_lua:DestroyOnExpire()
    return false
end

function modifier_item_midas_lua:OnCreated()
    self.parent = self:GetParent()
    self.attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_item_midas_lua:OnRefresh()
    self.attack_speed = self:GetAbility():GetSpecialValueFor("attack_speed")
end

function modifier_item_midas_lua:OnDestroy()
    if not IsServer() then
        return
    end
    if self:GetAbility().mod then
        self:GetAbility().mod:Destroy()
    end
end

function modifier_item_midas_lua:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
    }
end

function modifier_item_midas_lua:GetModifierAttackSpeedBonus_Constant()
    return self.attack_speed
end

modifier_item_midas_lua_shareable_gold = class({})
--Classifications template
function modifier_item_midas_lua_shareable_gold:IsHidden()
    return false
end

function modifier_item_midas_lua_shareable_gold:IsDebuff()
    return false
end

function modifier_item_midas_lua_shareable_gold:IsPurgable()
    return false
end

function modifier_item_midas_lua_shareable_gold:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_item_midas_lua_shareable_gold:IsStunDebuff()
    return false
end

function modifier_item_midas_lua_shareable_gold:RemoveOnDeath()
    return true
end

function modifier_item_midas_lua_shareable_gold:DestroyOnExpire()
    return false
end

function modifier_item_midas_lua_shareable_gold:OnCreated()
    self.parent = self:GetParent()
    self.shareable_gold = self:GetAbility():GetSpecialValueFor("shareble_gold") * 0.01
    self.caster = self:GetCaster()
    if not IsServer() then
        return
    end
    ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'SharebleGold'), self)
end

function modifier_item_midas_lua_shareable_gold:OnDestroy()
    self:GetAbility().mod = nil
end

function modifier_item_midas_lua_shareable_gold:SharebleGold(data)
    if not self:GetAbility() or (self:GetAbility():GetItemSlot() == -1 or self:GetAbility():GetItemSlot() > 5) then
        self:Destroy()
        return
    end
    local killedUnit = EntIndexToHScript( data.entindex_killed )
	local killerEntity = EntIndexToHScript( data.entindex_attacker )
    if killerEntity == self.parent then
        local bounty = killedUnit:GetGoldBounty()
        if bounty then
            gold = bounty * self.shareable_gold
            self:GetCaster():ModifyGoldFiltered(gold, true, DOTA_ModifyGold_SharedGold)
        end
    end
end