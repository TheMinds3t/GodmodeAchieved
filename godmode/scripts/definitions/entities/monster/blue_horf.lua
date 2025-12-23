local monster = {}
-- monster.data gets updated every callback
monster.name = "[GODMODE] Hushed Horf"
monster.type = GODMODE.registry.entities.hushed_horf.type
monster.variant = GODMODE.registry.entities.hushed_horf.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()

    ent.Velocity = ent.Velocity * 0.5
    if ent.Velocity:Length() <= 0.1 then ent.Velocity = Vector.Zero end

    local dir = math.floor((ent.Velocity:GetAngleDegrees()+45+180)/90)%4
    ent.FlipX = dir == 0

    if sprite:IsFinished("Appear") or sprite:IsFinished("Attack") then 
        sprite:Play("Idle",true)
    elseif sprite:IsFinished("Idle") then 
        ent.I1 = ent.I1 + 1

        if ent:GetDropRNG():RandomFloat() < ent.I1 * 0.5 - 0.35 then 
            ent.I1 = -1
            sprite:Play("Attack",true)
        end
    end

    if sprite:IsEventTriggered("Fire") then 
        local ang = math.rad((player.Position-(ent.Position)):GetAngleDegrees())
        local spd = 7.0 + (GODMODE.game.Difficulty % 2) * 3.5
        local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position,Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
        tear = tear:ToProjectile()
        tear.Height = -25
        tear.FallingSpeed = 0.0
        tear.FallingAccel = -(4.2/60.0)
        tear.Scale = 2
        tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.BURST | ProjectileFlags.CONTINUUM
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