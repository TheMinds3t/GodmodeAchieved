local players = {}
players["Recluse"] = {
    eid_birthright = "↑ Chiggers spawned deal 3.75x damage instead of 2.5x damage",
    init = function(player)
        player:AddCollectible(Isaac.GetItemIdByName("Larval Therapy"))
        player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/arac_head.anm2"))
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/arac_head.anm2"))
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(player)
            player.Damage = player.Damage * 0.875
        end,
        [CacheFlag.CACHE_SPEED] = function(player)
            player.MoveSpeed = player.MoveSpeed + 0.1
        end,
        [CacheFlag.CACHE_RANGE] = function(player)
            player.TearRange = player.TearRange + 26*2
        end,
    }
}
players["Tainted Recluse"] = {
    eid_birthright = "↑ Spawn twice as many Chiggers when using Reclusive Tendencies#↑ Spiders spawned deal 15% contact damage instead of 10%",
    pocket_item = Isaac.GetItemIdByName("Reclusive Tendencies"), pocket_charge = 1,
    init = function(player)
        player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/tainted_arac_head.anm2"))
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/tainted_arac_head.anm2"))    
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(player)
            player.Damage = player.Damage * 0.7
            -- player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/characters/234_infestation2.anm2"))
        end,
        [CacheFlag.CACHE_SPEED] = function(player)
            player.MoveSpeed = player.MoveSpeed - 0.1
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(player)
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.3)
        end,
    }
}
players["Xaphan"] = {
    eid_birthright = "↑ +2 Luck#Adramolech's Blessing charges twice as fast",
    init = function(player)
        player:AddCollectible(Isaac.GetItemIdByName("Adramolech's Blessing"))
        player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/xaphan_head.anm2"))
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/xaphan_head.anm2"))
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(player)
            player.Damage = player.Damage + 1.0
        end,
        [CacheFlag.CACHE_SPEED] = function(player)
            player.MoveSpeed = player.MoveSpeed - 0.125
        end,
        [CacheFlag.CACHE_LUCK] = function(player)
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                player.Luck = player.Luck + 5.0
            end

            player.Luck = player.Luck - 6.0
        end,
        [CacheFlag.CACHE_RANGE] = function(player)
            player.TearRange = player.TearRange - 26*2
        end,
    },
    update = function(player)
        local data = GODMODE.get_ent_data(player)
        data.added_xaphan_birthright = GODMODE.save_manager.get_player_data(player, "XaphanBirthright", "false") == "true"
            
        if not data.added_xaphan_birthright and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            GODMODE.save_manager.set_player_data(player, "XaphanBirthright", "true",true)
            player:AddCacheFlags(CacheFlag.CACHE_LUCK)
            player:EvaluateItems()
        end
    end
}
players["Tainted Xaphan"] = {
    eid_birthright = "Adramolech's Fury mark chance is increased to 75%#25% chance for marked enemies to not become champions",
    pocket_item = Isaac.GetItemIdByName("Adramolech's Fury"), pocket_charge = 10, red_health = false, soul_health = false,
    init = function(player) 
        player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/xaphan_head.anm2"))
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/xaphan_head.anm2"))
        player:AddCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_LORD_OF_THE_PIT),false)
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(player)
            player.Damage = player.Damage - 0.25
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(player)
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,-0.2)
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(player)
            player.ShotSpeed = player.ShotSpeed - 0.2
        end,
        [CacheFlag.CACHE_SPEED] = function(player)
            player.MoveSpeed = player.MoveSpeed - 0.1
        end,
        [CacheFlag.CACHE_LUCK] = function(player)
            player.Luck = player.Luck - 10.0
        end,
        [CacheFlag.CACHE_RANGE] = function(player)
            player.TearRange = player.TearRange - 26*1
        end,
        [CacheFlag.CACHE_FLYING] = function(player)
            player.CanFly = true
        end
    }
}
players["Elohim"] = {
    eid_birthright = "Teleport to Elohim's Throne, giving 3 free angel items",
    init = function(player)
        player:AddCollectible(Isaac.GetItemIdByName("Holy Chalice"))
        player:AddGoldenHearts(3)
        player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/elohim_beard.anm2"))
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/elohim_beard.anm2"))
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(player)
            player.Damage = player.Damage - 1.5
        end,
        [CacheFlag.CACHE_SPEED] = function(player)
            player.MoveSpeed = player.MoveSpeed - 0.1
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(player)
            player.ShotSpeed = player.ShotSpeed - 0.2
        end,
        [CacheFlag.CACHE_FLYING] = function(player)
            player.CanFly = true
        end,
        [CacheFlag.CACHE_LUCK] = function(player)
            player.Luck = player.Luck + 2
        end,
        [CacheFlag.CACHE_RANGE] = function(player)
            player.TearRange = player.TearRange + 26
        end,


    },
    update = function(player)
        local data = GODMODE.get_ent_data(player)
        data.added_elohim_birthright = GODMODE.save_manager.get_player_data(player, "ElohimBirthright", "false") == "true"
            
        if not data.added_elohim_birthright and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            GODMODE.save_manager.set_player_data(player, "ElohimBirthright", "true",true)
            Isaac.ExecuteCommand("goto s.angel.650")
        end
    end
}
players["Tainted Elohim"] = {
    eid_birthright = "Gain a small all stat up whenever a future boss fight is aced#Remove 1 more broken heart per ace as well",
    init = function(player)
        player:AddBrokenHearts(10)
        player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/tainted_elohim_beard.anm2"))
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/tainted_elohim_beard.anm2"))
        player:AddCollectible(Isaac.GetItemIdByName("Divine Approval"))
        player:AddGoldenHearts(-1)
        player:AddSoulHearts(-2)
        player:AddTrinket(Isaac.GetTrinketIdByName("Godmode"))
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
        -- GODMODE.log("init!",true)
    end,
    soul_health = true, red_health = false,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(player)
            player.Damage = player.Damage * 1.125 + 0.06 + 0.5 + tonumber(GODMODE.save_manager.get_player_data(player,"ElohimBRStatBoost","0")) * 0.3
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(player)
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.2 + tonumber(GODMODE.save_manager.get_player_data(player,"ElohimBRStatBoost","0")) * 0.25)
        end,
        [CacheFlag.CACHE_SPEED] = function(player)
            player.MoveSpeed = player.MoveSpeed + 0.1 + tonumber(GODMODE.save_manager.get_player_data(player,"ElohimBRStatBoost","0")) * 0.1
        end,
        [CacheFlag.CACHE_LUCK] = function(player)
            player.Luck = player.Luck - 1 + tonumber(GODMODE.save_manager.get_player_data(player,"ElohimBRStatBoost","0"))
        end,
        [CacheFlag.CACHE_RANGE] = function(player)
            player.TearRange = player.TearRange + 52 + tonumber(GODMODE.save_manager.get_player_data(player,"ElohimBRStatBoost","0")) * 26
        end,
    }
}
players["Gehazi"] = {
    eid_birthright = "Retain 2 more coins on hit",
    init = function(player)
        player:AddCollectible(Isaac.GetItemIdByName("Crown of Gold"))
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(player)
            player.Damage = player.Damage - 0.75
        end,
        [CacheFlag.CACHE_SPEED] = function(player)
            player.MoveSpeed = player.MoveSpeed + 0.1
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(player)
            player.ShotSpeed = player.ShotSpeed + 0.2
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(player)
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,1)
        end,
        [CacheFlag.CACHE_RANGE] = function(player)
            player.TearRange = player.TearRange - 26*1.25
        end,
        [CacheFlag.CACHE_LUCK] = function(player)
            player.Luck = player.Luck - 1
        end
    }
}

