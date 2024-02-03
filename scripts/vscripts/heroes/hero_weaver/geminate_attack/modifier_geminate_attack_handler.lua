modifier_geminate_attack_handler = class({
    IsHidden = function()
        return false
    end,
    IsPurgable = function()
        return false
    end,
    GetAttributes = function()
        return MODIFIER_ATTRIBUTE_MULTIPLE + MODIFIER_ATTRIBUTE_PERMANENT
    end,
    DeclareFunctions = function()
        return {
            
        }
    end
})

function modifier_geminate_attack_handler:OnCreated( kv )
    if not IsServer() then
        return
    end
    self.ability = self:GetAbility()
    self.bonus_damage = self.ability:GetSpecialValueFor("bonus_damage")
    if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_agi7") then
        self.bonus_damage = self.bonus_damage + (self:GetCaster():GetAverageTrueAttackDamage(self:GetCaster()) * 0.4)
    end
    self.caster = self.ability:GetCaster()
    self.target = self:GetParent()
    self:StartIntervalThink(self.ability:GetSpecialValueFor("delay"))
end

function modifier_geminate_attack_handler:OnIntervalThink()
    if (self.caster:IsAlive()) then
        -- self.caster:AddNewModifier(self.caster, self.ability, "modifier_geminate_attack_bonus_damage", {bonus_damage = self.bonus_damage})
        -- self.caster:PerformAttack(self.target, true, true, true, false, true, false, false)
        -- self.caster:RemoveModifierByName("modifier_geminate_attack_bonus_damage")
        self:ProjectileShot()
    end
    local stacks = self:GetStackCount() - 1
    if (stacks < 1) then
        self:Destroy()
    else
        self:SetStackCount(stacks)
    end
end

function modifier_geminate_attack_handler:ProjectileShot()
	if not IsServer() then return end
	
		local projectile =
		{
			Target = self.target,
			Source = self:GetCaster(),
			Ability = self:GetAbility(),
			EffectName = self:GetCaster():GetRangedProjectileName(),
			bDodgeable = true,
			bProvidesVision = false,
			iMoveSpeed = self:GetCaster():GetProjectileSpeed(),
			flExpireTime = GameRules:GetGameTime() + 60,
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
		}
				

	ProjectileManager:CreateTrackingProjectile(projectile)
end

modifier_geminate_attack_bonus_damage = class({})

function modifier_geminate_attack_bonus_damage:OnCreated(kv)
    self.bonus_damage = kv.bonus_damage
    if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_int8") then
        self:OnDestroy()
    end
end

function modifier_geminate_attack_bonus_damage:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE
    }
end

function modifier_geminate_attack_bonus_damage:GetModifierPreAttack_BonusDamage()
    return self.bonus_damage
end