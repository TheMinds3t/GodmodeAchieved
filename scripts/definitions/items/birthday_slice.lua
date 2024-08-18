local item = {}
item.instance = GODMODE.registry.items.birthday_slice
item.eid_description = "↑ +5% All Stats#↑ Heals 2 Red Hearts#↑ +1 Soul Heart"
item.binge_eid_description = "↑ +7.5% All Stats#↑ Heals 2 Red Hearts#↑ +1 Soul Heart"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - +5% Damage, Tears, Range, Movement Speed, and Shot Speed."},
      {str = " - Heals 2 Red hearts."},
      {str = " - +1 Soul Heart"},
    },
    { -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
	  {str = "Gives an additional 2.5% to all stats per Binge Eater held"}
    },
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end
    local num = player:GetCollectibleNum(item.instance)
    local amt = 0.05 * num + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BINGE_EATER) * 0.025

    if cache == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay, player.MaxFireDelay * amt)
    elseif cache == CacheFlag.CACHE_DAMAGE then 
        player.Damage = player.Damage + math.max(0.25*num,player.Damage * amt)
    elseif cache == CacheFlag.CACHE_SPEED then 
        player.MoveSpeed = player.MoveSpeed + math.max(0.1*num,player.MoveSpeed * amt)
      elseif cache == CacheFlag.CACHE_LUCK then 
        if player.Luck < 0 then 
            player.Luck = player.Luck + math.max(0.5*num,player.Luck * -amt)
        else
            player.Luck = player.Luck + math.max(0.5*num,player.Luck * amt)
        end
    elseif cache == CacheFlag.CACHE_RANGE then 
      player.TearRange = player.TearRange + math.max(0.5*num,player.TearRange * amt)
    elseif cache == CacheFlag.CACHE_SHOTSPEED then 
        player.ShotSpeed = player.ShotSpeed + math.max(0.05*num,player.ShotSpeed * amt)
    end
end

item.post_get_collectible = function(self, coll,pool,decrease,seed)
    if pool == ItemPoolType.POOL_BOSS and GODMODE.birthday_mode == true and decrease == true then 
      return item.instance
    end
end

return item