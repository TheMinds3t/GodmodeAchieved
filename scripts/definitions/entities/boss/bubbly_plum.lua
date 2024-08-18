local monster = {}
-- monster.data gets updated every callback
monster.name = "Bubbly Plum"
monster.type = GODMODE.registry.entities.bubbly_plum.type
monster.variant = GODMODE.registry.entities.bubbly_plum.variant

local water_fx = {EffectVariant.WATER_SPLASH, EffectVariant.BIG_SPLASH}
local atks = {"Attack1","Attack4","Attack3"}
local max_charge = 150
local max_submerge = 200
local emerge_time = 10
local bubble_time = 100
local bubble_expire = 100
local item_time = 1600

local splash = function(ent,vel,pos_off)
    if vel == nil then vel = ent.Velocity * 0.2 end
    if pos_off == nil then pos_off = Vector.Zero end
    for _,fx in ipairs(water_fx) do 
        local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT,fx,0,ent.Position+pos_off,vel,ent)
        fx.DepthOffset = 100
    end

    GODMODE.sfx:Play(SoundEffect.SOUND_BOSS2INTRO_WATER_EXPLOSION,Options.SFXVolume * 2.5,1,false,1.2+ent:GetDropRNG():RandomFloat()*0.5)
    GODMODE.game:ShakeScreen(5)
end

local fire_tear = function(ent,ang,speed,scale)
    scale = scale or 0.6 + ent:GetDropRNG():RandomFloat() * 0.4
    ang = math.rad(ang)
    local vel = Vector(math.cos(ang) * speed,math.sin(ang) * speed)
    local offset = ent:GetDropRNG():RandomFloat() * 6.28
    local tear = nil 
    if ent.SubType == 1 and ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then 
        tear = Isaac.Spawn(EntityType.ENTITY_TEAR,0,0,ent.Position + vel,vel,ent)
        tear = tear:ToTear()
        tear.FallingSpeed = 0.0
        tear.FallingAcceleration = -(5.0/60.0)
        tear.Scale = scale * 0.75
        tear.CollisionDamage = ent.CollisionDamage
    else 
        tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_TEAR,0,ent.Position + vel,vel,ent)
        tear = tear:ToProjectile()
        tear.FallingSpeed = 0.0
        tear.FallingAccel = -(5.0/60.0)
        tear.Scale = scale
    end
end

local fire_bubble_tear = function(ent,ang,speed,size,timeout,i2)
    scale = scale or 1
    i2 = i2 or 0
    ang = math.rad(ang)
    local vel = Vector(math.cos(ang) * speed,math.sin(ang) * speed):Resized(speed)
    local offset = ent:GetDropRNG():RandomFloat() * 6.28
    local tear = Isaac.Spawn(monster.type,monster.variant,size,ent.Position + vel,vel,ent)
    tear:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    tear:ToNPC().I2 = i2

    if timeout ~= nil then 
        GODMODE.get_ent_data(tear).timeout = timeout
    end

    tear:Update()
end


local splash_fire = function(ent,goal,speed,count)
    local goal = ent.Position + Vector(0,1):Rotated(1):Resized(speed)
    local params = ProjectileParams()
    params.HeightModifier = -1.25
    params.FallingAccelModifier = 0.4
    params.FallingSpeedModifier = 0.4
    params.Scale = 1.0
    params.Variant = ProjectileVariant.PROJECTILE_TEAR
    params.TargetPosition = goal

    for i=1,count do 
        -- local tear = ent:FireProjectiles(ent.Position, (goal - ent.Position):Resized(speed+ent:GetDropRNG():RandomFloat()*speed):Rotated(ent:GetDropRNG():RandomFloat()*180-90), 0, params)
        local tear = ent:FireBossProjectiles(1, Vector.Zero, speed, params)
        -- tear.Height = tear.Height - 20
        -- tear.Velocity = tear.Velocity:Rotated((goal - ent.Position):GetAngleDegrees())
        -- tear.Velocity = (goal - ent.Position):Resized(speed*3)
    end
end

