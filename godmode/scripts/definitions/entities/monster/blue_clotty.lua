local monster = {}
-- monster.data gets updated every callback
monster.name = "[GODMODE] Hushed Clotty"
monster.type = GODMODE.registry.entities.hushed_clotty.type
monster.variant = GODMODE.registry.entities.hushed_clotty.variant

monster.hop_strength = 3
monster.atk_count = 6
monster.atk_spread = 0.25
monster.atk_speed = 6.5

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()

    local dir = math.floor((ent.Velocity:GetAngleDegrees()+45+180)/90)%4
    ent.FlipX = dir == 0

    if sprite:IsFinished("Appear") or sprite:IsFinished("Attack") or sprite:IsFinished("Hop") then 
        if sprite:GetAnimation() == "Hop" then 
            ent.I2 = ent.I2 + 1
        else 
            ent.I2 = 0
        end

        if ent:GetDropRNG():RandomFloat() <= 3.0 - ent.I2 * 1.25 then 
            sprite:Play("Hop",true)
            data.hop_dir = RandomVector() * monster.hop_strength
        else 
            sprite:Play("Idle",false)
        end
    elseif ent:IsFrame(12,1) and sprite:IsPlaying("Idle") then
        ent.I1 = ent.I1 + 1
        sprite:Play("Hop", true)

        if ent:GetDropRNG():RandomFloat() < ent.I1 * 0.75 then 
            ent.I1 = -1
            sprite:Play("Attack",true)
        else 
            data.hop_dir = RandomVector() * monster.hop_strength
        end
    end

    if sprite:IsPlaying("Hop") then 
        ent.Velocity = ent.Velocity + data.hop_dir:Resized(1/20.0)
    else 
        ent.Velocity = ent.Velocity * 0.5
    end

    if sprite:IsEventTriggered("Shoot") then 
        for i=1,monster.atk_count do 
            local ang = math.rad((360/monster.atk_count*i)+ent:GetDropRNG():RandomFloat()*(360/monster.atk_count*monster.atk_spread) + (360/monster.atk_count*monster.atk_spread/2))
            local spd = monster.atk_speed + (GODMODE.game.Difficulty % 2) * 3.5
            local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position,Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
            tear = tear:ToProjectile()
            tear.Height = -25
            tear.FallingSpeed = 0.0
            tear.FallingAccel = -(4.25/60.0)
            tear.Scale = 1.2
            tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.CONTINUUM
        end
        GODMODE.sfx:Play(SoundEffect.SOUND_WEIRD_WORM_SPIT,Options.SFXVolume*1.0+0.75)
        ent:ToNPC():PlaySound(SoundEffect.SOUND_CHILD_ANGRY_ROAR, 1.0, 1, false, 0.7 + ent:GetDropRNG():RandomFloat() * 0.3)
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