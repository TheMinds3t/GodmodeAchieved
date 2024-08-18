local monster = {}
monster.name = "Ludomaw"
monster.type = GODMODE.registry.entities.ludomaw.type
monster.variant = GODMODE.registry.entities.ludomaw.variant

monster.set_delirium_visuals = function(self,ent)
    for i=0,3 do 
        ent:GetSprite():ReplaceSpritesheet(i,"gfx/bosses/deliriumforms/ludomaw_new.png")
    end
    ent:GetSprite():LoadGraphics()
end

local sfx = GODMODE.sfx

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()
    ent.SpriteOffset = Vector(0,8)

    if data.init == nil then
        sprite:Play("Idle",true)
        data.flame_size = 96
        
        -- for i=1,3 do
        --     local fly = Isaac.Spawn(EntityType.ENTITY_ETERNALFLY,0,i,ent.Position+Vector(160,160):Rotated(i*120),Vector.Zero,ent)
        --     fly:ToNPC().V1 = Vector(160,160)
        --     fly:ToNPC().V2 = Vector(160,160)
        --     fly:ToNPC().I1 = 160
        --     fly:ToNPC().ProjectileCooldown = 160
        --     fly.TargetPosition = Vector(160,160)
        --     fly:ToNPC().GroupIdx = monster.variant+monster.type+ent.Index
        --     fly.Parent = ent
        --     fly.Target = ent
        -- end

        ent.GroupIdx = monster.variant+monster.type+ent.Index
    
        data.start_pos = ent.Position
        data.init = true
    end


    ent.Position = data.start_pos or ent.Position
    ent.Velocity = ent.Velocity * 0.85
    if ent.Velocity:Length() < 0.1 then ent.Velocity = Vector.Zero end
    if not data.start_pos then data.start_pos = ent.Position end
    data.flame_size = 108 + math.cos(data.time / 35) * 24

    if sprite:IsFinished("Idle") then
        data.atk_last = (data.atk_last or 0) + 1.5 
        if ent:GetDropRNG():RandomFloat() < 0.1 + data.atk_last * 0.2 then 
            local atk_type = ent:GetDropRNG():RandomInt(10)
            
            if atk_type < 2 then 
                sprite:Play("Fire",true)
                data.last_atk = 0
            elseif atk_type <= 5 and data.last_atk ~= 1 then 
                sprite:Play("Pustule",true)
                data.last_atk = 1
            elseif atk_type <= 8 and data.last_atk ~= 3 then 
                sprite:Play("Launch",true) --RedStinger idea!
                data.last_atk = 3
            elseif GODMODE.util.count_enemies(nil,GODMODE.registry.entities.ludomini.type,GODMODE.registry.entities.ludomini.variant,-1) < 2 then
                sprite:Play("Spawn",true)
                data.last_atk = 2
            else 
                sprite:Play("Fire",true)
                data.last_atk = 0
            end

            data.atk_last = 0
        else 
            sprite:Play("Idle",true)
        end
    end

    if sprite:IsFinished("Fire") or sprite:IsFinished("Pustule") or sprite:IsFinished("Spawn") or sprite:IsFinished("Launch") then
        sprite:Play("Idle",true)
    end

    if sprite:IsEventTriggered("Attack") then
        if sprite:IsPlaying("Pustule") then
			sfx:Play(SoundEffect.SOUND_HEARTOUT,2.5*Options.SFXVolume,0,false,1)
            
            for i=0,3 do
                local spd = 2.5 + ent:GetDropRNG():RandomFloat() * 1.0
                local ang = player.Position - ent.Position
                local f = math.rad(ang:GetAngleDegrees() + ent:GetDropRNG():RandomFloat() * 45 - 22.5)
                ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
                local params = ProjectileParams()
                params.HeightModifier = -30
                params.BulletFlags = ProjectileFlags.SMART
                local pustule_off = Vector(-52,40)
                ent.Position = ent.Position + pustule_off
                ent:ToNPC():FireBossProjectiles(2,ent.Position+ang * (i+1), 0.45, params)
                ent.Position = ent.Position - pustule_off
            end
        elseif sprite:IsPlaying("Fire") then
			sfx:Play(SoundEffect.SOUND_FIRE_RUSH,2.5*Options.SFXVolume,0,false,1)

            local spd = 2.5+ent:GetDropRNG():RandomFloat()*0.25
            local off = data.time * 15
            local flags = 0

            if ent:GetDropRNG():RandomInt(2) == 1 then 
                flags = ProjectileFlags.CURVE_LEFT
            else
                flags = ProjectileFlags.CURVE_RIGHT
            end

            for i=1,8 do
                local f = math.rad(off + 45 * i)
                local ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
                local t = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,2,0,ent.Position + ang,ang*spd,ent)
                t = t:ToProjectile()
                t.ProjectileFlags = flags
                t.HomingStrength = 0.0
                t.CurvingStrength = 1/150.0
                t.FallingAccel = (-5.8/60.0)
                t.Acceleration = 5.0
                t.FallingSpeed = 1
                t.Height = -18
                -- t.Scale = 2.0
                t:SetColor(Color(0.2,0,0.2,1.25,0.4,0,0.6),999,99,false,false)
                t.SpriteOffset = Vector(0,16)
            end
        elseif sprite:IsPlaying("Spawn") then
			sfx:Play(SoundEffect.SOUND_MONSTER_GRUNT_4,2.5*Options.SFXVolume,0,false,1)

            if GODMODE.util.count_enemies(nil,GODMODE.registry.entities.ludomini.type,1,-1) < 2 then
                local t = Isaac.Spawn(GODMODE.registry.entities.ludomini.type,GODMODE.registry.entities.ludomini.variant,0,GODMODE.room:FindFreeTilePosition(ent.Position,96)+Vector(0,32),Vector(0,0),ent)
            end
        elseif sprite:IsPlaying("Launch") then
			sfx:Play(SoundEffect.SOUND_MAGGOT_BURST_OUT,2.5*Options.SFXVolume,0,false,1)
			sfx:Play(SoundEffect.SOUND_SMB_LARGE_CHEWS_4,2.5*Options.SFXVolume,0,false,1)

            local t = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position+Vector(0,-24),(player.Position-ent.Position):Resized(7),ent)
            t = t:ToProjectile()
            t.ProjectileFlags = ProjectileFlags.SMART | ProjectileFlags.EXPLODE | ProjectileFlags.ANY_HEIGHT_ENTITY_HIT | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT
            t.ChangeFlags = ProjectileFlags.SMART | ProjectileFlags.EXPLODE | ProjectileFlags.ANY_HEIGHT_ENTITY_HIT | ProjectileFlags.HIT_ENEMIES
            t.ChangeTimeout = 20
			t.HomingStrength = 0.7
			t.CurvingStrength = 0.5
            t.FallingAccel = (-0.0/60.0)
            t.Acceleration = 5.0
            t.FallingSpeed = 4
            t.Height = -100
            t.Scale = 2.0
            t.DepthOffset = 50

            local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_JET,0,ent.Position+Vector(8,-72),Vector.Zero,ent)
            fx.DepthOffset = 100
            fx.CollisionDamage = 0
            fx:SetColor(Color(0.3,0.25,1,1,0.2,0,0.2),999,1,false,false)
        end
    end
end

return monster