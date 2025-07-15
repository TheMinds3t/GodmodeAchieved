local item = {}
item.instance = GODMODE.registry.trinkets.cracked_nazar
item.eid_description = "50% chance to remove curses when entering a new stage"
item.trinket = true
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When entering a new stage, 50% chance to remove any active curses"},
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


item.choose_curse = function(self,curses)
    local players = GODMODE.util.does_player_have(item.instance,true,true)
    
    if #players > 0 and #GODMODE.util.get_curse_list(false) > 0 and players[1]:GetTrinketRNG(item.instance):RandomFloat() <= 0.5 then 
        return LevelCurse.CURSE_NONE
    end
end

return item