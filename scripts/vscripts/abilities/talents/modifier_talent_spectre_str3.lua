modifier_talent_spectre_str3 = class({})

function modifier_talent_spectre_str3:IsHidden()
	return true
end

function modifier_talent_spectre_str3:IsPurgable()
	return false
end

function modifier_talent_spectre_str3:RemoveOnDeath()
	return false
end

function modifier_talent_spectre_str3:OnCreated( kv )
	self.value = {0.5, 1.0, 1.5, 2, 2.5, 3}
	if not IsServer() then
		return
	end
	self:SetStackCount(1)
end

function modifier_talent_spectre_str3:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
	}
end

function modifier_talent_spectre_str3:GetModifierBonusStats_Strength()
	return self.value[self:GetStackCount()] * self:GetParent():GetLevel()
end