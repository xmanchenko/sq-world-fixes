modifier_talent_armor_curruption = class({})

function modifier_talent_armor_curruption:IsHidden()
	return true
end

function modifier_talent_armor_curruption:IsPurgable()
	return false
end

function modifier_talent_armor_curruption:RemoveOnDeath()
	return false
end

function modifier_talent_armor_curruption:OnCreated( kv )
	self.value = {0.1, 0.12, 0.14, 0.16, 0.18, 0.2}
	self.parent = self:GetParent()
	if not IsServer() then
		return
	end
	self:SetStackCount(1)
end

function modifier_talent_armor_curruption:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PROCATTACK_FEEDBACK,
	}
end

function modifier_talent_armor_curruption:GetModifierProcAttack_Feedback(data)
	data.target:AddNewModifier(self.parent, nil, "modifier_talent_armor_curruption_effect", {duration = 3, armor_curruption = self.value[self:GetStackCount()] * self:GetParent():GetLevel()})
end

modifier_talent_armor_curruption_effect = class({})

function modifier_talent_armor_curruption_effect:GetTexture()
	return "talents/agi1"
end
--Classifications template
function modifier_talent_armor_curruption_effect:IsHidden()
	return false
end

function modifier_talent_armor_curruption_effect:IsDebuff()
	return true
end

function modifier_talent_armor_curruption_effect:IsPurgable()
	return false
end

function modifier_talent_armor_curruption_effect:RemoveOnDeath()
	return true
end

function modifier_talent_armor_curruption_effect:DestroyOnExpire()
	return true
end

function modifier_talent_armor_curruption_effect:OnCreated(data)
	if not IsServer() then
		return
	end
	self.armor_curruption = data.armor_curruption
	self:SetHasCustomTransmitterData( true )
end

function modifier_talent_armor_curruption_effect:OnRefresh(data)
	if not IsServer() then
		return
	end
	self:SetDuration(3, true)
	self.armor_curruption = data.armor_curruption
	self:SendBuffRefreshToClients()
end

function modifier_talent_armor_curruption_effect:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
	}
end

function modifier_talent_armor_curruption_effect:GetModifierPhysicalArmorBonus()
	return self.armor_curruption * -1
end

function modifier_talent_armor_curruption_effect:AddCustomTransmitterData()
	return {
		armor_curruption = self.armor_curruption,
	}
end

function modifier_talent_armor_curruption_effect:HandleCustomTransmitterData( data )
	self.armor_curruption = data.armor_curruption
end
