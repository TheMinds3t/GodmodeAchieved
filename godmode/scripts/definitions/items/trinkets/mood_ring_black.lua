local item = {}
item.instance = GODMODE.registry.trinkets.mood_ring_black
item.eid_description = "#Resets to Mood Ring (Green) each stage"
item.trinket = true
item.encyc_entry = {
    { -- Effects
        {str = "Effects", fsize = 2, clr = 3, halign = 0},
        {str = "- When traveling to a new floor, this trinket turns into Mood Ring (Green)."},
    },
}

item.new_level = function(self)
    local red = GODMODE.registry.trinkets.mood_ring_green
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        player:TryRemoveTrinket(item.instance)
        player:AddTrinket(red)

        if not player:HasTrinket(red) then 
            Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,red,GODMODE.room:FindFreePickupSpawnPosition(player.Position),Vector.Zero,nil)
        end
    end, true)
end

return item