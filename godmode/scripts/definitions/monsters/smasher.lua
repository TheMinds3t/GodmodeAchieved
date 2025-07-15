local monster = {}
monster.name = "Slammer"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()

    if data.real_time == 1 then
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        ent:GetSprite():Play("Idle",true)
        data.slamtime = -1
    end

    ent.CollisionDamage = 0.0

    local ti = player.Position - ent.Position
    local spd = 2.25
    if ent:GetSprite():IsPlaying("GoDown") then if ent:GetSprite():GetFrame() < 21 then spd = 8.0 else spd = 0.0 end end
    if ti:Length() > 12 then 
        ent.Position = ent.Position + Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)
    end

    data.slamtime = (data.slamtime or -1) - 1
    if ent:GetSprite():IsFinished("GoUp") then
        ent:GetSprite():Play("GoDown",false)
    end
    if ent:GetSprite():IsFinished("GoDown") then
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        ent:GetSprite():Play("Idle",false)
    end
    if ent:GetSprite():IsFinished("Appear") then
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        ent:GetSprite():Play("Idle",false)
    end
    if (data.time) % 100 == 0 and ent:GetSprite():IsPlaying("Idle") then
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        ent:GetSprite():Play("GoUp",false)
    end

    ent.Velocity = ent.Velocity * 0.15

    if ent:GetSprite():IsEventTriggered("Smash") then
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        ent:BloodExplode()
        ent:BloodExplode()
        Game():ShakeScreen(10)
        Game():BombDamage(ent.Position,40.0,48,false,ent,TearFlags.FLAG_NO_EFFECT,0,true)
        --data.slamtime = 40
        ent:ToNPC():PlaySound(SoundEffect.SOUND_CHILD_HAPPY_ROAR_SHORT, 1.0, 1, false, 0.4 + ent:GetDropRNG():RandomFloat() * 0.2)
        local count = 6
        for i=0, count do
            local spd = 1.75 + ent:GetDropRNG():RandomFloat()
            local f = math.rad(ent:GetDropRNG():RandomFloat() * (360/count)+i*(360/count))
            local ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
            local t = Game():Spawn(EntityType.ENTITY_PROJECTILE,0,ent.Position + ang,ang*spd,ent,0,ent.InitSeed)
            for x=0,ent:GetDropRNG():RandomFloat()*20 do
                t:Update()
            end
            t.Position = ent.Position
        end
    end
end

monster.player_collide = function(self, player, ent, entfirst)
    if ent.Type == monster.type and ent.Variant == monster.variant and (ent:GetSprite():IsPlaying("Idle") or ent:GetSprite():IsPlaying("GoUp")) then 
        return true
    end
end

return monster