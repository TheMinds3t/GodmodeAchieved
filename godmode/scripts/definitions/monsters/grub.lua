local monster = {}
-- monster.data gets updated every callback
monster.name = "Grubby"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()
    if ent.FrameCount == 1 then
        ent:GetSprite():Play("Idle",true)
    end

    local ti = player.Position - ent.Position
    local spd = 1.0

    if ent:GetSprite():IsPlaying("Attack") then 
        spd = 0.4
    end

    if ent:GetSprite():IsFinished("Attack") then
        ent:GetSprite():Play("Idle",true)
    end

    -- ent.Position = ent.Position + Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)

    if ent:GetSprite():IsFinished("Appear") and not ent:GetSprite():IsPlaying("Attack") then
        ent:GetSprite():Play("Idle",false)
    end

    data.attack_time = (data.attack_time or 46) - 1

    if data.attack_time <= 0 and Game():GetRoom():CheckLine(ent.Position, player.Position, 1) == true and not ent:GetSprite():IsPlaying("Attack") then
        ent:GetSprite():Play("Attack",true)
        data.attack_time = 30
    end

    ent.Velocity = ent.Velocity * 0.4 + ti:Resized(math.max(0.3,math.min(ti:Length()/104.0,1.5)))*spd

    if ent:GetSprite():IsEventTriggered("Fire") then
        ent:ToNPC():PlaySound(SoundEffect.SOUND_CHILD_HAPPY_ROAR_SHORT, 1.0, 1, false, 0.4 + ent:GetDropRNG():RandomFloat() * 0.2)
        for i=0, 2 do
            local spd = 3.0
            local ang = player.Position - ent.Position
            local f = math.rad(ang:GetAngleDegrees() - 27 + i * 27)
            ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
            Game():Spawn(EntityType.ENTITY_PROJECTILE,0,ent.Position + ang,ang*spd,ent,0,ent.InitSeed)
        end
    end

end

return monster