local monster = {}
monster.name = "Hostess"
monster.type = GODMODE.registry.entities.hostess.type
monster.variant = GODMODE.registry.entities.hostess.variant

local phase_threshold = 0.33
local function spawn_tendrils(ent,data,count,center,radius)
    local room = GODMODE.room
    data.grid_map = data.grid_map or {}
    for i=1,count do 
        local grid = room:GetGridIndex(center + RandomVector():Resized(ent:GetDropRNG():RandomFloat()*radius))
        local depth = 25 

        while (data.grid_map[tostring(grid)] ~= nil or not room:IsPositionInRoom(room:GetGridPosition(grid),1)) and depth > 0 do 
            grid = room:GetGridIndex(center + RandomVector():Resized(ent:GetDropRNG():RandomFloat()*radius))
            depth = depth - 1
        end

        data.grid_map[tostring(grid)] = true
        local tendril_pos = room:GetGridPosition(grid)
        local tendril = Isaac.Spawn(monster.type,monster.variant,1,tendril_pos,Vector.Zero,ent)
        tendril.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        tendril:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        tendril.Position = tendril_pos
    end
end

monster.set_delirium_visuals = function(self,ent)
    for i=0,5 do 
        ent:GetSprite():ReplaceSpritesheet(i,"gfx/bosses/deliriumforms/the_hostess.png")
    end
    ent:GetSprite():LoadGraphics()
end

local attempt_play = function(data, ent,anim)
    if ent.HitPoints / ent.MaxHitPoints < phase_threshold then 
        ent:GetSprite():Play("Phase",true)
        GODMODE.get_ent_data(ent).phase = 1
        if data.tear_map ~= nil then
            for i=1, #data.tear_map do
                if data.tear_map[i] ~= nil then
                    data.tear_map[i].tear:Kill()
                end
            end
        end
    else
        ent:GetSprite():Play(anim,true)
    end
end

