local players = {}
players[GODMODE.registry.players.recluse] = {
    eid_birthright = "↑ Chiggers spawned deal 3.75x damage instead of 2.5x damage",
    init = function(self, player)
        player:AddCollectible(GODMODE.registry.items.larval_therapy)
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(self, player)
            player.Damage = player.Damage * 0.875
        end,
        [CacheFlag.CACHE_SPEED] = function(self, player)
            player.MoveSpeed = player.MoveSpeed + 0.1
        end,
        [CacheFlag.CACHE_RANGE] = function(self, player)
            player.TearRange = player.TearRange + GODMODE.util.grid_size
        end,
        ["on_item_pickup"] = function(self, player)
            player:TryRemoveNullCostume(GODMODE.registry.costumes.arac_head)
            player:AddNullCostume(GODMODE.registry.costumes.arac_head)
        end
    },
    encyclopedia_entry = {{ -- Start Data
        {str = "Start Data", fsize = 2, clr = 3, halign = 0},
        {str = "Items:"},
        {str = "- Larval Therapy"},
        {str = "Stats:"},
        {str = "- HP: 2 Red Hearts, 1 Black Heart"},
        {str = "- Extra: 1 Bomb"},
        {str = "- Speed: 1.1"},
        {str = "- Tear Rate: 3.06"},
        {str = "- Damage: 3.06 (0.875x multiplier)"},
        {str = "- Range: 7.8"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: 0.00"},
    },
    { -- Birthright
        {str = "Birthright", fsize = 2, clr = 3, halign = 0},
        {str = "Chiggers deal 3.75x damage over time instead of 2.5x damage."},
    }},
    encyclopedia_details = {
        name = "Recluse",
        anmfile = "gfx/ui/main menu/encyc_portraits.anm2",
        anmname = "Recluse",
    }
}
players[GODMODE.registry.players.t_recluse] = {
    eid_birthright = "↑ All attacks apply a poison effect for 2 seconds, dealing 10% player damage#Getting hit while toxic creates toxic creep",
    pocket_item = GODMODE.registry.items.reclusive_tendencies, pocket_charge = 240, tainted = true, max_hits = 12,
    init = function(self, player)
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(self, player)
            player.Damage = player.Damage * 0.7
        end,
        [CacheFlag.CACHE_SPEED] = function(self, player)
            player.MoveSpeed = player.MoveSpeed - 0.1
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(self, player)
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.3)
        end,
        [CacheFlag.CACHE_TEARFLAG] = function(self, player) 
            if tonumber(GODMODE.save_manager.get_player_data(player,"ToxicPerc","1.0")) > 0.0 then 
                player:AddCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_SCORPIO),false)
                player.TearFlags = player.TearFlags | TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP
            else 
                player:RemoveCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_SCORPIO),false)
            end
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(self, player)
            player.ShotSpeed = player.ShotSpeed + 0.2
        end,        
        ["on_item_pickup"] = function(self, player)
            player:TryRemoveNullCostume(GODMODE.registry.costumes.t_arac_head)
            player:AddNullCostume(GODMODE.registry.costumes.t_arac_head)
        end
    },
    encyclopedia_entry = {{ -- Start Data
        {str = "Start Data", fsize = 2, clr = 3, halign = 0},
        {str = "Items:"},
        {str = "- Reclusive Tendencies"},
        {str = "Stats:"},
        {str = "- HP: 3 Black Hearts & 6 Toxic Hearts"},
        {str = "- Extra: 1 Bomb"},
        {str = "- Speed: 0.9"},
        {str = "- Tear Rate: 3.03"},
        {str = "- Damage: 2.45 (0.7x multiplier)"},
        {str = "- Range: 6.50"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: 0.00"},
    },
    {
        {str = "Toxic Hearts", fsize = 2, clr = 3, halign = 0},
        {str = "Tainted Recluse has 6 toxic hearts, limiting his regular health to 6 hearts. His toxicity decays to 0 at a configurable time in seconds, and he gains toxicity by dealing damage."},
        {str = "If Tainted Recluse takes damage while retaining toxicity, he loses all toxicity instead of taking damage and cannot gain any by dealing damage. He will take full heart damage while he remains at 0 toxicity. Once an enemy is killed, he will be able to gain toxicity over time again and will gain an additional 50% toxicity over the course of 10 seconds."},
    },
    { -- Birthright
        {str = "Birthright", fsize = 2, clr = 3, halign = 0},
        {str = "While toxic, all damage dealt applies a weak poison effect that lasts for 2 seconds."},
        {str = "When damage is taken while toxic create a green creep puddle, with the size, damage and duration growing based on how much toxicity was lost (from 1 damage per tick to 5 damage per tick at max toxicity)."},
    }},
    encyclopedia_details = {
        name = "Recluse",
        anmfile = "gfx/ui/main menu/encyc_portraits_alt.anm2",
        anmname = "Tainted Recluse",
        description = "The friendless",
    },
    update = function(self, player, data)
        data.toxic_cd = math.max(0,(data.toxic_cd or 0) - 1)
        if player:IsFrame(10,1) and not GODMODE.paused then 
            local state = tonumber(GODMODE.save_manager.get_player_data(player,"ToxicState","1"))
            local toxic = tonumber(GODMODE.save_manager.get_player_data(player,"ToxicPerc","1.0"))
            local perc = 1 / tonumber(GODMODE.save_manager.get_config("ToxicDecayRate","60.0")) / 3

            if state > 0 and state <= 1 then 
                GODMODE.save_manager.set_player_data(player,"ToxicPerc",math.max(0,toxic - perc))
            elseif state > 1 then 
                perc = 0.5 / 10.0 / 3.0
                GODMODE.save_manager.set_player_data(player,"ToxicPerc",math.min(1,toxic + perc))

                if toxic + perc >= 1.0 then 
                    GODMODE.save_manager.set_player_data(player,"ToxicState","1")
                else 
                    GODMODE.save_manager.set_player_data(player,"ToxicState",state - 0.1)
                end
            end

            if toxic - perc <= 0.0 then 
                player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
                player:EvaluateItems()
            elseif toxic > 0 and player.TearFlags & TearFlags.TEAR_ACID ~= 1 then
                player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
                player:EvaluateItems()
            end
        end
    end
}
players[GODMODE.registry.players.xaphan] = {
    eid_birthright = "↑ +5 Luck#Adramolech's Blessing charges twice as fast",
    init = function(self, player)
        player:AddCollectible(GODMODE.registry.items.adramolechs_blessing)
        player:AddCollectible(GODMODE.registry.items.wings_of_betrayal)

        player:TryRemoveNullCostume(GODMODE.registry.costumes.xaphan_head)
        player:AddNullCostume(GODMODE.registry.costumes.xaphan_head)
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(self, player)
            player.Damage = player.Damage * 1.1 - 0.35
        end,
        [CacheFlag.CACHE_SPEED] = function(self, player)
            player.MoveSpeed = player.MoveSpeed - 0.1
        end,
        [CacheFlag.CACHE_LUCK] = function(self, player)
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                player.Luck = player.Luck + 5.0
            end

            player.Luck = player.Luck - 6.0
        end,
        [CacheFlag.CACHE_RANGE] = function(self, player)
            player.TearRange = player.TearRange - GODMODE.util.grid_size
        end,
    },
    update = function(self, player, data)
        data.added_xaphan_birthright = GODMODE.save_manager.get_player_data(player, "XaphanBirthright", "false") == "true"
            
        if not data.added_xaphan_birthright and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            GODMODE.save_manager.set_player_data(player, "XaphanBirthright", "true",true)
            player:AddCacheFlags(CacheFlag.CACHE_LUCK)
            player:EvaluateItems()
        end
    end,
    encyclopedia_entry = {{ -- Start Data
        {str = "Start Data", fsize = 2, clr = 3, halign = 0},
        {str = "Items:"},
        {str = "- Adramolech's Blessing"},
        {str = "Stats:"},
        {str = "- HP: 1 Red Heart, 2 Black Hearts"},
        {str = "- Extra: 1 Bomb"},
        {str = "- Speed: 0.9"},
        {str = "- Tear Rate: 2.73"},
        {str = "- Damage: 3.5 (1.1x multiplier)"},
        {str = "- Range: 5.2"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: -1.00 (-6 if Adramolech's Blessing is removed)"},
    },
    { -- Birthright
        {str = "Birthright", fsize = 2, clr = 3, halign = 0},
        {str = "+5 Luck"},
        {str = "Adramolech's Blessing gains 2 charge after each 4 marked champion kills instead of 1 charge."},
    }},
    encyclopedia_details = {
        name = "Xaphan",
        anmfile = "gfx/ui/main menu/encyc_portraits.anm2",
        anmname = "Xaphan",
    }
}
players[GODMODE.registry.players.t_xaphan] = {
    eid_birthright = "Adramolech's Fury mark chance is increased to 75%#25% chance for marked enemies to not become champions",
    pocket_item = GODMODE.registry.items.adramolechs_fury, pocket_charge = 10, red_health = false, soul_health = false, tainted = true,
    init = function(self, player) 
        player:TryRemoveNullCostume(GODMODE.registry.costumes.t_xaphan_head)
        player:AddNullCostume(GODMODE.registry.costumes.t_xaphan_head)
        player:TryRemoveNullCostume(GODMODE.registry.costumes.t_xaphan_body)
        player:AddNullCostume(GODMODE.registry.costumes.t_xaphan_body)

        player:TryRemoveNullCostume(GODMODE.registry.costumes.t_xaphan_eyes_0)
        player:AddNullCostume(GODMODE.registry.costumes.t_xaphan_eyes_0)

    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(self, player)
            player.Damage = player.Damage - 0.25
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(self, player)
            -- player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,-0.2)
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(self, player)
            player.ShotSpeed = player.ShotSpeed
        end,
        [CacheFlag.CACHE_SPEED] = function(self, player)
            player.MoveSpeed = player.MoveSpeed
        end,
        [CacheFlag.CACHE_LUCK] = function(self, player)
            player.Luck = player.Luck - 10.0
        end,
        [CacheFlag.CACHE_RANGE] = function(self, player)
            player.TearRange = player.TearRange - GODMODE.util.grid_size
        end,
        [CacheFlag.CACHE_FLYING] = function(self, player)
            player.CanFly = true
        end,
        [CacheFlag.CACHE_TEARCOLOR] = function(self, player)
            player.TearColor = Color(1,1,0.5,1,1,0.125,0)
        end
    },
    shadow_frequency = 3, --special to t-xaphan rendering
    max_shadow = tonumber(GODMODE.save_manager.get_config("TXaphanTrail","4")),
    shadow_life = 100,
    update = function(self, player, data)
        if player:IsFrame(self.shadow_frequency,1) and player.Velocity:Length() > player.MoveSpeed then 
            data.xaphan_trail = data.xaphan_trail or {}
            local max_flag = #(data.xaphan_trail or {}) < self.max_shadow

            if #data.xaphan_trail > 0 then
                local max_trail = nil
                for ind,trail in ipairs(data.xaphan_trail) do 
                    if trail:IsDead() then 
                        table.remove(data.xaphan_trail,ind)
                    elseif max_flag == false and (max_trail == nil or max_trail.Timeout > trail.Timeout) then 
                        max_trail = trail
                    end
                end

                if max_trail then 
                    max_trail.Timeout = math.floor(max_trail.Timeout * 0.8)
                end
            end

            if max_flag and data.second_sprite then 
                -- local shadow = Isaac.Spawn(GODMODE.registry.entities.player_trail_fx.type, GODMODE.registry.entities.player_trail_fx.variant, 0, player.Position+RandomVector()*player.Size, Vector.Zero, player):ToEffect()
                -- shadow.State = self.shadow_life
                -- shadow:Update()
                -- table.insert(data.xaphan_trail, shadow)        

                local shadow = Isaac.Spawn(GODMODE.registry.entities.player_trail_fx.type, GODMODE.registry.entities.player_trail_fx.variant, 0, player.Position, Vector.Zero, player):ToEffect()
                shadow.State = self.shadow_life
                GODMODE.get_ent_data(shadow).far_color = Color(0,0,0,0.2,0,0,0)
                shadow:Update()
                shadow:GetSprite():Load(data.second_sprite:GetFilename(),true)
                shadow:GetSprite():SetFrame(player:GetSprite():GetAnimation(),player:GetSprite():GetFrame())
                shadow.DepthOffset = -100
                table.insert(data.xaphan_trail, shadow)
            end
        end
    end,
    encyclopedia_entry = {{ -- Start Data
        {str = "Start Data", fsize = 2, clr = 3, halign = 0},
        {str = "Items:"},
        {str = "- Adramolech's Fury"},
        {str = "Stats:"},
        {str = "- HP: 1 Black Heart"},
        {str = "- Extra: 1 Bomb"},
        {str = "- Speed: 1.0 to 2.0"},
        {str = "- Tear Rate: 2.73 to 5.0"},
        {str = "- Damage: 3.25 to 8.25"},
        {str = "- Range: 5.85"},
        {str = "- Shot Speed: 1.0 to 1.50"},
        {str = "- Luck: -10.00 to 2.00"},
    },
    { -- Notes
        {str = "Notes", fsize = 2, clr = 3, halign = 0},
        {str = "The stats of Tainted Xaphan depend on the charge of Adramolech's Fury. The item starts at 10 charge out of 100"},
    },
    { -- Birthright
        {str = "Birthright", fsize = 2, clr = 3, halign = 0},
        {str = "The chance to mark an enemy is increased to 75%"},
        {str = "If an enemy is selected to be marked, 25% chance to not convert enemy to a champion"},
    }},
    encyclopedia_details = {
        name = "Xaphan",
        anmfile = "gfx/ui/main menu/encyc_portraits_alt.anm2",
        anmname = "Tainted Xaphan",
        description = "The deflector",
    }
}
players[GODMODE.registry.players.elohim] = {
    eid_birthright = "Teleport to Elohim's Throne, giving 3 free angel items",
    init = function(self, player)
        player:AddCollectible(GODMODE.registry.items.holy_chalice)
        player:AddGoldenHearts(3)
        player:TryRemoveNullCostume(GODMODE.registry.costumes.elohim_beard)
        player:AddNullCostume(GODMODE.registry.costumes.elohim_beard)
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(self, player)
            player.Damage = player.Damage - 1
        end,
        [CacheFlag.CACHE_SPEED] = function(self, player)
            player.MoveSpeed = player.MoveSpeed - 0.1
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(self, player)
            player.ShotSpeed = player.ShotSpeed - 0.2
        end,
        [CacheFlag.CACHE_FLYING] = function(self, player)
            player.CanFly = true
        end,
        [CacheFlag.CACHE_LUCK] = function(self, player)
            player.Luck = player.Luck + 2
        end,
        [CacheFlag.CACHE_RANGE] = function(self, player)
            player.TearRange = player.TearRange + GODMODE.util.grid_size / 2.0
        end,


    },
    update = function(self, player, data)
        data.added_elohim_birthright = GODMODE.save_manager.get_player_data(player, "ElohimBirthright", "false") == "true"
            
        if not data.added_elohim_birthright and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            GODMODE.save_manager.set_player_data(player, "ElohimBirthright", "true",true)
            Isaac.ExecuteCommand("goto s.angel.650")
        end
    end,
    encyclopedia_entry = {{ -- Start Data
        {str = "Start Data", fsize = 2, clr = 3, halign = 0},
        {str = "Items:"},
        {str = "- Holy Chalice"},
        {str = "Stats:"},
        {str = "- HP: 1 Red Heart, 2 Soul Hearts, 3 Golden Hearts"},
        {str = "- Extra: 1 Bomb"},
        {str = "- Speed: 0.9"},
        {str = "- Tear Rate: 2.73"},
        {str = "- Damage: 2.00"},
        {str = "- Range: 7.15"},
        {str = "- Shot Speed: 0.80"},
        {str = "- Luck: 2.00"},
    },
    { -- Birthright
        {str = "Birthright", fsize = 2, clr = 3, halign = 0},
        {str = "You warp to a unique angel room containing three sets of angel items."},
        {str = "You are able to choose one item from each set."},
    }},
    encyclopedia_details = {
        name = "Elohim",
        anmfile = "gfx/ui/main menu/encyc_portraits.anm2",
        anmname = "Elohim",
    }
}
players[GODMODE.registry.players.t_elohim] = {
    eid_birthright = "You can charge daggers to gain a swing attack, pushing enemies away, removing projectiles and dealing damage#Remove 1 more broken heart per boss fight as well",
    pocket_item = GODMODE.registry.items.vengeful_dagger,
    init = function(self, player)
        player:AddBrokenHearts(10)
        player:TryRemoveNullCostume(GODMODE.registry.costumes.t_elohim_beard)
        player:AddNullCostume(GODMODE.registry.costumes.t_elohim_beard)
        player:AddCollectible(GODMODE.registry.items.divine_approval)
        player:AddGoldenHearts(-1)
        player:AddSoulHearts(-2)
        player:AddTrinket(GODMODE.registry.trinkets.godmode)
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
        -- GODMODE.log("init!",true)
    end,
    soul_health = true, red_health = false, tainted = true,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(self, player)
            player.Damage = player.Damage + 0.5
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(self, player)
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.2)
        end,
        [CacheFlag.CACHE_SPEED] = function(self, player)
            player.MoveSpeed = player.MoveSpeed + 0.1
        end,
        [CacheFlag.CACHE_LUCK] = function(self, player)
            player.Luck = player.Luck - 1
        end,
        [CacheFlag.CACHE_RANGE] = function(self, player)
            player.TearRange = player.TearRange + GODMODE.util.grid_size
        end,
    },
    encyclopedia_entry = {{ -- Start Data
        {str = "Start Data", fsize = 2, clr = 3, halign = 0},
        {str = "Items:"},
        {str = "- Divine Approval"},
        {str = "Trinkets:"},
        {str = "- Godmode"},
        {str = "Stats:"},
        {str = "- HP: 1 Soul Heart, 1 Golden Heart, 10 Broken Hearts"},
        {str = "- Speed: 1.10"},
        {str = "- Tear Rate: 3.18"},
        {str = "- Damage: 4.0"},
        {str = "- Range: 7.8"},
        {str = "- Shot Speed: 1.00"},
        {str = "- Luck: -1.00"},
    },
    { -- Birthright
        {str = "Birthright", fsize = 2, clr = 3, halign = 0},
        {str = "Adds an additional counter that charges when your Vengeful Dagger is ready. "..
        "If it is full, when you use a vengeful dagger the dagger will do a spin attack before being launched, "..
        "dealing damage to enemies and knocking them back as well as removing projectiles that touch the dagger. "..
        "You can also change the direction you launch daggers when they are swinging."},
    }},
    encyclopedia_details = {
        name = "Elohim",
        anmfile = "gfx/ui/main menu/encyc_portraits_alt.anm2",
        anmname = "Tainted Elohim",
        description = "The witness",
    }
}
players[GODMODE.registry.players.gehazi] = {
    eid_birthright = "Retain 2 more coins on hit",
    init = function(self, player)
        player:AddCollectible(GODMODE.registry.items.crown_of_gold)

        if GODMODE.validate_rgon() then 
            player:AddLeprosy()
        end
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(self, player)
            player.Damage = player.Damage - 0.75
        end,
        [CacheFlag.CACHE_SPEED] = function(self, player)
            player.MoveSpeed = player.MoveSpeed + 0.1
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(self, player)
            player.ShotSpeed = player.ShotSpeed + 0.2
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(self, player)
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,1)
        end,
        [CacheFlag.CACHE_RANGE] = function(self, player)
            player.TearRange = player.TearRange - GODMODE.util.grid_size / 2.0
        end,
        [CacheFlag.CACHE_LUCK] = function(self, player)
            player.Luck = player.Luck - 1
        end
    },
    encyclopedia_entry = {{ -- Start Data
        {str = "Start Data", fsize = 2, clr = 3, halign = 0},
        {str = "Items:"},
        {str = "- Greed's Gullet"},
        {str = "- Crown of Gold"},
        {str = "Stats:"},
        {str = "- HP: 1 Black Heart"},
        {str = "- Speed: 1.10"},
        {str = "- Tear Rate: 3.73"},
        {str = "- Damage: 2.75"},
        {str = "- Range: 5.69"},
        {str = "- Shot Speed: 1.20"},
        {str = "- Luck: -1.00"},
    },
    { -- Birthright
        {str = "Birthright", fsize = 2, clr = 3, halign = 0},
        {str = "Lose 2 less coins on taking damage."},
    }},
    encyclopedia_details = {
        name = "Gehazi",
        anmfile = "gfx/ui/main menu/encyc_portraits.anm2",
        anmname = "Gehazi",
    },
    update = function(self, player, data) 
        
        if GODMODE.validate_rgon() then 
            if data.health_cache ~= nil and data.health_cache ~= player:GetMaxHearts() then 
                -- GODMODE.log("health change! cache=="..data.health_cache,true)

                if player:GetMaxHearts() < data.health_cache then 
                    player:AddLeprosy()
                end

                data.health_cache = data.health_cache + math.max(-2,math.min(2,(player:GetMaxHearts() - data.health_cache)))
            end

            data.health_cache = data.health_cache or player:GetMaxHearts()
        end
    end
}
players[GODMODE.registry.players.t_gehazi] = {
    eid_birthright = "Additional 2% chance for nickel drops from attacking#Additional 10% chance for double penny drops from attacking", pocket_item = GODMODE.registry.items.golden_stopwatch, pocket_charge = 3, tainted = true,
    init = function(self, player)
    end,
    dmg_split = 3,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(self, player)
            local add = 1 - math.min(not GODMODE.get_ent_data(player).has_eyes and 0 or player:GetNumCoins(),1)
            local gs_bonus = 0
            if GODMODE.get_ent_data(player).gold_stopwatch == true then add = 0 end

            player.Damage = (player.Damage + 1.5) * (0.4 * add + 1.0 * math.max(0,1 - add)) + gs_bonus
        end,
        [CacheFlag.CACHE_SPEED] = function(self, player)
            player.MoveSpeed = player.MoveSpeed + 0.15
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(self, player)
            player.ShotSpeed = player.ShotSpeed + 0.25
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(self, player)
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay, 1)
        end,
        [CacheFlag.CACHE_RANGE] = function(self, player)
            player.TearRange = player.TearRange - GODMODE.util.grid_size / 2.0
        end,
        [CacheFlag.CACHE_LUCK] = function(self, player)
            player.Luck = player.Luck + 1
        end,
        [CacheFlag.CACHE_TEARCOLOR] = function(self, player)
            if GODMODE.get_ent_data(player).has_eyes then 
                player.LaserColor = Color(0.25,0.25,0.25,1,150/255,130/255,10/255)
            else
                player.LaserColor = Color(1,1,1,1)
            end
        end
    },
    mods = {
        [CollectibleType.COLLECTIBLE_CRICKETS_BODY] = 2,
    },
    get_item_mod = function(self, player)
        local ret = 0
        for col,amt in pairs(self.mods) do
            if player:HasCollectible(col) then 
                ret = ret + amt
            end
        end

        return ret 
    end,
    
    tear_fire = function(self, tear, player) 
        local data = GODMODE.get_ent_data(tear)
        local stopwatch_flag = GODMODE.get_ent_data(player).gold_stopwatch or false
        if (player:GetNumCoins() > 0 or stopwatch_flag) 
            and (tear.Position - player.Position):Length() < tear.Size+tear.Velocity:Length()
            and GODMODE.get_ent_data(player).has_eyes == true
            and GODMODE.get_ent_data(player).gehazi_keep_coin ~= true then 

            if player:GetNumCoins() == 0 then 
                data.noval = true
            end

            if tear.Variant ~= TearVariant.COIN then 
                tear:ChangeVariant(TearVariant.COIN)
            end

            tear.CollisionDamage = tear.BaseDamage / self.dmg_split
            player:AddCoins(-1-self:get_item_mod(player))
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARCOLOR)
            player:EvaluateItems()
        end

        tear.Parent = player
    end,
    coin_amt = {
        [CoinSubType.COIN_PENNY] = 1,
        [CoinSubType.COIN_DOUBLEPACK] = 2,
        [CoinSubType.COIN_NICKEL] = 5,
        [CoinSubType.COIN_DIME] = 10,
    },
    spawn_coin = function(self, tear, player, target, farm)
        local tear_dat = GODMODE.get_ent_data(tear)
        target = target or tear_dat.hit_enemy
        local dir = Vector(1,0):Rotated(tear:GetDropRNG():RandomFloat()*360.0):Resized(tear:GetDropRNG():RandomFloat()*1.25+1.25)
        + (player.Position - tear.Position):Resized((player.Position - tear.Position):Length()*0.5/13)
        -- birthright moment
        local br = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 1 or 0

        local sub = tear:GetDropRNG():RandomFloat()

        if farm == true then 
            if sub >= 0.99-br*0.02 then 
                sub = CoinSubType.COIN_NICKEL
            else 
                sub = tear:GetDropRNG():RandomFloat() 
                if sub >= 0.9-br*0.1 then 
                    sub = CoinSubType.COIN_DOUBLEPACK 
                else sub = CoinSubType.COIN_PENNY end
            end
        else sub = CoinSubType.COIN_PENNY end
        
        local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, sub, tear.Position,dir,tear)
        coin.CollisionDamage = tear.CollisionDamage * ((self.dmg_split - 1) * self.coin_amt[sub])
        coin.Target = target
        coin.Parent = player
    end,
    should_use_coin = function(self,player)
        return player:GetNumCoins() > 0 or GODMODE.get_ent_data(player).gold_stopwatch or false 
    end,
    tear_kill = function(self, tear, player) 
        local tear_dat = GODMODE.get_ent_data(tear)
        local col = tear_dat.collided 
        local stopwatch_flag = GODMODE.get_ent_data(player).gold_stopwatch or tear_dat.nolife or false
        local noval_flag = tear_dat.noval

        if (col == true or stopwatch_flag) and noval_flag ~= true and tear.Variant == TearVariant.COIN and tear.Parent ~= nil then 
            self:spawn_coin(tear, player, nil, col)
        end    
    end,
    update = function(self, player, data)

        if ((GODMODE.room:IsClear() and Isaac.CountBosses() == 0) or (player:GetNumCoins() == 0)) and data.gold_stopwatch ~= true then 
            local old = data.has_eyes 
            data.has_eyes = false 

            if old == true then 
                player:TryRemoveNullCostume(GODMODE.registry.costumes.t_gehazi_eyes)
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARCOLOR)
                player:EvaluateItems()
            end
        else 
            local old = data.has_eyes
            data.has_eyes = true

            if old ~= true then 
                player:AddNullCostume(GODMODE.registry.costumes.t_gehazi_eyes)
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARCOLOR)
                player:EvaluateItems()
            end
        end
    end,
    tear_collide = function(self, tear, ent2, player) 
        local data = GODMODE.get_ent_data(tear)
        if not GODMODE.util.is_valid_enemy(ent2,true) then 
            data.nolife = true
            tear.CollisionDamage = tear.CollisionDamage * self.dmg_split
        else 
            data.collided = true
            data.hit_enemy = ent2
        end
    end,
    pickup_collide = function(self, pickup, player)
        if pickup.Variant == PickupVariant.PICKUP_COIN and pickup.CollisionDamage > 0 and pickup.Target ~= nil then 
            pickup.Target:TakeDamage(pickup.CollisionDamage,0,EntityRef(player),0) 
            pickup.CollisionDamage = 0
            pickup.Target = nil
        end
    end,
    encyclopedia_entry = {{ -- Start Data
        {str = "Start Data", fsize = 2, clr = 3, halign = 0},
        {str = "Items:"},
        {str = "- Golden Stopwatch"},
        {str = "Stats:"},
        {str = "- HP: 3 Black Hearts"},
        {str = "- Speed: 1.15"},
        {str = "- Tear Rate: 3.73"},
        {str = "- Damage: 4.00"},
        {str = "- Range: 5.69"},
        {str = "- Shot Speed: 1.25"},
        {str = "- Luck: -1.00"},
    },
    { -- Birthright
        {str = "Birthright", fsize = 2, clr = 3, halign = 0},
        {str = "Before choosing what type of coin to spawn when hitting an enemy, adds an additional 5% chance for the new coin to be a nickel"},
    }},
    { -- Notes
        {str = "Notes", fsize = 2, clr = 3, halign = 0},
        {str = "Tainted Gehazi starts at 4.0 damage, but when he runs out of money he receives a 62.5% damage modifier (Down to 2.5 damage at base damage)."},
        {str = "Shooting tears while you have any money, or while Golden Stopwatch's effect is active, converts the tear into a coin tear and removes one penny from the player."},
            {str = "While Golden Stopwatch's effect is active, coin tears that do not hit enemies still drop a penny. Grants +10% damage for the room."},
    },
    encyclopedia_details = {
        name = "Tainted Gehazi",
        anmfile = "gfx/ui/main menu/encyc_portraits.anm2",
        anmname = "Gehazi",
        description = "The indebted",
    }
}

