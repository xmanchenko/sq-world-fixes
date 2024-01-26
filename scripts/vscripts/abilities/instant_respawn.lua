instant_respawn = class({})

function instant_respawn:Spawn()
    if not IsServer() then
        return
    end
    if self.first_time == nil then
        self.first_time = 1
        self.spawn_pos = self:GetCaster():GetAbsOrigin()
        local calss = self
        Timers:CreateTimer(0.03,function()
            if self.spawn_pos:Length2D() < 10 then
                calss.spawn_pos = self:GetCaster():GetAbsOrigin()
            else
                return 0.03
            end
        end)
    end
end

function instant_respawn:OnOwnerDied()
    self:GetCaster():SetContextThink("respawn", function(unit)         
        unit:RespawnUnit()
        unit:SetAbsOrigin(self.spawn_pos)
    end, 0.4)
end