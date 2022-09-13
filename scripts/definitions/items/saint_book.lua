local item = {}
item.instance = Isaac.GetItemIdByName( "Book of Saints" )
item.eid_description = "↑ +2 Golden Hearts #↑ +1 Soul Heart"
item.eid_transforms = GODMODE.util.eid_transforms.ANGEL
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, grants 2 golden hearts and 1 soul heart."},
	},
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        player:AddGoldenHearts(2)
        player:AddSoulHearts(2)
        SFXManager():Play(SoundEffect.SOUND_HOLY,1,2,false,1.5)
        return true
    end
end

return item