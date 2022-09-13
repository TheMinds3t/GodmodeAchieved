local item = {}
item.instance = Isaac.GetItemIdByName( "Black Mushroom" )
item.eid_description = "{{Warning}} ONE TIME USAGE {{Warning}}#↑ Full health#↑ 3 Soul hearts#↓ 1 Heart #Reroll current floor after leavin g the room it was used in#"
item.eid_transforms = GODMODE.util.eid_transforms.MUSHROOM
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "On use, flags the current room. After leaving the current room:"},
      {str = " - Gives two soul hearts."},
      {str = " - Removes 2 red heart containers, fills all health."},
      {str = " - Restarts the current floor, akin to Forget-Me-Now."},
    },
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
		local void_slot = GODMODE.util.get_active_slot(player,CollectibleType.COLLECTIBLE_VOID)

		if void_slot ~= slot or GODMODE.save_manager.get_player_data(player,"MushroomVoid","false") == "false" then
			GODMODE.save_manager.set_player_data(player,"MushroomUse",""..Game():GetRoom():GetDecorationSeed(),true)
			if void_slot == slot then
				GODMODE.save_manager.set_player_data(player,"MushroomVoid","true",true)
			else
				player:RemoveCollectible(player:GetActiveItem())
			end
		end

		return true
	end
end

item.player_update = function(self,player)
	local use_room = tonumber(GODMODE.save_manager.get_player_data(player,"MushroomUse","-1"))
	local time = tonumber(GODMODE.save_manager.get_player_data(player,"MushroomTime","-1"))

	if time >= 0 then 
		GODMODE.save_manager.set_player_data(player,"MushroomTime",""..(time-1))
		GODMODE.shader_params.black_mushroom_intensity = math.min(5,(GODMODE.shader_params.black_mushroom_intensity or 0)+(30-time)*(1/95.0))

		if time == 0 then 
			player:AddMaxHearts(-4,false)
			player:AddHearts(24)
			player:AddSoulHearts(4)
			player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false, true, true, false)
			GODMODE.shader_params.black_mushroom_intensity = 0
		end

		if time == 15 then 
			Game():GetRoom():MamaMegaExplosion(player.Position)
		end
	else 
		if use_room == Game():GetRoom():GetDecorationSeed() then 
			GODMODE.shader_params.black_mushroom_intensity = math.min(2.2,(GODMODE.shader_params.black_mushroom_intensity or 0)+(1/120.0))
		end	
	end
end

item.new_room = function(self)
	GODMODE.util.macro_on_players(function(player) 
		local use_room = tonumber(GODMODE.save_manager.get_player_data(player,"MushroomUse","-1"))

		if use_room ~= Game():GetRoom():GetDecorationSeed() and use_room ~= -1 then 
			GODMODE.save_manager.set_player_data(player,"MushroomUse","-1",true)
			GODMODE.save_manager.set_player_data(player,"MushroomTime","100",true)
		end
	end)
end
return item