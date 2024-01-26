AI = {}

AI.Init = function( self )
	-- Defer the initialization to first tick, to allow spawners to set state.
	self.aiState = {
		hAggroTarget = nil,
		flShoutRange = 1000,
		nWalkingMoveSpeed = 400,
		nAggroMoveSpeed = 400,
		flAcquisitionRange = 2000,
		vTargetWaypoint = nil,
		isAttacking = false,
	}
	self:SetContextThink( "init_think", function() 
		self.aiThink = aiThink
		self.RoamBetweenWaypoints = RoamBetweenWaypoints
		self:SetAcquisitionRange( self.aiState.flAcquisitionRange )
		self.bIsRoaring = false
		
		local tWaypoints = {}
		local nWaypointsPerRoamNode = 3
		local nMinWaypointSearchDistance = 0
		local nMaxWaypointSearchDistance = 3048

		while #tWaypoints < nWaypointsPerRoamNode do
			local vWaypoint = self:GetAbsOrigin() + RandomVector( RandomFloat( nMinWaypointSearchDistance, nMaxWaypointSearchDistance ) )
			if GridNav:CanFindPath( self:GetAbsOrigin(), vWaypoint ) then
				table.insert( tWaypoints, vWaypoint )
			end
		end
		self.aiState.tWaypoints = tWaypoints
		self:SetContextThink( "ai_base_creature.aiThink", Dynamic_Wrap( self, "aiThink" ), 0 )
	end, 0 )
end


function aiThink( self )
	if not self:IsAlive() then
		return 0.1
	end
	if GameRules:IsGamePaused() then
		return 0.1
	end

	return self:RoamBetweenWaypoints()
end




function RoamBetweenWaypoints( self )
	local gameTime = GameRules:GetGameTime()
	local aiState = self.aiState
	if aiState.vWaypoint ~= nil then
		local flRoamTimeLeft = aiState.flNextWaypointTime - gameTime
		if flRoamTimeLeft <= 0 then
			aiState.vWaypoint = nil
		end
	end
	if aiState.vWaypoint == nil then
	 aiState.vWaypoint = aiState.tWaypoints[ RandomInt( 1, #aiState.tWaypoints ) ]
	 aiState.flNextWaypointTime = gameTime + RandomFloat( 2, 4 )
		self:MoveToPositionAggressive( aiState.vWaypoint )
	end
	return RandomFloat( 0.5, 1.0 )
end

function Spawn( entityKeyValues )
    AI.Init( thisEntity )
end
