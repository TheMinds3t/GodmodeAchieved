-- this file both adds a small API to easily reference and integrate godmode with other mods that choose to add official support


if ModConfigMenu then -- stitch my DSS integration to my MCM configuration >:D but now both menus should work near-identically!!
    local mod_name = "Godmode Achieved"
    local bool_read = {
        ["true"]="Enabled",
        ["false"]="Disabled"
    }
    ModConfigMenu.RemoveCategory(mod_name)
    ModConfigMenu.UpdateCategory(mod_name, {
        Info = "Overhaul mod that adds more content in all angles, customizable here or press 'C' to access the Dead Sea Scrolls menu, integrated with Godmode!",
    })

    local cat_order = {
        "alts",
        "scaling",
        "gameplay",
        "unlocks",
        "cosmetic",
        "controls",
        "credits",
    }

    local subcats = GODMODE.options.layout

    local bool_text_sets = {
        [GODMODE.options.bool_choices] = GODMODE.options.bool_choices,
        [GODMODE.options.unlock_choices] = GODMODE.options.unlock_choices,
        [GODMODE.options.scaling_choices] = GODMODE.options.scaling_choices,
        [GODMODE.options.bypass_choices] = GODMODE.options.bypass_choices,
    }

    local multi_text_sets = {
        [GODMODE.options.palace_clear_options] = GODMODE.options.palace_clear_options,
        [GODMODE.options.fractal_display_choices] = GODMODE.options.fractal_display_choices,
        [GODMODE.options.red_juice_choices] = GODMODE.options.red_juice_choices,
        [GODMODE.options.tutorial_choices] = GODMODE.options.tutorial_choices,
    }

    for ind, id in ipairs(cat_order) do 
        local cat = subcats[id]

        if cat then 
            local cat_name = GODMODE.util.to_title_case(cat.title)
            ModConfigMenu.AddTitle(mod_name, cat_name, cat_name)
            -- ModConfigMenu.AddText("My Settings Page", "Tab 1", "My Text")
            
            for i, but in ipairs(cat.buttons) do 
                if but.dss_button == true then --skip dss buttons (for obvious reasons)
                elseif but.credits == true then --credits text
                    -- ModConfigMenu.AddText(mod_name, cat_name, but.str)

                    ModConfigMenu.AddSetting(
                        mod_name,
                        cat_name,
                        {
                            Type = ModConfigMenu.OptionType.NUMBER,
                            CurrentSetting = function()
                                return 1
                            end,
                            Minimum = but_min,
                            Maximum = but_max,
                            Display = function()
                                return but.str
                            end,
                            OnChange = function(n)
                            end,
                            -- Text in the "Info" section will automatically word-wrap, unlike in the main section above
                            Info = {}
                        }
                    )
                elseif but.gap == true then 
                    ModConfigMenu.AddSpace(mod_name, cat_name)
                elseif but ~= GODMODE.options.back_option then -- skip adding the back button since the menu is a different layout
                    local but_name = GODMODE.util.to_title_case(but.str)
                    local but_desc = {}

                    if but.tooltip then -- squish tooltip for DSS since DSS wordwraps it
                        local cur_desc = ""

                        for _,str in ipairs(but.tooltip.strset) do 
                            cur_desc = cur_desc..str.." "
                        end    

                        if cur_desc ~= "" then 
                            table.insert(but_desc, cur_desc) 
                        end
                    end

                    if but.min and but.max and but.increment then -- numeric option
                        local inc = but.increment
                        local n_options = math.ceil((but.max - but.min) / inc)
                        local but_min = 0
                        local but_max = n_options

                        ModConfigMenu.AddSetting(
                            mod_name,
                            cat_name,
                            {
                                Type = ModConfigMenu.OptionType.NUMBER,
                                CurrentSetting = function()
                                    return (but.load() - but.min) / inc
                                end,
                                Minimum = but_min,
                                Maximum = but_max,
                                Display = function()
                                    return but_name.." | "..(but.pref or "").. but.load() ..(but.suf or "")
                                end,
                                OnChange = function(n)
                                    but.store(but.min + n * inc)
                                    GODMODE.save_manager.save()
                                end,
                                -- Text in the "Info" section will automatically word-wrap, unlike in the main section above
                                Info = but_desc
                            }
                        )
                    elseif bool_text_sets[but.choices] ~= nil then -- boolean option
                        ModConfigMenu.AddSetting(
                            mod_name,
                            cat_name,
                            {
                                Type = ModConfigMenu.OptionType.BOOLEAN,
                                CurrentSetting = function()
                                return but.load() == GODMODE.options.str_bool_map[options.bool_map[but.load()]] -- default to true
                                end,
                                Display = function()
                                return but_name.." | "..tostring(but.choices[but.load()])
                                end,
                                OnChange = function(b)
                                but.store(GODMODE.options.str_bool_map[b])
                                GODMODE.save_manager.save()
                                end,
                                Info = but_desc
                            }
                        )
                    elseif multi_text_sets[but.choices] then -- multi-options
                        ModConfigMenu.AddSetting(
                            mod_name,
                            cat_name,
                            {
                                Type = ModConfigMenu.OptionType.NUMBER,
                                CurrentSetting = function()
                                    return but.load()
                                end,
                                Minimum = 1,
                                Maximum = #multi_text_sets[but.choices],
                                Display = function()
                                return but_name.." | "..tostring(but.choices[but.load()])
                                end,
                                OnChange = function(val)
                                    but.store(val)
                                    GODMODE.save_manager.save()
                                end,
                                Info = but_desc
                            }
                        )
                    elseif but.keybind == true then 
                        ModConfigMenu.AddSetting( -- thank you minimapi, this was painful to understand without example
                            mod_name,
                            cat_name,
                            {
                                Type = ModConfigMenu.OptionType.KEYBIND_KEYBOARD,
                                CurrentSetting = function()
                                    return but.load()
                                end,
                                Display = function()
                                    local key = tostring(GODMODE.options.dssmod.inputButtonNames[but.load()])
                                    if key == "nil" then key = "None" end 
                                    return but_name .. " | " .. key
                                end,
                                OnChange = function(val)
                                    if (val == Keyboard.KEY_ESCAPE or val == Keyboard.KEY_BACKSPACE) then
                                        val = Keyboard.KEY_TAB
                                    end

                                    but.store(val)
                                end,
                                PopupGfx = ModConfigMenu.PopupGfx.WIDE_SMALL,
                                PopupWidth = 200,
                                Popup = function()
                                    return "Waiting for input...$newline(Currently set to \'"
                                        ..tostring(GODMODE.options.dssmod.inputButtonNames[but.load()])
                                        .."\')$newline$newlineThe default option is Tab.$newline$newlineIf you want to rebind this key to Tab, you must go to DSS's input by pressing \'C\' while in a safe room. I am looking into a solution for this."
                                end,
                              Info = but_desc
                            }
                          )
                    else
                        GODMODE.log("unhandled option \'"..but_name.."\' from category \'"..cat_name.."\' when converting DSS option to ModConfigMenu option", true)
                    end
                end
            end
        end
    end
