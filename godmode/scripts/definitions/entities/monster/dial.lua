local monster = {}
monster.name = "Dial"
monster.type = GODMODE.registry.entities.dial.type
monster.variant = GODMODE.registry.entities.dial.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    if data.real_time == 1 then return end
    local player = ent:GetPlayerTarget()
    if data.l == nil and sprite:IsFinished("Appear") then
        sprite:Play("Idle",true)
        data.l = {}
    end

    local ti = player.Position - ent.Position
    local spd = 0.5
    if sprite:IsPlaying("Attack") then spd = 0.0 end
    local vel = Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)
    ent.Velocity = ent.Velocity * 0.92 + vel * 0.4
    if sprite:IsFinished("Attack") then
        sprite:Play("Idle",true)
    end

    for i=1,3 do
        if data.l and data.l[i] then
            data.l[i].MaxDistance = data.l[i].MaxDistance * 1.1625
            data.l[i].RotationDegrees = data.l[i].RotationDegrees / 1.03 
        end
    end

    if (data.time) % 60 == 20 and ent:GetDropRNG():RandomFloat() < 0.9 and sprite:IsPlaying("Idle") then
        sprite:Play("Attack",true)
    end

    if sprite:IsEventTriggered("Brim") then
        ent:ToNPC():PlaySound(SoundEffect.SOUND_SATAN_BLAST, 1.2, 1, false, 0.8 + ent:GetDropRNG():RandomFloat() * 0.2)
        for i=0,2 do
            local f = math.rad(360 / 3 + i * (360 / 3))
            ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
            local l = EntityLaser.ShootAngle(1,ent.Position,math.deg(f),55,Vector(0,-24),ent)
            l.MaxDistance = 1.0
            l:SetActiveRotation(0, math.deg(f) + 360, 3.25, false)
            data.l[i+1] = l
        end
    end
end

-- monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
--     local data = GODMODE.get_ent_data(enthit)
--     if (enthit.Type == monster.type and enthit.Variant == monster.variant) and flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER and entsrc.Type ~= 1 then 
--         return false 
--     end
-- end

return monster