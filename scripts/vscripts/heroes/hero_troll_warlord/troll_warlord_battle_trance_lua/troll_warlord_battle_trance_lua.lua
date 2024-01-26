LinkLuaModifier("modifier_troll_warlord_battle_trance_lua", "heroes/hero_troll_warlord/troll_warlord_battle_trance_lua/troll_warlord_battle_trance_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_troll_warlord_battle_trance_lua_vision_720", "heroes/hero_troll_warlord/troll_warlord_battle_trance_lua/troll_warlord_battle_trance_lua", LUA_MODIFIER_MOTION_NONE)

troll_warlord_battle_trance_lua = class({})
function troll_warlord_battle_trance_lua:IsHiddenWhenStolen() return false end
function troll_warlord_battle_trance_lua:IsRefreshable() return true end
function troll_warlord_battle_trance_lua:IsStealable() return true end
function troll_warlord_battle_trance_lua:IsNetherWardStealable() return true end

function troll_warlord_battle_trance_lua:GetAbilityTextureName()
	return "troll_warlord_battle_trance"
end

function troll_warlord_battle_trance_lua:GetCooldown( level )
	if self:GetCaster():FindAbilityByName("npc_dota_hero_troll_warlord_int9") ~= nil then 
		return  self.BaseClass.GetCooldown( self, level ) - 30
	end
	return self.BaseClass.GetCooldown( self, level )
end

function troll_warlord_battle_trance_lua:GetManaCost(iLevel)
	if self:GetCaster():FindAbilityByName("npc_dota_hero_troll_warlord_int8") == nil then 
		return 0
	end
	return 100 + math.min(65000, self:GetCaster():GetIntellect() / 100)
end

function troll_warlord_battle_trance_lua:OnSpellStart()
	if IsServer() then
		local caster	= self:GetCaster()
		local duration = self:GetSpecialValueFor("buff_duration")
		caster:EmitSound("Hero_TrollWarlord.BattleTrance.Cast")
		
		caster:Purge(false, true, false, false, false)
		
		if self:GetCaster():FindAbilityByName("special_bonus_unique_npc_dota_hero_troll_warlord_str50") then
			duration = duration * 2
		end
		
		local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_troll_warlord_int_last")
		if abil ~= nil	then 
			local allies = FindUnitsInRadius(caster:GetTeamNumber(), Vector(0,0,0), nil, FIND_UNITS_EVERYWHERE, self:GetAbilityTargetTeam(), self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false)
			for _,ally in ipairs(allies) do
				local mod = ally:AddNewModifier(caster, self, "modifier_troll_warlord_battle_trance_lua", {duration = duration})
				mod.sound = sound
			end
		else
			caster:AddNewModifier(caster, self, "modifier_troll_warlord_battle_trance_lua", {duration = duration})
		end
		
		local cast_pfx = ParticleManager:CreateParticle( "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
		ParticleManager:SetParticleControlEnt( cast_pfx, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc" , caster:GetOrigin(), true )
		ParticleManager:ReleaseParticleIndex(cast_pfx)
		caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
	end
end

-----------------------------------------------------------------------------------

modifier_troll_warlord_battle_trance_lua = class({})

function modifier_troll_warlord_battle_trance_lua:IsPurgable()	return false end

function modifier_troll_warlord_battle_trance_lua:GetEffectName()
	return "particles/units/heroes/hero_troll_warlord/troll_warlord_battletrance_buff.vpcf"
end

function modifier_troll_warlord_battle_trance_lua:OnCreated()
	self.ability	= self:GetAbility()
	self.caster		= self:GetCaster()
	self.parent		= self:GetParent()
	
	self.lifesteal		= self.ability:GetSpecialValueFor("lifesteal")
	self.attack_speed	= self.ability:GetSpecialValueFor("attack_speed")
	self.movement_speed	= self.ability:GetSpecialValueFor("movement_speed")
	self.range			= self.ability:GetSpecialValueFor("range")
	
	local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_troll_warlord_agi8")
		if abil ~= nil	then 	
			self.lifesteal = self.lifesteal + 40
		end
	
	self.bonus_bat = min(self.ability:GetSpecialValueFor("bonus_bat"), self.parent:GetBaseAttackTime())

	if not IsServer() then return end
	
	self.target = nil
	
	self:OnIntervalThink()
	self:StartIntervalThink(FrameTime())
end

function modifier_troll_warlord_battle_trance_lua:OnIntervalThink()

	if not IsServer() or self.ability:IsNull() then return end

	if self.target and self.target:IsAlive() and not self.target:IsAttackImmune() and not self.target:IsInvulnerable() and self.parent:CanEntityBeSeenByMyTeam(self.target) then
			
		if self:GetStackCount() ~= 1 then
			self:SetStackCount(1)
		end
		
		local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_troll_warlord_int11")
		if abil == nil	then 
			self.parent:MoveToTargetToAttack(self.target)
		end	
	
		if not self.target:HasModifier("modifier_troll_warlord_battle_trance_lua_vision_720") and (self.target:GetAbsOrigin() - self.parent:GetAbsOrigin()):Length2D() <= self.range then
			self.target:AddNewModifier(self.parent, self.ability, "modifier_troll_warlord_battle_trance_lua_vision_720", {})
		elseif self.target:HasModifier("modifier_troll_warlord_battle_trance_lua_vision_720") and (self.target:GetAbsOrigin() - self.parent:GetAbsOrigin()):Length2D() > self.range then
			self.target:RemoveModifierByName("modifier_troll_warlord_battle_trance_lua_vision_720")
		end
		return
	elseif self.target and self.target:HasModifier("modifier_troll_warlord_battle_trance_lua_vision_720") then
		self.target:RemoveModifierByName("modifier_troll_warlord_battle_trance_lua_vision_720")
	end
		local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_troll_warlord_int11")
		if abil == nil	then 
		self.parent:MoveToTargetToAttack(self.target)
		end
	if self.parent:GetAttackTarget() and self.parent:GetAttackTarget():IsAlive() and not self.parent:GetAttackTarget():IsAttackImmune() and not self.parent:GetAttackTarget():IsInvulnerable() and self.parent:CanEntityBeSeenByMyTeam(self.parent:GetAttackTarget()) then
		self.target = self.parent:GetAttackTarget()
		local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_troll_warlord_int11")
		if abil == nil	then 
			self.parent:MoveToTargetToAttack(self.target)
		end
		return
	end
	
	local non_hero_enemies = FindUnitsInRadius(self.parent:GetTeamNumber(), self.parent:GetAbsOrigin(), nil, self.range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE, FIND_CLOSEST, false)
	if #non_hero_enemies > 0 then
		for enemy = 1, #non_hero_enemies do
			local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_troll_warlord_int11")
			if abil == nil	then 
				self.parent:MoveToTargetToAttack(non_hero_enemies[enemy])
			end
			self.target = non_hero_enemies[enemy]
			self:SetStackCount(1)
			return
		end
	end
	
	if self.target then
		if self.target:HasModifier("modifier_troll_warlord_battle_trance_lua_vision_720") then
			self.target:RemoveModifierByName("modifier_troll_warlord_battle_trance_lua_vision_720")
		end	
		self.target	= nil
	end
	
	self:SetStackCount(0)
end

function modifier_troll_warlord_battle_trance_lua:OnDestroy()
	if self.target and self.target:HasModifier("modifier_troll_warlord_battle_trance_lua_vision_720") then
		self.target:RemoveModifierByName("modifier_troll_warlord_battle_trance_lua_vision_720")
	end	
end

function modifier_troll_warlord_battle_trance_lua:GetPriority()
	return 10
end

function modifier_troll_warlord_battle_trance_lua:CheckState()
	if self:GetParent() == self:GetCaster() then
		return {
			[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true
		}
	end
end

function modifier_troll_warlord_battle_trance_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_IGNORE_CAST_ANGLE,

		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_TOOLTIP,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}
end

function modifier_troll_warlord_battle_trance_lua:GetModifierProcAttack_Feedback( params )
	if IsServer() then
		local pass = false
		if params.target:GetTeamNumber()~=self:GetParent():GetTeamNumber() then
			if (not params.target:IsBuilding()) and (not params.target:IsOther()) then
				pass = true
			end
		end

		if pass then
			self.attack_record = params.record
		end
	end
end

function modifier_troll_warlord_battle_trance_lua:OnTakeDamage( params )
	if IsServer() then
		local pass = false
		if self.attack_record and params.record == self.attack_record then
			pass = true
			self.attack_record = nil
		end

		if pass then
			local heal = params.damage * self.lifesteal/100
			self:GetParent():Heal( math.min(heal, 2^30), self:GetAbility() )
			self:PlayEffects( self:GetParent() )
		end
	end
end

function modifier_troll_warlord_battle_trance_lua:PlayEffects( target )
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, target )
	ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() )
	ParticleManager:ReleaseParticleIndex( effect_cast )
