sniper_headshot_lua = class({})
LinkLuaModifier( "modifier_sniper_headshot_lua", "heroes/hero_sniper/sniper_headshot_lua/modifier_sniper_headshot_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sniper_headshot_lua_slow", "heroes/hero_sniper/sniper_headshot_lua/modifier_sniper_headshot_lua_slow", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sniper_headshot_fly_vision", "heroes/hero_sniper/sniper_headshot_lua/sniper_headshot_lua", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
-- Passive Modifier
function sniper_headshot_lua:GetIntrinsicModifierName()
	return "modifier_sniper_headshot_lua"
end

function sniper_headshot_lua:GetManaCost(iLevel)
	if self:GetCaster():FindAbilityByName("special_bonus_unique_npc_dota_hero_sniper_agi50") then
		return 100 + math.min(65000, self:GetCaster():GetIntellect() / 100)
	end
end

function sniper_headshot_lua:GetCooldown(iLevel)
	if self:GetCaster():FindAbilityByName("special_bonus_unique_npc_dota_hero_sniper_agi50") then
		return 10
	end
end

function sniper_headshot_lua:GetBehavior()
	if self:GetCaster():FindAbilityByName("special_bonus_unique_npc_dota_hero_sniper_agi50") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING
	end
end

function sniper_headshot_lua:OnSpellStart()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_sniper_headshot_fly_vision", {duration=5})
end

modifier_sniper_headshot_fly_vision = class({})

function modifier_sniper_headshot_fly_vision:IsHidden()
	return false
end

function modifier_sniper_headshot_fly_vision:IsPurgable()
	return false
end

function modifier_sniper_headshot_fly_vision:RemoveOnDeath()
	return true
end

function modifier_sniper_headshot_fly_vision:CheckState()
	local state =
		{
			[MODIFIER_STATE_FORCED_FLYING_VISION] = true
		}
	return state
end