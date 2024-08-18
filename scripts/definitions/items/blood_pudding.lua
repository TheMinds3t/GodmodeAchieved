local curses = {
	--Isaac.GetCurseIdByName("Curse of Darkness!"), nobody deserves this blight of existence
	--Isaac.GetCurseIdByName("Curse of the Labryinth!"),
	LevelCurse.CURSE_OF_THE_LOST,
	LevelCurse.CURSE_OF_THE_UNKNOWN,
	LevelCurse.CURSE_OF_MAZE,
}

local item = {}
item.instance = GODMODE.registry.items.blood_pudding
item.eid_description = "↑ +5.0 luck#↓ Guaranteed curse on every floor"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - +5 luck"},
      {str = " - Guarantees either curse of the lost, curse of the unknown, or curse of the maze if the current floor does not have a curse already."},
    },
}


item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_LUCK then
		local num = math.min(3,player:GetCollectibleNum(item.instance))
		player.Luck = player.Luck + num*num+3+player:GetCollectibleNum(item.instance)
	end
end

item.player_update = function(self,player,data)
	if player:HasCollectible(item.instance) and player:IsFrame(20,1) then
		if #GODMODE.util.get_curse_list() < math.min(3,player:GetCollectibleNum(item.instance)) then
			local depth = 6
			--Add up to three curses per floor
			local curse_ind = player:GetCollectibleRNG(item.instance):RandomInt(#curses)+1
			
			while GODMODE.util.has_curse(curses[curse_ind]) do 
				depth = depth - 1
				curse_ind = ((curse_ind + 1) % #curses) + 1
				GODMODE.log("ind \'"..curse_ind.."\' taken, switching...")

				if depth <= 0 then 
					break
				end
			end
			
			GODMODE.util.add_curse(curses[curse_ind],true)
		end
	end
end

return item