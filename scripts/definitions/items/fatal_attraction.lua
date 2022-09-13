local item = {}
item.instance = Isaac.GetItemIdByName( "Fatal Attraction" )
item.eid_description = "↑ +1 Black Heart #↓ -3 hearts#At the start of each floor, choose one of 3 options to permanently increase a stat by 10% and decrease another stat by 7.5%"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - Removes 3 hearts and adds one black heart"},
      {str = " - On traversing to a new floor, 3 options (+1 for each extra instance held globally, up to 7) are spawned for selecting a stat to increase and a stat to decrease."},
      {str = " - Whichever option is selected, increases the shown stat by 10% and decreases the shown second stat by 7.5%."},
    },
}

local spacing = 64

item.new_level = function(self)
	local cnt = GODMODE.util.total_item_count(item.instance)

	if cnt > 0 then 
		local total = math.min(cnt*1+2,7)
		local spawn_pos = Game():GetRoom():GetCenterPos() + Vector(0,-80) - Vector(total / 2*spacing+spacing / 2,0)
		for i=1,total do 
			local spawn_off 
			local choice = Isaac.Spawn(Isaac.GetEntityTypeByName("Fatal Attraction Helper"),Isaac.GetEntityVariantByName("Fatal Attraction Helper"),GODMODE.util.random(0,29),spawn_pos+Vector(i*spacing,0),Vector.Zero,nil):ToPickup()
			choice.OptionsPickupIndex = 66666
			choice:Update()
		end
	end
end
return item