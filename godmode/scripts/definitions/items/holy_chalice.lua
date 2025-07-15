local item = {}
item.instance = GODMODE.registry.items.holy_chalice
item.eid_description = "↑ Gives +10% damage per room cleared without taking damage, up to +40% damage#↓ Resets to +0% when taking damage"
item.eid_transforms = GODMODE.util.eid_transforms.ANGEL
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "If you clear a room without taking damage, grants +10% damage. This effect can stack 4 times for a maximum of +40% damage"},
		{str = "BFFs! adds a 1.666x damage modifier to the stat increase from this familiar, raising the maximum damage boost to +66.6% damage."},
	},
}


item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end
	local bonus = (data.chalice_level or 0) * player:GetCollectibleNum(item.instance) * 0.1

	if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then 
		bonus = bonus * 1.666 
	end

	if cache == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage * math.max(1 + bonus,1)
	end

	if cache == CacheFlag.CACHE_FAMILIARS then 
		player:CheckFamiliar(GODMODE.registry.entities.holy_chalice.variant, player:GetCollectibleNum(item.instance), player:GetCollectibleRNG(item.instance), Isaac.GetItemConfig():GetCollectible(item.instance))
	end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit:ToPlayer() and enthit:ToPlayer():HasCollectible(item.instance) and 
		not (flags & DamageFlag.DAMAGE_NO_PENALTIES == DamageFlag.DAMAGE_NO_PENALTIES 
			or flags & DamageFlag.DAMAGE_IV_BAG == DamageFlag.DAMAGE_IV_BAG 
			or flags & DamageFlag.DAMAGE_RED_HEARTS == DamageFlag.DAMAGE_RED_HEARTS and entsrc.Type == EntityType.ENTITY_SLOT) then
		local player = enthit:ToPlayer()
		GODMODE.get_ent_data(player).chalice_level = 0
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
		GODMODE.save_manager.set_player_data(player, "ChaliceLevel", GODMODE.get_ent_data(player).chalice_level,true)
	end
end

item.room_rewards = function(self,rng,pos)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player)
		local data = GODMODE.get_ent_data(player)
		data.chalice_level = math.min(4,(data.chalice_level or 0) + 1)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
		GODMODE.save_manager.set_player_data(player, "ChaliceLevel", GODMODE.get_ent_data(player).chalice_level,true)
	end)
end

return item