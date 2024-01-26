LinkLuaModifier( "modifier_viper_nethertoxin_intrinsic_lua", "heroes/hero_viper/nethertoxin/nethertoxin_intrinsic" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_viper_nethertoxin_lua", "heroes/hero_viper/nethertoxin/nethertoxin" ,LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_viper_nethertoxin_lua_thinker", "heroes/hero_viper/nethertoxin/nethertoxin" ,LUA_MODIFIER_MOTION_NONE )

if viper_nethertoxin_lua == nil then
    viper_nethertoxin_lua = class({})
end

--------------------------------------------------------------------------------
function viper_nethertoxin_lua:GetIntrinsicModifierName()
    return "modifier_viper_nethertoxin_intrinsic_lua"
end
function viper_nethertoxin_lua:OnUpgrade()
    if self:GetLevel() == 1 then
        self:RefreshCharges()
    end
end

function viper_nethertoxin_lua:GetCooldown( level )
	if self:GetCaster():FindAbilityByName("npc_dota_hero_viper_int7") then
		return 0.1
	end

	return self.BaseClass.GetCooldown( self, level )
end

function viper_nethertoxin_lua:GetAOERadius()
    if self:GetCaster():FindAbilityByName("npc_dota_hero_viper_agi10") then
        return 600
    end
    return self:GetSpecialValueFor("radius")
end

function viper_nethertoxin_lua:OnSpellStart(attack)
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    
    if self:GetCaster():FindAbilityByName("npc_dota_hero_viper_agi10") and attack == nil then
        for i = 1, 3 do
            local angle_gaps = 360 / 3
            local qangle = QAngle(0, (i-1)*angle_gaps, 0)
            local direction = (point - caster:GetAbsOrigin()):Normalized()
            local spawn_point = point + direction * 200
            local mini_blast_center = RotatePosition(point, qangle, spawn_point)
            self:ApplyAbilityOnPoint(mini_blast_center)
        end
    else
        self:ApplyAbilityOnPoint(point)
    end
    EmitSoundOn("Hero_Viper.Nethertoxin.Cast", caster)
end

