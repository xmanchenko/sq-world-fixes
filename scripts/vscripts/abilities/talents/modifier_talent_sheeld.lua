modifier_talent_sheeld = class({})

function modifier_talent_sheeld:IsHidden()
	return true
end

function modifier_talent_sheeld:IsPurgable()
	return false
end

function modifier_talent_sheeld:RemoveOnDeath()
	return false
end

function modifier_talent_sheeld:OnCreated( kv )
	if IsServer() then
		self:SetStackCount(1)
	end
	self.value = {7.5, 10, 12.5, 15, 17.5, 20}
	self.is_broken = false
	self.sheeld_max = self.value[self:GetStackCount()] * 0.01 * self:GetParent():GetMaxHealth()
	self.sheeld_regen = self.sheeld_max / 25 * 0.03
	self.current_sheeld_health = self.value[self:GetStackCount() or 1] * 0.01 * self:GetParent():GetMaxHealth()
	if IsClient() then
		self:StartIntervalThink(0.03)
	end
	if not IsServer() then
		return
	end
	ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap(self, "LevelUP"), self)
	self.iPlayerID = self:GetParent():GetPlayerID()
	self:SetHasCustomTransmitterData( true )
end

function modifier_talent_sheeld:OnRefresh( kv )
	self.sheeld_max = self.value[self:GetStackCount()] * 0.01 * self:GetParent():GetMaxHealth()
	self.sheeld_regen = self.sheeld_max / 25 * 0.03
end

function modifier_talent_sheeld:OnStackCountChanged()
	self.sheeld_max = self.value[self:GetStackCount()] * 0.01 * self:GetParent():GetMaxHealth()
	self.sheeld_regen = self.sheeld_max / 25 * 0.03
end

function modifier_talent_sheeld:LevelUP(data)
	if (data.player_id == self.iPlayerID or data.PlayerID == self.iPlayerID) and self then
		self:SetStackCount(self:GetStackCount())
		self.is_broken = true
		self:StartIntervalThink(0.03)
	end
end

function modifier_talent_sheeld:OnIntervalThink()
	if not self.is_broken then
		self:StartIntervalThink(0.03)
		self.is_broken = true
		self:SendBuffRefreshToClients()
		return
	end
	self.current_sheeld_health = self.current_sheeld_health + self.sheeld_regen
	if self.current_sheeld_health >= self.sheeld_max then
		self.current_sheeld_health = self.sheeld_max
		self.is_broken = false
		self:SendBuffRefreshToClients()
		self:StartIntervalThink(-1)
	end
end

if IsClient() then
	function modifier_talent_sheeld:OnIntervalThink()
		if not self.is_broken then
			return
		end
		self.current_sheeld_health = self.current_sheeld_health + self.sheeld_regen
		if self.current_sheeld_health >= self.sheeld_max then
			self.current_sheeld_health = self.sheeld_max
		end
	end
end

function modifier_talent_sheeld:DeclareFunctions()
	return {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_CONSTANT
	}
end

function modifier_talent_sheeld:GetModifierIncomingDamageConstant(data)
    if IsClient() then
        if data.report_max then
            return self.sheeld_max
        else
            return self.current_sheeld_health
        end
    end
	if self.is_broken then
		return 0
	end
    if not self.is_broken and self.current_sheeld_health > 0 then
        local remain = self.current_sheeld_health - data.damage
        if remain > 0 then
            self.current_sheeld_health = self.current_sheeld_health - data.damage
			self.is_broken = false
			self:StartIntervalThink(0.03)
			self:SetStackCount(self:GetStackCount())
			self:SendBuffRefreshToClients()
			return -data.damage
        else
			self.is_broken = true
			self:StartIntervalThink(0.03)
            self.current_sheeld_health = 0
			self:SetStackCount(self:GetStackCount())
			self:SendBuffRefreshToClients()
			return -self.current_sheeld_health
        end
    end	
end

function modifier_talent_sheeld:AddCustomTransmitterData()
	return {
		current_sheeld_health = self.current_sheeld_health,
		sheeld_max = self.sheeld_max,
		is_broken = self.is_broken,
	}
end

function modifier_talent_sheeld:HandleCustomTransmitterData( data )
	self.current_sheeld_health = data.current_sheeld_health
	self.sheeld_max = data.sheeld_max
	self.is_broken = data.is_broken
end
