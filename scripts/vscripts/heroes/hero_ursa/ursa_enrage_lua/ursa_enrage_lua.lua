ursa_enrage_lua = class({})
LinkLuaModifier( "modifier_ursa_enrage_lua", "heroes/hero_ursa/ursa_enrage_lua/modifier_ursa_enrage_lua", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------
function ursa_enrage_lua:GetBehavior()
	local behavior = DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
 	if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_str8") then
 		behavior = behavior + DOTA_ABILITY_BEHAVIOR_IGNORE_PSEUDO_QUEUE
 	end
 	return behavior
end

function ursa_enrage_lua:GetCooldown( level )
	if self:GetCaster():FindAbilityByName("npc_dota_hero_ursa_str11") then
		return self.BaseClass.GetCooldown( self, level ) -20
	end

	return self.BaseClass.GetCooldown( self, level )
end

function ursa_enrage_lua:OnSpellStart()
	-- get references
	local bonus_duration = self:GetSpecialValueFor("duration")

	-- Purge
	self:GetCaster():Purge(false, true, false, true, false)

	-- Add buff modifier
	self:GetCaster():AddNewModifier(
		self:GetCaster(),
		self,
		"modifier_ursa_enrage_lua",
		{ duration = bonus_duration }
	)

	-- play effects
	self:PlayEffects()
end

function ursa_enrage_lua:PlayEffects()
	-- get resources
	local sound_cast = "Hero_Ursa.Enrage"

	-- play sound
	EmitSoundOn( sound_cast, self:GetCaster() )
end