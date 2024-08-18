local monster = {}
-- monster.data gets updated every callback
monster.name = "Infested MemBrain"
monster.type = GODMODE.registry.entities.infested_membrain.type
monster.variant = GODMODE.registry.entities.infested_membrain.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()

    if not sprite:IsPlaying("Attack") and not sprite:IsPlaying("Attack2") and not sprite:IsPlaying("Wiggle") then
        sprite:Play("Wiggle",false)
    end

    if sprite:IsFinished("Wiggle") then 
        if ent:GetDropRNG():RandomFloat() < 0.7 + ent.I1 * 0.15 then 
            if ent:GetDropRNG():RandomFloat() < 0.5 then 
                sprite:Play("Attack",false)
            else
                sprite:Play("Attack2",false)
            end
            ent.I1 = 0
        else
            sprite:Play("Wiggle",false)
            ent.I1 = ent.I1 + 1
        end
    end

    if sprite:IsPlaying("Wiggle") then 
        ent.Pathfinder:MoveRandomly(false)
        ent.Velocity = ent.Velocity * 0.95
    else
        ent.Velocity = ent.Velocity * 0.8
    end

    if sprite:IsEventTriggered("Shoot") then
        if sprite:IsPlaying("Attack") then 
            local eye_offset = Vector(0,-32)
            local f = math.floor(((player.Position - Vector(0,player.Size / 2.0)) - (ent.Position+eye_offset)):GetAngleDegrees()) % 360
            local tell = Isaac.Spawn(GODMODE.registry.entities.unholy_order.type,GODMODE.registry.entities.unholy_order.variant,f,ent.Position+eye_offset,Vector.Zero,ent)
            local tell_data = GODMODE.get_ent_data(tell)
            tell_data.fire_time = 30
            tell_data.laser_timeout = 10
            tell_data.follow_parent = true
            tell_data.remove_on_dead = true
            tell.Parent = ent
            tell.DepthOffset = 40    
        else
            local spd = 8.75 + ent:GetDropRNG():RandomFloat() * 0.25
            GODMODE.sfx:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS,Options.SFXVolume*1.3+0.5)

            for i=0,7 do
                local f = math.rad(360 / 8 * i)
                local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,Vector(ent.Position.X,ent.Position.Y),Vector(math.cos(f)*spd,math.sin(f)*spd),ent)
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