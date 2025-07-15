local item = {}
item.instance = GODMODE.registry.items.tear_gas
item.eid_description = "When used, rolls a tear gas canister#After a little rolling, tear gas is created#Standing in the tear gas grants +50% Tears and -10% Movement Speed"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, holds the item above Isaac's head. Using again will cancel using the item at no cost."},
		{str = "Next time the player fires a tear, will throw a tear gas canister instead, rolling to a stop after a short period."},
		{str = "Once the canister stops, releases a cluster of tear gas clouds."},
		{str = "While standing in the clouds, +50% Tears and -10% Speed."},
	},
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end
    local active = GODMODE.save_manager.get_player_data(player, "TearGasBuff", "0") == "1"

    if active then 
        if cache == CacheFlag.CACHE_FIREDELAY then
            GODMODE.util.modify_stat(player, cache, 1.5, true, false)
        end

        if cache == CacheFlag.CACHE_SPEED then 
            GODMODE.util.modify_stat(player, cache, 0.9, true, false)
        end
    end
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        player:StopExtraAnimation()
        local state = tonumber(GODMODE.save_manager.get_player_data(player, "TearGasState", "0"))

        if state == 1 then 
            player:StopExtraAnimation()
            player:AnimateCollectible(item.instance,"HideItem")
        end

        GODMODE.save_manager.set_player_data(player, "TearGasState", state == 1 and 0 or 1, true)

        return {Discharge=false,Remove=false,ShowAnim=false}
    end
end

item.new_room = function(self)
    GODMODE.util.macro_on_players(function(player) 
        GODMODE.save_manager.set_player_data(player,"TearGasBuff","0")
        GODMODE.save_manager.set_player_data(player,"TearGasState","0")
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
    end)
end

item.player_update = function(self, player,data)
    if player:HasCollectible(item.instance) then
        local state = tonumber(GODMODE.save_manager.get_player_data(player, "TearGasState", "0"))

        if state == 1 then -- using tear gas
            if player:IsExtraAnimationFinished() then
                player:AnimateCollectible(item.instance,"LiftItem")
            end

            -- disable tears
            player.FireDelay = player.MaxFireDelay

            if player:GetShootingJoystick().X + player:GetShootingJoystick().Y ~= 0 then
                local vel = player:GetShootingJoystick()*16
                local gas = Isaac.Spawn(GODMODE.registry.entities.tear_gas_can.type,GODMODE.registry.entities.tear_gas_can.variant,GODMODE.registry.entities.tear_gas_can.subtype,player.Position,vel,player)
                gas = gas:ToEffect()
                gas.m_Height = 32
                gas:Update()
                player:AnimateCollectible(item.instance,"HideItem")
                GODMODE.save_manager.set_player_data(player, "TearGasState", 0)
                player:DischargeActiveItem(GODMODE.util.get_active_slot(player, item.instance))
            end
        end

        local buff_state = tonumber(GODMODE.save_manager.get_player_data(player, "TearGasBuff", "0"))

        if buff_state == 1 then 
            data.gas_timeout = 30
            GODMODE.save_manager.set_player_data(player,"TearGasBuff","0")
        else 
            data.gas_timeout = math.max(-1, (data.gas_timeout or 0) - 1)

            if data.gas_timeout == 0 then 
                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end
        end
    end
end

return item