end



--EXTERNAL ITEM DESCRIPTIONS SUPPORT
if EID then
    GODMODE.eid_transform_anim = Sprite()
    GODMODE.eid_transform_anim:Load("godmode/gfx/ui/eid_transformations.anm2", true)
    
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
    else 
        GODMODE.log("[Error] EID is missing 'addIcon', so not adding Godmode EID icons. Non-fatal but concerning")
    end

    if EID.addCollectible then 
        for _,item in ipairs(GODMODE.items) do
            if item.instance ~= nil then 
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
            else 
                GODMODE.log("[Error] invalid item object found while trying to register for EID, skipping!")
            end
        end
    
        EID:addCollectible(GODMODE.registry.items.jack_of_all_trades, "Counts as one item towards all transformations")
        EID:addCollectible(GODMODE.registry.items.blood_key, "Allows you to enter the Ivory Palace in Sheol/Cathedral")
        EID:assignTransformation("collectible", GODMODE.registry.items.jack_of_all_trades, GODMODE.util.eid_transforms.JACK_OF_ALL_TRADES)
        EID:addCollectible(GODMODE.registry.items.brass_cross, "↑ +2 Soul Hearts#↑ +25% chance to encounter a blessed floor")

        if GODMODE.save_manager.get_config("MoreOptionsRework","true") == "true" then 
            EID:addCollectible(CollectibleType.COLLECTIBLE_MORE_OPTIONS, "↑ Treasure rooms have more items# Each item is sequentially assigned a group, 1 to (1+More Options Quantity), indicated on the item pedestal# You can only pick one item from each group")    
        end
        
        EID.descriptions["en_us"].collectibles[CollectibleType.COLLECTIBLE_BLACK_CANDLE][3] = EID.descriptions["en_us"].collectibles[CollectibleType.COLLECTIBLE_BLACK_CANDLE][3].."#↓ Prevents Godmode Blessings"
    else 
        GODMODE.log("[Error] EID is missing 'addCollectible', so not adding Godmode item info. Non-fatal but concerning")
    end

    if EID.addBirthright then
        for name,player in pairs(GODMODE.players) do
            if player.eid_birthright then
                EID:addBirthright(name,player.eid_birthright)
            end
        end

        GODMODE.log("Loaded Godmode External Items Description Integration!")
    else 
        GODMODE.log("[Error] EID is missing 'addBirthright', so not adding Godmode birthright info. Non-fatal but concerning")
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
                {str = "Obtained by giving the Stifled Gatekeeper in Sheol an item collected in an Angel room, or by giving the Stifled Gatekeeper in Cathedral an item collected in a Devil room. Allows for the player to reach the Ivory Palace, the final stage of Godmode."},
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
    local bar_path = "godmode/gfx/ui/boss/bar_icons/"
    local bar_path_bar = "godmode/gfx/ui/boss/bars/"
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
    StageAPI.GetChampionChance = function() -- replace to make StageAPI compatible with non-RGON setups! 
        local chance = 0.05 --Base chance is 5%
        if GODMODE.game:GetSeeds():HasSeedEffect(SeedEffect.SEED_ALL_CHAMPIONS) then
            chance = 1.1
        elseif GODMODE.level:GetStage() == LevelStage.STAGE7 then --The Void sets base chance to 75%
            chance = 0.75
        elseif StageAPI.AnyPlayerHasItem(CollectibleType.COLLECTIBLE_CHAMPION_BELT) then --Champion Belt sets base chance to 20%
            chance = 0.2
        end
        -- local purpleHearts = PlayerManager.GetTotalTrinketMultiplier(TrinketType.TRINKET_PURPLE_HEART) -- it's literally this one line that breaks compatibility with non-RGON users
        local purpleHearts = GODMODE.util.total_item_count(TrinketType.TRINKET_PURPLE_HEART,true) 
        if purpleHearts > 0 then
            chance = chance * purpleHearts * 2 --Purple Heart is a x2 mult per copy
        end 
        return chance
    end

    GODMODE.stages = {}
    StageAPI.UnregisterCallbacks(GODMODE.mod_id)

    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.recluse, {
        Name = "godmode/gfx/ui/boss/names/arac.png",
        Portrait = "godmode/gfx/ui/stage/arac.png",
        NoShake = false,
        -- Controls = "godmode/gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.t_recluse, {
        Name = "godmode/gfx/ui/boss/names/arac.png",
        Portrait = "godmode/gfx/ui/stage/tainted_arac.png",
        NoShake = false,
        -- Controls = "godmode/gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.xaphan, {
        Name = "godmode/gfx/ui/boss/names/xaphan.png",
        Portrait = "godmode/gfx/ui/stage/xaphan.png",
        NoShake = false,
        -- Controls = "godmode/gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.t_xaphan, {
        Name = "godmode/gfx/ui/boss/names/xaphan.png",
        Portrait = "godmode/gfx/ui/stage/tainted_xaphan.png",
        NoShake = false,
        -- Controls = "godmode/gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.deli, {
        Name = "godmode/gfx/ui/boss/names/deli.png",
        Portrait = "godmode/gfx/ui/stage/deli.png",
        NoShake = false,
        -- Controls = "godmode/gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.t_deli, {
        Name = "godmode/gfx/ui/boss/names/deli.png",
        Portrait = "godmode/gfx/ui/stage/tainted_deli.png",
        NoShake = false,
        -- Controls = "godmode/gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.elohim, {
        Name = "godmode/gfx/ui/boss/names/elohim.png",
        Portrait = "godmode/gfx/ui/stage/elohim.png",
        NoShake = false,
        -- Controls = "godmode/gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.t_elohim, {
        Name = "godmode/gfx/ui/boss/names/elohim.png",
        Portrait = "godmode/gfx/ui/stage/tainted_elohim.png",
        NoShake = false,
        -- Controls = "godmode/gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.gehazi, {
        Name = "godmode/gfx/ui/boss/names/gehazi.png",
        Portrait = "godmode/gfx/ui/stage/gehazi.png",
        NoShake = false,
        -- Controls = "godmode/gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.t_gehazi, {
        Name = "godmode/gfx/ui/boss/names/gehazi.png",
        Portrait = "godmode/gfx/ui/stage/tainted_gehazi.png",
        NoShake = false,
        -- Controls = "godmode/gfx/backdrop/controls_fiend.png"
    })
    StageAPI.AddPlayerGraphicsInfo(GODMODE.registry.players.the_sign, {
        Name = "godmode/gfx/ui/boss/names/thesign.png",
        Portrait = "godmode/gfx/ui/stage/thesign.png",
        NoShake = false,
        -- Controls = "godmode/gfx/backdrop/controls_fiend.png"
    })
    
    function create_stage(stage_file)
        local stage_file = include("godmode.scripts.definitions.stages."..stage_file)

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
    
                if stage.simulating_stage then 
                    stage:SetStageNumber(stage.simulating_stage)
                end

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

                stage:SetMusic(Music.MUSIC_SHOP_ROOM, {RoomType.ROOM_SHOP})
                stage:SetMusic(Music.MUSIC_ARCADE_ROOM, {RoomType.ROOM_ARCADE})
                stage:SetMusic(Music.MUSIC_ANGEL_ROOM, {RoomType.ROOM_ANGEL})
                stage:SetMusic(Music.MUSIC_DEVIL_ROOM, {RoomType.ROOM_DEVIL})
                stage:SetMusic(Music.MUSIC_SECRET_ROOM, {RoomType.ROOM_SECRET})
                stage:SetMusic(Music.MUSIC_SECRET_ROOM2, {RoomType.ROOM_SUPERSECRET})
                stage:SetMusic(Music.MUSIC_SECRET_ROOM_ALT_ALT, {RoomType.ROOM_ULTRASECRET})

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
    GODMODE.fallen_light_entrance = StageAPI.RoomsList("FallenLightEntrance",assert(include("resources.godmode.rooms.luc.bossroom"),"Error loading Fallen Light entrance!"))

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
                grid:GetSprite():Load("godmode/gfx/grid/luc/doors/door_10_bossroomdoor.anm2",true)
            end
        end
    end)


    StageAPI.AddCallback(GODMODE.mod_id, "PRE_SELECT_NEXT_STAGE", 99, function(currentStage, secretExit)
        if currentStage ~= nil then
            for _,stage in pairs(GODMODE.stages) do
                GODMODE.log("Testing "..(stage.api_id or "NIL"),true)

                GODMODE.save_manager.set_data("StageReseed"..GODMODE.level:GetStage(),"true")

                if stage.secret_next and stage.api_id == currentStage.Name and secretExit then 
                    GODMODE.save_manager.save()
                    return stage:secret_next(stage.stage)
                elseif stage.next and stage.api_id == currentStage.Name then
                    GODMODE.save_manager.save()
                    return stage:next(stage.stage)
                end
            end

        end
    end)

    StageAPI.AddCallback(GODMODE.mod_id, "PRE_BOSS_SELECT", 1, function(bosses, rng, roomDesc, ignoreNoOptions) 
        if GODMODE.is_at_palace and GODMODE.is_at_palace() then 
            return 
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
                Rooms=StageAPI.RoomsList("BossRooms_"..entry.roomfile, require("godmode.scripts.room_overrides."..(entry.roomfile))),
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
    GODMODE.palace_transition:Load("godmode/gfx/anim_lucifertransition.anm2", true)

    -- the actual teleport is done in a POST_UPDATE in main with this palace_transition object
    GODMODE.transition_to_palace = function()
        GODMODE.palace_transition:Play("Scene", true) 
        GODMODE.cur_splash = GODMODE.palace_transition
        GODMODE.cur_splash_pos = GODMODE.util.get_center_of_screen()
    end


    -- FOUND A BUG! The LTL L room is pivoted on 1,0 instead of 0,0, so the map icon needs to be moved for that room shape by Vector(1,0)
    ---@param roomData LevelMap.RoomData
    function StageAPI.LevelMap:AddRoomToMinimap(roomData)
        if MinimapAPI and roomData.X and roomData.Y then
            local levelRoom = self:GetRoom(roomData)
            if levelRoom then
                local dim = self.OverlapDimension or self.Dimension
                local t = {
                    Shape = levelRoom.Shape,
                    PermanentIcons = {MinimapAPI:GetRoomTypeIconID(levelRoom.RoomType)},
                    LockedIcons = {MinimapAPI:GetUnknownRoomTypeIconID(levelRoom.RoomType)},
                    ItemIcons = {},
                    VisitedIcons = {},
                    Position = Vector(roomData.X, roomData.Y) + (MinimapAPI.RoomShapeGridPivots[levelRoom.Shape] or Vector.Zero),
                    AdjacentDisplayFlags = MinimapAPI.RoomTypeDisplayFlagsAdjacent[levelRoom.RoomType] or 5,
                    -- StageAPI custom room types can be strings, which MinimapAPI doesn't support
                    Type = type(levelRoom.RoomType) == "number" and levelRoom.RoomType or RoomType.ROOM_DEFAULT,
                    Dimension = dim,
                    ID = roomData.MapID
                }
                if t.Type == RoomType.ROOM_SECRET or t.Type == RoomType.ROOM_SUPERSECRET then
                    t.Hidden = 1
                elseif t.Type == RoomType.ROOM_ULTRASECRET then
                    t.Hidden = 2
                end

                MinimapAPI:AddRoom(t)
            end
        end
    end

    -- necessary data structure to proof different room shapes
    local roomshape_to_neighbor_check = {
        [RoomShape.ROOMSHAPE_1x1] = {name="1x1",x=1,y=1},
        [RoomShape.ROOMSHAPE_1x2] = {name="1x2",x=1,y=2},
        [RoomShape.ROOMSHAPE_2x1] = {name="2x1",x=2,y=1},
        [RoomShape.ROOMSHAPE_2x2] = {name="2x2",x=2,y=2},
        [RoomShape.ROOMSHAPE_IH] =  {name="IH",x=1,y=1,noneighbor={{x=0,y=1},{x=0,y=-1}} }, --specify missing neighbors required
        [RoomShape.ROOMSHAPE_IV] =  {name="IV",x=1,y=1,noneighbor={{x=1,y=0},{x=-1,y=0}} },
        [RoomShape.ROOMSHAPE_IIH] = {name="IIH",y=2,x=1,noneighbor={{x=0,y=1},{x=0,y=-1},{x=1,y=1},{x=1,y=-1}} },
        [RoomShape.ROOMSHAPE_IIV] = {name="IIV",x=1,y=2,noneighbor={{x=1,y=0},{x=-1,y=0},{x=1,y=1},{x=-1,y=1}} },
        [RoomShape.ROOMSHAPE_LTL] = {name="LTL",x=2,y=2,skip={x=0,y=0}},
        [RoomShape.ROOMSHAPE_LTR] = {name="LTR",x=2,y=2,skip={x=1,y=0}},
        [RoomShape.ROOMSHAPE_LBL] = {name="LBL",x=2,y=2,skip={x=0,y=1}},
        [RoomShape.ROOMSHAPE_LBR] = {name="LBR",x=2,y=2,skip={x=1,y=1}},
    }

    local doorpos_to_neighbor_check = {
        [DoorSlot.LEFT0] = {x=-1,y=0},
        [DoorSlot.LEFT1] = {x=-1,y=1},
        [DoorSlot.RIGHT0] = {x=1,y=0},
        [DoorSlot.RIGHT1] = {x=1,y=1},
        [DoorSlot.UP0] = {x=0,y=-1},
        [DoorSlot.UP1] = {x=1,y=-1},
        [DoorSlot.DOWN0] = {x=0,y=1},
        [DoorSlot.DOWN1] = {x=1,y=1},
    }

    -- generate a partially randomized custom layout floor! 
    -- only needs the above data structure, and then the following adjustments to your room file:
    -- The map room needs to have a group entity per special room group. If no group entities are found, no randomization will occur.
    -- Each room layout must include a group entity per room group it is a part of. This is so that a room can be in two groups, if desired.
    GODMODE.generate_ivory_map = function()
        GODMODE.ivory_level_roomlist = GODMODE.ivory_level_roomlist or StageAPI.RoomsList("GODMODEIvoryLevelMap")
        GODMODE.ivory_level_rooms = include("resources.godmode.rooms.luc.ivory_rooms")

        local level_map = GODMODE.generate_semi_randomized_floor(GODMODE.ivory_level_roomlist, GODMODE.ivory_level_rooms)
    end

    --[[ ================================================================================================================================================================== ]]--
    --[[ @author MINDS3T ]]--
    --[[ ================================================================================================================================================================== ]]--
    --[[ WHAT YOU NEED: ]]--
    --[[ ================================================================================================================================================================== ]]--
    --[[ - luaroom file with each room layout in a randomized group having a StageAPI group metadata entity (199.0.X), where X is the group ID (middle click in BR)         ]]--
    --[[ - A map layout, akin to Ivory Palace, Curse of the Everchanger or FF's Gauntlet, as a room layout in the luaroom file.                                             ]]--
    --[[ - In this map layout, to indicate a random group create the same StageAPI group metadata entities that were placed in the room layouts.                            ]]--
    --[[ - Place a StageAPI boss indicator metadata entity on top of the groups in the map room layout to indicate you want rooms removed from the pool as they're placed.  ]]--
    --[[ - Refer to "resources/rooms/luc/ivory_rooms.lua" for an example of proper implementation.                                                                          ]]--
    --[[ ================================================================================================================================================================== ]]--
    --[[ @param max_tries_per_tile: int (default 33)                                                                                                                        ]]--
    --[[ @param rooms_list: StageAPI.RoomsList                                                                                                                              ]]--
    --[[ @param rooms: include("luaroom file")                                                                                                                              ]]--
    --[[ ================================================================================================================================================================== ]]--
    --[[ feel free to re-use this code or parts of it, even rename it, just keep this @ in the comments <3 this took me WAY too long to lay out lmao                        ]]--
    --[[ ================================================================================================================================================================== ]]--
    GODMODE.generate_semi_randomized_floor = function(rooms_list, rooms, max_tries_per_tile)
        max_tries_per_tile = max_tries_per_tile or 33
        rooms_list = rooms_list or StageAPI.RoomsLists["GODMODEIvoryLevelMap"] or StageAPI.RoomsList("GODMODEIvoryLevelMap")
        rooms = rooms or include("resources.godmode.rooms.luc.ivory_rooms")

        -- empty the RoomsList
        rooms_list.All = {}
        rooms_list.ByShape = {}
        rooms_list.Shapes = {}
        rooms_list.NotSimplifiedFiles = {}

        -- then re-add the rooms list so that the random rooms can be re-randomized
        rooms_list:AddRooms(rooms)

        StageAPI.StageRNG:SetSeed(StageAPI.Seeds:GetStageSeed(GODMODE.level:GetStage()), 32)
        local rand = StageAPI.StageRNG 

        -- I use the literal group entity from stageapi to determine what groups are going to be randomly generated, and also to assign rooms to specific groups
        local room_groups = {}

        local get_group_for = function(type) 
            if room_groups[type] == nil then 
                GODMODE.log("Registering group \'"..type.."\'",true) 
            end

            room_groups[type] = room_groups[type] or {}
            return room_groups[type]
        end

        -- index rooms so that bigger rooms can generate correctly when placed randomly 
        for ind,room in ipairs(rooms_list.All) do 
            -- scan room layouts for door restraints and group declarations
            local no_door_list = {} 
            local groups_from_room = {}
            -- look for Boss Indicator entities to indicate if room pools should deplete
            local perishable_markers = {}

            for _,meta in ipairs(room.Entities) do 
                -- collect invalid doors
                if meta.Slot ~= nil and meta.Exists == false then 
                    no_door_list[#door_list + 1] = meta.Slot
                    GODMODE.log("Collected non-door \'"..meta.Slot.."\' for room \'"..room.Variant.."\'!",true)
                end

                -- this is indicating a random group for the map
                if meta.Type == 199 and meta.Variant == 0 then 
                    table.insert(groups_from_room, {type=meta.SubType,pos=Vector(meta.GridX,meta.GridY)})
                    GODMODE.log("Collected group \'"..meta.SubType.."\' for room \'"..room.Variant.."\'!",true)
                end

                -- this indicates a perishable group (pull rooms as they are placed)
                if meta.Type == 199 and meta.Variant == 30 then 
                    table.insert(perishable_markers, {pos=Vector(meta.GridX,meta.GridY)})
                end
            end

            -- check each boss indicator for groups on top of it to mark them perishable
            for _,meta in ipairs(perishable_markers) do 
                for _,group in ipairs(groups_from_room) do 
                    if group.pos.X == meta.GridX and group.pos.Y == meta.GridY then 
                        get_group_for(group.type).perishable = true 
                    end
                end
            end

            -- register this room layout to all groups found in the file
            for _,group_id in ipairs(groups_from_room) do 
                local cur_group = get_group_for(group_id.type)
                table.insert(cur_group, room)

                cur_group.list_of_variants = cur_group.list_of_variants or {}
                local room_shape_data = roomshape_to_neighbor_check[room.Shape] or {x = 1, y = 1}

                for i=1,room_shape_data.x * room_shape_data.y do 
                    table.insert(cur_group.list_of_variants,room.Variant)
                end

                -- store the room
                cur_group[room.Variant] = {room=room,doors=no_door_list} 
                cur_group.max_var = math.max(cur_group.max_var or room.Variant, room.Variant)
                cur_group.min_var = math.min(cur_group.min_var or room.Variant, room.Variant)
                cur_group.max_weight = math.max(cur_group.max_weight or room.Weight, room.Weight)
                cur_group.min_weight = math.min(cur_group.min_weight or room.Weight, room.Weight)
                cur_group.total_weight = (cur_group.total_weight or 0) + room.Weight
            end
        end

        -- rooms from the map layout in the luarooms file 
        local map_rooms = {}
        -- get the bounds of the grid positions
        local min_x, min_y, max_x, max_y = 99, 99, -1, -1

        local floorPlan = rooms_list.All[1]
        if not floorPlan then 
            GODMODE.log("Floor plan is invalid, try reloading!", true)
            return 
        end

        -- scrape valid, replaceable rooms from the map
        for ind,ent in pairs(floorPlan.Entities) do 
            --pulled from stageapi to check for room entities
            local metadata = StageAPI.IsMetadataEntity(ent.Type, ent.Variant) 
            --StageAPI indicates room IDs with subtype increments of 4.
            local group_id = math.floor(ent.SubType / 4)
            
            --check if the group of the room tile matches the room groups discovered so far, if so track it
            if metadata and metadata.Name == "Room" and room_groups[group_id] ~= nil then
                local x, y = ent.GridX, ent.GridY 
                map_rooms[x] = map_rooms[x] or {}
                map_rooms[x][y] = ent
                ent.group_id = group_id
                -- GODMODE.log("added room entity at \'"..x..","..y.."\'!",true)

                min_x = math.min(x,min_x)
                min_y = math.min(y,min_y)
                max_x = math.max(x,max_x)
                max_y = math.max(y,max_y)
            end
        end

        -- looks at neighboring tiles to make sure the room shape can fit in the live randomized map_room grid
        local check_room_size_at = function(shape, tile_x, tile_y, door_blacklist)
            local size = roomshape_to_neighbor_check[shape]
            if not size then 
                GODMODE.log("   -> UNIMPLEMENTED SHAPE \'"..tostring(shape).."\', discarding...",true)
                return false, {x=0,y=0}
            end

            local cur_group_id = map_rooms[tile_x][tile_y].group_id
            local valid = true 
            GODMODE.log("   -> \'"..size.name.."\' shape is sized at \'"..size.x.."x"..size.y.."\' for \'"..(tile_x)..","..(tile_y).."\'. Third arg = "..tostring(size.skip and (size.skip.x..","..size.skip.y) or "NA"),true)

            for x_off=0, size.x-1 do 
                for y_off=0, size.y-1 do 
                    local x_neighbor, y_neighbor = tile_x+x_off, tile_y+y_off
                    GODMODE.log("   -> is \'"..(x_neighbor)..","..(y_neighbor).."\' invalid?",true)

                    -- this is for L-room checks
                    if size.skip == nil or (size.skip ~= nil and not (size.skip.x == x_off and size.skip.y == y_off)) then 
                        -- if the room space is missing, then invalidate the room shape at this position 
                        if not map_rooms[x_neighbor] then 
                            GODMODE.log("    -> {"..(x_neighbor)..","..(y_neighbor).."} yes!!! no row",true)
                            valid=false 
                        elseif (map_rooms[x_neighbor] and not map_rooms[x_neighbor][y_neighbor]) then 
                            GODMODE.log("    -> {"..(x_neighbor)..","..(y_neighbor).."} yes!!! no col",true)
                            valid = false 
                        elseif map_rooms[x_neighbor][y_neighbor].disable_for_neighbor_check == true then 
                            GODMODE.log("    -> {"..(x_neighbor)..","..(y_neighbor).."} yes!!! already disabled",true)
                            valid = false 
                        else
                            local neighbor_group_id = map_rooms[x_neighbor][y_neighbor].group_id
                            
                            if cur_group_id ~= neighbor_group_id and room_groups[neighbor_group_id] then
                                GODMODE.log("    -> {"..(x_neighbor)..","..(y_neighbor).."} yes!!! different neighbor group (mine is "..cur_group_id..", not "..neighbor_group_id..")",true)
                                valid = false 
                            else
                                GODMODE.log("    -> {"..(x_neighbor)..","..(y_neighbor).."} no...",true)
                            end
                        end

                        if valid == false then break end 
                    else 
                        GODMODE.log("    -> {"..(x_neighbor)..","..(y_neighbor).."} no, this is the skipped spot for the L room...",true)
                    end
                end

                if valid == false then break end 
            end

            -- check for the thin rooms to make sure they don't block a face of a room
            if valid and size.noneighbor ~= nil then
                GODMODE.log("   -> checking neighbor requirements for \'"..size.name.."\' shape...",true)

                for _,check in ipairs(size.noneighbor) do 
                    GODMODE.log("    -> is \'"..(tile_x-min_x+1).."+"..check.x..","..(tile_y-min_y+1).."+"..check.y.."\' empty?",true)
                    if map_rooms[tile_x+check.x] and map_rooms[tile_x+check.x][tile_y+check.y] then 
                        GODMODE.log("     -> NO, invalidating..",true)
                        valid = false 
                        break
                    else 
                        GODMODE.log("     -> YES, continuing..",true)
                    end
                end
            end

            -- if there are doors that are disabled for this room, make sure it can still fit 
            if door_blacklist then 
                for _,slot in ipairs(door_blacklist) do 
                    if slot and doorpos_to_neighbor_check[slot] then 
                        local off = doorpos_to_neighbor_check[slot] 

                        GODMODE.log("     -> is door slot "..slot.." offset safe?",true)

                        if map_rooms[tile_x+off.x][tile_y+off.y] ~= nil then 
                            GODMODE.log("      -> no!",true)
                            valid = false 
                        else 
                            GODMODE.log("      -> yes...",true)
                        end
                    end
                end
            end

            return valid, size
        end 

        -- fix LTL rooms not placed correctly on the minimap
        local minimapi_pivot_fix = {}

        -- MEAT AND BONES: now that the rooms have been indexed, we go through the defined groups and re-assign their subtype to a matching room variant for that group!
        -- start from the bottom right and work towards the top left, that way making big rooms is less consequential 
        for x=max_x, min_x, -1 do 
            for y=max_y, min_y, -1 do 
                -- GODMODE.log("checking room at \'"..x..","..y.."\'..",true)
                if map_rooms[x] then 
                    local room = map_rooms[x][y] 

                    if room then 
                        local group_id = math.floor(room.SubType / 4)
                        local cur_group = room_groups[group_id]
   
                        if cur_group then 
                            -- GODMODE.log("->valid room at \'"..x..","..y.."\'..",true)
                            local selected_room = nil 

                            -- try up to 33 different rooms before leaving it at the default of 1
                            local max_depth = max_tries_per_tile

                            while max_depth > 0 do 
                                -- get the pool of rooms for this map entry 
                                selected_room = cur_group.list_of_variants[rand:RandomInt(#cur_group.list_of_variants) + 1]
                                GODMODE.log("choosing a room (IDs between "..cur_group.min_var.."-"..cur_group.max_var..") for group "..group_id.."!",true)
                                local room_shape = cur_group[selected_room].room.Shape

                                -- if the room is valid 
                                if cur_group[selected_room] and cur_group[selected_room].room then 
                                    GODMODE.log("  ->checking room \'"..selected_room.."\', size \'"..room_shape.."\', for \'"..(x)..","..(y).."\'?",true)
                                    local place_valid, check_grid = check_room_size_at(room_shape, x, y, cur_group[selected_room].doors)
                                    
                                    -- if the placement is valid for the selected room shape, then update the overlapping rooms for the room shape to say they are reserved.
                                    if place_valid then 
                                        GODMODE.log("   ->valid placement of \'"..selected_room.."\', size \'"..check_grid.x.."x"..check_grid.y.."\', for \'"..(x)..","..(y).."\'!",true)
                                        
                                        -- convert all spaces that match 
                                        for grid_x_off=check_grid.x-1,0,-1  do 
                                            for grid_y_off=check_grid.y-1,0,-1  do 
                                                -- this is for L-room checks 
                                                -- GODMODE.log("     checking "..grid_x_off.."&"..grid_y_off,true)
                                                if check_grid.skip == nil -- no L, or L and not the empty spot
                                                    or (check_grid.skip and not (check_grid.skip.x == grid_x_off and check_grid.skip.y == grid_y_off)) then 
                                                    local final_x, final_y = x + grid_x_off, y + grid_y_off

                                                    local sel_room_ent = map_rooms[final_x][final_y]

                                                    if sel_room_ent then 
                                                        sel_room_ent.SubType = selected_room * 4
                                                        GODMODE.log("----->placed room \'"..selected_room.."\' , size \'"..room_shape.."\', at \'"..(x).."+"..grid_x_off.." ("..final_x.."),"..(y).."+"..grid_y_off.." ("..final_y..")\'!",true)
                                                            
                                                        -- if there was a boss indicator on top of this group then remove the rooms from the pool as they place
                                                        if cur_group.perishable then  
                                                            GODMODE.log("----->group is perishable, removing \'"..selected_room.."\' from pool!",true)
                                                            table.remove(cur_group.list_of_variants, selected_room)
                                                            cur_group[selected_room] = nil
                                                        end

                                                        -- if this is a larger room we need to reserve these seats, so to speak
                                                        if check_grid.x > 1 or check_grid.y > 1 then 
                                                            sel_room_ent.disable_for_neighbor_check = true
                                                            GODMODE.log("------> (marked the room as reserved due to size of current layout)",true)
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                        -- MinimapAPI pivots specifically this room type around 1,0 instead of 0,0 :L
                                        if MinimapAPI and MinimapAPI.RoomShapeGridPivots[room_shape] ~= Vector.Zero then 
                                            GODMODE.log("----------> (added the room to the list of LTL rooms for MinimapAPI fix)",true)
                                            table.insert(minimapi_pivot_fix, {x=final_x,y=final_y,shape=room_shape})
                                        end
                                        
                                        break
                                    end
                                end

                                max_depth = max_depth - 1
                            end

                            if max_depth == 0 then 
                                GODMODE.log("set \'"..(x)..","..(y).."\' to default room of "..cur_group.min_var..".")
                                map_rooms[x][y].SubType = cur_group.min_var * 4 -- if failed to find a successful room, use the first room ID indexed for the group
                            end
                        end
                    end
                end
            end
        end

        -- finally, take the frankenstein'ed roomslist and give it to StageAPI >:D
        GODMODE.ivory_map = StageAPI.CreateMapFromRoomsList(rooms_list, nil, {NoChampions = false})
        StageAPI.InitCustomLevel(GODMODE.ivory_map, true)
        GODMODE.save_manager.set_data("PalaceMinibossKills", 0, true)

        -- if MinimapAPI then 
        --     for _,room in ipairs(minimapi_pivot_fix) do 
        --         local minimap_room = MinimapAPI:GetRoomAtPosition(Vector(room.x,room.y))
        --         if minimap_room then 
        --             minimap_room.DisplayPosition = minimap_room.DisplayPosition + MinimapAPI.RoomShapeGridPivots[room.shape]
        --         end
        --     end
        -- end

        return GODMODE.ivory_map
    end

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
        rocks = "godmode/gfx/grid/unlock_room/rocks.png",
        pits = "godmode/gfx/grid/unlock_room/pits.png",
        alt_pits = "godmode/gfx/grid/unlock_room/pits.png",
        bridge = "godmode/gfx/grid/unlock_room/bridge.png",
        shading = "godmode/gfx/backdrop/base_shading/shading",
        player_spot = "godmode/gfx/ui/stage/unlock_room/boss_spot.png",
        boss_spot = "godmode/gfx/ui/stage/unlock_room/player_spot.png",
    
        backdrop_gfx = {
            Walls = {""},
            NFloors = {"nfloor"},
            LFloors = {"lfloor"},
            Corners = {"corner"}
        }, 
    
        backdrop_prefix = "godmode/gfx/backdrop/unlock_room/unlock", 
        backdrop_suffix = ".png",
    
        doors = {
            {graphic="godmode/gfx/grid/unlock_room/doors/normal.png", req=GODMODE.util.base_room_door},
            {graphic="godmode/gfx/grid/basedoors/door_00_shopdoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_SHOP}}},
            {graphic="godmode/gfx/grid/basedoors/door_05_arcaderoomdoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_ARCADE}}},
            {graphic="godmode/gfx/grid/basedoors/door_13_librarydoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_LIBRARY}}},
        }
    })

    GODMODE.backdrops.observatory_gfx = GODMODE.make_room_gfx({
        backdrop_gfx = {
            Walls = {""},
            NFloors = {"nfloor"},
            LFloors = {"lfloor"},
            Corners = {"corner"}
        }, 
    
        backdrop_prefix = "godmode/gfx/backdrop/observatory/observatory_back", 
        backdrop_suffix = ".png",
    
        doors = {
            {graphic="godmode/gfx/grid/observatory_door.png", req=GODMODE.util.base_room_door},
        }
    })

    GODMODE.backdrops.correction_gfx = GODMODE.make_room_gfx({
        backdrop_gfx = {
            Walls = {"1","2"},
            NFloors = {"nfloor"},
            LFloors = {"lfloor"},
            Corners = {"corner"}
        }, 
    
        backdrop_prefix = "godmode/gfx/backdrop/correction/correct_", 
        backdrop_suffix = ".png",
    
        doors = {
            {graphic="godmode/gfx/grid/correction_door.png", req=GODMODE.util.base_room_door},
        }
    })

    GODMODE.backdrops.correction_dogma_gfx = GODMODE.make_room_gfx({
        backdrop_gfx = {
            Walls = {""},
            NFloors = {"nfloor"},
            LFloors = {"lfloor"},
            Corners = {"corner"}
        }, 
    
        backdrop_prefix = "godmode/gfx/backdrop/correction/correction_back", 
        backdrop_suffix = ".png",
    
        doors = {
            {graphic="godmode/gfx/grid/correction_door2.png", req=GODMODE.util.base_room_door},
        }
    })

    GODMODE.backdrops.sheol_to_palace = GODMODE.make_room_gfx({
        backdrop_gfx = {
            Walls = {"1","2","3","4"},
            NFloors = {"nfloor"},
            LFloors = {"lfloor"},
            Corners = {"corner"}
        }, 
    
        backdrop_prefix = "godmode/gfx/backdrop/god_palace_night/sheol_", 
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
    
        backdrop_prefix = "godmode/gfx/backdrop/god_palace_day/palace_", 
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
        backdrop_prefix = "godmode/gfx/backdrop/god_sanctuary/sanctuary_", 
        backdrop_suffix = ".png",
        overlay = StageAPI.Overlay("godmode/gfx/backdrop/god_sanctuary/sanctuary_overlay.anm2", Vector(0.55,0.45), Vector(-10,-10)),
    
        doors = {
            {graphic="godmode/gfx/grid/sanctuary/door.png", req=GODMODE.util.base_room_door},
        }
    })

    GODMODE.backdrops.lower_level = GODMODE.make_room_gfx({
        backdrop_gfx = {
            Walls = {"1"},
            NFloors = {"nfloor"},
            LFloors = {"lfloor"},
            Corners = {"corner"}
        }, 
    
        backdrop_prefix = "godmode/gfx/backdrop/lower/lower_", 
        backdrop_suffix = ".png",
    
        doors = {
            {graphic="godmode/gfx/grid/correction_door.png", req=GODMODE.util.base_room_door},
        }
    })

    GODMODE.backdrop_overlays = {
        -- [LevelStage.STAGE5..","..StageType.STAGETYPE_ORIGINAL] = "SheolToPalace",
        -- [LevelStage.STAGE5..","..StageType.STAGETYPE_WOTL] = "CathedralToPalace",
        -- [LevelStage.STAGE6..","..StageType.STAGETYPE_ORIGINAL] = "DarkRoomToFurnace",
        [LevelStage.STAGE6..","..StageType.STAGETYPE_WOTL] = StageAPI.Overlay("godmode/gfx/backdrop/god_sanctuary/sanctuary_overlay.anm2", Vector(0.55,0.45), Vector(-10,-10)),
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

    if GODMODE.validate_rgon() then 
        function GODMODE.mod_object:pre_render_walls() 
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

        GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_BACKDROP_RENDER_WATER, GODMODE.mod_object.pre_render_walls)
    else 
        -- StageAPI.AddCallback(GODMODE.mod_id, "PRE_TRANSITION_RENDER", 2, function()
        --     overlay_func()
        -- end)    
    end



    -- GODMODE.ObservatoryDoor = StageAPI.CustomDoor("ObservatoryDoor", "godmode/gfx/grid/observatory_door.anm2", nil, nil, nil, nil, true)

    GODMODE.observatory_rooms = StageAPI.RoomsList("GODMODE-Observatory",include("resources.godmode.rooms.observatory_rooms"))--StageAPI.CreateEmptyRoomLayout(RoomShape.ROOMSHAPE_1x1)

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


-- mod music callback
if MMC then 
    MMC.AddMusicCallback(GODMODE.mod_object, function()
        local bd_key = GODMODE.level:GetAbsoluteStage()..","..GODMODE.level:GetStageType()

        if (GODMODE.room_type or GODMODE.room:GetType()) ~= RoomType.ROOM_BOSS and GODMODE.level:GetStage() == LevelStage.STAGE5 and GODMODE.level:GetStageType() == StageType.STAGETYPE_WOTL then
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


if MinimapAPI then 
    GODMODE.sprites.minimapapi_sprite = Sprite()
    GODMODE.sprites.minimapapi_sprite:Load("godmode/gfx/ui/minimapapi/godmode_minimap.anm2", true)
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

-- THEYVE DONE IT! THEYVE FIXED IT!
-- -- community remix debug with knife pieces, unfortunately this doesn't seem to work if I put it here on my end but I will keep this here until community remix fixes it
-- if communityRemix then 
--     communityRemix:AddPriorityCallback (ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, function(self, p, flag)
--         if flag == CacheFlag.CACHE_FAMILIARS then
--             local numFamiliars = p:GetTrinketMultiplier(TrinketType.TRINKET_INFANTICIDE) + p:GetEffects():GetTrinketEffectNum(TrinketType.TRINKET_INFANTICIDE)
--              + math.min(p:GetCollectibleNum(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1), p:GetCollectibleNum(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2))
           
--             p:CheckFamiliar(
--                 FamiliarVariant.KNIFE_FULL,
--                 numFamiliars,
--                 p:GetTrinketRNG(TrinketType.TRINKET_INFANTICIDE)
--             )
--         end
--     end)    
-- end

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