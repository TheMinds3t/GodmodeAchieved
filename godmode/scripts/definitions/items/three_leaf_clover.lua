local item = {}
item.instance = GODMODE.registry.items.three_leaf_clover
item.eid_description = "↑ +3 Luck#↑ +0.1 Shot Speed"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - +3 Luck"},
      {str = " - +0.1 Shot Speed"},
    },
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end
    local num = player:GetCollectibleNum(item.instance) + player:GetEffects():GetCollectibleEffectNum(item.instance)

    if cache == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + 3 * num
    end

    if cache == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + 0.1 * num
    end
end

return item