players[GODMODE.registry.players.deli] = {
    eid_birthright = "↑ +20% Damage#↑ +10% Tears",
    update = function(self, player, data)
        data.added_deli_birthright = GODMODE.save_manager.get_player_data(player, "DeliBirthright", "false") == "true"
        data.trisagion_time = (data.trisagion_time or 0) + 1    

        if not data.added_deli_birthright and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            GODMODE.save_manager.set_player_data(player, "DeliBirthright", "true",true)
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
    end,
    clone_fire = function(self, player, position, base_tear, stored)
        local data = GODMODE.get_ent_data(player)
        local moff = player:GetTearMovementInheritance(player.Velocity)*0.25
        local off = (position - player.Position):Length()
        if off > 32 then return end 
        local og_laser = data.proj_ref:ToLaser()
        if og_laser and og_laser.Timeout == 0 then return end 

        if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) or player:HasCollectible(GODMODE.registry.items.uncommon_cough) then
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
                        t:SetTimeout(player.MaxFireDelay)
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
                        laser:SetMaxDistance(100 + 300 * ang_scale)
                        laser.IsActiveRotating = data.proj_ref:ToLaser().IsActiveRotating
                        laser.OneHit = data.proj_ref:ToLaser().OneHit
                        laser.OneHit = data.proj_ref:ToLaser().OneHit
                        laser.Size = data.proj_ref.Size
                        laser.SizeMulti = data.proj_ref.SizeMulti
                    end

                    
                    t.Scale = t.Scale * (0.5 + ang_scale * 0.5)
                    t.CollisionDamage = t.CollisionDamage * (0.25 + ang_scale * 0.75)
                    t:Update()

                    if stored ~= nil then 
                        table.insert(stored, t)
                    end
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
                    local v = Vector(math.cos(math.rad(f)),math.sin(math.rad(f))):Resized(player.ShotSpeed*10)

                    local l2 = nil
                    if player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) then 
                        f = math.rad(f)
                        l2 = player:FireTear(player.Position,v,true,true,false)
                    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_ANTI_GRAVITY) then
                        l2 = player:FireDelayedBrimstone(f,player)
                        l2.Variant = 2
                    else
                        local laser = data.proj_ref:ToLaser()
                        l2 = EntityLaser.ShootAngle(LaserVariant.THICK_RED,laser.Position,f,laser.Timeout,
                            Vector(laser.ParentOffset:Rotated(f).X,laser.ParentOffset.Y),laser.SpawnerEntity or laser.Parent)--player:FireBrimstone(v,v.SpawnerEntity)
                    end

                    if l2:ToLaser() then 
                        local laser = l2:ToLaser()
                        local max_dist = 256
                        laser.Radius = og_laser.Radius
                        laser.Shrink = og_laser.Shrink
                        laser.RotationSpd = og_laser.RotationSpd
                        laser.RotationDelay = og_laser.RotationDelay
                        laser:SetMaxDistance(max_dist * (0.25 + ang_scale * 0.75))
                        laser.IsActiveRotating = og_laser.IsActiveRotating
                        laser.OneHit = og_laser.OneHit
                        laser.Size = data.proj_ref.Size
                        laser.SizeMulti = data.proj_ref.SizeMulti
                        laser.TearFlags = og_laser.TearFlags
                        laser:SetColor(og_laser:GetColor(),laser.Timeout + 10, 1, false, false)
                    else
                        l2.Scale = l2.Scale * (0.5 + ang_scale * 0.5)
                    end

                    l2.CollisionDamage = (og_laser or {CollisionDamage=base_tear.CollisionDamage}).CollisionDamage * (0.25 + ang_scale * 0.75)

                    if stored ~= nil then 
                        table.insert(stored, t)
                    end
                end
            end
        else
            for i=-3,3 do
                local real_ind = i
                if i == 0 then real_ind = -4 end 
                local dir = (data.cur_deli_ang + (360 / 8 * (real_ind))) % 360
                local ang_scale = 1 / math.abs(real_ind)
                -- GODMODE.log("cur_ang="..data.cur_deli_ang..",dir="..dir..",scale="..ang_scale,true)

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

                if not t:ToLaser() then 
                    t.Scale = t.Scale * (0.25 + ang_scale * 0.75)
                end

                t.CollisionDamage = t.CollisionDamage * (0.25 + ang_scale * 0.75)
                if stored ~= nil then 
                    table.insert(stored, t)
                end
            end
        end
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(self, player)
            local mod = 0.65
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                mod = 0.85
            end

            player.Damage = player.Damage * mod
        end,
        [CacheFlag.CACHE_RANGE] = function(self, player)
            player.TearRange = player.TearRange - GODMODE.util.grid_size / 2.0
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(self, player)
            local mod = 1.2
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                mod = 1.1
            end
            player.MaxFireDelay = player.MaxFireDelay * mod
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(self, player)
            player.ShotSpeed = player.ShotSpeed - 0.6
        end
    },
    encyclopedia_entry = {{ -- Start Data
        {str = "Start Data", fsize = 2, clr = 3, halign = 0},
        {str = "Stats:"},
        {str = "- HP: 4 Red Hearts"},
        {str = "- Speed: 1.00"},
        {str = "- Tear Rate: 2.31 (x1.2 multiplier)"},
        {str = "- Damage: 2.28 (x0.65 multiplier)"},
        {str = "- Range: 3.90"},
        {str = "- Shot Speed: 0.60"},
        {str = "- Luck: 0.00"},
    },
    { -- Birthright
        {str = "Birthright", fsize = 2, clr = 3, halign = 0},
        {str = "The damage and fire rate multipliers are lessened."},
        {str = "- x0.85 damage instead of x0.65"},
        {str = "- x1.1 fire rate instead of x1.2"},
    }},
    encyclopedia_details = {
        name = "Deli",
        anmfile = "gfx/ui/main menu/encyc_portraits.anm2",
        anmname = "Deli",
    }
}

