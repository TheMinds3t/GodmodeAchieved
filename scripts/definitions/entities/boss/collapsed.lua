local monster = {}
--nest war
monster.name = "The Collapsed"
monster.type = GODMODE.registry.entities.the_collapsed.type
monster.variant = GODMODE.registry.entities.the_collapsed.variant

local hand_anchors = {
    Vector(128,64),
    Vector(-128,64)
}

local cam_damp = 1
local head_damp = 20
local raise_damp = 3
local raise_height = 64
local raise_deadzone = 8

local eye_offset = Vector(24,-18)
local eye2_offset = Vector(-eye_offset.X,eye_offset.Y)
local cry_threshold = 0.66
local phase2_threshold = 0.33
local phase2_health_scalar = 0.4

local raw_eye_offset = Vector(32,-18)
local raw_eye2_offset = Vector(-raw_eye_offset.X,raw_eye_offset.Y)

local lower_atk_bullet_off = Vector(0,64)
local bullet_timeout_floor = 70
local bullet_timeout_ceil = 200

local slam_time = 100
local max_hand_move_speed = 5.5
local max_hand_move_speed_idle = 14.5

local dark_matter_off = Vector(0,64)
local dark_matter_vel = Vector(0,4)
local dark_matter_life = 100

local fx_beam_step = 28
local fx_variance = Vector(0.75,0.3)

local grace_period = 100

local phase2_flags = {
    ProjectileFlags.SINE_VELOCITY,
    0,
    ProjectileFlags.WIGGLE,
}

monster.fx_beam = function(ent, pos1, pos2)
    local dist = (pos2 - pos1):Length()
    local count = dist / fx_beam_step

    for i=1, count do 
        local perc = i / count
        monster.fx(ent, pos1 * perc + pos2 * (1 - perc) + RandomVector():Resized(ent.Size * ent:GetDropRNG():RandomFloat()) * fx_variance)
    end
end

monster.fx = function(ent, pos)
    local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, pos, Vector.Zero, nil):ToEffect()
    fx:SetTimeout(10)
    fx.LifeSpan = 20
    fx.Scale = ent:GetDropRNG():RandomFloat() * 0.5 + 1.0
    fx:SetColor(Color(0,0,0,1),999,1,false,false)
    fx.DepthOffset = -100
end

monster.bullet = function(ent,pos,ang,speed,flags,mod_func)
    flags = flags == nil and 0 or flags 

    local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_NORMAL,0,ent.Position+ent.SpriteOffset+pos,
        Vector.FromAngle(ang):Resized(speed), ent)
    proj = proj:ToProjectile()
    
    proj.ProjectileFlags = proj.ProjectileFlags | flags | ProjectileFlags.NO_WALL_COLLIDE
    proj:GetSprite():ReplaceSpritesheet(0,"gfx/alt_bulletatlas_2.png")
    proj:GetSprite():LoadGraphics()
    proj.Scale = 1.5
    proj.SplatColor = Color(0,0,0,1)
    proj.FallingAccel = -0.1
    proj.FallingSpeed = 0
    GODMODE.get_ent_data(proj).cotv_bullet = true
    if mod_func then mod_func(proj) end 

    local size = math.max(1,math.min(13, math.floor(proj.Scale*12)))
    proj:GetSprite():Play("RegularTear"..size,true)
    proj:Update()

    return proj
end

monster.ring = function(ent,pos,ang,speed,count,flags,mod_func,only_below)
    for i=1,count do 
        local ang = (i * (360 / count) + ang) % 360

        if only_below == true and ang >= 0 and ang <= 180 or only_below ~= true then 
            local proj = monster.bullet(ent, pos, ang, speed, flags, mod_func)
        end
    end
end

monster.calc_ang = function(ent,off)
    return (ent:GetPlayerTarget().Position - (ent.Position + ent.SpriteOffset + off)):GetAngleDegrees()
end

