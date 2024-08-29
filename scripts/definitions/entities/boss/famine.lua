local monster = {}
--fruit cellar famine
monster.name = "(GODMODE) Famine"
monster.type = GODMODE.registry.entities.godmode_famine.type
monster.variant = GODMODE.registry.entities.godmode_famine.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()

    if sprite:IsEventTriggered("Shoot") and sprite:IsPlaying("AttackDashStart") then 
        -- GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A)
    end

    if sprite:IsEventTriggered("AltShoot") then 
        if sprite:IsPlaying("Attack1") then 
            local room = GODMODE.room
            local pos = room:FindFreePickupSpawnPosition(room:GetRandomPosition(32)) 
            local depth = 10

            while (player.Position - pos):Length() < 80 and depth > 0 do 
                pos = room:FindFreePickupSpawnPosition(room:GetRandomPosition(32))
                depth = depth - 1
            end

            local rat = Isaac.Spawn(GODMODE.registry.entities.ratty.type,GODMODE.registry.entities.ratty.variant,0,pos,Vector.Zero,ent):ToNPC()
            rat.MaxHitPoints = rat.MaxHitPoints * 4
            rat.HitPoints = rat.MaxHitPoints
            rat.Scale = 1.25

            for u=0,16+ent:GetDropRNG():RandomFloat()*5 do
                local params = ProjectileParams() 
                params.Variant = ProjectileVariant.PROJECTILE_NORMAL
                params.FallingAccelModifier = 1.0
                params.GridCollision = false
                local proj = ent:FireBossProjectiles(1,ent.Position+RandomVector():Resized(24-ent:GetDropRNG():RandomFloat()*8),0.25,params)
                proj.Height = proj.Height - 20
                proj:GetSprite():ReplaceSpritesheet(0,"gfx/alt_bulletatlas.png")
                proj:GetSprite():LoadGraphics()
                proj:GetSprite():Play("RegularTear6",true)
                -- t.Color = Color(0.3,0.4,0.1,1.0,50/255,50/255,50/255)
            end

            GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_GRUNT_5)
        elseif sprite:IsPlaying("HeadAttack") then 
            local count = GODMODE.util.count_child_enemies(ent,false)

            if count < 3 then 
                Isaac.Spawn(GODMODE.registry.entities.ratty.type,GODMODE.registry.entities.ratty.variant,1,GODMODE.room:FindFreePickupSpawnPosition(ent.Position),Vector.Zero,ent)
            end
    
            for u=0,7+ent:GetDropRNG():RandomFloat()*5 do
                local params = ProjectileParams() 
                params.Variant = ProjectileVariant.PROJECTILE_NORMAL
                params.FallingAccelModifier = 1.0
                params.GridCollision = false
                local proj = ent:FireBossProjectiles(1,ent.Position+RandomVector():Resized(24-ent:GetDropRNG():RandomFloat()*8),0.25,params)
                proj.Height = proj.Height - 20
                proj:GetSprite():ReplaceSpritesheet(0,"gfx/alt_bulletatlas.png")
                proj:GetSprite():LoadGraphics()
                proj:GetSprite():Play("RegularTear6",true)
                proj.Velocity = proj.Velocity * 0.5 + (player.Position-ent.Position):Resized(math.min(10,math.max(4,(player.Position-ent.Position):Length()/20.0)))
                -- t.Color = Color(0.3,0.4,0.1,1.0,50/255,50/255,50/255)
            end    

            GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_GRUNT_0)

        elseif sprite:IsPlaying("AttackDash") or sprite:IsPlaying("AttackDashStart") then 
            local creep = Isaac.Spawn(1000,EffectVariant.CREEP_RED,0,ent.Position,Vector(0,0),ent):ToEffect()
            creep.Timeout = 60 + ent:GetDropRNG():RandomInt(40)
            creep:SetColor(Color(1,1,1,1,-0.1,0,0.125),999,1,false,false)
            creep.Scale = 1.0 + ent:GetDropRNG():RandomFloat()*0.05-0.025
            creep:Update()

            if GODMODE.room:IsPositionInRoom(ent.Position,13) then 
                local params = ProjectileParams() 
                params.Variant = ProjectileVariant.PROJECTILE_NORMAL
                params.FallingAccelModifier = 1.0
                params.GridCollision = false
                local proj = ent:FireBossProjectiles(1,ent.Position+RandomVector():Resized(24-ent:GetDropRNG():RandomFloat()*8),0.25,params)
                proj.Height = proj.Height - 20
                proj.Velocity = -ent.Velocity:Rotated(-60+ent:GetDropRNG():RandomFloat()*120) * 0.25
                proj:GetSprite():ReplaceSpritesheet(0,"gfx/alt_bulletatlas.png")
                proj:GetSprite():LoadGraphics()
                proj:GetSprite():Play("RegularTear6",true)    
                proj:Update()
            end
        end

        if sprite:IsPlaying("AttackDash") then 
            ent.Position.Y = player.Position.Y
        end
    end
end

monster.npc_collide = function(self,ent,ent2,entfirst)
    if ent.Type == monster.type and ent.Variant == monster.variant 
        and ent2.Type == GODMODE.registry.entities.ratty.type and ent2.Variant == GODMODE.registry.entities.ratty.variant 
        and ent:GetSprite():IsPlaying("AttackDash") then 
            ent2:Kill()
    end
end

monster.npc_kill = function(self,ent)
    for i=1,4 do 
        Isaac.Spawn(GODMODE.registry.entities.fruit.type,GODMODE.registry.entities.fruit.variant,1, ent.Position, RandomVector():Resized(ent:GetDropRNG():RandomFloat()*0.5+1.5), nil)
    end
end

monster.npc_init = function(self,ent)
    if ent.Type == monster.type and ent.Variant == 0 then 
        if StageAPI ~= nil and StageAPI.Loaded and StageAPI.GetCurrentStage() ~= nil and StageAPI.GetCurrentStage().Name == "FruitCellar" or ent:GetDropRNG():RandomFloat() < tonumber(GODMODE.save_manager.get_config("AltHorsemanChance","0.2")) then 
            ent:Morph(ent.Type,monster.variant,0,-1)    
            ent:SetColor(Color(1,1,1,1),1,1,false,false)
        end
    end
end

monster.bypass_hooks = {["npc_init"] = true}

return monster