local item = {}
item.instance = Isaac.GetItemIdByName( "Ghanta" )
item.eid_description = "#When used, brings you down to one red heart and then spawns soul hearts equal to the red health you lost#↓ -1 Heart container # Doesn't work on characters with no red hearts"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "On use:"},
		{str = "- -1 heart container"},
		{str = "- removes all but 1 red heart and spawns one soul heart per heart removed on the ground"},
	},
}

	
item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then 
		local hearts = player:GetHearts() - 2 

		if hearts > 0 then
			player:AddHearts(-hearts)

			for i=1,math.floor(hearts/2) do 
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, player.Position, Vector(-4+player:GetDropRNG():RandomFloat()*8,-4+player:GetDropRNG():RandomFloat()*8), player) 
			end

			if hearts % 2 == 1 then
				Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, player.Position, Vector(-4+player:GetDropRNG():RandomFloat()*8,-4+player:GetDropRNG():RandomFloat()*8), player) 
			end

			player:AddMaxHearts(-2)

			local saved_hearts = tonumber(GODMODE.save_manager.get_persistant_data("GhantaHearts","0",true))
			GODMODE.save_manager.set_persistant_data("GhantaHearts", saved_hearts + hearts/2)

			if saved_hearts + hearts/2 > 12 then
				GODMODE.achievements.unlock_item(Isaac.GetItemIdByName("Vajra"))
			end

			return true
		end	
	end
end

return item