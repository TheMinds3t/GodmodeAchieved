local item = {}
item.instance = Isaac.GetTrinketIdByName( "Marble Cake Pop" )
item.eid_description = "Swallow your currently held trinkets at the beginning of each floor"
item.trinket = true

item.new_level = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, true, true, false)
    end, true)
end

return item