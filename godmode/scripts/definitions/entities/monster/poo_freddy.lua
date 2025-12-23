local monster = {}
-- monster.data gets updated every callback
monster.name = "[GODMODE] Farddy"
monster.type = GODMODE.registry.entities.farddy.type
monster.variant = GODMODE.registry.entities.farddy.variant

monster.min_down_time = 15
monster.max_down_time = 30
monster.raise_speed = 1
monster.jump_tick = 0.75

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
        ent.SpriteOffset = Vector(0,0)

        if ent.I1 <= 0 then 
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            ent.Visible = true 
            sprite:Play("DigUp",true)
        end
        ent.Velocity = ent.Velocity * 0.1
        data.anchor_pos = nil
    else 

        if sprite:IsFinished("JumpStart") then 
            sprite:Play("JumpLoop",true)
        elseif sprite:GetAnimation() == "JumpLoop" then
            data.prev_vel = ent.Velocity
            ent.V1 = ent.V1 * 0.9

            ent.Velocity = ent.Velocity * 0.8 + ent.V1

            if data.prev_vel.X < 0 and ent.Velocity.X > 0 or data.prev_vel.X > 0 and ent.Velocity.X < 0 then 
                ent.V1 = Vector(-ent.V1.X,ent.V1.Y)
            end
            
            if data.prev_vel.Y < 0 and ent.Velocity.Y > 0 or data.prev_vel.Y > 0 and ent.Velocity.Y < 0 then 
                ent.V1 = Vector(ent.V1.X,-ent.V1.Y)
            end


            if data.up_vel then 
                ent.SpriteOffset = ent.SpriteOffset + Vector(0, -data.up_vel * ((1+data.jump_time)/20))
                data.up_vel = data.up_vel * 0.9 - monster.raise_speed
                data.jump_time = (data.jump_time or 0) + monster.jump_tick

                if ent.SpriteOffset.Y > -2 then 
                    data.anchor_pos = nil 
                    sprite:Play("JumpEnd",true)
                end
            end
        else
            data.anchor_pos = data.anchor_pos or ent.Position 
            ent.Velocity = (data.anchor_pos - ent.Position)
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
            ent.V1 = Vector(1,0):Rotated(ent:GetDropRNG():RandomFloat()*360):Resized(ent:GetDropRNG():RandomFloat()*3.5 + 2.5)
            data.up_vel = ent:GetDropRNG():RandomFloat()*32+64
            data.jump_time = 0
            ent.SpriteOffset = Vector(0,-3)
            sprite:Play("JumpStart",true)
        end
    end

    if sprite:IsEventTriggered("Shoot") then 
        if sprite:GetAnimation() == "Attack" then 
            GODMODE.game:ButterBeanFart(ent.Position, 82, ent, true, false)
        else -- jump attack 
            local ang = math.rad(ent:GetDropRNG():RandomFloat()*360)
            local spd = 1.5 + (GODMODE.game.Difficulty % 2) * 1.0
            local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_CORN,0,ent.Position,Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
            tear = tear:ToProjectile()
            tear.Height = -25+ent.SpriteOffset.Y * 2
            tear.FallingSpeed = 7.0+math.abs(ent.SpriteOffset.Y / 32)
            tear.FallingAccel = 1.0+ent:GetDropRNG():RandomFloat()*0.5
            tear.Scale = 0.9 + ent:GetDropRNG():RandomFloat()*0.3
            tear.ProjectileFlags = tear.ProjectileFlags
            tear.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            tear:Update()
        end
    end

    if sprite:IsEventTriggered("Roar") then 
        GODMODE.sfx:Play(SoundEffect.SOUND_WEIRD_WORM_SPIT,Options.SFXVolume*1.0+0.75)
        ent:ToNPC():PlaySound(SoundEffect.SOUND_CHILD_ANGRY_ROAR, 1.0, 1, false, 0.8 + ent:GetDropRNG():RandomFloat() * 0.25)
    end

    if sprite:IsEventTriggered("Land") then 
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE 
            ent.I1 = ent:GetDropRNG():RandomInt(monster.max_down_time - monster.min_down_time) + monster.min_down_time
            ent.Visible = false 
            ent.Position = monster.pick_safe_spot()
        ent:ToNPC():PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1.0, 1, false, 0.8 + ent:GetDropRNG():RandomFloat() * 0.2)
    end

    if sprite:IsEventTriggered("Jump") then 
        if sprite:IsPlaying("DigUp") then 
            ent:ToNPC():PlaySound(SoundEffect.SOUND_MEAT_JUMPS, 1.0, 1, false, 0.6 + ent:GetDropRNG():RandomFloat() * 0.2)
        else
            ent:ToNPC():PlaySound(SoundEffect.SOUND_FART_GURG, 1.0, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil)		
        end

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

monster.npc_kill = function(self, ent)
    GODMODE.game:ButterBeanFart(ent.Position, 82, ent, true, false)
end

monster.npc_collide = function(self,ent,ent2,entfirst)
    local anim_flag = ent2:GetSprite():IsPlaying("JumpLoop")
    if ent.Type == monster.type and ent.Variant == monster.variant then
        if ent2.Type == EntityType.ENTITY_PLAYER and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) 
            or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and GODMODE.util.is_valid_enemy(ent2) and not ent2:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
                and not (ent2.Type == ent.Type and ent2.Variant == ent.Variant and ent2.SubType > 0) then 
            if ent.SpriteOffset.Y < -10 and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then 
                return true
            else 
                if ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then 
                    ent2:TakeDamage(ent.CollisionDamage,0,EntityRef(player),0)
                end
            end
        elseif ent2.Type == ent.Type and ent2.Variant == ent.Variant and anim_flag then 
            return true
        end 
    end
end

return monster