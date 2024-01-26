if wisp_splitshot_buff == nil then
	wisp_splitshot_buff = class({})
end
function wisp_splitshot_buff:Spawn()
	if not IsServer() then return end
	self:SetLevel(1)
end
function wisp_splitshot_buff:OnOwnerSpawned()
	if self.toggle_state then
		self:ToggleAbility()
	end
end
function wisp_splitshot_buff:OnOwnerDied()
	self.toggle_state = self:GetToggleState()
end
function wisp_splitshot_buff:OnToggle()
	if not IsServer() then return end
end
---------------------------------------------------------------------
modifier_wisp_splitshot_buff = class({})

function modifier_wisp_splitshot_buff:IsHidden()
	return true
end
function modifier_wisp_splitshot_buff:IsPurgable()
	return false
end

--Modifiers
function modifier_wisp_splitshot_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK
	}
	return funcs
end

function modifier_wisp_splitshot_buff:OnAttack( params )
	if not IsServer() then return end
	if params.attacker~=self:GetParent() then return end

	-- not proc for instant attacks
	if params.no_attack_cooldown then return end

	-- not proc for attacking allies
	if params.target:GetTeamNumber()==params.attacker:GetTeamNumber() then return end

	-- not proc if attack can't use attack modifiers
	if not params.process_procs then return end

	-- not proc on split shot attacks, even if it can use attack modifier, to avoid endless recursive call and crash
	if self.split_shot then return end

	self:SplitShotModifier( params.target )
end

--------------------------------------------------------------------------------
function modifier_wisp_splitshot_buff:SplitShotModifier( target )
	-- get radius
	local radius = self:GetParent():Script_GetAttackRange() + 100

	-- find other target units
	local enemies = FindUnitsInRadius(
		self:GetParent():GetTeamNumber(),	-- int, your team number
		self:GetParent():GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_COURIER,	-- int, type filter
		DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	local count = 4
	for _,enemy in pairs(enemies) do
		-- not target itself
		if enemy~=target then

			-- perform attack
			self.split_shot = true
			self:GetParent():PerformAttack(
				enemy, -- hTarget
				false, -- bUseCastAttackOrb
				true, -- bProcessProcs
				true, -- bSkipCooldown
				false, -- bIgnoreInvis
				true, -- bUseProjectile
				false, -- bFakeAttack
				false -- bNeverMiss
			)
			self.split_shot = false

			count = count + 1
			if count>=self.count then break end
		end
	end

	-- play effects if splitshot
	if count>0 then
		local sound_cast = "Hero_Medusa.AttackSplit"
		EmitSoundOn( sound_cast, self:GetParent() )
	end
end