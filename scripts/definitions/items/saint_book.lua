local item = {}
item.instance = GODMODE.registry.items.book_of_saints
item.eid_description = "↑ +2 Golden Hearts #↑ +1 Soul Heart#↑ +10% Gilded chance"
item.eid_transforms = GODMODE.util.eid_transforms.ANGEL
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, grants 2 golden hearts and 1 soul heart, and +10% Gilded chance (decaying, flat percent to convert basic pickups into their golden variants)."},
	},
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        player:AddGoldenHearts(2)
        player:AddSoulHearts(2)
        GODMODE.sfx:Play(SoundEffect.SOUND_HOLY,1,2,false,1.5)
        GODMODE.save_manager.set_data("GildedChance", math.min(tonumber(GODMODE.save_manager.get_data("GildedChance","0.0")) + 0.15,1),true)
        return true
    end
end

return item