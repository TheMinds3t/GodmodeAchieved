local item = {}
item.instance = Isaac.GetItemIdByName( "Forbidden Knowledge" )
item.eid_description = "When picking up a red heart, spawn:#20% chance for bomb#15% chance for key#40% chance for coin#25% chance for nothing"
item.eid_transforms = GODMODE.util.eid_transforms.BOOKWORM
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When picking up a red heart, create one of the following:"},
      {str = "- 20% chance to create a bomb"},
      {str = "- 15% chance to create a key"},
      {str = "- 40% chance to create a coin"},
      {str = "- 25% chance to create nothing"},
      {str = "These chances are weighed differently depending on the type of red heart, with scared hearts giving the best rewards and half hearts giving the worst rewards"},
    },
}

item.pickup_collide = function(self, pickup,ent,entfirst)
	if ent.Type == EntityType.ENTITY_PLAYER and ent:ToPlayer():GetHearts() < ent:ToPlayer():GetMaxHearts()+ent:ToPlayer():GetBoneHearts() and pickup.Type == EntityType.ENTITY_PICKUP and pickup.Variant == PickupVariant.PICKUP_HEART 
		and pickup.SubType <= 2 and ent:ToPlayer():HasCollectible(item.instance) then
		local player = ent:ToPlayer()
		local flag = true
		if pickup:IsShopItem() and player:GetNumCoins() < pickup.Price then 
			flag = false
		end

		if flag then
			local item_drop = player:GetCollectibleRNG(item.instance):RandomFloat()
			local scale = 1

			if pickup.SubType == 2 then scale = 0.5 --half
			elseif pickup.SubType == 5 then scale = 2 --double
			elseif pickup.SubType == 10 then scale = 0.75 --blended
			elseif pickup.SubType == 9 then scale = 1.25 --scared
			elseif pickup.SubType ~= 1 then scale = 0 end --full

			item_drop = item_drop * scale
			local count_scale = math.min(0.25,((player:GetCollectibleNum(item.instance) - 1) * 0.125))
			local reward = PickupVariant.PICKUP_COIN

			-- GODMODE.log("drop="..item_drop..",count_scale="..count_scale,true)

			if item_drop < 0.45*scale-count_scale then
				reward = PickupVariant.PICKUP_BOMB
			elseif item_drop < 0.6*scale+count_scale then
				reward = PickupVariant.PICKUP_KEY
			end

			if item_drop > 0.25-count_scale then
				Isaac.Spawn(EntityType.ENTITY_PICKUP,reward,1,pickup.Position,pickup.Velocity,pickup)
			end
		end
	end
end
return item