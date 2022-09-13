local monster = {}
monster.name = "Delirious Pile"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

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

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local data = GODMODE.get_ent_data(ent)
    local player = ent.SpawnerEntity or ent:GetPlayerTarget()

    if ent:GetSprite():IsFinished("Appear") then
        ent:GetSprite():Play("Idle",true)
    end

    ent.Velocity = ent.Velocity * 0.6
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
            local tear = Game():Spawn(type,0,Vector(ent.Position.X,ent.Position.Y),Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent,0,ent.InitSeed)
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
                tear:AddProjectileFlags(ProjectileFlags.EXPLODE)
                tear:SetColor(Color(0.8,1,0.8,1,0.1,0.2,0.1),10000,100,false,false)
            else
                -- tear:SetColor(Color(0.7,0.7,0.7,1,0.5,0.5,0.5),10000,100,false,false)
            end
        end
    end
end

monster.new_room = function(self)
    local room = Game():GetRoom()
    local tl = room:GetTopLeftPos()
    local br = room:GetBottomRightPos()
    local cr = room:GetCenterPos()
    GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(ent)
        if ent:GetDropRNG():RandomFloat() < 0.5 then 
            ent.Position = room:FindFreePickupSpawnPosition(cr + RandomVector()*(tl-br)*0.15)+RandomVector()*ent:GetDropRNG():RandomFloat()
            ent.HitPoints = ent.MaxHitPoints
        end
    end)
end

monster.new_level = function(self)
    GODMODE.util.macro_on_players(function(player) 
        if player:GetName() == "Tainted Deli" then 
            local data = GODMODE.get_ent_data(player)
            data.delirious_pile = {}
        end
    end)

    GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(ent)

        GODMODE.util.macro_on_players(function(player) 
            if player:GetName() == "Tainted Deli" then 
                local data = GODMODE.get_ent_data(player)
                local clamped_subtype = math.max(0,math.min(2,ent.SubType))+1

                data.delirious_pile = data.delirious_pile or {} 
                data.delirious_pile[clamped_subtype] = (data.delirious_pile[clamped_subtype] or 0) + 1
            end
        end)

        ent:Remove()
    end)

    GODMODE.util.macro_on_players(function(player) 
        if player:GetName() == "Tainted Deli" then 
            local data = GODMODE.get_ent_data(player)
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_SPEED)
            player:EvaluateItems()
        end
    end)
    
end

return monster