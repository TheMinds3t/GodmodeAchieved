local item = {}
item.instance = GODMODE.registry.items.black_mushroom
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
		local void_flag = flags & UseFlag.USE_VOID == UseFlag.USE_VOID

		if void_flag and GODMODE.save_manager.get_player_data(player,"MushroomVoid","false") == "false" 
			or not void_flag then
			
			GODMODE.save_manager.set_player_data(player,"MushroomUse",""..GODMODE.room:GetDecorationSeed(),true)
			
			if GODMODE.room:GetType() == RoomType.ROOM_ERROR then 
				GODMODE.save_manager.set_player_data(player,"MushroomTime","100",true)
			end

			if void_flag then
				GODMODE.save_manager.set_player_data(player,"MushroomVoid","true",true)
			else
				return {Discharge=true,Remove=true,ShowAnim=false}
			end
		end

		return true
	end
end

item.player_update = function(self,player,data)

	if data.bm_use == nil and player:IsFrame(30,1) or data.bm_use ~= nil then 
		local use_room = tonumber(GODMODE.save_manager.get_player_data(player,"MushroomUse","-1"))
		local time = tonumber(GODMODE.save_manager.get_player_data(player,"MushroomTime","-1"))
	
		if time >= 0 then 
			data.bm_use = true
			GODMODE.save_manager.set_player_data(player,"MushroomTime",""..(time-1))
			GODMODE.shader_params.black_mushroom_intensity = math.min(5,(GODMODE.shader_params.black_mushroom_intensity or 0)+(30-time)*(1/95.0))
	
			if time == 0 then 
				player:AddMaxHearts(-4,false)
				player:AddHearts(24)
				player:AddSoulHearts(4)
				player:UseActiveItem(CollectibleType.COLLECTIBLE_FORGET_ME_NOW, false, true, true, false)
				data.bm_use = nil
				GODMODE.shader_params.black_mushroom_intensity = 0
				GODMODE.save_manager.set_player_data(player,"MushroomUse","-1",true)
			end
	
			if time == 15 then 
				GODMODE.room:MamaMegaExplosion(player.Position)
			end	
		else 
			if use_room == GODMODE.room:GetDecorationSeed() then 
				GODMODE.shader_params.black_mushroom_intensity = math.min(2.2,(GODMODE.shader_params.black_mushroom_intensity or 0)+(1/120.0))
			end	
		end	
	end
end

item.new_room = function(self)
	GODMODE.util.macro_on_players(function(player) 
		local use_room = tonumber(GODMODE.save_manager.get_player_data(player,"MushroomUse","-1"))

		if use_room ~= GODMODE.room:GetDecorationSeed() and use_room ~= -1 then 
			GODMODE.save_manager.set_player_data(player,"MushroomUse","-1",true)
			GODMODE.save_manager.set_player_data(player,"MushroomTime","100",true)
		end
	end)
end
return item