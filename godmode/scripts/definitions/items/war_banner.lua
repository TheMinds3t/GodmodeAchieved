local item = {}
item.instance = GODMODE.registry.items.war_banner
item.eid_description = "Placing a bomb places a banner that gives you either a +10% damage, +0.3 tears, or +0.1 shot speed buff while you stand in it's radius#+5 Bombs"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When a bomb you place explodes, a small banner with an aura is spawned at the location of the explosion. Banner effects stack."},
      {str = "While standing in the aura, you will be granted one of the following buffs:"},
      {str = "- Red: +10% damage."},
      {str = "- Blue: +0.3 tears."},
      {str = "- Yellow: +0.1 shot speed."},
    },
}

local banner_place_cooldown = 30

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end
	local bff_scale = 1.0

	if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then 
		bff_scale = 2.0
	end

	if (data.attack_banners or 0) > 0 then 
		if cache == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage*(1.0 + 0.1*data.attack_banners*player:GetCollectibleNum(item.instance)*bff_scale)
		end	
	end
	if (data.speed_banners or 0) > 0 then 
		if cache == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.3*data.speed_banners*player:GetCollectibleNum(item.instance)*bff_scale, true)
		end	
	end
	if (data.shotspeed_banners or 0) > 0 then 
		if cache == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed+0.1*data.shotspeed_banners*player:GetCollectibleNum(item.instance)*bff_scale
		end	
	end
end

item.auras = {"Red","Yellow","Blue"}

item.explode_frame = function(self, ent, data, sprite, effect, explode_pos, explode_size, collided)
	if effect.SpawnerEntity ~= nil and (effect.SpawnerEntity.Type == EntityType.ENTITY_BOMB or effect.SpawnerEntity.Type == EntityType.ENTITY_EFFECT and effect.SpawnerEntity.Variant == EffectVariant.ROCKET) then 
		local bomb = effect.SpawnerEntity
		
		if bomb.SpawnerEntity ~= nil and bomb.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
			local player = bomb.SpawnerEntity:ToPlayer()
			local dat = GODMODE.get_ent_data(player)

			if player:HasCollectible(item.instance) and dat and (dat.banner_time or banner_place_cooldown) == 0 then
				local banner = Isaac.Spawn(GODMODE.registry.entities.war_banner.type, GODMODE.registry.entities.war_banner.variant, 0, bomb.Position, Vector.Zero, bomb.SpawnerEntity)
				local aura = Isaac.Spawn(GODMODE.registry.entities.war_banner.type, GODMODE.registry.entities.war_banner.variant, player:GetCollectibleRNG(item.instance):RandomInt(3)+1, bomb.Position, Vector.Zero, bomb.SpawnerEntity)
				banner.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
				aura.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
				banner:GetSprite():Play("WarBannerAppear",true)
				aura:GetSprite():Play(item.auras[aura.SubType].."AuraAppear",true)
				dat.banner_time = banner_place_cooldown

				if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then 
					GODMODE.get_ent_data(banner).bff_flag = true
					GODMODE.get_ent_data(aura).bff_flag = true
				end
			end
		end
	end
end

item.player_update = function(self,player,data,sprite)
	if (data.banner_time or 0) > 0 then 
		data.banner_time = data.banner_time - 1
	else data.banner_time = nil end 
end

item.new_room = function()
	GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
		local data = GODMODE.get_ent_data(player)
		data.attack_banners = 0 
		data.speed_banners = 0 
		data.shotspeed_banners = 0
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SHOTSPEED)
		player:EvaluateItems()
	end)
end

return item