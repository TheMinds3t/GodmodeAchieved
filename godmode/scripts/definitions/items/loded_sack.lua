local item = {}
item.instance = GODMODE.registry.items.loded_sack
item.eid_description = "Every 3 rooms spawns 3-4 friendly dips"
item.eid_transforms = nil
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Every 3 rooms cleared will spawn 3-4 friendly dips from the sack."},
		{str = "No direct interaction with BFFs!, but the item will buff the friendly dips spawned."},
	},
}

item.eval_cache = function(self, player,cache,data)
	if cache == CacheFlag.CACHE_FAMILIARS then 
		player:CheckFamiliar(GODMODE.registry.entities.loded_sack.variant, 
			math.min(1,player:GetCollectibleNum(item.instance)+player:GetEffects():GetCollectibleEffectNum(item.instance)), 
			player:GetCollectibleRNG(item.instance), Isaac.GetItemConfig():GetCollectible(item.instance))
	end
end

return item