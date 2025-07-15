local monster = {}
-- monster.data gets updated every callback
monster.name = "Infested MemBrain"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()

    if not ent:GetSprite():IsPlaying("Attack") and not ent:GetSprite():IsPlaying("Attack2") and not ent:GetSprite():IsPlaying("Wiggle") then
        ent:GetSprite():Play("Wiggle",false)
    end

    if ent:GetSprite():IsFinished("Wiggle") then 
        if ent:GetDropRNG():RandomFloat() < 0.7 + ent.I1 * 0.15 then 
            if ent:GetDropRNG():RandomFloat() < 0.5 then 
                ent:GetSprite():Play("Attack",false)
            else
                ent:GetSprite():Play("Attack2",false)
            end
            ent.I1 = 0
        else
            ent:GetSprite():Play("Wiggle",false)
            ent.I1 = ent.I1 + 1
        end
    end

    if ent:GetSprite():IsPlaying("Wiggle") then 
        ent.Pathfinder:MoveRandomly(false)
        ent.Velocity = ent.Velocity * 0.95
    else
        ent.Velocity = ent.Velocity * 0.8
    end

    if ent:GetSprite():IsEventTriggered("Shoot") then
        if ent:GetSprite():IsPlaying("Attack") then 
            local eye_offset = Vector(0,-32)
            local f = math.floor(((player.Position - Vector(0,player.Size / 2.0)) - (ent.Position+eye_offset)):GetAngleDegrees()) % 360
            local tell = Isaac.Spawn(Isaac.GetEntityTypeByName("Unholy Order"),Isaac.GetEntityVariantByName("Unholy Order"),f,ent.Position+eye_offset,Vector.Zero,ent)
            local tell_data = GODMODE.get_ent_data(tell)
            tell_data.fire_time = 30
            tell_data.laser_timeout = 10
            tell_data.follow_parent = true
            tell_data.remove_on_dead = true
            tell.Parent = ent
            tell.DepthOffset = 40    
        else
            local spd = 8.75 + ent:GetDropRNG():RandomFloat() * 0.25
            SFXManager():Play(SoundEffect.SOUND_FORESTBOSS_STOMPS,Options.SFXVolume*1.3+0.5)

            for i=0,7 do
                local f = math.rad(360 / 8 * i)
                local tear = Game():Spawn(EntityType.ENTITY_PROJECTILE,0,Vector(ent.Position.X,ent.Position.Y),Vector(math.cos(f)*spd,math.sin(f)*spd),ent,0,player.InitSeed)
                tear = tear:ToProjectile()
                tear.Height = -17
                tear.FallingSpeed = 0.0
                tear.FallingAccel = -(2/60.0)
                tear.Scale = 1.5
            end
        end
    end
end

monster.npc_kill = function(self,ent)
    if not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then 
        Isaac.Spawn(EntityType.ENTITY_BRAIN,0,0,ent.Position,RandomVector(),ent)
        Isaac.Spawn(EntityType.ENTITY_BRAIN,0,0,ent.Position,RandomVector(),ent)
    end
end

return monster