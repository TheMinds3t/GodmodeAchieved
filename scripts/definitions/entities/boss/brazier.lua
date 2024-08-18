local monster = {}
monster.name = "Brazier (Poky)"
monster.type = GODMODE.registry.entities.brazier.type
monster.variant = GODMODE.registry.entities.brazier.variant

local eye_positions = {Vector(-19,-44),Vector(18,-44)}
local off2 = Vector(0,6)
local eye_off = 3.5

local body_playback_mod = 0.95
local heat_color = Color(1,0.8,0.01,1,0.4,0.2,0)
local overheat_color = Color(1,0.4,0.01,1,2,0.6,0)
local megacharge_color = Color(1,0.1,0.01,1,4,0.3,0)

local fireball_color = Color(1,1,1,1,1,0.3,0)
local fireball_spread = 60

local fireproj_spread_mod = 10
local num_fireproj = 1

local num_rocks = 24

local max_charge = 40
local min_charge = -60

monster.fireball = function(ent,player,pos,speed)
    speed = speed or 5
    local params = ProjectileParams()
    params.BulletFlags = ProjectileFlags.FIRE_WAVE-- | ProjectileFlags.EXPLODE
    params.Scale = 1.5
    params.Color = fireball_color
    params.PositionOffset = pos + Vector(0,32)
    params.TargetPosition = ent.Position+(player.Position - ent.Position):Resized(64)
    params.FallingAccelModifier = 0.05
    local proj = ent:FireBossProjectiles(1,player.Position,5,params)
    -- proj.Position = ent.Position+pos 
    proj.Velocity = (player.Position - (ent.Position+pos)):Resized(proj.Velocity:Length()*0.6+speed):Rotated(-fireball_spread/2+ent:GetDropRNG():RandomFloat()*fireball_spread/2)
    proj.Height = proj.Height
    proj.Scale = 2
    -- proj.Acceleration = 0.1
    proj.DepthOffset = 60
    proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

    
    if true then--ent:IsFrame(10,1) then 
        local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_JET,0,ent.Position+params.PositionOffset+Vector(0,proj.Height),Vector.Zero,ent)
        fx:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        fx.DepthOffset = 60
    end
end

monster.fireproj = function(ent,player,pos,speed,color,scale_mod,variant)
    speed = speed or 5
    local params = ProjectileParams()
    -- params.BulletFlags = ProjectileFlags.BOUNCE_FLOOR-- | ProjectileFlags.EXPLODE
    params.Scale = (scale_mod or 1) * (0.9+ent:GetDropRNG():RandomFloat()*0.5)
    params.Color = color or fireball_color
    params.PositionOffset = pos + Vector(0,32)
    params.TargetPosition = ent.Position+(player.Position - ent.Position):Resized(64)
    params.FallingAccelModifier = 0.05
    params.Variant = variant or 0
    local proj = ent:FireBossProjectiles(1,player.Position,5,params)
    -- proj.Position = ent.Position+pos 
    proj.Velocity = (player.Position - (ent.Position+pos)):Resized(proj.Velocity:Length()*0.6+speed):Rotated(ent:GetDropRNG():RandomFloat()*speed*fireproj_spread_mod*2-speed*fireproj_spread_mod)
    proj.Height = proj.Height
    -- proj.Acceleration = 0.1
    proj.DepthOffset = 60
    proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS


    return proj
end

monster.rockproj = function(ent,pos,speed)
    speed = speed or 5
    local params = ProjectileParams()
    -- params.BulletFlags = ProjectileFlags.BOUNCE_FLOOR-- | ProjectileFlags.EXPLODE
    params.Scale = 0.4+ent:GetDropRNG():RandomFloat()
    -- params.Color = fireball_color
    params.PositionOffset = pos
    params.FallingAccelModifier = 0.05
    params.Variant = ProjectileVariant.PROJECTILE_ROCK
    local proj = ent:FireBossProjectiles(1,RandomVector(),5,params)
    -- proj.Position = ent.Position+pos 
    proj.Velocity = Vector(1,0):Resized(proj.Velocity:Length()):Rotated((ent:GetPlayerTarget().Position - ent.Position):GetAngleDegrees() - 135 + ent:GetDropRNG():RandomFloat()*270)
    proj.Height = proj.Height
    -- proj.Acceleration = 0.1
    proj.DepthOffset = 60
    proj.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
end

