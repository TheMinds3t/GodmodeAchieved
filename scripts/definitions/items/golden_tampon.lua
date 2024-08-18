local item = {}
item.instance = GODMODE.registry.items.cloth_of_gold
item.eid_description = "Increases strength of Cloth on a String damage bonus by 25%#+25% Damage#+25% Gilded chance"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Increases the damage strength of Cloth on a String by 25%."},
		{str = "+25% Damage."},
		{str = "+25% Gilded chance (decaying, flat percent to convert basic pickups into their golden variants) on initial pick up."},
	},
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if tonumber(GODMODE.save_manager.get_player_data(player, "NumGoldTampon", "0")) < player:GetCollectibleNum(item.instance) then
        player:AddGoldenHearts(1)
        GODMODE.save_manager.set_data("GildedChance", math.min(tonumber(GODMODE.save_manager.get_data("GildedChance","0.0")) + 0.25,1),true)
        GODMODE.save_manager.set_player_data(player, "NumGoldTampon", player:GetCollectibleNum(item.instance), true)
    end

	if cache == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage * 1.25
	end
end

return item