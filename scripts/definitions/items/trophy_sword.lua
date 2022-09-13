local item = {}
item.instance = Isaac.GetItemIdByName( "Child's Trophy" )
item.eid_description = "{{Warning}}Usable once every two floors#↑ 600% Damage on use#↑ +3 Tears on use"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When used, grants 600% damage and +3 fire delay for the room."},
      {str = "Child's Trophy is only useable once every two floors."},
    },
}


item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end

	local data = GODMODE.get_ent_data(player)

	if tonumber(GODMODE.save_manager.get_player_data(player,"TrophyRoomSeed","-1")) == Game():GetRoom():GetDecorationSeed() then
		if cache == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 6.0
		end

		if cache == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,3, true)
		end
	end
end
item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
		local data = GODMODE.get_ent_data(player)
		GODMODE.save_manager.set_player_data(player, "TrophyRoomSeed", Game():GetRoom():GetDecorationSeed(),true)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
		return true
	end
end
item.new_room = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
		GODMODE.save_manager.set_player_data(player, "TrophyRoomSeed", "-1",true)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
	end)
end
item.new_level = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
		local slot = GODMODE.util.get_active_slot(player, item.instance)
		if player:GetActiveItem(slot) == item.instance then
			player:SetActiveCharge(player:GetActiveCharge() + 1, slot)
			if player:GetActiveCharge(slot) > 2 then 
				player:SetActiveCharge(2, slot) 
			end
		end
	end)
end

item.load_data = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
		local data = GODMODE.get_ent_data(player)
		data.trophy_use_room = tonumber(GODMODE.save_manager.get_player_data(player, "TrophyRoomSeed", "-1"))
		if data.trophy_use_room == Game():GetRoom():GetDecorationSeed() then
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
		end
	end)
end

return item