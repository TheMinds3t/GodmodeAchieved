local monster = {}
monster.name = "Dial"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
    if data.real_time == 1 then return end
    local player = ent:GetPlayerTarget()
    if data.l == nil and ent:GetSprite():IsFinished("Appear") then
        ent:GetSprite():Play("Idle",true)
        data.l = {}
    end

    local ti = player.Position - ent.Position
    local spd = 0.5
    if ent:GetSprite():IsPlaying("Attack") then spd = 0.0 end
    local vel = Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)
    ent.Velocity = ent.Velocity * 0.92 + vel * 0.4
    if ent:GetSprite():IsFinished("Attack") then
        ent:GetSprite():Play("Idle",true)
    end

    for i=1,3 do
        if data.l and data.l[i] then
            data.l[i].MaxDistance = data.l[i].MaxDistance * 1.1625
            data.l[i].RotationDegrees = data.l[i].RotationDegrees / 1.03 
        end
    end

    if (data.time) % 60 == 20 and ent:GetDropRNG():RandomFloat() < 0.9 and ent:GetSprite():IsPlaying("Idle") then
        ent:GetSprite():Play("Attack",true)
    end

    if ent:GetSprite():IsEventTriggered("Brim") then
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