local monster = {}
monster.name = "Stifled Gatekeeper"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, params)
    local ent = params[1]
    local data = params[2]
    data.persistent_state = GODMODE.persistent_state.single_room
	ent:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
end


monster.npc_update = function(self, ent)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()

	if data.real_time > 1 then
		ent:GetSprite():SetOverlayRenderPriority(false)
		if not data.screaming then
			ent:GetSprite():PlayOverlay("Idle",false)
			ent:AnimWalkFrame("MoveH","MoveV",0.1)

			local pathfinding = GODMODE.util.ground_ai_movement(ent,player,0.9,true)

			if pathfinding ~= nil then 
				ent.Velocity = ent.Velocity * 0.75 + pathfinding 
			elseif ent:GetPlayerTarget() ~= nil then 
				ent.Pathfinder:FindGridPath(player.Position,0.7,0,true)
			end	
		else
			ent.Velocity = ent.Velocity * 0.6
		end

		if ent:GetSprite():IsEventTriggered("Scream") then
			Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,ent.Position,Vector.Zero,ent)
			Game():GetRoom():MamaMegaExplosion(ent.Position)
			ent:Kill()

			if data.stole == true then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, Isaac.GetItemIdByName("Blood Key"), ent.Position, Vector.Zero, nil)
			end
		end
	end
end

monster.npc_kill = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant and not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
		Game():BombExplosionEffects(ent.Position,30.0,TearFlags.TEAR_NORMAL,Color.Default,ent,1)
		Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF04,0,ent.Position,Vector.Zero,ent)
	end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == monster.type and enthit.Variant == monster.variant and GODMODE.util.get_player_from_attack(entsrc) == nil then
		return false
	end
end

monster.new_room = function(self)
	local level = Game():GetLevel()
	if Game().Challenge == Challenge.CHALLENGE_NULL and level:GetStage() == LevelStage.STAGE5 and level:GetStageType() == StageType.STAGETYPE_ORIGINAL and Game():GetRoom():GetDecorationSeed() == (GODMODE.gatekeeper_spawn_index or 0) then --Sheol!
		Isaac.Spawn(monster.type,monster.variant,0,Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()),Vector.Zero,nil)
		GODMODE.gatekeeper_spawn_index = nil
	end
end

monster.new_level = function(self)
	local level = Game():GetLevel()
	GODMODE.gatekeeper_spawn_index = nil

	if level:GetStage() == LevelStage.STAGE5 and level:GetStageType() == StageType.STAGETYPE_ORIGINAL and Game().Challenge == Challenge.CHALLENGE_NULL then --Sheol!
		local rooms = level:GetRooms()
		local chance = 0.01
		
		for i=0, rooms.Size-1 do
			local room = rooms:Get(i)
			if room.Data.Type == RoomType.ROOM_DEFAULT and not room.Clear then
				if GODMODE.util.random() < chance then
					GODMODE.gatekeeper_spawn_index = room.DecorationSeed
					break
				else
					chance = chance + 0.09
				end
			end 
		end

		if GODMODE.gatekeeper_spawn_index == nil then GODMODE.gatekeeper_spawn_index = Game():GetRoom():GetDecorationSeed() end
	end
end

monster.npc_collide = function(self, ent, ent2, entfirst)
	if ent2:ToPlayer() and GODMODE.get_ent_data(ent).screaming ~= true then
		local player = ent2:ToPlayer()
		ent:GetSprite():Play("Scream",true)
		GODMODE.get_ent_data(ent).screaming = true
		local angel_items = GODMODE.get_angel_collected(player)

		if #angel_items > 0 then
			local ind = ent:GetDropRNG():RandomInt(#angel_items)+1
			local item = angel_items[ind]
			local quest = true 
			local depth = 10

			while quest == true and #angel_items > 0 and depth > 0 do 
				while item == 0 do
					ind = ent:GetDropRNG():RandomInt(#angel_items)+1
					item = angel_items[ind]
				end	

				local config = Isaac.GetItemConfig():GetCollectible(item)

				if config:IsCollectible() and config.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST and player:HasCollectible(item) then 
					quest = false
				else 
					GODMODE.remove_angel_collected(player,item)
					angel_items = GODMODE.get_angel_collected(player)
					depth = depth - 1
				end
			end

			if quest == false then 
				local config = Isaac.GetItemConfig():GetCollectible(item)

				if item ~= nil and config:IsCollectible() then 
					player:RemoveCollectible(item)
					ent:GetSprite():ReplaceSpritesheet(4, config.GfxFileName)
					ent:GetSprite():LoadGraphics()
					ent:GetSprite():PlayOverlay("ScreamSteal",true)
					GODMODE.get_ent_data(ent).stole = true
					GODMODE.remove_angel_collected(player,item)
				end
			else
				ent:GetSprite():RemoveOverlay()
			end
		else
			ent:GetSprite():RemoveOverlay()
		end
	end
end

return monster