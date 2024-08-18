local monster = {}
monster.name = "Delirious Pile"
monster.type = GODMODE.registry.entities.delirious_pile.type
monster.variant = GODMODE.registry.entities.delirious_pile.variant

local charge_colors = {
    [1] = Color(1,0.1,0.1,1), --red
    [2] = Color(1,1,0.1,1), --yellow
    [3] = Color(1,1,1,1), --white
}

monster.npc_init = function(self, ent)
    ent:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
    local clamped_subtype = math.max(0,math.min(2,ent.SubType))
    
    if clamped_subtype > 0 then 
        for i=0,4 do 
            ent:GetSprite():ReplaceSpritesheet(i,"gfx/monsters/delirious_pile_"..clamped_subtype..".png")
        end

        ent:GetSprite():LoadGraphics()
    end
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent.SpawnerEntity or ent:GetPlayerTarget()

    if sprite:IsFinished("Appear") and not sprite:IsPlaying("Die") then
        sprite:Play("Idle",true)
    end

    if sprite:IsFinished("Die") then 
        ent:Remove()
    end

    ent.Velocity = ent.Velocity * 0.6

    if GODMODE.room:IsClear() and sprite:IsPlaying("Idle") then 
        ent.I1 = ent.I1 + 1

        if ent.I1 >= 20 and not sprite:IsPlaying("Die") then 
            sprite:Play("Die",true)
        end
    end

    if sprite:IsEventTriggered("Fire") then 
        ent:BloodExplode()
        GODMODE.util.macro_on_players(function(player) 
            if player:GetPlayerType() == GODMODE.registry.players.t_deli then 
                for i=0,1 do
                    local fx = Isaac.Spawn(GODMODE.registry.entities.delirious_energy.type, GODMODE.registry.entities.delirious_energy.variant, GODMODE.registry.entities.delirious_energy.subtype, ent.Position, RandomVector()*(1+ent:GetDropRNG():RandomFloat()*2), ent)
                    GODMODE.get_ent_data(fx).player_target = player
                    GODMODE.get_ent_data(fx).seek_time = 5
                    fx:SetColor(charge_colors[ent.SubType+1],999,1,false,false)
                    fx:ToNPC().State = ent.SubType+1
                end
                -- local add = tonumber(GODMODE.save_manager.get_player_data(player,"DeliStat"..clamped_subtype,"0"))
                -- GODMODE.save_manager.set_player_data(player,"DeliStat"..clamped_subtype,add+1,true)
            end
        end)
    end
end

monster.npc_kill = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant then 
        local spd = 3
        local curve_flag = ProjectileFlags.CURVE_LEFT

        if ent:GetDropRNG():RandomFloat() <= 0.5 then 
            curve_flag = ProjectileFlags.CURVE_RIGHT
        end

        local explosive_chance = 0.5
        local type = EntityType.ENTITY_PROJECTILE
        local damage = 0


        if ent.SpawnerEntity ~= nil and ent.SpawnerEntity:ToPlayer() then 
            if ent.SpawnerEntity:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then 
                explosive_chance = 0
                type = EntityType.ENTITY_TEAR
                damage = ent.SpawnerEntity:ToPlayer().Damage
            end
        end

        for i=1,8 do 
            local ang = math.rad(360/8*i)
            local tear = Isaac.Spawn(type,0,0,Vector(ent.Position.X,ent.Position.Y),Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
            if type == EntityType.ENTITY_PROJECTILE then 
                tear = tear:ToProjectile()
                tear:AddProjectileFlags(ProjectileFlags.ACCELERATE | ProjectileFlags.NO_WALL_COLLIDE | curve_flag )
                tear.CurvingStrength = 1/90
                tear.FallingAccel = -(4/60.0)
            else
                tear = tear:ToTear()
                tear:AddTearFlags(TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_WIGGLE)
                tear.CollisionDamage = damage * 2
                tear.FallingAcceleration = -(4/60.0)
            end

            tear.Height = -20
            tear.FallingSpeed = 0.0
            tear:GetSprite():ReplaceSpritesheet(0, "gfx/tear/delirious_pile_tears.png")
            tear:GetSprite():LoadGraphics()
            tear:GetSprite():Play("RegularTear6",true)

            if ent:GetDropRNG():RandomFloat() <= explosive_chance then 
                tear:AddProjectileFlags(ProjectileFlags.EXPLODE | ProjectileFlags.HIT_ENEMIES)
                tear:SetColor(Color(0.8,1,0.8,1,0.1,0.2,0.1),10000,100,false,false)
            else
                -- tear:SetColor(Color(0.7,0.7,0.7,1,0.5,0.5,0.5),10000,100,false,false)
            end
        end
    end
end

monster.new_level = function(self)
    GODMODE.util.macro_on_players(function(player) 
        if player:GetPlayerType() == GODMODE.registry.players.t_xaphan then 
            local data = GODMODE.get_ent_data(player)
            GODMODE.save_manager.set_player_data(player,"DeliStat1","0")
            GODMODE.save_manager.set_player_data(player,"DeliStat2","0")
            GODMODE.save_manager.set_player_data(player,"DeliStat3","0",true)

            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED)
            player:EvaluateItems()
        end
    end)
end


return monster