local item = {}
item.instance = GODMODE.registry.items.hysteria
item.eid_description = "↑ +0.05 Fire Delay per living enemy or boss#↑ +0.25 Tears per living boss"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - For every living enemy and boss in the room, +0.05 Fire Delay."},
      {str = " - For every living boss in the room, +0.25 Tears."},
    },
    { -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
	  {str = "Stacking this item gives an additional +0.025 Fire Delay per enemy or boss and +0.125 Tears per boss per extra instance held."}
    },
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

    if cache == CacheFlag.CACHE_FIREDELAY then
        local buff = (Isaac.CountEnemies()+Isaac.CountBosses()) * 0.05
        local add = Isaac.CountBosses() * 0.25
        local scale = math.max(0,player:GetCollectibleNum(item.instance) - 1) * 0.5 + math.min(1,player:GetCollectibleNum(item.instance))
        player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,buff*scale,true)
        player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,add*scale)
    end
end

item.npc_remove = function(self,ent)
    if ent:ToNPC() then 
        GODMODE.util.macro_on_players_that_have(item.instance,function(player) 
            GODMODE.get_ent_data(player).hysteria_timeout = 5
        end)
    end
end

item.player_update = function(self,player, data)
    if player:HasCollectible(item.instance) then 

        if (data.hysteria_timeout or 0) > 0 then 
            data.hysteria_timeout = (data.hysteria_timeout or 0) - 1
    
            if data.hysteria_timeout == 0 then 
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
                player:EvaluateItems()
            end
        end    
    end
end

item.npc_init = function(self,npc,data)
    GODMODE.util.macro_on_players_that_have(item.instance,function(player) 
        GODMODE.get_ent_data(player).hysteria_timeout = 5
    end)
end

return item