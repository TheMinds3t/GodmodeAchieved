local monster = {}
-- monster.data gets updated every callback
monster.name = "[GODMODE] Hushed Freddy"
monster.type = GODMODE.registry.entities.hushed_freddy.type
monster.variant = GODMODE.registry.entities.hushed_freddy.variant

monster.min_down_time = 15
monster.max_down_time = 30

monster.pick_safe_spot = function(depth)
    depth = depth or 30
    local pos = GODMODE.room:GetRandomPosition(40)
    if #Isaac.FindInRadius(pos, 80, EntityPartition.PLAYER) == 0 or depth <= 0 then 
        return pos
    else 
        return monster.pick_safe_spot(depth - 1)
    end
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()

    ent.FlipX = player.Position.X < ent.Position.X 

    -- handle burying the enemy 
    if ent.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE  then 
        ent.I1 = ent.I1 - 1

        if ent.I1 <= 0 then 
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            ent.Visible = true 
            sprite:Play("DigUp",true)
        end
        ent.Velocity = ent.Velocity * 0.1
    else 
        local up_flag = sprite:GetAnimation() == "JumpUpHead"

        if sprite:GetAnimation() == "JumpDownHead" or up_flag then
            if up_flag then 
                ent.Velocity = ent.Velocity * 0.8 + Vector(ent.V1.X,-1) 
            else
                ent.Velocity = ent.Velocity * 0.8 + Vector(ent.V1.X,1) 
            end
        else 
            ent.Velocity = ent.Velocity * 0.5
        end
    end

    -- handle idle time before doing stuff
    if sprite:IsFinished("DigUp") and sprite:GetAnimation() == "DigUp" or sprite:IsFinished("Appear") then 
        ent.I2 = ent.I2 + 1 

        if ent:IsFrame(5,1) and ent:GetDropRNG():RandomFloat() < ent.I2 * (1/20/4) then 
            ent.I2 = 0

            if ent:GetDropRNG():RandomFloat() < 0.2 then 
                sprite:Play("DigDown",true)
            else 
                sprite:Play("Attack",true)
            end
        end
    else
        ent.I2 = 0
    end

    if sprite:IsFinished("Attack") then 
        if ent:GetDropRNG():RandomFloat() < 0.33 then 
            sprite:Play("DigDown", true)
        else
            ent.V1 = Vector(ent:GetDropRNG():RandomFloat()*3-1.5,0)
            if player.Position.Y > ent.Position.Y then 
                sprite:Play("JumpDownHead",true)
            else 
                sprite:Play("JumpUpHead",true)
            end
        end
    end

    if sprite:IsEventTriggered("Shoot") then 
        if sprite:GetAnimation() == "Attack" then 
            local ang = math.rad((player.Position - ent.Position):GetAngleDegrees())
            local spd = 8.5 + (GODMODE.game.Difficulty % 2) * 3.5
            local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position,Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
            tear = tear:ToProjectile()
            tear.Height = -25
            tear.FallingSpeed = 0.0
            tear.FallingAccel = -(4.25/60.0)
            tear.Scale = 1.5
            tear.CurvingStrength = 92
            tear.HomingStrength = 0.5
            tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.EXPLODE | ProjectileFlags.SMART
            tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            GODMODE.sfx:Play(SoundEffect.SOUND_WEIRD_WORM_SPIT,Options.SFXVolume*1.0+0.75)
            ent:ToNPC():PlaySound(SoundEffect.SOUND_CHILD_ANGRY_ROAR, 1.0, 1, false, 0.7 + ent:GetDropRNG():RandomFloat() * 0.3)
        else -- jump attack 

        end
    end

    if sprite:IsEventTriggered("Land") then 
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE 
            ent.I1 = ent:GetDropRNG():RandomInt(monster.max_down_time - monster.min_down_time) + monster.min_down_time
            ent.Visible = false 
            ent.Position = monster.pick_safe_spot()
        ent:ToNPC():PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1.0, 1, false, 0.8 + ent:GetDropRNG():RandomFloat() * 0.2)
    end

    if sprite:IsEventTriggered("Jump") then 
        ent:ToNPC():PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1.0, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)

        if sprite:GetAnimation() == "JumpDownHead" or sprite:GetAnimation() == "JumpUpHead" then 
            ent:ToNPC():PlaySound(SoundEffect.SOUND_SMB_LARGE_CHEWS_4, 1.0, 1, false, 1.1 + ent:GetDropRNG():RandomFloat() * 0.1)
        end
    end
end

-- monster.npc_kill = function(self,ent)
--     if not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then 
--         for i=1,3 do 
--             local bby = Isaac.Spawn(EntityType.ENTITY_BABY,3,0,ent.Position,Vector(1,0):Rotated(360/3*i):Resized(10.0),ent)
--             bby:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
--             bby:GetSprite():Play("DashStart",true)
--         end
--     end
-- end

return monster