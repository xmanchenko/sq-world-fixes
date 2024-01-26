LinkLuaModifier("modifier_muerta_pierce_the_veil_lua", "heroes/hero_muerta/muerta_pierce_the_veil_lua/muerta_pierce_the_veil_lua.lua", LUA_MODIFIER_MOTION_NONE)

local ItemBaseClass = {
    IsPurgable = function(self) return false end,
    RemoveOnDeath = function(self) return false end,
    IsHidden = function(self) return true end,
    IsStackable = function(self) return false end,
}

muerta_pierce_the_veil_lua = class(ItemBaseClass)
modifier_muerta_pierce_the_veil_lua = class(muerta_pierce_the_veil_lua)
-------------
function muerta_pierce_the_veil_lua:OnToggle()
    if not IsServer() then return end

    local caster = self:GetCaster()
    local mod = "modifier_muerta_pierce_the_veil_lua"

    if self:GetToggleState() then
        caster:AddNewModifier(caster, self, mod, {})
        EmitSoundOn("Hero_Muerta.PierceTheVeil.Cast", caster)
    else
        caster:RemoveModifierByName(mod)
    end
end
-------------
function modifier_muerta_pierce_the_veil_lua:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PROJECTILE_NAME,
        MODIFIER_EVENT_ON_ATTACK,
        MODIFIER_EVENT_ON_ATTACK_LANDED,
        MODIFIER_EVENT_ON_ATTACK_START,
        MODIFIER_PROPERTY_ALWAYS_ETHEREAL_ATTACK,
        MODIFIER_PROPERTY_ABSOLUTE_NO_DAMAGE_PHYSICAL,
        MODIFIER_PROPERTY_OVERRIDE_ATTACK_MAGICAL,
        MODIFIER_PROPERTY_OVERRIDE_ATTACK_DAMAGE,
        MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_MAGICAL,
        MODIFIER_PROPERTY_MODEL_CHANGE,
        MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
        MODIFIER_PROPERTY_MODEL_SCALE,
        MODIFIER_PROPERTY_DISABLE_HEALING,
        MODIFIER_PROPERTY_MIN_HEALTH,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE 
    }
end

function modifier_muerta_pierce_the_veil_lua:GetModifierModelChange() return "models/heroes/muerta/muerta_ult.vmdl" end

function modifier_muerta_pierce_the_veil_lua:GetDisableHealing() return 1 end

function modifier_muerta_pierce_the_veil_lua:GetMinHealth()
    if self:GetParent():GetHealth() <= 1 then
        self:Destroy()
    end

    return 1
end

function modifier_muerta_pierce_the_veil_lua:GetModifierOverrideAttackDamage() return 0 end

function modifier_muerta_pierce_the_veil_lua:GetModifierProcAttack_BonusDamage_Magical(keys)
    ApplyDamage({
        attacker = self:GetCaster(),
        victim = keys.target,
        damage = keys.original_damage,
        damage_type = DAMAGE_TYPE_MAGICAL,
        ability = self:GetAbility()
    })
    return 0
end

function modifier_muerta_pierce_the_veil_lua:GetOverrideAttackMagical()
    return 1
end

function modifier_muerta_pierce_the_veil_lua:GetAllowEtherealAttack()
    return 1
end

function modifier_muerta_pierce_the_veil_lua:GetAbsoluteNoDamagePhysical()
    return 1
end

function modifier_muerta_pierce_the_veil_lua:GetModifierBaseDamageOutgoing_Percentage()
    return self:GetAbility():GetSpecialValueFor("base_damage_pct")
end

function modifier_muerta_pierce_the_veil_lua:GetModifierMoveSpeedBonus_Percentage()
    return self:GetAbility():GetSpecialValueFor("movespeed")
end

function modifier_muerta_pierce_the_veil_lua:GetModifierModelScale()
    return self:GetAbility():GetSpecialValueFor("modelscale")
end

function modifier_muerta_pierce_the_veil_lua:GetPriority()
    return 10001
end

function modifier_muerta_pierce_the_veil_lua:OnAttackLanded(event)
    if not IsServer() then return end

    local parent = self:GetParent()

    if parent ~= event.attacker then return end

    if event.target:IsMagicImmune() then
        EmitSoundOn("Hero_Muerta.PierceTheVeil.ProjectileImpact.MagicImmune", parent)
    else
        EmitSoundOn("Hero_Muerta.PierceTheVeil.ProjectileImpact", parent)
    end
end

function modifier_muerta_pierce_the_veil_lua:OnAttackStart(event)
    if not IsServer() then return end

    local parent = self:GetParent()

    if parent ~= event.attacker then return end

    EmitSoundOn("Hero_Muerta.PierceTheVeil.PreAttack", parent)
end

function modifier_muerta_pierce_the_veil_lua:OnAttack(event)
    if not IsServer() then return end

    local parent = self:GetParent()

    if parent ~= event.attacker then return end

    EmitSoundOn("Hero_Muerta.PierceTheVeil.Attack", parent)
end

function modifier_muerta_pierce_the_veil_lua:GetModifierProjectileName()
    return "particles/units/heroes/hero_muerta/muerta_ultimate_projectile.vpcf"
end

function modifier_muerta_pierce_the_veil_lua:OnCreated()
    if not IsServer() then return end

    local caster = self:GetCaster()

    self.vfx = ParticleManager:CreateParticle("particles/units/heroes/hero_muerta/muerta_ultimate_form_ethereal.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(self.vfx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.vfx, 1, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(self.vfx, 3, caster:GetAbsOrigin())

    EmitSoundOn("Hero_Muerta.PierceTheVeil.Layer", caster)

    local ability = self:GetAbility()

    local hpInitialCost = caster:GetMaxHealth() * (ability:GetSpecialValueFor("hp_initial_cost_pct")/100)
    local cost = caster:GetHealth() - hpInitialCost
    if cost < 1 then
        cost = 1
    end

    caster:SetHealth(cost)

    local interval = ability:GetSpecialValueFor("interval")

    self.i = 0

    self:StartIntervalThink(interval)
end

function modifier_muerta_pierce_the_veil_lua:OnIntervalThink()
    local damage = self:GetParent():GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("hp_drain_sec")/100)

    if self.i > 0 then
        damage = damage + (self:GetAbility():GetSpecialValueFor("hp_flat_cost_increase")*self.i)
    end

    if damage >= self:GetParent():GetHealth() then
        self:Destroy()
        return
    end

    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetParent(),
        damage_type = DAMAGE_TYPE_PURE,
        damage = damage,
        damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_NON_LETHAL + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS,
    })

    self.i = self.i + 1
end

function modifier_muerta_pierce_the_veil_lua:OnRemoved()
    if not IsServer() then return end

    local caster = self:GetCaster()

    if self.vfx ~= nil then
        ParticleManager:DestroyParticle(self.vfx, false)
        ParticleManager:ReleaseParticleIndex(self.vfx)
    end

    StopSoundOn("Hero_Muerta.PierceTheVeil.Layer", caster)
    EmitSoundOn("Hero_Muerta.PierceTheVeil.End", caster)

    if self:GetAbility():GetToggleState() then
        self:GetAbility():ToggleAbility()
    end

    self:GetAbility():UseResources(false, false, false, true)

    local heal = caster:GetMaxHealth() * (self:GetAbility():GetSpecialValueFor("end_duration_heal_pct")/100)
    caster:Heal(heal, self:GetAbility())
end