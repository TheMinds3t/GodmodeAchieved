local item = {}
item.instance = GODMODE.registry.items.wings_of_betrayal
item.eid_description = "↑ +2.5 Damage and flight after taking damage for the first time each room"
item.eid_transforms = GODMODE.util.eid_transforms.LEVIATHAN..","..GODMODE.util.eid_transforms.ANGEL
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "On taking damage, grants +2.5 damage, +0.1 speed as well as flight for the current room. These bonuses reset after leaving the room."},
	},
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end
	
    if data.luc_wing_trigger then
		if cache == CacheFlag.CACHE_FLYING then
			player.CanFly = true     
		end

		player:AddNullCostume(GODMODE.registry.costumes.wings_of_betrayal)

		if cache == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 1.2
		end

		if cache == CacheFlag.CACHE_SPEED then 
			player.MoveSpeed = player.MoveSpeed + 0.1
		end
	else
		for i=-1,6 do 
			player:TryRemoveNullCostume(GODMODE.registry.costumes.wings_of_betrayal)
		end
	end
end

item.on_item_pickup = function(self,player)
	if player:HasCollectible(item.instance) then 
		if GODMODE.get_ent_data(player).luc_wing_trigger then 
			player:TryRemoveNullCostume(GODMODE.registry.costumes.wings_of_betrayal)
			player:AddNullCostume(GODMODE.registry.costumes.wings_of_betrayal)
		end
	end
end


item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == EntityType.ENTITY_PLAYER and enthit:ToPlayer():HasCollectible(item.instance) then
		local player = enthit:ToPlayer()
		GODMODE.get_ent_data(player).luc_wing_trigger = true
		GODMODE.save_manager.set_player_data(player, "LucWingActive", true,true)
		
		player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FLYING)
		player:EvaluateItems()
	end
end

item.new_room = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player)
		local data = GODMODE.get_ent_data(player)
		data.luc_wing_trigger = false
		GODMODE.save_manager.set_player_data(player, "LucWingActive", false,true)
		player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FLYING)
		player:EvaluateItems()
	end)
end

return item