LinkLuaModifier("modifier_npc_dota_hero_pudge_str_last", "heroes/hero_pudge/str_boss", LUA_MODIFIER_MOTION_NONE)

npc_dota_hero_pudge_str_last = class({})

function npc_dota_hero_pudge_str_last:GetIntrinsicModifierName()
	return "modifier_npc_dota_hero_pudge_str_last"
end

if modifier_npc_dota_hero_pudge_str_last == nil then 
    modifier_npc_dota_hero_pudge_str_last = class({})
end

function modifier_npc_dota_hero_pudge_str_last:DeclareFunctions()
	return {
        MODIFIER_EVENT_ON_DEATH,
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
    }
end

function modifier_npc_dota_hero_pudge_str_last:OnDeath(params)
    local parent = self:GetParent()
    if IsMyKilledBadGuys2(parent, params) then
        self:IncrementStackCount()
        parent:CalculateStatBonus(true)
    end
end

function modifier_npc_dota_hero_pudge_str_last:GetModifierBonusStats_Strength(params)
    return self:GetStackCount() * 100
end

function modifier_npc_dota_hero_pudge_str_last:IsHidden()
	return true
end

function modifier_npc_dota_hero_pudge_str_last:IsPurgable()
    return false
end
 
function modifier_npc_dota_hero_pudge_str_last:RemoveOnDeath()
    return false
end

function modifier_npc_dota_hero_pudge_str_last:OnCreated(kv)
end

function IsMyKilledBadGuys2(hero, params)
    if params.unit:GetTeamNumber() ~= DOTA_TEAM_BADGUYS then
        return false
    end
	local attacker = params.attacker
	local unit_name = params.unit:GetUnitName()
	local abil = attacker:FindAbilityByName("npc_dota_hero_pudge_str_last")             
	if abil ~= nil then 
		for _,current_name in pairs(bosses_names) do
			if current_name == unit_name and hero == attacker then
				return true
			end
		end
	end
end
