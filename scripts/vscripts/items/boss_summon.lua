LinkLuaModifier( "modifier_item_boss_summon_cd", "items/boss_summon", LUA_MODIFIER_MOTION_NONE )
modifier_item_boss_summon_cd = class({})
function modifier_item_boss_summon_cd:IsHidden() return true end
function modifier_item_boss_summon_cd:IsDebuff() return false end
function modifier_item_boss_summon_cd:IsPurgable() return false end
function modifier_item_boss_summon_cd:RemoveOnDeath() return false end

item_boss_summon = class({})

local bossTable = {
    [0] = "npc_forest_boss_fake",
    [1] = "npc_forest_boss_fake",
    [2] = "npc_village_boss_fake",
    [3] = "npc_mines_boss_fake",
    [4] = "npc_dust_boss_fake",
    [5] = "npc_cemetery_boss_fake",
    [6] = "npc_swamp_boss_fake",
    [7] = "npc_snow_boss_fake",
    [8] = "npc_boss_location8_fake",
    [9] = "npc_boss_magma_fake"
}
_G.Boss_Donate = {}
function item_boss_summon:OnSpellStart()
	if not _G.Boss_Donate[self:GetCaster():GetPlayerID()] then
		_G.Boss_Donate[self:GetCaster():GetPlayerID()] = {}
	end
	if table.count(_G.Boss_Donate[self:GetCaster():GetPlayerID()]) >= 3 then
		local player = PlayerResource:GetPlayer(self:GetCaster():GetPlayerOwnerID())
		CustomGameEventManager:Send_ServerToPlayer(player, "CreateIngameErrorMessage", {message="dota_hud_error_only_one_boss"})
		self:EndCooldown()
		return
	end
	if _G.don_spawn_level == 0 then
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer( self:GetCaster():GetPlayerID() ), "item_boss_summon_panorama", {
			spawn_level = 0,
		} )
	else
		CustomGameEventManager:Send_ServerToPlayer( PlayerResource:GetPlayer( self:GetCaster():GetPlayerID() ), "item_boss_summon_panorama", {
			spawn_level = _G.don_spawn_level - 1,
		} )
	end
	self.caster = self:GetCaster()
	if IsServer() then
		local duration = self:GetCooldown(self:GetLevel())* self.caster:GetCooldownReduction()
		local cd = self.caster:AddNewModifier(self.caster, self, "modifier_item_boss_summon_cd", {duration = duration})
	end
	if self:GetCurrentCharges() > 1 then
		self:SetCurrentCharges(self:GetCurrentCharges() - 1)
	else
		self:GetCaster():RemoveItem(self)
	end
end