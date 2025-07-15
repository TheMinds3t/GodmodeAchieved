local monster = {}
-- monster.data gets updated every callback
monster.name = "Hushed Horf"
monster.type = GODMODE.registry.entities.hushed_horf.type
monster.variant = GODMODE.registry.entities.hushed_horf.variant

local max_children = 5
local child_spawn_total = 10

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

        if ent:GetDropRNG():RandomFloat() < ent.I1 * 0.35 - 0.35 then 
            ent.I1 = -1
            local num_children = GODMODE.util.count_child_enemies(ent,true)

            if num_children <= 1 then 
                sprite:Play("Attack",true)
            else 
                sprite:Play("Idle",true)
            end
        end
    end

    if sprite:IsEventTriggered("Fire") then 
        if (data.max_children or child_spawn_total) <= 0 then 
            local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position,Vector(1,0):Rotated(360/split_into*i):Resized(4.0 + (GODMODE.game.Difficulty % 2) * 3.0),ent)
            tear = tear:ToProjectile()
            tear.Height = -40
            tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.DECELERATE | ProjectileFlags.CONTINUUM
        else
            -- local sub = 
            for i=1,max_children do 
                local fly = Isaac.Spawn(EntityType.ENTITY_HUSH_FLY, 0, 0, ent.Position, Vector.Zero, ent)
                fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                fly.Parent = player
                data.max_children = (data.max_children or child_spawn_total) - 1

                if data.max_children <= 0 then break end
            end


            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position + Vector(0,-16), Vector.Zero, nil)
            ent:ToNPC():PlaySound(SoundEffect.SOUND_CHILD_ANGRY_ROAR, 1.0, 1, false, 0.7 + ent:GetDropRNG():RandomFloat() * 0.3)
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