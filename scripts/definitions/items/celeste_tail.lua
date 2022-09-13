local item = {}
item.instance = Isaac.GetItemIdByName( "Celestial Tail" )
item.eid_description = "↑ All regular keys are now doubled#↑ 50% chance for chests to become eternal"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "All keys are doubled."},
      {str = "All chests have a 50% chance to turn into eternal chests."},
    },
	{ -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
      {str = "Mimic chests can turn into eternal chests once they try to reveal their spikes."},
    },
}

local affected = {
    [PickupVariant.PICKUP_CHEST] = true,
    [PickupVariant.PICKUP_BOMBCHEST] = true,
    [PickupVariant.PICKUP_SPIKEDCHEST] = true,
    [PickupVariant.PICKUP_MIMICCHEST] = true,
    [PickupVariant.PICKUP_OLDCHEST] = true,
    [PickupVariant.PICKUP_WOODENCHEST] = true,
    [PickupVariant.PICKUP_HAUNTEDCHEST] = true,
    [PickupVariant.PICKUP_LOCKEDCHEST] = true,
}

item.pickup_init = function(self, pickup)
    local count = GODMODE.util.total_item_count(item.instance) 

    if count > 0 then
        if affected[pickup.Variant] == true and pickup:GetDropRNG():RandomFloat() < 0.5+math.min(0.5,(count-1)*0.25) then
            pickup:Morph(pickup.Type,PickupVariant.PICKUP_ETERNALCHEST,0)
        end

        if pickup.Variant == PickupVariant.PICKUP_KEY and pickup.SubType == KeySubType.KEY_NORMAL then 
            pickup:Morph(pickup.Type,pickup.Variant,KeySubType.KEY_DOUBLEPACK,true,true)
        end
    end
end

return item