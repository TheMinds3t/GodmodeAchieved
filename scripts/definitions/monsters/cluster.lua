local monster = {}
-- monster.data gets updated every callback
monster.name = "Cluster"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()
    if data.life == nil then
        data.life = 8
        data.rand = ent:GetDropRNG():RandomInt(34)
    end

    ent:GetSprite():Play("Idle"..tostring(math.max(math.min(8,data.life),1)),false)

    local ti = player.Position - ent.Position
    local spd = 0.85
    if ent.FrameCount % 3 == 0 then
        ent.Velocity = ent.Velocity * 0.8 + Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)
    end

    if (data.time) % 34 == 0 then
        local fly = Game():Spawn(EntityType.ENTITY_FLY,0,ent.Position,Vector(0,0),ent,1,ent.InitSeed)
        fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        fly.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        data.life = data.life - 1
    end

    local perc = (data.life / 8)
    ent.Scale = 1.0 - (1.0-perc) * 0.35

    if ent.HitPoints / ent.MaxHitPoints < (1.0 - perc) or data.life <= 0 then
        ent:Kill()
        for i=0, 1+(data.life) do
            local spd = 3 * ent:GetDropRNG():RandomFloat() + 2
            local f = math.rad(ent:GetDropRNG():RandomFloat() * 360)
            local ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
            local fly = Game():Spawn(EntityType.ENTITY_FLY,0,ent.Position + ang,Vector.Zero,ent,1,ent.InitSeed)
            fly.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            fly.Velocity = ang*spd
        end

        local fly = Game():Spawn(EntityType.ENTITY_ATTACKFLY,0,ent.Position, Vector(0,0), ent, 1, ent.InitSeed)
        fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end

return monster