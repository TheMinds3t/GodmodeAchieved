local monster = {}
-- monster.data gets updated every callback
monster.name = "[GODMODE] Blind Spider"
monster.type = GODMODE.registry.entities.blind_spider.type
monster.variant = GODMODE.registry.entities.blind_spider.variant

monster.spawn_tear = function(self, ent, ang, speed, curve)
    if curve == nil then curve = 0 end
    local vel = Vector(math.cos(ang) * speed,math.sin(ang) * speed)
    local offset = ent:GetDropRNG():RandomFloat() * 6.28
    local off = Vector(math.cos(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7),math.sin(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7))
    local params = ProjectileParams()
    params.HeightModifier = -1.5
    params.Scale = 1.0
    params.CurvingStrength = curve

    local tear = ent:FireBossProjectiles(1, ent.Position + off*(0.9+ent:GetDropRNG():RandomFloat()*0.2), speed, params)
    tear.Height = tear.Height - 20
    --tear.Position = tear.Position + off
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()
    if not data.anim then
        sprite:Play("Idle",true)
        data.anim = true
    end

    local ti = player.Position - ent.Position
    local spd = 2.125
    if ent.SubType == 1 then spd = 3 end
    if sprite:IsPlaying("TeleportIn") or sprite:IsPlaying("TeleportOut") then spd = 0 end
    ent.Position = ent.Position + Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)
    ent.Velocity = ent.Velocity * 0.5
    if sprite:IsFinished("Fire") then
        sprite:Play("Idle",true)
    end

    if data.time % 50 == 0 then
        if ent:GetDropRNG():RandomFloat() < 0.25 then
            sprite:Play("TeleportOut",true)
        else
            sprite:Play("Fire",true)
        end
    end

    if sprite:IsEventTriggered("Teleport") then
        if sprite:IsPlaying("TeleportIn") then
            sprite:Play("Idle", true)
        else
            local v = player.Position
            local ang = math.rad(ent:GetDropRNG():RandomFloat() * 360)
            v = v + Vector(math.cos(ang) * 192,math.sin(ang) * 192)
            ent.Position = v
            sprite:Play("TeleportIn",true)
            ent.Velocity = Vector(0,0)
        end
    end

    if sprite:IsEventTriggered("Fire") then
        local fright_flag = ent.SubType == 1
        if fright_flag then
            local dir = player.Position - ent.Position 
            for i=0,2 do
                local spd = 0.5 + ent:GetDropRNG():RandomFloat()
                local f = math.rad(dir:GetAngleDegrees() + ent:GetDropRNG():RandomFloat() * 50-25)
                monster.spawn_tear(self,ent,f,spd,2.5)
            end
        else
            local spd = 6 + (GODMODE.game.Difficulty % 2) * 2.0
            local ang = player.Position - ent.Position
            local f = math.rad(ang:GetAngleDegrees())
            ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
            local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position,ang,ent)
            tear = tear:ToProjectile()
            tear.ChangeVelocity = spd * 0.9
            tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT
            tear.ChangeTimeout = 9
            tear.Height = tear.Height - 10
            tear.FallingAccel = tear.FallingAccel * 2.0
        end

        ent:PlaySound(SoundEffect.SOUND_CHILD_ANGRY_ROAR,1,0,false,0.9 + (fright_flag and -0.2 or 0.0))
    end

    if ent.FrameCount % 20 == 0 and ent:GetDropRNG():RandomFloat() < (data.sound_tick or 0) * 0.1 and sprite:IsPlaying("Idle") then 
        ent:PlaySound(SoundEffect.SOUND_FAT_GRUNT,1,0,false,1.2+ent:GetDropRNG():RandomFloat()*0.075 + (fright_flag and -0.2 or 0.0))
        data.sound_tick = 0
    else
        data.sound_tick = (data.sound_tick or 0) + 1 / 20.0
    end
end

return monster