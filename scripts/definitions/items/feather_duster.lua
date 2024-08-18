local item = {}
item.instance = GODMODE.registry.items.feather_duster
item.eid_description = "+0.1 Speed#Prevents negative door hazards from occurring#Walking over a web breaks it#Walking over a sticky nickel cleans it#Walking over a dirty carpet cleans it"
-- item.eid_transforms = GODMODE.util.eid_transforms.BOB
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "+0.1 movement speed."},
      {str = "Prevents negative door hazards from spawning."},
      {str = "Walking over webs will break the web beneath you."},
      {str = "Walking over sticky nickels will remove the stickiness, allowing you to pick them up."},
      {str = "Walking over dirty carpets in barren bedrooms will convert them into clean ones, allowing access to the crawlspace."},
    },
}

local carpet_size = 32

item.eval_cache = function(self, player,cache,data)
	if cache == CacheFlag.CACHE_SPEED then 
		player.MoveSpeed = player.MoveSpeed + 0.1 * player:GetCollectibleNum(item.instance)
	end
end

item.spawn_fx = function(self, pos)
	local dust = Isaac.Spawn(GODMODE.registry.entities.feather_dust.type,GODMODE.registry.entities.feather_dust.variant,GODMODE.registry.entities.feather_dust.subtype,pos,Vector.Zero,nil)
	dust.DepthOffset = 100
	dust:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
end

item.player_update = function(self, player)
	if player:HasCollectible(item.instance) then
		if not player:IsDead() and player:IsFrame(1,10) then
			if player:HasEntityFlags(EntityFlag.FLAG_SLOW) then 
				local grid = GODMODE.room:GetGridEntityFromPos(player.Position)
			
				if grid ~= nil and grid:GetType() == GridEntityType.GRID_SPIDERWEB and grid.State ~= 1 then 
					local pos = GODMODE.room:GetGridPosition(GODMODE.room:GetGridIndex(player.Position))
					item:spawn_fx(pos)
					grid:Destroy()
				end	
			end

			if GODMODE.room:GetType() == RoomType.ROOM_BARREN then 
				local carpets = Isaac.FindByType(EntityType.ENTITY_EFFECT,EffectVariant.ISAACS_CARPET,0)
				if carpets ~= nil and #carpets > 0 then 
					for _,carpet in ipairs(carpets) do
						if carpet.SpawnerVariant ~= 1 then 
							local dist = (player.Position-carpet.Position):Length()

							if dist < carpet_size then 
								-- GODMODE.log("hi!",true)
								carpet:GetSprite():ReplaceSpritesheet(0,"gfx/effects/isaaccarpet.png")
								carpet:GetSprite():LoadGraphics()
								item:spawn_fx(player.Position)
								carpet.SpawnerVariant = 1
							end								
						end
					end
				end

				local grid = GODMODE.room:GetGridEntityFromPos(GODMODE.room:GetCenterPos())

				if grid ~= nil and grid:GetType() == GridEntityType.GRID_TRAPDOOR then 
					local pos = grid.Position
					item:spawn_fx(pos)
					grid:Destroy()
					Isaac.GridSpawn(GridEntityType.GRID_STAIRS,0,pos,true)
				end	
			end
		end
	end
end

item.pickup_collide = function(self, pickup, ent2, entfirst)
	if ent2:ToPlayer() and ent2:ToPlayer():HasCollectible(item.instance) then 
		if pickup.Variant == PickupVariant.PICKUP_COIN and pickup.SubType == CoinSubType.COIN_STICKYNICKEL then 
			pickup:ToPickup():Morph(pickup.Type,pickup.Variant,CoinSubType.COIN_NICKEL,true,true)
			item:spawn_fx(pickup.Position)
			pickup.Wait = 20
		end
	
		if pickup.Variant == PickupVariant.PICKUP_BED and pickup.SpawnerVariant ~= 1 and GODMODE.room:GetType() == RoomType.ROOM_BARREN then 
			pickup:GetSprite():ReplaceSpritesheet(0,"gfx/items/pick ups/isaacbed.png")
			pickup:GetSprite():LoadGraphics()
			item:spawn_fx((ent2.Position+pickup.Position)/2)
			pickup.SpawnerVariant = 1
			return false
		end	
	end
end

return item