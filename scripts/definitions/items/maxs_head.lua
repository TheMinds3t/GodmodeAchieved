local item = {}
item.instance = Isaac.GetItemIdByName( "Max's Head" )
item.eid_description = "On use:#↑ +25% Damage#↓ -10% Firerate#↓ -5% Speed#Can be used up to 5 times in a room for increased effects"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "On use, grants +25% damage, -10% firerate, and -5% speed for the room."},
		{str = "The item can be used up to 5 times, granting +125% damage, -50% firerate, -25% speed for the current room."},
		{str = "After leaving the room, the modifiers are removed until the item is used again."},
	},
}

item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end

	local data = GODMODE.get_ent_data(player)
	if not data.max_head_charge then data.max_head_charge = 0 end
	if cache == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage * (1.0 + data.max_head_charge / 4)
	end
    if cache == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = math.floor(player.MaxFireDelay * (1.0 + data.max_head_charge / 10.0))
    end
    if cache == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed * (1.0 - data.max_head_charge / 20.0)
    end

    if data.max_head_charge > 0 then
    	if data.max_head_charge > 1 then
    		player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath(tostring("gfx/costumes/maxs_head_"..(data.max_head_charge-1)..".anm2")))
    	end
    	player:AddNullCostume(Isaac.GetCostumeIdByPath(tostring("gfx/costumes/maxs_head_"..data.max_head_charge..".anm2")))
	end
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
		local data = GODMODE.get_ent_data(player)
		if not data.max_head_charge then data.max_head_charge = 0 end
		if data.max_head_charge < 5 then 
			data.max_head_charge = data.max_head_charge + 1 
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
		end

		return true
	end
end

item.new_room = function(self)

	GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
		local data = GODMODE.get_ent_data(player)
		if data.max_head_charge and data.max_head_charge > 0 then
			player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath(tostring("gfx/costumes/maxs_head_"..(data.max_head_charge)..".anm2")))
		end
		data.max_head_charge = 0
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
	end)
	
end

return item