local monster = {}
monster.name = "The Grand Marshall"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, params)
    local ent = params[1]
    local data = params[2]
    ent.HitPoints = ent.HitPoints + math.min(1000,(GODMODE.util.get_basic_dps(ent) / 10.0) * 100)
    ent.MaxHitPoints = ent.HitPoints
end
monster.set_delirium_visuals = function(self,ent)
    for i=0,5 do 
        ent:GetSprite():ReplaceSpritesheet(i,"gfx/bosses/deliriumforms/the_grand_marshall.png")
    end
    ent:GetSprite():LoadGraphics()
end

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()

    local get_atck_name = function()
        if ent.HitPoints / ent.MaxHitPoints < 0.66 then
            return "Attack1"
        else
            return "Attack0"
        end
    end
    local get_idle_name = function()
        if ent.HitPoints / ent.MaxHitPoints < 0.66 then
            return "Idle1"
        else
            return "Idle0"
        end
    end

    if ent.HitPoints / ent.MaxHitPoints < 0.66 and data.has_played ~= true then
        ent:GetSprite():Play("Phase2",true)
        data.has_played = true
    end
    if not ent:GetSprite():IsPlaying(get_atck_name()) and data.angels == nil and data.real_time > 1 then
        data.angels = {}
        data.tears = {}
        data.tear_time = {}
        data.laser_cool = 0
        data.init = true
        data.attack_count = 0
        ent:GetSprite():Play(get_atck_name(),true)
        data.base_tear_color = Color(0.5,0.5,1,1,0,0,0.9)
        data.spawn_tear = function(self, ang, speed, curve)
            if curve == nil then curve = 0 end
            local vel = Vector(math.cos(ang) * speed,math.sin(ang) * speed)
            local tear = Game():Spawn(EntityType.ENTITY_PROJECTILE,0,ent.Position,Vector(math.cos(ang)*speed,math.sin(ang)*speed),ent,0,player.InitSeed)
            tear = tear:ToProjectile()
            tear.Position = tear.Position + tear.Velocity * 2.0
            tear.Scale = 2.0
            tear.Damage = 2.0
            tear.Height = -25
            tear.FallingSpeed = 0.0
            if not GODMODE.util.is_delirium() then 
                tear.FallingAccel = -(6/60.0)
            else
                tear.FallingAccel = -(4/60.0)
            end
            tear.Color = Color(0.5,0.5,1,1,0,0,0.9)
            local tear_data = GODMODE.get_ent_data(tear)
            self.tears[tear.Index] = tear
            self.tear_time[tear.Index] = 0
        end
    end

    if data.time % 30 == 0 then 
        local new_times = {}
        for ind,time in pairs(data.tear_time) do
            if time ~= nil then
                new_times[ind] = time
            end
        end
        data.tear_time = new_times 
        local new_tears = {}
        for ind,tear in pairs(data.tears) do
            if tear ~= nil and not tear:IsDead() then
                new_tears[ind] = tear
            end
        end
        data.tears = new_tears
    end

    data.tears = data.tears or {}
    for i,tear in pairs(data.tears) do
        if ent:GetSprite():IsPlaying("Death") then
            tear:Kill()
        end
        if tear == nil or tear:IsDead() then 
            data.tears[i] = nil 
            data.tear_time[i] = nil 
        else
            data.tear_time[i] = (data.tear_time[i] or 0) + 1
            local tear_time = data.tear_time[i]
    
            if tear_time % 20 == 0 and tear_time <= 80 and tear_time > 20 then
                local dist = player.Position - tear.Position
                --local ang = dist:GetAngleDegrees()
                tear.Velocity = dist:Resized(tear.Velocity:Length())
    
                if tear_time >= 80 then 
                    tear.Velocity = tear.Velocity * 2.0 
                end
                
                tear.Color = Color(1.0,0.95,0,1,0.5,0,0.3)
            end
    
            if tear_time < 80 then
                tear.Color = Color.Lerp(tear.Color, data.base_tear_color, 1.0 - tear_time % 30 / 30)
            end                
        end
    end    

    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS 
    if data.angels ~= nil then
        local spd = 2.35
        local ti = player.Position - ent.Position

        if ent:GetSprite():IsPlaying("Phase2") and ent:GetSprite():GetFrame() == 2 then
            local tx = Game():GetRoom():GetTopLeftPos().X
            local ty = Game():GetRoom():GetTopLeftPos().Y
            local bx = Game():GetRoom():GetBottomRightPos().X
            local by = Game():GetRoom():GetBottomRightPos().Y
            for l=0,1 do
                local x = {26+ent:GetDropRNG():RandomFloat()*(bx-tx),bx-26,26+ent:GetDropRNG():RandomFloat()*(bx-tx),26}
                local y = {ty+26,26+ent:GetDropRNG():RandomFloat()*(by-ty),by-26,26+ent:GetDropRNG():RandomFloat()*(by-ty)}
                local i = math.floor(ent:GetDropRNG():RandomFloat()*3.5+1)
                Game():Spawn(Isaac.GetEntityTypeByName("Guard of the Father"),Isaac.GetEntityVariantByName("Guard of the Father"),Vector(x[i%4+1],y[i%4+1]),Vector(0,0),ent,90 + i * 90,ent.InitSeed)
            end
            for l=0,4 do
                local x = {26+ent:GetDropRNG():RandomFloat()*(bx-tx),bx-26,26+ent:GetDropRNG():RandomFloat()*(bx-tx),26}
                local y = {ty+26,26+ent:GetDropRNG():RandomFloat()*(by-ty),by-26,26+ent:GetDropRNG():RandomFloat()*(by-ty)}
                local i = math.floor(ent:GetDropRNG():RandomFloat()*3.5+1)
                local ang = Game():Spawn(Isaac.GetEntityTypeByName("Marshall Pawn"),Isaac.GetEntityVariantByName("Marshall Pawn"),Vector(x[i%4+1],y[i%4+1]),Vector(0,0),ent,90 + i * 90,ent.InitSeed)
                GODMODE.get_ent_data(ang).slowed = false
            end
        elseif ent:GetSprite():IsPlaying("Phase2") and ent:GetSprite():GetFrame() == 34 then
            if not GODMODE.util.is_delirium() then 
                ent:GetSprite():Play("TeleportUp",true)
            end
        end

        if ent.HitPoints / ent.MaxHitPoints < 0.33 and not data.p3 then
            if not GODMODE.util.is_delirium() then 
                local tx = Game():GetRoom():GetTopLeftPos().X
                local ty = Game():GetRoom():GetTopLeftPos().Y
                local bx = Game():GetRoom():GetBottomRightPos().X
                local by = Game():GetRoom():GetBottomRightPos().Y
                for l=0,3 do
                    local x = {26+ent:GetDropRNG():RandomFloat()*(bx-tx),bx-26,26+ent:GetDropRNG():RandomFloat()*(bx-tx),26}
                    local y = {ty+26,26+ent:GetDropRNG():RandomFloat()*(by-ty),by-26,26+ent:GetDropRNG():RandomFloat()*(by-ty)}
                    local i = math.floor(ent:GetDropRNG():RandomFloat()*3.5+1)
                    Game():Spawn(Isaac.GetEntityTypeByName("Guard of the Father"),Isaac.GetEntityVariantByName("Guard of the Father"),Vector(x[i%4+1],y[i%4+1]),Vector(0,0),ent,90 + i * 90,ent.InitSeed)
                end
                for l=0,5 do
                    local x = {26+ent:GetDropRNG():RandomFloat()*(bx-tx),bx-26,26+ent:GetDropRNG():RandomFloat()*(bx-tx),26}
                    local y = {ty+26,26+ent:GetDropRNG():RandomFloat()*(by-ty),by-26,26+ent:GetDropRNG():RandomFloat()*(by-ty)}
                    local i = math.floor(ent:GetDropRNG():RandomFloat()*3.5+1)
                    local ang = Game():Spawn(Isaac.GetEntityTypeByName("Marshall Pawn"),Isaac.GetEntityVariantByName("Marshall Pawn"),Vector(x[i%4+1],y[i%4+1]),Vector(0,0),ent,90 + i * 90,ent.InitSeed)
                    GODMODE.get_ent_data(ang).slowed = false
                end
                ent:GetSprite():Play("TeleportUp",true)
            end
            data.p3 = true
        end

        ent.Velocity = Vector(0,0)

        for i=1, #data.angels do
            if data.angels[i] ~= nil and data.angels[i]:IsActiveEnemy(false) then
                local a = data.angels[i]
                local ang = math.rad(i * (360 / #data.angels) + (ent.FrameCount * 3) % 360)
                local targ_pos = ent.Position + Vector(math.cos(ang)*(112+math.cos(ent.FrameCount / 20)*16),math.sin(ang)*(112+math.cos(ent.FrameCount / 20)*16))
                a.Position = a.Position + (targ_pos - a.Position) * (1/20)
            else
                local d = {}
                for i=1,#data.angels do
                    if data.angels[i]:IsActiveEnemy(false) then
                        table.insert(d,data.angels[i])
                    end
                end
                data.angels = d
            end
        end

        if ent:GetSprite():IsEventTriggered("Teleport") and ent:GetSprite():IsPlaying("TeleportUp") then
            ent.CollisionDamage = 0
            ent.Size = 0
            ent:GetSprite():Play("TeleportLoop", true)
        end
        if ent:GetSprite():IsEventTriggered("Teleport") and ent:GetSprite():IsPlaying("TeleportDown") then
            ent.CollisionDamage = 2
            ent.Size = 26
            data.size = 0
        end

        if ent:GetSprite():IsPlaying("TeleportDown") and ent:GetSprite():GetFrame() == 18 then
            ent:GetSprite():Play("Idle1",true)
        end

        if ent:GetSprite():IsPlaying("TeleportLoop") then
            ent.Position = Vector(0,0)
            data.angels = {}
            Isaac.DebugString("Time = "..data.time)
            if data.time % 5 == 0 then
                local nm = GODMODE.util.count_enemies(nil, Isaac.GetEntityTypeByName("Marshall Pawn"), Isaac.GetEntityVariantByName("Marshall Pawn"))
                   + GODMODE.util.count_enemies(nil, Isaac.GetEntityTypeByName("Guard of the Father"), Isaac.GetEntityVariantByName("Guard of the Father"))

                   if nm == 0 then
                    ent.Position = Game():GetRoom():GetCenterPos()
                    ent:GetSprite():Play("TeleportDown",true)
                end
            end
        end

        if ent.HitPoints / ent.MaxHitPoints > 0.66 then
            if not ent:GetSprite():IsPlaying(get_idle_name()) then spd = 1.0 end
            if data.laser_cool > 0 then spd = 0 data.laser_cool = data.laser_cool - 1 end
            ent.Position = (ent.Position*60 + (ent.Position+Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)) * 60 + Game():GetRoom():GetCenterPos() * 1) / 121.0
            ent.Velocity = ent.Velocity * 0.9
                    
            if ent:GetDropRNG():RandomFloat() < 0.8 and (data.time) % 36 == 0 and ent:GetSprite():IsPlaying(get_idle_name()) and data.laser_cool <= 0 then
                ent:GetSprite():Play(get_atck_name(),true)
                data.attack_type = math.floor(ent:GetDropRNG():RandomFloat() * 4) % 4
                data.attack_count = 0
            end

            if ent:GetSprite():IsPlaying(get_atck_name()) and ent:GetSprite():GetFrame() > 38 and not ent:GetSprite():IsPlaying(get_idle_name()) then
                ent:GetSprite():Play(get_idle_name(),true)
                data.attack_count = 0
            end

            if ent:GetSprite():IsEventTriggered("Fire") then
                data.attack_count = data.attack_count + 1
                if data.attack_type == 0 then
                    for i=0,5 do
                        local spd = 2.0 + data.attack_count * 0.45
                        local ang = (ent.Position - player.Position):GetAngleDegrees() + i * (360 / 5)
                        data:spawn_tear(math.rad(ang),spd,0)
                    end
                elseif data.attack_type == 1 and data.attack_count == 1 then
                    local total = 0
                    for l=0,6 do
                        for i=0,6 do
                            if l == 0 or l == 6 or i == 0 or i == 6 then if ent:GetDropRNG():RandomFloat() < 0.7 and total < 20 then
                                total = total + 1
                                local posx = (Game():GetRoom():GetTopLeftPos().X + 16) + (Game():GetRoom():GetBottomRightPos().X-16) / 7 * i
                                local posy = (Game():GetRoom():GetTopLeftPos().Y+16) + (Game():GetRoom():GetBottomRightPos().Y-128) / 7 * l
                                if i ~= 0 then posx = posx - ent:GetDropRNG():RandomFloat() * 16 end
                                if l ~= 0 then posy = posy - ent:GetDropRNG():RandomFloat() * 16 end
                                local t = Game():Spawn(Isaac.GetEntityTypeByName("Crack The Sky (With Tell)"),Isaac.GetEntityVariantByName("Crack The Sky (With Tell)"),Vector(posx,posy),Vector(0,0),ent,0,ent.InitSeed)
                                t:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            end end
                        end
                    end
                elseif data.attack_type == 2 then
                    local entities = Isaac.GetRoomEntities()
                    local nm = GODMODE.util.count_enemies(nil,Isaac.GetEntityTypeByName("Marshall Pawn"), Isaac.GetEntityVariantByName("Marshall Pawn"))

                    if nm < 4 then
                        local t = Game():Spawn(Isaac.GetEntityTypeByName("Marshall Pawn"),Isaac.GetEntityVariantByName("Marshall Pawn"),ent.Position,Vector(0,0),ent,0,ent.InitSeed)
                        t.HitPoints = t.HitPoints / 2
                        table.insert(data.angels, t)
                    else
                        data.attack_type = 0
                    end
                elseif data.attack_type == 3 and data.attack_count % 2 == 1 then
                    local lx = Game():GetRoom():GetTopLeftPos().X + 26
                    local rx = Game():GetRoom():GetBottomRightPos().X - 26
                    local ty = Game():GetRoom():GetTopLeftPos().Y + 26
                    local by = Game():GetRoom():GetBottomRightPos().Y - 26
                    local hdist = rx - lx
                    local vdist = by - ty
                    for i=0,3 do
                        local wall = i+1
                        local perc = ent:GetDropRNG():RandomFloat()
                        local order_pos = nil

                        if wall == 1 then --top left
                            order_pos = Vector(lx, ty)
                        elseif wall == 2 then --top right
                            order_pos = Vector(rx, ty)                        
                        elseif wall == 3 then --bottom left 
                            order_pos = Vector(lx, by)
                        else--bottom right
                            order_pos = Vector(rx, by)                        
                        end
                        
                        local f = (player.Position) - order_pos
                        f = f:GetAngleDegrees()
                        local b = Game():Spawn(Isaac.GetEntityTypeByName("Holy Order"),Isaac.GetEntityVariantByName("Holy Order"),order_pos,Vector(0,0),nil,math.floor(f%360),ent.InitSeed)
                        GODMODE.get_ent_data(b).laser_timeout = 20 - ent:GetDropRNG():RandomInt(10)
                    end

                    data.laser_cool = 60
                end                    
            end
        elseif not ent:GetSprite():IsPlaying("Phase2") and not ent:GetSprite():IsPlaying("TeleportLoop") then
            if not ent:GetSprite():IsPlaying(get_idle_name()) then spd = 1.5 else spd = 2.4 end
            if data.laser_cool > 0 then spd = 0 data.laser_cool = data.laser_cool - 1 end
            ent.Position = (ent.Position*60 + (ent.Position+Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)) * 60 + Game():GetRoom():GetCenterPos() * 3) / 123.0
            ent.Velocity = ent.Velocity * 0.9

            if ent:GetDropRNG():RandomFloat() < 0.8 and (data.time) % 36 == 0 and ent:GetSprite():IsPlaying(get_idle_name()) and data.laser_cool <= 0 then
                ent:GetSprite():Play(get_atck_name(),true)
                data.attack_count = 0
                data.attack_type = math.floor(ent:GetDropRNG():RandomFloat() * 4) % 4
            end

            if ent:GetSprite():IsPlaying(get_atck_name()) and ent:GetSprite():GetFrame() > 38 and not ent:GetSprite():IsPlaying(get_idle_name()) then
                ent:GetSprite():Play(get_idle_name(),true)
            end

            if ent:GetSprite():IsEventTriggered("Fire") then
                if data.attack_type == 0 then
                    local co = 2 + data.attack_count
                    if ent.HitPoints / ent.MaxHitPoints <= 0.33 then co = co + data.attack_count end

                    for i=0,co do
                        local spd = 2.5 + 2^data.attack_count / 14
                        local ang = (ent.Position - player.Position):GetAngleDegrees() + i * (360 / co)
                        data:spawn_tear(math.rad(ang),spd,0)
                    end
                elseif data.attack_type == 1 then
                    local total = 0
                    local total = 0
                    for l=0,6 do
                        for i=0,6 do
                            if l <= 2 or l >= 4 or i <= 2 or i >= 4 then if ent:GetDropRNG():RandomFloat() < 0.5 and total < 40 then
                                total = total + 1
                                local posx = (Game():GetRoom():GetTopLeftPos().X + 16) + (Game():GetRoom():GetBottomRightPos().X-16) / 7 * i
                                local posy = (Game():GetRoom():GetTopLeftPos().Y+16) + (Game():GetRoom():GetBottomRightPos().Y-128) / 7 * l
                                if i ~= 0 then posx = posx - ent:GetDropRNG():RandomFloat() * 16 end
                                if l ~= 0 then posy = posy - ent:GetDropRNG():RandomFloat() * 16 end
                                local t = Game():Spawn(Isaac.GetEntityTypeByName("Crack The Sky (With Tell)"),Isaac.GetEntityVariantByName("Crack The Sky (With Tell)"),Vector(posx,posy),Vector(0,0),ent,0,ent.InitSeed)
                                t:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            end end
                        end
                    end
                elseif data.attack_type == 2 then
                    local entities = Isaac.GetRoomEntities()
                    local nm = GODMODE.util.count_enemies(nil,Isaac.GetEntityTypeByName("Marshall Pawn"), Isaac.GetEntityVariantByName("Marshall Pawn"))
                    if data.p3 then nm = nm-1 end

                    if nm <= 5 then
                        local t = Game():Spawn(Isaac.GetEntityTypeByName("Marshall Pawn"),Isaac.GetEntityVariantByName("Marshall Pawn"),ent.Position,Vector(0,0),ent,0,ent.InitSeed)
                        table.insert(data.angels, t)
                    else
                        data.attack_type = 0
                    end
                elseif data.attack_type == 3 then
                    local mp = 2
                    if data.p3 then mp = 4 end

                    local lx = Game():GetRoom():GetTopLeftPos().X + 26
                    local rx = Game():GetRoom():GetBottomRightPos().X - 26
                    local ty = Game():GetRoom():GetTopLeftPos().Y + 26
                    local by = Game():GetRoom():GetBottomRightPos().Y - 26
                    local hdist = rx - lx
                    local vdist = by - ty
            
                    for l=0,mp do
                        local wall = ent:GetDropRNG():RandomInt(5)
                        local perc = ent:GetDropRNG():RandomFloat()
                        local order_pos = nil

                        if wall == 1 then --top left
                            order_pos = Vector(lx, ty)
                        elseif wall == 2 then --top right
                            order_pos = Vector(rx, ty)                        
                        elseif wall == 3 then --bottom left 
                            order_pos = Vector(lx, by)
                        else--bottom right
                            order_pos = Vector(rx, by)                        
                        end
                        
                        local f = (player.Position) - order_pos
                        f = f:GetAngleDegrees()
                        local b = Game():Spawn(Isaac.GetEntityTypeByName("Holy Order"),Isaac.GetEntityVariantByName("Holy Order"),order_pos,Vector(0,0),nil,math.floor(f%360),ent.InitSeed)
                        GODMODE.get_ent_data(b).laser_timeout = 20 - ent:GetDropRNG():RandomInt(5)
                    end
                    data.laser_cool = 60
                end                    
                data.attack_count = data.attack_count + 1
            end
        end
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if (enthit.Type == monster.type and enthit.Variant == monster.variant) and (enthit:GetSprite():IsPlaying("TeleportLoop") or
        flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER and entsrc.Type ~= 1) then
        return false
    end
end

return monster