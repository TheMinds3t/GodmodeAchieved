local monster = {}
-- monster.data gets updated every callback
monster.name = "It Breathes!"
monster.type = 800
monster.variant = 128
--monster.subtype = 0 --deobfuscated
--monster.subtype_sensitive = false --deobfuscated
monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        ent.HitPoints = ent.HitPoints + (GODMODE:getBasicDPS() / 10.0) * 1500
        ent.MaxHitPoints = ent.HitPoints
    end
end
monster.postUpdate = function(self)
end
monster.npcUpdate = function(self, ent)
    local data = self.data
    local player = Isaac.GetPlayer(0)
    if data.minions == nil then
        ent:GetSprite():Play("Idle",true)
        data.abs_pos = ent.Position
        data.tears = {}
        data.minions = 9
        data.max_minions = 10
        local guts = Isaac.Spawn(78, 10, 0, ent.Position, Vector(0,0), ent)
        guts.Parent = ent
        guts:GetSprite():Play("Heartbeat2", true)
        data.gut = guts
        data.spawn_tear = function(self, ang, speed, curve)
            if curve == nil then curve = 0 end
            local vel = Vector(math.cos(ang) * speed,math.sin(ang) * speed)
            local offset = ent:GetDropRNG():RandomFloat() * 6.28
            local off = Vector(math.cos(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7),math.sin(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7))
            local tear = GODMODE.game:Spawn(EntityType.ENTITY_PROJECTILE,0,ent.Position + vel,vel,ent,0,ent.InitSeed)
            tear = tear:ToProjectile()
            tear.FallingSpeed = 0.0
            tear.FallingAccel = -(6/60.0)
            if ent:GetSprite():IsPlaying("Attack2") then
                off = off * 0.125 + Vector(-80,32)
                tear.Position = tear.Position + off
            end
            table.insert(data.tears, tear)
        end
    end

    ent.Position = data.abs_pos
    ent.Velocity = Vector(0,0)
	
    local f = ent.HitPoints / ent.MaxHitPoints
    if data.minions / data.max_minions > f then
        data.minions = data.minions - 1
        GODMODE.game:Spawn(38,0,ent.Position,Vector(ent:GetDropRNG():RandomFloat()*4-2,ent:GetDropRNG():RandomFloat()*4-2),ent,800,ent.InitSeed)
    end

    if ent:GetSprite():IsPlaying("Idle") and ent.HitPoints / ent.MaxHitPoints < 0.5 then
        ent:GetSprite():Play("Idle2", true)
    end


    if data.is_dead then
        ent:GetSprite():Play("BossDeath",false)
    end


    if ent:GetSprite():IsEventTriggered("Finale") then
        for i=0,11 do
            GODMODE.game:Spawn(38,0,ent.Position,Vector(ent:GetDropRNG():RandomFloat()*50-25,ent:GetDropRNG():RandomFloat()*50-252),ent,800,ent.InitSeed)
        end
        ent:Kill()
        GODMODE.game:ShakeScreen(20)
        GODMODE.room:EmitBloodFromWalls(5,60)
    end

    if ent:GetSprite():IsEventTriggered("Pump") then
        GODMODE.game:ShakeScreen(5)
        local ring = 3
        local ang_off = (data.time * 12) % 360
        for i=1,ring do
            local spd = 5.0
            if ent:GetSprite():IsPlaying("BossDeath") then spd = 6.0 ang_off = (data.time * 2.2) % 360 end
            local r_ang = math.rad(ang_off + (360 / ring) * i)
            local vel = Vector(math.cos(r_ang) * spd,math.sin(r_ang) * spd)
            data:spawn_tear(r_ang, spd, 0)
        end
    end

    if (ent:GetSprite():IsPlaying("BossDeath") and data.time % 3 == 0) then
        GODMODE.game:ShakeScreen(2)
        local ring = 3
        for i=1,ring do
            local spd = 8.0
            local vel = Vector(math.cos(ent:GetDropRNG():RandomFloat()*6.28) * spd,math.sin(ent:GetDropRNG():RandomFloat()*6.28) * spd)
            local params = ProjectileParams()
            local ang = math.rad(data.time * 5 + i * 120)
            local t = GODMODE.game:Spawn(EntityType.ENTITY_PROJECTILE,0,Vector(ent.Position.X+math.cos(ang)*spd,ent.Position.Y+math.sin(ang)*spd),Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent,0,Isaac.GetPlayer(0).InitSeed)
            t = t:ToProjectile()
            t.Height = t.Height * 2.25
        end
    end

    if ent:GetSprite():IsEventTriggered("Fire") then
        local ring = 6
        local ang_off = ent:GetDropRNG():RandomFloat() * 360
        for i=1,ring do
            local r_ang = math.rad(ang_off + (360 / ring) * i)
            local spd = 7
            local vel = Vector(math.cos(r_ang) * spd,math.sin(r_ang) * spd)
            data:spawn_tear(r_ang, spd, 0)
        end
    end

    if ent:GetSprite():IsPlaying("Idle") then
        if ent:GetSprite():GetFrame() == 23 then
            if ent:GetDropRNG():RandomFloat() <= 0.8 then
                if ent:GetSprite():IsPlaying("Idle") then
                    ent:GetSprite():Play("Attack", true)
                else
                    ent:GetSprite():Play("Attack2", true)
                end
            end
        end
    end

    if ent:GetSprite():IsPlaying("Idle2") then
        if ent:GetSprite():GetFrame() == 23 then
            if ent:GetDropRNG():RandomFloat() <= 0.8 then
                if ent:GetSprite():IsPlaying("Idle") then
                    ent:GetSprite():Play("Attack", true)
                else
                    ent:GetSprite():Play("Attack2", true)
                end
            end
        end
    end

    if ent:GetSprite():IsPlaying("Attack") then
        GODMODE.room:EmitBloodFromWalls(2,1)
        GODMODE.game:ShakeScreen(2)

        if ent:GetSprite():GetFrame() == 23 then
            if ent:GetSprite():IsPlaying("Attack") then
                ent:GetSprite():Play("Idle", true)
            else
                ent:GetSprite():Play("Idle2", true)
            end
        end
    end

    if ent:GetSprite():IsPlaying("Attack2") then
        GODMODE.room:EmitBloodFromWalls(1,1)
        GODMODE.game:ShakeScreen(1)

        if ent:GetSprite():GetFrame() == 42 then
            if ent:GetSprite():IsPlaying("Attack") then
                ent:GetSprite():Play("Idle", true)
            else
                ent:GetSprite():Play("Idle2", true)
            end
        end
    end

    for i=1,#data.tears do
        data.tears[i].Velocity = data.tears[i].Velocity * (1.0125 + math.cos(data.time * 9 + data.rand) * 0.1)
    end
end
monster.postRender = function(self)
end
monster.entityDamaged = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit.Type == nerve_cluster_ent and enthit.Variant == 128 and enthit.HitPoints - dmg_amount * 2 < 0 then
        self.data.is_dead = true
        enthit.HitPoints = 1
        return false
    end
end
monster.postRoomCleared = function(self)
end
monster.newRoom = function(self)
end
monster.newLevel = function(self)
end
return monster