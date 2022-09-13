local item = {}
item.instance = Isaac.GetItemIdByName( "Holy Chalice" )
item.eid_description = "↑ Gives +0.75 damage per room cleared without taking damage, up to +4 damage#↓ Resets to 0 when taking damage"
item.eid_transforms = GODMODE.util.eid_transforms.ANGEL
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "If you clear a room without taking damage, grants +0.75 damage. This effect can stack 4 times for a maximum of +3 damage"},
		{str = "BFFs! adds a 1.666x damage modifier to the stat increase from this familiar, raising the maximum damage boost to +5 damage."},
	},
}

item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end

	local data = GODMODE.get_ent_data(player)
	local bonus = (data.chalice_level or 0) * player:GetCollectibleNum(item.instance) * 0.75

	if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then 
		bonus = bonus * 1.666 
	end

	if cache == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + bonus
	end
end

item.player_update = function(self,player)
	player:CheckFamiliar(Isaac.GetEntityVariantByName("Holy Chalice"), player:GetCollectibleNum(item.instance), player:GetCollectibleRNG(item.instance), Isaac.GetItemConfig():GetCollectible(item.instance))
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