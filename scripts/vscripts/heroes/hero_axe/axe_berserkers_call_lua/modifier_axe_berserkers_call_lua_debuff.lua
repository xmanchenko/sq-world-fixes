modifier_axe_berserkers_call_lua_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_axe_berserkers_call_lua_debuff:IsHidden()
	return false
end

function modifier_axe_berserkers_call_lua_debuff:IsDebuff()
	return true
end

function modifier_axe_berserkers_call_lua_debuff:IsStunDebuff()
	return false
end

function modifier_axe_berserkers_call_lua_debuff:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_axe_berserkers_call_lua_debuff:OnCreated( kv )
	if IsServer() then
		-- two not working...?
		-- self:GetParent():SetAggroTarget( self:GetCaster() )
		-- self:GetParent():SetAttacking( self:GetCaster() )
		self:GetParent():SetForceAttackTarget( self:GetCaster() ) -- for creeps
		self:GetParent():MoveToTargetToAttack( self:GetCaster() ) -- for heroes
	end
	if self:GetCaster():FindAbilityByName("special_bonus_unique_npc_dota_hero_axe_agi50") then
		self.attackspeed = 1000
	end
end

function modifier_axe_berserkers_call_lua_debuff:OnRefresh( kv )
end

function modifier_axe_berserkers_call_lua_debuff:OnRemoved()
	if IsServer() then
		self:GetParent():SetForceAttackTarget( nil )
	end
end

function modifier_axe_berserkers_call_lua_debuff:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT
	}
end

function modifier_axe_berserkers_call_lua_debuff:GetModifierAttackSpeedBonus_Constant()
	return self.attackspeed
end
--------------------------------------------------------------------------------
-- Status Effects
function modifier_axe_berserkers_call_lua_debuff:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_axe_berserkers_call_lua_debuff:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end
