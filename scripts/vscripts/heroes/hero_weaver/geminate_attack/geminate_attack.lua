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