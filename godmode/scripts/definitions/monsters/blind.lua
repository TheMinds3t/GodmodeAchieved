local monster = {}
-- monster.data gets updated every callback
monster.name = "Blind Spider"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_init = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant then
        local data = GODMODE.get_ent_data(ent)
        data.spawn_tear = function(self, ang, speed, curve)
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
    end
end
monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()
    if not data.anim then
        ent:GetSprite():Play("Idle",true)
        data.anim = ent:GetSprite():IsPlaying("Idle")
    end

    local ti = player.Position - ent.Position
    local spd = 2.125
    if ent.SubType == 1 then spd = 3 end
    if ent:GetSprite():IsPlaying("TeleportIn") or ent:GetSprite():IsPlaying("TeleportOut") then spd = 0 end
    ent.Position = ent.Position + Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)
    ent.Velocity = ent.Velocity * 0.5
    if ent:GetSprite():IsFinished("Fire") then
        ent:GetSprite():Play("Idle",true)
    end

    if data.time % 50 == 0 then
        if ent:GetDropRNG():RandomFloat() < 0.25 then
            ent:GetSprite():Play("TeleportOut",true)
        else
            ent:GetSprite():Play("Fire",true)
        end
    end

    if ent:GetSprite():IsEventTriggered("Teleport") then
        if ent:GetSprite():IsPlaying("TeleportIn") then
            ent:GetSprite():Play("Idle", true)
        else
            local v = player.Position
            local ang = math.rad(ent:GetDropRNG():RandomFloat() * 360)
            v = v + Vector(math.cos(ang) * 192,math.sin(ang) * 192)
            ent.Position = v
            ent:GetSprite():Play("TeleportIn",true)
            ent.Velocity = Vector(0,0)
        end
    end

    if ent:GetSprite():IsEventTriggered("Fire") then
        if ent.SubType == 1 then
            for i=0,1 do
                local spd = 0.5 + ent:GetDropRNG():RandomFloat()
                local f = math.rad(360 / 8 * i + ent:GetDropRNG():RandomFloat() * 360)
                data:spawn_tear(f,spd,2.5)
            end
        else
            local spd = 2.5
            local ang = player.Position - ent.Position
            local f = math.rad(ang:GetAngleDegrees())
            ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
            Game():Spawn(EntityType.ENTITY_PROJECTILE,0,ent.Position + ang,ang*spd,ent,0,ent.InitSeed)
        end
    end

end

return monster