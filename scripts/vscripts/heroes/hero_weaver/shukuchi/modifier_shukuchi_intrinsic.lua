modifier_shukuchi_intrinsic = class({})

function modifier_shukuchi_intrinsic:IsHidden()
	return true
end

function modifier_shukuchi_intrinsic:IsPurgable()
	return false
end

function modifier_shukuchi_intrinsic:RemoveOnDeath()
	return false
end


function modifier_shukuchi_intrinsic:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
        MODIFIER_PROPERTY_IGNORE_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT,
	}

	return funcs
end

function modifier_shukuchi_intrinsic:GetModifierOverrideAbilitySpecial(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "speed" then
			return 1
		end
        if data.ability_special_value == "damage" then
			return 1
		end
        if data.ability_special_value == "radius" then
			return 1
		end
	end
	return 0
end

function modifier_shukuchi_intrinsic:GetModifierOverrideAbilitySpecialValue(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "speed" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "speed", data.ability_special_level )
            if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_agi6") then
                value = value * 5
            end
            return value
		end
        if data.ability_special_value == "damage" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "damage", data.ability_special_level )
            if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_int6") then
                value = value + self:GetCaster():GetIntellect()
            end
            if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_str9") then
                value = value + self:GetCaster():GetStrength() * 0.75
            end
            return value
		end
        if data.ability_special_value == "radius" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "radius", data.ability_special_level )
            if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_int9") then
                value = 600
            end
            return value
		end
	end
	return 0
end

function modifier_shukuchi_intrinsic:OnCreated( kv )
    if IsServer() then 
        self.damaged_enemies = {}
        self.damaged_enemies_time = {}
        self:StartIntervalThink(FrameTime())
    end
end

function modifier_shukuchi_intrinsic:OnIntervalThink()
    if not self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_int13") then return end
    self.ability = self:GetAbility()
    self.fade_time = self.ability:GetSpecialValueFor("fade_time")
    self.speed = self.ability:GetSpecialValueFor("speed")
    self.casterTeam = self:GetCaster():GetTeamNumber()
    self.damage = self.ability:GetSpecialValueFor("damage")
    self.radius = self.ability:GetSpecialValueFor("radius")
    self.damage_table = {
        victim = nil,
        damage = self.damage,
        damage_type = self.ability:GetAbilityDamageType(),
        damage_flags = DOTA_DAMAGE_FLAG_NONE,
        attacker = self:GetCaster(),
        ability = self.ability
    }
    local casterPosition = self:GetCaster():GetAbsOrigin()
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

function modifier_shukuchi_intrinsic:GetModifierIgnoreMovespeedLimit()
    if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_int13") then
        return 1
    end
end

function modifier_shukuchi_intrinsic:GetModifierMoveSpeedBonus_Constant()
    if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_int13") then
        return self.speed
    end
end