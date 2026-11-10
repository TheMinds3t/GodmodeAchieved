local item = {}
item.instance = GODMODE.registry.items.placeholder
item.eid_description = "Familiar that bounces diagonally#Deals 8 damage per tick#Rerolls pickups and chests while in uncleared rooms"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "A familiar identical to the Afterbirth version of the GB Bug item:"},
      {str = "Diagonally bouncing, 8 damage per tick familiar. Deals 120 damage/second"},
      {str = "If the [PLACEHOLDER] touches an enemy, it will apply a random debuff for 5 seconds. DOT debuffs deal 5 damage a tick."},
    },
}

item.eval_cache = function(self, player,cache,data)
	if cache == CacheFlag.CACHE_FAMILIARS then 
		player:CheckFamiliar(GODMODE.registry.entities.placeholder.variant, player:GetCollectibleNum(item.instance), player:GetCollectibleRNG(item.instance), Isaac.GetItemConfig():GetCollectible(item.instance))
	end
end

return item