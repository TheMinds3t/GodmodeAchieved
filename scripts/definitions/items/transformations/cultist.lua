local transform = include("scripts.definitions.items.transformations.transform")
transform.instance = "Cultist"
transform.transformation = true
transform.eid_transform = GODMODE.util.eid_transforms.CULTIST
transform.cache_flags = CacheFlag.CACHE_FLYING

transform.items = {
	[Isaac.GetItemIdByName("Adramolech's Blessing")] = true,
	[CollectibleType.COLLECTIBLE_CANDLE] = true,
	[CollectibleType.COLLECTIBLE_BLACK_CANDLE] = true,
	[CollectibleType.COLLECTIBLE_RED_CANDLE] = true,
	[CollectibleType.COLLECTIBLE_PASCHAL_CANDLE] = true,
	[CollectibleType.COLLECTIBLE_PYROMANIAC] = true,
	[CollectibleType.COLLECTIBLE_HOT_BOMBS] = true,
	[CollectibleType.COLLECTIBLE_VENGEFUL_SPIRIT] = true,
	[CollectibleType.COLLECTIBLE_FIRE_MIND] = true,
	[CollectibleType.COLLECTIBLE_EXPLOSIVO] = true,
	[CollectibleType.COLLECTIBLE_SMELTER] = true,
	[Isaac.GetItemIdByName("Jack-of-all-Trades")] = true,
}

local has_cultist = function(player)
	return GODMODE.save_manager.get_player_data(player,"Cultist","false") == "true"
end

transform.eval_cache = function(self, player,cache)
	if GODMODE.save_manager.get_player_data(player,"Cultist","false") == "true" or Isaac.GetChallenge() == Isaac.GetChallengeIdByName("The Galactic Approach") then
		if cache == CacheFlag.CACHE_FLYING then
			player.CanFly = true
		end
	end
end

transform.has_cultist = function(self, player,cache)
	if has_cultist(player) then

		if cache == CacheFlag.CACHE_FLYING then
			player.CanFly = true
		end
	end
end

transform.transform_update = function(self, player)
	if player:IsFrame(1,30) and GODMODE.util.count_enemies(player, Isaac.GetEntityTypeByName("Ritual Candle (Familiar)"), Isaac.GetEntityVariantByName("Ritual Candle (Familiar)")) == 0 then 
		player:CheckFamiliar(Isaac.GetEntityVariantByName("Ritual Candle (Familiar)"), 1, player:GetCollectibleRNG(Isaac.GetItemIdByName("Jack-of-all-Trades")), nil)
	end
end

return transform