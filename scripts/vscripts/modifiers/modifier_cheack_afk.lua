modifier_cheack_afk = class({})

function modifier_cheack_afk:IsHidden()
	return true
end

function modifier_cheack_afk:IsPurgeException()
	return false
end	

function modifier_cheack_afk:IsPurgable()
	return false
end

function modifier_cheack_afk:RemoveOnDeath()
	return false
end

function modifier_cheack_afk:OnCreated( kv )
	if not IsServer() then return end
	self.parent = self:GetParent()
	self.currentpos = self.parent:GetOrigin()
	self.MinigameStarted = false
	if IsInToolsMode() or GameRules:IsCheatMode() then
		return
	end
	self:StartIntervalThink(0.2)
end

function modifier_cheack_afk:OnIntervalThink()
	if not self.parent:IsAlive() then
		if self.parent:GetTimeUntilRespawn() > 11 then
			hero:SetTimeUntilRespawn(10)
		end
	end
	local CheckConnection = function()
		local connection_state = PlayerResource:GetConnectionState(self:GetParent():GetPlayerID())
		if connection_state == DOTA_CONNECTION_STATE_UNKNOWN then return false end
		if connection_state == DOTA_CONNECTION_STATE_ABANDONED then return false end
		if connection_state == DOTA_CONNECTION_STATE_FAILED then return false end
		return true
	end
	local CheckInsaneLives = function()
		if diff_wave.wavedef ~= "Insane" and diff_wave.wavedef ~= "Impossible" then return true end
		return self:GetParent():HasModifier( "modifier_insane_lives" )
	end
	local RemoveTimer = function()
		if self.timer then
			Timers:RemoveTimer(self.timer)
			self.timer = nil
		end
		if self.MinigameStarted then
			self:EndMinigame()
		end
	end
	if CheckConnection() == false or CheckInsaneLives() == false or not Entities:FindByName(nil, "badguys_fort") or _G.kill_invoker then
		RemoveTimer()
		return
	end
	if self.MinigameStarted then
		return
	end
	local pos = self.parent:GetOrigin()
	local dist = (pos-self.currentpos):Length2D()
	self.currentpos = pos
	if dist == 0 and not self.parent:IsAttacking() and not self.parent:IsChanneling() then 
		if not self.timer then
			self.timer = Timers:CreateTimer(300, function()
				self.modifier1 = self.parent:AddNewModifier(self.parent, nil, "modifier_invulnerable", {})
				self.modifier2 = self.parent:AddNewModifier(self.parent, nil, "modifier_stunned", {})
				self.MinigameStarted = true
				ListenToGameEvent("player_reconnected", Dynamic_Wrap(self, 'OnPlayerReconnected'), self)
				CustomUI:DynamicHud_Create(self.parent:GetPlayerOwnerID(), "minigame_container", "file://{resources}/layout/custom_game/minigame/minigame.xml", nil)
				Talents:EnableAFKGame(self:GetParent():GetPlayerID())
			end)
		end	
	else
		RemoveTimer()
	end
end

function modifier_cheack_afk:EndMinigame()
	local pid = self:GetParent():GetPlayerID()
	self.MinigameStarted = false
	Talents:DisableAFKGame(pid)
	CustomUI:DynamicHud_Destroy(pid, "minigame_container")
	if self.modifier1 then
		self.modifier1:Destroy()
		self.modifier2:Destroy()
	end
end

function modifier_cheack_afk:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_DIRECT_MODIFICATION,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_DEATH,
    }
end

function modifier_cheack_afk:GetModifierMagicalResistanceDirectModification()
	return -0.1 * self:GetParent():GetIntellect()
end

function modifier_cheack_afk:GetModifierConstantManaRegen()
	return -0.048 * self:GetParent():GetIntellect()
end

function modifier_cheack_afk:OnPlayerReconnected(data)
	if data.PlayerID == self.parent:GetPlayerOwnerID() then
		CustomUI:DynamicHud_Create(self.parent:GetPlayerOwnerID(), "minigame_container", "file://{resources}/layout/custom_game/minigame.xml", nil)
	end
end
function modifier_cheack_afk:OnDeath(keys)
	if not IsServer() then return end
	if keys.unit == self:GetParent() then
		Quests:UpdateCounter("daily", self:GetParent():GetPlayerID(), 49)
	end
end