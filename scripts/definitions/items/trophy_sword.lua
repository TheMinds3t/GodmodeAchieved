local item = {}
item.instance = GODMODE.registry.items.childs_trophy
item.eid_description = "{{Warning}}Usable once every two floors#↑ 600% Damage on use#↑ +3 Tears on use"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When used, grants 600% damage and +3 fire delay for the room."},
      {str = "Child's Trophy is only useable once every two floors."},
    },
}


item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if tonumber(GODMODE.save_manager.get_player_data(player,"TrophyRoomSeed","-1")) == GODMODE.room:GetDecorationSeed() then
		if cache == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 6.0
		end

		if cache == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,3, true)
		end
	end
end
item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
		local last_used = tonumber(GODMODE.save_manager.get_player_data(player,"TrophyRoomStage","-2"))
		if last_used + 2 <= GODMODE.level:GetStage() - 1 then 
			local data = GODMODE.get_ent_data(player)
			GODMODE.save_manager.set_player_data(player, "TrophyRoomSeed", GODMODE.room:GetDecorationSeed())
			GODMODE.save_manager.set_player_data(player, "TrophyRoomStage", GODMODE.level:GetStage(),true)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
			return {Discharge=true,Remove=false,ShowAnim=true}
		else
			GODMODE.sfx:Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ, .75, 0, false, 1.5)
			return {Discharge=false,Remove=false,ShowAnim=true}
		end
	end
end
item.new_room = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
		GODMODE.save_manager.set_player_data(player, "TrophyRoomSeed", "-1",true)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
	end)
end

item.new_level = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
		local slot = GODMODE.util.get_active_slot(player, item.instance)
		if player:GetActiveItem(slot) == item.instance then
			if player:GetActiveCharge(slot) < 2 then 
				player:SetActiveCharge(player:GetActiveCharge() + 1, slot)
			end
		end
	end)
end

item.load_data = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
		local data = GODMODE.get_ent_data(player)
		data.trophy_use_room = tonumber(GODMODE.save_manager.get_player_data(player, "TrophyRoomSeed", "-1"))
		if data.trophy_use_room == GODMODE.room:GetDecorationSeed() then
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
		end
	end)
end

return item