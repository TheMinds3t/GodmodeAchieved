local item = {}
item.instance = GODMODE.registry.items.marshall_scarf
item.eid_description = "↑ +Small tears up before womb#↑ + Medium tears in womb #↑ + High tears up after womb"
item.eid_transforms = GODMODE.util.eid_transforms.ANGEL
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Grants a tears upgrade depending on how far in the run you are:"},
		{str = "- +0.5 Fire Delay before the womb."},
		{str = "- +0.75 Fire Delay within the womb."},
		{str = "- +1.0 Fire Delay after the womb."},
	},
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_FIREDELAY then
		local t = 0.5
		local s = GODMODE.level:GetStage()

		if StageAPI and StageAPI.Loaded and GODMODE.stages ~= nil and StageAPI.GetCurrentStage() ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name] ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name].simulating_stage ~= nil then
			s = GODMODE.stages[StageAPI.GetCurrentStage().Name].simulating_stage
		end

		if s >= LevelStage.STAGE4_1 then t = 0.75 end
		if s >= LevelStage.STAGE5 then t = 1.0 end
	    player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,t*player:GetCollectibleNum(item.instance), true)
	end
end

item.new_level = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
	end)
end

return item