local monster = {}
monster.name = "Stifled Gatekeeper"
monster.type = GODMODE.registry.entities.stifled_gatekeeper.type
monster.variant = GODMODE.registry.entities.stifled_gatekeeper.variant

monster.data_init = function(self, ent, data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
		data.persistent_state = GODMODE.persistent_state.single_room
		ent:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)	
	end
end

monster.npc_update = function(self, ent, data, sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
	local player = ent:GetPlayerTarget()

	if data.real_time > 1 then
		sprite:SetOverlayRenderPriority(false)
		if not data.screaming then
			sprite:PlayOverlay("Idle",false)
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

		if sprite:IsEventTriggered("Scream") then
			Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,ent.Position,Vector.Zero,ent)
			GODMODE.room:MamaMegaExplosion(ent.Position)
			ent:Kill()

			if data.stole == true then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, GODMODE.registry.items.blood_key, ent.Position, Vector.Zero, nil)
			end
		end
	end
end

monster.npc_kill = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant and not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
		GODMODE.game:BombExplosionEffects(ent.Position,30.0,TearFlags.TEAR_NORMAL,Color.Default,ent,1)
		Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF04,0,ent.Position,Vector.Zero,ent)
	end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == monster.type and enthit.Variant == monster.variant and GODMODE.util.get_player_from_attack(entsrc) == nil then
		return false
	end
end

monster.new_room = function(self)
	local level = GODMODE.level
	if GODMODE.game.Challenge == Challenge.CHALLENGE_NULL and level:GetStage() == LevelStage.STAGE5
		and (level:GetStageType() == StageType.STAGETYPE_ORIGINAL or level:GetStageType() == StageType.STAGETYPE_WOTL)
		and GODMODE.save_manager.get_data("GatekeeperSpawned","false") ~= "true" then
		local boss_flag = false 

		for i=0,DoorSlot.NUM_DOOR_SLOTS do 
			local door = GODMODE.room:GetDoor(i)

			if door ~= nil and door.TargetRoomType == RoomType.ROOM_BOSS then 
				boss_flag = true 
				break 
			end
		end

		if boss_flag == true then 
			local sub = 0

			if level:GetStageType() == StageType.STAGETYPE_WOTL then 
				sub = 1
			end
	
			Isaac.Spawn(monster.type,monster.variant,sub,GODMODE.room:FindFreePickupSpawnPosition(GODMODE.room:GetCenterPos()),Vector.Zero,nil)
			GODMODE.save_manager.set_data("GatekeeperSpawned",true)	
		end
	end
end

monster.new_level = function(self)
	if GODMODE.level:GetStage() == LevelStage.STAGE5 and (GODMODE.level:GetStageType() == StageType.STAGETYPE_ORIGINAL or GODMODE.level:GetStageType() == StageType.STAGETYPE_WOTL)
		and GODMODE.game.Challenge == Challenge.CHALLENGE_NULL then
		GODMODE.save_manager.set_data("GatekeeperSpawned",false)
	end
end

monster.npc_collide = function(self, ent, ent2, entfirst)
	if ent2:ToPlayer() and GODMODE.get_ent_data(ent).screaming ~= true then
		local player = ent2:ToPlayer()
		ent:GetSprite():Play("Scream",true)
		GODMODE.get_ent_data(ent).screaming = true

		if player:HasTrinket(GODMODE.registry.trinkets.godmode) then 
			GODMODE.log("Gatekeeper taking Godmode instead of item!",false)
			local config = Isaac.GetItemConfig():GetTrinket(GODMODE.registry.trinkets.godmode)
			if config ~= nil and config:IsTrinket() then 
				-- GODMODE.log("HI!",true)
				player:TryRemoveTrinket(GODMODE.registry.trinkets.godmode)
				ent:GetSprite():ReplaceSpritesheet(4, config.GfxFileName)
				ent:GetSprite():LoadGraphics()
				ent:GetSprite():PlayOverlay("ScreamSteal",true)
				GODMODE.get_ent_data(ent).stole = true
			end
		else
			local pool = "AngelCollected"

			if ent.SubType == 1 then 
				pool = "DevilCollected"
			end

			local get_items = function()  
				return GODMODE.save_manager.get_player_list_data(player,pool,false,function(val) return tonumber(val) end)
			end
			local angel_items = get_items()
			GODMODE.log(tostring(#angel_items).." available items for gatekeeper ",false)

			if #angel_items > 0 then
				local ind = ent:GetDropRNG():RandomInt(#angel_items)+1
				local item = angel_items[ind]
				local quest = true 
				local depth = #angel_items
	
				while quest == true and #angel_items > 0 and depth > 0 do 
					while item == 0 do
						ind = ent:GetDropRNG():RandomInt(#angel_items)+1
						item = angel_items[ind]
					end	
	
					local config = Isaac.GetItemConfig():GetCollectible(item)
	
					if config:IsCollectible() and config.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST and player:HasCollectible(item) then 
						quest = false
					else 
						GODMODE.save_manager.remove_player_list_data(player,pool,item,true)
						angel_items = get_items()
						depth = depth - 1
						item = 0
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
						GODMODE.save_manager.remove_player_list_data(player,pool,item,true)
					end
				else
					ent:GetSprite():RemoveOverlay()
				end
			else
				ent:GetSprite():RemoveOverlay()
			end
		end
	end
end

return monster