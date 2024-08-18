local monster = {}
-- monster.data gets updated every callback
monster.name = "Harf"
monster.type = GODMODE.registry.entities.harf.type
monster.variant = GODMODE.registry.entities.harf.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()
    data.attack_time = (data.attack_time or 61) - 1

    if not sprite:IsPlaying("Attack") and not sprite:IsPlaying("Idle") then
        sprite:Play("Idle",false)
    end

    if data.attack_time <= 0 and GODMODE.room:CheckLine(ent.Position, player.Position, 1) == true then
        sprite:Play("Attack",false)
        data.attack_time = 60
    end

    ent.Velocity = ent.Velocity * 0.15

    if sprite:IsEventTriggered("Fire") then
        ent:ToNPC():PlaySound(SoundEffect.SOUND_CHILD_HAPPY_ROAR_SHORT, 1.0, 1, false, 0.7 + ent:GetDropRNG():RandomFloat() * 0.3)
        local spd = 2.8
        if GODMODE.game.Difficulty % 2 == 1 then spd = 3.2 end
        local ang = player.Position - ent.Position
        local f = math.rad(ang:GetAngleDegrees())
        ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
        local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position + ang,ang*spd,ent)

        if ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then 
            tear:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
        end
        
        local blood = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, ent.Position + ang-Vector(0,16), Vector.Zero, ent)
        blood:SetColor(Color(1,1,1,0.75,0.3,0.2,0.2),40,99,false,false)
        blood.DepthOffset = 100
    end
end

return monster