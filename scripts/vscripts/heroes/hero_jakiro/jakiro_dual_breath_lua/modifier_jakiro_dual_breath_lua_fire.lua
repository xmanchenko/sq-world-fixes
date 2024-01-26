modifier_jakiro_dual_breath_lua_fire = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_jakiro_dual_breath_lua_fire:IsHidden()
	return false
end

function modifier_jakiro_dual_breath_lua_fire:IsDebuff()
	return true
end

function modifier_jakiro_dual_breath_lua_fire:IsStunDebuff()
	return false
end

function modifier_jakiro_dual_breath_lua_fire:IsPurgable()
	return true
end

function modifier_jakiro_dual_breath_lua_fire:GetAttributes()
	if self:GetCaster():FindAbilityByName("npc_dota_hero_jakiro_int12") then
		return MODIFIER_ATTRIBUTE_MULTIPLE
	end
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_jakiro_dual_breath_lua_fire:OnCreated( kv )
	-- references
	local damage = self:GetAbility():GetSpecialValueFor( "burn_damage" )
	
	local talent_ability = self:GetCaster():FindAbilityByName("npc_dota_hero_jakiro_int1")
	if talent_ability ~= nil and talent_ability:GetLevel() > 0 then
		damage = self:GetAbility():GetSpecialValueFor( "burn_damage" ) + 50
	end
	

	if not IsServer() then return end

	-- precache damage
	self.damageTable = {
		victim = self:GetParent(),
		attacker = self:GetCaster(),
		damage = damage,
		damage_type = self:GetAbility():GetAbilityDamageType(),
		ability = self:GetAbility(), --Optional.
	}

	self:StartIntervalThink( 0.5 )
	self:OnIntervalThink()
end

function modifier_jakiro_dual_breath_lua_fire:OnRemoved()
end

function modifier_jakiro_dual_breath_lua_fire:OnDestroy()
end

--------------------------------------------------------------------------------
-- Interval Effects
function modifier_jakiro_dual_breath_lua_fire:OnIntervalThink()
	ApplyDamage( self.damageTable )
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_jakiro_dual_breath_lua_fire:GetEffectName()
	return "particles/units/heroes/hero_jakiro/jakiro_liquid_fire_debuff.vpcf"
end

function modifier_jakiro_dual_breath_lua_fire:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end