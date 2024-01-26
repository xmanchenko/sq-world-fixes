modifier_ursa_fury_swipes_lua = class({})

--------------------------------------------------------------------------------

function modifier_ursa_fury_swipes_lua:IsHidden()
	return self:GetStackCount() == 0
end

function modifier_ursa_fury_swipes_lua:IsDebuff()
	return false
end

function modifier_ursa_fury_swipes_lua:IsPurgable()
	return false
end
--------------------------------------------------------------------------------

function modifier_ursa_fury_swipes_lua:OnCreated( kv )
	if IsServer() then
		-- get reference
		self.damage_per_stack = self:GetAbility():GetSpecialValueFor("damage_per_stack")
		self.bonus_reset_time = self:GetAbility():GetSpecialValueFor("bonus_reset_time")
		self.bonus_reset_time_roshan = self:GetAbility():GetSpecialValueFor("bonus_reset_time_roshan")
	end
end

function modifier_ursa_fury_swipes_lua:OnRefresh( kv )
	if IsServer() then
		-- get reference
		self.damage_per_stack = self:GetAbility():GetSpecialValueFor("damage_per_stack")
		self.bonus_reset_time = self:GetAbility():GetSpecialValueFor("bonus_reset_time")
		self.bonus_reset_time_roshan = self:GetAbility():GetSpecialValueFor("bonus_reset_time_roshan")
	end
end
--------------------------------------------------------------------------------

function modifier_ursa_fury_swipes_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL,
		MODIFIER_PROPERTY_OVERRIDE_ABILITY_SPECIAL_VALUE,
		MODIFIER_EVENT_ON_DEATH,
	}

	return funcs
end

function modifier_ursa_fury_swipes_lua:GetModifierOverrideAbilitySpecial(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "damage_per_stack" then
			return 1
		end
	end
	return 0
end

function modifier_ursa_fury_swipes_lua:GetModifierOverrideAbilitySpecialValue(data)
	if data.ability and data.ability == self:GetAbility() then
		if data.ability_special_value == "damage_per_stack" then
			local value = self:GetAbility():GetLevelSpecialValueNoOverride( "damage_per_stack", data.ability_special_level )
            if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_str9") then
                value = value * 5
            end
			value = value + self:GetStackCount()
            return value
		end
	end
	return 0
end

--------------------------------------------------------------------------------

function modifier_ursa_fury_swipes_lua:AddStackToEnemy(enemy)
	local caster = self:GetCaster()
	local modifier = enemy:FindModifierByNameAndCaster("modifier_ursa_fury_swipes_debuff_lua", caster)
	local duration = self.bonus_reset_time
	if enemy:GetUnitName()=="npc_boss_plague_squirrel" then
		duration = self.bonus_reset_time_roshan
	end
	if modifier == nil then
		modifier = enemy:AddNewModifier(caster, self:GetAbility(), "modifier_ursa_fury_swipes_debuff_lua", {duration = duration})
		modifier:SetStackCount(1)
		if caster:FindAbilityByName("npc_dota_hero_ursa_agi6") then
			modifier:SetStackCount(caster:GetAttacksPerSecond(false) * 3)
		end
	else
		modifier:IncrementStackCount()
		if caster:FindAbilityByName("npc_dota_hero_ursa_agi10") and caster:HasModifier("modifier_ursa_enrage_lua") then
			modifier:IncrementStackCount()
		end
		modifier:SetDuration(duration, true)
	end
end

function modifier_ursa_fury_swipes_lua:GetModifierProcAttack_BonusDamage_Physical( params )
	if IsServer() then
		-- get target
		local target = params.target if target==nil then target = params.unit end
		if target:GetTeamNumber()==self:GetParent():GetTeamNumber() then
			return 0
		end

		if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_agi7") then
			local enemies = FindUnitsInRadius (
				self:GetCaster():GetTeamNumber(),
				target:GetOrigin(),
				nil,
				200,
				DOTA_UNIT_TARGET_TEAM_ENEMY,
				DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
				DOTA_UNIT_TARGET_FLAG_NONE,
				FIND_ANY_ORDER,
				false
			)
			for _,enemy in pairs(enemies) do
				self:AddStackToEnemy(enemy)
			end
		else
			self:AddStackToEnemy(target)
		end
		
		local modifier = target:FindModifierByNameAndCaster("modifier_ursa_fury_swipes_debuff_lua", self:GetCaster())
		if modifier == nil then return 0 end
		return modifier:GetStackCount() * self.damage_per_stack
	end
end

function modifier_ursa_fury_swipes_lua:OnDeath(params)
	local parent = self:GetParent()
	if IsMyKilledBadGuys(parent, params) then
		if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_agi12") and table.has_value(bosses_names, params.unit:GetUnitName()) then
			self:SetStackCount(self:GetStackCount() + 3)
		end
		if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_agi13") then
			if self.creeps == nil then self.creeps = 0 end
			self.creeps = self.creeps +1
			if self.creeps % 25 == 0 then
				self:IncrementStackCount()
			end
		end
	end
end

function IsMyKilledBadGuys(hero, params)
    if params.unit:GetTeamNumber() ~= DOTA_TEAM_BADGUYS then
        return false
    end
    local attacker = params.attacker
    if hero == attacker then
        return true
    else
        if hero == attacker:GetOwner() then
            return true
        else
            return false
        end
    end
end