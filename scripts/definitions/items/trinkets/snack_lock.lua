local item = {}
item.instance = Isaac.GetTrinketIdByName( "Snack Lock" )
item.eid_description = "Drop 3 random fruit on the start of each floor"
item.trinket = true

item.new_level = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        for l=1,1+2*player:GetTrinketMultiplier(item.instance) do 
            Isaac.Spawn(Isaac.GetEntityTypeByName("Fruit (Pickup)"),Isaac.GetEntityVariantByName("Fruit (Pickup)"),0,player.Position,RandomVector()*(player:GetCollectibleRNG(item.instance):RandomFloat()*4.0+1.5),nil)
        end
    end, true)
end

return item