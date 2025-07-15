local monster = {}
monster.name = "Masked Angel Statue"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
monster.animations = {"Idle","Phase2","Phase3","Phase4"}

monster.data_init = function(self, params)
    params[2].persistent_state = GODMODE.persistent_state.single_room
end
monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()
	ent.Velocity = Vector(0,0)

	if not ent:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then 
		ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
	end

	if data.prev_phase == nil then
		data.phase = 1
		data.prev_phase = 1
		ent:GetSprite():Play("Idle",false)
		ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET)
	elseif data.prev_phase ~= data.phase then
		data.prev_phase = data.phase 
		ent:GetSprite():Play(monster.animations[data.phase] or "Phase4Idle", false)
	end

	if ent:GetSprite():IsEventTriggered("Crush") then
		Game():ShakeScreen(10)
		local monsters = {}
		local player_pos = player.Position
		local topleft = Game():GetRoom():GetTopLeftPos()
		local botright = Game():GetRoom():GetBottomRightPos()

		if data.phase == 2 then
			monsters = {
				{pos = Vector(topleft.X + 26,topleft.Y + 26),id = EntityType.ENTITY_BABY, variant = Isaac.GetEntityVariantByName("Fallen Angelic Baby"), subtype = 0},
				{pos = Vector(botright.X - 26,topleft.Y + 26),id = EntityType.ENTITY_BABY, variant = Isaac.GetEntityVariantByName("Fallen Angelic Baby"), subtype = 0},
				{pos = Vector(botright.X - 26,botright.Y - 26),id = EntityType.ENTITY_BABY, variant = Isaac.GetEntityVariantByName("Fallen Angelic Baby"), subtype = 0},
				{pos = Vector(topleft.X + 26,botright.Y - 26),id = EntityType.ENTITY_BABY, variant = Isaac.GetEntityVariantByName("Fallen Angelic Baby"), subtype = 0},
			}
		elseif data.phase == 3 then
			monsters = {
				{pos = Vector(topleft.X + 26,(botright.Y + topleft.Y)/2),id = EntityType.ENTITY_URIEL , variant = 1, subtype = 0},
				{pos = Vector(botright.X - 26,(botright.Y + topleft.Y)/2),id = EntityType.ENTITY_GABRIEL , variant = 1, subtype = 0},
			}
		elseif data.phase == 4 then
			monsters = {
				{pos = Vector(topleft.X + 26,(botright.Y + topleft.Y)/2),id = EntityType.ENTITY_URIEL , variant = Isaac.GetEntityVariantByName("Bloody Uriel"), subtype = 0},
				{pos = Vector(botright.X - 26,(botright.Y + topleft.Y)/2),id = EntityType.ENTITY_GABRIEL , variant = Isaac.GetEntityVariantByName("Bloody Gabriel"), subtype = 0},
			}

			GODMODE.util.macro_on_enemies(nil,Isaac.GetEntityTypeByName("Papal Flame"),Isaac.GetEntityVariantByName("Papal Flame"),nil,function(flame) flame:Kill() end)
		end

		if StageAPI and GODMODE.is_at_palace() then
			GODMODE.set_palace_stage(data.phase)
		end


		for i=1, #monsters+1 do
			if monsters[i] then
				Isaac.Spawn(monsters[i].id,monsters[i].variant,monsters[i].subtype,monsters[i].pos,Vector(0,0),ent)
			end
		end
	end

	if Isaac.CountBosses() + Isaac.CountEnemies() > 0 then
		if Game():GetRoom():IsClear() then
			for i=0,8 do
				if i < 8 then
					local door = Game():GetRoom():GetDoor(i)

					if door and door:IsOpen() then
						door:Close(true)
					end
				end
			end
			Game():GetRoom():SetClear(false)
			
			if StageAPI then
				StageAPI.CloseDoors()
			end
		end
	else
		Game():GetRoom():SetClear(true)
		for i=0,8 do
			if i < 8 then
				local door = Game():GetRoom():GetDoor(i)

				if door and not door:IsOpen() then
					door:Close(false)
					door:Open()
				end
			end
		end

		if data.phase ~= nil and data.phase == 4 and ent:GetSprite():IsFinished("Phase4") then
			data.phase = data.phase + 1
		end

		if data.phase ~= nil and data.phase > 4 and data.spawned_item ~= true then
			data.spawned_item = true
	        Isaac.Spawn(Isaac.GetEntityTypeByName("Late Delivery"),Isaac.GetEntityVariantByName("Late Delivery"),Isaac.GetItemIdByName("Vessel of Purity"),Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetRandomPosition(48)),Vector(0,0),player)
			ent:GetSprite():Play("Phase4Idle",false)
		end
	end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)
	if enthit.Type == monster.type and enthit.Variant == monster.variant then
		if flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION then
			data.phase = data.phase + 1
			return false
		else
			return false
		end
	end
end

monster.npc_kill = function(self,ent)
	local statue = Isaac.Spawn(monster.type,monster.variant,0,Game():GetRoom():GetCenterPos(),Vector.Zero,nil)
	GODMODE.get_ent_data(statue).phase = GODMODE.get_ent_data(ent).phase
	GODMODE.get_ent_data(statue).prev_phase = GODMODE.get_ent_data(ent).prev_phase
end
return monster