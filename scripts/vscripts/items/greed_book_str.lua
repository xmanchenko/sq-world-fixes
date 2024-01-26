LinkLuaModifier("modifier_greed_book_str", "items/greed_book_str.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("modifier_greed_book_str_bonus", "items/greed_book_str.lua", LUA_MODIFIER_MOTION_NONE )

item_greed_str = class({})

function item_greed_str:GetIntrinsicModifierName()
    return "modifier_greed_book_str"
end

function item_greed_str:OnSpellStart()
    self.caster = self:GetCaster()
    local m = self.caster:FindModifierByName("modifier_greed_book_str_bonus")
    if m then
        m:SetStackCount(m:GetStackCount() + self:GetCurrentCharges())
    else
        self.caster:AddNewModifier(self.caster, nil, "modifier_greed_book_str_bonus", {}):SetStackCount(self:GetCurrentCharges())
    end
    self:SetCurrentCharges(0)
    self.caster:EmitSound("Item.TomeOfKnowledge")
end

------------------------------------------------------------------------------------

modifier_greed_book_str = class({})

function modifier_greed_book_str:IsHidden()
    return true
end

function modifier_greed_book_str:IsDebuff()
    return false
end

function modifier_greed_book_str:IsPurgable()
    return false
end

function modifier_greed_book_str:OnCreated()
    self:StartIntervalThink(1)
end

function modifier_greed_book_str:OnIntervalThink()
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



















modifier_greed_book_str_bonus = class({})
--Classifications template
function modifier_greed_book_str_bonus:IsHidden()
    return true
end

function modifier_greed_book_str_bonus:IsDebuff()
    return false
end

function modifier_greed_book_str_bonus:IsPurgable()
    return false
end

function modifier_greed_book_str_bonus:IsPurgeException()
    return false
end

-- Optional Classifications
function modifier_greed_book_str_bonus:IsStunDebuff()
    return false
end

function modifier_greed_book_str_bonus:RemoveOnDeath()
    return false
end

function modifier_greed_book_str_bonus:DestroyOnExpire()
    return false
end

function modifier_greed_book_str_bonus:DeclareFunctions()
    return {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS
    }
end

function modifier_greed_book_str_bonus:GetModifierBonusStats_Strength()
    return self:GetStackCount() * 25
end