LinkLuaModifier("modifier_time_lapse", "heroes/hero_weaver/time_lapse/time_lapse", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_time_lapse_cd", "heroes/hero_weaver/time_lapse/time_lapse", LUA_MODIFIER_MOTION_NONE)

time_lapse_lua = class({
    GetIntrinsicModifierName = function()
        return "modifier_time_lapse"
    end
})

function time_lapse_lua:OnUpgrade()
    if (not IsServer()) then
        return
    end
    if (not self.modifier) then
        self.modifier = self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName())
    end
end

function time_lapse_lua:OnSpellStart()
    if (not IsServer()) then
        return
    end
    local caster = self:GetCaster()
    local pidx = ParticleManager:CreateParticle("particles/units/heroes/hero_weaver/weaver_timelapse.vpcf", PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pidx, 2, self.modifier.position)
    ParticleManager:ReleaseParticleIndex(pidx)
    caster:EmitSound("Hero_Weaver.TimeLapse")
    ProjectileManager:ProjectileDodge(caster)
    caster:Purge(false, true, false, true, true)
    FindClearSpaceForUnit(caster, self.modifier.position, false)
    caster:SetHealth(self.modifier.health)
    caster:SetMana(self.modifier.mana)
    caster:Stop()
end

modifier_time_lapse = class({
    IsHidden = function()
        return true
    end,
    GetAttributes = function()
        return MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function()
        return {
            MODIFIER_EVENT_ON_RESPAWN,
            MODIFIER_EVENT_ON_DEATH,
            MODIFIER_EVENT_ON_TAKEDAMAGE,
        }
    end
})

function modifier_time_lapse:OnCreated()
    if (not IsServer()) then
        return
    end
    self.ability = self:GetAbility()
    self.caster = self.ability:GetCaster()
    self:OnIntervalThink()
    self:StartIntervalThink(self.ability:GetSpecialValueFor("return_time"))
end

function modifier_time_lapse:OnRefresh()
    if(not IsServer()) then
        return
    end
    self:StartIntervalThink(self.ability:GetSpecialValueFor("return_time"))
end

function modifier_time_lapse:OnIntervalThink()
    if (self.caster:IsAlive()) then
        self.position = self.caster:GetAbsOrigin()
        self.health = self.caster:GetHealth()
        self.mana = self.caster:GetMana()
    end
end

function modifier_time_lapse:OnDeath(params)
    if (not IsServer()) then
        return
    end
    if (params.unit == self.caster) then
        self:StartIntervalThink(-1)
    end
end

function modifier_time_lapse:OnRespawn(params)
    if (not IsServer()) then
        return
    end
    if (params.unit == self.caster) then
        self:StartIntervalThink(self.ability:GetSpecialValueFor("return_time"))
    end
end

function modifier_time_lapse:OnTakeDamage(keys)
    if keys.unit == self.caster and self.caster:FindAbilityByName("npc_dota_hero_weaver_str7") and self.caster:GetHealth() <= self.caster:GetMaxHealth() * 0.20 and not self.caster:HasModifier("modifier_time_lapse_cd") then
        self.ability:OnSpellStart()
        self.caster:AddNewModifier(self.caster, self.ability, "modifier_time_lapse_cd", {duration = 60 * self.caster:GetCooldownReduction()})
    end
end

modifier_time_lapse_cd = class({
    IsHidden = function()
        return false
    end,
    IsPurgable = function()
        return false
    end,
    RemoveOnDeath = function()
        return false
    end,
})