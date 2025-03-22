local item = {}
item.instance = GODMODE.registry.items.a_second_thought
item.eid_description = "↑ +0.2 Speed#Hush and Boss Rush doors are always open#Call of the Void no longer spawns"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Grants +0.2 speed."},
		{str = "Boss Rush and Hush no longer have a time requirement to complete, and Call of the Void will no longer spawn from cursed doors or taking too long on a floor."},
	},
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = player.MoveSpeed+0.2*player:GetCollectibleNum(item.instance)
	end
end

item.player_update = function(self, player)
	if player:HasCollectible(item.instance) then 
		GODMODE.game.BlueWombParTime = 24 * 60 * 60 * 30 -- 1 day should do it 
		GODMODE.game.BossRushParTime = 24 * 60 * 60 * 30 
	end
end

item.room_rewards = function(self)
	if GODMODE.room:GetType() == RoomType.ROOM_BOSS and (
		GODMODE.level:GetStage() == LevelStage.STAGE4_2 or GODMODE.level:GetStage() == LevelStage.STAGE3_2
	) and GODMODE.level:GetStageType() < StageType.STAGETYPE_GREEDMODE then 
		GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
			player:UseActiveItem(CollectibleType.COLLECTIBLE_DADS_KEY,false)
			GODMODE.log("Second Thought failsafe activated, opening boss door")
		end)
	end
end

return item