local item = {}
item.instance = GODMODE.registry.trinkets.white_candle
item.eid_description = "Additional 5% chance for blessings to occur"
item.trinket = true
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "Adds a 10% chance for blessings to occur when entering a new stage"},
    },
}

item.get_trinket = function(self,trinket,rng)
    if trinket == item.instance and not GODMODE.is_in_observatory() then 
        return rng:RandomInt(TrinketType.NUM_TRINKETS-1)+1
    end
end

item.player_update = function(self, player)
    if player:HasTrinket(item.instance, true) and GODMODE.is_in_observatory() then 
        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, true, true, false)
    end
end


return item