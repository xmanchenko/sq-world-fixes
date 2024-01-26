LinkLuaModifier( "modifier_ursa_earthshock_lua", "heroes/ursa_earthshock_lua/ursa_earthshock_lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ursa_earthshock_lua == nil then
	ursa_earthshock_lua = class({})
end
function ursa_earthshock_lua:GetIntrinsicModifierName()
	return "modifier_ursa_earthshock_lua"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ursa_earthshock_lua == nil then
	modifier_ursa_earthshock_lua = class({})
end
function modifier_ursa_earthshock_lua:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ursa_earthshock_lua:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ursa_earthshock_lua:OnDestroy()
	if IsServer() then
	end
end
function modifier_ursa_earthshock_lua:DeclareFunctions()
	return {
	}
end