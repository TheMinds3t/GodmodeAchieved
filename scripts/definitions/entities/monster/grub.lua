local monster = {}
-- monster.data gets updated every callback
monster.name = "Grubby"
monster.type = GODMODE.registry.entities.grubby.type
monster.variant = GODMODE.registry.entities.grubby.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()
    if ent.FrameCount == 1 then
        sprite:Play("Idle",true)
    end

    local ti = player.Position - ent.Position
    local spd = 1.0

    if sprite:IsPlaying("Attack") then 
        spd = 0.4
    end

    if sprite:IsFinished("Attack") then
        sprite:Play("Idle",true)
    end

    -- ent.Position = ent.Position + Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)

    if sprite:IsFinished("Appear") and not sprite:IsPlaying("Attack") then
        sprite:Play("Idle",false)
    end

    data.attack_time = (data.attack_time or 46) - 1

    if data.attack_time <= 0 and GODMODE.room:CheckLine(ent.Position, player.Position, 1) == true and not sprite:IsPlaying("Attack") then
        sprite:Play("Attack",true)
        data.attack_time = 30
    end

    ent.Velocity = ent.Velocity * 0.4 + ti:Resized(math.max(0.3,math.min(ti:Length()/104.0,1.5)))*spd

    if sprite:IsEventTriggered("Fire") then
        ent:ToNPC():PlaySound(SoundEffect.SOUND_CHILD_HAPPY_ROAR_SHORT, 1.0, 1, false, 0.4 + ent:GetDropRNG():RandomFloat() * 0.2)
        for i=0, 2 do
            local spd = 3.0
            local ang = player.Position - ent.Position
            local f = math.rad(ang:GetAngleDegrees() - 27 + i * 27)
            ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
            Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position + ang,ang*spd,ent)
        end
    end

end

return monster