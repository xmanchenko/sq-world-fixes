LinkLuaModifier("modifier_weird_potion", "items/weird_potion.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_weird_potion_bonus", "items/weird_potion.lua", LUA_MODIFIER_MOTION_NONE )

item_weird_potion = class({})

function item_weird_potion:OnSpellStart()
    self.caster = self:GetCaster()
    local m = self.caster:FindModifierByName("modifier_weird_potion_bonus")
    if m then
        m:SetStackCount(m:GetStackCount() + self:GetCurrentCharges())
    else
        self.caster:AddNewModifier(self.caster, nil, "modifier_weird_potion_bonus", {}):SetStackCount(self:GetCurrentCharges())
    end
    self:SetCurrentCharges(0)
    self.caster:EmitSound("Bottle.Drink")
end

function item_weird_potion:GetIntrinsicModifierName()
    return "modifier_weird_potion"
end
--------------------------------------------------------------------------

modifier_weird_potion = class({})

function modifier_weird_potion:IsHidden()
    return false
end

function modifier_weird_potion:IsDebuff()
    return false
end

function modifier_weird_potion:IsPurgable()
    return false
end

function modifier_weird_potion:OnCreated()
    self:StartIntervalThink(0.45)
end

function modifier_weird_potion:OnIntervalThink()
if not IsServer() then return end
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local charges = self:GetAbility():GetCurrentCharges()
    local gold = caster:GetGold()
    local gold_bank = caster:FindModifierByName("modifier_gold_bank")
    gold = gold + gold_bank:GetStackCount()
    gold_bank:SetStackCount(0)
    if gold >= 72000 then
        count = ( gold - ( gold % 72000 ) ) / 72000 
        gold = gold % 72000
        caster:SetGold(0 , false) 
        caster:ModifyGoldFiltered( gold, true, 0 )
        ability:SetCurrentCharges(charges + count)
        caster:EmitSound("DOTA_Item.Hand_Of_Midas")
    end
    self:StartIntervalThink(0.45)
end








modifier_weird_potion_bonus = class({})
--Classifications template
function modifier_weird_potion_bonus:IsHidden()
    return true
end

function modifier_weird_potion_bonus:IsDebuff()
    return false
end

function modifier_weird_potion_bonus:IsPurgable()
    return false
end

function modifier_weird_potion_bonus:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_weird_potion_bonus:IsStunDebuff()
    return false
end

function modifier_weird_potion_bonus:RemoveOnDeath()
    return false
end

function modifier_weird_potion_bonus:DestroyOnExpire()
    return false
end

function modifier_weird_potion_bonus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
    }
end

function modifier_weird_potion_bonus:GetModifierBonusStats_Intellect()
    return self:GetStackCount() * 25
end

function modifier_weird_potion_bonus:GetModifierBonusStats_Strength()
    return self:GetStackCount() * 25
end

function modifier_weird_potion_bonus:GetModifierBonusStats_Agility()
    return self:GetStackCount() * 25
end