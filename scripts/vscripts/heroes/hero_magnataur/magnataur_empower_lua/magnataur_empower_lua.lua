LinkLuaModifier("modifier_empower_buff", "heroes/hero_magnataur/magnataur_empower_lua/modifier_empower_buff.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_magnataur_empower_lua", "heroes/hero_magnataur/magnataur_empower_lua/modifier_magnataur_empower_lua.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_magnataur_talent_str9", "heroes/hero_magnataur/magnataur_empower_lua/modifier_magnataur_talent_str9.lua", LUA_MODIFIER_MOTION_NONE)

magnataur_empower_lua = {}

function magnataur_empower_lua:GetIntrinsicModifierName()
	return "modifier_magnataur_empower_lua"
end

function magnataur_empower_lua:OnAbilityPhaseStart()
	return true
end

function magnataur_empower_lua:GetBehavior()
	if self:GetCaster():HasModifier("modifier_hero_magnataur_buff_1") then
		return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_AUTOCAST
	end
end

function magnataur_empower_lua:GetManaCost(iLevel)
	if self:GetCaster():HasModifier("modifier_hero_magnataur_buff_1") then
		return 0
	end
    return 100 + math.min(65000, self:GetCaster():GetIntellect() / 100)
end

function magnataur_empower_lua:OnSpellStart()
	local caster = self:GetCaster()
	local target = self:GetCursorTarget()
	local duration = self:GetSpecialValueFor( "empower_duration" )
	if caster:FindAbilityByName("npc_dota_hero_magnataur_agi9") then
		duration = duration + 20
	end
	target:AddNewModifier(
		caster,
		self,
		"modifier_empower_buff",
		{ duration = duration }
	)

	EmitSoundOn( "Hero_Magnataur.Empower.Cast", caster )
	EmitSoundOn( "Hero_Magnataur.Empower.Target", target )
end