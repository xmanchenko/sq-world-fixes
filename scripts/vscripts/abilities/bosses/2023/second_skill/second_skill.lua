LinkLuaModifier("modifier_hero_destroyer_second_skill", "abilities/bosses/2023/second_skill/second_skill", LUA_MODIFIER_MOTION_VERTICAL)
LinkLuaModifier("modifier_hero_destroyer_second_skill_thinker", "abilities/bosses/2023/second_skill/second_skill", LUA_MODIFIER_MOTION_VERTICAL)
LinkLuaModifier("modifier_hero_destroyer_second_skill_burn", "abilities/bosses/2023/second_skill/second_skill", LUA_MODIFIER_MOTION_VERTICAL)

hero_destroyer_second_skill = class({})

function hero_destroyer_second_skill:OnSpellStart()
	self.mod_caster = self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_hero_destroyer_second_skill", {duration = 4})
end

------------------------------------------------------------------------------

modifier_hero_destroyer_second_skill = class({})

function modifier_hero_destroyer_second_skill:IsHidden()
    return true
end

function modifier_hero_destroyer_second_skill:OnCreated()
	self.interval = 0.7
	self.radius = self:GetAbility():GetSpecialValueFor("radius")
	self:StartIntervalThink(self.interval)
end


function modifier_hero_destroyer_second_skill:OnIntervalThink()
if not IsServer() then return end
	local caster_pos = self:GetCaster():GetAbsOrigin()
		for i = 1, 2 do
			local angle = RandomInt(0, 360)
			local variance = RandomInt(-self.radius, self.radius)
			local dy = math.sin(angle) * variance
			local dx = math.cos(angle) * variance
			local target_point = Vector(caster_pos.x + dx, caster_pos.y + dy, caster_pos.z)
			
			CreateModifierThinker( self:GetCaster(), self:GetAbility(), "modifier_hero_destroyer_second_skill_thinker", {}, target_point, self:GetCaster():GetTeamNumber(), false)
		
		self:StartIntervalThink(-1)
		self:StartIntervalThink(self.interval)
	end
end

--------------------------------------------------------------------------

modifier_hero_destroyer_second_skill_thinker = class({})

function modifier_hero_destroyer_second_skill_thinker:IsHidden()
	return true
end

function modifier_hero_destroyer_second_skill_thinker:OnCreated( kv )
	if IsServer() then
		self.caster_origin = self:GetCaster():GetOrigin()
		self.parent_origin = self:GetParent():GetOrigin()
		self.direction = self.parent_origin - self.caster_origin
		self.direction.z = 0
		self.direction = self.direction:Normalized()

		self.delay = 1
		self.radius = 300
		self.distance = 0
		self.speed = 0
		self.vision = 0
		self.vision_duration = 0
		
		self.interval = 1
		self.duration = 1
		local damage = self:GetAbility():GetSpecialValueFor( "damage" )

		self.fallen = false

		self:GetParent():SetDayTimeVisionRange( self.vision )
		self:GetParent():SetNightTimeVisionRange( self.vision )
		self:StartIntervalThink( self.delay )
		self:PlayEffects1()
	end
end

function modifier_hero_destroyer_second_skill_thinker:OnRefresh( kv )
	
end

function modifier_hero_destroyer_second_skill_thinker:OnDestroy( kv )
	if IsServer() then
		AddFOWViewer( self:GetCaster():GetTeamNumber(), self:GetParent():GetOrigin(), self.vision, self.vision_duration, false)

		local sound_loop = "Hero_Invoker.ChaosMeteor.Loop"
		-- local sound_stop = "Hero_Invoker.ChaosMeteor.Destroy"
		StopSoundOn( sound_loop, self:GetParent() )
		EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), sound_stop, self:GetCaster() )
		UTIL_Remove( self:GetParent() )
	end
end

function modifier_hero_destroyer_second_skill_thinker:OnIntervalThink()
	if not self.fallen then
		self.fallen = true
		self:StartIntervalThink( self.interval )
		self:Burn()
		
		self:PlayEffects2()
	else
		self:Move_Burn()
	end
end

