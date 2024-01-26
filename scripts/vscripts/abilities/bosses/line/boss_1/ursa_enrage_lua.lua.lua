LinkLuaModifier( "modifier_ursa_enrage_lua", "abilities/bosses/line/boss_1/ursa_enrage_lua.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if ursa_enrage_lua == nil then
	ursa_enrage_lua = class({})
end
function ursa_enrage_lua:GetIntrinsicModifierName()
	return "modifier_ursa_enrage_lua"
end
---------------------------------------------------------------------
--Modifiers
if modifier_ursa_enrage_lua == nil then
	modifier_ursa_enrage_lua = class({})
end
function modifier_ursa_enrage_lua:OnCreated(params)
	if IsServer() then
	end
end
function modifier_ursa_enrage_lua:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_ursa_enrage_lua:OnDestroy()
	if IsServer() then
	end
end
function modifier_ursa_enrage_lua:DeclareFunctions()
	return {
	}
end