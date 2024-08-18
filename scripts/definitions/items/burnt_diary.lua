local item = {}
item.instance = GODMODE.registry.items.burnt_diary
item.eid_description = "Spawn 5 burning pages, dealing 30 burn damage and 5 contact damage to enemies#Pages burn up after dealing damage, but otherwise persist"
item.eid_transforms = GODMODE.util.eid_transforms.BOOKWORM
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "On use, spawns 5 burning pages that persist between rooms."},
      {str = "Each page deals 5 contact damage and 30 tick damage from the burn it inflicts."},
    },
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        for i=1,5 do
            local spd = 1.0 + rng:RandomFloat()
            local ang = math.rad(rng:RandomFloat() * 360)
            Isaac.Spawn(GODMODE.registry.entities.burnt_page.type, GODMODE.registry.entities.burnt_page.variant, 0, player.Position, Vector(math.cos(ang)*spd,math.sin(ang)*spd), player)
        end
        return true
    end
end

return item