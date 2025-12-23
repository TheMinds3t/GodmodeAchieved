local monster = {}
monster.name = "[GODMODE] Tear Gas"
monster.type = GODMODE.registry.entities.tear_gas_can.type
monster.variant = GODMODE.registry.entities.tear_gas_can.variant

monster.can_timeout = 100
monster.gas_timeout = 375
monster.center_gas_timeout_add = 25
monster.mist_count = 6
monster.mist_dist = 36
monster.mist_motion_scalar = 0.175
monster.mist_collect_motion_scalar = (monster.mist_dist / monster.gas_timeout / 5.0)
monster.max_anim_scale = 1.2 
monster.min_anim_scale = 0.1
monster.can_natural_roll_strength = 1 / 40.0

monster.max_gas_scale = 1.1 
monster.min_gas_scale = 0.7

monster.bounce_friction = 0.9


monster.can_anims = {
    [0] = "RollRight",
    [1] = "RollDown",
    [2] = "RollLeft",
    [3] = "RollUp",
}

monster.get_can_anim = function(ent) 
    local ang_ind = math.abs(math.floor(ent.Velocity:GetAngleDegrees() / 90) % 4)

    if monster.can_anims[ang_ind] then return monster.can_anims[ang_ind] else 
        GODMODE.log("Index \'"..ang_ind.."\' is invalid!",true)
        return false 
    end
end

monster.create_cloud = function(pos,vel,spawner)
    local mist = Isaac.Spawn(GODMODE.registry.entities.tear_gas_cloud.type, GODMODE.registry.entities.tear_gas_cloud.variant, GODMODE.registry.entities.tear_gas_cloud.subtype, 
                        pos, vel, spawner)
    mist = mist:ToEffect()
    mist:GetSprite():Play("GasCloud",true)
    return mist 
end

monster.effect_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    data.max_timeout = math.max(ent.Timeout, data.max_timeout or ent.Timeout)

    if data.max_timeout == -1 then 
        data.max_timeout = monster.can_timeout
        ent.Timeout = monster.can_timeout
    end

    if ent.SubType == GODMODE.registry.entities.tear_gas_can.subtype then
        local motion_vector = ent.Velocity:Resized(monster.can_natural_roll_strength)
        
        if ent.m_Height > 0 then 
            local diff = ent.m_Height * (1 - monster.bounce_friction)
            ent.m_Height = ent.m_Height - diff 

            if ent.m_Height < 0 then 
                ent.m_Height = math.abs(ent.m_Height * 1.5)
            end

            if ent.m_Height < 1 then 
                ent.m_Height = 0
            end

            ent.SpriteOffset = Vector(0,-ent.m_Height)
        else 
            ent.SpriteOffset = Vector(0,0)
        end

        if ent.Timeout <= 0 then 
            local center_mist = nil 

            for i=0,monster.mist_count do 
                local dir = Vector(1,0):Rotated(360 / monster.mist_count * i):Resized(monster.mist_dist) 
                if i == 0 then dir = Vector.Zero end 
                local timeout_offset = math.max(1-i,0) * monster.center_gas_timeout_add
                local mist = monster.create_cloud(ent.Position + ent.SpriteOffset, dir:Resized(monster.mist_dist * monster.mist_motion_scalar), center_mist)
                mist.Timeout = math.floor((monster.gas_timeout + timeout_offset) * (0.9 + ent:GetDropRNG():RandomFloat()*0.2))
                mist.Scale = 1.0 - math.min(i,1) * 0.1
                center_mist = center_mist or mist 
            end

            ent:Remove()
        elseif ent:IsFrame(15,ent.Index % 15) then
            local mist = monster.create_cloud(ent.Position + ent.SpriteOffset, motion_vector:Resized(-2), nil)
            mist.Timeout = math.floor(10 * (0.9 + ent:GetDropRNG():RandomFloat()*0.2))
            mist.Scale = 0.25
        end

        local perc = monster.min_anim_scale + (ent.Timeout / data.max_timeout) * (monster.max_anim_scale - monster.min_anim_scale)
        sprite.PlaybackSpeed = perc 
        sprite:Play(monster.get_can_anim(ent),false)
        ent.Velocity = ent.Velocity * 0.9 + motion_vector
    elseif ent.SubType == GODMODE.registry.entities.tear_gas_cloud.subtype then 
        ent.Velocity = ent.Velocity * 0.9 
        local perc = monster.min_anim_scale + (ent.Timeout / data.max_timeout) * (monster.max_anim_scale - monster.min_anim_scale)
        sprite.Scale = Vector(ent.Scale,ent.Scale):Resized(perc)
        sprite:Play("GasCloud",false)

        if ent.Timeout <= 0 then 
            ent:Remove()

            if ent.SpawnerEntity == nil then 
                GODMODE.util.macro_on_players(function(player) 
                    GODMODE.save_manager.set_player_data(player,"TearGasBuff","0")
                    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED)
                    player:EvaluateItems()
                end)
            end
        end

        -- center mist
        if ent.SpawnerEntity ~= nil then 
            local center = ent.SpawnerEntity 
            local dir = center.Position - ent.Position 
            ent.Velocity = ent.Velocity + dir:Resized(perc * monster.mist_collect_motion_scalar)

            if center:IsDead() then ent:Remove() end 
        else -- this IS the center mist  
            local active_radius = math.max(ent.Size + monster.mist_dist, (ent.Size + monster.mist_dist * 2) * perc)
            -- local ents = Isaac.FindInRadius(ent.Position, active_radius,EntityPartition.PLAYER)

            GODMODE.util.macro_on_players(function(player) 
                local dist = (ent.Position - player.Position)

                if dist:Length() <= active_radius then 
                    GODMODE.save_manager.set_player_data(player,"TearGasBuff","1")
                end

                player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end)
        end
    end
end

-- not official callback, manually added in update
monster.apply_tear_buff = function(self,player,fx,data)
    data.players = data.players or {}
    
    for _,play in ipairs(data.players) do 
        if GetPtrHash(play) == GetPtrHash(player) then 
            return false 
        end
    end

    table.insert(data.players,player)
    GODMODE.save_manager.set_player_data(player,"TearGasBuff","1")
    player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SPEED)
    player:EvaluateItems()
end

return monster