players[GODMODE.registry.players.t_deli] = {
    eid_birthright = "One less eye closes any time eyes close on your halo#Shifting from Delusion to Oblivion creates a tear burst#Soul hearts have a 20% chance to open your halo's eyes", pocket_item = GODMODE.registry.items.deli_oblivion, tainted = true,
    red_health = false, soul_health = true, bone_health = false, max_hits = 1, devil_choice = true,
    pocket_valid = {[GODMODE.registry.items.deli_oblivion] = true, [GODMODE.registry.items.deli_delusion] = true}, --allows for more than 1 pocket active
    update = function(self, player, data)
        data.trisagion_time = (data.trisagion_time or 0) + 1   
        -- GODMODE.tainted_deli = true 
        local eyes = tonumber(GODMODE.save_manager.get_player_data(player,"EyesOpen","16"))
        local hidden = eyes == 0 or GODMODE.save_manager.get_player_data(player,"RingHidden","false") == "true"

        if hidden then 
            self.max_hits = 1
        else
            self.max_hits = 2

            if GODMODE.util.get_player_hits(player) == 1 then 
                player:AddSoulHearts(1)
            end
        end

        player.SplatColor = Color(0,0,0,1,0.95,0.95,0.95)

        if (data.t_deli_immune or 0) > 0 then 
            if eyes == 0 then 
                player.Color = Color(player.Color.R,player.Color.G,player.Color.B,((data.t_deli_immune or 0) % 10 < 5 and 1 or 0))
            end
        end

        -- if data.halo == nil or data.halo:IsDead() then
        --     data.halo = Isaac.Spawn(GODMODE.registry.entities.deli_halo.type, GODMODE.registry.entities.deli_halo.variant, 0, player.Position, Vector.Zero, player)
        --     data.halo:ToFamiliar().Player = player
        --     data.halo:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        -- end
    end,
    clone_fire = function(self, player, position, base_tear)
        local data = GODMODE.get_ent_data(player)
        data.deli_rotate = not (data.deli_rotate or false)
        local tears = {}
        players[GODMODE.registry.players.deli]:clone_fire(player,position,base_tear,tears)
        table.insert(tears, base_tear)
        for i=1, #tears do 
            local tear = tears[i]

            if tear:ToTear() then 
                tear = tear:ToTear()
                local t_data = GODMODE.get_ent_data(tear)
                
                if t_data.deli_rotate == nil then 
                    t_data.deli_rotate = data.deli_rotate
                end
            end
        end
    end,
    stats = {
        [CacheFlag.CACHE_SPEED] = function(self, player)
            player.MoveSpeed = player.MoveSpeed - 0.1
            player:TryRemoveNullCostume(GODMODE.registry.costumes.t_deli_eyes)
            player:AddNullCostume(GODMODE.registry.costumes.t_deli_eyes)
        end,
        [CacheFlag.CACHE_DAMAGE] = function(self, player)
            local mod = 0.9
            player.Damage = player.Damage * mod
        end,
        [CacheFlag.CACHE_RANGE] = function(self, player)
            player.TearRange = player.TearRange - GODMODE.util.grid_size * 1.5
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(self, player)
            local mod = 1.1
            player.MaxFireDelay = player.MaxFireDelay * mod
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(self, player)
            player.ShotSpeed = player.ShotSpeed - 0.25
        end,
        [CacheFlag.CACHE_TEARFLAG] = function(self, player)
            player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL-- | TearFlags.TEAR_WIGGLE
        end,
        [CacheFlag.CACHE_FAMILIARS] = function(self, player)
            player:CheckFamiliar(GODMODE.registry.entities.deli_halo.variant, 1, player:GetDropRNG())
            local eyes = tonumber(GODMODE.save_manager.get_player_data(player,"EyesOpen","16"))

            local hidden = eyes == 0 or GODMODE.save_manager.get_player_data(player,"RingHidden","false") == "true"
            player:CheckFamiliar(GODMODE.registry.entities.deli_eye.variant, hidden and eyes or 0, player:GetDropRNG())
        end
    },
    encyclopedia_entry = {{ -- Start Data
        {str = "Start Data", fsize = 2, clr = 3, halign = 0},
        {str = "Stats:"},
        {str = "- HP: 1 Delirious Heart"},
        {str = "- Speed: 0.90"},
        {str = "- Tear Rate: 2.50 (x1.1 multiplier)"},
        {str = "- Damage: 3.15 (x0.9 multiplier)"},
        {str = "- Range: 3.90"},
        {str = "- Shot Speed: 0.60"},
        {str = "- Luck: 0.00"},
    },
    { -- Birthright
        {str = "Birthright", fsize = 2, clr = 3, halign = 0},
        {str = "1 less eye closes any time eyes would close on your Delirious Halo."},
        {str = "Shifting from Delusion to Oblivion creates a burst of tears."},
        {str = "Soul hearts gain a 20% chance to become Delirious Hearts, opening eyes on your Delirious Halo instead of being unusable."},
    }},
    encyclopedia_details = {
        name = "Deli",
        anmfile = "gfx/ui/main menu/encyc_portraits_alt.anm2",
        anmname = "Tainted Deli",
        description = "The delirious",
    }

}

