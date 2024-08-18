local item = {}
item.instance = GODMODE.registry.items.fruit_salad
item.eid_description = "↑ +1 Max Heart #↑ +2 Hearts#↑ +1 Soul Heart#↑ 8 random fruit spawn on pickup"
-- item.eid_transforms = GODMODE.util.eid_transforms.ANGEL
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "On pickup, grants +1 max hearts, +2 red health and +1 soul heart as well as spawning 8 fruits."},
      {str = "Each fruit grants a small stat up that lasts for 5 minutes."},
    },
}

item.player_update = function(self, player)
    if player:IsFrame(20,1) then 
        local count = tonumber(GODMODE.save_manager.get_player_data(player,"FruitSalad","0"))

        if player:GetCollectibleNum(item.instance) > count then
            GODMODE.save_manager.set_player_data(player,"FruitSalad",player:GetCollectibleNum(item.instance),true)
    
            for i=0,(player:GetCollectibleNum(item.instance) - count) do 
                for l=0,3 do 
                    Isaac.Spawn(GODMODE.registry.entities.fruit.type,GODMODE.registry.entities.fruit.variant,0,player.Position,RandomVector()*(player:GetCollectibleRNG(item.instance):RandomFloat()*4.0+1.5),nil)
                end
            end
        end    
    end
end

return item