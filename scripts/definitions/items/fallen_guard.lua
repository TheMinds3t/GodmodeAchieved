local item = {}
item.instance = GODMODE.registry.items.fallen_guardian
item.eid_description = "Summons a mini Furnace Knight to fight for you, dealing (15% Damage + 1.3) contact damage# Gets enraged the longer its target is alive"
item.eid_transforms = GODMODE.util.eid_transforms.CONJOINED
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "A familiar that deals 15% of your damage + 1.3 per tick to any enemy in contact with it"},
      {str = "Once it selects a target, it will pursue that target until it is dead, getting faster and more precise the longer the target lives"},
    },
}

item.eval_cache = function(self,player,cache)
  if cache == CacheFlag.CACHE_FAMILIARS then 
    player:CheckFamiliar(GODMODE.registry.entities.fallen_guard_familiar.variant, player:GetCollectibleNum(item.instance), player:GetCollectibleRNG(item.instance), Isaac.GetItemConfig():GetCollectible(item.instance))
  end
end

return item