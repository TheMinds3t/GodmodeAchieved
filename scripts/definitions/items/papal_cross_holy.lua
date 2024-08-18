local item = {}
item.instance = GODMODE.registry.items.papal_cross_holy
item.eid_description = "Teleports to an angel room with a free item and enemies inside#(100-AngelRoomChance)% chance to turn into unholy Papal Cross"
item.eid_transforms = GODMODE.util.eid_transforms.ANGEL
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, the player will be teleported to a unique angel room with a free item as well as enemies to fight."},
		{str = "The difficulty of the room depends on which floor the player is currently on."},
		{str = "When used, there is a chance equal to the current angel room chance to keep the holy papal cross. If this roll fails, then the holy papal cross converts into the unholy papal cross."},
	},
}

item.pickup_update = function(self, pickup, data, sprite)
	if pickup.Variant == PickupVariant.PICKUP_SHOPITEM or pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then 
		if pickup.SubType == item.instance then 
			sprite:ReplaceSpritesheet(1,"gfx/items/collectibles/collectibles_papal_cross_both.png")
			sprite:LoadGraphics()
		end
	end
end

item.pickup_collide = function(self, pickup, ent, entfirst)
	item.pickup_update(self, pickup, GODMODE.get_ent_data(pickup), ent:GetSprite())
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
		local angel_chance = GODMODE.level:GetAngelRoomChance()
		GODMODE.log("angel = "..angel_chance..", devil = "..GODMODE.room:GetDevilRoomChance(), true)
		
		local room = GODMODE.level:GetStage() - 1
		if room > LevelStage.STAGE4_3 then room = room - 1 end
		if GODMODE.level:GetStage() == LevelStage.STAGE1_1 or GODMODE.level:GetStage() == LevelStage.STAGE_NULL then
			Isaac.ExecuteCommand("goto s.angel.600")
		else
			if room < 10 then room = "0"..room end
			Isaac.ExecuteCommand("goto s.angel.6"..room)
		end
		
		local void_slot = GODMODE.util.get_active_slot(player,CollectibleType.COLLECTIBLE_VOID)

		if rng:RandomFloat() < 1.0-angel_chance and void_slot ~= slot then
			player:RemoveCollectible(item.instance)
			player:AddCollectible(GODMODE.registry.items.papal_cross_unholy,12,false,slot,var_data)
		end

		return true
	end
end

return item