local creep = function(ent,size,timeout)
    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.CREEP_WHITE,0,ent.Position+RandomVector():Rotated(ent:GetDropRNG():RandomFloat()*360):Resized(ent.Size/4.0),Vector.Zero,ent)
    creep = creep:ToEffect()
    creep:SetTimeout(timeout)
    creep.Scale = size
    local color_dist = ent:GetDropRNG():RandomFloat()
    creep:SetColor(Color(1,1,1,1,-0.5+ent:GetDropRNG():RandomFloat()*0.4,-(0.25+color_dist*0.5)*0.25,-(0.25 + (0.5-color_dist*0.5))*0.25),500,99,false,false)
end

monster.npc_init = function(self, ent)
    if ent.SubType == 0 and GODMODE.validate_rgon() and GODMODE.level:GetAbsoluteStage() <= LevelStage.STAGE2_1 and GODMODE.level:GetStageType() == StageType.STAGETYPE_REPENTANCE then 
        GODMODE.room:SetWaterAmount(1.0)
    end
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()
    ent.SplatColor = Color(0.1,0.25,0.5,0.4,0.3,0.9,1.0)

    if ent.SubType == 0 then 
        if ent:HasEntityFlags(EntityFlag.FLAG_APPEAR) then 
            ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            sprite:Play("Appear",true)
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end
        
        if sprite:IsFinished("Appear") or sprite:IsFinished("Attack4") or sprite:IsFinished("Attack1") or sprite:IsFinished("Attack2Leave") or sprite:IsFinished("Attack3End") then
            sprite:Play("Idle",true)
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        end

        if ent.HitPoints == ent.MaxHitPoints then 
            ent.I1 = ent.I1 + 1

            ent.Scale = 1.0 - (ent.I1 / item_time)*0.45
            ent.SizeMulti = Vector(ent.Scale,ent.Scale)
            ent.Velocity = ent.Velocity * (ent.Scale * 0.15 + 0.85)
            
            if ent.I1 >= item_time then 
                ent:Kill()
            end
        elseif ent.Scale < 1.0 then
            ent.Scale = (1.0 + ent.Scale * 29) / 30.0

            if math.abs(ent.Scale - 1.0) < 0.0125 then 
                ent.Scale = 1.0
            end
        end


        data.submerge_time = math.max(-1,(data.submerge_time or 0)-1)
        data.charge_time = math.max(-1,(data.charge_time or 0)-1)

        if (data.submerge_time or -1) % 5 == 0 then 
            Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.WATER_RIPPLE,0,ent.Position+RandomVector():Rotated(ent:GetDropRNG():RandomFloat()*360):Resized(ent.Size/2.0),ent.Velocity * 0.5,ent)
            Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.RIPPLE_POOF,0,ent.Position+RandomVector():Rotated(ent:GetDropRNG():RandomFloat()*360):Resized(ent.Size/2.0),ent.Velocity * 0.25,ent)
            local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.BIG_SPLASH,0,ent.Position+RandomVector():Rotated(ent:GetDropRNG():RandomFloat()*360):Resized(ent.Size/2.0),ent.Velocity * 0.125,ent)
            fx:ToEffect().Scale = 0.5
            fx:ToEffect():GetSprite().Scale = Vector(0.5,0.5)
        end

        if (data.submerge_time or -1) == 0 then 
            sprite:Play("Attack2Leave",true) 
        end

        if (data.submerge_time or 0) > 0 then 
            if (data.submerge_time or 0) % 2 == 0 then 
                creep(ent,1.1,max_submerge)
            end

            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            ent.Visible = false

            if (data.submerge_time or 0) > emerge_time then 
                local dir = (player.Position - ent.Position) * (1/50.0)
                ent.Velocity = ent.Velocity * 0.88 + dir:Resized(math.max(0.5,math.min(2.0,dir:Length())))
            else 
                ent.Velocity = ent.Velocity * 0.7
            end

            if (player.Position - ent.Position):Length() < ent.Size and data.submerge_time > emerge_time then 
                data.submerge_time = emerge_time
            end
        else
            ent.Visible = true
        end

        if (data.charge_time or -1) == 0 then 
            sprite:Play("Attack3End",true) 
        end

        if sprite:IsPlaying("Attack3End") then 
            ent.Velocity = ent.Velocity * 0.85
        end

        if sprite:IsFinished("Attack2Enter") and (data.submerge_time or 0) < 0 then 
            data.submerge_time = max_submerge
        end

        if sprite:IsFinished("Attack3") then 
            data.charge_time = max_charge 
            ent.Velocity = Vector(0,1):Rotated(ent:GetDropRNG():RandomInt(4)*90+45)
            data.last_vel = ent.Velocity
        end

        data.squish_time = 20

        if (data.squish_time or 0) > 0 then
            data.squish_time = math.max(0,math.min((data.squish_time or 0)-1,20))
            ent.SpriteScale = Vector(math.cos(math.rad(ent.FrameCount*10))*data.squish_time/30+1.0,math.sin(math.rad(ent.FrameCount*10))*data.squish_time/30+1.0)
            ent.SpriteScale = Vector(math.cos(math.rad(ent.FrameCount*10))*data.squish_time/30+1.0,math.sin(math.rad(ent.FrameCount*10))*data.squish_time/30+1.0)
            -- ent.SpriteScale = Vector(math.cos(math.rad(ent.FrameCount*10))*0.5+1.0,math.sin(math.rad(ent.FrameCount*10))*0.5+1.0)
            -- sprite.PlaybackSpeed = 1.0 + data.squish_time / 40.0
        elseif sprite.PlaybackSpeed > 1 then  
            ent.SpriteScale = Vector(1,1)
            -- sprite.PlaybackSpeed = 1.0
        end


        if (data.charge_time or 0) > 0 then 
            local cur_dir = Vector(0.8,0)
            data.last_vel = data.last_vel or ent.Velocity

            if data.last_vel.X < 0 and ent.Velocity.X > 0 or data.last_vel.X > 0 and ent.Velocity.X < 0 then 
                splash(ent,Vector.Zero,-ent.Velocity*3)
                fire_bubble_tear(ent,(player.Position-ent.Position):GetAngleDegrees(),2,2)
                ent.Velocity.X = ent.Velocity.X * 10 + ent:GetDropRNG():RandomFloat() * 2.0 - 1.0
                data.squish_time = (data.squish_time or 0) + 10
            end
            if data.last_vel.Y < 0 and ent.Velocity.Y > 0 or data.last_vel.Y > 0 and ent.Velocity.Y < 0 then 
                splash(ent,Vector.Zero,-ent.Velocity*3)
                fire_bubble_tear(ent,(player.Position-ent.Position):GetAngleDegrees(),2,2)
                ent.Velocity.Y = ent.Velocity.Y * 10 + ent:GetDropRNG():RandomFloat() * 2.0 - 1.0
                data.squish_time = (data.squish_time or 0) + 10
            end

            if ent.Velocity.Y < 0 then 
                sprite:Play("Attack3Loop",false)
                cur_dir.Y = -1
            else
                sprite:Play("Attack3BackLoop",false)
                cur_dir.Y = 1
            end

            ent.FlipX = ent.Velocity.X < 0

            if ent.FlipX then 
                cur_dir.X = -0.8
            end

            if data.charge_time % 7 == 0 or data.charge_time % 6 == 0 and data.charge_time % 42 ~= 0 then 
                fire_tear(ent,cur_dir:Rotated(180):GetAngleDegrees()+ent:GetDropRNG():RandomFloat()*30-15, 3.2+ent:GetDropRNG():RandomFloat()*1.0+ent.Velocity:Length()*0.2)
                GODMODE.sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES,Options.SFXVolume * 3,1,false,2.2+ent:GetDropRNG():RandomFloat()*0.5)
            end
            
            local perc = 1.0 - (data.charge_time / max_charge)
            data.last_vel = ent.Velocity
            ent.Velocity = ent.Velocity * (0.9+perc*0.09) + cur_dir:Resized(math.min(0.9,math.max(0.1,perc)*5+0.4))
        elseif not sprite:IsPlaying("Attack3") then
            ent.FlipX = false
        end

        if sprite:IsPlaying("Idle") then 
            ent.Pathfinder:MoveRandomly(false)
            ent.Velocity = ent.Velocity * 0.95
        end

        if sprite:IsPlaying("Appear") then 
            ent.Velocity = ent.Velocity * 0.8
        end

        if sprite:IsFinished("Idle") then
            data.atk_count = (data.atk_count or 0) + 1
            
            if ent:GetDropRNG():RandomFloat() < (1.2 - data.atk_count * 0.2) then 
                sprite:Play("Idle",true)
            else
                data.last_attack = data.last_attack or "Idle"
                local cur = atks[ent:GetDropRNG():RandomInt(#atks)+1]
                local four_flag = (ent.HitPoints / ent.MaxHitPoints) < 0.5

                if four_flag and (ent:GetDropRNG():RandomFloat() < math.min(0.5,1.0 - (ent.HitPoints/ent.MaxHitPoints*2.0)) or ent.I2 ~= 1) then 
                    cur = "Attack2Enter"
                    ent.I2 = 1
                end

                while cur == data.last_attack do 
                    cur = atks[ent:GetDropRNG():RandomInt(#atks)+1]

                    if four_flag and ent:GetDropRNG():RandomFloat() < math.min(0.5,1.0 - (ent.HitPoints/ent.MaxHitPoints*2.0)) then 
                        cur = "Attack2Enter"
                    end
                end
                
                -- cur = "Attack4"
                sprite:Play(cur,true)
                sprite:LoadGraphics()

                if cur == "Attack1" then 
                    data.fire_loop = 0
                end

                data.bubble_count = 0

                if cur == "Attack3" then 
                    ent.FlipX = ent.Velocity.X < 0
                end

                data.last_attack = cur
                data.atk_count = 0
            end
        end

        if sprite:IsEventTriggered("Splash") then 
            splash(ent)

            if sprite:IsPlaying("Appear") then 
                fire_bubble_tear(ent,ent:GetDropRNG():RandomFloat()*360,2,2)

                if ent.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE then 
                    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
                elseif ent.EntityCollisionClass == EntityCollisionClass.ENTCOLL_PLAYERONLY then 
                    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
                end
            end
            
            if sprite:IsPlaying("Attack2Leave") then 
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
            end
            
            if sprite:GetFrame() <= 10 and sprite:IsPlaying("Attack2Enter") or sprite:IsPlaying("Attack2Leave") then 
                GODMODE.sfx:Play(SoundEffect.SOUND_BABY_HURT,Options.SFXVolume * 2.5,1,false,1.0+ent:GetDropRNG():RandomFloat()*0.35)
            end
        end

        if sprite:IsPlaying("Attack4") then 
            ent.Velocity = ent.Velocity * 0.5-- + (GODMODE.room:GetCenterPos() - ent.Position) * (1/20.0)
        end

        if sprite:IsPlaying("Attack1") and sprite:GetFrame() == 20 then 
            if ent.HitPoints / ent.MaxHitPoints < 0.2 then 
                if (data.fire_loop or 0) < 2 then 
                    sprite:SetFrame(4)
                end
                data.fire_loop = data.fire_loop + 1
            elseif ent.HitPoints / ent.MaxHitPoints < 0.5 then 
                if (data.fire_loop or 0) < 1 then 
                    sprite:SetFrame(4)
                end
                data.fire_loop = data.fire_loop + 1
            end
        end

        if sprite:IsEventTriggered("Shoot") then 
            if sprite:IsPlaying("Attack4") then 
                for i=1,math.max(1,math.max(1,ent:GetDropRNG():RandomInt(2)+1-math.max(0,(data.bubble_count or 0)-3))) do 
                    fire_bubble_tear(ent,ent:GetDropRNG():RandomFloat()*360,3+ent:GetDropRNG():RandomFloat()*2,2,50+ent:GetDropRNG():RandomInt(100),1)
                    data.bubble_count = (data.bubble_count or 0) + 1
                end



                -- for i=1,1 + math.max(0,2-ent:GetDropRNG():RandomInt(4)) do 
                fire_bubble_tear(ent,ent:GetDropRNG():RandomFloat()*360,3+ent:GetDropRNG():RandomFloat()*2,1,20+ent:GetDropRNG():RandomInt(40),1)
                -- end

                GODMODE.sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES,Options.SFXVolume * 2,1,false,2.2+ent:GetDropRNG():RandomFloat()*0.5)

            elseif sprite:IsPlaying("Attack1") then 
                ent.Velocity = ent.Velocity * 0.8 - Vector(0,3)
                fire_bubble_tear(ent,90,1.25,1)
                GODMODE.sfx:Play(SoundEffect.SOUND_BABY_HURT,Options.SFXVolume * 2.5,1,false,1.0+ent:GetDropRNG():RandomFloat()*0.35)
            elseif sprite:IsPlaying("Attack2Enter") or sprite:IsPlaying("Attack2Leave") then 
                if GODMODE.room:HasWater() then 
                    splash_fire(ent,player.Position,16,12)
                    splash_fire(ent,player.Position,36,12)
                else 
                    ent:Kill()
                end
            end
        end
    else --bubble code
        local anim = "Idle"..math.min(2,(ent.SubType-1)%2+1)
        if not sprite:IsPlaying(anim) then 
            sprite:Play(anim,true)
        end

        if ent.V1:Length() == 0 then 
            ent.V1 = ent.V1 or ent.Velocity
        end

        local perc = math.min(1,ent.FrameCount / bubble_time)

        if ent.SubType == 2 and ent.I2 == 0 then 
            perc = perc * 0.25
        else perc = perc * 0.6 end

        if ent.I2 == 0 or ent.SubType == 2 then 
            ent.Velocity = ent.Velocity * (0.90 + (1.5 - perc)*0.05) + (player.Position - ent.Position) * (1 / 120.0) * perc + ent.V1 * (1-perc) * (1/120)
        end
        
        if data.timeout == nil then 
            if ent.SubType >= 3 then 
                data.timeout = data.timeout or (bubble_expire+100+(ent:GetDropRNG():RandomInt(30)-15))
            else
                data.timeout = data.timeout or (bubble_expire+(ent:GetDropRNG():RandomInt(30)-15))                
            end
        end

        local perc = ent.FrameCount / (data.timeout or bubble_expire)
        local off = math.sin(perc * math.pi-math.pi)
        local max = 16
        if ent.I2 ~= 0 then
            ent.Velocity = ent.Velocity * 0.95
            max = ent.InitSeed % 32 + 48
            if ent.SubType == 2 then max = max - 32 end
        elseif ent.SubType == 2 then 
            max = ent.InitSeed % 32 + 8
        end
        
        
        ent.SpriteOffset = Vector(0,max*off+16)
        if ent.SubType >= 3 then 
            -- ent.SpriteOffset = Vector(0,max*off*0.25)
            ent.SplatColor = Color(0.1,0.25,0.1,0.4,0.1,0.9,0.1)

            if ent.FrameCount == 10 then 
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            end

            ent.Velocity = ent.Velocity * 0.9
        end

        data.last_vel = data.last_vel or ent.Velocity
        if ent.FrameCount > data.timeout then 
            ent:Kill()

            if ent.I2 ~= 0 then 
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.TEAR_POOF_A,0,ent.Position-Vector(0,8),Vector.Zero,ent)
                poof:ToEffect().Scale = 2.0
            end
        end

        ent.Scale = 0.95 + math.cos(ent.InitSeed) * 0.05

        data.last_vel = ent.Velocity
    end
end

monster.npc_remove = function(self,ent)
    if ent.Type == monster.type and ent.Variant == monster.variant then 
        if ent.SubType > 0 then 
            if ent.SubType < 3 then 
                local scale = 0.85+(3-ent.SubType)*0.33
                local time = 100+33*(3-ent.SubType)

                if ent.I2 ~= 0 then 
                    scale = scale * 1.25
                    time = math.floor(time * 2)
                    if ent.SubType == 1 then                 
                        -- GODMODE.game:BombExplosionEffects(ent.Position,0.0,0,ent.SplatColor,ent,0.666,true,false,DamageFlag.DAMAGE_FAKE)
                    end
                end

                creep(ent,scale,time)
                if ent.SubType == 1 then 
                    for i=1,8 do 
                        fire_tear(ent,360/8*i,8.0+GODMODE.game.Difficulty % 2 * 2,1.25)
                    end
                end
            else
                if ent.SubType == 3 then 
                    for i=0,6 do 
                        local off = Vector.Zero 
    
                        if i > 0 then 
                            off = Vector(1,0):Rotated(i*360/6):Resized(80)
                        end
    
                        local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.SMOKE_CLOUD,0,ent.Position+off,Vector.Zero,nil):ToEffect()
                        cloud:SetTimeout(200-ent:GetDropRNG():RandomInt(20))
                        if i == 0 then  
                            cloud.Scale = 3.0
                        end
                    end
                end
            end
        else 
            if ent:ToNPC().Scale < 1.0 then 
                Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,GODMODE.registry.items.bubble_wand,GODMODE.room:FindFreePickupSpawnPosition(ent.Position),Vector.Zero,ent)
            end

            if not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then 
                splash_fire(ent:ToNPC(),ent:ToNPC():GetPlayerTarget().Position,4,8)
                splash_fire(ent:ToNPC(),ent:ToNPC():GetPlayerTarget().Position,16,16)
                splash_fire(ent:ToNPC(),ent:ToNPC():GetPlayerTarget().Position,32,24)
                fire_bubble_tear(ent,ent:GetDropRNG():RandomFloat()*360,4,2)
                fire_bubble_tear(ent,ent:GetDropRNG():RandomFloat()*360,4,2)
                fire_bubble_tear(ent,ent:GetDropRNG():RandomFloat()*360,4,2)
                fire_bubble_tear(ent,ent:GetDropRNG():RandomFloat()*360,4,1)    
            end

            splash(ent)
            GODMODE.sfx:Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS,Options.SFXVolume * 2.5,1,false,1.2+ent:GetDropRNG():RandomFloat()*0.5)
        end

        GODMODE.sfx:Play(SoundEffect.SOUND_PESTILENCE_MAGGOT_POPOUT,Options.SFXVolume * 2.5,1,false,1.2+ent:GetDropRNG():RandomFloat()*0.5)
        GODMODE.sfx:Play(SoundEffect.SOUND_PESTILENCE_HEAD_EXPLODE,Options.SFXVolume * 2.5,1,false,1.2+ent:GetDropRNG():RandomFloat()*0.5)
    end
