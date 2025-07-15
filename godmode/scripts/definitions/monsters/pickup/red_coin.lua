local monster = {}
monster.name = "Red Coin"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

-- monster.data_init = function(self, params)
--     local ent = params[1]
--     local data = params[2]
--     -- data.persistent_state = GODMODE.persistent_state.single_room
--     ent.SplatColor = Color(0,0,0,0,1,1,1)
--     ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_PLAYER_CONTROL )
-- end

monster.pickup_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    ent.Velocity = ent.Velocity * 0.98

    if ent.Velocity:Length() <= 0.1 then ent.Velocity = Vector.Zero end

    if ent:GetSprite():IsFinished("Death") then
        ent:Remove()
    elseif not ent:GetSprite():IsPlaying("Death") or ent:GetSprite():IsFinished("Appear") then
        if not ent:GetSprite():IsPlaying("Appear") then 
            ent:GetSprite():Play("Idle",false)
        end
    end
end

-- monster.new_room = function(self)
--     GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,-1,function(ent)
--         if ent.FrameCount > 5 then
--             ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
--         end
--     end)
-- end

monster.pickup_init = function(self,ent)
    if GODMODE.util.is_mirror() and ent.Type == monster.type and ent.Variant == monster.variant then ent:Remove() end
    ent:GetSprite():Play("Appear",true)
end

monster.player_collide = function(self, player,ent,entfirst)
    if (ent.Type == monster.type and ent.Variant == monster.variant) then 
        if ent:GetSprite():IsPlaying("Appear") or ent.FrameCount < 3 or ent:GetSprite():IsPlaying("Death") then
            return true
        end

        if not ent:GetSprite():IsPlaying("Death") then
            local data = GODMODE.get_ent_data(player)
            data.red_coin_count = tonumber(GODMODE.save_manager.get_player_data(player, "RedCoinCount", "0")) + 1
            GODMODE.save_manager.set_player_data(player, "RedCoinCount", data.red_coin_count,true)
            data.red_coin_display = 100
            player:AddCoins(1)
            ent:GetSprite():Play("Death",true)

            if data.red_coin_count == 5 then
                player:AddCollectible(CollectibleType.COLLECTIBLE_ONE_UP)
                Game():GetHUD():ShowItemText("5 Red Coins Collected!","+1up")
                data.red_coin_count = 0
                GODMODE.save_manager.set_player_data(player, "RedCoinCount", data.red_coin_count,true)
                SFXManager():Play(GODMODE.sounds.red_coin_complete)
            else
                SFXManager():Play(GODMODE.sounds.red_coin, 1.0, 1, false, 0.8+data.red_coin_count * 0.2)
            end
        end
        
        return true
    end
end

-- monster.use_item = function(self, coll,rng,player,flags,slot,var_data)
--     if coll == CollectibleType.COLLECTIBLE_D20 then
--         GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(item)
--             item:Remove()
--             Isaac.Spawn(EntityType.ENTITY_PICKUP,0,0,item.Position,Vector.Zero,item.SpawnerEntity)
--         end)
--     end
-- end

return monster