-- this file both adds a small API to easily reference and integrate godmode with other mods that choose to add official support

GODMODE.api = {}

-- adds a new stat to the stat score system for Correction Rooms. 
-- stat_name: string stat identifier
-- stat_max: float maximum stat value
-- stat_calc_func: function to get the current stat value (this value is automatically clamped to stat_max if it is higher than it)
GODMODE.api.add_stat_to_score = function(stat_name, stat_max, stat_calc_func)
    GODMODE.util.stat_dist[stat_name] = stat_max or 0
    -- this requires patching into the correction shrine code if you want to add another "buffable" stat inside the correction room.
    GODMODE.util.stat_buff[stat_name] = false
    GODMODE.util.stat_scale[stat_name] = stat_calc_func or function(player) return 0 end
end

-- adds a new tearflag to the tearflag stat score. 
-- tearflag: custom TearFlag
-- add_val: function. Check for and return the statscore modifier for your custom tearflag. The max value for the tearflag stat score is 5, so keep that in mind.
-- examples of basegame values:
--[[
	TearFlags.TEAR_SPECTRAL = 0.3,
	TearFlags.TEAR_PIERCING = 0.4,
	TearFlags.TEAR_HOMING = 0.5,
	TearFlags.TEAR_SLOW = 0.1,
]] 
GODMODE.api.add_tearflag_to_statscore = function(tearflag, add_val)
    GODMODE.util.tearflag_mods[tearflag] = add_val or function(player) return 0 end
end

-- adds a new transformation to the transformation stat score. 
-- transform: string. transformation name
-- add_val: function. Check for and return the statscore modifier for your custom transformation. The max value for the transformation stat score is 4, so keep that in mind.
-- examples of basegame values:
--[[
	PlayerForm.PLAYERFORM_GUPPY = 2.5,
	PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES = 2.0,
	PlayerForm.PLAYERFORM_MUSHROOM = 0.1,
	PlayerForm.PLAYERFORM_ANGEL = 0.75,
]] 
GODMODE.api.add_transform_to_statscore = function(transform, add_val)
    GODMODE.util.transform_mods[transform] = add_val or function(player) return 0 end
end

-- sets the faithless heart and damage charges for Call of the Void. Damage charges are gained from the door hazard, faithless hearts are gained from passing the time limit.
-- faithless: int. The number of faithless heart charges active
-- damaging: int. The number of damaging charges active
GODMODE.api.set_cotv_charges = function(faithless, damaging)
    GODMODE.save_manager.set_data("VoidBHProj",faithless)
    GODMODE.save_manager.set_data("VoidDMProj",damaging,true)
end

-- gets the current number of charges active for Call of the Void, with the faithless parameter dictating whether you're getting the faithless heart charges or the damaging charges.
-- faithless: boolean. True to get the # of faithless charges, false to get the # of damaging charges
GODMODE.api.get_cotv_charges = function(faithless)
    faithless = faithless or true 
    return faithless and tonumber(GODMODE.save_manager.get_data("VoidBHProj","0")) or tonumber(GODMODE.save_manager.get_data("VoidDMProj","0"))
end

-- registers a custom file to the godmode godhook system.
-- file: include() file. This should return an object with the godmode functions, ideally just copy paste an existing item and use that for a reference.
-- note that for entities and items you need specific variables in your returned userdata:
-- entities: type (int), variant (int)
-- items: instance (int)
-- these should just be set to Isaac.GetXByName() or your existing registry 
GODMODE.api.add_to_godhooks = function(file)
    GODMODE.godhooks.register_object(file)
end

-- creates a new observatory in the stage.
-- returns the RoomDescriptor if the room was generated succesfully, false if it was not.
GODMODE.api.generate_observatory = function()
    local ret = GODMODE.gen_observatory_in_stage(false)

    if ret ~= false then 
        GODMODE.cached_observatory_ids = nil 
        GODMODE.observatory_door_cache = nil    
    end

    return ret
end

-- sets whether the specified room should render as an observatory.
-- safegrididx: int. This should just be the roomdescriptor's SafeGridIndex. Defaults to the current room's safe grid index.
-- observatory: boolean. True to set the specified room to render observatory fx, false to clear/not set it to render the observatory fx. Defaults to true.
GODMODE.api.set_observatory = function(safegrididx, observatory)
    safegrididx = safegrididx or GODMODE.level:GetCurrentRoomDesc().SafeGridIndex
    observatory = observatory or true 

    if observatory then 
        GODMODE.save_manager.add_list_data("ObservatoryGridIdx",safegrididx,true)
    else
        GODMODE.save_manager.remove_list_data("ObservatoryGridIdx",safegrididx,true)
    end
    
    GODMODE.cached_observatory_ids = nil 
    GODMODE.observatory_door_cache = nil
end

-- adds a new pickup variant that chest infestors are allowed to manifest from.
-- pickup_variant: int. This should be a valid pickup variant "5.pickup_variant"
-- mimic_data: userdata. This holds all of the metadata for the chest infestor's manifestation of the pickup. An example is included for the default value.
GODMODE.api.add_chest_infest_variant = function(pickup_variant, mimic_data)
    assert(GODMODE.registry.mimic_chests[pickup_variant] == nil,GODMODE.log("[ERROR] Existing Chest Infestor pickup_variant \'"..pickup_variant.."\', cannot register. Please choose a new variant, or remove the old one before calling this function."))

    GODMODE.registry.mimic_chests[pickup_variant] = mimic_data or --example
    {
        -- chest position offset from the null position of the chest infestor (use if your chest is not positioned correctly)
        null_pos_off=Vector(0,-2),
        -- eye position offset from the opened chest (use if the eyes are not placed in the opened chest correctly)
        eye_pos_off=Vector(0,-2),
        -- all fields below the offsets "null_pos_off" and "eye_pos_off" are optional 

        -- should unlock chest on attack?
        unlock=true,
        -- should unlock chest on kill?
        death_unlock = false,

        -- called when the "PreAttack" animation event is triggered. Mostly useful for SFX, as this is the telegraph for the attack. "ent" is the chest infestor
        -- preattack=function(ent,data,sprite) end,

        -- called when the "Attack" animation event is triggered, main attack here. "ent" is the chest infestor, if unlock=true then the chest opens here via chest infestor 
        -- attack=function(ent,data,sprite) 
                -- data.fire_ring = function(self,ent,count,spd,ang_offset,scale,flags)
                -- data.launch_ring = function(self,ent,count,spd,ang_offset,scale,flags)
                -- data.launch_bullet = function(self,ent,pos,scale,flags)
                -- data.fire_bullet = function(self,ent,ang,spd,scale,flags)
        --
        --     data:fire_ring(ent,10,7.5+(GODMODE.game.Difficulty % 2) * 2,ent:GetDropRNG():RandomFloat() * 36.0,1.25,ProjectileFlags.DECELERATE)
        -- end, 

        -- -- called each tick when the chest is infested. "ent" is the chest infestor
        -- atk_update = function(ent,data,sprite) end,
        
        -- -- called to add additional checks when trying to spawn a chest infestor for this pickup variant.
        -- can_spawn = function(pickup) return true end
    }