monster.fire_ring = function(ent)
    for l=0,1 do 
        for i=0,7 do
            local spd = 7 - l * 3
            local f = math.rad(45 * i + l * 22.5)
            local ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
            local t = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,2,0,ent.Position + ang,ang,ent)
            t = t:ToProjectile()
            -- t.ProjectileFlags = flags
            -- t.CurvingStrength = 1/150.0
            t.FallingAccel = (-5.8/60.0)
            t.Acceleration = 5.0
            t.FallingSpeed = 1
            t.Height = -18
            -- t.Scale = 2.0
            -- t:SetColor(Color(0.2,0,0.2,1.25,0.4,0,0.6),999,99,false,false)
            t.SpriteOffset = Vector(0,16)
        end    
    end
end

monster.sel_attack = function(ent,data)
    local perc = ent.HitPoints / ent.MaxHitPoints
        
    if ent:GetDropRNG():RandomFloat() < 0.5 and perc < 0.75 then 
        return "EyeFire"
    else
        return "EyeSpew"
    end
end

monster.npc_init = function(self,ent)
    ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    ent:Update()
    ent:GetSprite():Play("Eye",true)
end

monster.npc_kill = function(self,ent)
    if ent.SubType == 0 then 
        ent:Remove()
        local corpse = Isaac.Spawn(monster.type,monster.variant,1,ent.Position,ent.Velocity*2,ent)
        for i=1, num_rocks/2 do 
            monster.rockproj(ent:ToNPC(),RandomVector():Resized(ent:GetDropRNG():RandomFloat()*ent.Size),5+ent:GetDropRNG():RandomFloat())
        end
        -- monster.fire_ring(ent)

        GODMODE.game:ShakeScreen(35)
    end
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	

    if ent.SubType == 1 then sprite:Play("Dead",false) ent.Velocity = ent.Velocity * 0.7 return end

    local player = ent:GetPlayerTarget()
    local perc = ent.HitPoints / ent.MaxHitPoints

    if not data.second_sprite then 
        ent.I2 = min_charge
    elseif (data.shake_counter or 0) > 0 then 
        data.shake_counter = math.max((data.shake_counter or 0) - 1,0)
        local counter_rad = math.rad((data.shake_counter or 0)*18*4)
        data.second_sprite.Scale = Vector(1,1) + Vector(math.cos(counter_rad),math.sin(counter_rad)):Resized(data.shake_counter / 20.0) * 0.065
    end

    if sprite:IsFinished("EyeSpew") or sprite:IsFinished("EyeFire") or sprite:IsFinished("Eye") then 
        if ent:GetDropRNG():RandomFloat() < -0.1 + ent.I1 * 0.05 and ent.I2 < min_charge / 2 and perc < 1.0 and perc > 0.25 then 
            local atk = monster.sel_attack(ent,data)
            local depth = 3

            while atk ~= nil and atk == data.last_attack and depth > 0 do 
                atk = monster.sel_attack(ent,data)
                depth = depth - 1
            end

            ent.I1 = 0

            if atk == "EyeSpew" then 
                ent.I2 = max_charge
            else
                ent.I2 = 0
            end

            sprite:Play(atk,true)
            data.last_attack = atk
        else
            sprite:Play("Eye",true)
        end

        ent.I1 = ent.I1 + 1
    end

    if sprite:IsPlaying("EyeFire") then 
        if data.second_sprite then 
            data.second_sprite.PlaybackSpeed = math.max(0.1,data.second_sprite.PlaybackSpeed * body_playback_mod)
            if sprite:IsEventTriggered("Fire") then
                ent:SetColor(Color.Lerp(ent:GetColor(),overheat_color,0.5),999,1,true,false)
                data.second_sprite.PlaybackSpeed = 3.5
            end    
        end

        ent:SetColor(Color.Lerp(ent:GetColor(),heat_color,0.25),999,1,true,false)

        if sprite:IsEventTriggered("Fire") and player ~= nil then
            for ind,pos in ipairs(eye_positions) do 
                local eye_pos = pos+(player.Position - (ent.Position+pos)):Resized(eye_off)         
                monster.fireball(ent,player,eye_pos,5)
            end
        end

        ent.Velocity = ent.Velocity * 0.8
    elseif ent.FrameCount > 40 then --idle / spew
        if sprite:IsPlaying("EyeSpew") then 

            ent.Velocity = ent.Velocity * 0.75
            ent:SetColor(Color.Lerp(ent:GetColor(),heat_color,0.6),999,1,true,false)

            if sprite:IsEventTriggered("Fire") then
                data.fireball_time = (data.fireball_time or 0) + 10

                for ind,pos in ipairs(eye_positions) do 
                    local eye_pos = pos+(player.Position - (ent.Position+pos)):Resized(eye_off)         

                    for i=1, num_fireproj do 
                        if ent:IsFrame(2,1) then 
                            monster.fireproj(ent,player,eye_pos,4+ent:GetDropRNG():RandomFloat()*2)
                        end
                        local proj = monster.fireproj(ent,player,eye_pos,1.0+ent:GetDropRNG():RandomFloat()*3)
                        proj.Scale = proj.Scale * 0.75
                        proj:SetColor(Color.Lerp(fireball_color,Color(0.9,0,0,1,0.8,0.1,0),ent:GetDropRNG():RandomFloat()),999,1,false,false)
                    end
                end
            end
        end

        if (data.fireball_time or 0) > 0 then
            -- if player and ent:IsFrame(math.max(1,6-math.floor(data.fireball_time / 10)),1) then  
            --     for ind,pos in ipairs(eye_positions) do 
            --         local eye_pos = pos+(player.Position - (ent.Position+pos)):Resized(eye_off)         
            --         ent:SetColor(Color.Lerp(ent:GetColor(),heat_color,0.6),999,1,true,false)
            --         local proj = monster.fireproj(ent,player,eye_pos,3+ent:GetDropRNG():RandomFloat()*5,,0.4,2)
            --         -- proj:ChangeVariant(2)
            --         proj:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)
            --     end
            -- end

            data.fireball_time = data.fireball_time - 1
        end

        if data.second_sprite then 
            data.second_sprite.PlaybackSpeed = math.max(1,data.second_sprite.PlaybackSpeed * body_playback_mod)
        end

        ent:SetColor(Color.Lerp(ent:GetColor(),Color(1,1,1,1),0.3),999,1,true,false)
        local in_bounds_flag = math.abs(player.Position.X - ent.Position.X) < ent.Size or math.abs(player.Position.Y - ent.Position.Y) < ent.Size
        
        if data.vert == nil or ent:IsFrame(20,1) or in_bounds_flag then 
            data.vert = math.abs(player.Position.Y - ent.Position.Y)*2 > math.abs(player.Position.X - ent.Position.X) 
        end

        local vert = data.vert 
        local move_mask = Vector(0,0)

        if vert then 
            move_mask = Vector(0,1)
        else 
            move_mask = Vector(1,0)
        end

        if in_bounds_flag then 
            if ent.I2 == min_charge then 
                ent.I2 = max_charge
                ent.V1 = move_mask
                ent.V2 = (player.Position - ent.Position)
            end
        end
        local rage_move_scale = 1

        if ent.I2 > 0 then 
            local scale = 3.0

            if perc <= 0.25 then 
                ent:SetColor(Color.Lerp(ent:GetColor(),megacharge_color,0.1),999,1,true,false)
                scale = 2.5 
                rage_move_scale = 1.5
            end 

            local move_perc = (ent.I2 / (max_charge * 0.9))*scale
            move_mask = ent.V1 * Vector(-1,-1)*(move_perc-scale*0.95)*3
            
            if ent.I2 < max_charge * 0.6 then 
                -- GODMODE.log("BREAKING!",true)
                local flag = false 
                for i=1,16 do 
                    local grid = GODMODE.room:GetGridEntityFromPos(ent.Position+Vector(1,0):Resized(ent.Size+20):Rotated(22.5*i+45))
                    
                    if grid ~= nil then 
                        -- GODMODE.log("breaking state = "..grid.State,true)

                        if (grid:ToRock() or grid:ToPoop()) and grid.State == 1 then 
                            grid:Destroy()
                            flag = true 
                        end
                    end
                end    
                
                if flag then 
                    ent.I2 = 0
                end
            end
        elseif ent:IsFrame(10,1) then
            ent.V2 = (player.Position - ent.Position)
        end

        if GODMODE.room:IsPositionInRoom(ent.Position+ent.Velocity,54) then 
            ent.Velocity = ent.Velocity * 0.75 + ent.V2:Resized(rage_move_scale)*move_mask

            if ent.I2 > 0 and ent.I2 < max_charge * 0.5 then 
                local shadow = Isaac.Spawn(GODMODE.registry.entities.player_trail_fx.type, GODMODE.registry.entities.player_trail_fx.variant, 0, ent.Position, Vector.Zero, ent):ToEffect()
                shadow.State = 5
                GODMODE.get_ent_data(shadow).far_color = Color(0,0,0,0.2,0,0,0)
                shadow:Update()
                shadow:GetSprite():Load(data.second_sprite:GetFilename(),true)
                local sprite = 4 - math.floor(ent.HitPoints/ent.MaxHitPoints*4)
                shadow:GetSprite():SetFrame("Idle"..sprite,data.second_sprite:GetFrame())
                shadow.DepthOffset = -100
            end

        elseif ent.I2 < max_charge * 0.7 then
            -- GODMODE.log("not in room",true)
            for i=1, num_rocks/5 do 
                monster.rockproj(ent:ToNPC(),RandomVector():Resized(ent:GetDropRNG():RandomFloat()*ent.Size),10+ent:GetDropRNG():RandomFloat())
            end

            if perc <= 0.25 and ent.I2 > 0 then 
                scale = 4.0 
                ent.I2 = min_charge/4
                monster.fire_ring(ent)
                GODMODE.game:ShakeScreen(5)
                ent:SetColor(Color.Lerp(ent:GetColor(),megacharge_color,0.75),999,1,true,false)
            else 
                ent:SetColor(Color.Lerp(ent:GetColor(),overheat_color,0.5),999,1,true,false)
                GODMODE.game:ShakeScreen(3)
            end

            GODMODE.game:MakeShockwave(ent.Position, 0.0125, 0.01, 15)
            ent.I2 = ent.I2 - 10
            data.shake_counter = 20

            ent.Velocity = ent.Velocity * 0.5 - ent.V2:Resized(0.25)*move_mask
        end
    end

    ent.I2 = math.max(min_charge,ent.I2 - 1)

    if data.second_sprite then 
        local sprite = 4 - math.floor(ent.HitPoints/ent.MaxHitPoints*4)
        data.second_sprite:Play("Idle"..sprite,false)
        data.second_sprite:Update()

        if data.second_sprite:IsFinished("Idle"..sprite) or data.second_sprite:IsFinished("Idle"..(sprite-1)) and data.second_sprite:GetAnimation() == "Idle"..(sprite-1) then 
            data.second_sprite:Play("Idle"..sprite,true)
        end
    end
