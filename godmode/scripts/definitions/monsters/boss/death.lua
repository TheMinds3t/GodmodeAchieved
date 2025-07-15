local monster = {}
--colon death
monster.name = "(GODMODE) Death"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)

    if ent:GetSprite():IsEventTriggered("Fire") then 
        local room = Game():GetRoom()
        if ent:GetSprite():IsPlaying("Attack04") then
            SFXManager():Play(SoundEffect.SOUND_SUMMONSOUND)
            SFXManager():Play(SoundEffect.SOUND_MONSTER_GRUNT_0)
            --nonhoming scythes
            local off = RandomVector()*ent.Size*1.5
            Isaac.Spawn(EntityType.ENTITY_SQUIRT,0,0,ent.Position+off,Vector.Zero,ent)
            Isaac.Spawn(EntityType.ENTITY_SQUIRT,0,0,ent.Position+off:Rotated(180),Vector.Zero,ent)

        elseif ent:GetSprite():IsPlaying("Attack01") then
            --scythes
            SFXManager():Play(SoundEffect.SOUND_MONSTER_GRUNT_5)
            for u=0,24+ent:GetDropRNG():RandomFloat()*5 do
                local params = ProjectileParams() 
                params.Variant = ProjectileVariant.PROJECTILE_PUKE
                params.FallingAccelModifier = 0.25
                params.GridCollision = false
                ent:FireBossProjectiles(1,ent.Position+RandomVector():Resized(24-ent:GetDropRNG():RandomFloat()*8),1.5,params)
                -- t.Color = Color(0.3,0.4,0.1,1.0,50/255,50/255,50/255)
            end
        end
    end

    local player = ent:GetPlayerTarget()

    if ent:IsFrame(4,1) then 
        local creep = Isaac.Spawn(1000,EffectVariant.CREEP_BROWN,0,ent.Position,Vector(0,0),ent):ToEffect()
        creep.Timeout = 80 + ent:GetDropRNG():RandomInt(20)
        creep.Scale = 1.5 + ent:GetDropRNG():RandomFloat()*0.25-0.125
        creep:Update()
    end

    if ent:GetSprite():IsFinished("Appear") or ent:GetSprite():IsFinished("Attack01") or ent:GetSprite():IsFinished("Attack04") then 
        ent:GetSprite():Play("Walk",true)
    end

    if ent:GetSprite():IsPlaying("Walk") then 
        ent.Pathfinder:MoveRandomlyBoss(true)
        ent.Velocity = ent.Velocity * 0.9 + (player.Position - ent.Position) * (1 / 500.0)

        if ent:IsFrame(20,1) then 
            if ent:GetDropRNG():RandomFloat() < ent.I1 * 0.2 then 
                if ent:GetDropRNG():RandomInt(2) == 0 and GODMODE.util.count_child_enemies(ent,true) < 2 then 
                    ent:GetSprite():Play("Attack04",true)
                else
                    ent:GetSprite():Play("Attack01",true)
                end
                ent.I1 = 0
            else
                ent.I1 = ent.I1 + 1
            end
        end
    else 
        ent.Velocity = ent.Velocity * 0.8
    end

    if ent:GetSprite():IsFinished("DashStart") then 
        local death = Isaac.Spawn(EntityType.ENTITY_DEATH,30,700,ent.Position,Vector.Zero,ent)
        death:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        -- war:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/horsemen/boss_000_bodies02.png")
        -- war:GetSprite():ReplaceSpritesheet(1, "gfx/bosses/horsemen/boss_052_war_nest.png")
        -- war:GetSprite():LoadGraphics()
        death:TakeDamage(-(ent.HitPoints-(death.MaxHitPoints+150))/2.0,0,EntityRef(player),0)
        -- Game():BombExplosionEffects(ent.Position,)
        death:Update()
        death:GetSprite():Play("Appear",true)
        ent:Remove()
        local horse = Isaac.Spawn(EntityType.ENTITY_DEATH,20,700,ent.Position,Vector.Zero,ent)
        horse:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        horse:Update()
        ent:Remove()
    end

    if ent.HitPoints / ent.MaxHitPoints < 0.5 and not ent:GetSprite():IsPlaying("DashStart") then 
        ent:GetSprite():Play("DashStart",true)
        SFXManager():Play(SoundEffect.SOUND_MONSTER_YELL_A)
    end
end

monster.npc_init = function(self,ent)
    if ent.Type == monster.type and ent.Variant == 0 then 
        if StageAPI ~= nil and StageAPI.GetCurrentStage() ~= nil and StageAPI.GetCurrentStage().Name == "Colon" or ent:GetDropRNG():RandomFloat() < tonumber(GODMODE.save_manager.get_config("AltHorsemanChance","0.2")) then 
            ent:Morph(ent.Type,monster.variant,0,-1)    
        end
    end
end

monster.bypass_hooks = {["npc_init"] = true}

return monster