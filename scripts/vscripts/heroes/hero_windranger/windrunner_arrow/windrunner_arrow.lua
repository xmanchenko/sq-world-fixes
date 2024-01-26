LinkLuaModifier( "modifier_ult_armor", "heroes/hero_windranger/modifier_ult_armor", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_windranger_arrow", "heroes/hero_windranger/windrunner_arrow/windrunner_arrow", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_stop", "heroes/hero_windranger/modifier_stop", LUA_MODIFIER_MOTION_NONE )

windrunner_arrow = class({})

function windrunner_arrow:GetManaCost(iLevel)         
	if self:GetCaster():FindAbilityByName("npc_dota_hero_windrunner_int7")  ~= nil then 
		return 120 + math.min(65000, self:GetCaster():GetIntellect() / 45)
	end
	return 150 + math.min(65000, self:GetCaster():GetIntellect() / 30)
end

function windrunner_arrow:OnSpellStart()
	local direction = (self:GetCaster():GetCursorPosition() - self:GetCaster():GetAbsOrigin()):Normalized()
	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_windranger_arrow", {duration = self:GetSpecialValueFor("duration"), direction_x = direction.x, direction_y = direction.y})
	EmitSoundOn("Ability.Focusfire", self:GetCaster())
	self:GetSpecialValue()
	local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_windrunner_str6")             
	if abil ~= nil then 
		self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_ult_armor",{ duration = self:GetSpecialValueFor("duration") })
	end
end

function windrunner_arrow:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
	if hTarget ~= nil and not hTarget:IsMagicImmune() and not hTarget:IsInvulnerable() then	
		if ExtraData.abil then
			hTarget:AddNewModifier(self:GetCaster(),self,"modifier_stop",{ duration = 0.2 })
		end
		ApplyDamage({
			victim = hTarget,
			attacker = self:GetCaster(),
			damage = self.damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		})
	end
	return false
end

function windrunner_arrow:GetSpecialValue()
    self.duration = self:GetSpecialValueFor("duration")
    self.scale = self:GetSpecialValueFor("scale")
    self.damage = self:GetSpecialValueFor("damage")
		local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_windrunner_int10")             
		if abil ~= nil then 
		self.duration = 5
		end
			
		local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_windrunner_int9")             
		if abil ~= nil then 
		self.damage = self:GetCaster():GetIntellect()
		end
		
		local abil = self:GetCaster():FindAbilityByName("npc_dota_hero_windrunner_int8")             
		if abil ~= nil then 
		self.damage = self.damage + (self:GetCaster():GetIntellect()/2)
		end		
end

modifier_windranger_arrow = class({})
--Classifications template
function modifier_windranger_arrow:IsHidden()
	return false
end

function modifier_windranger_arrow:IsDebuff()
	return false
end

function modifier_windranger_arrow:IsPurgable()
	return false
end

function modifier_windranger_arrow:IsPurgeException()
	return false
end

-- Optional Classifications
function modifier_windranger_arrow:IsStunDebuff()
	return false
end

function modifier_windranger_arrow:RemoveOnDeath()
	return true
end

function modifier_windranger_arrow:DestroyOnExpire()
	return true
end

function modifier_windranger_arrow:OnCreated(data)
	if not IsServer() then
		return
	end
	self.abil = self:GetCaster():FindAbilityByName("npc_dota_hero_windrunner_str7") ~= nil         
	self.direction = Vector(data.direction_x, data.direction_y, 0)
	self:StartIntervalThink(0.2)
	self:OnIntervalThink()
end

function modifier_windranger_arrow:OnIntervalThink()
    local info = {
        EffectName = "particles/econ/items/windrunner/windrunner_weapon_sparrowhawk/windrunner_spell_powershot_sparrowhawk.vpcf",
        Ability = self:GetAbility(),
        fStartRadius = 200,
        fEndRadius = 200,
        vVelocity = self.direction * 2000,
        fDistance = 2000,
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		ExtraData = {abil = self.abil},
    }
	info.vSpawnOrigin = self:GetCaster():GetOrigin() + RandomVector(200)
	ProjectileManager:CreateLinearProjectile(info)
end