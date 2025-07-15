local item = {}
item.instance = GODMODE.registry.items.golden_stopwatch
item.eid_description = "Spawns a penny, makes the room gold#Until you leave the room, you don't lose money over time"

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        local data = GODMODE.get_ent_data(player)
        
        data.gold_stopwatch = true
        data.gold_stopwatch_countdown = 150
        data.gold_stopwatch_uses = 6
        GODMODE.save_manager.set_player_data(player, "GoldStopwatchTime", data.gold_stopwatch_countdown,true)
        GODMODE.save_manager.set_player_data(player, "GoldStopwatchLeft", data.gold_stopwatch_uses,true)
        GODMODE.save_manager.set_player_data(player, "GoldStopwatchActive", tostring(data.gold_stopwatch),true)
    
        for i=1,5 do 
            local dir = Vector(1,0):Rotated(player:GetCollectibleRNG(item.instance):RandomFloat()*360.0):Resized(player:GetCollectibleRNG(item.instance):RandomFloat()*26+13)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY,player.Position,dir,player):ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end
    
        GODMODE.room:TurnGold()
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
        return true
    end
end

item.new_room = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        local data = GODMODE.get_ent_data(player)
        data.gold_stopwatch = false
        data.gold_stopwatch_countdown = 150
        data.gold_stopwatch_uses = 0
        GODMODE.save_manager.set_player_data(player, "GoldStopwatchActive", tostring(data.gold_stopwatch),true)
        GODMODE.save_manager.set_player_data(player, "GoldStopwatchTime", data.gold_stopwatch_countdown,true)
        GODMODE.save_manager.set_player_data(player, "GoldStopwatchLeft", data.gold_stopwatch_uses,true)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end)
end

item.player_update = function(self, player, data)
	if player:HasCollectible(item.instance) then
        local num_seconds = 5

        if player.SubType == GODMODE.registry.players.t_gehazi and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then 
            num_seconds = 10 
        end

        
        -- if GODMODE.save_manager.get_player_data(player, "GoldStopwatchActive", "false") == "true" then
        --     data.gold_stopwatch_countdown = math.max(0, tonumber(GODMODE.save_manager.get_player_data(player, "GoldStopwatchTime", "300")) - 1)
        --     GODMODE.save_manager.set_player_data(player, "GoldStopwatchTime", data.gold_stopwatch_countdown)
        
        --     if data.gold_stopwatch_countdown == 0 and tonumber(GODMODE.save_manager.get_player_data(player, "GoldStopwatchLeft", "6")) > 0 then
        --         data.gold_stopwatch_countdown = 150
        --         GODMODE.save_manager.set_player_data(player, "GoldStopwatchTime", data.gold_stopwatch_countdown)
        
        --         Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, GODMODE.room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)
        --         data.gold_stopwatch_uses = tonumber(GODMODE.save_manager.get_player_data(player, "GoldStopwatchLeft", "6")) - 1
        --         GODMODE.save_manager.set_player_data(player, "GoldStopwatchLeft", data.gold_stopwatch_uses)
        --     end
        -- end
    end
end

return item