local item = {}
item.instance = GODMODE.registry.items.diya
item.eid_description = "When used, weakens all enemies in the room similar to Reverse Strength"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "On use, the candle lights and weakens enemies near it for the duration of the room, similar to the strength? card."},
    },
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
		local data = GODMODE.get_ent_data(player)
		GODMODE.save_manager.set_player_data(player, "DiyaLit", "true",true)
		return true
	end
end

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_FAMILIARS then 
		player:CheckFamiliar(GODMODE.registry.entities.diya.variant, player:GetCollectibleNum(item.instance), player:GetCollectibleRNG(item.instance), Isaac.GetItemConfig():GetCollectible(item.instance))
	end
end

item.new_room = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance,function(player) GODMODE.save_manager.set_player_data(player, "DiyaLit", "false",true) end)
end

return item