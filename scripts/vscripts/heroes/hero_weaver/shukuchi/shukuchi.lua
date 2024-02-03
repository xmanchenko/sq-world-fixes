LinkLuaModifier("modifier_shukuchi", "heroes/hero_weaver/shukuchi/shukuchi", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shukuchi_intrinsic", "heroes/hero_weaver/shukuchi/modifier_shukuchi_intrinsic", LUA_MODIFIER_MOTION_NONE)

shukuchi_lua = class({})

function shukuchi_lua:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("radius")
end

function shukuchi_lua:GetIntrinsicModifierName()
	return "modifier_shukuchi_intrinsic"
end

function shukuchi_lua:OnSpellStart()
    if (not IsServer()) then
        return
    end
    self.caster = self:GetCaster()
    self.caster:EmitSound("Hero_Weaver.Shukuchi")
    local modifier = self.caster:FindModifierByNameAndCaster("modifier_shukuchi", self.caster)
    if (modifier) then
        modifier:Destroy()
    end
    self.caster:AddNewModifier(
            self.caster,
            self,
            "modifier_shukuchi",
            {
                duration = self:GetSpecialValueFor("duration")
            }
    )
end

modifier_shukuchi = class({
    GetEffectName = function()
        return "particles/units/heroes/hero_weaver/weaver_shukuchi.vpcf"
    end,
    DeclareFunctions = function()
        return {
            MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
            MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
            MODIFIER_PROPERTY_INVISIBILITY_LEVEL,
            MODIFIER_EVENT_ON_ATTACK,
            MODIFIER_EVENT_ON_ABILITY_FULLY_CAST,
        }
    end,
    GetModifierIgnoreMovespeedLimit = function(self)
        if not self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_int13") then
            return 1
        end
    end,
    GetModifierMoveSpeedBonus_Constant = function(self)
        if not self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_int13") then
            return self.speed
        end
    end
})

function modifier_shukuchi:CheckState()
    if (self:GetElapsedTime() >= self.fade_time) then
        return {
            [MODIFIER_STATE_INVISIBLE] = true,
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_UNSLOWABLE] = true
        }
    else
        return {
            [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
            [MODIFIER_STATE_UNSLOWABLE] = true
        }
    end
end

function modifier_shukuchi:GetModifierInvisibilityLevel()
    return math.min(self:GetElapsedTime() / self.fade_time, 1)
end

function modifier_shukuchi:OnCreated(kv)
    self.ability = self:GetAbility()
    self.fade_time = self.ability:GetSpecialValueFor("fade_time")
    self.speed = self.ability:GetSpecialValueFor("speed")
    self.duration = kv.duration
    if not IsServer() then
        return
    end
    self.casterTeam = self.ability.caster:GetTeamNumber()
    self.damage = self.ability:GetSpecialValueFor("damage")
    self.radius = self.ability:GetSpecialValueFor("radius")
    self.damaged_enemies = {}
    self.damaged_enemies_time = {}
    self.damage_table = {
        victim = nil,
        damage = self.damage,
        damage_type = self.ability:GetAbilityDamageType(),
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        attacker = self.ability.caster,
        ability = self.ability
    }
    local pidx = ParticleManager:CreateParticle(
            "particles/units/heroes/hero_weaver/weaver_shukuchi_start.vpcf",
            PATTACH_ABSORIGIN,
            self.ability.caster
    )
    ParticleManager:SetParticleControlForward(pidx, 0, self.ability.caster:GetForwardVector())
    ParticleManager:ReleaseParticleIndex(pidx)
    if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_str6") then
        self:GetCaster():Heal(self:GetCaster():GetMaxHealth() * 0.35, self:GetCaster())
    end
    self:StartIntervalThink(FrameTime())
end

function modifier_shukuchi:OnIntervalThink()
    if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_int13") then return end
    local casterPosition = self.ability.caster:GetAbsOrigin()
    local enemies = FindUnitsInRadius(
            self.casterTeam,
            casterPosition,
            nil,
            self.radius,
            DOTA_UNIT_TARGET_TEAM_ENEMY,
            DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_NONE,
            FIND_ANY_ORDER,
            false)
    for _, enemy in pairs(enemies) do
        if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_int12") and self.damaged_enemies_time[enemy] and self.damaged_enemies_time[enemy] <= GameRules:GetGameTime()-1 then
            self.damaged_enemies[enemy] = false
        end
        if (not self.damaged_enemies[enemy]) then
            local pidx = ParticleManager:CreateParticle(
                    "particles/units/heroes/hero_weaver/weaver_shukuchi_damage.vpcf",
                    PATTACH_ABSORIGIN,
                    enemy
            )
            ParticleManager:SetParticleControl(pidx, 1, casterPosition)
            ParticleManager:ReleaseParticleIndex(pidx)
            self.damage_table.victim = enemy
            ApplyDamage(self.damage_table)
            self.damaged_enemies[enemy] = true
            self.damaged_enemies_time[enemy] = GameRules:GetGameTime()
        end
    end
end

function modifier_shukuchi:OnAttack(keys)
    if keys.attacker == self.ability.caster and not keys.no_attack_cooldown and self:GetElapsedTime() >= self.fade_time then
        if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_str13") then
            if self.duration - 3 <= self:GetRemainingTime() then 
                return
            end
        elseif self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_str12") then
            if self.duration - 1.5 <= self:GetRemainingTime() then 
                return
            end
        end
        self:Destroy()
    end
end

function modifier_shukuchi:OnAbilityFullyCast(keys)
    if keys.unit == self.ability.caster and keys.ability ~= self.ability and self:GetElapsedTime() >= self.fade_time then
        self:Destroy()
    end
end