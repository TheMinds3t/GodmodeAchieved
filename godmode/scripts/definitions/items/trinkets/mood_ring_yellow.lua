local item = {}
item.instance = GODMODE.registry.trinkets.mood_ring_yellow
item.eid_description = "Prevents one damaging projectile spawned by Call of the Void#Resets to Mood Ring (Blue) each stage"
item.trinket = true
item.encyc_entry = {
    { -- Effects
        {str = "Effects", fsize = 2, clr = 3, halign = 0},
        {str = "- On entering a new level, this trinket turns into Mood Ring (Blue)."},
        {str = "- If Call of the Void spawns on the stage, getting hit by any of its projectiles gets nullified and this trinket turns into Mood Ring (Green)."},
    },
}

item.new_level = function(self)
    local blue = GODMODE.registry.trinkets.mood_ring_blue
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        player:TryRemoveTrinket(item.instance)
        player:AddTrinket(blue)

        if not player:HasTrinket(blue) then 
            Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,blue,GODMODE.room:FindFreePickupSpawnPosition(player.Position),Vector.Zero,nil)
        end
    end, true)
end

return item