local monster = {}
monster.name = "Souleater"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, params)
    local ent = params[1]
    local data = params[2]

    if not data.hitpoint_buff then
        local bonus = math.min((GODMODE.util.get_basic_dps(ent) / 10.0) * 100, 1000)
        ent.MaxHitPoints = ent.MaxHitPoints + bonus
        ent.HitPoints = ent.MaxHitPoints
        data.hitpoint_buff = true
    end
end
monster.set_delirium_visuals = function(self,ent)
    for i=0,4 do 
        ent:GetSprite():ReplaceSpritesheet(i,"gfx/bosses/deliriumforms/souleater2.png")
    end
    ent:GetSprite():LoadGraphics()
end
monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()

    if data.tell == nil then
        ent:GetSprite():Play("Idle",true)
        data.firelooptime = -1
        data.tell = 0
    end

    if ent.HitPoints / ent.MaxHitPoints <= 0.4 and not data.p2 then
        if not GODMODE.util.is_delirium() then 
            ent:GetSprite():Play("BodyDeath",true)
        else
            ent:BloodExplode()
        end

        data.p2 = true
    end

    local ti = player.Position - ent.Position
    local spd = 2.35
    
    if not ent:GetSprite():IsPlaying("Idle") then spd = 1.5 end
    if ent:GetSprite():IsPlaying("BrimFire") or ent:GetSprite():IsPlaying("FireLoop") 
        or ent:GetSprite():IsPlaying("BodyDeath") then spd = 0.1 end
    if data.p3 == true then spd = 2.0 end
    
    ent.Position = (ent.Position*60 + (ent.Position+Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)) * 60 + Game():GetRoom():GetCenterPos() * 1) / 121.0

    if ent:GetSprite():IsPlaying("HeadIdleRage") then
        ent.Position = (ent.Position*60 + (ent.Position+Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)) * 60 + Game():GetRoom():GetCenterPos() * 5) / 125.0
    end

    ent.Velocity = ent.Velocity * 0.9

    if ent:GetSprite():IsPlaying("Idle") and data.time % 30 == 0 and ent:GetDropRNG():RandomFloat() < 0.9 then
        if ent:GetDropRNG():RandomFloat() < 0.5 then
            ent:GetSprite():Play("Charge",true)
        else
            ent:GetSprite():Play("BrimFire",true)
        end
    end

    if data.firelooptime > 0 then
        data.firelooptime = data.firelooptime - 1 
    elseif ent:GetSprite():IsPlaying("FireLoop") then
        ent:GetSprite():Play("LeaveCharge",true)
    end

    if ent:GetSprite():IsEventTriggered("Switch") then
        if ent:GetSprite():IsPlaying("Charge") then
            ent:GetSprite():Play("FireLoop",true)
            data.firelooptime = 120
        end
        if ent:GetSprite():IsPlaying("LeaveCharge") then
            ent:GetSprite():Play("Idle",true)
        end
        if ent:GetSprite():IsPlaying("BrimFire") then
            ent:GetSprite():Play("Idle",true)
        end
        if ent:GetSprite():IsPlaying("BodyDeath") and not GODMODE.util.is_delirium() then
            local offsets = {Vector(96,-64),Vector(-96,-64),Vector(0,96)}

            for i,offset in ipairs(offsets) do
                local knight = Isaac.Spawn(Isaac.GetEntityTypeByName("Furnace Knight (Boss)"),Isaac.GetEntityVariantByName("Furnace Knight (Boss)"),2, ent.Position+offset,Vector(0,0),ent) 
                --knight.IsBoss = function(self) return true end
            end
        end
    end

    if data.p2 ~= nil and not ent:GetSprite():IsPlaying("BodyDeath") then
        if (data.guard_check_timer or 0) % 20 == 0 then
            data.guards = GODMODE.util.count_enemies(nil, Isaac.GetEntityTypeByName("Furnace Knight (Boss)"), Isaac.GetEntityVariantByName("Furnace Knight (Boss)"), 2)
        end

        data.guard_check_timer = (data.guard_check_timer or 0) + 1

        if data.guards > 0 then
            ent:GetSprite():Play("HeadIdle", false)
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
    
                ent:GetSprite():Play("HeadIdleRage", false)

                if GODMODE.util.is_delirium() then 
                    ent:GetSprite().PlaybackSpeed = 0.5
                end
            else
                ent:GetSprite():Play("HeadIdleVulnerable", false)
                if GODMODE.util.is_delirium() then 
                    ent:GetSprite().PlaybackSpeed = 0.75
                end
            end
        end
    end

    if ent:GetSprite():IsEventTriggered("Tell") and ent:GetSprite():IsPlaying("BrimFire") then
        data.tell = ent:GetDropRNG():RandomFloat() * 360
        local dist = 16
        for i=0,7 do
            local ang = data.tell + i * (360 / 8)
            local f = math.rad(ang)
            local offset = Vector(math.cos(f)*dist,math.sin(f)*dist)
            local tell = Game():Spawn(Isaac.GetEntityTypeByName("Unholy Order"),Isaac.GetEntityVariantByName("Unholy Order"),ent.Position+offset,Vector.Zero,ent,math.floor(ang),ent.InitSeed)
            local tell_data = GODMODE.get_ent_data(tell)
            tell_data.laser_timeout = 45
        end
    end

    if (ent:GetSprite():IsPlaying("HeadIdle") or ent:GetSprite():IsPlaying("HeadIdleRage") or ent:GetSprite():IsPlaying("HeadIdleVulnerable")) and ent:GetSprite():IsEventTriggered("Fire") 
        or data.p3 ~= true and (ent:GetSprite():IsEventTriggered("Fire") and ent:GetSprite():IsPlaying("FireLoop") 
        or ent:GetSprite():IsEventTriggered("Fire2") and ent:GetSprite():IsPlaying("BrimFire")) then

        local total = 4
        local sped = 2.95
        local of = 45

        if data.guards == 0 and data.p2 ~= nil then
            total = 6
            sped = 2.25
            of = 44
            data.p3 = true

            if ent:GetSprite():IsPlaying("HeadIdleRage") then
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
                if ent:GetSprite():IsPlaying("HeadIdle") or ent:GetSprite():IsPlaying("HeadIdleVulnerable") 
                    or ent:GetSprite():IsPlaying("BrimFire") then off = (data.time * 6) % 360 end
                local ang = off + i * (360 / total) + l * of
                if data.p3 == true then
                    ang = data.time * 4 + i * (360 / total) + l * 45
                    if i % 2 == 0 then
                        spd = spd * 0.8
                    end
                end

                local f = math.rad(ang)
                ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
                local t = Game():Spawn(EntityType.ENTITY_PROJECTILE,0,ent.Position + ang,ang*spd*Vector(tear_move_scale[1],tear_move_scale[2]),ent,0,ent.InitSeed)
                t = t:ToProjectile()
                t.Height = t.Height * (1.5 + l)
                t.FallingSpeed = t.FallingSpeed * 0.0001
                t.FallingAccel = t.FallingAccel * 0.001
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
                end
            end
        end
    end

    if ent:GetSprite():IsEventTriggered("DeathExplode") then ent:BloodExplode() end
end

monster.npc_remove = function(self, ent)
    if ent:IsDead() and ent.Type == monster.type and ent.Variant == monster.variant then 
        Game():GetRoom():MamaMegaExplosion(ent.Position)
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