monster.hand_attacks = {
    {
        init = function(ent,data,sprite) 
            data.did_raise = false 
            data.did_lower = false
            sprite:Play("HandRaise", true)
        end,
        update = function(ent,data,sprite,atk)
        end,
        fire = function(ent,data,sprite)
            monster.ring(ent, Vector.Zero, 
                monster.calc_ang(ent, Vector.Zero), 
                2 - ((GODMODE.game.Difficulty + 1) % 2) * 0.5, 
                16 - ((GODMODE.game.Difficulty + 1) % 2) * 4, ProjectileFlags.ACCELERATE, function(proj) proj.Scale = 2.0 end)

        end,
        raised = function(ent,data,sprite) 
            monster.ring(ent, Vector.Zero, 
                monster.calc_ang(ent, Vector.Zero), 
                5 - (GODMODE.game.Difficulty + 1) % 2, 
                12 - ((GODMODE.game.Difficulty + 1) % 2) * 4, 0, function(proj) proj.Scale = 1.0 end)

            data.did_raise = true
        end,
        lowered = function(ent,data,sprite) 
            monster.ring(ent, lower_atk_bullet_off, 
                monster.calc_ang(ent, lower_atk_bullet_off), 
                8 - (GODMODE.game.Difficulty + 1) % 2, 
                10 - ((GODMODE.game.Difficulty + 1) % 2) * 3, 0, function(proj) proj.Scale = 1.5 end)

            data.did_lower = true
            GODMODE.game:ShakeScreen(5)
            local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF02,1,ent.Position+lower_atk_bullet_off,Vector.Zero,nil)
            fx:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end,
        is_done = function(ent,data,sprite)
            return sprite:IsFinished("HandRaise") and sprite:GetAnimation() == "HandRaise" and data.raised == false and data.did_raise == true and data.did_lower == true
        end
    },
    {
        init = function(ent,data,sprite) 
            data.did_raise = false 
            data.did_lower = false
            data.slam_time = slam_time 
            data.hand_targ_pos = ent.Position
            sprite:Play("HandRaiseIn", true)
        end,
        update = function(ent,data,sprite,atk)
            local player = ent:GetPlayerTarget()

            if sprite:IsFinished("HandRaiseIn") then
                sprite:Play("HandRaiseLoop",true)
            end

            -- follow above player
            if sprite:IsPlaying("HandRaiseLoop") then
                data.slam_time = math.max((data.slam_time or 0) - 1, 0) 

                if data.slam_time > 0 then 
                    data.hand_targ_pos = (data.hand_targ_pos + player.Position) / 2.0
                    data.add_to_y_off = (data.add_to_y_off or 0) - 1 / 2.0
                else 
                    data.hand_targ_pos = ent.Position + ent.Velocity * 2
                    sprite:Play("HandRaiseOut",true)
                end
            end
        end,
        fire = function(ent,data,sprite)
            local flag = ent:GetDropRNG():RandomInt(2) == 1 and ProjectileFlags.CURVE_LEFT or ProjectileFlags.CURVE_RIGHT
            local flag2 = flag == ProjectileFlags.CURVE_LEFT and ProjectileFlags.CURVE_RIGHT or ProjectileFlags.CURVE_LEFT

            monster.ring(ent, Vector.Zero, 
                monster.calc_ang(ent, Vector.Zero), 
                7 - ((GODMODE.game.Difficulty + 1) % 2) * 1, 
                12 - ((GODMODE.game.Difficulty + 1) % 2) * 4, ProjectileFlags.DECELERATE | flag, function(proj) 
                    proj.Scale = 2 
                    proj.CurvingStrength = 1 / 240
                end)
            
            monster.ring(ent, Vector.Zero, 
                monster.calc_ang(ent, Vector.Zero) + 360 / 16 / 2, 
                2.5 - ((GODMODE.game.Difficulty + 1) % 2) * 0.75, 
                16 - ((GODMODE.game.Difficulty + 1) % 2) * 6, ProjectileFlags.ACCELERATE | flag2, function(proj) 
                    proj.Scale = 1.7
                    proj.CurvingStrength = 1 / 360
                end)
            
            monster.ring(ent, Vector.Zero, 
                monster.calc_ang(ent, Vector.Zero) + 360 / 16 / 2, 
                1.4 - ((GODMODE.game.Difficulty + 1) % 2) * 0.125, 
                18 - ((GODMODE.game.Difficulty + 1) % 2) * 6, ProjectileFlags.ACCELERATE | flag, function(proj) 
                    proj.Scale = 1.5 
                    proj.CurvingStrength = 1 / 360
                end)

            GODMODE.game:MakeShockwave(ent.Position, 0.065, 0.0095, 30)

            for fxi = 1, 8 do 
                local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF02,1,ent.Position+Vector(64,0):Rotated(360 / 8 * fxi),Vector.Zero,nil)
                fx:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            end
        end,
        raised = function(ent,data,sprite) 
            data.did_raise = true
        end,
        lowered = function(ent,data,sprite) 
            data.did_lower = true
            GODMODE.game:ShakeScreen(15)
        end,
        is_done = function(ent,data,sprite)
            return sprite:IsFinished("HandRaiseOut") and sprite:GetAnimation() == "HandRaiseOut" and data.raised == false and data.did_raise == true and data.did_lower == true
        end,
        get_targ_pos = function(ent,data,sprite)
            if sprite:IsPlaying("HandRaiseLoop") or sprite:IsPlaying("HandRaiseOut") and data.hand_targ_pos then
                return data.hand_targ_pos 
            end
        end
    },
    {
        init = function(ent,data,sprite) 
            sprite:Play("HandSqueeze", true)
            data.squeeze_off = 0
            data.squeeze_speed = 0
        end,
        fire = function(ent,data,sprite)
            local count = data.squeeze_speed * 2 + 14 - ((GODMODE.game.Difficulty + 1) % 2) * 4
            monster.ring(ent, Vector.Zero, 
                data.squeeze_off, 
                -data.squeeze_speed * 0.25 + 2.5 - ((GODMODE.game.Difficulty + 1) % 2) * 0.5, 
                count, ProjectileFlags.ACCELERATE, function(proj) proj.Scale = 1.0 end)
            data.squeeze_off = data.squeeze_off + 360 / count * (1 - (ent.I1 % 2) * 2)
            data.squeeze_speed = data.squeeze_speed + 1
        end,
        is_done = function(ent,data,sprite)
            return sprite:IsFinished("HandSqueeze") and sprite:GetAnimation() == "HandSqueeze"
        end
    },
    {
        init = function(ent,data,sprite) 
            sprite:Play("HandMatter", true)
        end,
        fire = function(ent,data,sprite)
            local matter = Isaac.Spawn(GODMODE.registry.entities.the_collapsed_matter.type,GODMODE.registry.entities.the_collapsed_matter.variant,GODMODE.registry.entities.the_collapsed_matter.subtype,
            ent.Position + dark_matter_off, dark_matter_vel, ent.Parent or ent)
            matter:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            matter:Update()
        end,
        is_done = function(ent,data,sprite)
            return sprite:IsFinished("HandMatter") and sprite:GetAnimation() == "HandMatter"
        end
    },
}