players[GODMODE.registry.players.the_sign] = {
    eid_birthright = "↑ Removes all Broken Hearts#↑ Removes 25% speed penalty", red_health = false, soul_health = true,
    init = function(self, player)
        local kills = tonumber(GODMODE.save_manager.get_persistant_data("PalaceKills", "0", true))
        local data = GODMODE.get_ent_data(player)
        data.added_sign_start = GODMODE.save_manager.get_player_data(player, "SignStarted", "false") == "true"

        if data.added_sign_start == false then
            player:AddBrokenHearts(math.max(0,math.min(11,math.floor(11-kills*2.2))))
            player:AddSoulHearts(math.floor(kills/2)*2)

            if kills == 5 then
                player:AddEternalHearts(1)
            end

            GODMODE.save_manager.set_player_data(player, "SignStarted", "true",true)
        end

        player:TryRemoveNullCostume(GODMODE.registry.costumes.the_sign_wings)
        player:AddNullCostume(GODMODE.registry.costumes.the_sign_wings)
    end,
    stats = {
        [CacheFlag.CACHE_DAMAGE] = function(self, player)
            local kills = tonumber(GODMODE.save_manager.get_persistant_data("PalaceKills", "1"))
            local hearts = math.max(0,(10-kills * 2))
            player.Damage = player.Damage - 1.25 + hearts/10*1.25
        end,
        [CacheFlag.CACHE_SPEED] = function(self, player)
            local mod = 0.75

            if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                mod = 1.0
            end

            player.MoveSpeed = player.MoveSpeed * mod
        end,
        [CacheFlag.CACHE_SHOTSPEED] = function(self, player)
            player.ShotSpeed = player.ShotSpeed - 0.25
        end,
        [CacheFlag.CACHE_FIREDELAY] = function(self, player)
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.25)
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.5,true)
        end,
        [CacheFlag.CACHE_FLYING] = function(self, player)
            player.CanFly = true
        end,
        [CacheFlag.CACHE_TEARFLAG] = function(self, player)
            player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_QUADSPLIT
        end,
        [CacheFlag.CACHE_RANGE] = function(self, player)
            local mod = player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) and 0.75 or 1
            player.TearRange = player.TearRange * mod + GODMODE.util.grid_size * 0.75
        end,
    },
    update = function(self, player, data)
        if true then
        -- if kills > 0 then

            data.added_sign_birthright = GODMODE.save_manager.get_player_data(player, "SignBirthright", "false") == "true"
            
            if not data.added_sign_birthright and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                GODMODE.save_manager.set_player_data(player, "SignBirthright", "true",true)
                player:AddBrokenHearts(-12)
                player:AddSoulHearts(2)
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end

            if data.flame == nil or data.flame:IsDead() then
                data.flame = Isaac.Spawn(GODMODE.registry.entities.sign_flame.type, GODMODE.registry.entities.sign_flame.variant, 0, player.Position, Vector.Zero, player)
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
    end,
    encyclopedia_entry = {{ -- Start Data
        {str = "Start Data", fsize = 2, clr = 3, halign = 0},
        {str = "Stats:"},
        {str = "- HP: 1 Soul Heart to 3 Soul Hearts and 1 Eternal Heart"},
        {str = "- Speed: 0.75 (x0.75 multiplier)"},
        {str = "- Tear Rate: 3.48"},
        {str = "- Damage: 2.83 to 3.25"},
        {str = "- Range: 7.31"},
        {str = "- Shot Speed: 0.75"},
        {str = "- Luck: 0.00"},
    },
    { -- Notes
        {str = "Notes", fsize = 2, clr = 3, halign = 0},
        {str = "The stats of The Sign depend on how many times you have defeated The Fallen Light's final phase."},
        {str = "The Sign fires tears backwards, but movement influences the speed of your tears drastically."},
    },
    { -- Birthright
        {str = "Birthright", fsize = 2, clr = 3, halign = 0},
        {str = "Removes all Broken Hearts, and removes the speed multiplier."},
    }},
    encyclopedia_details = {
        name = "The Sign",
        anmfile = "gfx/ui/main menu/encyc_portraits.anm2",
        anmname = "The Sign",
        description = "The shackled",
    }

}

players[PlayerType.PLAYER_THELOST_B] = {
    red_health = false, soul_health = true,
    init = function(self, player)
        if player.SubType == PlayerType.PLAYER_THELOST_B and GODMODE.save_manager.get_config("TaintedLostWish","true") == "true" then
            player:AddCollectible(GODMODE.registry.items.moms_wish,1,true,ActiveSlot.SLOT_POCKET)
        end
    end,
}

return players