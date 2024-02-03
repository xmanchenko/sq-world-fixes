LinkLuaModifier( "modifier_corrosive_skin", "heroes/hero_viper/corrosive_skin/corrosive_skin.lua.lua", LUA_MODIFIER_MOTION_NONE )
--Abilities
if corrosive_skin == nil then
	corrosive_skin = class({})
end
function corrosive_skin:GetIntrinsicModifierName()
	return "modifier_corrosive_skin"
end
---------------------------------------------------------------------
--Modifiers
if modifier_corrosive_skin == nil then
	modifier_corrosive_skin = class({})
end
function modifier_corrosive_skin:OnCreated(params)
	if IsServer() then
	end
end
function modifier_corrosive_skin:OnRefresh(params)
	if IsServer() then
	end
end
function modifier_corrosive_skin:OnDestroy()
	if IsServer() then
	end
end
function modifier_corrosive_skin:DeclareFunctions()
	return {
	}
end