monster.npc_update = function(self, ent, data, sprite)
    local player = ent:GetPlayerTarget()

    if ent.SubType == 0 then --Hostess
        if data.attack_type == nil or ent:GetSprite():IsFinished("Appear")then
            data.attack_type = 1
            data.tear_map = {}
            sprite:Play("Idle",true)
        end

    
        data.abs_pos = data.abs_pos or ent.Position     
        ent.Position = data.abs_pos
        ent.Velocity = Vector(0,0)

        if sprite:IsEventTriggered("Roar") then
            GODMODE.sfx:Play(SoundEffect.SOUND_BOSS_LITE_SLOPPY_ROAR)
        end

        if data.tear_map ~= nil then
            for i=1, #data.tear_map do
                if data.tear_map[i] ~= nil then
                    local tear = data.tear_map[i].tear
                    if tear ~= nil and tear:IsDead() == false then
                        if tear.Height ~= data.tear_map[i].height then
                            tear.Height = (tear.Height * 5 + data.tear_map[i].height) / 6.0
                        else
                            tear.Height = -20
                        end
            
                        if not GODMODE.util.is_delirium() then 
                            tear.Velocity = tear.Velocity * 1.025
                        else
                            if (data.phase or 0) == 2 then 
                                tear.Velocity = tear.Velocity * 1.02
                            else
                                tear.Velocity = tear.Velocity * 1.0075
                            end
                        end
                    else
                        table.remove(data.tear_map,i)
                    end
                end
            end
        end
        
        if (data.phase or 0) ~= 2 then
            if sprite:IsPlaying("Idle") and sprite:GetFrame() == 49 then
                if ent:GetDropRNG():RandomFloat() < 0.6 or data.attack_type == -1 then
                    attempt_play(data,ent,"AttackUp")           
                    data.grid_map = {}
                    data.attack_type = math.max(data.attack_type,0)
                else
                    sprite:Play("GoDown", true)
                    data.attack_type = 0.1
                end
            end

            if (data.phase or 0) == 1 and sprite:IsFinished("Phase") then 
                data.phase = 2
                local room = GODMODE.room 
                local tl = room:GetTopLeftPos()
                local br = room:GetBottomRightPos()
                local corns = {
                    tl,
                    Vector(tl.X,br.Y-26),
                    br-Vector(26,26),
                    Vector(br.X-26,tl.Y)
                }

                for _,pos in ipairs(corns) do 
                    local cluster = Isaac.Spawn(GODMODE.registry.entities.nerve_cluster.type,GODMODE.registry.entities.nerve_cluster.variant,1,room:GetGridPosition(room:GetClampedGridIndex(pos)),Vector.Zero,ent)
                    cluster.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    cluster:Update()
                end

                sprite:Play("Idle2",true)
            end
        
            if sprite:IsPlaying("GoDown") and sprite:GetFrame() == 49 then
                sprite:Play("IdleDown", true)
            end
            if sprite:IsPlaying("AttackDown") and sprite:GetFrame() == 49 then
                sprite:Play("IdleDown", true)
            end
            if sprite:IsPlaying("AttackUp") and sprite:GetFrame() == 49 then
                attempt_play(data,ent,"Idle")
            end
            if sprite:IsPlaying("GoUp") and sprite:GetFrame() == 49 then
                attempt_play(data,ent,"Idle")
            end
        
            if sprite:IsPlaying("AttackUp") and sprite:GetFrame() == 2 then
                data.attack_type = ent:GetDropRNG():RandomFloat()
            end
        
            if sprite:IsPlaying("AttackDown") and sprite:GetFrame() == 2 then
                data.attack_type = ent:GetDropRNG():RandomFloat()
                data.grid_map = {}
                data.tear_map = {}
            end

            if sprite:IsPlaying("Phase") or sprite:IsPlaying("Phase2") then
                if sprite:IsEventTriggered("Explosion") then 
                    ent:BloodExplode()
                elseif sprite:IsEventTriggered("Fire") then 
                    ent:BloodExplode()
                    ent:BloodExplode()
                    ent:BloodExplode()
                end
            elseif sprite:IsEventTriggered("Fire") then
                ent:BloodExplode()
                GODMODE.game:ShakeScreen(5)

                if data.attack_type > 0.4 and sprite:IsPlaying("AttackDown") or data.attack_type > 0.6 and not sprite:IsPlaying("AttackDown") then
                    if sprite:IsPlaying("AttackDown") then --down summon attack / tendril attack
                        local nm = GODMODE.util.count_enemies(ent,EntityType.ENTITY_HOST)

                        if data.attack_type > 0.75 or nm >= 3 then 
                            spawn_tendrils(ent,data,14+(1.0-ent.HitPoints/ent.MaxHitPoints)*10,ent.Position,256)
                        else
                            spawn_tendrils(ent,data,4+(1.0-ent.HitPoints/ent.MaxHitPoints)*10,ent.Position,256)
                            if nm < 3 then
                                local dpth = 5
                                local pos = GODMODE.room:GetRandomPosition(32.0)
                                while dpth > 0 and (player.Position-pos):Length() < 64 do 
                                    pos = GODMODE.room:GetRandomPosition(32.0)
                                    dpth = dpth - 1
                                end

                                local t = Isaac.Spawn(EntityType.ENTITY_HOST,0,0,GODMODE.room:FindFreeTilePosition(pos,256),RandomVector(),ent)
                                t.Velocity = Vector(-5 + ent:GetDropRNG():RandomFloat()*10,8-ent:GetDropRNG():RandomFloat()*7.5)
                                t.MaxHitPoints = t.MaxHitPoints * 0.8
                                t.HitPoints = t.MaxHitPoints
                            end
                        end
                    else --spread + tendrils attack
                        for l=0,1 do
                            for i=0,10 do
                                local ang = player.Position - ent.Position
                                local f = math.rad(ang:GetAngleDegrees()+ent:GetDropRNG():RandomFloat() * 270 + 45)
                                local spd = 1 + ent:GetDropRNG():RandomFloat() * 0.125 - (0.5 * math.abs(f - ang:GetAngleDegrees()) / 360)
                                spd = spd / ((l*0.5 + 1))
                                ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
                                local t = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position + ang,ang*spd,ent)
                                t = t:ToProjectile()
                                t.FallingSpeed = 0.0
        
                                if not GODMODE.util.is_delirium() then 
                                    t.FallingAccel = -(5.95/60.0)
                                else
                                    t.FallingAccel = -(5/60.0)
                                end
        
                                t.Height = -80
                                table.insert(data.tear_map, {tear=t,height=-20})
                            end
                    end

                    spawn_tendrils(ent,data,2+(1.0-ent.HitPoints/ent.MaxHitPoints)*8,player.Position,256)
                    spawn_tendrils(ent,data,1+(1.0-ent.HitPoints/ent.MaxHitPoints)*2,ent.Position,128)
                    end
                else --transition attack + down attack
                    if sprite:IsPlaying("AttackDown") or sprite:IsPlaying("GoDown") or sprite:IsPlaying("GoUp") then
                        local count = 1
                        if not sprite:IsPlaying("AttackDown") then count = 0 end
                        local bul_count = 18
                        local off = ent:GetDropRNG():RandomFloat() * (360 / bul_count)
                        for i=0,bul_count-1 do
                            local ang = player.Position - ent.Position
                            local f = math.rad(off + (360 / bul_count) * i)
                            local spd = 1.4
                            ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
                            local t = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position + ang,ang*spd*Vector(1,0.8),ent)
                            t = t:ToProjectile()
                            t.FallingSpeed = 0.0
    
                            if not GODMODE.util.is_delirium() then 
                                t.FallingAccel = -(5.95/60.0)
                            else
                                t.FallingAccel = -(5/60.0)
                            end
    
                            t.Height = -30
                            table.insert(data.tear_map, {tear=t,height=-20})
                        end

                        spawn_tendrils(ent,data,1+(1.0-ent.HitPoints/ent.MaxHitPoints)*3,ent.Position,96)
                    else --pincer attack
                        for i=-2,2 do
                            for l=0,1 do 
                                if not (l == 1 and i == 0) then 
                                    local spd = 1.75 - (math.abs(i/3) * 0.75)-l*0.25
                                    local ang = player.Position - ent.Position
                                    local f = math.rad(ang:GetAngleDegrees()-i*(25-10*l))
                                    ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
                                    local t = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position + ang,ang*spd,ent)
                                    t = t:ToProjectile()
                                    t.FallingSpeed = 0.0
            
                                    if not GODMODE.util.is_delirium() then 
                                        t.FallingAccel = -(5.95/60.0)
                                    else
                                        t.FallingAccel = -(5/60.0)
                                    end
            
            
                                    t.Height = -80
                                    table.insert(data.tear_map, {tear=t,height=-20})
                                end
                            end
                        end

                        spawn_tendrils(ent,data,1+(1.0-ent.HitPoints/ent.MaxHitPoints)*3,ent.Position,96)
                    end
                end
            end
        
            if sprite:IsPlaying("IdleDown") and sprite:GetFrame() == 49 then
                if ent:GetDropRNG():RandomFloat() < 0.75 - (0.33 * (data.attack_down_count or 0)) or (data.attack_down_count or 0) == 0 then
                    sprite:Play("AttackDown", true)     
                    data.attack_down_count = (data.attack_down_count or 0) + 1       
                else
                    sprite:Play("GoUp", true)            
                    data.attack_down_count = 0
                    data.attack_type = -1
                end
            end    
        else --final phase
            local anim_num = 2
            if (data.cluster_count or 1) == 0 then anim_num = 3 end
            data.prev_anim_num = data.prev_anim_num or anim_num 

            if data.prev_anim_num ~= anim_num and (data.cluster_count or 1) == 0 then 
                if not sprite:IsPlaying("Phase2") and ent.I1 ~= 1 then 
                    sprite:Play("Phase2",true)
                    ent.I1 = 1
                elseif sprite:IsFinished("Phase2") then 
                    data.prev_anim_num = anim_num
                    sprite:Play("Idle3",true)
                end
            else 
                if sprite:IsFinished("Idle"..anim_num) then 
                    sprite:Play("Attack"..anim_num,true)
                    data.grid_map = {}
                    data.fired = false
                    data.prev_anim_num = anim_num
                elseif sprite:IsFinished("Attack"..anim_num) then 
                    sprite:Play("Idle"..anim_num,true)
                    data.prev_anim_num = anim_num
                end    
            end
            

            if data.cluster_count == nil or ent:IsFrame(10,1) then 
                data.cluster_count = GODMODE.util.count_enemies(nil,GODMODE.registry.entities.nerve_cluster.type,GODMODE.registry.entities.nerve_cluster.variant,-1)
            end

            if ent:IsFrame(40,1) and data.cluster_count == 0 then 
                local bul_count = 8
                local off = ent.FrameCount * 3
                for i=0,bul_count-1 do
                    local ang = player.Position - ent.Position
                    local f = math.rad(off + (360 / bul_count) * i)
                    local spd = 1.0
                    ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
                    local t = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position + ang,ang*spd,ent)
                    t = t:ToProjectile()
                    t.FallingSpeed = 0.0

                    if not GODMODE.util.is_delirium() then 
                        t.FallingAccel = -(5.95/60.0)
                    else
                        t.FallingAccel = -(5/60.0)
                    end

                    t.Height = -30
                    table.insert(data.tear_map, {tear=t,height=-20})
                end
            end

            if sprite:IsPlaying("Phase2") then
                if sprite:IsEventTriggered("Explosion") then 
                    ent:BloodExplode()
                elseif sprite:IsEventTriggered("Fire") then 
                    ent:BloodExplode()
                    ent:BloodExplode()
                    ent:BloodExplode()
                end
            elseif sprite:IsEventTriggered("Fire") then 
                spawn_tendrils(ent,data,1+(1.0-ent.HitPoints/(ent.MaxHitPoints*phase_threshold))*2,player.Position,512)

                if data.fired ~= true and anim_num == 3 then 
                    data.fired = true 
                    local eye_offset = Vector(0,-144)
                    local f = math.floor(((player.Position - Vector(0,player.Size / 2.0)) - (ent.Position+eye_offset)):GetAngleDegrees())
                    local tell = Isaac.Spawn(GODMODE.registry.entities.unholy_order.type,GODMODE.registry.entities.unholy_order.variant,f,ent.Position+eye_offset,Vector.Zero,ent)
                    local tell_data = GODMODE.get_ent_data(tell)
                    tell_data.fire_time = 30
                    tell_data.laser_timeout = 10
                    tell.DepthOffset = 1000
                    tell.Parent = ent
                end
            end
        end
    else --tendril
        if sprite:IsFinished("Tendril") and ent.FrameCount > 2 then 
            ent:Remove()
        end

        if not sprite:IsPlaying("Tendril") then 
            sprite:Play("Tendril",true)
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end

        data.root_pos = data.root_pos or ent.Position
        ent.Velocity = ent.Velocity * 0.8 + (data.root_pos - ent.Position) * (1/20.0)

        if sprite:IsEventTriggered("Fire") then 
            if ent.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE then 
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
            else
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            end
        end
    end
