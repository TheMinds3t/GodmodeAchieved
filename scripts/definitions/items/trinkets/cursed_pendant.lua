local item = {}
item.instance = GODMODE.registry.trinkets.cursed_pendant
item.eid_description = "#↑ +10% Damage#↑ +0.2 Speed#↓ 10% chance to add a curse to a floor that would be curse-free"
item.trinket = true
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "+10% damage and +0.2 movement speed."},
      {str = "If a curse is not selected for a floor, 10% chance to add a curse."},
    },
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasTrinket(item.instance) then return end

    if cache == CacheFlag.CACHE_DAMAGE then 
        player.Damage = player.Damage * 1.1
    elseif cache == CacheFlag.CACHE_SPEED then 
        player.MoveSpeed = player.MoveSpeed + 0.2
    end
end

item.get_trinket = function(self,trinket,rng)
    if trinket == item.instance and not GODMODE.is_in_observatory() then 
        return rng:RandomInt(TrinketType.NUM_TRINKETS-1)+1
    end
end

item.new_level = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance,function(player) 
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
    end,true)
end

item.player_update = function(self, player)
    if player:HasTrinket(item.instance, true) and GODMODE.is_in_observatory() then 
        player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, true, true, false)
    end
end

item.choose_curse = function(self,curses)
    local players = GODMODE.util.does_player_have(item.instance,true,true)
    
    if #players > 0 and #GODMODE.util.get_curse_list(false) == 0 and players[1]:GetTrinketRNG(item.instance):RandomFloat() <= 0.1 then 
        return GODMODE.util.get_shifted_curse(GODMODE.util.get_random_curse(players[1]:GetTrinketRNG(item.instance)))
    end
end

return item