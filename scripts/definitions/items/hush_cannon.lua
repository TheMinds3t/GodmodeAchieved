local item = {}
item.instance = Isaac.GetItemIdByName( "Anguish Jar" )
item.eid_description = "Creates a controllable beam from the sky, dealing 40 damage per tick#Leaves a trail of creep"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Creates a controllable hush laser from your character, controlled with the fire keys."},
		{str = "The laser deals 40 damage per tick and lasts for 6.666 seconds, resulting in roughly 170 DPS for a total of 1130 damage!"},
	},
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
		Game():Spawn(3, Isaac.GetEntityVariantByName("Hush Cannon"), player.Position, Vector(0,0), player, 0, player.InitSeed)
		return true
	end
end

return item