modifier_health_voker = class({})

function modifier_health_voker:IsHidden()
	return false
end

function modifier_health_voker:GetTexture()
	return "item_aegis"
end

function modifier_health_voker:IsPermanent()
	return true
end

function modifier_health_voker:IsPurgable()
	return false
end


function modifier_health_voker:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_DEATH,
	}
	return funcs
end

function modifier_health_voker:OnCreated()
	if IsServer() then
		self.armor = self:GetParent():GetPhysicalArmorBaseValue()
       	self.reincarnate_time = 0.1
    end
end

function modifier_health_voker:ReincarnateTime()
		local nPlayerID
    if self:GetParent().GetPlayerOwnerID then
       nPlayerID = self:GetParent():GetPlayerOwnerID()
    end

    if  nPlayerID  and PlayerResource:GetConnectionState(nPlayerID) == DOTA_CONNECTION_STATE_ABANDONED then
        return nil
    end
end

function modifier_health_voker:OnDeath(keys)
	if IsServer() then
	   if keys.unit == self:GetParent() then
			local nStackCount = self:GetStackCount()
			if nStackCount>0 then
			self:SetStackCount(nStackCount-1)
			
          	  local hCaster = self:GetParent()
          	  local hAbility = self:GetAbility()
          	  local flReincarnateTime = self.reincarnate_time
		      Timers:CreateTimer({ endTime = flReincarnateTime, 
				    callback = function()
				    local nParticle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, hCaster)
					ParticleManager:SetParticleControl(nParticle, 1, Vector(0, 0, 0))
					ParticleManager:SetParticleControl(nParticle, 3, hCaster:GetAbsOrigin())
					ParticleManager:ReleaseParticleIndex(nParticle)
					local point = keys.unit:GetAbsOrigin()
					keys.unit:SetAbsOrigin( point )
					FindClearSpaceForUnit(keys.unit, point, false)
					keys.unit:Stop()
					keys.unit:RespawnUnit()
					if keys.unit:GetBaseMagicalResistanceValue() >= 99 then
						if keys.unit:FindItemInInventory("item_pipe_lua") then
							keys.unit:SetBaseMagicalResistanceValue(96)
						else
							invkeys.unitoker:SetBaseMagicalResistanceValue(98)
						end
					end
					if keys.unit:GetPhysicalArmorBaseValue() > self.armor then
						keys.unit:SetPhysicalArmorBaseValue(self.armor)
					end
				end})
			end
			if nStackCount <=0  then
			self:Destroy()
			end
		end
	end
end