players["Deli"] = {
    eid_birthright = "↑ +20% Damage#↑ +10% Tears",
    update = function(player)
        local data = GODMODE.get_ent_data(player)
        data.added_deli_birthright = GODMODE.save_manager.get_player_data(player, "DeliBirthright", "false") == "true"
        data.trisagion_time = (data.trisagion_time or 0) + 1    

        if not data.added_deli_birthright and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            GODMODE.save_manager.set_player_data(player, "DeliBirthright", "true",true)
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
    end,
    clone_fire = function(player, position, base_tear)
        local data = GODMODE.get_ent_data(player)
        local moff = player:GetTearMovementInheritance(player.Velocity)*0.25

        if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) or player:HasCollectible(Isaac.GetItemIdByName("Uncommon Cough")) then
            local xl = 5
            
            if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
                xl = 1
            elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
                xl = 1
            elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
                xl = 2
            elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) then
                xl = 1
            elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) or player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) then
                xl = 1
            end

            for i=-3,3 do
                for x=0,xl do
                    local real_ind = i
                    if i == 0 then real_ind = -4 end 
                    local dir = (data.cur_deli_ang + (360 / 8 * (real_ind))) % 360 + player:GetDropRNG():RandomFloat()*15-7.5
                    local ang_scale = 1 / (math.abs(real_ind) * 1.125)

                    dir = math.rad(dir)
                    local spd = Vector(math.cos(dir)*player.ShotSpeed*10,math.sin(dir)*player.ShotSpeed*10) * (0.8 + GODMODE.util.random() * 0.4)
                    moff = player:GetTearMovementInheritance(player.Velocity+spd)*0.25
                    spd = spd + moff

                    local t = {}
                    
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) then
                        t = player:FireTechLaser(position+spd,LaserOffset.LASER_TECH2_OFFSET, spd,true,false)
                        t:SetTimeout((player.MaxFireDelay))
                    end

                    if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
                        if i % 2 == 1 then
                            spd = spd * 1.125
                        end
                        t = player:FireBomb(position+spd*1.125,spd)
                        t:SetExplosionCountdown(28)
                        t.RadiusMultiplier = 0.5
                    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
                        t = player:FireTechXLaser(position+spd, data.deli_brimstone/player.MaxFireDelay*32, player.Damage * 10)
                    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
                        if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
                            t = player:FireBrimstone(spd)
                        else
                            t = player:FireTechLaser(position+spd,LaserOffset.LASER_TECH1_OFFSET, spd,false,true)
                        end
                    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
                        if player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
                            t = player:FireDelayedBrimstone(math.deg(dir), player)
                        else
                            t = player:FireBrimstone(spd)
                        end
                    else
                        t = player:FireTear(position,spd,true,true,false)
                        t.Height = t.Height * (0.8 + GODMODE.util.random() * 0.4)
                        t.Scale = t.Scale * (0.5 + GODMODE.util.random() * 1.0)
                    end

                    if t:ToTear() then
                        t.Rotation = spd:GetAngleDegrees()
                        t:ToTear().Height = t:ToTear().Height * ang_scale
                    elseif t:ToLaser() then
                        local laser = t:ToLaser()
                        laser.Radius = data.proj_ref:ToLaser().Radius
                        laser.Shrink = data.proj_ref:ToLaser().Shrink
                        laser.RotationSpd = data.proj_ref:ToLaser().RotationSpd
                        laser.RotationDelay = data.proj_ref:ToLaser().RotationDelay
                        laser.LaserLength = data.proj_ref:ToLaser().LaserLength
                        laser.IsActiveRotating = data.proj_ref:ToLaser().IsActiveRotating
                        laser.OneHit = data.proj_ref:ToLaser().OneHit
                        laser.OneHit = data.proj_ref:ToLaser().OneHit
                        laser.Size = data.proj_ref.Size
                        laser.SizeMulti = data.proj_ref.SizeMulti
                    end

                    
                    t.Scale = t.Scale * (0.5 + ang_scale * 0.5)
                    t.CollisionDamage = t.CollisionDamage * (0.25 + ang_scale * 0.75)
                    t:Update()
                    --t.CollisionDamage = t.CollisionDamage * (0.8 + GODMODE.util.random() * 0.4)
                end
            end
        elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) or (player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION)) then
            local flag = math.ceil(player.FireDelay) == math.floor(player.MaxFireDelay)

            if player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then 
                flag = data.trisagion_time % 3 == 0 and player.FireDelay > 0 and base_tear.CollisionDamage > 0
            end

            if flag and player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) or not player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) then
                for i=-3,3 do
                    local real_ind = i
                    if i == 0 then real_ind = -4 end 
                    local f = (data.cur_deli_ang + (360 / 8 * (real_ind))) % 360
                    local ang_scale = 1 / (math.abs(real_ind) * 1.125)

                    local v = Vector(math.cos(math.rad(f)),math.sin(math.rad(f)))
                    local l2 = nil
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) then 
                        f = math.rad(f)
                        local spd = Vector(math.cos(f)*player.ShotSpeed*10,math.sin(f)*player.ShotSpeed*10)
                        l2 = player:FireTear(player.Position,spd,true,true,false)
                    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
                        l2 = player:FireDelayedBrimstone(f,player)
                        l2.Variant = 2
                    else
                        l2 = player:FireBrimstone(v)
                        l2.Variant = 2
                    end

                    if l2:ToLaser() then 
                        l2:SetMaxDistance(100 + 300 * ang_scale)
                    else
                        l2.Scale = l2.Scale * (0.5 + ang_scale * 0.5)
                    end

                    l2.CollisionDamage = l2.CollisionDamage * (0.25 + ang_scale * 0.75)
                end
            end
        else
            for i=-3,3 do
                local real_ind = i
                if i == 0 then real_ind = -4 end 
                local dir = (data.cur_deli_ang + (360 / 8 * (real_ind))) % 360
                local ang_scale = 1 / math.abs(real_ind)
                --GODMODE.log("cur_ang="..data.cur_deli_ang..",dir="..dir..",scale="..ang_scale,true)

                dir = math.rad(dir)
                local spd = Vector(math.cos(dir)*player.ShotSpeed*10,math.sin(dir)*player.ShotSpeed*10)
                spd = spd + moff
                local t = {}

                if player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) then
                    t = player:FireTechLaser(player.Position+spd,LaserOffset.LASER_TECH2_OFFSET, spd,true,false)
                    t:SetTimeout(math.ceil(player.MaxFireDelay))
                end

                if player:HasCollectible(CollectibleType.COLLECTIBLE_DR_FETUS) then
                    if i % 2 == 1 then
                        spd = spd * 1.125
                    end
                    t = player:FireBomb(player.Position+spd*1.125,spd)
                    t:SetExplosionCountdown(28)
                    t.RadiusMultiplier = 0.5
                elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECH_X) then
                    t = player:FireTechXLaser(player.Position+spd, spd,player.Damage * 10)
                elseif player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) then
                    t = player:FireTechLaser(player.Position+spd,LaserOffset.LASER_TECH1_OFFSET, spd,false,true)
                elseif player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
                        t = player:FireDelayedBrimstone(math.deg(dir), player)
                    else
                        t = player:FireBrimstone(spd)
                    end
                else
                    t = player:FireTear(player.Position,spd,true,true,false)
                end

                if data.proj_ref:ToTear() then
                    t.Rotation = spd:GetAngleDegrees()
                    local tear = t:ToTear()
                    local ref_tear = data.proj_ref:ToTear()
                    tear.Height = ref_tear.Height
                    tear.FallingSpeed = ref_tear.FallingSpeed
                    tear.FallingAcceleration = ref_tear.FallingAcceleration
                end

                t.Scale = t.Scale * (0.25 + ang_scale * 0.75)
                t.CollisionDamage = t.CollisionDamage * (0.25 + ang_scale * 0.75)
            end
        end
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(player)
            local mod = 0.65
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                mod = 0.85
            end

            player.Damage = player.Damage * mod
        end,
        [CacheFlag.CACHE_RANGE] = function(player)
            player.TearRange = player.TearRange - 26*4
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(player)
            local mod = 1.2
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                mod = 1.1
            end
            player.MaxFireDelay = player.MaxFireDelay * mod
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(player)
            player.ShotSpeed = player.ShotSpeed - 0.6
        end,
    }
}

