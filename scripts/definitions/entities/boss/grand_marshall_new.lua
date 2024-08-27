local monster = {}
monster.name = "The Grand Marshall"
monster.type = GODMODE.registry.entities.grand_marshall.type
monster.variant = GODMODE.registry.entities.grand_marshall.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        ent.HitPoints = ent.HitPoints + math.min(1000,(GODMODE.util.get_basic_dps(ent) / 10.0) * 100)
        ent.MaxHitPoints = ent.HitPoints
    end
end

monster.set_delirium_visuals = function(self,ent)
    for i=0,5 do 
        ent:GetSprite():ReplaceSpritesheet(i,"gfx/bosses/deliriumforms/the_grand_marshall.png")
    end
    ent:GetSprite():LoadGraphics()
end

local max_vel = 1
local laser_time_range = {100, 200}
local laser_rotate_speed = 2.5
local phase_2_thres = 0.5
local phase_2_wave_safe_thres = 25
local phase_2_wave_safe_section = 180
local phase_2_pulse_offset = Vector(0,-136)
local phase_2_gridsize = 128
local phase_2_dagger_explode_time = 40
local phase_2_dagger_wait = 60

local attack_reroll_scalar = 3


local spawn_laser = function(ent, pos, angle, delay, timeout)
    local order = Isaac.Spawn(GODMODE.registry.entities.holy_order.type, GODMODE.registry.entities.holy_order.variant, math.floor(angle),pos,Vector.Zero,ent)
    local dat = GODMODE.get_ent_data(order)
    dat.fire_time = delay or 20
    dat.laser_timeout = timeout or 30
end

local spawn_dagger = function(ent, pos, angle, vel)
    local dagger = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_NORMAL, 0, pos, Vector(1,0):Rotated(angle):Resized(vel), ent):ToProjectile()
    dagger:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    dagger.FallingSpeed = 0.0
    dagger.FallingAccel = -(5.2/60.0)
    dagger.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    GODMODE.get_ent_data(dagger).marshall_blade = true 

    dagger:GetSprite():Load("gfx/proj_blade.anm2", true)
    dagger:Update()
    dagger:GetSprite():Play("Blade",true)
    dagger:GetSprite().Rotation = (dagger.Velocity:GetAngleDegrees() - 90) % 360
    dagger.ProjectileFlags = ProjectileFlags.EXPLODE

    return dagger
end

local spawn_fire = function(ent, pos, angle, vel)
    local flame = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, ProjectileVariant.PROJECTILE_FIRE, 0, pos, Vector(1,0):Rotated(angle):Resized(vel), ent):ToProjectile()
    flame:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    flame.FallingSpeed = flame.FallingSpeed * (0.9 + ent:GetDropRNG():RandomFloat()*0.2)
    flame.Height = flame.Height * (0.9 + ent:GetDropRNG():RandomFloat()*0.2)
    flame.Scale = 0.8 + 0.4 * ent:GetDropRNG():RandomFloat()
    flame:GetSprite().Scale = Vector(flame.Scale,flame.Scale)
    return flame
end


monster.projectile_update = function(self, dagger, data, sprite)
    if dagger.SpawnerEntity and dagger.SpawnerEntity.Type == monster.type and dagger.SpawnerEntity.Variant == monster.variant then 
        local marshall = dagger.SpawnerEntity:ToNPC()

        if GODMODE.room:IsPositionInRoom(dagger.Position, 0) then 
            if data.passed_room ~= true then 
                data.passed_room = true
            end
        elseif data.passed_room == true then
            if sprite:IsPlaying("Blade") then 
                sprite:Play("Impact",true)
                GODMODE.game:ShakeScreen(5)
                
                spawn_laser(dagger, dagger.Position, (marshall:GetPlayerTarget().Position - dagger.Position):GetAngleDegrees() % 360, 40, 20)

                for i=1,8 do 
                    spawn_fire(marshall, dagger.Position, sprite.Rotation-90 + dagger:GetDropRNG():RandomFloat() * 45 - 22.5, i / 2.0 + 0.5 + dagger:GetDropRNG():RandomFloat())
                end
            end

            dagger.Velocity = Vector.Zero

            data.explode_timer = (data.explode_timer or (phase_2_dagger_explode_time + 1)) - 1

            if sprite:IsEventTriggered("Explode") then 
                dagger:Remove()
                GODMODE.game:ShakeScreen(5)

                GODMODE.game:BombExplosionEffects (dagger.Position, 20)
            end

            if data.explode_timer <= 0 and not sprite:IsPlaying("Explode") then 
                sprite:Play("Explode",true)
            end
        end
    end
