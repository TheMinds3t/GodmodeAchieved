local monster = {}
monster.name = "Ludomaw"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.set_delirium_visuals = function(self,ent)
    for i=0,3 do 
        ent:GetSprite():ReplaceSpritesheet(i,"gfx/bosses/deliriumforms/ludomaw_new.png")
    end
    ent:GetSprite():LoadGraphics()
end


monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()

    if data.init == nil then
        ent:GetSprite():Play("Idle",true)
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

    if ent:GetSprite():IsFinished("Idle") then
        data.atk_last = (data.atk_last or 0) + 1.5 
        if ent:GetDropRNG():RandomFloat() < 0.1 + data.atk_last * 0.2 then 
            local atk_type = ent:GetDropRNG():RandomInt(10)
            
            if atk_type < 3 then 
                ent:GetSprite():Play("Fire",true)
                data.last_atk = 0
            elseif atk_type <= 7 and data.last_atk ~= 1 then 
                ent:GetSprite():Play("Pustule",true)
                data.last_atk = 1
            elseif GODMODE.util.count_enemies(nil,Isaac.GetEntityTypeByName("Ludomini"),Isaac.GetEntityVariantByName("Ludomini"),-1) < 2 then
                ent:GetSprite():Play("Spawn",true)
                data.last_atk = 2
            else 
                ent:GetSprite():Play("Fire",true)
                data.last_atk = 0
            end

            data.atk_last = 0
        else 
            ent:GetSprite():Play("Idle",true)
        end
    end

    if ent:GetSprite():IsFinished("Fire") or ent:GetSprite():IsFinished("Pustule") or ent:GetSprite():IsFinished("Spawn") then
        ent:GetSprite():Play("Idle",true)
    end

    if ent:GetSprite():IsEventTriggered("Attack") then
        if ent:GetSprite():IsPlaying("Pustule") then
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
        elseif ent:GetSprite():IsPlaying("Fire") then
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
                local t = Game():Spawn(EntityType.ENTITY_PROJECTILE,2,ent.Position + ang,ang*spd,ent,0,ent.InitSeed)
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
        elseif ent:GetSprite():IsPlaying("Spawn") then
            if GODMODE.util.count_enemies(nil,Isaac.GetEntityTypeByName("Ludomini"),1,-1) < 2 then
                local t = Isaac.Spawn(Isaac.GetEntityTypeByName("Ludomini"),Isaac.GetEntityVariantByName("Ludomini"),0,Game():GetRoom():FindFreeTilePosition(ent.Position,96)+Vector(0,32),Vector(0,0),ent)
            end
        end
    end
end

return monster