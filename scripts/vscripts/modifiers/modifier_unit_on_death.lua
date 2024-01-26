LinkLuaModifier( "modifier_unit_on_death", "modifiers/modifier_unit_on_death", LUA_MODIFIER_MOTION_NONE )

----------------------------------------------------------------

if modifier_unit_on_death == nil then modifier_unit_on_death = class({}) end

function modifier_unit_on_death:IsHidden()
	return true
end

function modifier_unit_on_death:IsPurgable()
	return false
end

function modifier_unit_on_death:RemoveOnDeath()
	return false
end

function modifier_unit_on_death:OnCreated(kv)
	if not IsServer() then return end
	self:GetParent():SetUnitCanRespawn(true)
	self.spawnPos = Vector(kv.posX, kv.posY, kv.posZ)
	self.unitName = kv.name
end

function modifier_unit_on_death:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_DEATH
	}
	return funcs
end

creep_respawn_20 = {"forest_creep_mini_1","forest_creep_big_1","forest_creep_mini_2","forest_creep_big_2","forest_creep_mini_3","forest_creep_big_3","dust_creep_1","dust_creep_2","dust_creep_3","dust_creep_4","dust_creep_5","dust_creep_6","cemetery_creep_1","cemetery_creep_2","cemetery_creep_3","cemetery_creep_4","swamp_creep_1","swamp_creep_2","swamp_creep_3","swamp_creep_4","snow_creep_1","snow_creep_2","snow_creep_3","snow_creep_4","last_creep_1","last_creep_2","last_creep_3","last_creep_4","magma_creep_1","magma_creep_2"}
creep_respawn_8 = {"village_creep_1","village_creep_2","village_creep_3"}
creep_respawn_5 = {"mines_creep_1","mines_creep_2","mines_creep_3"}

function modifier_unit_on_death:OnDeath(event)
    if not IsServer() then return end
    local creep = event.unit
    if creep ~= self:GetParent() then return end
	
	if creep.donate then
		amountTime = 1
		self:GetParent():AddNoDraw()
		self:StartIntervalThink(amountTime)
		return
	end

	if self.unitName == "farm_zone_dragon" then
		amountTime = 0.2
		self:GetParent():AddNoDraw()
		self:StartIntervalThink(amountTime)
		return
	end

	if _G.kill_invoker == true then return end
	
	for _,t in ipairs(creep_respawn_8) do
		if t and t == self.unitName then 			 
			amountTime = 4
			self:GetParent():AddNoDraw()
			self:StartIntervalThink(amountTime)
			return
		end
    end

	for _,t in ipairs(creep_respawn_5) do
		if t and t == self.unitName then 
			amountTime = 2
			self:GetParent():AddNoDraw()
			self:StartIntervalThink(amountTime)
			return
		end
    end

	for _,t in ipairs(creep_respawn_20) do
		if t and t == self.unitName then 
			amountTime = 10
			self:GetParent():AddNoDraw()
			self:StartIntervalThink(amountTime)
			return
		end
    end
end

function modifier_unit_on_death:OnIntervalThink(amountTime)
	-- if _G.kill_invoker == false then
		local unit = CreateUnitByName(self.unitName, self.spawnPos, true, nil, nil, DOTA_TEAM_BADGUYS)
		Rules:difficality_modifier(unit)
		unit:AddNewModifier(unit, nil, "modifier_unit_on_death", {
			posX = self.spawnPos.x,
			posY = self.spawnPos.y,
			posZ = self.spawnPos.z,
			name = self.unitName
		})
	-- end
	UTIL_Remove(self:GetParent())
end