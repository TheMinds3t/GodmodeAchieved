local item = {}
item.instance = GODMODE.registry.items.flying_pan
item.eid_description = "When used, removes the pan from Isaac and throws it in the air#Every second in combat +1% chance the pan falls, creating a large explosion inheriting your bomb effects#Once landed, walking over it will return the pan"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "On use, removes the Flying Pan from Isaac and throws it in the air."},
      {str = "It will remain above Isaac as a shadow, and every second in combat grants it a +1% chance to fall back down."},
      {str = "Once it falls, it will create a shockwave effect (10 damage) and a blast (40 damage) at the location of impact, inheriting your bomb effects."},
      {str = "When the Flying Pan is on the ground, walking over it will return it to Isaac uncharged."},
    },
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
		GODMODE.save_manager.set_player_data(player, "FlyingPanThrown", "true")
		GODMODE.save_manager.set_player_data(player, "FlyingPanLand", "0")
		GODMODE.save_manager.set_player_data(player, "FlyingPanChance", "0",true)
		player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
		player:EvaluateItems()
		return {Discharge=true,Remove=true,ShowAnim=false}
	end
end

item.player_update = function(self, player, data, sprite)
	if not GODMODE.room:IsClear() then 
		local thrown = GODMODE.save_manager.get_player_data(player, "FlyingPanThrown", "false") == "true"
        local land_state = GODMODE.save_manager.get_player_data(player, "FlyingPanLand", "0")

		-- if the pan is not falling yet
		if thrown and land_state == "0" then 
			local cur_chance = tonumber(GODMODE.save_manager.get_player_data(player, "FlyingPanChance", "0"))

			if player:IsFrame(30,1) then 
				if player:GetCollectibleRNG(item.instance):RandomFloat() < cur_chance then 
					GODMODE.save_manager.set_player_data(player, "FlyingPanLand", "1")
					GODMODE.save_manager.set_player_data(player, "FlyingPanChance", 0)
				else 
					cur_chance = cur_chance + 0.05
					GODMODE.save_manager.set_player_data(player, "FlyingPanChance", cur_chance)
				end
			end
		end
	end
end

-- allow a pan to be in the air if godmode thinks that a pan is thrown 
item.eval_cache = function(self, player,cache,data)
	if cache == CacheFlag.CACHE_FAMILIARS then 
		local thrown = GODMODE.save_manager.get_player_data(player, "FlyingPanThrown", "false") == "true"
		player:CheckFamiliar(GODMODE.registry.entities.flying_pan.variant, (thrown and 1 or 0), player:GetCollectibleRNG(item.instance), Isaac.GetItemConfig():GetCollectible(item.instance))
	end
end

return item