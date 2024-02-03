LinkLuaModifier("modifier_geminate_attack", "heroes/hero_weaver/geminate_attack/modifier_geminate_attack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_geminate_attack_handler", "heroes/hero_weaver/geminate_attack/modifier_geminate_attack_handler", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_geminate_attack_bonus_damage", "heroes/hero_weaver/geminate_attack/modifier_geminate_attack_handler", LUA_MODIFIER_MOTION_NONE)

geminate_attack_lua = class({
    GetIntrinsicModifierName = function()
        return "modifier_geminate_attack"
    end,
})

function geminate_attack_lua:OnUpgrade()
    if self:GetLevel() == 1 then
        self:ToggleAutoCast()
    end
end

function geminate_attack_lua:OnProjectileHit_ExtraData(target, vLocation, extraData)
	if IsServer() then
        local bonus_damage = self:GetSpecialValueFor("bonus_damage")
        if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_agi7") then
            bonus_damage = bonus_damage + (self:GetCaster():GetAverageTrueAttackDamage(self:GetCaster()) * 0.4)
        end
        if self:GetCaster():FindAbilityByName("npc_dota_hero_weaver_int8") then
            local damage_table = {
                victim = target,
                damage = bonus_damage,
                damage_type = DAMAGE_TYPE_MAGICAL,
                damage_flags = DOTA_DAMAGE_FLAG_NONE,
                attacker = self:GetCaster(),
                ability = self
            }
            ApplyDamage(damage_table)
            SendOverheadEventMessage(nil, OVERHEAD_ALERT_BONUS_SPELL_DAMAGE, target, bonus_damage, nil)
        else
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_geminate_attack_bonus_damage", {bonus_damage = bonus_damage})
        end
        self:GetCaster():PerformAttack(target, true, true, true, false, false, false, false)
        self:GetCaster():RemoveModifierByName("modifier_geminate_attack_bonus_damage")
	end
end