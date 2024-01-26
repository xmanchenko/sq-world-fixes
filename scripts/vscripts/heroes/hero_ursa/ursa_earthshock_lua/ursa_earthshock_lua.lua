ursa_earthshock_lua = class({})
LinkLuaModifier( "modifier_ursa_earthshock_lua", "heroes/hero_ursa/ursa_earthshock_lua/modifier_ursa_earthshock_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_ursa_earthshock_movement", "heroes/hero_ursa/ursa_earthshock_lua/modifier_ursa_earthshock_movement", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ursa_earthshock_intrinsic", "heroes/hero_ursa/ursa_earthshock_lua/modifier_ursa_earthshock_intrinsic", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------

function ursa_earthshock_lua:GetIntrinsicModifierName()
	return "modifier_ursa_earthshock_intrinsic"
end

function ursa_earthshock_lua:GetCastRange()
    if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_int11") then
        return 800
    end
    return self:GetSpecialValueFor("shock_radius")
end

function ursa_earthshock_lua:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 0.33/0.25)
	return true
end

function ursa_earthshock_lua:OnAbilityPhaseInterrupted()
	local caster = self:GetCaster()
	caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
end

function ursa_earthshock_lua:OnSpellStart()
    self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ursa_earthshock_movement", {duration = self:GetSpecialValueFor("hop_distance") / self:GetSpecialValueFor("speed") + 0.2})
    self:Enrage(1.5)
end

function ursa_earthshock_lua:Enrage(duration)
    if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_str7") then
        local enrage = self:GetCaster():FindAbilityByName("ursa_enrage_lua")
        if enrage and enrage:GetLevel() > 0 then
            self:GetCaster():Purge(false, true, false, true, false)
            enrage:PlayEffects()
            self:GetCaster():AddNewModifier(self:GetCaster(), enrage, "modifier_ursa_enrage_lua", {duration = duration})
        end
    end
end

function ursa_earthshock_lua:EarthShock()
    -- get references
    local slow_radius = self:GetSpecialValueFor("shock_radius")
    local slow_duration = self:GetSpecialValueFor("duration")
    local ability_damage = self:GetSpecialValueFor("damage")


    -- get list of affected enemies
    local enemies = FindUnitsInRadius (
        self:GetCaster():GetTeamNumber(),
        self:GetCaster():GetOrigin(),
        nil,
        slow_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY,
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE,
        FIND_ANY_ORDER,
        false
    )

    local npc_dota_hero_ursa_str10 = self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_str10")
    -- Do for each affected enemies
    for _,enemy in pairs(enemies) do
        -- Apply damage
        local damage = {
            victim = enemy,
            attacker = self:GetCaster(),
            damage = ability_damage,
            damage_type = DAMAGE_TYPE_MAGICAL,
            ability = self
        }
        ApplyDamage( damage )
        if npc_dota_hero_ursa_str10 then
            self:GetCaster():PerformAttack( enemy, true, true, true, false, false, false, false )
        end
        -- Add slow modifier
        enemy:AddNewModifier(
            self:GetCaster(),
            self,
            "modifier_ursa_earthshock_lua",
            { duration = slow_duration }
        )
    end

    -- Play effects
    self:PlayEffects()
end

function ursa_earthshock_lua:PlayEffects()
	-- get resources
	local sound_cast = "Hero_Ursa.Earthshock"
	local particle_cast = "particles/units/heroes/hero_ursa/ursa_earthshock.vpcf"

	-- get data
	local slow_radius = self:GetSpecialValueFor("shock_radius")

	-- play particles
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	-- local effect_cast = assert(loadfile("lua_abilities/rubick_spell_steal_lua/rubick_spell_steal_lua_arcana"))(self, particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self:GetCaster():GetOrigin() )
	ParticleManager:SetParticleControlForward( effect_cast, 0, self:GetCaster():GetForwardVector() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector(slow_radius/2, slow_radius/2, slow_radius/2) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	-- play sounds
	EmitSoundOn( sound_cast, self:GetCaster() )
end