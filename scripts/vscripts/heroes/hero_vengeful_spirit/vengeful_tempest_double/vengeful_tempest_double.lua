vengeful_tempest_double = class({})
LinkLuaModifier("modifier_tempest_double_illusion", "heroes/hero_vengeful_spirit/vengeful_tempest_double/modifier_tempest_double_illusion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_tempest_double_illusion_permanent", "heroes/hero_vengeful_spirit/vengeful_tempest_double/modifier_tempest_double_illusion_permanent", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_npc_dota_hero_vengefulspirit_str11", "heroes/hero_vengeful_spirit/vengeful_tempest_double/modifier_npc_dota_hero_vengefulspirit_str11", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_vengeful_tempest_double_intrinsic", "heroes/hero_vengeful_spirit/vengeful_tempest_double/modifier_vengeful_tempest_double_intrinsic", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier( "modifier_bkb", "modifiers/modifier_bkb", LUA_MODIFIER_MOTION_NONE )

local TRANSFER_PLAIN = 1 -- just add modifier to clone
local TRANSFER_FULL = 2 -- add modifier and transfer stacks

function vengeful_tempest_double:GetManaCost(iLevel)
    return 150 + math.min(65000, self:GetCaster():GetIntellect() / 30)
end
function vengeful_tempest_double:GetIntrinsicModifierName()
	return "modifier_vengeful_tempest_double_intrinsic"
end
vengeful_tempest_double.transferable_ability = {
    ["spell_item_pet_RDA_250_attribute_bonus"]           = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_250_bkb"]                       = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_250_dmg_reduction"]             = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_250_gold_and_exp"]              = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_250_minus_armor"]               = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_250_no_phys_spell_bonus"]       = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_250_no_spell_phys_bonus"]       = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_250_phys_dmg_reducrion"]        = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_250_pure_damage"]               = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_250_regen"]                     = TRANSFER_PLAIN,
    ["spell_pet_ability"]                                = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_agi"]                           = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_all_dmg_amp"]                   = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_block"]                         = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_cleave"]                        = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_dmg"]                           = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_fast"]                          = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_gold"]                          = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_heal"]                          = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_hp"]                            = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_int"]                           = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_mana_regen"]                    = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_simple_1"]                      = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_simple_2"]                      = TRANSFER_PLAIN,
    ["spell_item_pet_RDA_simple_3"]                      = TRANSFER_PLAIN,
    ["spell_item_pet_rda_roshan_1"]                      = TRANSFER_PLAIN,
    ["spell_item_pet_rda_roshan_2"]                      = TRANSFER_PLAIN,

	["npc_dota_hero_vengefulspirit_str6"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_str8"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_str9"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_str10"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_str11"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_str12"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_str13"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_int6"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_int8"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_int9"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_int10"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_int11"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_int12"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_int13"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_agi6"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_agi8"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_agi9"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_agi10"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_agi11"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_agi12"]	= 	TRANSFER_PLAIN,
	["npc_dota_hero_vengefulspirit_agi13"]	= 	TRANSFER_PLAIN,
}

vengeful_tempest_double.transferable_modifiers = {
	["modifier_don6"]				=	TRANSFER_PLAIN,
	["modifier_don7"]				=	TRANSFER_PLAIN,
	["modifier_don8"]				=	TRANSFER_PLAIN,
	["modifier_don9"]				=	TRANSFER_PLAIN,
	["modifier_don10"]				=	TRANSFER_PLAIN,
	["modifier_don11"]				=	TRANSFER_PLAIN,
	["modifier_don_last"]				=	TRANSFER_PLAIN,
	["modifier_don13"]				=	TRANSFER_PLAIN,
	["modifier_talent_hp_per_level"]		=	TRANSFER_FULL,
	["modifier_talent_hp_regen_level"]		=	TRANSFER_FULL,
	["modifier_talent_sheeld"]		=	TRANSFER_FULL,
	["modifier_talent_armor_per_level"]		=	TRANSFER_FULL,
	["modifier_talent_increase_str"]		=	TRANSFER_FULL,
	["modifier_talent_armor_curruption"]		=	TRANSFER_FULL,
	["modifier_talent_dmg_per_level"]		=	TRANSFER_FULL,
	["modifier_talent_all_evasion"]		=	TRANSFER_FULL,
	["modifier_talent_base_attack_time"]		=	TRANSFER_FULL,
	["modifier_talent_increase_agi"]		=	TRANSFER_FULL,
	["modifier_talent_magic_damage"]		=	TRANSFER_FULL,
	["modifier_talent_mp_regen_level"]		=	TRANSFER_FULL,
	["modifier_talent_m_resist"]		=	TRANSFER_FULL,
	["modifier_talent_manacost"]		=	TRANSFER_FULL,
	["modifier_talent_increase_int"]		=	TRANSFER_FULL,
}

function vengeful_tempest_double:OnUpgrade()
    if self:GetLevel() == 1 then
        self:RefreshCharges()
    end
end
function vengeful_tempest_double:OnOwnerSpawned()
	local caster = self:GetCaster()
	if caster:FindAbilityByName("npc_dota_hero_vengefulspirit_agi7") and self.talent_clone then
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(caster:GetPlayerID()), "SelectUnit", { entityIndex = caster:entindex(), bAddToGroup = false })
        if self.talent_clone:IsAlive() then
            FindClearSpaceForUnit(caster, self.talent_clone:GetAbsOrigin(), true)
            self.talent_clone:ForceKill(false)
            self.talent_clone:AddEffects(EF_NODRAW)
        end
        self.talent_clone = nil
    end
end

