local transform = include("scripts.definitions.items.transformations.transform")
transform.instance = "Cyborg"
transform.transformation = true
transform.eid_transform = GODMODE.util.eid_transforms.CYBORG
transform.cache_flags = CacheFlag.CACHE_SPEED | CacheFlag.CACHE_DAMAGE
transform.custom_itemtag = "cyborg"
transform.costume = GODMODE.registry.costumes.cyborg
transform.items = {
	[GODMODE.registry.items.gold_plated_battery] = true,
	[CollectibleType.COLLECTIBLE_9_VOLT] = true,
	[CollectibleType.COLLECTIBLE_BATTERY] = true,
	[CollectibleType.COLLECTIBLE_CAR_BATTERY] = true,
	[CollectibleType.COLLECTIBLE_JACOBS_LADDER] = true,
	[CollectibleType.COLLECTIBLE_JUMPER_CABLES] = true,
	[CollectibleType.COLLECTIBLE_DOCTORS_REMOTE] = true,
	[CollectibleType.COLLECTIBLE_TECHNOLOGY] = true,
	[CollectibleType.COLLECTIBLE_TECHNOLOGY_2] = true,
	[CollectibleType.COLLECTIBLE_TECH_5] = true,
	[CollectibleType.COLLECTIBLE_TECH_X] = true,
	[CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO] = true,
	[CollectibleType.COLLECTIBLE_METAL_PLATE] = true,
	[CollectibleType.COLLECTIBLE_ANALOG_STICK] = true,
	[CollectibleType.COLLECTIBLE_BROKEN_MODEM] = true,
	[GODMODE.registry.items.jack_of_all_trades] = true,
}

local has_cyborg = function(player)
	return GODMODE.save_manager.get_player_data(player,"Cyborg","false") == "true"
end

transform.eval_cache = function(self, player,cache,data)
	if has_cyborg(player) then
		if cache == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed - 0.1
			player:TryRemoveNullCostume(GODMODE.registry.costumes.cyborg)
			player:AddNullCostume(GODMODE.registry.costumes.cyborg)
		end

		if cache == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 1.1
		end
	end
end

transform.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if has_cyborg(player) then 
		local config = Isaac.GetItemConfig():GetCollectible(coll)

		if config.MaxCharges > 0 then
			local count = 8

			for i=1,count do 
				local ang = math.rad(360/count*i)
				local vel = Vector(math.cos(ang),math.sin(ang))*2.0
				local rocket = Isaac.Spawn(EntityType.ENTITY_BOMBDROP, BombVariant.BOMB_SMALL, 0, player.Position, vel*3, player):ToBomb()
				rocket.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
				rocket:GetSprite():Play("Appear",false)
				rocket:SetExplosionCountdown(20*2+rocket:GetDropRNG():RandomInt(15))
				rocket.RadiusMultiplier = 0.75
				rocket.ExplosionDamage = player.Damage * 0.125 + 10
			end
		end
	end
end

transform.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit:ToPlayer() then 
		local player = enthit:ToPlayer()
		local data = GODMODE.get_ent_data(player)

		if has_cyborg(player) then 
			if flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION or flags & DamageFlag.DAMAGE_CRUSH == DamageFlag.DAMAGE_CRUSH then 
				return false
			end
		end
	end
end

return transform