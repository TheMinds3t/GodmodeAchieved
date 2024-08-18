local item = {}
item.instance = GODMODE.registry.items.arcade_ticket
item.eid_description = "#If arcade is present, teleports to arcade#↑ If used in arcade:#90% chance to spawn a random collectible#10% chance to spawn a red coin# If used outside arcade:#↑ Spawns 1 penny"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "On use:"},
      {str = " - If in an arcade, 10% chance to spawn a red coin, otherwise a completely random pickup."},
      {str = " - If not in an arcade, either teleports you to an unvisited arcade or spawns a penny if all arcades have been visited on the floor."},
    },
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
		if GODMODE.room:GetType() == RoomType.ROOM_ARCADE then
			local other = rng:RandomFloat()

			if other <= 0.9 then
				Isaac.Spawn(5,0,0,GODMODE.room:FindFreePickupSpawnPosition(player.Position, GODMODE.room:GetClampedGridIndex(player.Position), true),Vector(0,0),player)
				return true
			else
				Isaac.Spawn(GODMODE.registry.entities.red_coin.type,GODMODE.registry.entities.red_coin.variant,0,GODMODE.room:FindFreePickupSpawnPosition(player.Position, GODMODE.room:GetClampedGridIndex(player.Position), true),Vector(0,0),player)
				return true
			end
		else
			local level = GODMODE.level
			local rooms = level:GetRooms()
		
			for i=0, rooms.Size-1 do
				local room = rooms:Get(i)

				if room.Data.Type == RoomType.ROOM_ARCADE and room.VisitedCount == 0 then
	--				player:AnimateTeleport(true)
					level.LeaveDoor = -1
					--level:ChangeRoom(room.GridIndex)
					GODMODE.game:StartRoomTransition(room.GridIndex, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT)
					return true
				end 
			end
		
			Isaac.Spawn(5,PickupVariant.PICKUP_COIN,0,GODMODE.room:FindFreePickupSpawnPosition(player.Position, GODMODE.room:GetClampedGridIndex(player.Position), true),Vector(0,0),player)
			return true
		end
	end
end

return item