local item = {}
item.instance = GODMODE.registry.items.eggnog
item.eid_description = "↑ +2 Max Hearts#↑ Heals 4 Red Hearts#↑ +3 Luck"
item.binge_eid_description = "↑ +2 Max Hearts#↑ Heals 4 Red Hearts#↑ +3 Luck#↑ +10% Damage"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - Plus 2 Max Red hearts."},
      {str = " - Heals 4 Red hearts."},
      {str = " - +3 Luck"},
    },
    { -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
	  {str = "Gives +10% Damage if Binge Eater is held"}
    },
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end
    local num = player:GetCollectibleNum(item.instance)
    local binge = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BINGE_EATER) > 0
    local amt = 0.1 * num

    if cache == CacheFlag.CACHE_LUCK then 
            player.Luck = player.Luck + math.min(1,num) + 2 * num
    elseif cache == CacheFlag.CACHE_DAMAGE and binge then 
        player.Damage = player.Damage + math.max(0.25*num,player.Damage * amt)
    end
end

item.post_get_collectible = function(self, coll,pool,decrease,seed)
    local total_count = GODMODE.util.total_item_count(self.instance)
    local total_players = GODMODE.util.get_num_players()

    if pool == ItemPoolType.POOL_BOSS and GODMODE.christmas_mode == true and decrease == true and total_count < total_players then 
      return item.instance
    end
end

return item