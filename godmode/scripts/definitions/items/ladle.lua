local item = {}
item.instance = GODMODE.registry.items.the_ladle
item.eid_description = "↑ +1 Heart Container#↑ +0.1 speed#↑ +0.1 speed after taking damage, up to 5 times a floor#↓ Resets to +0.3 speed on a new floor"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Grants the following:"},
		{str = " +1 Heart Container"},
		{str = " +0.1 Speed"},
		{str = "Each time you take damage in a floor, grants an additional +0.1 speed up to a total of +0.6 speed from this item. The additional boost is reset at the beginning of each floor."},
	},
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	data.ladle_level = tonumber(GODMODE.save_manager.get_player_data(player, "LadleLevel",0))
	if cache == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = math.min(2.0, player.MoveSpeed + 0.1) + data.ladle_level * 0.1
	end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == EntityType.ENTITY_PLAYER and enthit:ToPlayer():HasCollectible(item.instance) then
		local player = enthit:ToPlayer()
		local data = GODMODE.get_ent_data(player)
		if data.ladle_level == nil or data.ladle_level < 5 then
			data.ladle_level = (data.ladle_level or 0) + 1
			GODMODE.save_manager.set_player_data(player, "LadleLevel", GODMODE.get_ent_data(player).ladle_level or 0,true)
			player:AddCacheFlags(CacheFlag.CACHE_SPEED)
			player:EvaluateItems()
		end
	end
end

item.new_level = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player)
		GODMODE.get_ent_data(player).ladle_level = 0
		GODMODE.save_manager.set_player_data(player, "LadleLevel", GODMODE.get_ent_data(player).ladle_level or 0,true)
		player:AddCacheFlags(CacheFlag.CACHE_SPEED)
		player:EvaluateItems()
	end)
end

return item