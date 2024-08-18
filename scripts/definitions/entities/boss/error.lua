local monster = {}

monster.name = "Error Keeper (Boss)"
monster.type = GODMODE.registry.entities.error_boss.type
monster.variant = GODMODE.registry.entities.error_boss.variant

local teleport_delay = 10
local in_spread = 60
local out_count = 8
local time_extend_mult = 3
local valid_flags = {
    ProjectileFlags.BOOMERANG,
    ProjectileFlags.ORBIT_CW,
    ProjectileFlags.ORBIT_CCW,
    ProjectileFlags.GHOST,
    ProjectileFlags.WIGGLE,
    ProjectileFlags.BOUNCE_FLOOR,
    ProjectileFlags.CREEP_BROWN,
    ProjectileFlags.BURST,
    ProjectileFlags.CURVE_LEFT,
    ProjectileFlags.CURVE_RIGHT,
    ProjectileFlags.TRIANGLE,
    ProjectileFlags.SINE_VELOCITY, 
    ProjectileFlags.SHIELDED,
    ProjectileFlags.MEGA_WIGGLE,
    ProjectileFlags.SAWTOOTH_WIGGLE,
}    

monster.fire_tear = function(ent,dir,speed)
    local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position,Vector(1,0):Rotated(dir):Resized(speed),ent)
    proj = proj:ToProjectile()
    proj.FallingAccel = -0.07
    proj.Scale = ent:GetDropRNG():RandomFloat()*0.8+0.6
    local color = ent:GetDropRNG():RandomFloat()
    proj:SetColor(Color(math.sin(color*6.28),math.sin(color*6.28+2.1),math.sin(color*6.28+4.2),1),999,1,false,false)
    local count = 0

    while count < 2 do 
        local flag = valid_flags[ent:GetDropRNG():RandomInt(#valid_flags)+1]

        if not proj:HasProjectileFlags(flag) then 
            proj:AddProjectileFlags(flag)
            count = count + 1
        end
    end
end

monster.spawn_clone = function(ent,data)
    local clone = Isaac.Spawn(monster.type,monster.variant,1,GODMODE.room:GetRandomPosition(ent.Size * 2),Vector.Zero,ent)
    data.clone = math.max(data.clone_time,data.clone - 1)
    clone:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    clone:GetSprite():Play("WarpInClone",true)  
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()
    local anim = sprite:GetAnimation()

    if sprite:IsEventTriggered("Shoot") and ent.SubType == 0 and data.clone == 0 then 
        if anim == "WarpOut" then 
            for i=1,out_count do 
                monster.fire_tear(ent,Vector(1,0):Rotated(i*(360/out_count)):GetAngleDegrees(),4)
            end
        elseif anim == "WarpIn" then 
            data.fire_count = (data.fire_count or 0) + 1

            if ent:GetDropRNG():RandomFloat() < data.fire_count * 0.1 - 0.3 then 
                data.fire_count = 0
                monster.fire_tear(ent,(player.Position-ent.Position):Rotated(ent:GetDropRNG():RandomFloat()*in_spread-in_spread/2):GetAngleDegrees(),3+ent:GetDropRNG():RandomFloat())
            end
        end
    end

    data.clone = data.clone or 0
    data.last_clone = data.last_clone or 0
    if sprite:IsFinished(anim) then 
        if anim == "WarpOut" then 
            ent.I2 = ent.I2 - 1

            if ent.I2 == teleport_delay*3 then 
                data.clone_time = 1
                monster.spawn_clone(ent,data) 
            elseif ent.I2 == 1 then 
                data.cur_spot = GODMODE.room:GetRandomPosition(ent.Size * 2)
            elseif ent.I2 <= 0 then 
                if data.clone > 0 then 
                    sprite:Play("WarpInClone",true)
                else
                    sprite:Play("WarpIn",true)
                end

                ent.I2 = teleport_delay
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            end
        else
            if ent:GetDropRNG():RandomFloat() < -0.3 + ent.I1 * 0.3 and data.clone == 0 then 
                sprite:Play("WarpOut",true)
                ent.I2 = teleport_delay
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                ent.I1 = 0
                if ent:GetDropRNG():RandomFloat() < 0.4+(data.last_clone or 0)*0.6 and ent.SubType == 0 then 
                    data.clone = 5+ent:GetDropRNG():RandomInt(6)+math.floor((1-ent.HitPoints/ent.MaxHitPoints)*15)
                    ent.I2 = ent.I2 + teleport_delay*2 + data.clone * time_extend_mult + 1
                    data.last_clone = 0
                else
                    data.last_clone = data.last_clone + 1
                end
            else 
                if ent.SubType == 1 then 
                    sprite:Play("Clone",true)        
                    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                elseif data.clone == 1 or anim == "Hide" then 
                    sprite:Play("Hide",true)
                else
                    sprite:Play("Idle"..(ent:GetDropRNG():RandomInt(3)+1),true)
                    ent.I1 = ent.I1 + 1
                end
            end
        end
    end

    if data.clone > 1 and data.clone_time == 1 then 
        if ent:IsFrame(time_extend_mult,1) and ent:GetDropRNG():RandomFloat() < 0.5 then 
            monster.spawn_clone(ent,data) 
        end
    else 
        data.clone_time = 0
    end

    data.cur_spot = data.cur_spot or ent.Position
    ent.Velocity = data.cur_spot - ent.Position 
    ent.SpriteOffset = Vector(0,-12)
end

monster.player_collide = function(self,player,ent,entfirst)
    return true
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)
    if enthit.Type == monster.type and enthit.Variant == monster.variant and enthit.SubType == 0 and data.clone > 0 then 
        data.clone = 0
        data.clone_time = 0
        enthit = enthit:ToNPC()
        enthit:GetSprite():Play("WarpOut",true)
        enthit.I2 = teleport_delay
        enthit.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

        GODMODE.util.macro_on_enemies(ent,monster.type,monster.variant,1,function(ent)
            ent:Kill()
        end)
	end
end

local rewards = {
    {EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,0,3},
    {EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_NULL,0,1},
    {EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,Card.CARD_FOOL,1},
}

monster.npc_kill = function(self,ent)
    if ent.SubType == 0 then 
        GODMODE.util.macro_on_enemies(ent,monster.type,monster.variant,1,function(ent2)
            ent2:Kill()
        end)

        if GODMODE.room:GetType() == RoomType.ROOM_ERROR then 
            local room = GODMODE.room
            Isaac.GridSpawn(GridEntityType.GRID_TRAPDOOR, 0, room:FindFreePickupSpawnPosition(room:GetCenterPos()), true)
    
            for _,reward in ipairs(rewards) do 
                local count = reward[4]
    
                while count > 0 do
                    local rew = Isaac.Spawn(reward[1],reward[2],reward[3],room:FindFreePickupSpawnPosition(room:GetRandomPosition(64)),Vector.Zero,nil)
    
                    if reward[2] ~= PickupVariant.PICKUP_COLLECTIBLE then 
                        rew:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        rew:GetSprite():Play("Appear",true)
                    end
    
                    count = count - 1
                end
            end
        end
    elseif ent.SubType == 1 and ent.HitPoints <= 0 then 
        for i=1,4 do
            monster.fire_tear(ent,Vector(1,0):Rotated(i*90):GetAngleDegrees(),3)
        end
    end
end

-- monster.npc_collide = function(self,ent,ent2,entfirst)
-- end

-- monster.npc_kill = function(self,ent)
--     for i=1,4 do 
--         Isaac.Spawn(GODMODE.registry.entities.fruit.type,GODMODE.registry.entities.fruit.variant,1, ent.Position, RandomVector():Resized(ent:GetDropRNG():RandomFloat()*0.5+1.5), nil)
--     end
-- end

return monster