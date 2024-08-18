local item = {}
item.instance = GODMODE.registry.items.fatal_attraction
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
	local actual_count = math.min(7,cnt * 1 + 2*(math.min(1,cnt)))
		+ math.min(5,GODMODE.util.total_item_count(GODMODE.registry.trinkets.shattered_moonrock,true)*2)
	-- GODMODE.log("actual= "..actual_count..", (fa="..math.min(7,cnt * 1 + 2*(math.min(1,cnt)))
	-- 	.."), (sm="..GODMODE.util.total_item_count(GODMODE.registry.trinkets.shattered_moonrock,true)*2*math.min(1,#GODMODE.util.get_curse_list(false))
	-- 	.."),(cc="..(#GODMODE.util.get_curse_list(false)),true)

	if actual_count > 0 then 
		local total = actual_count
		local spawn_pos = GODMODE.room:GetCenterPos() + Vector(0,-80) - Vector(total / 2*spacing+spacing / 2,0)
		for i=1,total do 
			local spawn_off 
			local choice = Isaac.Spawn(GODMODE.registry.entities.fatal_attraction_station.type,GODMODE.registry.entities.fatal_attraction_station.variant,GODMODE.util.random(0,29),
				spawn_pos+Vector(i*spacing,0),Vector.Zero,nil):ToPickup()
			choice.OptionsPickupIndex = 66666
			choice:Update()
			if i % 7 == 5 then 
				spawn_pos = spawn_pos + Vector(0,spacing)
			end
		end
	end
end

return item