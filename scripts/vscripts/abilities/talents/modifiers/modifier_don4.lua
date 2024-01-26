modifier_don4 = class({})

function modifier_don4:IsHidden()
	return true
end

function modifier_don4:IsPurgable()
	return false
end

function modifier_don4:RemoveOnDeath()
	return false
end

function modifier_don4:OnCreated( kv )
    self.parent = self:GetParent()
	self:StartIntervalThink(30)
end

function modifier_don4:OnIntervalThink()
	if IsServer() then
		-- if self.parent:GetTotalGold() * 0.02 > 20000 then
		-- 	self.parent:ModifyGoldFiltered(20000, true, 0)
		-- else
			self.parent:ModifyGoldFiltered(self.parent:GetTotalGold() * 0.02, true, 0)
		-- end
	end
end