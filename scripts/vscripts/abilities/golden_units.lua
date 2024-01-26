local MODIFIER_PRIORITY_MONKAGIGA_EXTEME_HYPER_ULTRA_REINFORCED_V9 = 10001

golden_passive = class({})
LinkLuaModifier( "modifier_golden_passive", "abilities/golden_units", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function golden_passive:GetIntrinsicModifierName()
	return "modifier_golden_passive"
end

--------------------------------------------------------------------------------

modifier_golden_passive = class({})

--------------------------------------------------------------------------------

function modifier_golden_passive:IsHidden()
	return true
end

--------------------------------------------------------------------------------

function modifier_golden_passive:OnCreated( kv )
	if IsServer() then
		--if self:GetParent():GetUnitName() == "GoldenDragon" then
		--	self:GetParent():SetRenderColor( 255, 250, 0 )
			--local field_fx = ParticleManager:CreateParticle("particles/golden_dragon.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())	   
			--self:AddParticle(field_fx, false, false, -1, true, true)
		--end
	end
end

--------------------------------------------------------------------------------

function modifier_golden_passive:CheckState()
	local state = {}
	if IsServer()  then
		state[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = false
		state[MODIFIER_STATE_NOT_ON_MINIMAP] = true
		state[MODIFIER_STATE_NO_HEALTH_BAR] = false
	end
	return state
end

--------------------------------------------------------------------------------

function modifier_golden_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_golden_passive:GetModifierProvidesFOWVision( params )
	return 1
end


function modifier_golden_passive:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_gold_lvl2.vpcf"
end

function modifier_golden_passive:StatusEffectPriority()
	return MODIFIER_PRIORITY_MONKAGIGA_EXTEME_HYPER_ULTRA_REINFORCED_V9
end
