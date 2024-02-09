ursa_overpower_lua = class({})
LinkLuaModifier( "modifier_ursa_overpower_lua", "heroes/hero_ursa/ursa_overpower_lua/modifier_ursa_overpower_lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_ursa_overpower_intrinsic", "heroes/hero_ursa/ursa_overpower_lua/modifier_ursa_overpower_intrinsic", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------
function ursa_overpower_lua:GetIntrinsicModifierName()
	return "modifier_ursa_overpower_intrinsic"
end

function ursa_overpower_lua:GetBehavior()
	if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_int7") then
		return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IGNORE_BACKSWING + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	end
end

function ursa_overpower_lua:GetManaCost(iLevel)
	if not self:GetCaster():IsRealHero() then return 0 end
	if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_int7") then
		return 0
	end
	return 100 + math.min(65000, self:GetCaster():GetIntellect()/100)
end

function ursa_overpower_lua:GetCooldown(level)
	if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_int9") then
		return self.BaseClass.GetCooldown( self, level ) * 1.5
	end
	return self.BaseClass.GetCooldown( self, level )
end

function ursa_overpower_lua:OnSpellStart()
	-- get references
	local bonus_duration = self:GetSpecialValueFor("duration_tooltip")

	-- Add buff modifier
	self:GetCaster():AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_ursa_overpower_lua",
		{ duration = bonus_duration }
	)
	-- Play effects
	self:PlayEffects()
end

function ursa_overpower_lua:PlayEffects()
	-- get resources
	local sound_cast = "Hero_Ursa.Overpower"

	-- play particles

	-- play sounds
	EmitSoundOn(sound_cast, self:GetCaster())
end