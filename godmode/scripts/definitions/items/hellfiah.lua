local item = {}
item.instance = GODMODE.registry.items.hellfiah
item.eid_description = "#Familiar that charges or partial charges to breathe fire#The longer he breathes fire the stronger the flames get#Charge indicated by coloration"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "A familiar that can breathe fire. The fire gets stronger the longer you charge the attack for, but can be released with partial charge."},
		{str = "After a certain charge time, begins flashing blue which indicates a couple longer lasting, weaker blue flames will spawn at the start of the next attack."},
		{str = "BFFs! Makes each red flame have a 66% chance to become a blue flame, increasing by 33% for the next roll if not."},
	},
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_FAMILIARS then 
		player:CheckFamiliar(GODMODE.registry.entities.hellfiah_familiar.variant, player:GetCollectibleNum(item.instance), player:GetCollectibleRNG(item.instance), Isaac.GetItemConfig():GetCollectible(item.instance))
	end
end

return item