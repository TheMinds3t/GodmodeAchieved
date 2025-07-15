local monster = {}
monster.name = "Paracolony"
monster.type = GODMODE.registry.entities.paracolony.type
monster.variant = GODMODE.registry.entities.paracolony.variant

monster.npc_update = function(self, ent, data, sprite)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()
    if data.life == nil then
        sprite:Play("Idle",true)
        data.life = 7
        data.rand = ent:GetDropRNG():RandomInt(60)
    end

    local ti = player.Position - ent.Position
    local spd = 0.85
    if ent.FrameCount % 3 == 0 then
        ent.Velocity = ent.Velocity * 0.8 + Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)
    end

    if (ent.FrameCount+data.rand) % 60 == 0 then
        local bit = Isaac.Spawn(GODMODE.registry.entities.parabit.type,GODMODE.registry.entities.parabit.variant,700,ent.Position,Vector(0,0),ent) --parabit
        bit:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        data.life = data.life - 1.0
    end

    local perc = (data.life / 8)
    ent.Scale = 1.0 - (1.0-perc) * 0.15

    if ent.HitPoints / ent.MaxHitPoints < (1.0 - perc) or data.life <= 0 then
        ent:Kill()
        for i=1, (data.life) do
            local spd = 0.1
            local f = math.rad(ent:GetDropRNG():RandomFloat() * 360)
            local ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
            local bit = Isaac.Spawn(GODMODE.registry.entities.parabit.type,GODMODE.registry.entities.parabit.variant,700,ent.Position + ang,ang*spd,ent) --parabit
        end
        
        Isaac.Spawn(EntityType.ENTITY_PARA_BITE,0,0,ent.Position, Vector(0,0), ent)
    end
end

return monster