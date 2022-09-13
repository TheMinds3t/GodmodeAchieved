local curses = {
	--Isaac.GetCurseIdByName("Curse of Darkness!"), nobody deserves this blight of existence
	--Isaac.GetCurseIdByName("Curse of the Labryinth!"),
	LevelCurse.CURSE_OF_THE_LOST,
	LevelCurse.CURSE_OF_THE_UNKNOWN,
	LevelCurse.CURSE_OF_MAZE,
}

local item = {}
item.instance = Isaac.GetItemIdByName( "Blood Pudding" )
item.eid_description = "↑ +5.0 luck#↓ Guaranteed curse on every floor"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - +5 luck"},
      {str = " - Guarantees either curse of the lost, curse of the unknown, or curse of the maze if the current floor does not have a curse already."},
    },
}


item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_LUCK then
		local num = math.min(3,player:GetCollectibleNum(item.instance))
		player.Luck = player.Luck + num*num+4
	end
end

item.player_update = function(self,player)
	if player:HasCollectible(item.instance) then
		if Game():GetLevel():GetCurseName() == "" then
			local depth = 3
			--Add up to three curses per floor
			for i=1,math.min(3,player:GetCollectibleNum(item.instance)) do 
				local curse = curses[player:GetCollectibleRNG(item.instance):RandomInt(#curses)+1]
				
				while GODMODE.util.has_curse(curse) do 
					depth = depth - 1
					curse = curses[player:GetCollectibleRNG(item.instance):RandomInt(#curses)+1]

					if depth <= 0 then 
						break
					end
				end

				if depth <= 0 then 
					break 
				end
				
				depth = 3
				Game():GetLevel():AddCurse(curse,true)
			end
		end
	end
end

return item