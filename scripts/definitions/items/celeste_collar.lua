local item = {}
item.instance = Isaac.GetItemIdByName( "Celestial Collar" )
item.eid_description = "15% chance for treasure, boss and shop items to be replaced with 1up!#↑ x1.1 Damage per extra life"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - Grants a 15% chance for treasure, boss and shop items to be replaced with a 1up! instead"},
      {str = " - For each life the player possesses, gain an additional 1.1x damage multiplier."},
    },
}
item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end

    if cache == CacheFlag.CACHE_DAMAGE then
        local num = player:GetExtraLives()
        while num > 0 do
            player.Damage = player.Damage * (1 + 0.1 * player:GetCollectibleNum(item.instance))
            num = num - 1
        end
    end
end

item.pickup_collide = function(self, pickup,ent,entfirst)
	if ent:ToPlayer() and ent:ToPlayer():HasCollectible(item.instance) and ent:ToPlayer().SubType ~= PlayerType.PLAYER_CAIN_B and (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM) then
        ent:ToPlayer():AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        ent:ToPlayer():EvaluateItems()
    end
end

item.player_update = function(self, player)
    if player:IsFrame(30,1) and player:HasCollectible(item.instance) then 
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end
end

item.post_get_collectible = function(self,coll,pool,decrease,seed)
    local count = GODMODE.util.total_item_count(item.instance)

    if count > 0 then
        if pool == ItemPoolType.POOL_BOSS or pool == ItemPoolType.POOL_TREASURE or pool == ItemPoolType.POOL_SHOP then
            --GODMODE.log("replaced?",true)
            if Isaac.GetPlayer():GetCollectibleRNG(item.instance):RandomFloat() < count * 0.15 then
                --GODMODE.log("replaced!",true)
                return CollectibleType.COLLECTIBLE_ONE_UP
            end
        end
    end
end

return item