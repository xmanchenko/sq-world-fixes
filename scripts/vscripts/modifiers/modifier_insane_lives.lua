modifier_insane_lives = class({})

function modifier_insane_lives:IsHidden()
	return false
end

function modifier_insane_lives:IsPurgable()
	return false
end

function modifier_insane_lives:RemoveOnDeath()
	return false
end

function modifier_insane_lives:GetTexture()
    return "item_aegis"
end

function modifier_insane_lives:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_TOOLTIP
	}
end

function modifier_insane_lives:OnTooltip()
	return self:GetStackCount()
end
