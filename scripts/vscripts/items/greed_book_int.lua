LinkLuaModifier("modifier_greed_book_int", "items/greed_book_int.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_greed_book_int_bonus", "items/greed_book_int.lua", LUA_MODIFIER_MOTION_NONE )

item_greed_int = class({})

function item_greed_int:GetIntrinsicModifierName()
    return "modifier_greed_book_int"
end

function item_greed_int:OnSpellStart()
    self.caster = self:GetCaster()
    local m = self.caster:FindModifierByName("modifier_greed_book_int_bonus")
    if m then
        m:SetStackCount(m:GetStackCount() + self:GetCurrentCharges())
    else
        self.caster:AddNewModifier(self.caster, nil, "modifier_greed_book_int_bonus", {}):SetStackCount(self:GetCurrentCharges())
    end
    self:SetCurrentCharges(0)
    self.caster:EmitSound("Item.TomeOfKnowledge")
end

----------------------------------------------------------

modifier_greed_book_int = class({})

function modifier_greed_book_int:IsHidden()
    return true
end

function modifier_greed_book_int:IsDebuff()
    return false
end

function modifier_greed_book_int:IsPurgable()
    return false
end

function modifier_greed_book_int:OnCreated()
    self:StartIntervalThink(1)
end

function modifier_greed_book_int:OnIntervalThink()
    local caster = self:GetCaster()
    local parent = self:GetParent()
    local ability = self:GetAbility()
    local charges = self:GetAbility():GetCurrentCharges()
    local gold = caster:GetGold()
    local gold_bank = caster:FindModifierByName("modifier_gold_bank")
    gold = gold + gold_bank:GetStackCount()
    gold_bank:SetStackCount(0)
    if gold >= 20000 then
        count = ( gold - ( gold % 20000 ) ) / 20000 
        gold = gold % 20000
        caster:SetGold(0 , false) 
        caster:ModifyGoldFiltered( gold, true, 0 )
        ability:SetCurrentCharges(charges + count)
        caster:EmitSound("DOTA_Item.Hand_Of_Midas")
    end
end

























modifier_greed_book_int_bonus = class({})
--Classifications template
function modifier_greed_book_int_bonus:IsHidden()
    return true
end

function modifier_greed_book_int_bonus:IsDebuff()
    return false
end

function modifier_greed_book_int_bonus:IsPurgable()
    return false
end

function modifier_greed_book_int_bonus:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_greed_book_int_bonus:IsStunDebuff()
    return false
end

function modifier_greed_book_int_bonus:RemoveOnDeath()
    return false
end

function modifier_greed_book_int_bonus:DestroyOnExpire()
    return false
end

function modifier_greed_book_int_bonus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
end

function modifier_greed_book_int_bonus:GetModifierBonusStats_Intellect()
    return self:GetStackCount() * 25
end