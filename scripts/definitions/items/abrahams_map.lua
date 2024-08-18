local item = {}
item.instance = GODMODE.registry.items.abrahams_map
item.eid_description = "#↑ If no item pedestal is in the room, creates one#↑ If item pedestal is in room, rerolls pedestal to a random quality 4 item"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When used, one of two abilities occur:"},
      {str = " - If there is an item pedestal in the room that does not contain a quality 4 item, it converts that item into a random quality 4 item from any pool."},
      {str = " - If there is no item pedestals in the room (or none that contain items that aren't quality 4), a new item pedestal is generated using the current room's pool."},
    },
    { -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
      {str = "The item has two uses total, unless you duplicate it via Diplopia: this is because the uses are tied to players, not the item itself. "},
	  {str = "In this case, touching both combines the uses from both for the current item. In example, you used Abraham's Map once, put it on a pedestal and duplicated it, if you touch the duplicated one you will have 3 uses remaining."}
    },
}
local corners = {{x=0.025,y=0.1},{x=1.15,y=0.1},{x=0.5,y=1.9},{x=1.15,y=1.9}}

item.player_render = function(self,player,offset)
	if player:HasCollectible(item.instance) then
		if GODMODE.save_manager.has_player_data(player,"AbrahamUses") then
			local data = GODMODE.get_ent_data(player)
			data.abraham_uses = tonumber(GODMODE.save_manager.get_player_data(player, "AbrahamUses","2"))
			local center = GODMODE.util.get_center_of_screen()
			Isaac.RenderText(("x"..data.abraham_uses), 
				center.X * corners[player.ControllerIndex+1].x, 
				center.Y * corners[player.ControllerIndex+1].y, 
				1,1,1,1)
		end
	end
end

item.pickup_collide = function(self, pickup,ent,entfirst)
	if ent:ToPlayer() and (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM) and pickup.SubType == item.instance and not pickup.Touched then
		local data = GODMODE.get_ent_data(pickup)
		if data.abraham_added ~= true then
			GODMODE.save_manager.set_player_data(ent:ToPlayer(), "AbrahamUses", tonumber(GODMODE.save_manager.get_player_data(ent:ToPlayer(), "AbrahamUses","0",false))+2,true)
			data.abraham_added = true
			return true
		end
	end
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then 
		local ents = Isaac.GetRoomEntities()
		local ped = nil
		
		for i=1,#ents do
			if ents[i] and ents[i].Type == 5 and ents[i].Variant == 100 and ents[i].SubType > 0 then
				local config = Isaac.GetItemConfig():GetCollectible(ents[i].SubType)
				if config:IsCollectible() and config.Quality < 4 then
					ped = ents[i]
				end
			end
		end

		local data = GODMODE.get_ent_data(player)
		local use = function()
			data.abraham_uses = tonumber(GODMODE.save_manager.get_player_data(player, "AbrahamUses","2",false)) - 1
			GODMODE.save_manager.set_player_data(player, "AbrahamUses", data.abraham_uses,true)

			if data.abraham_uses == 1 then
				GODMODE.game:GetHUD():ShowItemText("Abraham's Map", data.abraham_uses.." use remaining", false)
			else
				GODMODE.game:GetHUD():ShowItemText("Abraham's Map", data.abraham_uses.." uses remaining", false)
			end

			if data.abraham_uses <= 0 then
				local void_slot = GODMODE.util.get_active_slot(player,CollectibleType.COLLECTIBLE_VOID)

				if void_slot ~= slot then
					player:RemoveCollectible(item.instance)
				end
				return data.abraham_uses == 0
			end

			return true
		end

		if ped == nil then
			if use() then
				Isaac.Spawn(5,100,0,GODMODE.room:FindFreePickupSpawnPosition(player.Position, GODMODE.room:GetClampedGridIndex(player.Position), true),Vector(0,0),player)  
				return true
			end
		elseif ped and ped:ToPickup() then
			if use() then
				local flag = -1
				local depth = 0

				while flag == -1 or flag == nil do 
					flag = GODMODE.special_items:get_item_of_quality(4) 

					local config = Isaac.GetItemConfig():GetCollectible(flag)
					if config and config:IsCollectible() and not config.Hidden then

						if config.Tags & ItemConfig.TAG_QUEST == ItemConfig.TAG_QUEST then 
							flag = -1
						end
					end	
				end
				ped:ToPickup():Morph(5, 100, flag, true)
				return true
			end
		end
	end
end

return item