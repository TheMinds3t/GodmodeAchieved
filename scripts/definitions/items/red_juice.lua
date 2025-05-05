local item = {}
item.instance = GODMODE.registry.items.red_juice
item.eid_description = "#↑+1 Luck↑+0.05 Speed#↓ Warps vision slightly#Effect stacks 20 times#Decays over time and on room clear"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "On use:"},
		{str = "- +1 Luck"},
		{str = "- +0.05 Speed"},
		{str = "- Slightly distorts vision, akin to Wavy Cap."},
		{str = "These effects can be stacked up to 20 times to increase the potency of the item. The potency decays at a rate of 1 use every 30 seconds, and decays by 1 use every room clear."},
	},
}

local decay_time = 30.0 * 30.0
local max_stacks = 20

item.eval_cache = function(self, player,cache,data)
    local num = player:GetCollectibleNum(item.instance)
	local distort = tonumber(GODMODE.save_manager.get_data("RedJuiceDistort","0"))

    if cache == CacheFlag.CACHE_LUCK then 
		player.Luck = player.Luck + tonumber(GODMODE.save_manager.get_player_data(player, "RedJuiceLuck", "0"))
    end

	if cache == CacheFlag.CACHE_SPEED then 
		player.MoveSpeed = player.MoveSpeed + 1.0 * distort 
    end
end

item.player_update = function(self, player)
	local distort = tonumber(GODMODE.save_manager.get_data("RedJuiceDistort","0"))
	GODMODE.save_manager.set_data("RedJuiceDistort", math.max(0,distort-1/decay_time/max_stacks))

	if player:IsFrame(5,1) and (player:HasCollectible(item.instance) or distort > 0) then 
		player:AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_SPEED)
		player:EvaluateItems()

		local luck = tonumber(GODMODE.save_manager.get_player_data(player, "RedJuiceLuck", "0"))

		if luck > 0 and distort == 0 then 
			GODMODE.save_manager.set_player_data(player,"RedJuiceLuck","0",true)
		elseif distort > 0 and player:IsFrame(20,1) then 
			GODMODE.save_manager.save()
		end
	end
end
	
item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then 
		local luck = tonumber(GODMODE.save_manager.get_player_data(player, "RedJuiceLuck", "0"))
		GODMODE.save_manager.set_player_data(player,"RedJuiceLuck",math.min(luck+1, max_stacks))
		local distort = tonumber(GODMODE.save_manager.get_data("RedJuiceDistort","0"))
		GODMODE.save_manager.set_data("RedJuiceDistort", math.min(1,distort + 1.0 / max_stacks),true)
		
		player:AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_SPEED)
		player:EvaluateItems()
		return true 
	end
end

item.room_rewards = function(self)
	local distort = tonumber(GODMODE.save_manager.get_data("RedJuiceDistort","0"))
	GODMODE.save_manager.set_data("RedJuiceDistort", math.min(1,distort-1.0 / max_stacks), true)
end

item.bypass_hooks = {["player_update"] = true}


return item