function modifier_hero_destroyer_second_skill_thinker:Burn()
	local enemies = FindUnitsInRadius(
		self:GetCaster():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		self.radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,enemy in pairs(enemies) do
		self.damageTable = {
			victim = enemy,
			attacker = self:GetCaster(),
			damage = self:GetAbility():GetSpecialValueFor( "damage" ) * enemy:GetMaxHealth()/100,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(),
		}
		
		ApplyDamage( self.damageTable )

		-- add modifier
		enemy:AddNewModifier(
			self:GetCaster(), -- player source
			self:GetAbility(), -- ability source
			"modifier_hero_destroyer_second_skill_burn", -- modifier name
			{ duration = self.duration } -- kv
		)
	end
end

function modifier_hero_destroyer_second_skill_thinker:Move_Burn()
	local parent = self:GetParent()

	local target = self.direction*self.speed*self.interval
	parent:SetOrigin( parent:GetOrigin() + target )

	self:Burn()
	
	--if (parent:GetOrigin() - self.parent_origin + target):Length2D()>self.distance then
		self:Destroy()
		return
	--end
end


function modifier_hero_destroyer_second_skill_thinker:PlayEffects1()
	local particle_cast = "particles/destr_snow.vpcf"
	local sound_impact = "Hero_Invoker.ChaosMeteor.Cast"

	local height = 1000
	local height_target = -0

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self.caster_origin + Vector( 0, 0, height ) )
	ParticleManager:SetParticleControl( effect_cast, 1, self.parent_origin + Vector( 0, 0, height_target) )
	ParticleManager:SetParticleControl( effect_cast, 2, Vector( self.delay, 0, 0 ) )
	ParticleManager:ReleaseParticleIndex( effect_cast )

	EmitSoundOnLocationWithCaster( self.caster_origin, sound_impact, self:GetCaster() )
end

function modifier_hero_destroyer_second_skill_thinker:PlayEffects2()
	local particle_cast = "particles/destr_snow_i.vpcf"
	local sound_impact = "Hero_Invoker.ChaosMeteor.Impact"
	-- local sound_loop = "Hero_Invoker.ChaosMeteor.Loop"

	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent_origin )
	ParticleManager:SetParticleControlForward( effect_cast, 0, self.direction )
	ParticleManager:SetParticleControl( effect_cast, 1, self.direction * self.speed )

	self:AddParticle(
		effect_cast,
		false,
		false,
		-1,
		false,
		false
	)

	EmitSoundOnLocationWithCaster( self.parent_origin, sound_impact, self:GetCaster() )
	EmitSoundOn( sound_loop, self:GetParent() )
end


------------------------------------------------------------------

modifier_hero_destroyer_second_skill_burn = class({})

function modifier_hero_destroyer_second_skill_burn:IsHidden()
	return false
end

function modifier_hero_destroyer_second_skill_burn:IsDebuff()
	return true
end

function modifier_hero_destroyer_second_skill_burn:IsStunDebuff()
	return false
end

function modifier_hero_destroyer_second_skill_burn:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE 
end

function modifier_hero_destroyer_second_skill_burn:IsPurgable()
	return true
end

function modifier_hero_destroyer_second_skill_burn:OnCreated( kv )
	if IsServer() then
		local damage = self:GetAbility():GetSpecialValueFor( "burn_dps" )
		local delay = 1
		self.damageTable = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self:GetAbility(), --Optional.
		}

		self:StartIntervalThink( delay )
	end
end

function modifier_hero_destroyer_second_skill_burn:OnRefresh( kv )
	
end

function modifier_hero_destroyer_second_skill_burn:OnDestroy( kv )

end

function modifier_hero_destroyer_second_skill_burn:OnIntervalThink()
	ApplyDamage( self.damageTable )

	-- local sound_tick = "Hero_Invoker.ChaosMeteor.Damage"
	-- EmitSoundOn( sound_tick, self:GetParent() )
end

function modifier_hero_destroyer_second_skill_burn:GetEffectName()
	return "particles/units/heroes/hero_invoker/invoker_chaos_meteor_burn_debuff.vpcf"
end

function modifier_hero_destroyer_second_skill_burn:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
