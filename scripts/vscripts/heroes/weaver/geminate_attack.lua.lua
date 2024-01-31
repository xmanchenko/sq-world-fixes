LinkLuaModifier( "modifier_geminate_attack", "heroes/weaver/geminate_attack.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if geminate_attack == nil then
	geminate_attack = class({})
end
function geminate_attack:GetIntrinsicModifierName()
	return "modifier_geminate_attack"
end
---------------------------------------------------------------------
--Modifiers
if modifier_geminate_attack == nil then
	modifier_geminate_attack = class({})
end
function modifier_geminate_attack:OnCreated(params)
	if IsServer() then
	end
end
function modifier_geminate_attack:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_geminate_attack:OnDestroy()
	if IsServer() then
	end
end
function modifier_geminate_attack:DeclareFunctions()
	return {
	}
end