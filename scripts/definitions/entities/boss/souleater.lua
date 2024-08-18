local monster = {}
monster.name = "Souleater"
monster.type = GODMODE.registry.entities.souleater.type
monster.variant = GODMODE.registry.entities.souleater.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        if not data.hitpoint_buff then
            local bonus = math.min((GODMODE.util.get_basic_dps(ent) / 10.0) * 100, 1000)
            ent.MaxHitPoints = ent.MaxHitPoints + bonus
            ent.HitPoints = ent.MaxHitPoints
            data.hitpoint_buff = true
        end
    end
end

monster.set_delirium_visuals = function(self,ent)
    for i=0,4 do 
        ent:GetSprite():ReplaceSpritesheet(i,"gfx/bosses/deliriumforms/souleater2.png")
    end
    ent:GetSprite():LoadGraphics()
end

local atks = {"BrimFire","Charge","FlameAttack"}
monster.choose_atk = function(ent,data)
    local last = data.last_atk or "Idle"
    local atk = atks[ent:GetDropRNG():RandomInt(#atks)+1]

    while atk == last do 
        atk = atks[ent:GetDropRNG():RandomInt(#atks)+1]
    end

    return atk
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()

    if data.tell == nil then
        sprite:Play("Idle",true)
        data.firelooptime = -1
        data.tell = 0
    end

    if ent.HitPoints / ent.MaxHitPoints <= 0.4 and not data.p2 then
        if not GODMODE.util.is_delirium() then 
            sprite:Play("BodyDeath",true)
        else
            ent:BloodExplode()
        end

        data.p2 = true
    end

    local ti = player.Position
    local spd = 1/40
    
    if not sprite:IsPlaying("Idle") then spd = 1/40 end
    if sprite:IsPlaying("BrimFire") or sprite:IsPlaying("FireLoop") 
        or sprite:IsPlaying("BodyDeath") then spd = 1/100 end
    if data.p3 == true then spd = 1/50 end
    local targ = (ti * 2 + GODMODE.room:GetCenterPos() * 1) / 3

    if sprite:IsPlaying("HeadIdleRage") then
        targ = (ti + GODMODE.room:GetCenterPos() * 5) / 6
    end

    ent.Velocity = ent.Velocity * 0.9 + (targ - ent.Position):Resized(spd)

    if sprite:IsPlaying("Idle") and ent:IsFrame(30,1) and ent:GetDropRNG():RandomFloat() < ent.I1 * 0.2 then
        local atk = monster.choose_atk(ent,data)

        if atk == "FlameAttack" then
            ent.I1 = -6
        end

        sprite:Play(atk,true)
        data.last_atk = atk
        ent.I1 = math.min(ent.I1,0)
    elseif sprite:IsFinished("Idle") then 
        sprite:Play("Idle",true)
        ent.I1 = ent.I1 + 1
    end

    if data.firelooptime > 0 then
        data.firelooptime = data.firelooptime - 1 
    elseif sprite:IsPlaying("FireLoop") then
        sprite:Play("LeaveCharge",true)
    end

    if sprite:IsEventTriggered("Switch") then
        if sprite:IsPlaying("Charge") then
            sprite:Play("FireLoop",true)
            data.firelooptime = 120
        end

        if sprite:IsPlaying("LeaveCharge") or sprite:IsPlaying("BrimFire") or sprite:IsPlaying("FlameAttack") then
            sprite:Play("Idle",true)
        end

        if sprite:IsPlaying("BodyDeath") and not GODMODE.util.is_delirium() then
            local offsets = {Vector(96,-64),Vector(-96,-64),Vector(0,96)}

            for i,offset in ipairs(offsets) do
                local knight = Isaac.Spawn(GODMODE.registry.entities.furnace_knight_boss.type,GODMODE.registry.entities.furnace_knight_boss.variant, GODMODE.registry.entities.furnace_knight_boss.subtype, ent.Position+offset,Vector(0,0),ent) 
            end
        end
    end

    if data.p2 ~= nil and not sprite:IsPlaying("BodyDeath") then
        if (data.guard_check_timer or 0) % 20 == 0 then
            data.guards = GODMODE.util.count_enemies(nil, GODMODE.registry.entities.furnace_knight_boss.type, GODMODE.registry.entities.furnace_knight_boss.variant, GODMODE.registry.entities.furnace_knight_boss.subtype)
        end

        data.guard_check_timer = (data.guard_check_timer or 0) + 1

        if data.guards > 0 then
            sprite:Play("HeadIdle", false)
        else
            if data.head_bled ~= true then 
                ent:BloodExplode()
                ent:BloodExplode()
                ent:BloodExplode()
                data.head_bled = true
            end
            
            if ent.HitPoints / ent.MaxHitPoints <= 0.125 then
                if data.head_bled_2 ~= true then 
                    ent:BloodExplode()
                    ent:BloodExplode()
                    ent:BloodExplode()
                    data.head_bled_2 = true
                end
    
                sprite:Play("HeadIdleRage", false)

                if GODMODE.util.is_delirium() then 
                    sprite.PlaybackSpeed = 0.5
                end
            else
                sprite:Play("HeadIdleVulnerable", false)
                if GODMODE.util.is_delirium() then 
                    sprite.PlaybackSpeed = 0.75
                end
            end
        end
    end

    if sprite:IsEventTriggered("Tell") then
        if sprite:IsPlaying("BrimFire") then 
            data.tell = ent:GetDropRNG():RandomFloat() * 360
            local dist = 16
            for i=0,7 do
                local ang = data.tell + i * (360 / 8)
                local f = math.rad(ang)
                local offset = Vector(math.cos(f)*dist,math.sin(f)*dist)
                local tell = Isaac.Spawn(GODMODE.registry.entities.unholy_order.type,GODMODE.registry.entities.unholy_order.variant,math.floor(ang),ent.Position+offset,Vector.Zero,ent)
                local tell_data = GODMODE.get_ent_data(tell)
                tell_data.laser_timeout = 45
            end    
        elseif sprite:IsPlaying("FlameAttack") then 

        end
    end

    if sprite:IsEventTriggered("Fire") and sprite:IsPlaying("FlameAttack") then 
        local cnt = 6
        local layers = 8
        local min_speed = 0.5
        local max_speed = 2.5
        local spread = 360/cnt/layers*3

        for l=0,layers do 
            for i=0,cnt do 
                local speed = min_speed + (max_speed - min_speed)*((l+1)/cnt)
                local vel = Vector(1,0):Rotated(360/cnt*i+spread*l):Resized(speed)
                local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_FIRE,0,ent.Position,vel,ent)
                proj = proj:ToProjectile()
                proj:AddProjectileFlags(ProjectileFlags.ACCELERATE)
                proj.SpriteOffset = Vector(0,-proj.Height-4)

                if not GODMODE.util.is_delirium() then 
                    proj.FallingAccel = -(6/60.0)
                else
                    proj.FallingAccel = -(5.7/60.0)
                end
            end
        end
    end

    if sprite:IsEventTriggered("Fire2") and sprite:IsPlaying("BrimFire") then 
        local dir = (ti - ent.Position)
        local cnt = 5
        local spread = 360
        local off = ent:GetDropRNG():RandomFloat()*(spread/cnt+1)*2

        for i=0,cnt do 
            local speed = 3
            local vel = Vector(1,0):Rotated(dir:GetAngleDegrees()+spread/2-i*spread/(cnt+1)+off):Resized(speed)
            local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_NORMAL,0,ent.Position,vel,ent)
            proj = proj:ToProjectile()
            proj:AddProjectileFlags(ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.WIGGLE)
            proj:AddChangeFlags(ProjectileFlags.ACCELERATE | ProjectileFlags.WIGGLE)
            proj.Parent = ent
            proj.ChangeTimeout = 40

            if not GODMODE.util.is_delirium() then 
                proj.FallingAccel = -(6/60.0)
            else
                proj.FallingAccel = -(5.7/60.0)
            end
        end
    end

    if (sprite:IsPlaying("HeadIdle") or sprite:IsPlaying("HeadIdleRage") or sprite:IsPlaying("HeadIdleVulnerable")) and sprite:IsEventTriggered("Fire") 
        or data.p3 ~= true and (sprite:IsEventTriggered("Fire") and sprite:IsPlaying("FireLoop")) then

        local total = 3
        local sped = 2.95
        local of = 45

        if data.guards == 0 and data.p2 ~= nil then
            total = 6
            sped = 2.25
            of = 44
            data.p3 = true

            if sprite:IsPlaying("HeadIdleRage") then
                sped = 2.0
            end
        end

        local phase3 = 1
        if data.p3 == true then
            phase3 = 0
            total = 12
        end
        
        local tear_move_scale = {1.0,0.8}
        for l=0,phase3 do
            for i=0,total-1 do
                local spd = sped - l * (sped * 0.375)
                local off = (data.firelooptime * 4) % 360
                if sprite:IsPlaying("HeadIdle") or sprite:IsPlaying("HeadIdleVulnerable") 
                    or sprite:IsPlaying("BrimFire") then off = (data.time * 6) % 360 end
                local ang = off + i * (360 / total) + l * of
                if data.p3 == true then
                    ang = data.time * 4 + i * (360 / total) + l * 45
                    if i % 2 == 0 then
                        spd = spd * 0.8
                    end
                end

                local f = math.rad(ang)
                ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
                local t = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position + ang,ang*spd*Vector(tear_move_scale[1],tear_move_scale[2]),ent)
                t = t:ToProjectile()
                t.Height = t.Height * (1.5)
                t.FallingSpeed = t.FallingSpeed * 0.0001
                t.FallingAccel = -(5/60.0)
                
                if data.p3 == true then
                    t.FallingAccel = 0.0
                    t.FallingSpeed = 0.0
                end

                t.Scale = 1.0 + spd / 5.0

                if l == 0 and data.p3 ~= true or data.p3 == true and i % 2 == 1 then
                    t.FallingSpeed = 0.0
                    if not GODMODE.util.is_delirium() then 
                        t.FallingAccel = -(6/60.0)
                    else
                        t.FallingAccel = -(5.5/60.0)
                    end
                else
                    t.Color = Color(1.0,1.0,1.0,1.0,150/255,0,0)
                    t:AddProjectileFlags(ProjectileFlags.ACCELERATE)
                end
            end
        end
    end

    if sprite:IsEventTriggered("DeathExplode") then ent:BloodExplode() end
end

monster.npc_remove = function(self, ent)
    if ent:IsDead() and ent.Type == monster.type and ent.Variant == monster.variant then 
        GODMODE.room:MamaMegaExplosion(ent.Position)
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)

    local data = GODMODE.get_ent_data(enthit)
    if (enthit.Type == monster.type and enthit.Variant == monster.variant) and 
        ((data.guards or 0) > 0 or enthit:GetSprite():IsPlaying("BodyDeath") or
        flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER and entsrc.Type ~= 1) then 
        return false 
    end
end

return monster