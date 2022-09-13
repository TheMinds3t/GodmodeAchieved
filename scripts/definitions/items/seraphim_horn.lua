local item = {}
item.instance = Isaac.GetItemIdByName( "Seraphim Warhorn" )
item.eid_description = "Summons a Bloody Uriel to assist you for the duration of the room"
item.eid_transforms = GODMODE.util.eid_transforms.ANGEL
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, summons a Bloody Uriel to fight for the current room."},
		{str = "The Bloody Uriel that is spawned has 66.6% of the health of a hostile one, though the DPS of the blood spread as well as the holy lasers can do serious damage in the right situation."},
	},
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        local angel = Game():Spawn(Isaac.GetEntityTypeByName("Bloody Uriel"), Isaac.GetEntityVariantByName("Bloody Uriel"), Game():GetRoom():GetCenterPos()-Vector(0,64), Vector.Zero, player, 0, player.InitSeed)
        angel:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)
        angel:Update()
        angel.MaxHitPoints = angel.MaxHitPoints * 0.666
        angel.HitPoints = angel.MaxHitPoints
        return true
    end
end

return item