local monster = {}
-- monster.data gets updated every callback
monster.name = "Dream"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()
    if ent:GetSprite():IsFinished("Appear") and data.start ~= true then
        ent:GetSprite():Play("Idle",true)
        data.start = ent:GetSprite():IsPlaying("Idle")
    end
    ent.Velocity = ent.Velocity * 0.95

    if ent:GetSprite():IsFinished("Fire") or ent:GetSprite():IsFinished("TeleportIn") then
        ent:GetSprite():Play("Idle",false)
    end

    if data.time % 50 == 25 and ent:GetSprite():IsPlaying("Idle") then
        if ent:GetDropRNG():RandomFloat() < 0.25 then
            ent:GetSprite():Play("TeleportOut",true)
        else
            ent:GetSprite():Play("Fire",true)
        end
    end

    if ent:GetSprite():IsEventTriggered("Teleport") then
        local v = player.Position
        local ang = math.rad(ent:GetDropRNG():RandomFloat() * 360)
        v = v + Vector(math.cos(ang) * 160,math.sin(ang) * 160)
        ent.Position = v
        ent:GetSprite():Play("TeleportIn",true)
        ent.Velocity = Vector(0,0)
    end

    if ent:GetSprite():IsEventTriggered("Fire") then
        for i=0,2 do
            local spd = 1.25 + ent:GetDropRNG():RandomFloat() * 1.25
            local ang = player.Position - ent.Position
            local f = math.rad(ang:GetAngleDegrees() + ent:GetDropRNG():RandomFloat() * 45 - 22.5)
            ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
            Game():Spawn(EntityType.ENTITY_PROJECTILE,0,ent.Position + ang,ang*spd,ent,0,ent.InitSeed)
        end
    end
end

return monster