local item = {}
item.instance = Isaac.GetTrinketIdByName( "Mood Ring (Black)" )
item.eid_description = "#Resets to Mood Ring (Green) each stage"
item.trinket = true

item.new_level = function(self)
    local red = Isaac.GetTrinketIdByName("Mood Ring (Green)")
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        GODMODE.log("hi!",true)
        player:TryRemoveTrinket(item.instance)
        player:AddTrinket(red)

        if not player:HasTrinket(red) then 
            Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,red,Game():GetRoom():FindFreePickupSpawnPosition(player.Position),Vector.Zero,nil)
        end
    end, true)
end

return item