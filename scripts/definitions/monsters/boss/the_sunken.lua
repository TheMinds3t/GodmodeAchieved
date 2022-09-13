local monster = {}
-- monster.data gets updated every callback
monster.name = "The Sunken"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
monster.subtype = 0
monster.postUpdate = function(self)
end
monster.npcUpdate = function(self, ent)
	local data = monster.data
    local player = Isaac.GetPlayer(0)
    if data.brims == nil then
        ent:GetSprite():Play("Idle", false)
        data.brims = {}
    end
    if data.init ~= true then
        ent:GetSprite():Play("Idle", false)
        data.init = true
    end

    if ent:GetSprite():IsFinished("Appear") then
        ent:GetSprite():Play("Idle", false)
    end
    if data.rand == nil then data.rand = ent:GetDropRNG():RandomFloat() * 999999 end
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
    local f = Vector(math.cos(data.time / 15 + ent.Index * 120 + data.rand)*160+math.cos(data.time / 10 + ent.Index * 100 + data.rand)*48,math.sin(data.time / 45 + ent.Index * 120 + data.rand)*160+math.sin(data.time / 25 + ent.Index * 100 + data.rand)*48)
    f = f / 24
    local mspeed = 0.25
    if data.P3 ~= nil then f = f * 8 end
    if data.Prime ~= nil then f = f * 6 end
    if ent:GetSprite():IsPlaying("BrimFire") then ent.Velocity = Vector(0,0) mspeed = mspeed / 5 end
    local t = Game():GetRoom():GetCenterPos() - ent.Position + f
    ent.Velocity = ent.Velocity +  t * mspeed / 100
    ent.Position = ent.Position + t * mspeed

    if ent:GetDropRNG():RandomFloat() < 0.75 and data.time % 65 == 60 and ent:GetSprite():IsPlaying("Idle") and not ent:GetSprite():IsPlaying("Split") then
        if ent:GetDropRNG():RandomFloat() < 0.6 then ent:GetSprite():Play("Fire", true) else ent:GetSprite():Play("BrimFire", true) end
    end

    if ent:GetSprite():IsEventTriggered("Exit") and not ent:GetSprite():IsPlaying("Split") then--data.time % 30 == 0 or data.time % 30 == 15 then            
        ent:GetSprite():Play("Idle", true)
    end
    local hs = ent.HitPoints / ent.MaxHitPoints
    if data.P3 ~= nil and data.Prime == nil then ent.Scale = 0.7 elseif data.Prime ~= nil then ent.Scale = 0.85 end

    if ent:GetSprite():IsEventTriggered("Fire") and ent:GetSprite():IsPlaying("Fire") then--data.time % 30 == 0 or data.time % 30 == 15 then
        local num = 1
        local num2 = 4
        if hs < 0.6 and data.P3 ~= nil then num = 0 num2 = 2 end
        if hs < 0.6 and data.P3 ~= nil and data.Prime ~= nil then num2 = 4 end
        for l=0,num do
            local sped = 2.45 + l * 0.65

            for i=0,num2 do
                local spd = sped - (math.abs(i - 2) / 10)
                local ang = player.Position - ent.Position
                local f = math.rad(ang:GetAngleDegrees() - math.floor(num2 / 2) * 20 + i * 20 + 7)
                ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
                local t = Game():Spawn(EntityType.ENTITY_PROJECTILE,0,ent.Position + ang,ang*spd,ent,0,ent.InitSeed)
            end
        end
    end

    if hs < 0.6 and data.Prime == nil and data.P3 == nil and not ent:GetSprite():IsPlaying("Split") then
        ent:GetSprite():Play("Split", true)
    end

    if hs < 0.3 and data.Prime ~= nil and not ent:GetSprite():IsPlaying("Split") then
        ent:GetSprite():Play("Split", true)
    end

    if ent:GetSprite():IsEventTriggered("Split") and ent:GetSprite():IsPlaying("Split") then

        if data.Prime == nil then
            local sml = Game():Spawn(monster.type,100,ent.Position,Vector(0,0),ent,0,ent.InitSeed)
            getEntData(sml).P3 = true
            sml.HitPoints = ent.MaxHitPoints * 0.3
            local prm = Game():Spawn(monster.type,100,ent.Position,Vector(0,0),ent,0,ent.InitSeed)
            getEntData(prm).Prime = true
            prm.HitPoints = ent.MaxHitPoints * 0.6
            getEntData(prm).brims = {}
            getEntData(prm).time = 0
            getEntData(sml).brims = {}
            getEntData(sml).time = 0
            ent:Kill()
        else
            local sml = Game():Spawn(monster.type,100,ent.Position,Vector(0,0),ent,0,ent.InitSeed)
            getEntData(sml).P3 = true
            sml.HitPoints = ent.MaxHitPoints * 0.3
            local prm = Game():Spawn(monster.type,100,ent.Position,Vector(0,0),ent,0,ent.InitSeed)
            getEntData(prm).P3 = true
            prm.HitPoints = ent.MaxHitPoints * 0.3
            getEntData(prm).brims = {}
            getEntData(prm).time = 0
            getEntData(sml).brims = {}
            getEntData(sml).time = 0
        end

        ent:Kill()
    end

    if data.Prime ~= nil then
        ent.SpriteScale = Vector(0.6,0.6)
    elseif data.P3 ~= nil then
        ent.SpriteScale = Vector(0.325,0.325)
    end

    if ent:GetSprite():IsEventTriggered("Fire") and ent:GetSprite():IsPlaying("BrimFire") then--data.time % 30 == 0 or data.time % 30 == 15 then
        local num = 7
        if data.Prime ~= nil then num = 4 end
        if data.P3 then num = 4 end
        for i=0,num do
            local spd = 3.0
            local f = math.rad(i * (360 / 5) + ent:GetDropRNG():RandomFloat() * (360 / 5))
            local ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
            data.brims[i] = f
            local t = Game():Spawn(EntityType.ENTITY_PROJECTILE,0,ent.Position + ang,ang*spd,ent,0,ent.InitSeed)
        end
    end

    if ent:GetSprite():IsEventTriggered("BrimFire") then--data.time % 30 == 0 or data.time % 30 == 15 then
        for i=0,#data.brims do
            local spd = 5.0
            local ang = data.brims[i]
            EntityLaser.ShootAngle(1,ent.Position,math.deg(ang),35,Vector(0,0),ent)
        end
        data.brims = {}
    end
end
monster.postRender = function(self)
end
monster.entityDamaged = function(self,enthit,amount,flags,entsrc,countdown)
end
monster.postRoomCleared = function(self)
end
monster.newRoom = function(self)
end
monster.newLevel = function(self)
end
return monster