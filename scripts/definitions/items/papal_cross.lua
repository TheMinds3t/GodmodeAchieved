local item = {}
item.instance = Isaac.GetItemIdByName( "Papal Cross" )
item.eid_description = "Teleports to a devil room with a free item and enemies inside#50% chance to remove this item on use#If not removed, AngelRoomChance% to convert to holy Papal Cross"
item.eid_transforms = GODMODE.util.eid_transforms.DEVIL
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, the player will be teleported to a unique devil room with a free item as well as enemies to fight."},
		{str = "The difficulty of the room depends on which floor the player is currently on."},
		{str = "When used, there is a 50% chance for this item to be removed from the player's inventory. If this roll fails, there is a chance equal to the current angel room chance to convert the unholy papal cross into a holy papal cross."},
	},
}


item.pickup_update = function(self, pickup)
	if pickup.Variant == PickupVariant.PICKUP_SHOPITEM or pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then 
		if pickup.SubType == item.instance then 
			pickup:GetSprite():ReplaceSpritesheet(1,"gfx/items/collectibles/collectibles_papal_cross_both.png")
			pickup:GetSprite():LoadGraphics()
		end
	end
end

item.pickup_collide = function(self, pickup, ent, entfirst)
	item.pickup_update(self, pickup)
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then

		local angel_chance = Game():GetLevel():GetAngelRoomChance()

		local room = Game():GetLevel():GetStage() - 1
		if room > LevelStage.STAGE4_3 then room = room - 1 end
		if Game():GetLevel():GetStage() == LevelStage.STAGE1_1 or Game():GetLevel():GetStage() == LevelStage.STAGE_NULL then
			Isaac.ExecuteCommand("goto s.devil.600")
		else
			if room < 10 then room = "0"..room end
			Isaac.ExecuteCommand("goto s.devil.6"..room)
		end
		local void_slot = GODMODE.util.get_active_slot(player,CollectibleType.COLLECTIBLE_VOID)

		if rng:RandomFloat() < 0.5 and void_slot ~= slot then
			player:RemoveCollectible(item.instance)
		elseif rng:RandomFloat() > 1.0 - angel_chance and void_slot ~= slot then
			player:RemoveCollectible(item.instance)
			player:AddCollectible(Isaac.GetItemIdByName(" Papal Cross "),12,false)
		end

		return true
	end
end

return item