end

monster.npc_remove = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant and ent.SubType == 0 and not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
        local brain = Isaac.Spawn(GODMODE.registry.entities.infested_membrain.type,GODMODE.registry.entities.infested_membrain.variant,0,ent.Position,Vector.Zero,ent)
        brain:BloodExplode()
        local data = GODMODE.get_ent_data(ent)
        if data.tear_map ~= nil then
            for i=1, #data.tear_map do
                if data.tear_map[i] ~= nil then
                    data.tear_map[i].tear:Kill()
                end
            end
        end
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if (enthit.Type == monster.type and enthit.Variant == monster.variant) then
        local data = GODMODE.get_ent_data(enthit)
        if (enthit:GetSprite():IsPlaying("IdleDown") or enthit:GetSprite():IsPlaying("AttackDown") or enthit:GetSprite():IsPlaying("Phase")
            or enthit:GetSprite():IsPlaying("GoUp")) or (entsrc.Type == EntityType.ENTITY_LASER and entsrc.SpawnerType == monster.type and entsrc.SpawnerVariant == monster.variant) 
            or (enthit.HitPoints / enthit.MaxHitPoints < phase_threshold and data.phase ~= 2) then 
            
            return false
        else
            local nm = GODMODE.util.count_enemies(ent,GODMODE.registry.entities.nerve_cluster.type,GODMODE.registry.entities.nerve_cluster.variant,1)

            if nm > 0 then 
                enthit:SetColor(Color(1, 1, 1, 1, 0.5, 0.25, 0.25), 15, 1, true, false)
                return false
            end
        end
    end
end

return monster