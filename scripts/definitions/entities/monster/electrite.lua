local monster = {}
monster.name = "Electrite"
monster.type = GODMODE.registry.entities.electrite.type
monster.variant = GODMODE.registry.entities.electrite.variant

local hostile_spark_radius = 256.0
local laser_offset = Vector(0,-12)
local scalar_scalar = 5.0

monster.wood = function(self, ent)
    local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.WOOD_PARTICLE,0,ent.Position,RandomVector() * (ent:GetDropRNG():RandomFloat() * 1.5 + 2.0),ent):ToEffect()
    fx.Timeout = 20
end

monster.laser = function(self,ent,dir,life)
    local laser = EntityLaser.ShootAngle(LaserVariant.ELECTRIC,ent.Position,dir:GetAngleDegrees(), life or 3, laser_offset, ent)
    laser.MaxDistance = dir:Length() + ent:GetDropRNG():RandomFloat() * 8.0
    laser.OneHit = true
    laser.CollisionDamage = 1
    laser.Parent = ent
end

monster.spark = function(self, ent)
    local targets = Isaac.FindInRadius(ent.Position,hostile_spark_radius,EntityPartition.ENEMY)

    for _,target in ipairs(targets) do 
        if GODMODE.util.is_valid_enemy(target,true) then 
            monster.laser(self,ent,(target.Position + Vector(target.Size/2.0,0):Rotated(ent:GetDropRNG():RandomInt(360))) - ent.Position)
        end
    end

    for i=0,1 do 
        monster.laser(self,ent,Vector(1,0):Rotated(ent:GetDropRNG():RandomInt(360)):Resized((ent:GetDropRNG():RandomFloat() * 0.05 + 0.25 - i * 0.1) * hostile_spark_radius),12 - ent:GetDropRNG():RandomInt(5) - i * 5)
    end
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    
    if sprite:IsFinished("Appear") or sprite:IsFinished("Idle") or sprite:IsFinished("Hop") or sprite:IsFinished("Drill") then 
        sprite:Play("Idle",true)
        data.idle_ticks = (data.idle_ticks or -1) + 1
        data.spark_radi = nil    

        if ent:GetDropRNG():RandomFloat() < (data.idle_ticks * 0.25) then 
            data.idle_ticks = -8
            data.spark_ticks = (data.spark_ticks or -1) + 1
            
            if ent:GetDropRNG():RandomFloat() < data.spark_ticks * 0.425 then 
                sprite:Play("Drill",true)
                data.spark_ticks = -1
            else
                local off = Vector((ent:GetDropRNG():RandomInt(5)-2) * 128.0,(ent:GetDropRNG():RandomInt(5)-2) * 128.0)
                data.target_position = GODMODE.room:FindFreePickupSpawnPosition(ent.Position + off)
                sprite:Play("Hop",true)
            end
        end    
    end

    if (ent.Position - (data.target_position or ent.Position)):Length() > ent.Size then 
        ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    else 
        ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
    end

    data.target_position = data.target_position or GODMODE.room:FindFreePickupSpawnPosition(ent.Position)
    local scalar = math.max(10,15 - ent.State * 0.25)
    data.scalar = ((data.scalar or scalar) * (scalar_scalar - 1) + scalar) / scalar_scalar
    ent.Velocity = ((data.target_position + ent.Position * (data.scalar - 1)) / data.scalar) - ent.Position

    if sprite:IsEventTriggered("Jump") then 
        ent.State = 10
    end

    if ent.State > 0 and ent.State < 10 then 
        math.max(1,ent.State - 1)
    end 
    
    if data.tunnel == true and ent:IsFrame(3,1) then 
        monster.wood(self,ent)
    end

    if sprite:IsEventTriggered("Land") then 
        ent.State = 9

        if sprite:IsPlaying("Drill") then 
            for i=0,5 do 
                monster.wood(self,ent) 
            end
        end
    end

    if sprite:IsEventTriggered("DigToggle") then 
        data.tunnel = not (data.tunnel or false)
    end

    if sprite:IsEventTriggered("Spark") then 
        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.RIPPLE_POOF,0,ent.Position,Vector.Zero,ent)
        monster.spark(self, ent)

        if data.spark_radi ~= true then 
            local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.RIPPLE_POOF,0,ent.Position,Vector.Zero,ent)
            local sprite = fx:GetSprite()
            sprite.Scale = Vector(0.5,1.2):Resized(hostile_spark_radius / 16.0)
            sprite.Color = Color(1,1,1,0.1)
            sprite.PlaybackSpeed = 0.4 

            data.spark_radi = true
        end
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)
    if enthit.Type ~= EntityType.ENTITY_PLAYER
        -- and flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER then
        and flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER and entsrc.Type == monster.type and entsrc.Variant == monster.variant then 
        return false 
    end
end


return monster