end
















--EXTERNAL ITEM DESCRIPTIONS SUPPORT
if EID then
    GODMODE.eid_transform_anim = Sprite()
    GODMODE.eid_transform_anim:Load("gfx/ui/eid_transformations.anm2", true)
    
    if EID.addIcon then 
        -- Add icon with the same Identifier as the transformation (NewTransform1)
        EID:addIcon(GODMODE.util.eid_transforms.CELESTE, "celeste", 1, 16, 16, -2, -2, GODMODE.eid_transform_anim)
        EID:addIcon(GODMODE.util.eid_transforms.CYBORG, "cyborg", 1, 16, 16, -3, -3, GODMODE.eid_transform_anim)
        EID:addIcon(GODMODE.util.eid_transforms.CULTIST, "cultist", 1, 16, 16, -3, -3, GODMODE.eid_transform_anim)
        EID:addIcon(GODMODE.util.eid_transforms.JACK_OF_ALL_TRADES, "jack", 1, 16, 16, -2, -2, GODMODE.eid_transform_anim)
    
        -- The icon will now be assigned to this transformation entry:
        EID:createTransformation(GODMODE.util.eid_transforms.CELESTE, "Celeste!")
        EID:createTransformation(GODMODE.util.eid_transforms.CYBORG, "Cyborg!")
        EID:createTransformation(GODMODE.util.eid_transforms.CULTIST, "Cultist!")
        EID:createTransformation(GODMODE.util.eid_transforms.JACK_OF_ALL_TRADES, "ANYTHING!!!!!!")
    end

    if EID.addCollectible then 
        for _,item in ipairs(GODMODE.items) do
            if item.eid_description then
                if item.trinket then
                    EID:addTrinket(item.instance, item.eid_description)
    
                    if item.eid_transforms ~= nil then 
                        EID:assignTransformation("trinket", item.instance, ""..item.eid_transforms)
                    end
                else
                    EID:addCollectible(item.instance, item.eid_description)
    
                    if item.eid_transforms ~= nil then 
                        EID:assignTransformation("collectible", item.instance, item.eid_transforms)
                    end
                end
            elseif item.items and item.transformation == true and item.eid_transform ~= nil then 
                for item2,_ in pairs(item.items) do 
                    if item2 ~= GODMODE.registry.items.jack_of_all_trades then 
                        EID:assignTransformation("collectible", item2, item.eid_transform)
                    end
                end
            end
        end
    
        EID:addCollectible(GODMODE.registry.items.jack_of_all_trades, "Counts as one item towards all transformations")
        EID:addCollectible(GODMODE.registry.items.questrock_1, "Part 1 of 4, allows access to the Gatekeeper in Sheol#!!!!!!!!!NOTE!!!!!!!!! NOT CURRENTLY IMPLEMENTED!")
        EID:addCollectible(GODMODE.registry.items.questrock_2, "Part 2 of 4, allows access to the Gatekeeper in Sheol#!!!!!!!!!NOTE!!!!!!!!! NOT CURRENTLY IMPLEMENTED!")
        EID:addCollectible(GODMODE.registry.items.questrock_3, "Part 3 of 4, allows access to the Gatekeeper in Sheol#!!!!!!!!!NOTE!!!!!!!!! NOT CURRENTLY IMPLEMENTED!")
        EID:addCollectible(GODMODE.registry.items.questrock_4, "Part 4 of 4, allows access to the Gatekeeper in Sheol#!!!!!!!!!NOTE!!!!!!!!! NOT CURRENTLY IMPLEMENTED!")
        EID:addCollectible(GODMODE.registry.items.blood_key, "Allows you to enter the Ivory Palace in Sheol")
        EID:assignTransformation("collectible", GODMODE.registry.items.jack_of_all_trades, GODMODE.util.eid_transforms.JACK_OF_ALL_TRADES)
        EID:addCollectible(GODMODE.registry.items.brass_cross, "↑ +2 Soul Hearts#↑ +25% chance to encounter a blessed floor")

        if GODMODE.save_manager.get_config("MoreOptionsRework","true") == "true" then 
            EID:addCollectible(CollectibleType.COLLECTIBLE_MORE_OPTIONS, "↑ Treasure rooms have more items# Each item is sequentially assigned a group, 1 to (1+More Options Quantity), indicated on the item pedestal# You can only pick one item from each group")    
        end
        
        EID.descriptions["en_us"].collectibles[CollectibleType.COLLECTIBLE_BLACK_CANDLE][3] = EID.descriptions["en_us"].collectibles[CollectibleType.COLLECTIBLE_BLACK_CANDLE][3].."#↓ Prevents Blessings"
    end

    if EID.addBirthright then
        for name,player in pairs(GODMODE.players) do
            if player.eid_birthright then
                EID:addBirthright(name,player.eid_birthright)
            end
        end

        GODMODE.log("Loaded Godmode External Items Description Integration!")
    end
end

-- ENCYCLOPEDIA SUPPORT
if Encyclopedia then 
    local class = "Godmode Achieved"
    -- Encyclopedia.HideItem(Isaac.GetItemIdByName("Morphine Used"))
    for _,item in ipairs(GODMODE.items) do
        if item.encyc_entry then
            if item.trinket then
                Encyclopedia.AddTrinket({ -- 5.TRINKET_PURPLE_HEART
                    Class = class,
                    ID = item.instance,
                    WikiDesc = item.encyc_entry,
                    ModName = "Godmode Achieved"
                })
            else
                Encyclopedia.AddItem({
                    Class = class,
                    ID = item.instance,
                    WikiDesc = item.encyc_entry,
                    ModName = "Godmode Achieved",
                },"items")
            end
        end
    end

    for id,player in pairs(GODMODE.players) do 
        if player.encyclopedia_entry ~= nil and player.encyclopedia_details ~= nil then 
            local add_func = Encyclopedia.AddCharacter

            if Isaac.GetPlayerTypeByName(player.encyclopedia_details.anmname,true) == id then 
                add_func = Encyclopedia.AddCharacterTainted
            end
            add_func({ -- 2.PLAYER_CAIN
                Class = class,
                Name = player.encyclopedia_details.name or "",
                Description = player.encyclopedia_details.description or null,
                ID = id,
                Sprite = Encyclopedia.RegisterSprite(player.encyclopedia_details.anmfile, player.encyclopedia_details.anmname, 0),
                ModName = "Godmode Achieved",
                WikiDesc = player.encyclopedia_entry,
            })    
        end
    end

    Encyclopedia.AddItem({
        Class = class,
        ID = Isaac.GetItemIdByName("Morphine Used"),
        ModName = "Godmode Achieved",
        Hide = true,
    },"items")

    Encyclopedia.AddItem({
        Class = class,
        ID = GODMODE.registry.items.jack_of_all_trades,
        ModName = "Godmode Achieved",
        WikiDesc = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Grants an entry to every base transformation as well as Godmode transformation."},
            },
        }
    },"items")
    Encyclopedia.AddItem({
        Class = class,
        ID = GODMODE.registry.items.brass_cross,
        ModName = "Godmode Achieved",
        WikiDesc = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Grants +2 soul hearts, and the chance to encounter a floor blessing is increased by 25%."},
            },
        }
    },"items")
    Encyclopedia.AddItem({
        Class = class,
        ID = GODMODE.registry.items.blood_key,
        ModName = "Godmode Achieved",
        WikiDesc = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Obtained by giving the Stifled Gatekeeper in Sheol an angel item. Allows for the player to reach the Ivory Palace, the final stage of Godmode."},
            },
        }
    },"items")

