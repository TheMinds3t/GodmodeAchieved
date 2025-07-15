local monster = {}
-- monster.data gets updated every callback
monster.name = "Hushed Fatty"
monster.type = GODMODE.registry.entities.hushed_fatty.type
monster.variant = GODMODE.registry.entities.hushed_fatty.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()
    local pathfinding = GODMODE.util.ground_ai_movement(ent,ent:GetPlayerTarget(),0.4,true)
    local dir = math.floor((ent.Velocity:GetAngleDegrees()+45+180)/90)%4
    local attack_flag = ent.I2 == 1
    ent.FlipX = dir == 0
    
    if attack_flag then 
        ent.Velocity = ent.Velocity * 0.8
    else 
        if pathfinding ~= nil then 
            ent.Velocity = ent.Velocity * 0.75 + pathfinding
        elseif ent:GetPlayerTarget() ~= nil then 
            ent.Pathfinder:FindGridPath(ent:GetPlayerTarget().Position,(0.2 + ent.I1 / 5.0 * 0.3)*ent.Friction,0,true)
        end
    end


    if not attack_flag then 
        if dir % 2 == 0 then 
            sprite:Play("WalkHori",false)
        else
            sprite:Play("WalkVert",false)
        end    
    end

    if sprite:IsFinished("AttackHori") or sprite:IsFinished("AttackVert") then 
        ent.I2 = 0
        ent.I1 = 0
    end

    -- pick when to attack
    if ent:IsFrame(10,1) and not attack_flag then 
        ent.I1 = ent.I1 + 1

        if ent:GetDropRNG():RandomFloat() < ent.I1 * 0.1 - 0.5 then 
            sprite:Play("Attack"..(dir % 2 == 0 and "Hori" or "Vert"), true)
            ent.I2 = 1
        end
    end

    if sprite:IsEventTriggered("Ring") then
        local split_into = 8 

        for i=1,split_into do 
            local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position,Vector(1,0):Rotated(360/split_into*i):Resized(4.0 + (GODMODE.game.Difficulty % 2) * 3.0),ent)
            tear = tear:ToProjectile()
            tear.Height = -40
            tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.DECELERATE | ProjectileFlags.CONTINUUM
        end
    end

    if sprite:IsEventTriggered("Shoot") then 
        local ang = math.rad((player.Position-(ent.Position)):GetAngleDegrees())
        local spd = 8.0 + (GODMODE.game.Difficulty % 2) * 4.0
        local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position,Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
        tear = tear:ToProjectile()
        tear.Height = -35
        tear.FallingSpeed = 0.0
        tear.FallingAccel = -(5.1/60.0)
        tear.Scale = 2
        tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.BURST8 | ProjectileFlags.CONTINUUM
        GODMODE.sfx:Play(SoundEffect.SOUND_WEIRD_WORM_SPIT,Options.SFXVolume*1.0+0.75)
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