end

monster.npc_collide = function(self,ent,ent2,entfirst)
    if ent.Type == monster.type and ent.Variant == monster.variant and ent2.Type == GODMODE.registry.entities.dynamite_rock.type and ent2.Variant == GODMODE.registry.entities.dynamite_rock.variant then 
		ent = ent:ToNPC()
        if ent.I2 > 0 and ent.I2 < max_charge * 0.8 then 
            GODMODE.game:BombExplosionEffects(ent2.Position, 20.0, 0, Color(1.0,1.0,1.0,1.0,0,0,0), ent2, 1.0, false, true)--Isaac.Explode(ent.Position, ent, 40.0)
            ent2:Remove()
            ent:TakeDamage(ent.MaxHitPoints / 4.0,DamageFlag.DAMAGE_EXPLOSION,EntityRef(ent),0)
        end
    end
end

monster.npc_post_render = function(self,ent,offset)
    if ent.SubType == 1 then return end
    local data = GODMODE.get_ent_data(ent)

    if data.second_sprite == nil then 
        data.second_sprite = Sprite()
        data.second_sprite:Load(ent:GetSprite():GetFilename(),true)
    end

    data.second_sprite.Offset = ent.SpriteOffset
    data.second_sprite.Color = Color.Lerp(Color(1,1,1,1),ent:GetSprite().Color,0.5)

    for ind,pos in ipairs(eye_positions) do 
        local eye_pos = ent.Position + pos

        if ent:GetPlayerTarget() ~= nil then
            local ang = (ent:GetPlayerTarget().Position - (eye_pos)):Resized(eye_off) 

            eye_pos = eye_pos + ang
        end

        ent:GetSprite():Render(Isaac.WorldToScreen(eye_pos+off2))
    end

    data.second_sprite:Render(Isaac.WorldToScreen(ent.Position+off2))
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)

    if (enthit.Type == monster.type and enthit.Variant == monster.variant) then

        if ((flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION)) then 
            if not (entsrc.Type == monster.type and entsrc.Variant == monster.variant) and enthit.SubType == 0 then 
                return false
            else
                if enthit.SubType == 1 then 
                    if enthit.FrameCount >= 20 then 
                        enthit:Kill()
                    else
                        return false 
                    end
                end

                for i=1, num_rocks do 
                    monster.rockproj(enthit:ToNPC(),RandomVector():Resized(enthit:GetDropRNG():RandomFloat()*enthit.Size),10+enthit:GetDropRNG():RandomFloat())
                end

                enthit:SetColor(Color.Lerp(enthit:GetColor(),overheat_color,1),999,1,true,false)
                GODMODE.game:ShakeScreen(25)
            end
        else 
            return false
        end
    end
end

return monster