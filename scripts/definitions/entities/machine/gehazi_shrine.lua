local monster = {}
monster.name = "[GODMODE] Gehazi Shrine"
monster.type = GODMODE.registry.entities.gehazi_shrine.type
monster.variant = GODMODE.registry.entities.gehazi_shrine.variant
monster.reward_amt = 20
monster.coin_amt = {
    [CoinSubType.COIN_PENNY] = 1,
    [CoinSubType.COIN_DOUBLEPACK] = 2,
    [CoinSubType.COIN_NICKEL] = 5,
    [CoinSubType.COIN_DIME] = 10,
}

monster.pickup_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    data.origin = data.origin or GODMODE.room:GetGridPosition(GODMODE.room:GetGridIndex(ent.Position))
    ent.Velocity = (data.origin - ent.Position)
    if ent.Velocity:Length() <= 0.1 then ent.Velocity = Vector.Zero end

    if sprite:IsFinished("Appear") then 
        sprite:Play("Idle",false)
    end

    if sprite:IsFinished("Reward") then ent:Remove() end 

    if ent:IsFrame(2,1) then 
        local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, ent.Position+RandomVector():Resized(ent.Size)+Vector(0,-ent.Size/2), Vector.Zero, nil):ToEffect()
        fx:SetTimeout(10)
        fx.LifeSpan = 40
        fx.Scale = ent:GetDropRNG():RandomFloat() * 0.5 + 1.0
        fx:SetColor(Color(0,0,0,1),999,1,false,false)
        fx.DepthOffset = -100
        
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS    
    end

    if sprite:IsEventTriggered("Crush") then 
        for i=0,8 do 
            local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.COIN_PARTICLE, 0, ent.Position+RandomVector():Resized(ent.Size)+Vector(0,-ent.Size/2), RandomVector()*3, nil):ToEffect()
            fx:SetTimeout(10)
            fx.LifeSpan = 40
            fx.Scale = ent:GetDropRNG():RandomFloat() * 0.5 + 1.0
            fx.DepthOffset = -100    
        end

        GODMODE.sfx:Play(SoundEffect.SOUND_BONE_SNAP,Options.SFXVolume*8,1,false,1)
    end

    if sprite:IsEventTriggered("Explode") then 
        ent:BloodExplode()

        for i=0,32 do 
            local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.COIN_PARTICLE, 0, ent.Position+RandomVector():Resized(ent.Size)+Vector(0,-ent.Size/2), RandomVector()*3, nil):ToEffect()
            fx:SetTimeout(10)
            fx.LifeSpan = 40
            fx.Scale = ent:GetDropRNG():RandomFloat() * 0.5 + 1.0
            fx:SetColor(Color(0,0,0,1),999,1,false,false)
            fx.DepthOffset = -100    
        end

        local sel_coin = function(remain)
            local val = ent:GetDropRNG():RandomFloat()
            local ret = CoinSubType.COIN_PENNY

            if val < 0.2 and remain >= 11 then 
                ret = CoinSubType.COIN_DIME
            else
                val = ent:GetDropRNG():RandomFloat()

                if val < 0.5 and remain >= 5 then 
                    ret = CoinSubType.COIN_NICKEL
                else
                    if val < 0.7 and remain >= 2 then 
                        ret = CoinSubType.COIN_DOUBLEPACK
                    end
                end
            end

            return ret
        end

        local amt = monster.reward_amt

        while amt > 0 do 
            local coin = sel_coin(amt)
            Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COIN,coin,ent.Position,Vector(1,0):Rotated(ent:GetDropRNG():RandomInt(360)):Resized(ent:GetDropRNG():RandomFloat()*4+1.5),ent)
            amt = amt - monster.coin_amt[coin]
        end

        GODMODE.game:MakeShockwave(ent.Position, 0.0375, 0.005, 20)
        GODMODE.sfx:Play(SoundEffect.SOUND_BLOOD_LASER_LARGER,Options.SFXVolume*12,1,false,0.8)
        GODMODE.sfx:Play(SoundEffect.SOUND_DEATH_BURST_BONE,Options.SFXVolume*12,1,false,1)
        if data.player ~= nil then 
            GODMODE.util.add_faithless(data.player, 3)
            -- data.player:AddBrokenHearts(1)
        end
    end

    if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
        ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
    end
    -- GODMODE.log("hi!",true)
end

monster.spawn_shrine = function(room,player)
    Isaac.Spawn(monster.type,monster.variant,0,room:FindFreePickupSpawnPosition(Vector(room:GetBottomRightPos().X,room:GetTopLeftPos().Y)+Vector(-64,-64)),Vector.Zero,player)
end

monster.new_level = function()
    if not GODMODE.util.is_start_of_run() then 
        local room = GODMODE.room
        GODMODE.util.macro_on_players(function(player) 
            if player:GetPlayerType() == GODMODE.registry.players.t_gehazi then 
                monster.spawn_shrine(room,player)
            end
        end)    
    end
end

-- monster.player_init = function(self,player)
--     if player:GetPlayerType() == GODMODE.registry.players.t_gehazi and GetPtrHash(player) ~= GetPtrHash(Isaac.GetPlayer(0)) then 
--         monster.spawn_shrine(GODMODE.room,player)
--     end
-- end

monster.pickup_init = function(self,ent)
    if GODMODE.util.is_mirror() and ent.Type == monster.type and ent.Variant == monster.variant then ent:Remove() end
    ent:GetSprite():Play("Appear",true)
end

monster.player_collide = function(self, player,ent,entfirst)
    if (ent.Type == monster.type and ent.Variant == monster.variant) then 
        -- GODMODE.log("hi",true)
        if ent:GetSprite():IsPlaying("Appear") or ent.FrameCount < 3 then
            return true
        end

        if not ent:GetSprite():IsPlaying("Reward") then
            ent:GetSprite():Play("Reward", true)
            GODMODE.sfx:Play(SoundEffect.SOUND_SUPERHOLY)
            GODMODE.get_ent_data(ent).player = player
        end
        
        return false
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