modifier_talent_magic_damage = class({})

function modifier_talent_magic_damage:IsHidden()
	return true
end

function modifier_talent_magic_damage:IsPurgable()
	return false
end

function modifier_talent_magic_damage:RemoveOnDeath()
	return false
end

function modifier_talent_magic_damage:OnCreated()
	self.value = {6, 8, 10, 12, 14, 16}
	self.parent = self:GetParent()
	if not IsServer() then
		return
	end
	self:SetStackCount(1)
end

function modifier_talent_magic_damage:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE,
	}
end

function modifier_talent_magic_damage:GetModifierSpellAmplify_Percentage()
	return self.value[self:GetStackCount()] * self:GetParent():GetLevel()
end