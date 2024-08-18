local item = {}
item.instance = GODMODE.registry.trinkets.shattered_moonrock
item.eid_description = "When entering a new stage:#2 Fatal Attraction stat exchange stations spawns#If Fatal Attraction is held, the stat debuffs are 2.5% weaker"
item.trinket = true
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "Two Fatal Attraction stations spawn in the starting room of each new stage."},
      {str = "If Fatal Attraction is held, stat debuffs are 2.5% weaker."},
    },
}

item.get_trinket = function(self,trinket,rng)
    if trinket == item.instance and not GODMODE.is_in_observatory() then 
        return rng:RandomInt(TrinketType.NUM_TRINKETS-1)+1
    end
end

item.choose_curse = function(self,curses)
    local players = GODMODE.util.does_player_have(item.instance,true,true)
    
    if #players > 0 and #GODMODE.util.get_curse_list(false) == 0 and players[1]:GetTrinketRNG(item.instance):RandomFloat() <= 0.1 then 
        return GODMODE.util.get_shifted_curse(GODMODE.util.get_random_curse(players[1]:GetTrinketRNG(item.instance)))
    end
end

return item