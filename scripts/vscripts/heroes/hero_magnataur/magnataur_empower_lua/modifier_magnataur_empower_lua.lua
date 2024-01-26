modifier_magnataur_empower_lua = class({})

function modifier_magnataur_empower_lua:IsHidden()
    return true
end

function modifier_magnataur_empower_lua:IsPurgable()
    return false
end

function modifier_magnataur_empower_lua:RemoveOnDeath()
    return false
end

function modifier_magnataur_empower_lua:OnCreated( kv )
    if not IsServer() then return end
    self:StartIntervalThink(0.2)
end

function modifier_magnataur_empower_lua:OnIntervalThink()
    if self:GetCaster():HasModifier("modifier_hero_magnataur_buff_1") and self:GetAbility():IsFullyCastable() and self:GetAbility():GetAutoCastState() then
        self:GetCaster():SetCursorCastTarget(self:GetCaster())
        self:GetAbility():OnSpellStart()
        self:GetAbility():UseResources(true, false, false, true)
    end
end