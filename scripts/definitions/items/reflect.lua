local item = {}
item.instance = GODMODE.registry.items.reflect
item.eid_description = "Repels enemy projectiles for 1 second#Charges your primary attack if it touches you while active#Detonates fully charged primary if active"
item.eid_transforms = nil
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "While held, Isaac's tears become a glass ball that always tries to impact Isaac."},
		{str = "When used, gain a short window where all projectiles get deflected from you. If your own tear touches Isaac while this effect is active, the tear then increases in charge."},
		{str = "When the tear increases in charge, a small AOE attack gets released around the tear and it gets harder to control the tear. If the tear is at its max charge stage, next time it contacts the player or enemy it will explode dealing clamp(10,Damage * 5,100) + 20 damage, release flames, and go back to the uncharged state."},
		{str = "If the tear is charged at all, purple flames will be shot out of the tear dealing (1.0 + Damage / StageDepth / 13) / 2.0 based on what direction Isaac is shooting."},
		{str = "If the tear is charged at all, touching the tear without Reflect active will damage Isaac and discharge the tear, releasing the corresponding AOE attack. If Isaac touches the tear while Reflect is active, deals no damage and cycles the charge state like normal (if max charge, releases a safe player explosion at the tear's position)"},
	},
}

item.reflect_time = 60

item.tear_reflect_time = 60
item.tear_reflect_speed = 3.0
item.tear_max_speed = 6

item.tear_disable_time = 100

item.tear_move_strengthen = 1 / 2.0
item.tear_move_dampener = {min=3,max=80 + item.tear_move_strengthen}

item.fire_col = Color(50/255,50/255,200/255,1,200/255,25/255,50/255)
item.fire_lifebase = 15
item.fire_angle_range = 33
item.fire_speed = 6.25

-- shot speed debuff max
item.shotspeed_debuff_cap = 0.8
item.shotspeed_debuff_time = 200

item.default_charge = 0

item.fire_stats = {
    [-1] = false,
    [0] = {
        interval = 0,
        min=60,
        min_dist = 64,
    },
    [1] = {
        interval = 15,
        lifemod = 1.0,
        speedmod = 0.3,
        firemod = 3,
        min=15,
        min_dist = 1,
    },
    [2] = {
        interval = 10,
        lifemod = 0.875,
        speedmod = 0.6,
        firemod = 5,
        min=5,
        min_dist = 1,
    },
    [3] = {
        interval = 7,
        lifemod = 0.75,
        speedmod = 1,
        firemod = 9,
        min=1,
        min_dist = 1,
    },
}

item.fire_life_deviance = 0.5

item.tear_move_scalars = {
    [-1] = 1,
    [0] = 1,
    [1] = 1.25,
    [2] = 1.5,
    [3] = 1.75
}

item.tear_charge_sprites = {
    [-1] = "gfx/tear_glass_0.anm2",
    [0] = "gfx/tear_glass_0.anm2",
    [1] = "gfx/tear_glass_1.anm2",
    [2] = "gfx/tear_glass_2.anm2",
    [3] = "gfx/tear_glass_3.anm2",
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_SHOTSPEED then
		local num = math.min(3,player:GetCollectibleNum(item.instance))
        local shot_debuff_time = math.min(item.shotspeed_debuff_cap, tonumber(GODMODE.save_manager.get_player_data(player,"ReflectShotSpeedTick","0")) / item.shotspeed_debuff_time * item.shotspeed_debuff_cap)
        -- GODMODE.log("shotspeed? old = "..player.ShotSpeed..",buff="..shot_debuff_time,true)
		player.ShotSpeed = player.ShotSpeed - shot_debuff_time
        -- GODMODE.log("shotspeed! new = "..player.ShotSpeed..",buff="..shot_debuff_time.."\n",true)
	end

    if cache == CacheFlag.CACHE_WEAPON then 
        if GODMODE.validate_rgon() and player:GetWeapon(1):GetWeaponType() ~= WeaponType.WEAPON_LUDOVICO_TECHNIQUE then 
            player:SetWeapon(Isaac.CreateWeapon(WeaponType.WEAPON_LUDOVICO_TECHNIQUE,player),1)
        else
            player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE,false)
        end
    end

    if cache == CacheFlag.CACHE_TEARCOLOR then 
        -- somehow
    end
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        local data = GODMODE.get_ent_data(player)
        -- local birthright = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
        GODMODE.save_manager.set_player_data(player,"ReflectActiveTime",item.reflect_time)
        -- data.reflect_time = item.reflect_time

        return {Discharge=true,Remove=false,ShowAnim=true}
    end
end

item.set_charge = function(sprite, tear, charge)
    GODMODE.save_manager.set_ent_data(tear,"Charge", math.min(3,math.max(-1,charge)))
    sprite:Load(item.tear_charge_sprites[math.min(3,charge)], true)
    local size = math.max(1,math.min(13, math.floor(tear.Scale*5)))
    tear:GetSprite():Play("RegularTear"..size,false)
