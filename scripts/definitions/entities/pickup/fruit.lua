local monster = {}
monster.name = "Grapes (Pickup)"
monster.type = GODMODE.registry.entities.fruit.type
monster.variant = GODMODE.registry.entities.fruit.variant

local subtypes = {
    random = 0,
    grapes = 1,
    orange = 2,
    apple = 3,
    banana = 4,
    kiwi = 5,
}
local num_subs = 5
local stat_ups = {
    [subtypes.grapes] = {flag = CacheFlag.CACHE_SPEED, amt = 0.1},
    [subtypes.orange] = {flag = CacheFlag.CACHE_FIREDELAY, amt = 0.06125},
    [subtypes.apple] = {flag = CacheFlag.CACHE_DAMAGE, amt = 0.1},
    [subtypes.banana] = {flag = CacheFlag.CACHE_SHOTSPEED, amt = 0.06125},
    [subtypes.kiwi] = {flag = CacheFlag.CACHE_RANGE, amt = 0.1},
}
local duration = 30*60*5

monster.pickup_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    ent.Velocity = ent.Velocity * 0.97
    if ent.Velocity:Length() <= 0.1 then ent.Velocity = Vector.Zero end

    if sprite:IsFinished("Collect") then
        ent:Remove()
    elseif sprite:IsFinished("Appear") or not sprite:IsPlaying("Collect") then
        if not sprite:IsPlaying("Appear") then 
            sprite:Play("Idle",false)
        end
    end
    
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
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
    if ent.SubType == 0 then 
        ent:Morph(ent.Type,ent.Variant,ent:GetDropRNG():RandomInt(num_subs)+1,true,true)
    end

    if ent.State == 0 then--GODMODE.room:IsFirstVisit() or ent.State == 0 then 
        ent:GetSprite():Play("Appear",true)
        ent.FlipX = ent:GetDropRNG():RandomInt(2) == 1
        ent.State = 1
    else
        ent:GetSprite():Play("Idle",true)
    end
end

monster.eval_cache = function(self, player,cache,data)
    for _,sub in pairs(subtypes) do 
        if sub > 0 then
            local amt = tonumber(GODMODE.save_manager.get_player_data(player,"Fruit"..sub,"0"))
            
            local f_cache = stat_ups[sub].flag
            if cache == f_cache then 
                -- if cache == CacheFlag.CACHE_DAMAGE then 
                --     player.Damage = player.Damage + amt
                -- elseif cache == CacheFlag.CACHE_FIREDELAY then 
                --     player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,amt)
                -- elseif cache == CacheFlag.CACHE_SPEED then 
                --     player.MoveSpeed = player.MoveSpeed + amt
                -- elseif cache == CacheFlag.CACHE_SHOTSPEED then 
                --     player.ShotSpeed = player.ShotSpeed + amt
                -- elseif cache == CacheFlag.CACHE_RANGE then 
                --     player.TearRange = player.TearRange + amt
                -- end
                GODMODE.util.modify_stat(player, cache, 1+amt,true)
            end
        end
    end
end

monster.player_update = function(self, player, data)
    local flags = 0

    for _,sub in pairs(subtypes) do 
        if sub > 0 then 
            local amt = tonumber(GODMODE.save_manager.get_player_data(player,"Fruit"..sub,"0"))
            local max_amt = tonumber(GODMODE.save_manager.get_player_data(player,"MaxFruit"..sub,"0"))
            local perc = (GODMODE.game:GetFrameCount() - tonumber(GODMODE.save_manager.get_player_data(player,"TimeStamp"..sub,"0"))) / duration
            
            if perc < 1.0 and max_amt > 0 then 
                flags = flags | stat_ups[sub].flag
                GODMODE.save_manager.set_player_data(player,"Fruit"..sub, max_amt * (1.0 - perc))
                -- GODMODE.log("perc="..perc..", amt="..amt,true)
            else 
                GODMODE.save_manager.set_player_data(player,"Fruit"..sub,0)
                GODMODE.save_manager.set_player_data(player,"MaxFruit"..sub,0)
                GODMODE.save_manager.set_player_data(player,"TimeStamp"..sub,0)
            end
        end
    end

    if flags > 0 then 
        player:AddCacheFlags(flags)
        player:EvaluateItems()    
    end
end

monster.player_collide = function(self, player,ent,entfirst)
    if (ent.Type == monster.type and ent.Variant == monster.variant) then 
        -- GODMODE.log("hi",true)
        if ent:GetSprite():IsPlaying("Appear") or ent.FrameCount < 3 then
            return true
        end

        if not ent:GetSprite():IsPlaying("Collect") then
            ent:GetSprite():Play("Collect", true)

            local mult = 1
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then mult = 2.0 end
    
            GODMODE.save_manager.set_player_data(player,"Fruit"..ent.SubType,tonumber(GODMODE.save_manager.get_player_data(player,"Fruit"..ent.SubType,"0"))+stat_ups[ent.SubType].amt*mult,true)
            GODMODE.save_manager.set_player_data(player,"MaxFruit"..ent.SubType,tonumber(GODMODE.save_manager.get_player_data(player,"MaxFruit"..ent.SubType,"0"))+stat_ups[ent.SubType].amt*mult,true)
            GODMODE.save_manager.set_player_data(player,"TimeStamp"..ent.SubType,GODMODE.game:GetFrameCount(),true)
            GODMODE.sfx:Play(SoundEffect.SOUND_VAMP_GULP)

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