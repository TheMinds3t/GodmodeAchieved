local item = {}
item.instance = GODMODE.registry.items.soul_food
item.eid_description = "+2 Soul Hearts#↑ +1 Luck"
item.binge_eid_description = "+2 Soul Hearts#↑ +1 Luck#↑ +0.2 Speed"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - +2 soul hearts."},
      {str = " - +1 luck."},
    },
    { -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
	  {str = "Additionally gives +0.2 speed if Binge Eater is held."}
    },
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end


	if cache == CacheFlag.CACHE_SPEED and player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then
		player.MoveSpeed = player.MoveSpeed + 0.2 * player:GetCollectibleNum(item.instance)
	end

	if cache == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + player:GetCollectibleNum(item.instance)
	end
end




return item