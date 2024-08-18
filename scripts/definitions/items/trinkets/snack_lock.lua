local item = {}
item.instance = GODMODE.registry.trinkets.snack_lock
item.eid_description = "Drop 3 random fruit on the start of each floor"
item.trinket = true
item.encyc_entry = {
    { -- Effects
        {str = "Effects", fsize = 2, clr = 3, halign = 0},
        {str = "- When traveling to a new floor, spawn 3 random fruit (+2 for additional trinket multiplier)."},
    },
}

item.new_level = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        for l=1,5+2*player:GetTrinketMultiplier(item.instance) do 
            Isaac.Spawn(GODMODE.registry.entities.fruit.type,GODMODE.registry.entities.fruit.variant,0,player.Position,RandomVector()*(player:GetCollectibleRNG(item.instance):RandomFloat()*4.0+1.5),nil)
        end
    end, true)
end

return item