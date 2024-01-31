LinkLuaModifier( "modifier_shukuchi", "heroes/weaver/shukuchi.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if shukuchi == nil then
	shukuchi = class({})
end
function shukuchi:GetIntrinsicModifierName()
	return "modifier_shukuchi"
end
---------------------------------------------------------------------
--Modifiers
if modifier_shukuchi == nil then
	modifier_shukuchi = class({})
end
function modifier_shukuchi:OnCreated(params)
	if IsServer() then
	end
end
function modifier_shukuchi:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_shukuchi:OnDestroy()
	if IsServer() then
	end
end
function modifier_shukuchi:DeclareFunctions()
	return {
	}
end