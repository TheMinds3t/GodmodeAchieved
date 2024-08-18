local item = {}
item.instance = GODMODE.registry.items.angel_food
item.eid_description = "↑ +1 Golden Soul Heart #↑ +0.5 Tears#↑ +20% Gilded chance"
item.binge_eid_description = "↑ +1 Golden Soul Heart #↑ +0.5 Tears#↑ +2 Range"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - Adds one golden soul heart."},
      {str = " - +0.5 tears."},
      {str = " - +20% Gilded chance (decaying, flat percent to convert basic pickups into their golden variants)."},
    },
    { -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
	  {str = "Additionally gives +2 range if Binge Eater is held."}
    },
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

    data.num_angel_food = tonumber(GODMODE.save_manager.get_player_data(player, "NumAngelFood", "0"))

    if data.num_angel_food < player:GetCollectibleNum(item.instance) then
        player:AddGoldenHearts(1)
        GODMODE.save_manager.set_data("GildedChance", math.min(tonumber(GODMODE.save_manager.get_data("GildedChance","0.0")) + 0.2,1),true)
        data.num_angel_food = (data.num_angel_food or 0) + 1
        GODMODE.save_manager.set_player_data(player, "NumAngelFood", data.num_angel_food,true)
    end

    if cache == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.5*player:GetCollectibleNum(item.instance))
    end

    if player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) and cache == CacheFlag.CACHE_RANGE then
		player.TearRange = player.TearRange - 2
	end
end

return item