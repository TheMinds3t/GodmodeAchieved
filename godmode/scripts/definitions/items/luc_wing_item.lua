local item = {}
item.instance = Isaac.GetItemIdByName( "Lucifer's Wings" )
item.eid_description = "↑ +2.5 Damage and flight after taking damage for the first time each room"
item.eid_transforms = GODMODE.util.eid_transforms.LEVIATHAN..","..GODMODE.util.eid_transforms.ANGEL
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "On taking damage, grants +2.5 damage as well as flight for the current room. These bonuses reset after leaving the room."},
	},
}

item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end

	local data = GODMODE.get_ent_data(player)
	
    if data.luc_wing_trigger then
		if cache == CacheFlag.CACHE_FLYING then
			player.CanFly = true     
		end

		player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/luc_wings.anm2"))

		if cache == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage + 2.5
		end
	else
		player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/luc_wings.anm2"))
	end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == EntityType.ENTITY_PLAYER and enthit:ToPlayer():HasCollectible(item.instance) then
		local player = enthit:ToPlayer()
		GODMODE.get_ent_data(player).luc_wing_trigger = true
		GODMODE.save_manager.set_player_data(player, "LucWingActive", true,true)
		
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FLYING)
		player:EvaluateItems()
	end
end

item.new_room = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player)
		local data = GODMODE.get_ent_data(player)
		data.luc_wing_trigger = false
		GODMODE.save_manager.set_player_data(player, "LucWingActive", false,true)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FLYING)
		player:EvaluateItems()
	end)
end

return item