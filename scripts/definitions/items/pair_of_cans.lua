local item = {}
item.instance = Isaac.GetItemIdByName( "Pair of Cans" )
item.eid_description = "Spawns four orbital familiars each room that prevent one bullet from hitting you"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When entering a room, creates four familiars that circle around the player and block a single projectile each."},
		{str = "These familiars regenerate when entering a new room."},
	},
}

item.new_room = function(self)
	local ents = Isaac.GetRoomEntities()

	for i,ent in ipairs(ents) do
		if ent.Type == EntityType.ENTITY_FAMILIAR and ent.Variant == Isaac.GetEntityVariantByName("Pair of Cans") then
			ent:Remove()
		end
	end

	local players = GODMODE.util.does_player_have(item.instance)

	for i,player in ipairs(players) do
		for i=0,3 do 
			local can = Isaac.Spawn(3, Isaac.GetEntityVariantByName("Pair of Cans"), i, player.Position, Vector(0, 0), player)
			can:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			can:Update()
		end
	end
end

return item