players["Tainted Deli"] = {
    eid_birthright = "Delirious Piles now fire a ring of spectral tears with Damage * 2",
    update = function(player)
        local data = GODMODE.get_ent_data(player)
        data.trisagion_time = (data.trisagion_time or 0) + 1   
        GODMODE.tainted_deli = true 
    end,
    clone_fire = players["Deli"].clone_fire,
    stats = {
        [CacheFlag.CACHE_SPEED] = function(player)
            local data = GODMODE.get_ent_data(player)
            data.delirious_pile = data.delirious_pile or {}
            local add = data.delirious_pile[2] or 0

            player.MoveSpeed = player.MoveSpeed - 0.1 + add * 0.05
        end,
        [CacheFlag.CACHE_DAMAGE] = function(player)
            local mod = 0.85
            local data = GODMODE.get_ent_data(player)
            data.delirious_pile = data.delirious_pile or {}
            local add = data.delirious_pile[1] or 0

            player.Damage = player.Damage * mod + add * 0.125
        end,
        [CacheFlag.CACHE_RANGE] = function(player)
            player.TearRange = player.TearRange - 26*4
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(player)
            local mod = 1.1
            player.MaxFireDelay = player.MaxFireDelay * mod
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(player)
            local data = GODMODE.get_ent_data(player)
            data.delirious_pile = data.delirious_pile or {}
            local add = data.delirious_pile[3] or 0

            player.ShotSpeed = player.ShotSpeed - 0.4 + add * 0.1
        end,
        [CacheFlag.CACHE_TEARFLAG] = function(player)
            player.TearFlags = player.TearFlags | TearFlags.TEAR_WIGGLE | TearFlags.TEAR_SPECTRAL
        end
    }
}