end

local attacks = {
    [0] = {
        { -- holy orders
            id = 0, anim = "Attack01In", anim2 = "Attack01Loop", anim3 = "Attack01Out", --dev_name = "lasers",
            start_atk_chance = -1,
            -- specific stats for this attack's variants
            laser_stats = {
                { --vertical/horizontal lasers
                    update = function(self, ent, data, sprite) 
                        data.laser_angle = (data.laser_angle + laser_rotate_speed) % 360
                    end,
                    spawn = function(self, ent, data, sprite)
                        --spawn laser
                        data.vert = not data.vert
                        local player = ent:GetPlayerTarget()
                        local ang = math.floor(((player.Position + player.Velocity * 2.5) - GODMODE.room:GetCenterPos()):GetAngleDegrees())

                        if data.vert == true then 
                            spawn_laser(ent, Vector(player.Position.X,-500), 90, self.laser_stats[data.laser_pattern].laser_delay, self.laser_stats[data.laser_pattern].laser_timeout)
                            spawn_laser(ent, Vector(-500,player.Position.Y-144), 0, self.laser_stats[data.laser_pattern].laser_delay, self.laser_stats[data.laser_pattern].laser_timeout)
                            spawn_laser(ent, Vector(-500,player.Position.Y+144), 0, self.laser_stats[data.laser_pattern].laser_delay, self.laser_stats[data.laser_pattern].laser_timeout)
                        else
                            spawn_laser(ent, Vector(-500,player.Position.Y), 0, self.laser_stats[data.laser_pattern].laser_delay, self.laser_stats[data.laser_pattern].laser_timeout)
                            spawn_laser(ent, Vector(player.Position.X-144,-500), 90, self.laser_stats[data.laser_pattern].laser_delay, math.floor(self.laser_stats[data.laser_pattern].laser_timeout * 0.5))
                            spawn_laser(ent, Vector(player.Position.X+144,-500), 90, self.laser_stats[data.laser_pattern].laser_delay, math.floor(self.laser_stats[data.laser_pattern].laser_timeout * 0.5))
                        end
                    end,

                    spawn_delay = 15,
                    laser_delay = 80,
                    laser_timeout = 10
                },
                { --laser wave!
                    update = function(self, ent, data, sprite) 
                        data.laser_angle = (data.laser_angle + math.cos(math.rad(ent.FrameCount * 8)) * laser_rotate_speed + laser_rotate_speed) % 360
                    end,
                    spawn = function(self, ent, data, sprite)
                        --spawn laser
                        spawn_laser(ent, self:get_marshall_pos(ent, data, sprite) + Vector(500,0):Rotated(data.laser_angle), data.laser_angle+180, self.laser_stats[data.laser_pattern].laser_delay, self.laser_stats[data.laser_pattern].laser_timeout)
                    end,

                    spawn_delay = 4,
                    laser_delay = 60,
                    laser_timeout = 15
                },
                { --cross laser
                    update = function(self, ent, data, sprite) 
                        data.laser_angle = (data.laser_angle + math.cos(math.rad(ent.FrameCount * 8)) * laser_rotate_speed + laser_rotate_speed) % 360
                    end,
                    spawn = function(self, ent, data, sprite)
                        --spawn laser
                        spawn_laser(ent, ent:GetPlayerTarget().Position + Vector(500,0):Rotated(data.laser_angle), data.laser_angle+180, self.laser_stats[data.laser_pattern].laser_delay, self.laser_stats[data.laser_pattern].laser_timeout)
                        spawn_laser(ent, ent:GetPlayerTarget().Position + Vector(500,0):Rotated(data.laser_angle+90), data.laser_angle+180+90, self.laser_stats[data.laser_pattern].laser_delay, self.laser_stats[data.laser_pattern].laser_timeout)
                    end,

                    spawn_delay = 20,
                    laser_delay = 50,
                    laser_timeout = 12
                },
            },

            init = function(self, ent, data, sprite) 
                local perc = (1.0 - ent.HitPoints / ent.MaxHitPoints)
                data.laser_time = laser_time_range[1] + math.floor((laser_time_range[2] - laser_time_range[1]) * perc)
                data.max_laser_time = data.laser_time
                data.laser_angle = ent:GetDropRNG():RandomInt(360)
                local pattern = ent:GetDropRNG():RandomInt(#self.laser_stats) + 1

                if data.laser_pattern ~= nil then --dont do the same pattern twice in a row
                    local depth = #self.laser_stats * 2
                    while data.laser_pattern == pattern and depth > 0 do 
                        pattern = ent:GetDropRNG():RandomInt(#self.laser_stats) + 1
                        depth = depth - 1
                    end
                end

                data.laser_pattern = pattern
            end,
            update = function(self, ent, data, sprite) 
                if (data.laser_time or 0) > 0  then 
                    data.laser_time = (data.laser_time or 0) - 1
                    self.laser_stats[data.laser_pattern or 1].update(self, ent, data, sprite)

                    if data.laser_time % self.laser_stats[data.laser_pattern].spawn_delay == 0 then 
                        self.laser_stats[data.laser_pattern or 1].spawn(self, ent, data, sprite)
                    end
                end
            end,
            is_done = function(self, ent, data, sprite) return (data.laser_time or 1) <= 0 end,
            get_marshall_pos = function(self, ent, data, sprite) 
                return GODMODE.room:GetCenterPos() + 
                Vector(1,0):Rotated(data.laser_angle or 0):Resized(64 * (1 - (data.laser_time or 0) / (data.max_laser_time or 1)))
            end 
        },
    },
    [1] = {
        { -- holy orders
            id = 0, anim = "Attack1", anim2 = "Idle1", anim3 = "Attack1", --dev_name = "lasers",
            start_atk_chance = -2,
            -- specific stats for this attack's variants
            laser_stats = {
                { --vertical/horizontal lasers PT 2
                    update = function(self, ent, data, sprite) 
                        data.laser_angle = (data.laser_angle + laser_rotate_speed) % 360
                    end,
                    spawn = function(self, ent, data, sprite)
                        --spawn laser
                        data.vert = not data.vert
                        local player = ent:GetPlayerTarget()
                        local ang = math.floor(((player.Position + player.Velocity * 2.5) - GODMODE.room:GetCenterPos()):GetAngleDegrees())

                        for i=-2,2 do 
                            if data.vert == true then 
                                spawn_laser(ent, Vector(player.Position.X+phase_2_gridsize * i,-500), 90, self.laser_stats[data.laser_pattern].laser_delay, self.laser_stats[data.laser_pattern].laser_timeout)
                            else
                                spawn_laser(ent, Vector(-500,player.Position.Y+phase_2_gridsize*i), 0, self.laser_stats[data.laser_pattern].laser_delay, self.laser_stats[data.laser_pattern].laser_timeout)
                            end
                        end
                    end,

                    spawn_delay = 15,
                    laser_delay = 60,
                    laser_timeout = 7
                },
                { --laser wave CHAOTIC!
                    update = function(self, ent, data, sprite) 
                        local add = math.cos(math.rad(ent.FrameCount * 16)) * laser_rotate_speed 
                        data.laser_angle = (data.laser_angle + laser_rotate_speed * 2 + add * 0.2) % 360
                    end,
                    spawn = function(self, ent, data, sprite)
                        --spawn laser
                        local dist_from_safe = math.min(
                            math.abs((data.laser_angle % phase_2_wave_safe_section) - data.laser_safe_space),
                            math.abs(((data.laser_angle + phase_2_wave_safe_section / 2.0) % phase_2_wave_safe_section) - data.laser_safe_space))

                        if dist_from_safe > phase_2_wave_safe_thres then 
                            spawn_laser(ent, self:get_marshall_pos(ent, data, sprite) + Vector(500,0):Rotated(data.laser_angle), data.laser_angle+180, self.laser_stats[data.laser_pattern].laser_delay, self.laser_stats[data.laser_pattern].laser_timeout)
                        end
                    end,

                    spawn_delay = 3,
                    laser_delay = 80,
                    laser_timeout = 20
                },
                { --cross laser PT 2
                    update = function(self, ent, data, sprite) 
                        data.laser_angle = (data.laser_angle + math.cos(math.rad(ent.FrameCount * 8)) * laser_rotate_speed + laser_rotate_speed) % 360
                    end,
                    spawn = function(self, ent, data, sprite)
                        --spawn laser
                        for i=-3,3 do 
                            spawn_laser(ent, (GODMODE.room:GetCenterPos() + RandomVector():Resized(ent:GetDropRNG():RandomFloat(phase_2_gridsize)):Rotated(ent:GetDropRNG():RandomFloat(360))) + Vector(500,i*phase_2_gridsize * 0.75):Rotated(data.laser_angle), data.laser_angle+180, self.laser_stats[data.laser_pattern].laser_delay, self.laser_stats[data.laser_pattern].laser_timeout)
                        end
                    end,

                    spawn_delay = 20,
                    laser_delay = 30,
                    laser_timeout = 10
                },
            },

            init = function(self, ent, data, sprite) 
                local perc = (1.0 - ent.HitPoints / ent.MaxHitPoints)
                data.laser_time = laser_time_range[1] + math.floor((laser_time_range[2] - laser_time_range[1]) * perc)
                data.max_laser_time = data.laser_time
                data.laser_angle = ent:GetDropRNG():RandomInt(360)
                local pattern = ent:GetDropRNG():RandomInt(#self.laser_stats) + 1
                data.laser_safe_space = ent:GetDropRNG():RandomFloat(phase_2_wave_safe_section)

                if data.laser_pattern ~= nil then --dont do the same pattern twice in a row
                    local depth = #self.laser_stats * 2
                    while data.laser_pattern == pattern and depth > 0 do 
                        pattern = ent:GetDropRNG():RandomInt(#self.laser_stats) + 1
                        depth = depth - 1
                    end
                end

                data.laser_pattern = pattern
            end,
            update = function(self, ent, data, sprite) 
                if (data.laser_time or 0) > 0  then 
                    data.laser_time = (data.laser_time or 0) - 1
                    self.laser_stats[data.laser_pattern or 1].update(self, ent, data, sprite)

                    if data.laser_time % self.laser_stats[data.laser_pattern].spawn_delay == 1 then 
                        self.laser_stats[data.laser_pattern or 1].spawn(self, ent, data, sprite)
                    end
                end
            end,
            is_done = function(self, ent, data, sprite) return (data.laser_time or 1) <= 0 end,
            get_marshall_pos = function(self, ent, data, sprite) 
                return GODMODE.room:GetCenterPos() + 
                Vector(1,0):Rotated(data.laser_angle or 0):Resized(64 * (1 - (data.laser_time or 0) / (data.max_laser_time or 1)))
            end 
        },
        { -- dagger projectiles
        id = 0, anim = "Attack1", anim2 = "Idle1", anim3 = "Attack1", --dev_name = "lasers",

        knife_interval = 30,
        knife_speed_thres = {12,16},
        knife_count_thres = {6,12},
        start_atk_chance = -1,
        max_knives = function(self,ent,data,sprite) 
            return self.knife_count_thres[1] + (self.knife_count_thres[2] - self.knife_count_thres[1]) * (1 - ent.HitPoints / ent.MaxHitPoints)
        end,
        knife_vel = function(self,ent,data,sprite)
            return self.knife_speed_thres[1] + (self.knife_speed_thres[2] - self.knife_speed_thres[1]) * (1 - ent.HitPoints / ent.MaxHitPoints)
        end,

        init = function(self, ent, data, sprite) 
            local perc = (1.0 - ent.HitPoints / ent.MaxHitPoints)
            data.laser_angle = ent:GetDropRNG():RandomInt(4) * 90
            data.knives_left = self.max_knives(self,ent,data,sprite)
            data.knife_explode_time = nil

        end,
        update = function(self, ent, data, sprite)
            local player = ent:GetPlayerTarget()
            
            if player then 
                if ent:IsFrame(self.knife_interval,1) and data.knives_left > 0 then 
                    local dagger = spawn_dagger(ent,
                        ent:GetPlayerTarget().Position,
                        data.laser_angle - 90,
                        self:knife_vel(ent,data,sprite))

                    dagger.Position = dagger.Position - dagger.Velocity:Resized(500)
                    GODMODE.get_ent_data(dagger).passed_room = nil

                    data.knives_left = data.knives_left - 1
                    data.laser_angle = data.laser_angle + 90
                end

                if data.knives_left <= 0 then 
                    data.knife_explode_time = (data.knife_explode_time or (phase_2_dagger_wait + 1)) - 1
                end
            end
        end,
        is_done = function(self, ent, data, sprite) return (data.knives_left or 0) <= 0 and (data.knife_explode_time or 0) <= 0 end,
        get_marshall_pos = function(self, ent, data, sprite) 
            return ent:GetPlayerTarget().Position - Vector(0,80) + 
            Vector(1,0):Rotated(ent.FrameCount * 4):Resized(32 * (1 - (data.laser_time or 0) / (data.max_laser_time or 1)))
        end 
    },
    }
}

local choose_new_atk = function(ent, data, sprite) 
    local atk_list = attacks[data.phase or 0] or attacks[0]
    local sel = function() return atk_list[ent:GetDropRNG():RandomInt(#atk_list) + 1] end
    local ret = sel()
    local depth = (#atk_list + 1) * attack_reroll_scalar
    
    while data.atk_meta ~= nil and data.atk_meta.id == ret.id and depth > 0 do 
        ret = sel()
        depth = depth - 1
    end

    data.atk_meta = ret
    data.atk_chance = data.atk_meta.start_atk_chance or -3
    data.atk_meta:init(ent, data, sprite)
    return ret 
end

local get_next_anim = function(ent, data, sprite)
    if (data.phase or 0) == 0 then 
        if ent.HitPoints / ent.MaxHitPoints <= phase_2_thres then 
            data.phase = 1
            data.phase_transition = true  
            data.atk_chance = -3
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            ent.CollisionDamage = 0

            return "Phase"
        else 
            if data.atk_meta == nil then 
                data.atk_chance = (data.atk_chance or -4) + 1
                if data.cur_anim == "Idle0" and ent:GetDropRNG():RandomFloat() < 0.0 + data.atk_chance * 0.4 then 
                    return choose_new_atk(ent,data,sprite).anim
                else 
                    return "Idle0"
                end
            else 
                return "Idle0"
            end
        end
    else
        if data.phase_transition == nil then 
            return "Phase"
        else
            if data.atk_meta == nil then 
                data.atk_chance = (data.atk_chance or -4) + 1
                if data.cur_anim == "Idle1" and ent:GetDropRNG():RandomFloat() < 0.06 + data.atk_chance * 0.33 then 
                    return choose_new_atk(ent,data,sprite).anim
                else 
                    return "Idle1"
                end    
            else
                return "Idle1"
            end
        end
    end
end

local get_target_pos = function(ent, data, sprite)
    local cur = data.cur_anim

    if data.atk_meta ~= nil and data.atk_meta.get_marshall_pos ~= nil then 
        return data.atk_meta:get_marshall_pos(ent, data, sprite)
    end

    if (data.phase or 0) == 0 then 
        return GODMODE.room:GetCenterPos()
    else 
        return (ent:GetPlayerTarget().Position) + Vector(64,64):Rotated(ent.FrameCount):Resized(math.cos(ent.FrameCount / 3.14 / 6) * 32 + 160)
    end
end

monster.npc_update = function(self, ent, data, sprite)
    local player = ent:GetPlayerTarget()

    -- animation machine
    if sprite:IsFinished((data.cur_anim or "Appear")) then
        if data.atk_meta ~= nil then --if currently in attack
            if data.atk_meta:is_done(ent, data, sprite) then 
                data.cur_anim = data.atk_meta.anim3 or nil --get outro animation if it exists
                data.atk_meta = nil -- wipe old attack
                data.cur_anim = data.cur_anim or get_next_anim(ent, data, sprite) -- if outro does not exist, select new animation
            else 
                data.cur_anim = data.atk_meta.anim2
            end
        else -- if not currently in an attack
            data.cur_anim = get_next_anim(ent, data, sprite)
        end
        
        sprite:Play(data.cur_anim, true)
    end

    -- update active attack
    if data.atk_meta ~= nil then 
        data.atk_meta:update(ent, data, sprite)
    end

    -- movement
    local targ_pos = get_target_pos(ent, data, sprite)
    local new_vel = (targ_pos - ent.Position)
    ent.Velocity = ent.Velocity * 0.75 + new_vel:Resized(math.min(new_vel:Length() / 52.0,max_vel))

    if sprite:IsEventTriggered("Pulse") then 
        GODMODE.game:MakeShockwave(ent.Position + phase_2_pulse_offset + ent.Velocity, 0.0025, 0.005, 20)
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if (enthit.Type == monster.type and enthit.Variant == monster.variant) and (enthit:GetSprite():IsPlaying("TeleportLoop") or
        flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER and entsrc.Type ~= 1) then
        return false
    end
end

return monster