end

-- PREAPPEARANCE SUPPORT
if PreAppearance then 
    local blacklist_adds = {"Red Coin", "Unholy Order", "Crossbones Shield", "Aztec Shield", "Heart Container (Pickup)",
        "Soft Serve Spawner", "Soft Serve Puddle (White)", "Soft Serve Puddle (Pink)", "Soft Serve Puddle (Red)", "Soft Serve Puddle (Light Brown)", "Soft Serve Puddle (Dark Brown)",
        "Soft Serve Puddle (White)", "Crack The Sky (With Tell)", "Celestial Swipe", "Adramolech's Fuel", "Fallen Light Crack",
        "War Banner", "War Banner (Red Aura)", "War Banner (Yellow Aura)", "War Banner (Blue Aura)", "Papal Flame", "Bomb Barrel", "Golden Scale", "Elohim's Throne",
        "Masked Angel Statue", "Keepah (Shop Parrot)", "Trap Turret", "Lucifer's Palace Mural", "Ivory Portal", "Ooze Turret", "Ooze Turret (Always On)"}

    for _,ent in ipairs(blacklist_adds) do 
        PreAppearance.AddToBlacklist(Isaac.GetEntityTypeByName(ent),Isaac.GetEntityVariantByName(ent),nil)
    end    
end

-- ENHANCED BOSS BARS

