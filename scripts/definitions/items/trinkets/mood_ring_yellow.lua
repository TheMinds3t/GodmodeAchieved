local item = {}
item.instance = Isaac.GetTrinketIdByName( "Mood Ring (Yellow)" )
item.eid_description = "Prevents one damaging projectile spawned by Call of the Void#Resets to Mood Ring (Blue) each stage"
item.trinket = true

item.new_level = function(self)
    local blue = Isaac.GetTrinketIdByName("Mood Ring (Blue)")
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        player:TryRemoveTrinket(item.instance)
        player:AddTrinket(blue)

        if not player:HasTrinket(blue) then 
            Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,blue,Game():GetRoom():FindFreePickupSpawnPosition(player.Position),Vector.Zero,nil)
        end
    end, true)
end

return item