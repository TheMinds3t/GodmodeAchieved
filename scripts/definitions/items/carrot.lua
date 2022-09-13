local item = {}
item.instance = Isaac.GetItemIdByName( "The Carrot" )
item.eid_description = "↑ +1 Heart #↑ Randomly reveal either secret rooms, map icons, or map layout on entering a new floor"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - Grants 1 heart container"},
      {str = " - On traversing to a new floor, randomly selects either the map, blue map, or the compass to give the player for the floor."},
      {str = " - If more than one is held, then an additional effect is given with a cap of three carrots in possession to give a similar effect to The Mind."},
    },
}

item.new_level = function(self)
	local list = GODMODE.util.does_player_have(item.instance)
	local count = math.min(3,#list)
	local bools = {false,false,false}
	if count > 0 then
		while count > 0 do
			local i = list[1]:GetCollectibleRNG(item.instance):RandomInt(3)
			local flag = false

			if i == 1 and bools[i] ~= true then
				Game():GetLevel():ApplyMapEffect()
				bools[i] = true
				flag = true
			elseif i == 2 and bools[i] ~= true then
				Game():GetLevel():ApplyBlueMapEffect()
				bools[i] = true
				flag = true
			elseif i == 3 and bools[i] ~= true then
				Game():GetLevel():ApplyCompassEffect(true)
				bools[i] = true
				flag = true
			end

			if flag then
				count = count - 1
			end
		end
	end
end
return item