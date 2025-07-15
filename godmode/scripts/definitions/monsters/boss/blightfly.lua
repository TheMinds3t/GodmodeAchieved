local monster = {}
-- monster.data gets updated every callback
monster.name = "Blightfly"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

-- monster.set_delirium_visuals = function(self,ent)
-- 	ent:GetSprite():ReplaceSpritesheet(0,"gfx/bosses/deliriumforms/gimmimick.png")
--     for i=3,6 do 
--         ent:GetSprite():ReplaceSpritesheet(i,"gfx/bosses/deliriumforms/gimmimick.png")
--     end
--     ent:GetSprite():LoadGraphics()
-- end

local head_offset = function(ent) 
    local ret = Vector(0,-36)
    
    return ret
end

local dash_window = 26

local atks = {"DigIn","Shoot","Summon"}
local sel_attack = function(data,ent)
    data.summon_cache = data.summon_cache or 0
    if data.last_atk == nil then 
        return "DigIn"
    elseif ent.FrameCount > 100 and ent:GetDropRNG():RandomFloat() < (0.45 - (data.summon_cache or 0)*0.15) and data.last_atk ~= "Summon" then 
        return "Summon"
    else
        local new = atks[ent:GetDropRNG():RandomInt(#atks)+1]

        if new == "Summon" and data.summon_cache >= 3 then 
            return "Shoot"
        end

        local depth = 10
        while data.last_atk == new and depth > 0 do 
            new = atks[ent:GetDropRNG():RandomInt(#atks)+1]
            depth = depth - 1

            if new == "Summon" and data.summon_cache >= 3 then 
                return "Shoot"
            end    
        end

        return new 
    end
end

local atks = {"Fire","Plant","IntoCharge","MegaPlant","Spin"}
local sel_atk = function(ent,data)
    local ret = atks[ent:GetDropRNG():RandomInt(#atks)+1]
    local perc = ent.HitPoints / ent.MaxHitPoints 
    if data.last_atk == nil then 

        if ret == "MegaPlant" and perc > 0.5 then 
            if (data.wrm_cache or 0) <= 10 then 
                return "Plant"
            else 
                return "Fire"
            end
        elseif ret == "Spin" and perc > 0.75 then 
            return -1
        else
            return ret 
        end
    else
        while ret == data.last_atk do 
            ret = atks[ent:GetDropRNG():RandomInt(#atks)+1]
        end

        if ret == "MegaPlant" and perc > 0.5 then 
            if (data.wrm_cache or 0) <= 10 then 
                return "Plant"
            else 
                return "Fire"
            end
        elseif ret == "Spin" and perc > 0.75 then 
            return -1
        else
            return ret 
        end
    end
end

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()

    if ent:GetSprite():IsEventTriggered("Attack") or ent:GetSprite():IsFinished("Idle") or ent:GetSprite():IsFinished("Fire") or ent:GetSprite():IsFinished("Plant") or ent:GetSprite():IsFinished("OutOfCharge") 
        or ent:GetSprite():IsFinished("MegaPlant") or ent:GetSprite():IsFinished("Spin") then 
        if ent:GetDropRNG():RandomFloat() < ent.I1 * 0.25 then 
            ent.I1 = 0
            local atk = sel_atk(ent,data)
            while atk == -1 do 
                atk = sel_atk(ent,data)
            end
            -- atk = "Spin" --dbug
            if not SFXManager():IsPlaying(SoundEffect.SOUND_INSECT_SWARM_LOOP) then
                SFXManager():Play(SoundEffect.SOUND_INSECT_SWARM_LOOP,1.0+Options.SFXVolume*0.5)
            end
        
            if atk == "IntoCharge" then 
                ent.FlipX = player.Position.X < ent.Position.X
                ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS_Y
                ent.I2 = 3+4 - math.floor(ent.HitPoints / ent.MaxHitPoints * 4)
                data.reposition = dash_window - 1
            end

            if atk == "MegaPlant" then 
                data.creepoff = 0
            end

            data.last_atk = atk

            ent:GetSprite():Play(atk,true)
        else
            ent.I1 = ent.I1 + 1
            if ent:GetSprite():IsPlaying("Idle") then 
                ent:GetSprite():Play("Idle",false)
            else
                ent:GetSprite():Play("Idle",true)
            end

            ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        end
    end


    if ent:GetSprite():IsFinished("IntoCharge") then 
        ent:GetSprite():Play("Charge",true)
    end

    if ent:GetSprite():IsPlaying("OutOfCharge") or ent:GetSprite():IsPlaying("Fire") or ent:GetSprite():IsPlaying("Plant") or ent:GetSprite():IsPlaying("MegaPlant") then 
        ent.Velocity = ent.Velocity * 0.9
    end

    if ent:GetSprite():IsPlaying("Idle") then 
        ent.Velocity = ent.Velocity * 0.95
        ent.Pathfinder:MoveRandomlyBoss(true)
        ent.SizeMulti = Vector(1.0,1.0)
    end

    if ent:GetSprite():IsPlaying("Charge") then 
        local flip = 1
        if ent.FlipX then flip = -1 end 
        ent.SizeMulti = Vector(1.3,0.65)
        
        if data.in_wall == nil or data.in_wall == false then 
            ent.Velocity = ent.Velocity * 0.5 + Vector(13*flip,(player.Position-ent.Position):Resized(5).Y)

            if ent.FrameCount % 2 == 0 and ent.I2 >= 0 and ent.Velocity:Length() > 10 then 
                local ang = math.rad((player.Position-(ent.Position+head_offset(ent))):GetAngleDegrees())
                local spd = 8.0 + (Game().Difficulty % 2) * 4.0
                local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_PUKE,0,ent.Position+head_offset(ent),ent.Velocity:Rotated(ent:GetDropRNG():RandomFloat()*50-25) * (0.125+ent:GetDropRNG():RandomFloat()*0.05),ent)
                tear = tear:ToProjectile()
                tear.Height = -20
                tear.FallingSpeed = 0.0
                tear.FallingAccel = -(4.8/60.0)
                tear.Scale = 1.0+ent:GetDropRNG():RandomFloat()*0.1
                tear.CollisionDamage = 2.0
                tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.DECELERATE 
                SFXManager():Play(SoundEffect.SOUND_TEARS_FIRE,Options.SFXVolume*1.0+0.75)    
            end

            if ent.I2 <= 0 and (Game():GetRoom():GetCenterPos() - ent.Position):Length() < 160 then 
                ent.Velocity = ent.Velocity * 0.7
                ent:GetSprite():Play("OutOfCharge",true)
            end

            ent.Visible = true
            data.charge_fx = 1
        else 
            data.reposition = (data.reposition or dash_window) - 1 

            if data.reposition == dash_window - 1 then 
                ent.FlipX = not ent.FlipX
                SFXManager():Play(SoundEffect.SOUND_MAGGOT_ENTER_GROUND,Options.SFXVolume*1.5+0.75)
                data.charge_fx = 1
            end

            if data.reposition == 0 then 
                ent.Velocity = Vector(30*flip,0)
                ent.Position = ent.Position - Vector(30*flip,0)
                ent.I2 = ent.I2 - 1
                data.reposition = dash_window + 1
            else 
                if ent.Velocity:Length() > 0.1 and data.reposition > 0 and data.charge_fx == 1 then 
                    --spawn fx
                    Game():ShakeScreen(15)
                    local back = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.BLOOD_EXPLOSION,4,ent.Position-Vector(0,ent.Size / 2.0),Vector.Zero,ent):ToEffect()
                    local fore = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF02,4,ent.Position+Vector(0,ent.Size / 2.0),Vector.Zero,ent):ToEffect()
                    fore.DepthOffset = 100
                    SFXManager():Play(SoundEffect.SOUND_MAGGOT_BURST_OUT,Options.SFXVolume*1.5+0.75)
                    local stage = Game():GetLevel():GetStage()
                    if stage ~= LevelStage.STAGE4_1 then 
                        back:SetColor(Color(0.3,0.1,0.1,1.0,0.0,0.1,0.1),999,1,false,false)
                        fore:SetColor(Color(0.3,0.1,0.1,1.0,0.0,0.1,0.1),999,1,false,false)
                    elseif Game():GetLevel():GetStageType() == StageType.STAGETYPE_REPENTANCE then 
                        back:SetColor(Color(0.5,0.25,0.1,1.0,0.0,0.3,0.1),999,1,false,false)
                        fore:SetColor(Color(0.5,0.25,0.1,1.0,0.0,0.3,0.1),999,1,false,false)
                    end

                    data.charge_fx = 0
                end
                
                if data.reposition > 1 then 
                    ent.Visible = false
                    ent.Velocity = Vector.Zero
                    data.charge_fx = 1
                end
            end
        end

        data.in_wall = not Game():GetRoom():IsPositionInRoom(ent.Position,0.0)

        if data.in_wall == true and not (ent.Position.X > Game():GetRoom():GetCenterPos().X and not ent.FlipX or ent.Position.X < Game():GetRoom():GetCenterPos().X and ent.FlipX) then 
            data.in_wall = false 
        end
    end
    
    if ent:GetSprite():IsPlaying("Spin") then 
        ent.Velocity = ent.Velocity * 0.95 + (Game():GetRoom():GetCenterPos() - ent.Position) * (1 / 300.0)
    end

    if ent:GetSprite():IsEventTriggered("MoveR") then 
        ent.Velocity = ent.Velocity + Vector(5,0)
        data.move_fire = Vector(1,0)
    end

    if ent:GetSprite():IsEventTriggered("MoveL") then 
        ent.Velocity = ent.Velocity - Vector(5,0)
        data.move_fire = Vector(1,0):Rotated(180)
    end

    if SFXManager():IsPlaying(SoundEffect.SOUND_INSECT_SWARM_LOOP) then
        SFXManager():Play(SoundEffect.SOUND_INSECT_SWARM_LOOP,Options.SFXVolume*1.0+0.75,0,true)    
    end

    if ent:GetSprite():IsEventTriggered("Spawn") then 
        if ent:GetSprite():IsPlaying("Spin") then 
            SFXManager():Play(SoundEffect.SOUND_BOSS_LITE_HISS,Options.SFXVolume*1.0+0.75)    
        elseif ent:GetSprite():IsPlaying("IntoCharge") then 
            SFXManager():Play(SoundEffect.SOUND_BOSS_LITE_ROAR,Options.SFXVolume*1.0+0.75)    
        else
            SFXManager():Play(SoundEffect.SOUND_GASCAN_POUR,Options.SFXVolume*1.0+0.75)    
            local tear_count = 20 - math.floor(ent.HitPoints / ent.MaxHitPoints * 8)
            for i=0, tear_count do 
                local ang = math.rad(360/tear_count*i+ent:GetDropRNG():RandomFloat()*(360/tear_count*0.75))
                local spd = (1.0 + (Game().Difficulty % 2)*1)+ent:GetDropRNG():RandomFloat()*5.0
                local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_PUKE,0,ent.Position,Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
                tear = tear:ToProjectile()
                tear.Height = -20
                tear.FallingSpeed = 0.0
                tear.FallingAccel = -(4.5/60.0)
                tear.Scale = 1.25-ent:GetDropRNG():RandomFloat()*0.5
                tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.DECELERATE
                tear.CollisionDamage = 2.0
            end
    
            if ent:GetSprite():IsPlaying("MegaPlant") then 
                local wrms = GODMODE.util.count_enemies(ent,EntityType.ENTITY_PUSTULE,0,0)+GODMODE.util.count_enemies(ent,EntityType.ENTITY_SUCKER,6,0)
                Game():ShakeScreen(10)
                Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF02,3,ent.Position,Vector.Zero,ent)
        
                if wrms >= 5 or data.creepoff > 0 then 
                    for l=1,5 do 
                        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED,0,ent.Position+RandomVector():Resized(data.creepoff*4),Vector.Zero,ent):ToEffect()
                        creep:SetTimeout(140-ent:GetDropRNG():RandomInt(40))
                        creep.Scale = 1.8-ent:GetDropRNG():RandomFloat()*0.4
                        data.creepoff = data.creepoff + 1
                    end
                else 
                    local pos = Game():GetRoom():GetRandomPosition(16.0)
                    local depth = 10 
    
                    while (player.Position - pos):Length() < 64 and depth > 0 do 
                        depth = depth - 1
                        pos = Game():GetRoom():GetRandomPosition(16.0)
                    end
    
                    local wrm = Isaac.Spawn(EntityType.ENTITY_PUSTULE,0,0,pos,Vector.Zero,ent)
                    wrm:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    local fore = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.LARGE_BLOOD_EXPLOSION,0,wrm.Position,Vector.Zero,ent)
                    fore.DepthOffset = 100
                    wrms = wrms + 1     
                end
    
                Game():GetRoom():EmitBloodFromWalls(2,1)
            else
                data.wrm_cache = GODMODE.util.count_enemies(ent,EntityType.ENTITY_SMALL_MAGGOT,0,0)
                local creepoff = 0
                Game():ShakeScreen(5)
                Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF02,3,ent.Position,Vector.Zero,ent)
                local fore = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF02,4,ent.Position,Vector.Zero,ent)
                fore.DepthOffset = 100
        
                for i=1,10 - math.floor(ent.HitPoints / ent.MaxHitPoints * 5) do 
                    if data.wrm_cache >= 8 or creepoff > 0 then 
                        for l=1,2+(3-math.floor(ent.HitPoints / ent.MaxHitPoints * 3)) do 
                            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED,0,ent.Position+RandomVector():Resized(creepoff*4),Vector.Zero,ent):ToEffect()
                            creep:SetTimeout(140-ent:GetDropRNG():RandomInt(40))
                            creep.Scale = 1.8-ent:GetDropRNG():RandomFloat()*0.4
                            creepoff = creepoff + 1
                        end
                    else 
                        local wrm = Isaac.Spawn(EntityType.ENTITY_SMALL_MAGGOT,0,0,ent.Position,RandomVector():Resized(10),ent)
                        wrm:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        data.wrm_cache = data.wrm_cache + 1     
                    end
                end    

                SFXManager():Play(SoundEffect.SOUND_BOSS_LITE_GURGLE,Options.SFXVolume*1.5+0.75)
            end    
        end
    end


    if ent:GetSprite():IsEventTriggered("Fire") then 
        if ent:GetSprite():IsPlaying("Fire") then 
            local blood = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, ent.Position + head_offset(ent)-Vector(0,12), Vector.Zero, ent)
            blood:SetColor(Color(1,1,1,0.75,0.0,0.0,0.0),40,99,false,false)
            blood.DepthOffset = 100
            local bubble = Isaac.Spawn(Isaac.GetEntityTypeByName("Toxic Bubble (Large)"),Isaac.GetEntityVariantByName("Toxic Bubble (Large)"),3,ent.Position+head_offset(ent),Vector(0,4),ent)
            bubble:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            bubble:Update()
            bubble.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
            ent.Velocity = ent.Velocity + Vector(0,-4)
            SFXManager():Play(SoundEffect.SOUND_BOSS_BUG_HISS,Options.SFXVolume*1.0+0.75)    
        else
            for i=0,4 do 
                local ang = math.rad((data.move_fire or ent.Velocity):Rotated(ent:GetDropRNG():RandomFloat()*90-45):GetAngleDegrees())
                local spd = (1.0 + (Game().Difficulty % 2)*1)+ent:GetDropRNG():RandomFloat()*5.0
                local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_NORMAL,0,ent.Position,Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
                tear = tear:ToProjectile()
                tear.Height = -20
                tear.FallingSpeed = 0.0
                tear.FallingAccel = -(4.8/60.0)
                tear.Scale = 1.0-ent:GetDropRNG():RandomFloat()*0.5
                tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.SINE_VELOCITY
                tear.CollisionDamage = 2.0

                if i % 2 == 0 then 
                    tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.CURVE_LEFT
                else 
                    tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.CURVE_RIGHT
                end

                tear.Parent = ent
            end
        end
    end
end

monster.npc_collide = function(self,ent,ent2,entfirst)
    if entfirst and ent.Type == monster.type and ent.Variant == monster.variant and ent:GetSprite():IsPlaying("Charge") then 
        if ent2.Type == EntityType.ENTITY_SMALL_MAGGOT or ent2.Type == EntityType.ENTITY_PUSTULE or ent2.Type == EntityType.ENTITY_SUCKER or (ent2.Type == Isaac.GetEntityTypeByName("Toxic Bubble (Large)") and ent2.Variant == Isaac.GetEntityVariantByName("Toxic Bubble (Large)")) then
            ent2:Kill()
        end
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)
    if (enthit.Type == monster.type and enthit.Variant == monster.variant) and 
        ((entsrc.Type == monster.type and entsrc.Variant == monster.variant) or 
            (entsrc.Entity and entsrc.Entity.Parent and entsrc.Entity.Parent.Type == monster.type and entsrc.Entity.Parent.Variant == monster.variant)) then
        return false
    end
end

return monster