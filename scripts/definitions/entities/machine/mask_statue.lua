local monster = {}
monster.name = "Masked Angel Statue"
monster.type = GODMODE.registry.entities.masked_angel_statue.type
monster.variant = GODMODE.registry.entities.masked_angel_statue.variant
monster.animations = {"Idle","Phase2","Phase3","Phase4"}

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
		data.persistent_state = GODMODE.persistent_state.single_room
	end
end
monster.npc_update = function(self, ent, data, sprite)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local player = ent:GetPlayerTarget()
	ent.Velocity = Vector(0,0)

	if not ent:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then 
		ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
	end

	if data.prev_phase == nil then
		data.phase = 1
		data.prev_phase = 1
		sprite:Play("Idle",false)
		ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET)
	else
		data.prev_phase = data.phase 
		sprite:Play(monster.animations[data.phase] or "Phase4Idle", false)
	end

	if sprite:IsEventTriggered("Crush") then
		GODMODE.game:ShakeScreen(10)
		local monsters = {}
		local player_pos = player.Position
		local topleft = GODMODE.room:GetTopLeftPos()
		local botright = GODMODE.room:GetBottomRightPos()

		if data.phase == 2 then
			monsters = {
				{pos = Vector(topleft.X + 26,topleft.Y + 26),id = EntityType.ENTITY_BABY, variant = GODMODE.registry.entities.fallen_angelic_baby.variant, subtype = 0},
				{pos = Vector(botright.X - 26,topleft.Y + 26),id = EntityType.ENTITY_BABY, variant = GODMODE.registry.entities.fallen_angelic_baby.variant, subtype = 0},
				{pos = Vector(botright.X - 26,botright.Y - 26),id = EntityType.ENTITY_BABY, variant = GODMODE.registry.entities.fallen_angelic_baby.variant, subtype = 0},
				{pos = Vector(topleft.X + 26,botright.Y - 26),id = EntityType.ENTITY_BABY, variant = GODMODE.registry.entities.fallen_angelic_baby.variant, subtype = 0},
			}
		elseif data.phase == 3 then
			monsters = {
				{pos = Vector(topleft.X + 26,(botright.Y + topleft.Y)/2),id = EntityType.ENTITY_URIEL , variant = 1, subtype = 0},
				{pos = Vector(botright.X - 26,(botright.Y + topleft.Y)/2),id = EntityType.ENTITY_GABRIEL , variant = 1, subtype = 0},
			}
		elseif data.phase == 4 then
			monsters = {
				{pos = Vector(topleft.X + 26,(botright.Y + topleft.Y)/2),id = EntityType.ENTITY_URIEL , variant = GODMODE.registry.entities.bloody_uriel.variant, subtype = 0},
				{pos = Vector(botright.X - 26,(botright.Y + topleft.Y)/2),id = EntityType.ENTITY_GABRIEL , variant = GODMODE.registry.entities.bloody_gabriel.variant, subtype = 0},
			}

			GODMODE.util.macro_on_enemies(nil,GODMODE.registry.entities.papal_flame.type,GODMODE.registry.entities.papal_flame.variant,nil,function(flame) flame:Kill() end)
		end

		if StageAPI and StageAPI.Loaded and GODMODE.is_at_palace() then
			GODMODE.set_palace_stage(data.phase)
		end


		for i=1, #monsters+1 do
			if monsters[i] then
				Isaac.Spawn(monsters[i].id,monsters[i].variant,monsters[i].subtype,monsters[i].pos,Vector(0,0),ent)
			end
		end
	end

	if Isaac.CountBosses() + Isaac.CountEnemies() > 0 then
		if GODMODE.room:IsClear() then
			for i=0,8 do
				if i < 8 then
					local door = GODMODE.room:GetDoor(i)

					if door and door:IsOpen() then
						door:Close(true)
					end
				end
			end
			GODMODE.room:SetClear(false)
			
			if StageAPI and StageAPI.Loaded and StageAPI.GetCurrentStage ~= nil then
				StageAPI.CloseDoors()
			end
		end
	else
		GODMODE.room:SetClear(true)
		for i=0,8 do
			if i < 8 then
				local door = GODMODE.room:GetDoor(i)

				if door and not door:IsOpen() then
					door:Close(false)
					door:Open()
				end
			end
		end

		if data.phase ~= nil and data.phase == 4 and sprite:IsFinished("Phase4") then
			data.phase = data.phase + 1
		end

		if data.phase ~= nil and data.phase > 4 and data.spawned_item ~= true then
			data.spawned_item = true
	        Isaac.Spawn(GODMODE.registry.entities.late_delivery.type,GODMODE.registry.entities.late_delivery.variant,GODMODE.registry.items.vessel_of_purity_1,GODMODE.room:FindFreePickupSpawnPosition(GODMODE.room:GetRandomPosition(48)),Vector(0,0),player)
			sprite:Play("Phase4Idle",false)
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
	local statue = Isaac.Spawn(monster.type,monster.variant,0,GODMODE.room:GetCenterPos(),Vector.Zero,nil)
	GODMODE.get_ent_data(statue).phase = GODMODE.get_ent_data(ent).phase
	GODMODE.get_ent_data(statue).prev_phase = GODMODE.get_ent_data(ent).prev_phase
	GODMODE.get_ent_data(statue).spawned_item = GODMODE.get_ent_data(ent).spawned_item
	statue:GetSprite():SetFrame(ent:GetSprite():GetAnimation(),ent:GetSprite():GetFrame())
	-- statue:GetSprite():Play(statue:GetSprite():GetAnimation(),false)
	statue:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

end
return monster