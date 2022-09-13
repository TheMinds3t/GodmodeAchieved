local monster = {}
monster.name = "Paracolony"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()
    if data.life == nil then
        ent:GetSprite():Play("Idle",true)
        data.life = 8
        data.rand = ent:GetDropRNG():RandomInt(60)
    end

    local ti = player.Position - ent.Position
    local spd = 0.85
    if ent.FrameCount % 3 == 0 then
        ent.Velocity = ent.Velocity * 0.8 + Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)
    end

    if (ent.FrameCount+data.rand) % 60 == 0 then
        local bit = Game():Spawn(Isaac.GetEntityTypeByName("Para-Bit"),Isaac.GetEntityVariantByName("Para-Bit"),ent.Position,Vector(0,0),ent,700,ent.InitSeed) --parabit
        bit:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        data.life = data.life - 0.5
    end

    local perc = (data.life / 8)
    ent.Scale = 1.0 - (1.0-perc) * 0.3

    if ent.HitPoints / ent.MaxHitPoints < (1.0 - perc) or data.life <= 0 then
        ent:Kill()
        for i=0, 1+(data.life) do
            local spd = 0.1
            local f = math.rad(ent:GetDropRNG():RandomFloat() * 360)
            local ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
            local bit = Game():Spawn(Isaac.GetEntityTypeByName("Para-Bit"),Isaac.GetEntityVariantByName("Para-Bit"),ent.Position + ang,ang*spd,ent,700,ent.InitSeed) --parabit
        end
        
        Game():Spawn(EntityType.ENTITY_PARA_BITE,0,ent.Position, Vector(0,0), ent, 0, ent.InitSeed)
    end
end

return monster