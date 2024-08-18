local item = {}
item.instance = GODMODE.registry.items.greedy_glance
item.eid_description = "#When your tears touch a bomb, key or coin you collect the pickup#When your tears touch an unlocked chest, opens the chest"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - When your tears touch a bomb, key or coin, you collect the pickup."},
      {str = " - When your tears touch an unlocked chest (regular, spiked, old and wooden) the chest gets opened."},
    },
}

local chests = {
	[PickupVariant.PICKUP_CHEST] = true,
	[PickupVariant.PICKUP_SPIKEDCHEST] = true,
	[PickupVariant.PICKUP_OLDCHEST] = true,
	[PickupVariant.PICKUP_WOODENCHEST] = true,
}

item.tear_update = function(self, tear, data)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer() or nil 

	if player and tear:IsFrame(3,1) and player:HasCollectible(item.instance) and data.celeste_tear ~= true then
		local pickups = Isaac.FindInRadius(tear.Position, tear.Size * 2, EntityPartition.PICKUP)

		if #pickups > 0 then 
			for _,ent in ipairs(pickups) do 
				if ent:ToPickup() then 
					local pickup = ent:ToPickup()
	
					if (pickup.Variant == PickupVariant.PICKUP_BOMB or pickup.Variant == PickupVariant.PICKUP_KEY or pickup.Variant == PickupVariant.PICKUP_COIN) and pickup.Price == 0 then 
						if player ~= nil and player:HasCollectible(item.instance) then 
							local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,ent.Position,Vector.Zero,ent)
							poof = poof:ToEffect()
							poof:GetSprite().Scale = Vector(0.5,0.5)
							ent.Position = player.Position
						end
					elseif chests[pickup.Variant] == true then 
						pickup:TryOpenChest(player)
					end
				end
			end
		end	
	end
end


return item