if HPBars then -- check if the mod is installed
    local bar_path = "gfx/ui/boss/bar_icons/"
    local bar_path_bar = "gfx/ui/boss/bars/"
    HPBars.Conditions["isSubtype"] = function(entity,args) return entity.SubType == args[1] end 
	HPBars.BossDefinitions[GODMODE.registry.entities.souleater.type.."."..GODMODE.registry.entities.souleater.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."souleater.png", -- path to the .png file that will be used as the icon for this boss
		conditionalSprites = {
			{"isHPSmallerPercent", bar_path.."souleater2.png", {40}}
		},
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
	HPBars.BossDefinitions[GODMODE.registry.entities.the_ritual.type.."."..GODMODE.registry.entities.the_ritual.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."ritual_0.png", -- path to the .png file that will be used as the icon for this boss
		conditionalSprites = {
			{"isHPSmallerPercent", bar_path.."ritual_3.png", {25}},
			{"isHPSmallerPercent", bar_path.."ritual_2.png", {50}},
			{"isHPSmallerPercent", bar_path.."ritual_1.png", {75}},
		},
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
	HPBars.BossDefinitions[GODMODE.registry.entities.grand_marshall.type.."."..GODMODE.registry.entities.grand_marshall.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."grand_marshal.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
	HPBars.BossDefinitions[GODMODE.registry.entities.bowl_play.type.."."..GODMODE.registry.entities.bowl_play.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."bowl_play_corny.png", -- path to the .png file that will be used as the icon for this boss
        conditionalSprites = {
			{"isSubtype", bar_path.."bowl_play_smiley.png", {1}},
		},
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.sacred_mind.type.."."..GODMODE.registry.entities.sacred_mind.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."sacred_mind.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.sacred_body.type.."."..GODMODE.registry.entities.sacred_body.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."sacred_body.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.sacred_soul.type.."."..GODMODE.registry.entities.sacred_soul.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."sacred_soul.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.the_fallen_light.type.."."..GODMODE.registry.entities.the_fallen_light.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
        sprite = bar_path.."fl_0.png", -- path to the .png file that will be used as the icon for this boss
        conditionalSprites = {
            {"isHPSmallerPercent", bar_path.."fl_2.png", {44.4}},
            {"isHPSmallerPercent", bar_path.."fl_1.png", {66.6}},
        },
        barStyle = "GODMODE_FallenLight",
        offset = Vector(5, -5) -- number of pixels the icon should be moved from its center versus the left-side of the bar
    }
    HPBars.BossIgnoreList[GODMODE.registry.entities.the_fallen_light.type.."."..GODMODE.registry.entities.the_fallen_light.variant] = function(entity) 
		return GODMODE.get_ent_data(entity) ~= nil and GODMODE.get_ent_data(entity).soul_made == true
	end
    HPBars.BossDefinitions[GODMODE.registry.entities.the_sign.type.."."..GODMODE.registry.entities.the_sign.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
        sprite = bar_path.."sign_0.png", -- path to the .png file that will be used as the icon for this boss
        conditionalSprites = {
            {"animationNameContains", bar_path.."sign_1.png", {"1"}},
            {"animationNameContains", bar_path.."sign_2.png", {"2"}},
            {"animationNameContains", bar_path.."sign_3.png", {"3"}},
            {"animationNameContains", bar_path.."sign_4.png", {"4"}},
            {"animationNameContains", bar_path.."sign_5.png", {"Death"}},
        },
        offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
    }
    HPBars.BossDefinitions[GODMODE.registry.entities.mega_worm.type.."."..GODMODE.registry.entities.mega_worm.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."megaworm.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.blightfly.type.."."..GODMODE.registry.entities.blightfly.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."blight_fly.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.bubbly_plum.type.."."..GODMODE.registry.entities.bubbly_plum.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."bubbly_plum.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.bathemo_swarm.type.."."..GODMODE.registry.entities.bathemo_swarm.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."bathemo_swarm.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.bathemo.type.."."..GODMODE.registry.entities.bathemo.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."bathemo.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.ludomaw.type.."."..GODMODE.registry.entities.ludomaw.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."ludomaw.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.godmode_famine.type.."."..GODMODE.registry.entities.godmode_famine.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."famine.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.godmode_war.type.."."..GODMODE.registry.entities.godmode_war.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."war.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    
    if HPBars.BossDefinitions["65.10"].conditionalSprites ~= nil then 
        table.insert(HPBars.BossDefinitions["65.10"].conditionalSprites, {"isSubtype", bar_path.."war_phase2.png", {700}})
    else
        HPBars.BossDefinitions["65.10"].conditionalSprites = {{"isSubtype", bar_path.."war_phase2.png", {700}}}
    end

    HPBars.BossDefinitions[GODMODE.registry.entities.hostess.type.."."..GODMODE.registry.entities.hostess.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."hostess.png", -- path to the .png file that will be used as the icon for this boss
        conditionalSprites = {
            {"animationNameContains", bar_path.."hostess_2.png", {"2"}},
            {"animationNameEqual", bar_path.."hostess_2.png", {"Phase"}},
            {"animationNameContains", bar_path.."hostess_3.png", {"3"}},
        },
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.hostess_cluster.type.."."..GODMODE.registry.entities.hostess_cluster.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."hostess_tendril.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.furnace_knight.type.."."..GODMODE.registry.entities.furnace_knight.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."furnace_guard.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.bloody_uriel.type.."."..GODMODE.registry.entities.bloody_uriel.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."bloody_uriel.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[GODMODE.registry.entities.bloody_gabriel.type.."."..GODMODE.registry.entities.bloody_gabriel.variant] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."bloody_gabriel.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}

    HPBars.BarStyles["GODMODE_FallenLight"] = {
        sprite = bar_path_bar .. "fallen_light_bar.png",
		barAnm2 = bar_path_bar .. "fallen_light_bosshp.anm2",
		barAnimationType = "Animated",
		overlayAnm2 = bar_path_bar .. "fallen_light_bosshp_overlay.anm2",
		overlayAnimationType = "Animated",
		tooltip = "'Fallen Light' - Boss themed",

        idleColoring = HPBars.BarColorings.none,
		hitColoring = Color(196.0/255.0,0,0,1),
	}
    
end


-- STAGEAPI 
function load_stageapi_integration()
    GODMODE.stages = {}
    StageAPI.UnregisterCallbacks(GODMODE.mod_id)

    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.recluse, {
        Name = "gfx/ui/boss/names/arac.png",
        Portrait = "gfx/ui/stage/arac.png",
        NoShake = false,
        -- Controls = "gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.t_recluse, {
        Name = "gfx/ui/boss/names/arac.png",
        Portrait = "gfx/ui/stage/tainted_arac.png",
        NoShake = false,
        -- Controls = "gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.xaphan, {
        Name = "gfx/ui/boss/names/xaphan.png",
        Portrait = "gfx/ui/stage/xaphan.png",
        NoShake = false,
        -- Controls = "gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.t_xaphan, {
        Name = "gfx/ui/boss/names/xaphan.png",
        Portrait = "gfx/ui/stage/tainted_xaphan.png",
        NoShake = false,
        -- Controls = "gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.deli, {
        Name = "gfx/ui/boss/names/deli.png",
        Portrait = "gfx/ui/stage/deli.png",
        NoShake = false,
        -- Controls = "gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.t_deli, {
        Name = "gfx/ui/boss/names/deli.png",
        Portrait = "gfx/ui/stage/tainted_deli.png",
        NoShake = false,
        -- Controls = "gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.elohim, {
        Name = "gfx/ui/boss/names/elohim.png",
        Portrait = "gfx/ui/stage/elohim.png",
        NoShake = false,
        -- Controls = "gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.t_elohim, {
        Name = "gfx/ui/boss/names/elohim.png",
        Portrait = "gfx/ui/stage/tainted_elohim.png",
        NoShake = false,
        -- Controls = "gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.gehazi, {
        Name = "gfx/ui/boss/names/gehazi.png",
        Portrait = "gfx/ui/stage/gehazi.png",
        NoShake = false,
        -- Controls = "gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.t_gehazi, {
        Name = "gfx/ui/boss/names/gehazi.png",
        Portrait = "gfx/ui/stage/tainted_gehazi.png",
        NoShake = false,
        -- Controls = "gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.the_sign, {
        Name = "gfx/ui/boss/names/thesign.png",
        Portrait = "gfx/ui/stage/thesign.png",
        NoShake = false,
        -- Controls = "gfx/backdrop/controls_fiend.png"
    })
    
    function create_stage(stage_file)
        local stage_file = include("scripts.definitions.stages."..stage_file)

        if not StageAPI.CustomStages[stage_file.api_id] then
            if stage_file.second ~= nil then
                local stage = GODMODE.stages[stage_file.second].stage(stage_file.second,stage_file.override_stage)
                stage.DisplayName = stage_file.display_name
                stage_file.stage = stage
                GODMODE.stages[stage_file.api_id] = stage_file            
            else
                local stage = StageAPI.CustomStage(stage_file.api_id,stage_file.override_stage,false)
                stage_file.backdrop_copy = {GODMODE.util.deep_copy(stage_file.graphics.backdrop_gfx),GODMODE.util.deep_copy(stage_file.graphics.backdrop_prefix),GODMODE.util.deep_copy(stage_file.graphics.backdrop_suffix)}
                local floor_room = StageAPI.BackdropHelper(stage_file.backdrop_copy[1], stage_file.backdrop_copy[2], stage_file.backdrop_copy[3])
                stage:SetName(stage_file.api_id)
                stage.DisplayName = stage_file.display_name

                -- if stage.simulating_stage then 
                --     GODMODE.save_manager.set_data("StageReseed"..stage.simulating_stage,"false",true)
                -- end 
                local stage_music = stage_file.music or "Basement"
                if type(stage_music) == "string" then 
                    stage_music = Isaac.GetMusicIdByName(stage_music)
                end
                
                stage:SetMusic(stage_music, stage_file.music_rooms or 
                    {RoomType.ROOM_DEFAULT,RoomType.ROOM_TREASURE,RoomType.ROOM_CHALLENGE,RoomType.ROOM_SACRIFICE,RoomType.ROOM_CURSE,
                        RoomType.ROOM_DUNGEON,RoomType.ROOM_ERROR,RoomType.ROOM_ISAACS,RoomType.ROOM_BARREN,RoomType.ROOM_CHEST,RoomType.ROOM_DICE,RoomType.ROOM_BLACK_MARKET})

                if stage_file.boss_music ~= nil then
                    local boss_music = stage_file.boss_music or Music.MUSIC_BOSS
                    if type(boss_music) == "string" then 
                        boss_music = Isaac.GetMusicIdByName(boss_music)
                    end
                    local over_music = stage_file.boss_music_over or Music.MUSIC_BOSS_OVER
                    if type(over_music) == "string" then 
                        over_music = Isaac.GetMusicIdByName(over_music)
                    end
            
                    stage:SetBossMusic(boss_music, over_music)
                end
            
                local room_grid = StageAPI.GridGfx()
                
                room_grid:SetBridges(stage_file.graphics.bridge)
                room_grid:SetRocks(stage_file.graphics.rocks)
                room_grid:SetPits(stage_file.graphics.pits, stage_file.graphics.alt_pits, true)
            
                if stage_file.graphics.doors ~= nil then
                    for i=1,#stage_file.graphics.doors do
                        room_grid:AddDoors(stage_file.graphics.doors[i].graphic, stage_file.graphics.doors[i].req)
                    end
                end
            
                if stage_file.graphics.grids ~= nil then
                    for i=1,#stage_file.graphics.grids do
                        room_grid:SetGrid(stage_file.graphics.grids[i].gfx,stage_file.graphics.grids[i].type)
                    end
                end
                
                if stage_file.override and stage.SetLevelgenStage then 
                    stage:SetLevelgenStage(stage_file.override.Stage,stage_file.override.StageType)
                end

                stage:SetRoomGfx(StageAPI.RoomGfx(floor_room, room_grid, "_default", stage_file.graphics.shading), {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BOSS})
                stage:SetSpots(stage_file.graphics.player_spot, stage_file.graphics.boss_spot)    
                stage.GenerateLevel = StageAPI.GenerateBaseLevel
                -- stage:SetReplace(stage_file:override(stage))

                -- local boss_rooms = assert(include(stage_file.boss_room_path), "[GODMODE_ACHIEVED] AN ERROR OCCURRED WHILE ATTEMPTING TO LOAD BOSS ROOMS FOR \'"..stage_file.api_id.."\' at \'"..stage_file.boss_room_path.."\'")
            
                if stage_file.rooms ~= nil then
                    for i=1,#stage_file.rooms do
                        local room_set = assert(include(stage_file.rooms[i].path),"[GODMODE_ACHIEVED] AN ERROR OCCURRED WHILE ATTEMPTING TO LOAD STAGE ROOMS FOR \'"..stage_file.api_id.."\' at \'"..stage_file.rooms[i].path.."\'")
                        stage:SetRooms(StageAPI.RoomsList(stage_file.api_id.."-"..stage_file.rooms[i].id, room_set), stage_file.rooms[i].type)
                    end
                else
                    local regular_rooms = assert(include(stage_file.room_path),"[GODMODE_ACHIEVED] AN ERROR OCCURRED WHILE ATTEMPTING TO LOAD STAGE ROOMS FOR \'"..stage_file.api_id.."\' at \'"..stage_file.room_path.."\'")
                    stage:SetRooms(StageAPI.RoomsList(stage_file.api_id.."-General", regular_rooms), RoomType.ROOM_DEFAULT)
                end
            
                local boss_ids = {}
            
                for i=1, #stage_file.bosses do
                    local dat = stage_file.bosses[i]
                    if dat ~= nil then
                        table.insert(boss_ids, stage_file.api_id.."_"..dat.Name)
                        
                        dat.Rooms = StageAPI.RoomsList(stage_file.api_id.."_Boss_"..dat.Name, include(dat.Rooms))
            
                        StageAPI.AddBossData(stage_file.api_id.."_"..dat.Name, dat)
                        GODMODE.log("Added boss data for boss \'"..stage_file.api_id.."_"..dat.Name.."\' to stage \'"..stage_file.api_id.."\'!")
                    end
                end
            
                stage:SetBosses(boss_ids)    

                if stage_file.challenge_wave_path ~= nil then 
                    stage:SetChallengeWaves(
                        StageAPI.RoomsList(stage_file.api_id.."_Challenge",include(stage_file.challenge_wave_path[1])),
                        StageAPI.RoomsList(stage_file.api_id.."_BossChallenge",include(stage_file.challenge_wave_path[2])))
                end
            end
            
            stage_file.stage = stage
            GODMODE.stages[stage_file.api_id] = stage_file
        else
            stage_file.stage = StageAPI.CustomStages[stage_file.api_id]
            GODMODE.stages[stage_file.api_id] = stage_file
        end
    end

    create_stage("l_palace")
    create_stage("fruit_cellar")
    create_stage("intestines")
    create_stage("nest")
    GODMODE.fallen_light_entrance = StageAPI.RoomsList("FallenLightEntrance",assert(include("resources.rooms.luc.bossroom"),"Error loading Fallen Light entrance!"))

    GODMODE.make_room_gfx = function(graphics)
        local backdrop_copy = {GODMODE.util.deep_copy(graphics.backdrop_gfx),GODMODE.util.deep_copy(graphics.backdrop_prefix),GODMODE.util.deep_copy(graphics.backdrop_suffix)}
        local backdrop_gfx = StageAPI.BackdropHelper(backdrop_copy[1], backdrop_copy[2], backdrop_copy[3])

        local grid_gfx = StageAPI.GridGfx()
        grid_gfx:SetBridges(graphics.bridge)
        grid_gfx:SetRocks(graphics.rocks)
        grid_gfx:SetPits(graphics.pits, graphics.alt_pits, true)
    
        if graphics.doors ~= nil then
            for i=1,#graphics.doors do
                grid_gfx:AddDoors(graphics.doors[i].graphic, graphics.doors[i].req)
            end
        end
    
        if graphics.grids ~= nil then
            for i=1,#graphics.grids do
                grid_gfx:SetGrid(graphics.grids[i].gfx,graphics.grids[i].type)
            end
        end

        return StageAPI.RoomGfx(backdrop_gfx, grid_gfx, "_default", graphics.shading)
    end

    --matches current room graphics to the specified godmode stage
    GODMODE.set_room_gfx = function(api_id,graphics)
        local stage_file = GODMODE.stages[api_id]

        if stage_file ~= nil and StageAPI.CustomStages[api_id] ~= nil then
            local stage = StageAPI.CustomStages[api_id]

            if graphics == nil then graphics = stage_file.graphics end
            
            local room_gfx = GODMODE.make_room_gfx(graphics)
            --stage:SetRoomGfx(room_gfx, {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BOSS})

            StageAPI.ChangeRoomGfx(room_gfx)
            GODMODE.log("Changed room gfx for api_id \'"..api_id.."\'!")
        else
            GODMODE.log("Unable to change room gfx for api_id \'"..api_id.."\'", true)
        end
    end

    GODMODE.is_at_palace = GODMODE.is_at_palace or function()
        return StageAPI and StageAPI.GetCurrentStageDisplayName() == "Ivory Palace"
    end

    GODMODE.set_palace_stage = function(stage)
        if not GODMODE.is_at_palace() then GODMODE.log("Not at palace, can't change stage!",false) 
        else
            local last_state = tonumber(GODMODE.save_manager.get_data("Deterioration","1"))
            local levels = GODMODE.stages["IvoryPalace"].deterioration_levels
            stage = math.max(1,math.min(stage,#levels))
            if stage < #levels+1 then
                if stage > last_state then 
                    GODMODE.room:EmitBloodFromWalls(5,10)
                    --Isaac.Spawn(GODMODE.registry.entities.ivory_portal.type, GODMODE.registry.entities.ivory_portal.variant, 0, Isaac.GetPlayer(0).Position, Vector(0,0), nil)) 
                end

                GODMODE.game:ShakeScreen(10)
                GODMODE.set_room_gfx("IvoryPalace", levels[stage].graphics)
                GODMODE.save_manager.set_data("Deterioration",""..(stage),true)
                GODMODE.log("Palace state was set to "..stage.." ("..levels[stage].friendly_name..")")
            end
        end
    end

    GODMODE.get_palace_stage = function()
        return tonumber(GODMODE.save_manager.get_data("Deterioration","1"))
    end

    StageAPI.AddCallback(GODMODE.mod_id, "PRE_CHANGE_ROOM_GFX", 2, function(currentRoom)
        if GODMODE.is_at_palace and GODMODE.is_at_palace() then
            local ind = tonumber(GODMODE.save_manager.get_data("Deterioration","1"))
            return GODMODE.make_room_gfx(GODMODE.stages["IvoryPalace"].deterioration_levels[ind].graphics)
        end
    end)

    StageAPI.AddCallback(GODMODE.mod_id, "PRE_CHANGE_MISC_GRID_GFX", 2, function(grid, index, usingFilename)
        if GODMODE.is_at_palace and GODMODE.is_at_palace() then
            if grid:ToDoor() and (grid:ToDoor().TargetRoomType == RoomType.ROOM_BOSS or grid:ToDoor().CurrentRoomType == RoomType.ROOM_BOSS) then 
                grid:GetSprite():Load("gfx/grid/luc/doors/door_10_bossroomdoor.anm2",true)
            end
        end
    end)


    StageAPI.AddCallback(GODMODE.mod_id, "PRE_SELECT_NEXT_STAGE", 2, function(currentStage, secretExit)
        if currentStage ~= nil then
            for _,stage in pairs(GODMODE.stages) do
                if stage.secret_next and stage.api_id == currentStage.Name and secretExit then 
                    return stage:secret_next(stage.stage)
                elseif stage.next and stage.api_id == currentStage.Name then                     
                    -- GODMODE.save_manager.set_data("StageReseed"..GODMODE.level:GetStage(),"true",true)

                    return stage:next(stage.stage)
                end
            end
        end
    end)

    GODMODE.add_base_bosses = function()
        --Add godmode bosses to stageapi hooks instead of manually overriding them
        for _,entry in pairs(GODMODE.bosses) do
            local boss_entry = {
                Name=entry.roomfile,
                Bossname=entry.name,
                Portrait=entry.portrait,
                Weight=entry.stage_api_entry.weight,
                Horseman=entry.horseman or false,
                Rooms=StageAPI.RoomsList("BossRooms_"..entry.roomfile, require("scripts.room_overrides."..(entry.roomfile))),
            }

            GODMODE.log("Added boss entry \'"..entry.roomfile.."\' to StageAPI hooks!")
            if StageAPI.AddBossData(entry.roomfile, boss_entry) ~= nil then
                local weight = entry.stage_api_entry.weight

                if entry.major_boss == true then 
                    weight = tonumber(GODMODE.save_manager.get_config("MajorBossWeight","1"))
                else
                    weight = weight * tonumber(GODMODE.save_manager.get_config("MinorBossPercent","1.0"))
                end

                if entry.stage_api_entry.stage_type == nil or entry.stage_api_entry.stage_type == "base" then
                    StageAPI.AddBossToBaseFloorPool({BossID=entry.roomfile,Weight=weight}, entry.stage_api_entry.stage, StageType.STAGETYPE_ORIGINAL, entry.stage_api_entry.no_stage_two)
                    StageAPI.AddBossToBaseFloorPool({BossID=entry.roomfile,Weight=weight}, entry.stage_api_entry.stage, StageType.STAGETYPE_WOTL, entry.stage_api_entry.no_stage_two)
                    StageAPI.AddBossToBaseFloorPool({BossID=entry.roomfile,Weight=weight}, entry.stage_api_entry.stage, StageType.STAGETYPE_AFTERBIRTH, entry.stage_api_entry.no_stage_two)
                elseif entry.stage_api_entry.stage_type == "rep" then 
                    StageAPI.AddBossToBaseFloorPool({BossID=entry.roomfile,Weight=weight}, entry.stage_api_entry.stage, StageType.STAGETYPE_REPENTANCE, entry.stage_api_entry.no_stage_two)
                    StageAPI.AddBossToBaseFloorPool({BossID=entry.roomfile,Weight=weight}, entry.stage_api_entry.stage, StageType.STAGETYPE_REPENTANCE_B, entry.stage_api_entry.no_stage_two)
                elseif type(entry.stage_api_entry.stage_type) == "table" then 
                    for _,stage in ipairs(entry.stage_api_entry.stage_type) do 
                        StageAPI.AddBossToBaseFloorPool({BossID=entry.roomfile,Weight=weight}, entry.stage_api_entry.stage, stage, entry.stage_api_entry.no_stage_two)
                    end
                else
                    StageAPI.AddBossToBaseFloorPool({BossID=entry.roomfile,Weight=weight}, entry.stage_api_entry.stage, entry.stage_api_entry.stage_type, entry.stage_api_entry.no_stage_two)
                end
            end
        end
    end

    GODMODE.add_base_bosses()

    -- StageAPI.AddCallback(GODMODE.mod_id, "PRE_BOSS_SELECT", 1, function(bosses,allowHorseman,rng)
    --     if GODMODE.is_at_palace() then
    --         return bosses["Angelusossa"]
    --     end
    -- end)

    GODMODE.palace_transition = Sprite()
    GODMODE.palace_transition:Load("gfx/anim_lucifertransition.anm2", true)

    GODMODE.transition_to_palace = function()
        GODMODE.palace_transition:Play("Scene", true) 
        GODMODE.cur_splash = GODMODE.palace_transition
        GODMODE.cur_splash_pos = GODMODE.util.get_center_of_screen()
    end

    GODMODE.first_level_load = nil 
    GODMODE.try_switch_stage = function()
        if GODMODE.util.is_start_of_run() then return end 
        
        local level = GODMODE.level
        if not level:IsAscent() and GODMODE.game.Difficulty < Difficulty.DIFFICULTY_GREED and GODMODE.level:GetStageType() <= StageType.STAGETYPE_AFTERBIRTH then  
            for _,stage in pairs(GODMODE.stages) do
                if stage.try_switch then 
                    local allowed = stage:try_switch()
                    if allowed and GODMODE.util.random() < tonumber(GODMODE.save_manager.get_config("GodmodeStageChance","0.25")) and not GODMODE.is_at_palace() then 
                        -- Isaac.ExecuteCommand("cstage "..stage.api_id)
                        StageAPI.GotoCustomStage(StageAPI.CustomStages[stage.api_id],false)
                        local remove_labrynth_reseed = function()
                            local depth = 30

                            while GODMODE.util.has_curse(LevelCurse.CURSE_OF_LABYRINTH) and depth > 0 do 
                                GODMODE.log("removed labrynth",true)
                                Isaac.ExecuteCommand("creseed")
                                depth = depth - 1 
                            end
                        end

                        -- if GODMODE.fc_glitch_flag == nil and stage.api_id == "FruitCellar" then 
                        --     GODMODE.fc_glitch_flag = true
                        --     GODMODE.log("fixing glitch",true)
                        --     local types = {"a","b","c"}
                        --     Isaac.ExecuteCommand("stage 1"..types[GODMODE.util.random(1,#types)])
                        -- else 
                            -- remove_labrynth_reseed()
                            -- StageAPI.GotoCustomStage(StageAPI.CustomStages[stage.api_id],false,true)    
                        -- end

                        -- if stage.api_id == "FruitCellar" or stage.api_id == "IvoryPalace" then --reduce planetarium chance artificially
                        --     local rooms = GODMODE.level:GetRooms()
                        --     local depth = 10
                        --     local has_planetarium = function()
                        --         for i=0, rooms.Size-1 do
                        --             local room = rooms:Get(i)
                        --             if room.Data and room.Data.Type == RoomType.ROOM_PLANETARIUM then
                        --                 return true 
                        --             end 
                        --         end

                        --         return false 
                        --     end
                            
                        --     if has_planetarium() and (GODMODE.util.random() > (0.01/0.21) and stage.api_id == "FruitCellar" or stage.api_id ~= "FruitCellar") then 
                        --         while has_planetarium() and depth > 0 do
                        --             depth = depth - 1
                        --             remove_labrynth_reseed()
                        --         end    
                        --     end

                        --     GODMODE.level:DisableDevilRoom()
                        -- end

                        -- StageAPI.GotoCustomStage(stage.stage, false, false)
                        break
                    end
                end
            end
        end
    end

    GODMODE.backdrops = {}

    GODMODE.backdrops.unlock_room_gfx = GODMODE.make_room_gfx({
        rocks = "gfx/grid/unlock_room/rocks.png",
        pits = "gfx/grid/unlock_room/pits.png",
        alt_pits = "gfx/grid/unlock_room/pits.png",
        bridge = "gfx/grid/unlock_room/bridge.png",
        shading = "gfx/backdrop/base_shading/shading",
        player_spot = "gfx/ui/stage/unlock_room/boss_spot.png",
        boss_spot = "gfx/ui/stage/unlock_room/player_spot.png",
    
        backdrop_gfx = {
            Walls = {""},
            NFloors = {"nfloor"},
            LFloors = {"lfloor"},
            Corners = {"corner"}
        }, 
    
        backdrop_prefix = "gfx/backdrop/unlock_room/unlock", 
        backdrop_suffix = ".png",
    
        doors = {
            {graphic="gfx/grid/unlock_room/doors/normal.png", req=GODMODE.util.base_room_door},
            {graphic="gfx/grid/basedoors/door_00_shopdoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_SHOP}}},
            {graphic="gfx/grid/basedoors/door_05_arcaderoomdoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_ARCADE}}},
            {graphic="gfx/grid/basedoors/door_13_librarydoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_LIBRARY}}},
        }
    })

    GODMODE.backdrops.observatory_gfx = GODMODE.make_room_gfx({
        backdrop_gfx = {
            Walls = {""},
            NFloors = {"nfloor"},
            LFloors = {"lfloor"},
            Corners = {"corner"}
        }, 
    
        backdrop_prefix = "gfx/backdrop/observatory/observatory_back", 
        backdrop_suffix = ".png",
    
        doors = {
            {graphic="gfx/grid/observatory_door.png", req=GODMODE.util.base_room_door},
        }
    })

    GODMODE.backdrops.correction_gfx = GODMODE.make_room_gfx({
        backdrop_gfx = {
            Walls = {"1","2"},
            NFloors = {"nfloor"},
            LFloors = {"lfloor"},
            Corners = {"corner"}
        }, 
    
        backdrop_prefix = "gfx/backdrop/correction/correct_", 
        backdrop_suffix = ".png",
    
        doors = {
            {graphic="gfx/grid/correction_door.png", req=GODMODE.util.base_room_door},
        }
    })

    GODMODE.backdrops.correction_dogma_gfx = GODMODE.make_room_gfx({
        backdrop_gfx = {
            Walls = {""},
            NFloors = {"nfloor"},
            LFloors = {"lfloor"},
            Corners = {"corner"}
        }, 
    
        backdrop_prefix = "gfx/backdrop/correction/correction_back", 
        backdrop_suffix = ".png",
    
        doors = {
            {graphic="gfx/grid/correction_door2.png", req=GODMODE.util.base_room_door},
        }
    })

    GODMODE.backdrops.sheol_to_palace = GODMODE.make_room_gfx({
        backdrop_gfx = {
            Walls = {"1","2","3","4"},
            NFloors = {"nfloor"},
            LFloors = {"lfloor"},
            Corners = {"corner"}
        }, 
    
        backdrop_prefix = "gfx/backdrop/god_palace_night/sheol_", 
        backdrop_suffix = ".png",
    
        doors = {
            {graphic="gfx/grid/door_19_sheoldoor.png", req=GODMODE.util.base_room_door},
        }
    })

    GODMODE.backdrops.cathedral_to_palace = GODMODE.make_room_gfx({
        backdrop_gfx = {
            Walls = {"1","2","3","4"},
            NFloors = {"nfloor"},
            LFloors = {"lfloor"},
            Corners = {"corner"}
        }, 
    
        backdrop_prefix = "gfx/backdrop/god_palace_day/palace_", 
        backdrop_suffix = ".png",
    
        doors = {
            {graphic="gfx/grid/door_22_cathedraldoor.png", req=GODMODE.util.base_room_door},
        }
    })

    GODMODE.backdrops.chest_to_sanctuary = GODMODE.make_room_gfx({
        backdrop_gfx = {
            Walls = {"1","2","3","4","5","6"},
            NFloors = {"nfloor"},
            LFloors = {"lfloor"},
            Corners = {"corner"}
        }, 
        
        underlay = function() --MC_PRE_BACKDROP_RENDER_WATER
            
        end,
        backdrop_prefix = "gfx/backdrop/god_sanctuary/sanctuary_", 
        backdrop_suffix = ".png",
        overlay = StageAPI.Overlay("gfx/backdrop/god_sanctuary/sanctuary_overlay.anm2", Vector(0.55,0.45), Vector(-10,-10)),
    
        doors = {
            {graphic="gfx/grid/sanctuary/door.png", req=GODMODE.util.base_room_door},
        }
    })

    GODMODE.backdrop_overlays = {
        -- [LevelStage.STAGE5..","..StageType.STAGETYPE_ORIGINAL] = "SheolToPalace",
        -- [LevelStage.STAGE5..","..StageType.STAGETYPE_WOTL] = "CathedralToPalace",
        -- [LevelStage.STAGE6..","..StageType.STAGETYPE_ORIGINAL] = "DarkRoomToFurnace",
        [LevelStage.STAGE6..","..StageType.STAGETYPE_WOTL] = StageAPI.Overlay("gfx/backdrop/god_sanctuary/sanctuary_overlay.anm2", Vector(0.55,0.45), Vector(-10,-10)),
    }

    GODMODE.backdrop_config_toggles = {
        [LevelStage.STAGE5..","..StageType.STAGETYPE_ORIGINAL] = "SheolToPalace",
        [LevelStage.STAGE5..","..StageType.STAGETYPE_WOTL] = "CathedralToPalace",
        [LevelStage.STAGE6..","..StageType.STAGETYPE_ORIGINAL] = "DarkRoomToFurnace",
        [LevelStage.STAGE6..","..StageType.STAGETYPE_WOTL] = "ChestToSanctuary",
    }

    GODMODE.backdrop_overrides = {
        [LevelStage.STAGE5..","..StageType.STAGETYPE_ORIGINAL] = GODMODE.backdrops.sheol_to_palace,
        [LevelStage.STAGE5..","..StageType.STAGETYPE_WOTL] = GODMODE.backdrops.cathedral_to_palace,
        -- [LevelStage.STAGE6..","..StageType.STAGETYPE_ORIGINAL] = GODMODE.backdrops.dark_room_to_furnace,
        [LevelStage.STAGE6..","..StageType.STAGETYPE_WOTL] = GODMODE.backdrops.chest_to_sanctuary,
    }

    GODMODE.backdrop_roomtypes = {
        [RoomType.ROOM_DEFAULT] = true,
        [RoomType.ROOM_BOSS] = true,
        [RoomType.ROOM_TREASURE] = true,
        [RoomType.ROOM_MINIBOSS] = true
    }

    local overlay_func = function()
        if not StageAPI.IsHUDAnimationPlaying() then
            local room = GODMODE.room
            local level = GODMODE.level
            local listIndex = StageAPI.GetCurrentListIndex()
            local type = StageAPI.GetCurrentRoomType()

            if type == RoomType.ROOM_DEFAULT then 
                local bd_key = level:GetAbsoluteStage()..","..level:GetStageType()
                -- GODMODE.log("right room type! bd_key="..tostring(bd_key),true)

                if GODMODE.backdrop_overlays and GODMODE.backdrop_overlays[bd_key]
                    and GODMODE.save_manager.get_config(GODMODE.backdrop_config_toggles[bd_key],"false") == "true" then 

                    -- GODMODE.log("rendering overlay!",true)
                    GODMODE.backdrop_overlays[bd_key]:SetAlpha(1)
                    GODMODE.backdrop_overlays[bd_key]:Render(false)
                end
            end
        end
    end

    if GODMODE.validate_rgon() then 
        function GODMODE.mod_object:pre_render_walls() 
            overlay_func()
        end
        GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_BACKDROP_RENDER_WATER, GODMODE.mod_object.pre_render_walls)
    else 
        -- StageAPI.AddCallback(GODMODE.mod_id, "PRE_TRANSITION_RENDER", 2, function()
        --     overlay_func()
        -- end)    
    end

    -- mod music callback
    if MMC then 
        MMC.AddMusicCallback(GODMODE.mod_object, function()
            local bd_key = GODMODE.level:GetAbsoluteStage()..","..GODMODE.level:GetStageType()

            if GODMODE.room:GetType() ~= RoomType.ROOM_BOSS and GODMODE.level:GetStage() == LevelStage.STAGE5 and GODMODE.level:GetStageType() == StageType.STAGETYPE_WOTL then
                if GODMODE.save_manager.get_config(GODMODE.backdrop_config_toggles[bd_key],"false") == "true" and GODMODE.save_manager.get_config("CathedralTheme","false") == "true" then 
                    return GODMODE.registry.music.a_song_from_a_broken_soul
                end
            end
        end, Music.MUSIC_CATHEDRAL)

        MMC.AddMusicCallback(GODMODE.mod_object, function()
            if GODMODE.save_manager.get_config("ShopTheme","true") == "true" then 
                return GODMODE.registry.music.persuasions
            end
            
        end, Music.MUSIC_SHOP_ROOM)
    end

    -- GODMODE.ObservatoryDoor = StageAPI.CustomDoor("ObservatoryDoor", "gfx/grid/observatory_door.anm2", nil, nil, nil, nil, true)

    GODMODE.observatory_rooms = StageAPI.RoomsList("GODMODE-Observatory",include("resources.rooms.observatory_rooms"))--StageAPI.CreateEmptyRoomLayout(RoomShape.ROOMSHAPE_1x1)

    -- REVEL.MirrorRoomLayout.Type = "Mirror"
    -- StageAPI.RegisterLayout("MirrorRoom", REVEL.MirrorRoomLayout)

    GODMODE.log("Loaded Godmode StageAPI Integration!")
end

if not StageAPI then
    if GODMODE.save_manager.get_config("ReqsPrompt", "true") == "true" then 
        GODMODE.achievements.play_splash("stageapi_request", 0.6)
    end

    StageAPI = StageAPI or {}
    StageAPI.ToCall = StageAPI.ToCall or {}
    table.insert(StageAPI.ToCall, load_stageapi_integration)
elseif StageAPI and StageAPI.Loaded then
    load_stageapi_integration()
end

if MinimapAPI then 
    GODMODE.sprites.minimapapi_sprite = Sprite()
    GODMODE.sprites.minimapapi_sprite:Load("gfx/ui/minimapapi/godmode_minimap.anm2", true)
	GODMODE.sprites.minimapapi_sprite:Play("ObservatoryIcon", false)
    local curse_predicate = function(curse)
        return function() return GODMODE.util.has_curse(GODMODE.util.get_shifted_curse(curse)) end
    end
	MinimapAPI:AddIcon("GODMODEObservatory", GODMODE.sprites.minimapapi_sprite)

    MinimapAPI:AddMapFlag("GODMODEBlessing_Opportunity", curse_predicate(GODMODE.registry.blessings["opportunity"]), GODMODE.sprites.minimapapi_sprite, "BlessingOpportunity", 0)
    MinimapAPI:AddMapFlag("GODMODEBlessing_Kindness", curse_predicate(GODMODE.registry.blessings["kindness"]), GODMODE.sprites.minimapapi_sprite, "BlessingKindness", 0)
    MinimapAPI:AddMapFlag("GODMODEBlessing_Charity", curse_predicate(GODMODE.registry.blessings["charity"]), GODMODE.sprites.minimapapi_sprite, "BlessingCharity", 0)
    MinimapAPI:AddMapFlag("GODMODEBlessing_Faith", curse_predicate(GODMODE.registry.blessings["faith"]), GODMODE.sprites.minimapapi_sprite, "BlessingFaith", 0)
    MinimapAPI:AddMapFlag("GODMODEBlessing_Justice", curse_predicate(GODMODE.registry.blessings["justice"]), GODMODE.sprites.minimapapi_sprite, "BlessingJustice", 0)
    MinimapAPI:AddMapFlag("GODMODEBlessing_Fortitude", curse_predicate(GODMODE.registry.blessings["fortitude"]), GODMODE.sprites.minimapapi_sprite, "BlessingFortitude", 0)
    MinimapAPI:AddMapFlag("GODMODEBlessing_Patience", curse_predicate(GODMODE.registry.blessings["patience"]), GODMODE.sprites.minimapapi_sprite, "BlessingPatience", 0)

end

-- community remix debug with knife pieces, unfortunately this doesn't seem to work if I put it here on my end but I will keep this here until community remix fixes it
if communityRemix then 
    communityRemix:AddPriorityCallback (ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, function(self, p, flag)
        if flag == CacheFlag.CACHE_FAMILIARS then
            local numFamiliars = p:GetTrinketMultiplier(TrinketType.TRINKET_INFANTICIDE) + p:GetEffects():GetTrinketEffectNum(TrinketType.TRINKET_INFANTICIDE)
             + math.min(p:GetCollectibleNum(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1), p:GetCollectibleNum(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2))
           
            p:CheckFamiliar(
                FamiliarVariant.KNIFE_FULL,
                numFamiliars,
                p:GetTrinketRNG(TrinketType.TRINKET_INFANTICIDE)
            )
        end
    end)    
end

-- soundtrack menu support
if SoundtrackSongList then
    AddSoundtrackToMenu("GODMODE")
end

-- if DetailedRespawnGlobalAPI then
--     DetailedRespawnGlobalAPI.AddCustomRespawn({
--         name = "GODMODEEdibleSoul",
--         itemId = GODMODE.registry.items.edible_soul,
--         -- positionModifier = Vector.Zero
--     }, DetailedRespawnGlobalAPI.RespawnPosition.Last)
-- end