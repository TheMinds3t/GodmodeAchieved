local item = {}
item.instance = Isaac.GetItemIdByName( "Four Leaf Clover" )
item.eid_description = "↑ +2.0 luck#↑ +0.25*luck damage#↑ +0.25*luck tears"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "Grants +0.25 damage per luck and +0.25 tears per luck"},
      {str = "Grants +2 luck"},
    },
}

item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end

	local luck_bonus = 2

	if cache == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + luck_bonus*player:GetCollectibleNum(item.instance)
	end
	
	if cache == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + math.max(0,(player.Luck+luck_bonus) * 0.25)
	end

	if cache == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,math.max(0, (player.Luck+luck_bonus) * 0.25)*player:GetCollectibleNum(item.instance))
	end
end

item.pickup_collide = function(self, pickup,ent,entfirst)
	if ent:ToPlayer() and ent:ToPlayer():HasCollectible(item.instance) and not entfirst then
		ent:ToPlayer():AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
		ent:ToPlayer():EvaluateItems()
    end
end

item.new_room = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
		player:AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
	end)
end

return item