players["The Sign"] = {
    eid_birthright = "↑ Remove all Broken Hearts#↑ Removes 25% speed penalty", red_health = false, soul_health = true,
    init = function(player)
        local kills = tonumber(GODMODE.save_manager.get_persistant_data("PalaceKills", "0", true))
        local data = GODMODE.get_ent_data(player)
        data.added_sign_start = GODMODE.save_manager.get_player_data(player, "SignStarted", "false") == "true"

        if data.added_sign_start == false then
            player:AddBrokenHearts(math.max(0,math.floor(11-kills*2.2)))
            player:AddSoulHearts(2 + math.floor(kills/2)*2)

            if kills == 5 then
                player:AddEternalHearts(1)
            end

            GODMODE.save_manager.set_player_data(player, "SignStarted", "true",true)
        end

        player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/sign_wings.anm2"))
        player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/sign_wings.anm2"))
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(player)
            local kills = tonumber(GODMODE.save_manager.get_persistant_data("PalaceKills", "1"))
            local hearts = math.max(0,(12-kills))
            player.Damage = player.Damage - 1.25 + hearts/12
        end,
        [CacheFlag.CACHE_SPEED] = function(player)
            local mod = 0.75

            if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                mod = 1.0
            end

            player.MoveSpeed = player.MoveSpeed * mod
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(player)
            player.ShotSpeed = player.ShotSpeed - 0.25
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(player)
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.25)
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.5,true)
        end,
        [CacheFlag.CACHE_FLYING] = function(player)
            player.CanFly = true
        end,
        [CacheFlag.CACHE_TEARFLAG] = function(player)
            player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_QUADSPLIT
        end,
        [CacheFlag.CACHE_RANGE] = function(player)
            player.TearRange = player.TearRange + 26*1.25
        end,
    },
    update = function(player)
        local kills = tonumber(GODMODE.save_manager.get_data("PalaceKills", "0"))

        if true then
        -- if kills > 0 then
            local data = GODMODE.get_ent_data(player)

            data.added_sign_birthright = GODMODE.save_manager.get_player_data(player, "SignBirthright", "false") == "true"
            
            if not data.added_sign_birthright and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                GODMODE.save_manager.set_player_data(player, "SignBirthright", "true",true)
                player:AddBrokenHearts(-(12-kills))
                player:AddSoulHearts(2)
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end

            if data.flame == nil or data.flame:IsDead() then
                data.flame = Isaac.Spawn(Isaac.GetEntityTypeByName("The Sign's Flame"), Isaac.GetEntityVariantByName("The Sign's Flame"), 0, player.Position, Vector.Zero, player)
                data.flame:ToFamiliar().Player = player
                data.flame:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            end

            data.sign_tears = data.sign_tears or {}

            for i,tear in ipairs(data.sign_tears) do
                local perc = math.min(1.0,tear.FrameCount / 5.0)
                if perc < 1.0 then
                    tear.Color = Color(tear.Color.R,tear.Color.G,tear.Color.B,perc)
                end

                local dist = tear.Position - player.Position

                if math.abs(dist.X) < 16 and math.abs(dist.Y) < 16 then
                    tear:Kill()
                end

                if tear:IsDead() then 
                    tear.Color = Color(tear.Color.R,tear.Color.G,tear.Color.B,1.0)
                    table.remove(data.sign_tears, i)
                end
            end
        end
    end
}

players["The Lost"] = {
    init = function(player)
        if player.SubType == PlayerType.PLAYER_THELOST_B and GODMODE.save_manager.get_config("TaintedLostWish","true") == "true" then
            player:AddCollectible(Isaac.GetItemIdByName("Mom's Wish"))
        end
    end,
}

return players