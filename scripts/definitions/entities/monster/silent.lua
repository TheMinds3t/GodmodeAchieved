local monster = {}
-- monster.data gets updated every callback
monster.name = "Silent"
monster.type = GODMODE.registry.entities.silent.type
monster.variant = GODMODE.registry.entities.silent.variant

monster.npc_update = function(self, ent, data, sprite)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()
    if data.real_time == 1 then return end
    if not data.init and sprite:IsFinished("Appear") then
        sprite:Play("Idle",true)
        data.init = true
        data.spawn_tear = function(self, ang, speed, curve)
            if curve == nil then curve = 0 end
            local vel = Vector(math.cos(ang) * speed,math.sin(ang) * speed)
            local offset = ent:GetDropRNG():RandomFloat() * 6.28
            local off = Vector(math.cos(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7),math.sin(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7))
            local params = ProjectileParams()
            params.HeightModifier = -2
            params.FallingSpeedModifier = 0.1
            params.FallingAccelModifier = 0.05
            params.Scale = 1.2
            params.CurvingStrength = curve

            local tear = ent:FireBossProjectiles(1, off*10+vel+player.Position, speed, params)
            if sprite:IsPlaying("Attack2") then
                off = off * 0.125 + Vector(-80,32)
            end
            --tear.Position = tear.Position + off
        end
    end

    local ti = player.Position - ent.Position
    local spd = 0.5
    if sprite:IsPlaying("Attack") then spd = 0.05 end
    local vel = Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)
    ent.Velocity = ent.Velocity * 0.89 + vel * 0.63
    if sprite:IsFinished("Attack") then
        sprite:Play("Idle",true)
    end

    if sprite:IsPlaying("Idle") and ent:GetDropRNG():RandomFloat() < 0.9 and (data.time) % 30 == 20 and ent.FrameCount > 60 then
        sprite:Play("Attack",true)
        ent:ToNPC():PlaySound(SoundEffect.SOUND_BOSS_GURGLE_ROAR , 1.2, 1, false, 0.7 + ent:GetDropRNG():RandomFloat() * 0.2)
    end

    if sprite:IsEventTriggered("Fire") then
        for i=0,9 do
            local spd = 3.0 + ent:GetDropRNG():RandomFloat()
            local f = math.rad(360 / 8 * i + ent:GetDropRNG():RandomFloat() * 360)
            data:spawn_tear(f,spd,2.5)
        end
    end
end

return monster