end

item.tear_init = function(self, tear)
    local player = tear.Parent and tear.Parent:ToPlayer() or tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()

    if player and player:HasCollectible(item.instance) and tear.TearFlags & TearFlags.TEAR_LUDOVICO ~= 0 then 
        item.discharge_tear(player, tear, false)
        item.set_charge(tear:GetSprite(), tear, item.room_clear() and -1 or item.default_charge)
    end
end

item.room_clear = function()
    return Isaac.CountEnemies() + Isaac.CountBosses() == 0
end

item.discharge_tear = function(player, tear, explode, reduce, fx, explode_src)
    fx = fx or true 
    local charge = tonumber(GODMODE.save_manager.get_ent_data(tear,"Charge",item.default_charge))
    
    if explode == true and item.fire_stats[charge] ~= false then
        if charge == 3 then 
            -- damage range: 30-120
            -- formula: clamp(10,Damage * 5,100) + 20
            if Isaac.CountBosses() + Isaac.CountEnemies() > 0 then 
                GODMODE.game:BombExplosionEffects(tear.Position,math.min(math.max(100,player.Damage * 5),10) + 20,TearFlags.TEAR_NORMAL, Color.Default, explode_src)
            else 
                Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.BOMB_EXPLOSION,0,tear.Position,Vector.Zero,nil):ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.BOMB_EXPLOSION,0,tear.Position,Vector.Zero,nil):ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                GODMODE.sfx:Play(SoundEffect.SOUND_BOSS1_EXPLOSIONS)
            end
        end

        GODMODE.save_manager.set_player_data(player,"ReflectShotSpeedTick","0",true)
    end

    if fx == true and item.fire_stats[charge] ~= false and (item.fire_stats[charge].firemod or 0) > 0 then 
        local count = item.fire_stats[charge].firemod
        local spread = 360/count
        for i=1, count do 
            local ang = spread * i
            item.shoot_fire(player, tear, 
                ang + (player:GetCollectibleRNG(item.instance):RandomFloat() * spread - spread / 2.0) / 4.0, 
                item.fire_speed * (0.75 + player:GetCollectibleRNG(item.instance):RandomFloat()*0.5), 
                2.0 * item.fire_stats[charge].lifemod + player:GetCollectibleRNG(item.instance):RandomFloat() * 2.0)
        end
    end

    if reduce == true then 
        item.set_charge(tear:GetSprite(), tear, 0)
    end

    local data = GODMODE.get_ent_data(player)
    data.targ_dir = (data.targ_dir or (player.Position - tear.Position)):Resized(item.tear_reflect_speed):Rotated(180)

end

item.shoot_fire = function(player, tear, ang, spd, lifemod)
    local dir = Vector(1,0):Rotated(ang):Resized(spd)
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, tear.Position, dir, player):ToEffect()
    effect:SetTimeout(math.floor(item.fire_lifebase * (lifemod or 1)))
    effect:SetColor(item.fire_col, 999, 1, false, true)
    effect.CollisionDamage = (1.0 + player.Damage * GODMODE.level:GetAbsoluteStage() / 13.0) / 2.0
end