function viper_nethertoxin_lua:ApplyAbilityOnPoint(point)
    local caster = self:GetCaster()
    local vector = point-caster:GetOrigin()
    local projectile_speed = self:GetSpecialValueFor("projectile_speed")
    local projectile_distance = vector:Length2D()
    local projectile_direction = vector
    projectile_direction.z = 0
    projectile_direction = projectile_direction:Normalized()

    local info = {
        Ability = self,
        EffectName = "",
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = projectile_distance,
        fStartRadius = 0,
        fEndRadius = 0,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        bDeleteOnHit = false,
        vVelocity = projectile_direction * projectile_speed,
        bProvidesVision = false,
        iVisionRadius = 0,
        iVisionTeamNumber = caster:GetTeamNumber(),
    }

    ProjectileManager:CreateLinearProjectile( info )

    local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_viper/viper_nethertoxin_proj.vpcf", PATTACH_CUSTOMORIGIN, caster)
    ParticleManager:SetParticleControlEnt(fx, 0, caster, PATTACH_POINT, "attach_attack1", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControl(fx, 1, Vector(projectile_speed,0,0))
    ParticleManager:SetParticleControl(fx, 5, point)
end

function viper_nethertoxin_lua:OnProjectileHit(Target, Location)
    if Target then return false end

    local duration = self:GetSpecialValueFor("duration")

    CreateModifierThinker(self:GetCaster(), self, "modifier_viper_nethertoxin_lua_thinker", {duration = duration}, Location, self:GetCaster():GetTeamNumber(), false)

end

--------------------------------------------------------------------------------


modifier_viper_nethertoxin_lua_thinker = class({
    IsHidden                = function(self) return true end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return false end,
    IsBuff                  = function(self) return true end,
    RemoveOnDeath           = function(self) return true end,
})


--------------------------------------------------------------------------------

function modifier_viper_nethertoxin_lua_thinker:IsAura()
    return true
end

function modifier_viper_nethertoxin_lua_thinker:GetModifierAura()
    return "modifier_viper_nethertoxin_lua"
end

function modifier_viper_nethertoxin_lua_thinker:GetAuraRadius()
    return self.radius
end

function modifier_viper_nethertoxin_lua_thinker:GetAuraSearchTeam()    
    return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function modifier_viper_nethertoxin_lua_thinker:GetAuraDuration()    
    return 0.5
end

function modifier_viper_nethertoxin_lua_thinker:GetAuraSearchType()    
    return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function modifier_viper_nethertoxin_lua_thinker:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NONE
end

function modifier_viper_nethertoxin_lua_thinker:OnCreated()
    self.radius = self:GetAbility():GetSpecialValueFor("radius")

    if IsServer() then
        EmitSoundOn("Hero_Viper.NetherToxin", self:GetParent())

        local fx = ParticleManager:CreateParticle("particles/units/heroes/hero_viper/viper_nethertoxin.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(fx, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(fx, 1, Vector(self.radius,1,1))
        self:AddParticle(fx, false, false, -1, false, false)
    end
end

function modifier_viper_nethertoxin_lua_thinker:OnDestroy()
    if not IsServer() then
        return
    end
    UTIL_Remove(self:GetParent())
end

--------------------------------------------------------------------------------


modifier_viper_nethertoxin_lua = class({
    IsHidden                = function(self) return false end,
    IsPurgable              = function(self) return false end,
    IsPurgeException        = function(self) return false end,
    IsDebuff                = function(self) return true end,
    IsBuff                  = function(self) return false end,
    RemoveOnDeath           = function(self) return true end,
    CheckState              = function(self)
        return {
            [MODIFIER_STATE_PASSIVES_DISABLED] = true
        }
    end,
    GetEffectName           = function(self) return "particles/generic_gameplay/generic_break.vpcf" end,
    GetEffectAttachType     = function(self) return PATTACH_OVERHEAD_FOLLOW end,
    DeclareFunctions        = function(self)
        return {
            MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        }
    end,
})


--------------------------------------------------------------------------------

function modifier_viper_nethertoxin_lua:OnCreated()
    self.min_damage = self:GetAbility():GetSpecialValueFor("min_damage")
    self.max_damage = self:GetAbility():GetSpecialValueFor("max_damage")

    self.max_duration = self:GetAbility():GetSpecialValueFor("max_duration")
    self.duration = self:GetAbility():GetSpecialValueFor("duration")
    self.damage_mid_per_tick = (self.max_damage - self.min_damage) / (self.duration / 0.5)
    self.damage_per_tick = 0.01*math.ceil(100*self.damage_mid_per_tick)

    self.ticks = 1

    self.time_old = GameRules:GetGameTime()

    if IsServer() then
        self:StartIntervalThink(0.5)

        self.fx = ParticleManager:CreateParticle("particles/units/heroes/hero_viper/viper_nethertoxin_debuff.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, self:GetCaster())
        ParticleManager:SetParticleControlEnt(self.fx, 0, self:GetParent(), PATTACH_ABSORIGIN_FOLLOW, nil, self:GetParent():GetOrigin(), true)
        self:AddParticle(self.fx, false, false, -1, false, false)
    end
end

function modifier_viper_nethertoxin_lua:OnIntervalThink()
    local time_now = GameRules:GetGameTime()

    if math.floor(time_now - self.time_old) <= self.max_duration then
        self.ticks = self.ticks + 1
    end

    local damage = self.damage_per_tick * self.ticks

    ApplyDamage({
        victim = self:GetParent(),
        attacker = self:GetCaster(),
        damage = damage,
        damage_type = self:GetAbility():GetAbilityDamageType(),
        ability = self:GetAbility()
    })
    EmitSoundOn("Hero_Viper.NetherToxin.Damage", self:GetParent())
end

function modifier_viper_nethertoxin_lua:GetModifierMoveSpeedBonus_Percentage()
    if self:GetCaster():FindAbilityByName("npc_dota_hero_viper_str9") then
        return -self:GetAbility():GetSpecialValueFor("move_slow")
    end
end