monster.is_phase_2_anim = function(sprite, playing)
    local func = sprite.IsFinished 
    if playing then func = sprite.IsPlaying end 
    return func(sprite,"1Transition") or func(sprite,"2CryIn") or func(sprite,"2CryOut") or func(sprite,"2CryLoop") or func(sprite,"2Idle") or (playing and monster.is_phase_2_anim(sprite) or false)
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()
    ent.SizeMulti = Vector(1,0.5)

    if data.dark_light == nil then 
        data.dark_light = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.LIGHT,0,ent.Position,Vector.Zero,ent)
        data.dark_light:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end

    if ent.SubType == 0 then 
        data.atk_cooldown = math.max(0,(data.atk_cooldown or 0)-1)
        GODMODE.game:Darken(1, 300)
        local perc = ent.HitPoints / ent.MaxHitPoints
        -- for _,hand in ipairs(data.hands) do 

        -- end    

        if sprite:IsFinished("1Idle") or sprite:IsFinished("1CryLoop") or sprite:IsFinished("1CryIn") or sprite:IsFinished("1CryOut") or sprite:IsFinished("1CryFlash") or 
            sprite:IsFinished("1Transition") or sprite:IsFinished("2CryIn") or sprite:IsFinished("2CryOut") or sprite:IsFinished("2CryLoop") or sprite:IsFinished("2Idle") then 
            if data.phase2 == true then 
                if sprite:IsFinished("1CryOut") or sprite:IsPlaying("1Idle") then 
                    sprite:Play("1Transition",true)
                elseif monster.is_phase_2_anim(sprite) then 
                    if sprite:IsFinished("2CryLoop") or sprite:IsFinished("2CryIn") then 
                        data.cry_time = data.cry_time - 1 
    
                        if data.cry_time <= 0 then 
                            sprite:Play("2CryOut",true)
                            local dir = (ent:GetDropRNG():RandomInt(2) == 1 and ProjectileFlags.CURVE_LEFT or ProjectileFlags.CURVE_RIGHT)
                            monster.ring(ent, Vector.Zero, 
                            0, 
                            1.5 - ((GODMODE.game.Difficulty + 1) % 2) * 0.5, 
                            32 - ((GODMODE.game.Difficulty + 1) % 2) * 8, dir | ProjectileFlags.ACCELERATE, function(proj) 
                                proj.Scale = 2
                                proj.CurvingStrength = 1 / 240
                            end)

                            data.phase2_flag = phase2_flags[ent:GetDropRNG():RandomInt(#phase2_flags) + 1]
                        else
                            sprite:Play("2CryLoop",true)
                            data.cry_dir = ent:GetDropRNG():RandomInt(2)
                        end
                    else
                        local atk = ent:GetDropRNG():RandomFloat()
    
                        if atk < 0.5 then 
                            sprite:Play("2CryIn",true)
                            data.cry_time = ent:GetDropRNG():RandomInt(5) + 4
                        else 
                            sprite:Play("2Idle",true)
                        end
                    end
                end
            elseif not monster.is_phase_2_anim(sprite,true) then
                if sprite:IsFinished("1CryIn") or sprite:IsFinished("1CryLoop") or sprite:IsFinished("1CryFlash") then 
                    sprite:Play("1CryLoop",true)
                else
                    if perc < cry_threshold and perc > phase2_threshold then 
                        sprite:Play("1CryIn",true)
                    else 
                        sprite:Play("1Idle",true)
                    end
                end
    
                local cry_flag = sprite:IsPlaying("1CryLoop")
    
                if perc <= phase2_threshold then 
                    
                    if data.phase2 == nil and sprite:IsPlaying("1CryLoop") then 
                        data.phase2 = true 
                        sprite:Play("1CryOut",true)
                        ent.MaxHitPoints = ent.MaxHitPoints * phase2_health_scalar
                        ent.HitPoints = ent.HitPoints * phase2_health_scalar
                    elseif sprite:IsFinished("1CryOut") or sprite:IsPlaying("1Idle") then 
                        sprite:Play("1Transition",true)
                    end
                end
    
                if data.atk_cooldown == 0 and data.phase2 ~= true and ent.FrameCount > grace_period then 
                    local atk = ent:GetDropRNG():RandomFloat()
    
                    if cry_flag and ent:GetDropRNG():RandomFloat() < 0.2 + (data.cry_chance or 0) * 0.3 then 
                        sprite:Play("1CryFlash",true)
                        data.atk_cooldown = 60
                        data.cry_dir = ent:GetDropRNG():RandomInt(2)
                        data.cry_chance = (data.cry_chance or 0) - 2
                        data.cry_speed = nil
                    else -- non crying attacks
                        if cry_flag then 
                            data.cry_chance = (data.cry_chance or 0) + 1
                        end
    
                        if atk < 0.3 then
                            if ent.I1 == 0 then 
                                ent.I1 = 3
                                ent.I2 = 4  
                                data.atk_cooldown = dark_matter_life + 75
                            else
                                ent.I1 = 3  
                            end
                        elseif atk < 0.6 then
                            local hand = ent:GetDropRNG():RandomInt(2)
                            local off_hand = ent:GetDropRNG():RandomInt(2)
                            
                            if hand == 0 and ent.I1 == 0 then 
                                if ent.I2 ~= 2 then 
                                    ent.I1 = 2
                                    ent.I2 = off_hand == 1 and 3 or 1
                                    data.atk_cooldown = slam_time + 120
                                end    
                            elseif hand == 1 and ent.I2 == 0 then 
                                if ent.I1 ~= 2 then 
                                    ent.I1 = off_hand == 1 and 3 or 1
                                    ent.I2 = 2
                                    data.atk_cooldown = slam_time + 120
                                end
                            end
                        elseif ent.I1 == 0 and ent.I2 == 0 then 
                            local var = ent:GetDropRNG():RandomInt(4)
                            ent.I1 = var % 2 == 1 and 3 or 1 
                            ent.I2 = var >= 2 and 3 or 1 
                            data.atk_cooldown = 60 + ((var > 0 and var < 3) and 50 or var == 3 and 90 or 0)
                        end    
                    end
                end    
            end
        end    

        if sprite:IsEventTriggered("Down") then
            if sprite:IsPlaying("1Transition") then 
                monster.ring(ent, Vector.Zero, 0,
                5,
                32, 0, function(proj) 
                    proj.Scale = 3
                end)
            end
        end

        if sprite:IsPlaying("1Transition") then 
            ent.HitPoints = math.min(ent.HitPoints + ent.MaxHitPoints * 0.05, ent.MaxHitPoints)
        end

        if sprite:IsEventTriggered("Fire") then
            if sprite:IsPlaying("1Transition") then 
                GODMODE.game:ShakeScreen(3)
            elseif sprite:IsPlaying("2CryLoop") then 
                local flag1 = data.cry_dir == 0 and ProjectileFlags.CURVE_LEFT or ProjectileFlags.CURVE_RIGHT
                local flag2 = flag1 == ProjectileFlags.CURVE_LEFT and ProjectileFlags.CURVE_RIGHT or ProjectileFlags.CURVE_LEFT
                local count = 12 - data.cry_time
                monster.ring(ent, raw_eye_offset, 
                    360 / count, 
                    2 - ((GODMODE.game.Difficulty + 1) % 2) * 0.5 + data.cry_time / 8.0 * 1.5, 
                    count, flag1 | ProjectileFlags.ACCELERATE | (data.phase2_flag or 0), function(proj) 
                        proj.Scale = 2
                        proj.CurvingStrength = 1 / 360
                    end, true)

                monster.ring(ent, raw_eye2_offset, 
                    -360 / count, 
                    2 - ((GODMODE.game.Difficulty + 1) % 2) * 0.5 + data.cry_time / 8.0 * 1.5, 
                    count, flag2 | ProjectileFlags.ACCELERATE | (data.phase2_flag or 0), function(proj) 
                        proj.Scale = 2
                        proj.CurvingStrength = 1 / 360
                    end, true)
            elseif sprite:IsPlaying("1CryFlash") then 
                data.cry_speed = (data.cry_speed or 1) - 1 
                local flag1 = data.cry_dir == 0 and ProjectileFlags.CURVE_LEFT or ProjectileFlags.CURVE_RIGHT
                local flag2 = flag1 == ProjectileFlags.CURVE_LEFT and ProjectileFlags.CURVE_RIGHT or ProjectileFlags.CURVE_LEFT
                
                monster.ring(ent, eye_offset, 
                    0, 
                    2 - ((GODMODE.game.Difficulty + 1) % 2) * 0.5 + data.cry_speed * 0.3, 
                    24 - ((GODMODE.game.Difficulty + 1) % 2) * 4, flag1 | ProjectileFlags.ACCELERATE, function(proj) 
                        proj.Scale = 2
                        proj.CurvingStrength = 1 / 360
                    end, true)

                monster.ring(ent, eye2_offset, 
                    0, 
                    2 - ((GODMODE.game.Difficulty + 1) % 2) * 0.5 + data.cry_speed * 0.3, 
                    24 - ((GODMODE.game.Difficulty + 1) % 2) * 4, flag2 | ProjectileFlags.ACCELERATE, function(proj) 
                        proj.Scale = 2
                        proj.CurvingStrength = 1 / 360
                    end, true)

            end
        end

        -- camera logic!
        if GODMODE.validate_rgon() and ent.FrameCount < grace_period then 
            GODMODE.room:GetCamera():SetFocusPosition(ent.Position)
        end

        local targ_pos = Vector((GODMODE.room_center or GODMODE.room:GetCenterPos()).X, (GODMODE.room_top_left or GODMODE.room:GetTopLeftPos()).Y + 80)

        targ_pos = targ_pos + Vector((player.Position.X - ent.Position.X) / 4.0, math.cos(math.rad(ent.FrameCount * 5)) * 4)

        ent.Velocity = (targ_pos - ent.Position) / head_damp

    elseif ent.SubType == GODMODE.registry.entities.the_collapsed_hand.subtype then 
        ent.FlipX = ent.I1 % 2 == 1
        ent.EntityCollisionClass = ent.SpriteOffset.Y <= -32 and EntityCollisionClass.ENTCOLL_NONE or EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        if ent.Parent ~= nil then 
            local parent = ent.Parent:ToNPC()
            local phase2_fight = monster.is_phase_2_anim(parent:GetSprite(),true)
            local targ = parent.Position + hand_anchors[ent.I1]
            local atk = ent.I1 == 1 and parent.I1 or parent.I2
            
            data.atk = data.atk or 0

            if data.atk > 0 and monster.hand_attacks[data.atk] and monster.hand_attacks[data.atk].get_targ_pos then 
                local new_targ = monster.hand_attacks[data.atk].get_targ_pos(ent,data,sprite)
                if new_targ then 
                    targ = new_targ
                end
            end

            if phase2_fight and data.atk == 0 then 
                targ = parent.Position + hand_anchors[ent.I1] * Vector(0.55,1)
            end

            local movement_vec = (targ - ent.Position)

            ent.Velocity = movement_vec:Resized(math.min(movement_vec:Length(), (data.atk == 0 and max_hand_move_speed_idle or max_hand_move_speed)))

            if parent:IsDead() then 
                ent:Kill()
            end

            ent:SetColor(parent:GetColor(), 999, 1, false, false)

            if ent.HitPoints < ent.MaxHitPoints then 
                ent.HitPoints = ent.MaxHitPoints
            end


            if atk > 0 and data.atk == 0 and not phase2_fight then 
                monster.hand_attacks[atk].init(ent,data,sprite)
                data.atk = atk
            elseif data.atk > 0 and (monster.hand_attacks[data.atk].is_done(ent,data,sprite) or phase2_fight) then 
                data.atk = 0
            end

            if phase2_fight then
                GODMODE.log(tostring(phase2_fight).." & "..tostring(data.atk).." & "..tostring(data.phase2_transition),true)

                if not sprite:IsPlaying("HandTransition") and data.phase2_transition ~= true or data.phase2_transition == true and not (sprite:GetAnimation() == "HandTransition" or sprite:GetAnimation() == "Hand2") then 
                    sprite:Play("HandTransition",true)
                    data.phase2_transition = true 
                    data.atk = 0
                elseif sprite:IsFinished("HandTransition") and data.phase2_transition == true then 
                    if not sprite:IsPlaying("Hand2") then 
                        sprite:Play("Hand2",true)
                    end
                end 
            elseif (data.atk or 0) == 0 then 
                data.raised = false 
                local anim = false 

                if not sprite:IsPlaying("HandIdle") then 
                    sprite:Play("HandIdle",true)
                    anim = true
                end 

                if anim then 
                    data.add_to_y_off = nil

                    if ent.I1 == 1 then 
                        parent.I1 = 0
                    else 
                        parent.I2 = 0
                    end
                end
            else 
                if monster.hand_attacks[data.atk].update then 
                    monster.hand_attacks[data.atk].update(ent,data,sprite,atk)
                end

                if sprite:IsEventTriggered("Fire") and monster.hand_attacks[data.atk].fire then 
                    monster.hand_attacks[data.atk].fire(ent,data,sprite,atk)
                end
            end

            -- connect the hand!
            local targ_beam = Vector((parent.Position.X + hand_anchors[ent.I1].X + ent.Position.X) / 2.0, (parent.Position.Y))
            if ent:IsFrame(2,1) then 
                monster.fx_beam(ent, ent.Position, targ_beam)
            else
                monster.fx_beam(ent, ent.Position, ent.Position + ent.SpriteOffset + Vector(0,-ent.Size))    
            end
        end

        -- raise the hand 
        if sprite:IsEventTriggered("Up") then 
            data.raised = true 
        end

        if sprite:IsEventTriggered("Down") then 
            data.raised = false 
        end

        local max_height = -raise_height + (data.add_to_y_off or 0)
        local targ_off = Vector(0, data.raised == true and max_height or 0)

        ent.SpriteOffset = Vector(0,(ent.SpriteOffset.Y * raise_damp + targ_off.Y) / (raise_damp + 1))

        if ent.SpriteOffset.Y > -raise_deadzone and (data.raised or false) == false then 
            if ent.SpriteOffset.Y ~= 0 and (data.atk or 0) > 0 and monster.hand_attacks[data.atk].lowered then 
                monster.hand_attacks[data.atk].lowered(ent,data,sprite,atk)
            end

            ent.SpriteOffset = Vector(0,0)
        elseif ent.SpriteOffset.Y < max_height + raise_deadzone and (data.raised or false) == true then 
            if ent.SpriteOffset.Y ~= max_height and (data.atk or 0) > 0 and monster.hand_attacks[data.atk].raised then 
                monster.hand_attacks[data.atk].raised(ent,data,sprite,atk)
            end
            
            ent.SpriteOffset = Vector(0,max_height)
        end

    elseif ent.SubType == GODMODE.registry.entities.the_collapsed_matter.subtype then 
        sprite:Play("DarkMatter",false)

        if ent.FrameCount > dark_matter_life then 
            GODMODE.game:ShakeScreen(20)
            local alt = ent:GetDropRNG():RandomInt(2)

            local flag1 = alt == 1 and ProjectileFlags.CURVE_LEFT or ProjectileFlags.CURVE_RIGHT
            local flag2 = alt == 1 and ProjectileFlags.CURVE_RIGHT or ProjectileFlags.CURVE_LEFT

            monster.ring(ent, Vector.Zero, 
                0, 
                8.0 - ((GODMODE.game.Difficulty + 1) % 2) * 4, 
                8, ProjectileFlags.ACCELERATE | flag1 | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT, function(proj) 
                proj.Scale = 2
                proj.CurvingStrength = 1 / 360
                proj.ChangeTimeout = 80
                proj.ChangeFlags = ProjectileFlags.FADEOUT | ProjectileFlags.NO_WALL_COLLIDE
            end)

            monster.ring(ent, Vector.Zero, 
                22.5, 
                6.0 - ((GODMODE.game.Difficulty + 1) % 2) * 3, 
                12, ProjectileFlags.ACCELERATE | flag2 | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT, function(proj) 
                proj.Scale = 2.5
                proj.CurvingStrength = 1 / 240
                proj.ChangeTimeout = 80
                proj.ChangeFlags = ProjectileFlags.FADEOUT | ProjectileFlags.NO_WALL_COLLIDE
            end)

            monster.ring(ent, Vector.Zero, 
                0, 
                4.0 - ((GODMODE.game.Difficulty + 1) % 2) * 2, 
                16, ProjectileFlags.ACCELERATE | flag1 | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT, function(proj) 
                proj.Scale = 3
                proj.CurvingStrength = 1 / 180
                proj.ChangeTimeout = 80
                proj.ChangeFlags = ProjectileFlags.FADEOUT | ProjectileFlags.NO_WALL_COLLIDE
            end)

            monster.ring(ent, Vector.Zero, 
                22.5, 
                2.0 - ((GODMODE.game.Difficulty + 1) % 2) * 0.25, 
                12, ProjectileFlags.ACCELERATE | flag2 | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT, function(proj) 
                proj.Scale = 1.75
                proj.CurvingStrength = 1 / 360
                proj.ChangeTimeout = 100
                proj.ChangeFlags = ProjectileFlags.FADEOUT | ProjectileFlags.NO_WALL_COLLIDE
            end)
            
            monster.ring(ent, Vector.Zero, 
                0, 
                1.25 - ((GODMODE.game.Difficulty + 1) % 2) * 0.25, 
                16, ProjectileFlags.ACCELERATE | flag1 | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT, function(proj) 
                proj.Scale = 1.5
                proj.CurvingStrength = 1 / 300
                proj.ChangeTimeout = 130
                proj.ChangeFlags = ProjectileFlags.FADEOUT | ProjectileFlags.NO_WALL_COLLIDE
            end)

            ent:Remove()
            data.dark_light:Remove()
            GODMODE.game:MakeShockwave(ent.Position, 0.1, 0.015, 30)
        end

        if ent:IsFrame(math.floor(dark_matter_life / 5),1) then 
            GODMODE.game:MakeShockwave(ent.Position, 0.0085, 0.01, math.floor(dark_matter_life / 5 * 0.7))
        end

        local perc = 1 - ent.FrameCount / dark_matter_life

        ent.Velocity = dark_matter_vel * math.min(1, perc)
        ent.Scale = 0.25 + perc * 0.75
        ent.SizeMulti = Vector(1,1):Resized(ent.Scale)

        monster.fx(ent, ent.Position+RandomVector():Resized(ent:GetDropRNG():RandomFloat() * ent.Size * ent.Scale) * Vector(1,1.25))

        if ent.Parent ~= nil and monster.is_phase_2_anim(ent.Parent:GetSprite(),true) then 
            ent:Remove()
        end
    end
end

monster.projectile_update = function(self, proj, data, sprite)
    if data.cotv_bullet == true then 
        if proj.FrameCount > bullet_timeout_floor and not GODMODE.util.is_in_view(proj.Position) or proj.FrameCount > bullet_timeout_ceil and proj.ProjectileFlags & ProjectileFlags.FADEOUT ~= ProjectileFlags.FADEOUT then 
            proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.FADEOUT
        end
    end
end

monster.player_collide = function(self, player, ent, player_first)
    if ent.Type == monster.type and ent.Variant == monster.variant and ent.SubType == GODMODE.registry.entities.the_collapsed_hand.subtype then 
        if ent.SpriteOffset.Y < -24 then 
            return true 
        end
    end
end

monster.npc_init = function(self,ent,data)
    -- if ent.Type == monster.type and ent.Variant == 0 then 
    --     if StageAPI ~= nil and StageAPI.Loaded and StageAPI.GetCurrentStage() ~= nil and StageAPI.GetCurrentStage().Name == "TheNest" or ent:GetDropRNG():RandomFloat() < tonumber(GODMODE.save_manager.get_config("AltHorsemanChance","0.2")) then 
    --         ent:Morph(ent.Type,monster.variant,0,-1)    
    --     end
    -- end

    if ent.SubType == 0 then 
        data.hands = {}

        for i=1,2 do 
            local hand = Isaac.Spawn(GODMODE.registry.entities.the_collapsed_hand.type,GODMODE.registry.entities.the_collapsed_hand.variant,GODMODE.registry.entities.the_collapsed_hand.subtype,
            ent.Position, Vector.Zero, ent)
            hand = hand:ToNPC()
            hand.Parent = ent
            hand.I1 = i
            table.insert(data.hands, hand)
        end
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)
	--Isaac.DebugString("Parent type: "..tostring(entsrc.Entity.Parent.Type)..", Spawner type: "..tostring(entsrc.Entity.SpawnerEntity.Type)..", Child type: "..tostring(entsrc.Entity.Child.Type)..", Child type: "..tostring(entsrc.Entity.Child.Type))
	if enthit.Type == monster.type and enthit.Variant == monster.variant then
        if enthit.Parent ~= nil and enthit.SubType == GODMODE.registry.entities.the_collapsed_hand.subtype then 
            enthit.Parent:TakeDamage(amount,flags,entsrc,countdown)
            return true
        elseif enthit.SubType == 0 and data.hands then
            local sprite = enthit:GetSprite()
            
            if sprite:IsPlaying("1Transition") or sprite:IsPlaying("1CryOut") then 
                return false 
            end
        end
	end
end

-- monster.bypass_hooks = {["npc_init"] = true}

return monster