item.tear_update = function(self, tear, data, sprite)
    local player = tear.Parent and tear.Parent:ToPlayer() or tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()

    if player and player:HasCollectible(item.instance) and tear.TearFlags & TearFlags.TEAR_LUDOVICO ~= 0 then 
        local charge = tonumber(GODMODE.save_manager.get_ent_data(tear,"Charge",item.default_charge))
        local stats = item.fire_stats[charge]
        data.reflect_time = math.max(0,(data.reflect_time or 0) - 1)


        if tear:IsFrame(5,1) then 
            if (data.room_clear_dearm or false) == false and item.room_clear() == true then 
                item.discharge_tear(player,tear,false,false,true,player)
                item.set_charge(sprite,tear,0)
            end
            
            data.room_clear_dearm = item.room_clear()
        end
        
        if data.reflect_time <= 0 then -- as long as reflection isn't happening
            local dir = (player.Position - tear.Position)
            data.targ_dir = (player.Position + dir:Resized(-(stats ~= false and stats or {min_dist=0}).min_dist)) - tear.Position
            data.reflect_strength = math.max(
                item.tear_move_dampener.min, 
                (data.reflect_strength or (item.tear_move_dampener.max)) - item.tear_move_strengthen * item.tear_move_scalars[charge])

            data.targ_dir = data.targ_dir:Resized(math.min(item.tear_max_speed,data.targ_dir:Length() / data.reflect_strength))
        elseif data.reflect_time > (item.tear_reflect_time - 2 + (1 - math.max(charge,1)) * 2) then
            local perc = data.reflect_time / item.tear_reflect_time
            if false then --player:GetFireDirection() ~= Direction.NONE then 
                data.targ_dir = Vector(0,item.tear_reflect_speed):Rotated(player:GetFireDirection()*90)
            else 
                data.targ_dir = tear.Position - player.Position
            end

            data.targ_dir = data.targ_dir:Resized(item.tear_reflect_speed * perc * (1.0 - (1 - math.max(charge,1)) * 0.6))
        end

        data.targ_dir = data.targ_dir:Resized(data.targ_dir:Length()*0.9)

        if stats ~= false then 
            data.reflect_strength = math.max(stats.min,data.reflect_strength)

            if (stats.interval or 0) > 0 and tear:IsFrame(stats.interval, tear.InitSeed % stats.interval) then 
                local dir = player:GetAimDirection():GetAngleDegrees() + tear:GetDropRNG():RandomFloat() * item.fire_angle_range - item.fire_angle_range / 2.0

                if player:GetFireDirection() == Direction.NONE then 
                    dir = player:GetCollectibleRNG(item.instance):RandomFloat(360)
                end

                item.shoot_fire(player, tear, 
                    dir, 
                    (tear.Velocity:Length() * 0.5 + item.fire_speed * 0.75) * (stats.speedmod or 1.0), 
                    (stats.lifemod or 1.0) * (tear:GetDropRNG():RandomFloat() * item.fire_life_deviance + 1.0 - item.fire_life_deviance / 2.0))
            end
        end

        -- GODMODE.log("stats:"..tostring(data.reflect_strength)..", ("..tostring(data.targ_dir.X)..","..tostring(data.targ_dir.Y)..")",true)
        if (tear.Position - player.Position):Length() > ((stats or {}).min_dist or 1) then 
            tear.Velocity = tear.Velocity + data.targ_dir
        end

        if (player.Position - tear.Position):Length() < tear.Size * 2 and data.reflect_time == 0 then -- collide
            local time = tonumber(GODMODE.save_manager.get_player_data(player,"ReflectActiveTime","0"))
            
            if time <= 0 and data.reflect_time <= 0 and charge > 0 then 
                player:TakeDamage(1,0,EntityRef(player),20)
                item.discharge_tear(player, tear, true, true)
            else
                if charge >= 3 then 
                    item.discharge_tear(player,tear,true,true,true,player)
                    charge = -1
                else 
                    item.discharge_tear(player,tear,false,false,true,player)
                end

                item.set_charge(sprite, tear, charge + 1)
            end

            data.reflect_time = item.tear_reflect_time
            data.reflect_strength = item.tear_move_dampener.max
        end
    end
end

item.tear_collide = function(self, tear, ent, entfirst)
    local player = tear.Parent and tear.Parent:ToPlayer() or tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()

    if player and player:HasCollectible(item.instance) and tear.TearFlags & TearFlags.TEAR_LUDOVICO ~= 0 then 
        local charge = tonumber(GODMODE.save_manager.get_ent_data(tear,"Charge",item.default_charge))
        local time = tonumber(GODMODE.save_manager.get_player_data(player,"ReflectActiveTime","0"))

        if time == 0 and charge == 3 then 
            item.discharge_tear(player,tear,true,true)
            GODMODE.save_manager.set_player_data(player,"ReflectActiveTime",40)
            item.set_charge(tear:GetSprite(), tear, 1)
        end
    end
end

item.player_update = function(self, player, data, sprite)
    if player:HasCollectible(item.instance) then 
        local time = tonumber(GODMODE.save_manager.get_player_data(player,"ReflectActiveTime","0"))
        
        -- make immune to damage while room is empty
        if Isaac.CountBosses() + Isaac.CountEnemies() == 0 then 
            time = math.max(2,time)
        end

        GODMODE.save_manager.set_player_data(player,"ReflectActiveTime",math.max(0,time - 1))

        local shot_debuff_time = tonumber(GODMODE.save_manager.get_player_data(player,"ReflectShotSpeedTick","0"))
        GODMODE.save_manager.set_player_data(player,"ReflectShotSpeedTick", math.min(item.shotspeed_debuff_time,shot_debuff_time + 1))
        -- GODMODE.log("shot debuff time = "..shot_debuff_time,true)

        if player:IsFrame(20,1) then 
            player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
            player:EvaluateItems()
        end
    end
end

item.player_collide = function(self, player, ent, p_first)
    if ent.Type == EntityType.ENTITY_PROJECTILE or ent.Type == EntityType.ENTITY_TEAR and player:HasCollectible(item.instance) then 
        local time = tonumber(GODMODE.save_manager.get_player_data(player,"ReflectActiveTime","0"))
        if time > 0 then 
            ent.Velocity = -ent.Velocity * 1.25

            if ent.Type == EntityType.ENTITY_PROJECTILE then 
                ent:ToProjectile():AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER | ProjectileFlags.HIT_ENEMIES)
            end

            return false     
        end
    end
end

item.new_room = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        GODMODE.save_manager.set_player_data(player,"ReflectActiveTime",40)
        GODMODE.save_manager.set_player_data(player,"ReflectShotSpeedTick","0",true)
    end)
end



return item