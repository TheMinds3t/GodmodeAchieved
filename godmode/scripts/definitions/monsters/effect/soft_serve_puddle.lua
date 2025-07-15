local monster = {}
monster.name = "Soft Serve Spawner"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.subtypes = {
    [0] = { --spawner
        anim="None",
        timeout = 120,
        on_collide = function(ent) end,
        update = function(data,ent) 
            data.avg_vel = ((data.avg_vel or ent.Velocity:GetAngleDegrees()) + ent.Velocity:GetAngleDegrees()) / 2
            data.velocity = data.velocity or RandomVector()*3
            data.color = data.color or (ent:GetDropRNG():RandomInt(#monster.subtypes-1) + 1)
            ent.Velocity = data.velocity

            if data.color == 2 then
                local ent2 = Isaac.FindInRadius(ent.Position,156,EntityPartition.ENEMY)

                if #ent2 > 0 then
                    for i=1, #ent2 do 
                        if not (ent2[i].Type == monster.type and ent2[i].Variant == monster.variant) then
                            ent2 = ent2[i]
                            break
                        end
                    end

                    if type(ent2) ~= "table" then 
                        data.velocity = (data.velocity*3 + (ent2.Position - ent.Position):Resized(data.velocity:Length())) * 0.25
                    end
                end
            end


            if ent:IsFrame(3,1) and data.scale > 0 then
                local puddle = Isaac.Spawn(ent.Type,ent.Variant,data.color,ent.Position,Vector.Zero,ent.SpawnerEntity or ent)
                GODMODE.get_ent_data(puddle).spawner = ent
                GODMODE.get_ent_data(puddle).max_size = data.max_size or 1.0
                puddle.CollisionDamage = ent.CollisionDamage
            end

            if data.color == 3 and data.bounces_left == nil then 
                data.bounces_left = 1
                data.velocity = data.velocity * 1.675
            end

            if data.color == 5 and data.max_size ~= 1.5 then 
                data.velocity = data.velocity * 1.25
                data.max_size = 1.5
                ent.CollisionDamage = ent.CollisionDamage * 1.25
            end

            if math.abs(data.velocity:GetAngleDegrees() - data.avg_vel) > 10 and ent.FrameCount > 20 then
                if data.bounces_left ~= nil and data.bounces_left > 0 then 
                    local ang = math.rad((-ent.Velocity:GetAngleDegrees()) % 360)
                    local len = ent.Velocity:Length()
                    data.velocity = Vector(math.cos(ang)*len,math.sin(ang)*len)
                    ent.Velocity = data.velocity
                    data.avg_vel = ent.Velocity:GetAngleDegrees()
                    data.bounces_left = 0
                else
                    ent:Remove()
                end
            end
        end,
    },
    [1] = {
        anim="White",
        timeout=50,
        on_collide = function(ent)
            ent:AddSlowing(EntityRef(ent.SpawnerEntity or ent),30*8,0.8,Color(1, 1, 1, 1, 0.25, 0.25, 0.25))
            ent:AddEntityFlags(EntityFlag.FLAG_ICE)
        end,
        update = function(data,ent) end,
    },
    [2] = {
        anim="Pink",
        timeout=30,
        on_collide = function(ent)
        end,
        update = function(data,ent) end,
    },
    [3] = {
        anim="Red",
        timeout=90,
        on_collide = function(ent)
            ent:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
        end,
        update = function(data,ent) end,
    },
    [4] = {
        anim="LightBrown",
        timeout=40,
        on_collide = function(ent, puddle)
        end,
        update = function(data,ent) end,
    },
    [5] = {
        anim="DarkBrown",
        timeout=20,
        on_collide = function(ent, puddle)
        end,
        update = function(data,ent) end,
    }
}

monster.data_init = function(self, params)
    local ent = params[1]
    local data = params[2]
    if not monster.subtypes[ent.SubType] then ent:Remove() return end
    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.CollisionDamage = 1 
    data.max_size = 1.0

    if ent.SubType == 0 then 
        ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        data.scale = 1
    else
        ent.DepthOffset = -100
        data.timeout = 30*4
        data.scale = 0
    end

    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
    ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
    ent:GetSprite():Play(monster.subtypes[ent.SubType].anim,true)
    ent:GetSprite().PlaybackSpeed = 0.0
    ent:ToNPC().Scale = 0
    data.sprite_frame = ent:GetDropRNG():RandomInt(6)
    ent:GetSprite():SetFrame(data.sprite_frame)
end
monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    if not monster.subtypes[ent.SubType] then ent:Remove() return end
    local data = GODMODE.get_ent_data(ent)

    if data then
        monster.subtypes[ent.SubType].update(data,ent)

        if ent.SubType > 0 then
            ent.Velocity = Vector.Zero
            ent.DepthOffset = -100
        else
            if data.timeout == nil then 
                data.timeout = monster.subtypes[data.color or 0].timeout
            end
        end

        data.scale = math.min((data.scale or 0) + (1/10), 1.0)

        if data.scale == 1.0 then
            data.timeout = math.max(0,(data.timeout or 120)-1) 

            if data.timeout <= 30 then
                local scale = math.max(0,data.timeout) / 30
                ent:ToNPC().Scale = scale*data.max_size
            else
                ent:ToNPC().Scale = data.scale*data.max_size
            end

            if data.timeout == 0 then
                ent:Remove()
            end
        else
            ent:ToNPC().Scale = data.scale*data.max_size
        end
        ent.SizeMulti = ent.SpriteScale
    else
        ent:Remove()
    end
end

monster.npc_collide = function(self,ent,ent2,entfirst)
    if ent2:IsVulnerableEnemy() and ent2.Type ~= EntityType.ENTITY_FIREPLACE and not (ent2.Type == monster.Type and ent2.Variant == monster.Variant) and not ent2:IsDead() then
        if ent2.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_GROUND then
            if ent2:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN) then return true end
            if ent:IsFrame(10,1) then 
                ent2:TakeDamage(ent.CollisionDamage,0,EntityRef(ent.SpawnerEntity or ent),0)
                if ent2.HitPoints - ent.CollisionDamage <= ent.CollisionDamage and ent.SubType == 4 then 
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BROWN_CLOUD, 0, ent2.Position,Vector.Zero, ent.SpawnerEntity or ent)
                end
            end

            monster.subtypes[ent.SubType].on_collide(ent2,ent)
        end
    end

    return true
end

-- GODMODE.godhooks.hook_list["npc_kill"]("npc_kill", { 
--     instance=Isaac.GetItemIdByName("Morphine Used"),

--     npc_kill = function(self, ent)
--         local data = GODMODE.get_ent_data(enthit)
--         GODMODE.log("hillo!!",true)
--         if data ~= nil and (enthit.Type ~= monster.type and enthit.Variant ~= monster.variant) and (data.soft_bean_puddle_hit or false) == true then
--         end
--     end
-- })

return monster