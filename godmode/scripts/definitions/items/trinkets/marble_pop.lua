local item = {}
item.instance = GODMODE.registry.trinkets.cake_pop
item.eid_description = "Swallow your currently held trinkets at the beginning of each floor"
item.trinket = true
item.encyc_entry = {
    { -- Effects
        {str = "Effects", fsize = 2, clr = 3, halign = 0},
        {str = "- When traveling to a new floor, swallow all currently held trinkets."},
        {str = "- Since this trinket gets swallowed as well, this effect persists for the rest of the run."},
    },
}

item.new_level = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, true, true, false)
    end, true)
end

return item