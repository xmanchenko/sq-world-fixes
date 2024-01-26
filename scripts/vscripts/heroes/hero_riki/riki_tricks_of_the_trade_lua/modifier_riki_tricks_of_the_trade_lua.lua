modifier_riki_tricks_of_the_trade_lua  = class({})
function modifier_riki_tricks_of_the_trade_lua:IsPurgable() return false end
function modifier_riki_tricks_of_the_trade_lua:IsDebuff() return false end
function modifier_riki_tricks_of_the_trade_lua:IsHidden() return false end

function modifier_riki_tricks_of_the_trade_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_DAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
	}
end
function modifier_riki_tricks_of_the_trade_lua:GetModifierDamageOutgoing_Percentage()
	return -100 + self.dmg_perc
end
function modifier_riki_tricks_of_the_trade_lua:GetModifierBonusStats_Agility()
	return self.agi
end
function modifier_riki_tricks_of_the_trade_lua:CheckState()
	local state = {	
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = self.npc_dota_hero_riki_str12 == nil,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}
	return state
end

function modifier_riki_tricks_of_the_trade_lua:OnCreated()
	local ability = self:GetAbility()

	self.npc_dota_hero_riki_str12 = self:GetCaster():FindAbilityByName("npc_dota_hero_riki_str12")
	self.dmg_perc = ability:GetSpecialValueFor("dmg_perc")
	self.agi = ability:GetSpecialValueFor("extra_agility") / 100 * self:GetParent():GetAgility()
	self.radius = ability:GetSpecialValueFor("area_of_effect")
	self.attack_count = ability:GetSpecialValueFor("attack_count")
	self.target_count = ability:GetSpecialValueFor("target_count")
	local duration = ability:GetSpecialValueFor("channel_duration")
	if self:GetCaster():FindAbilityByName("npc_dota_hero_riki_agi12") then
		self.attack_count = self.attack_count + duration / (1 / (self:GetCaster():GetAttacksPerSecond(false) / 2))
	end
	if self:GetCaster():FindAbilityByName("npc_dota_hero_riki_agi13") then
		self.attack_count = self.attack_count * 2
	end
	self.current_attack_count = self.attack_count
	self.attack_speed = duration / self.attack_count
	self.current_interval = 0
	if IsServer() then
		local particle_start = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_tricks_cast.vpcf", PATTACH_WORLDORIGIN, nil)
        self.particle_radius = ParticleManager:CreateParticle("particles/units/heroes/hero_riki/riki_tricks.vpcf", PATTACH_WORLDORIGIN, nil)
        ParticleManager:SetParticleControl(self.particle_radius, 0, self:GetParent():GetAbsOrigin())
        ParticleManager:SetParticleControl(self.particle_radius, 1, Vector(self.radius, 0, self.radius))
        ParticleManager:SetParticleControl(self.particle_radius, 2, Vector(self.radius, 0, self.radius))
        self:AddParticle(self.particle_radius, false, false, -1, false, false)
		if self.npc_dota_hero_riki_str12 == nil then
			self:GetParent():AddNoDraw()
		end
		self:OnIntervalThink()
        self:StartIntervalThink(FrameTime())
	end
end

function modifier_riki_tricks_of_the_trade_lua:OnDestroy()
    if not IsServer() then return end
    FindClearSpaceForUnit(self:GetParent(), self:GetParent():GetAbsOrigin(), true)
	if self.npc_dota_hero_riki_str12 == nil then
    	self:GetParent():RemoveNoDraw()
	end
    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_riki/riki_tricks_end.vpcf", PATTACH_ABSORIGIN, self:GetParent())
    ParticleManager:ReleaseParticleIndex(particle)
end

function modifier_riki_tricks_of_the_trade_lua:OnIntervalThink()
    ParticleManager:SetParticleControl(self.particle_radius, 0, self:GetParent():GetAbsOrigin())
    self.current_interval = self.current_interval + FrameTime()
    if self.current_interval >= self.attack_speed then
        self.current_interval = 0
        local targets = FindUnitsInRadius(self:GetParent():GetTeamNumber(), self:GetParent():GetAbsOrigin(), nil, self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY , DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC , DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_NO_INVIS, FIND_ANY_ORDER , false)
        local attacks = 0
		for _, target in pairs(targets) do
			if target:IsAlive() and not target:IsAttackImmune() and attacks < self.target_count then
				attacks = attacks + 1
				self:GetParent():AddNewModifier(self:GetCaster(), self:GetAbility(), "modifier_riki_tricks_of_the_trade_attack_range_lua", {})
				self:GetParent():PerformAttack(target, true, true, true, false, false, false, false)
				self:GetParent():RemoveModifierByName("modifier_riki_tricks_of_the_trade_attack_range_lua")
			end
		end
        self.current_attack_count = self.current_attack_count - 1
        if self.current_attack_count <= 0 then
            self:Destroy()
        end
		local duration = self:GetAbility():GetSpecialValueFor("channel_duration")
    end
end

modifier_riki_tricks_of_the_trade_attack_range_lua = class({})
function modifier_riki_tricks_of_the_trade_attack_range_lua:IsPurgable() return false end
function modifier_riki_tricks_of_the_trade_attack_range_lua:IsDebuff() return false end
function modifier_riki_tricks_of_the_trade_attack_range_lua:IsHidden() return true end
function modifier_riki_tricks_of_the_trade_attack_range_lua:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
end
function modifier_riki_tricks_of_the_trade_attack_range_lua:GetModifierAttackRangeBonus()
	return self:GetAbility():GetSpecialValueFor("area_of_effect")
end