end

monster.npc_collide = function(self,ent,ent2,entfirst)
    local anim_flag = ent2:GetSprite():IsPlaying("Attack3Loop") or ent2:GetSprite():IsPlaying("Attack3BackLoop")
    if ent.SubType > 0 then
        if ent2.Type == EntityType.ENTITY_PLAYER and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) 
            or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and GODMODE.util.is_valid_enemy(ent2) and not ent2:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)
                and not (ent2.Type == ent.Type and ent2.Variant == ent.Variant and ent2.SubType > 0) then 
            if ent.SpriteOffset.Y < -10 and not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then 
                return true
            else 
                if ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then 
                    ent2:TakeDamage(ent.CollisionDamage,0,EntityRef(player),0)
                end

                ent:Kill()
            end
        elseif ent2.Type == ent.Type and ent2.Variant == ent.Variant and anim_flag then 
            return true
        end 
    end

    if ent.SubType == 0 and ent:GetSprite():IsPlaying("Attack4") then return false end
end

monster.knife_collide = function(self,knife,ent,entfirst)
    if ent.SubType == 0 then    
        ent:Remove()
    else
        ent:Kill()
    end
end

monster.tear_collide = function(self,tear,ent,entfirst)
    if entfirst == true then
        if (ent:GetSprite():IsPlaying("Attack3Loop") or ent:GetSprite():IsPlaying("Attack3BackLoop")) then 
            ent.Velocity = ent.Velocity * 0.8 + tear.Velocity*0.125*tear.Scale
            GODMODE.get_ent_data(ent).last_vel = ent.Velocity
            GODMODE.get_ent_data(ent).squish_time = GODMODE.get_ent_data(ent).squish_time + 5                
        end

        if tear.Variant == TearVariant.NAIL or tear.Variant == TearVariant.NAIL_BLOOD or tear.Variant == TearVariant.KEY or tear.Variant == TearVariant.KEY_BLOOD then
            if ent.SubType == 0 then    
                ent:Remove()
            else
                ent:Kill()
            end
        end
    end
end

return monster