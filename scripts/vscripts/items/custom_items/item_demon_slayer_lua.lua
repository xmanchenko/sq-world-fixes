item_demon_slayer_lua = class({})

LinkLuaModifier("modifier_item_demon_slayer_lua", "items/custom_items/item_demon_slayer_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_demon_slayer_lua_effect", "items/custom_items/item_demon_slayer_lua.lua", LUA_MODIFIER_MOTION_NONE)

function item_demon_slayer_lua:GetCooldown()
    return 60
end

function item_demon_slayer_lua:IsRefreshable()
    return false
end

function item_demon_slayer_lua:GetIntrinsicModifierName()
    return "modifier_item_demon_slayer_lua"
end

function item_demon_slayer_lua:OnSpellStart()
    self:GetParent():AddNewModifier(self:GetCaster(), self, "modifier_item_demon_slayer_lua_effect", {duration = self:GetSpecialValueFor("duration")})
end

modifier_item_demon_slayer_lua = class({})
--Classifications template
function modifier_item_demon_slayer_lua:IsHidden()
    return false
end

function modifier_item_demon_slayer_lua:IsDebuff()
    return false
end

function modifier_item_demon_slayer_lua:IsPurgable()
    return false
end

function modifier_item_demon_slayer_lua:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_item_demon_slayer_lua:IsStunDebuff()
    return false
end

function modifier_item_demon_slayer_lua:RemoveOnDeath()
    return false
end

function modifier_item_demon_slayer_lua:DestroyOnExpire()
    return false
end

function modifier_item_demon_slayer_lua:OnCreated()
    self.health = self:GetAbility():GetSpecialValueFor("health")
    self.armor = self:GetAbility():GetSpecialValueFor("armor")
    if self:GetAbility().str == nil then
        self:GetAbility().str = 0
        self:GetAbility().int = 0
        self:GetAbility().agi = 0
    end
end

function modifier_item_demon_slayer_lua:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
    }
end

function modifier_item_demon_slayer_lua:GetModifierHealthBonus()
    return self.health
end

function modifier_item_demon_slayer_lua:GetModifierPhysicalArmorBonus()
    return self.armor
end

function modifier_item_demon_slayer_lua:GetModifierBonusStats_Strength()
    return self:GetAbility().str
end

function modifier_item_demon_slayer_lua:GetModifierBonusStats_Intellect()
    return self:GetAbility().int
end

function modifier_item_demon_slayer_lua:GetModifierBonusStats_Agility()
    return self:GetAbility().agi
end






modifier_item_demon_slayer_lua_effect = class({})
--Classifications template
function modifier_item_demon_slayer_lua_effect:IsHidden()
    return false
end

function modifier_item_demon_slayer_lua_effect:IsDebuff()
    return false
end

function modifier_item_demon_slayer_lua_effect:IsPurgable()
    return false
end

function modifier_item_demon_slayer_lua_effect:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_item_demon_slayer_lua_effect:IsStunDebuff()
    return false
end

function modifier_item_demon_slayer_lua_effect:RemoveOnDeath()
    return true
end

function modifier_item_demon_slayer_lua_effect:DestroyOnExpire()
    return true
end

function modifier_item_demon_slayer_lua_effect:OnCreated()
    self.agi = self:GetParent():GetAgility() * self:GetAbility():GetSpecialValueFor("convert") * 0.01
    self.int = self:GetParent():GetIntellect() * self:GetAbility():GetSpecialValueFor("convert") * 0.01
    self.str = self:GetParent():GetStrength() * self:GetAbility():GetSpecialValueFor("convert") * 0.01
    self.attack_rate_fix = self:GetAbility():GetSpecialValueFor("attack_rate_fix")
    if self:GetParent():GetAttacksPerSecond(false) >  self.attack_rate_fix then
        self.attack_rate_fix = self:GetParent():GetAttacksPerSecond(false)
    end
    if not IsServer() then
        return
    end
    self:StartIntervalThink(0.1)
end

function modifier_item_demon_slayer_lua_effect:OnDestroy()
    local r = RandomInt(1,3)
    if r == 1 then
        self:GetAbility().str = self:GetAbility().str + self:GetAbility():GetSpecialValueFor("stats_bonus")
    elseif r == 2 then
        self:GetAbility().int = self:GetAbility().int + self:GetAbility():GetSpecialValueFor("stats_bonus")
    else
        self:GetAbility().agi = self:GetAbility().agi + self:GetAbility():GetSpecialValueFor("stats_bonus")
    end
end

function modifier_item_demon_slayer_lua_effect:OnIntervalThink()
    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = self:GetParent():GetMaxHealth() * self:GetAbility():GetSpecialValueFor("self_damage") / 100 * 0.1,
        damage_type = DAMAGE_TYPE_MAGICAL,
        damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL,
        ability = self:GetAbility()
    })
end

function modifier_item_demon_slayer_lua_effect:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
        MODIFIER_PROPERTY_TOOLTIP
    }
end

function modifier_item_demon_slayer_lua_effect:GetDisableHealing()
    return 1
end

function modifier_item_demon_slayer_lua_effect:GetModifierPreAttack_BonusDamage()
    return self.agi + self.int + self.str
end

function modifier_item_demon_slayer_lua_effect:GetModifierBonusStats_Strength()
    if self.str then
        return -self.str
    end
end

function modifier_item_demon_slayer_lua_effect:GetModifierBonusStats_Intellect()
    if self.int then
        return -self.int
    end
end

function modifier_item_demon_slayer_lua_effect:GetModifierBonusStats_Agility()
    if self.agi then
        return -self.agi
    end
end

function modifier_item_demon_slayer_lua_effect:GetModifierFixedAttackRate()
    return self.attack_rate_fix
end

function modifier_item_demon_slayer_lua_effect:OnTooltip()
    return self:GetAbility():GetSpecialValueFor("self_damage")
end

function modifier_item_demon_slayer_lua_effect:GetEffectName()
    return "particles/econ/items/faceless_void/faceless_void_arcana/faceless_void_arcana_mask_of_madness_v2.vpcf"
end