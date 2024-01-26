modifier_hero_arc_warden_buff_1 = class({})

function modifier_hero_arc_warden_buff_1:IsHidden()
    return true
end

function modifier_hero_arc_warden_buff_1:IsPurgable()
    return false
end

function modifier_hero_arc_warden_buff_1:RemoveOnDeath()
    return false
end

function modifier_hero_arc_warden_buff_1:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_hero_arc_warden_buff_1:GetModifierSpellAmplify_Percentage()
	return self:GetParent():GetLevel() * 5
end