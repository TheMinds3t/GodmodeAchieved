local monster = {}
--nest war
monster.name = "(GODMODE) War"
monster.type = GODMODE.registry.entities.godmode_war.type
monster.variant = GODMODE.registry.entities.godmode_war.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)

    if sprite:IsEventTriggered("Fire") then 
        local room = GODMODE.room
        if sprite:IsPlaying("Dash") and room:IsPositionInRoom(ent.Position,16) then
            local grident = room:GetGridEntityFromPos(ent.Position)
            
            if grident == nil or grident:GetType() == GridEntityType.GRID_SPIDERWEB and grident.State == 1 then
                room:SpawnGridEntity(room:GetGridIndex(ent.Position), GridEntityType.GRID_SPIDERWEB, 0, ent.InitSeed, 0)
            end
        end
    end

    if (data.fire_override or -1) == ent.FrameCount then 
        -- GODMODE.log("HI!",true)
        local count = 16
        for i=0,count-1 do
            local spd = 6.75 - (i % 2) * 2
            local ang = Vector(1,0):Rotated(360/count * i):Resized(spd)
            local t = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_TEAR,0,ent.Position + ang,ang,ent)
            t = t:ToProjectile()
            t.FallingSpeed = 0.0
            t.Scale = 1.5 - (i % 2) * 0.25
            t:SetColor(Color(0.8,0.6,0.5,1,0.2,0.2,0.2),999,1,false,false)

            t.Height = -30
        end
    end

    local player = ent:GetPlayerTarget()

    if ent.HitPoints / ent.MaxHitPoints < 0.5 then 
        local war = Isaac.Spawn(EntityType.ENTITY_WAR,10,700,ent.Position,Vector.Zero,ent)
        war:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        war:GetSprite():ReplaceSpritesheet(0, "gfx/bosses/horsemen/boss_000_bodies02.png")
        war:GetSprite():ReplaceSpritesheet(1, "gfx/bosses/horsemen/boss_052_war_nest.png")
        war:GetSprite():LoadGraphics()
        war:TakeDamage(-(ent.HitPoints-war.MaxHitPoints),0,EntityRef(player),0)
        -- GODMODE.game:BombExplosionEffects(ent.Position,)
        war:Update()
        war:GetSprite():Play("Cry",true)
        ent:Kill()
    end
end

monster.projectile_init = function(self, proj)
    if proj.SpawnerEntity ~= nil and proj.SpawnerEntity.Type == monster.type and proj.SpawnerEntity.Variant == monster.variant then 
        local data = GODMODE.get_ent_data(proj.SpawnerEntity)

        if data ~= nil and (data.fire_override or 0) ~= proj.SpawnerEntity.FrameCount then 
            proj:Remove()
            data.fire_override = proj.SpawnerEntity.FrameCount + 1
        end
    end
end

monster.bomb_init = function(self,bomb)
    if bomb.SpawnerEntity ~= nil and bomb.SpawnerEntity.Type == monster.type and bomb.SpawnerEntity.Variant == monster.variant then 
        bomb:Remove()
        local num = GODMODE.util.count_enemies(nil,EntityType.ENTITY_TICKING_SPIDER,nil,nil) 
        local num_spider = GODMODE.util.count_enemies(nil,EntityType.ENTITY_SPIDER,nil,nil) 
        local num_burrow = GODMODE.util.count_enemies(nil,GODMODE.registry.entities.outbreak.type,GODMODE.registry.entities.outbreak.variant,2) 

        if (num < 3 or num_spider < 3) and num_burrow < 3 then 
            local player = bomb.SpawnerEntity:ToNPC():GetPlayerTarget()
            local room = GODMODE.room
            local pos = room:FindFreePickupSpawnPosition(room:GetRandomPosition(32)) 
            local depth = 10

            while (player.Position - pos):Length() < 80 and depth > 0 do 
                pos = room:FindFreePickupSpawnPosition(room:GetRandomPosition(32))
                depth = depth - 1
            end
            
            local burrow = Isaac.Spawn(GODMODE.registry.entities.outbreak.type,GODMODE.registry.entities.outbreak.variant,2,pos,Vector.Zero,bomb.SpawnerEntity)

            -- GODMODE.log(tostring(num),true)
            if num < 3 then 
                GODMODE.get_ent_data(burrow).spawn_data = {type = EntityType.ENTITY_TICKING_SPIDER, hp_mod = 0.33}
            elseif num_spider < 3 then  
                GODMODE.get_ent_data(burrow).spawn_data = {type = EntityType.ENTITY_SPIDER,var=0}
            end

            burrow.Parent = bomb.SpawnerEntity
            burrow:Update()
        end
    end
end

-- monster.npc_collide = function(self,ent,ent2,entfirst)
--     if ent.Type == monster.type and ent.Variant == monster.variant 
--         and ent2.Type == GODMODE.registry.entities.ratty.type and ent2.Variant == GODMODE.registry.entities.ratty.variant 
--         and sprite:IsPlaying("AttackDash") then 
--             ent2:Kill()
--     end
-- end

monster.npc_init = function(self,ent)
    if ent.Type == monster.type and ent.Variant == 0 then 
        if StageAPI ~= nil and StageAPI.Loaded and StageAPI.GetCurrentStage() ~= nil and StageAPI.GetCurrentStage().Name == "TheNest" or ent:GetDropRNG():RandomFloat() < tonumber(GODMODE.save_manager.get_config("AltHorsemanChance","0.2")) then 
            ent:Morph(ent.Type,monster.variant,0,-1)    
        end
    end
end

monster.bypass_hooks = {["npc_init"] = true}

return monster