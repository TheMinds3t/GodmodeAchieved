local item = {}
item.instance = Isaac.GetItemIdByName( "Golden Stopwatch" )
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
        Game():GetRoom():TurnGold()
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, Game():GetRoom():FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)
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
    end)
end

item.player_update = function(self, player)
	if player:HasCollectible(item.instance) then
        local data = GODMODE.get_ent_data(player)
        local num_seconds = 5

        if player.SubType == Isaac.GetPlayerTypeByName("Gehazi",true) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then 
            num_seconds = 10 
        end

        if Game():GetFrameCount() % (30*num_seconds) == 0 and player.SubType == Isaac.GetPlayerTypeByName("Gehazi") and GODMODE.save_manager.get_player_data(player, "GoldStopwatchActive", "false") == "false" then
            local coins = player:GetNumCoins()

            if coins > 0 then
                player:AddCoins(-1)
                for i=1,co do
                    local c = Game():Spawn(Isaac.GetEntityTypeByName("Shatter Coin"),Isaac.GetEntityVariantByName("Shatter Coin"),player.Position,Vector(player:GetCollectibleRNG(item.instance):RandomInt(10)-5,player:GetCollectibleRNG(item.instance):RandomInt(10)-5),player,0,player.InitSeed)
                    c:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    c.Velocity = Vector(player:GetCollectibleRNG(item.instance):RandomInt(4)-2,player:GetCollectibleRNG(item.instance):RandomInt(4)-2)
                end
            elseif Game():GetFrameCount() % (60*num_seconds) == 0 and (player:GetHearts()+player:GetSoulHearts()+player:GetBlackHearts()+player:GetEternalHearts()+player:GetBoneHearts()) > 1 then
                player:TakeDamage(1,DamageFlag.DAMAGE_NOKILL)
            end
        end

        if Game():GetRoom():IsClear() and data.gold_stopwatch == true then
            data.gold_stopwatch = false
            data.gold_stopwatch_countdown = 150
            data.gold_stopwatch_uses = 0
            GODMODE.save_manager.set_player_data(player, "GoldStopwatchActive", tostring(data.gold_stopwatch),true)
            GODMODE.save_manager.set_player_data(player, "GoldStopwatchTime", data.gold_stopwatch_countdown,true)
            GODMODE.save_manager.set_player_data(player, "GoldStopwatchLeft", data.gold_stopwatch_uses,true)
        end
        
        -- if GODMODE.save_manager.get_player_data(player, "GoldStopwatchActive", "false") == "true" then
        --     data.gold_stopwatch_countdown = math.max(0, tonumber(GODMODE.save_manager.get_player_data(player, "GoldStopwatchTime", "300")) - 1)
        --     GODMODE.save_manager.set_player_data(player, "GoldStopwatchTime", data.gold_stopwatch_countdown)
        
        --     if data.gold_stopwatch_countdown == 0 and tonumber(GODMODE.save_manager.get_player_data(player, "GoldStopwatchLeft", "6")) > 0 then
        --         data.gold_stopwatch_countdown = 150
        --         GODMODE.save_manager.set_player_data(player, "GoldStopwatchTime", data.gold_stopwatch_countdown)
        
        --         Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, Game():GetRoom():FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)
        --         data.gold_stopwatch_uses = tonumber(GODMODE.save_manager.get_player_data(player, "GoldStopwatchLeft", "6")) - 1
        --         GODMODE.save_manager.set_player_data(player, "GoldStopwatchLeft", data.gold_stopwatch_uses)
        --     end
        -- end
    end
end

return item