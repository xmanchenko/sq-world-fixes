LinkLuaModifier( "modifier_the_swarm", "heroes/weaver/the_swarm.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if the_swarm == nil then
	the_swarm = class({})
end
function the_swarm:GetIntrinsicModifierName()
	return "modifier_the_swarm"
end
---------------------------------------------------------------------
--Modifiers
if modifier_the_swarm == nil then
	modifier_the_swarm = class({})
end
function modifier_the_swarm:OnCreated(params)
	if IsServer() then
	end
end
function modifier_the_swarm:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_the_swarm:OnDestroy()
	if IsServer() then
	end
end
function modifier_the_swarm:DeclareFunctions()
	return {
	}
end