end


function modifier_troll_warlord_battle_trance_lua:GetModifierAttackSpeedBonus_Constant()
	return self.attack_speed
end

function modifier_troll_warlord_battle_trance_lua:GetModifierMoveSpeedBonus_Percentage()
	return self.movement_speed
end

function modifier_troll_warlord_battle_trance_lua:GetModifierIgnoreCastAngle()
	return 1
end

function modifier_troll_warlord_battle_trance_lua:GetMinHealth()
	return 1
end

function modifier_troll_warlord_battle_trance_lua:OnTooltip()
	return self.lifesteal
end

function modifier_troll_warlord_battle_trance_lua:GetModifierBaseAttackTimeConstant()
	return self.bonus_bat
end

function modifier_troll_warlord_battle_trance_lua:GetModifierTotalDamageOutgoing_Percentage()
	if self:GetCaster():FindAbilityByName("special_bonus_unique_npc_dota_hero_troll_warlord_str50") then
		return 200
	end
end

----------------------------------------------------------------------------------------
modifier_troll_warlord_battle_trance_lua_vision_720 = class({})

function modifier_troll_warlord_battle_trance_lua_vision_720:IsPurgable()		return false end
function modifier_troll_warlord_battle_trance_lua_vision_720:IgnoreTenacity()	return false end

function modifier_troll_warlord_battle_trance_lua_vision_720:GetPriority()	return MODIFIER_PRIORITY_ULTRA end

function modifier_troll_warlord_battle_trance_lua_vision_720:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function modifier_troll_warlord_battle_trance_lua_vision_720:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION
	}
end

function modifier_troll_warlord_battle_trance_lua_vision_720:GetModifierProvidesFOWVision()
	return 1
end
