LinkLuaModifier( "modifier_time_lapse", "heroes/weaver/time_lapse/time_lapse.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if time_lapse == nil then
	time_lapse = class({})
end
function time_lapse:GetIntrinsicModifierName()
	return "modifier_time_lapse"
end
---------------------------------------------------------------------
--Modifiers
if modifier_time_lapse == nil then
	modifier_time_lapse = class({})
end
function modifier_time_lapse:OnCreated(params)
	if IsServer() then
	end
end
function modifier_time_lapse:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_time_lapse:OnDestroy()
	if IsServer() then
	end
end
function modifier_time_lapse:DeclareFunctions()
	return {
	}
end