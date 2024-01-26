modifier_ursa_earthshock_movement = class({})

function modifier_ursa_earthshock_movement:OnCreated()
    if not IsServer() then return end
    local parent = self:GetParent()
    self.distance = self:GetAbility():GetSpecialValueFor("hop_distance")
    self.direction = parent:GetForwardVector()
    self.speed = self:GetAbility():GetSpecialValueFor("speed") * FrameTime()
    self.maxHeight = 100

    self:StartMotionController()
end

function modifier_ursa_earthshock_movement:OnDestroy()
    if not IsServer() then return end
    local parent = self:GetParent()
    local parentPos = parent:GetAbsOrigin()
    FindClearSpaceForUnit(parent, parentPos, true)

    GridNav:DestroyTreesAroundPoint(parentPos, parent:GetAttackRange(), false)
    
    self:GetAbility():EarthShock()

    self:StopMotionController()
end

function modifier_ursa_earthshock_movement:DoControlledMotion()
    if self:GetParent():IsNull() then return end
    local parent = self:GetParent()
    self.distanceTraveled =  self.distanceTraveled or 0
    if parent:IsAlive() and self.distanceTraveled < self.distance then
        local newPos = GetGroundPosition(parent:GetAbsOrigin(), parent) + self.direction * self.speed
        local height = GetGroundHeight(parent:GetAbsOrigin(), parent)
        newPos.z = height + self.maxHeight * math.sin( (self.distanceTraveled/self.distance) * math.pi )
        parent:SetAbsOrigin( newPos )
        
        self.distanceTraveled = self.distanceTraveled + self.speed
    else
        FindClearSpaceForUnit(parent, parent:GetAbsOrigin(), true)
        self:Destroy()
        return nil
    end       
    
end

function modifier_ursa_earthshock_movement:CheckState()
	return {[MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
			[MODIFIER_STATE_NO_UNIT_COLLISION] = true}
end

function modifier_ursa_earthshock_movement:DeclareFunctions()
	return {MODIFIER_EVENT_ON_ORDER}
end

function modifier_ursa_earthshock_movement:OnOrder( params )
	if params.unit == self:GetParent() then
		if params.order_type == DOTA_UNIT_ORDER_STOP or params.order_type == DOTA_UNIT_ORDER_HOLD_POSITION then
			self:Destroy()
			params.unit:RemoveGesture(ACT_DOTA_CAST_ABILITY_1)
			params.unit:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 2)
		end
	end
end

function modifier_ursa_earthshock_movement:IsHidden()
	return true
end