function vengeful_tempest_double:OnOwnerDied()
	if self:GetLevel() == 0 then
		return
	end
    local caster = self:GetCaster()
    if caster:FindAbilityByName("npc_dota_hero_vengefulspirit_agi7") then
        local clone = self:CreateClone()
        FindClearSpaceForUnit(clone, caster:GetAbsOrigin(), true)
        clone:AddNewModifier(caster, self, "modifier_tempest_double_illusion", {})
        CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer(caster:GetPlayerID()), "SelectUnit", { entityIndex = clone:entindex(), bAddToGroup = false })
        self.talent_clone = clone
    end
end

function vengeful_tempest_double:TransferModifiers(caster, clone)
	for name, transfer_type in pairs(self.transferable_modifiers) do
		local caster_modifier = caster:FindModifierByName(name)
		if caster_modifier and not caster_modifier:IsNull() then
			local clone_modifier = clone:AddNewModifier(clone, nil, name, {duration = caster_modifier:GetDuration()})
			if transfer_type == TRANSFER_FULL then
				clone_modifier:SetStackCount(caster_modifier:GetStackCount())
			end
		end
	end
end

function vengeful_tempest_double:TransferAbility(caster, clone)
	for name, transfer_type in pairs(self.transferable_ability) do
		local caster_ability = caster:FindAbilityByName(name)
		if caster_ability and caster_ability:GetLevel() > 0 then
			local clone_ability = clone:AddAbility(name):SetLevel(caster_ability:GetLevel())
		end
	end
end


function vengeful_tempest_double:CreateClone()
	local caster = self:GetCaster()
	if not caster or caster:IsNull() then return end
	local caster_name = caster:GetUnitName()
	local clone = CreateUnitByName(
		caster_name, 
		caster:GetAbsOrigin(), 
		true, 
		caster, 
		caster,
		caster:GetTeamNumber()
	)

	clone.IsRealHero = function() return false end
	clone.IsMainHero = function() return false end
	clone.IsTempestDouble = function() return true end

	clone:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
	clone:SetRenderColor(0, 0, 190)

	clone:AddNewModifier(clone, nil, "modifier_tempest_double_illusion_permanent", nil)

	while clone:GetLevel() < caster:GetLevel() do
		clone:HeroLevelUp( false )
	end

    for _, ab in pairs({"vengeful_spirit_magic_missile", "vengeful_spirit_wave_of_terror", "vengeful_spirit_command_aura", "vengeful_tempest_double"}) do
        local level = caster:FindAbilityByName(ab):GetLevel()
        local clone_ability = clone:FindAbilityByName(ab)
        clone_ability:SetLevel(level)
        if not self:GetCaster():FindAbilityByName("npc_dota_hero_vengefulspirit_int6") or ab == "vengeful_tempest_double" then
            clone_ability:SetActivated(false)
        end
    end
	for index = DOTA_ITEM_SLOT_1 , DOTA_ITEM_SLOT_9 do
		local caster_item = caster:GetItemInSlot(index)
		if caster_item and not caster_item:IsNull() then
            local clone_item = clone:AddItemByName(caster_item:GetAbilityName())
			clone_item:SetLevel(caster_item:GetLevel())
		end
	end

	local neutralItem = caster:GetItemInSlot(DOTA_ITEM_NEUTRAL_SLOT)
    if neutralItem then
	    clone:AddItemByName(neutralItem:GetAbilityName())
    end
	

	clone:SetBaseAgility(caster:GetBaseAgility())
	clone:SetBaseStrength(caster:GetBaseStrength())
	clone:SetBaseIntellect(caster:GetBaseIntellect())
	clone:Purge(true, true, false, true, true)
	clone:SetAbilityPoints(0)
	-- Illusions:HandleSuperIllusion(self.clone, caster)

	self:TransferModifiers(caster, clone)
	self:TransferAbility(caster, clone)
    clone:SetHealth(clone:GetMaxHealth())
    clone:SetMana(clone:GetMaxMana())

    clone:RemoveEffects(EF_NODRAW)

    local particle = ParticleManager:CreateParticle( "particles/units/heroes/hero_arc_warden/arc_warden_tempest_cast.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_ABSORIGIN_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
	Timers:CreateTimer(1, function()
		ParticleManager:DestroyParticle(particle, true)
		ParticleManager:ReleaseParticleIndex(particle)
	end)

	caster:EmitSound("Hero_ArcWarden.TempestDouble")
	return clone
end

function vengeful_tempest_double:GetCooldown(level)
	if self:GetCaster():FindAbilityByName("npc_dota_hero_vengefulspirit_str12") then
        return 0.1
    end
	return self.BaseClass.GetCooldown( self, level )
end


function vengeful_tempest_double:OnSpellStart()
	if not IsServer() then return end

	local caster = self:GetCaster()
	if not caster or caster:IsNull() then return end

	local clone = self:CreateClone()

	

	local duration = self:GetSpecialValueFor("duration")
    if caster:FindAbilityByName("npc_dota_hero_vengefulspirit_str13") then
        duration = 120
    end
	FindClearRandomPositionAroundUnit(clone, caster, 100)
	clone:AddNewModifier(caster, self, "modifier_tempest_double_illusion", { duration = duration })

	if caster:FindAbilityByName("npc_dota_hero_vengefulspirit_str11") then
		caster:AddNewModifier(caster, self, "modifier_npc_dota_hero_vengefulspirit_str11", {clone = clone:entindex()})
		clone:AddNewModifier(caster, self, "modifier_npc_dota_hero_vengefulspirit_str11", {clone = clone:entindex()})
	end
end
