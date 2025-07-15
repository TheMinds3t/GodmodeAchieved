local options = {}

options.mod = RegisterMod("GodmodeAchievedOptions", 1)

local dsscore = include("godmode.scripts.godmodemenucore")
-- DSSCoreVersion determines which menu controls the mod selection menu that allows you to enter other mod menus.
-- Don't change it unless you really need to and make sure if you do that you can handle mod selection and global mod options properly.
local DSSCoreVersion = 7

-- Every menu_provider function below must have its own implementation in your mod, in order to handle menu save data.
local menu_provider = {}
local json = require("json")

local function get_dss_data()
    return GODMODE.save_manager.get_dss()
end

local function save_dss_data()
    return GODMODE.save_manager.set_dss(GODMODE.save_manager.get_dss(),true)
end


function menu_provider.SaveSaveData()
    save_dss_data()
end

function menu_provider.GetPaletteSetting()
    return get_dss_data().MenuPalette
end

function menu_provider.SavePaletteSetting(var)
    get_dss_data().MenuPalette = var
end

function menu_provider.GetHudOffsetSetting()
    if not REPENTANCE then
        return get_dss_data().HudOffset
    else
        return Options.HUDOffset * 10
    end
end

function menu_provider.SaveHudOffsetSetting(var)
    if not REPENTANCE then
        get_dss_data().HudOffset = var
    end
end

function menu_provider.GetGamepadToggleSetting()
    return get_dss_data().GamepadToggle
end

function menu_provider.SaveGamepadToggleSetting(var)
    get_dss_data().GamepadToggle = var
end

function menu_provider.GetMenuKeybindSetting()
    return get_dss_data().MenuKeybind
end

function menu_provider.SaveMenuKeybindSetting(var)
    get_dss_data().MenuKeybind = var
end

function menu_provider.GetMenuHintSetting()
    return get_dss_data().MenuHint
end

function menu_provider.SaveMenuHintSetting(var)
    get_dss_data().MenuHint = var
end

function menu_provider.GetMenuBuzzerSetting()
    return get_dss_data().MenuBuzzer
end

function menu_provider.SaveMenuBuzzerSetting(var)
    get_dss_data().MenuBuzzer = var
end

function menu_provider.GetMenusNotified()
    return get_dss_data().MenusNotified
end

function menu_provider.SaveMenusNotified(var)
    get_dss_data().MenusNotified = var
end

function menu_provider.GetMenusPoppedUp()
    return get_dss_data().MenusPoppedUp
end

function menu_provider.SaveMenusPoppedUp(var)
    get_dss_data().MenusPoppedUp = var
end

--[[
##################################################################################
##################################################################################
##################################################################################
DSS ESSENTIALS END
######################################################################################
######################################################################################
######################################################################################
]]--

-- This function returns a table that some useful functions and defaults are stored on
options.dssmod = dsscore.init("Dead Sea Scrolls (Godmode Achieved)", menu_provider)

-- search for base DSS buttons to flag for ModConfigMenu conversion
for key,val in pairs(options.dssmod) do 
    if key:find("Button",1,true) and type(options.dssmod[key]) == "table" then 
        options.dssmod[key].dss_button = true
    end
end

options.gap = {
    -- Creating gaps in your page can be done simply by inserting a blank button.
    -- The "nosel" tag will make it impossible to select, so it'll be skipped over when traversing the menu, while still rendering!
    str = '', fsize = 2, nosel = true, gap = true,
}

options.bool_choices = {
    'disabled',
    'enabled'
}

options.scaling_choices = {
    "stage",
    "stats"
}

options.unlock_choices = {
    'locked',
    'unlocked'
}

options.bypass_choices = {
    'bypassed', 
    'standard'
}

options.tutorial_choices = {
    'file', 
    'session',
    'run',
}

options.palace_clear_options = {'0', '1', '2', '3', '4', '5+'}
options.fractal_display_choices = {'disabled','freeform','stathud'}
options.red_juice_choices = {'color+distort','color','distort','none'}

options.bool_map = {
    [2] = "true",
    [1] = "false",
    ["enabled"] = "true",
    ["disabled"] = "false"
}

options.str_bool_map = {
    ["true"] = 2,
    ["false"] = 1,
    [true] = 2,
    [false] = 1,
}

options.back_option = {str = 'back', action = 'back'}

local default_reset = "reset data?"
local next_reset = {
    [default_reset] = "really reset? (3)",
    ["really reset? (3)"] = "are you sure? (2)",
    ["are you sure? (2)"] = "last warning! (1)",
    ["last warning! (1)"] = "data wiped!"
}

local default_conf_reset = "reset config?"
local next_conf_reset = {
    [default_conf_reset] = "are you sure? (2)",
    ["are you sure? (2)"] = "config=default?! (1)",
    ["config=default?! (1)"] = "config reset!"
}

options.layout = {
    main = {
        title = "godmode achieved",

        buttons = {
            {str = 'resume game', action = 'resume'},
            {str = 'settings', dest = 'settings'},
            {str = "credits", dest="credits"},
            options.dssmod.changelogsButton,
        },

        tooltip = options.dssmod.menuOpenToolTip
    },
    settings = {
        title = "settings",
        buttons = {
            {str = "alts", dest="alts"},
            {str = "scaling", dest="scaling"},
            {str = "gameplay", dest="gameplay"},
            {str = "unlocks", dest="unlocks"},
            {str = "cosmetic", dest="cosmetic"},
            {str = "controls", dest="controls"},
            options.gap,
            {str = "tutorials", dest="tutorials"},
            options.gap,
            {str = "wipe data", dest="reset"},
            {str = "godmode", dest="godmode"},
            {str = "credits", dest="credits"},
            options.gap,
            {str = 'back', dest = 'main'},
        }
    },
    alts = {
        title = "alts",
        buttons = {
            --alt stage section

            {
                str = 'stage chance',
                min = 0, max = 100, increment = 5, suf = '%', setting = 25,
                variable = 'GodmodeGodmodeStageChance',
                
                load = function()
                    return math.floor(tonumber(GODMODE.save_manager.get_config("GodmodeStageChance","0.25"))*100)
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("GodmodeStageChance",var/100.0,true)
                end,

                tooltip = {strset = {'chance that', 'godmode', 'stages', 'will occur'}}
            },

            options.gap,

            --alt boss section
            -- {
            --     str = 'alt bosses',
            --     choices = options.bool_choices, setting = 2,
            --     variable = 'GodmodeBossesEnabled',

            --     load = function()
            --         return options.str_bool_map[GODMODE.save_manager.get_config("BossesEnabled","true")] or 2
            --     end,
            --     store = function(var)
            --         GODMODE.save_manager.set_config("BossesEnabled",options.bool_map[var],true)
            --     end,

            --     tooltip = {strset = {'can alt', 'bosses', 'spawn'}}
            -- },
            {
                str = 'end-boss chance',
                min = 0, max = 1000, increment = 25, suf = '%', setting = 50,
                variable = 'GodmodeMajorBossPercent',
                
                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'alt bosses' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return math.floor(tonumber(GODMODE.save_manager.get_config("MajorBossPercent","0.5"))*100)
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("MajorBossPercent",var/100.0,true)
                end,

                tooltip = {strset = {'weight for', 'new bosses', 'replacing','endgame', 'bosses'}}
            },
            {
                str = 'boss chance',
                min = 0, max = 1000, increment = 25, suf = '%', setting = 50,
                variable = 'GodmodeMinorBossPercent',
                
                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'alt bosses' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return math.floor(tonumber(GODMODE.save_manager.get_config("MinorBossPercent","0.5"))*100)
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("MinorBossPercent",var/100.0,true)
                end,

                tooltip = {strset = {'weight for', 'new bosses', 'spawning','in stages'}}
            },
            {
                str = 'horseman chance',
                min = 0, max = 100, increment = 5, suf = '%', setting = 20,
                variable = 'GodmodeAltHorsemanChance',
                
                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'alt bosses' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return math.floor(tonumber(GODMODE.save_manager.get_config("AltHorsemanChance","0.25"))*100)
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("AltHorsemanChance",var/100.0,true)
                end,

                tooltip = {strset = {'chance that', 'godmode', 'horsemen', 'will occur'}}
            },

            -- options.gap,

            -- --alt enemy section
            -- {
            --     str = 'alt enemies',
            --     choices = options.bool_choices, setting = 2,
            --     variable = 'GodmodeEnemyAlts',

            --     load = function()
            --         return options.str_bool_map[GODMODE.save_manager.get_config("EnemyAlts","true")] or 2
            --     end,
            --     store = function(var)
            --         GODMODE.save_manager.set_config("EnemyAlts",options.bool_map[var],true)
            --     end,

            --     tooltip = {strset = {'can alt', 'enemies', 'spawn'}}
            -- },
            {
                str = 'alt enemy weight',
                min = 0, max = 1000, increment = 10, suf = '%', setting = 50,
                variable = 'GodmodeEnemyModifier',
                
                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'alt enemies' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return math.floor(tonumber(GODMODE.save_manager.get_config("EnemyModifier","0.5"))*100)
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("EnemyModifier",var/100.0,true)
                end,

                tooltip = {strset = {'weight for', 'alt enemies', 'replacing','enemies'}}
            },
            {
                str = 'add to enemy cap',
                min = -10, max = 20, increment = 1, pref="+", setting = 0,
                variable = 'GodmodeEnemyCapModifier',
                
                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'alt enemies' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return tonumber(GODMODE.save_manager.get_config("EnemyCapModifier","0"))
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("EnemyCapModifier",var,true)
                end,

                tooltip = {strset = {'add max per', 'room for', 'alt enemy','spawns'}}
            },

            -- options.gap,

            -- --alt pickup section
            -- {
            --     str = 'alt pickups',
            --     choices = options.bool_choices, setting = 2,
            --     variable = 'GodmodePickupAlts',

            --     load = function()
            --         return options.str_bool_map[GODMODE.save_manager.get_config("PickupAlts","true")] or 2
            --     end,
            --     store = function(var)
            --         GODMODE.save_manager.set_config("PickupAlts",options.bool_map[var],true)
            --     end,

            --     tooltip = {strset = {'can alt', 'pickups', 'spawn'}}
            -- },
            {
                str = 'alt pickup weight',
                min = 0, max = 1000, increment = 10, suf = '%', setting = 50,
                variable = 'GodmodePickupModifier',
                
                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'alt pickups' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return math.floor(tonumber(GODMODE.save_manager.get_config("PickupModifier","0.5"))*100)
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("PickupModifier",var/100.0,true)
                end,

                tooltip = {strset = {'weight for', 'alt pickups', 'replacing','pickups'}}
            },
            {
                str = 'add to pickup cap',
                min = -10, max = 20, increment = 1, pref="+", setting = 0,
                variable = 'GodmodePickupCapModifier',
                
                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'alt pickups' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return math.floor(tonumber(GODMODE.save_manager.get_config("PickupCapModifier","0")))
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("PickupCapModifier",var,true)
                end,

                tooltip = {strset = {'add max per', 'room for', 'alt pickup','spawns'}}
            },


            options.gap,
            options.back_option,
        }
    },
    scaling = {
        title = "scaling",
        buttons = {
            --hard mode scaling
            {
                str = 'scale factor',
                choices = options.scaling_choices, setting = 2,
                variable = 'GodmodeHMEnabled',

                load = function()
                    return tonumber(GODMODE.save_manager.get_config("HPScaleMode","1"))
                end,
                displayif = function(button, item, menuObj)
                    local ret = false 
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if (btn.str == 'hard hp scaling' or btn.str == 'greedier hp scaling') and btn.setting == 2 then
                                ret = true 
                            end
                        end
                    end

                    return ret
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("HPScaleMode",var,true)
                end,

                tooltip = {strset = {'does enemy', 'health scale', 'based on', 'stage depth', 'or stat score?','','(disable','below)'}}
            },
            options.gap,
            {
                str = 'hard hp scaling',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeHMEnabled',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("HMEnabled","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("HMEnabled",options.bool_map[var],true)
                end,

                tooltip = {strset = {'does enemy', 'health scale', 'on hard?'}}
            },
            {
                str = 'max enemy hp %',
                min = 10, max = 1000, increment = 10, suf = '%', setting = 200,
                variable = 'GodmodeHMEScale',
                
                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'hard hp scaling' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return tonumber(GODMODE.save_manager.get_config("HMEScale","2"))*100
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("HMEScale",var/100.0,true)
                end,

                tooltip = {strset = {'enemy hp', 'scale cap','that is', 'present in', 'the void'}}
            },
            {
                str = 'max boss hp %',
                min = 10, max = 1000, increment = 10, suf = '%', setting = 230,
                variable = 'GodmodeHMBScale',
                
                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'hard hp scaling' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return tonumber(GODMODE.save_manager.get_config("HMBScale","2.3"))*100
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("HMBScale",var/100.0,true)
                end,

                tooltip = {strset = {'boss hp', 'scale cap','that is', 'present in', 'the void', '(applies in','miniboss and','boss rooms)'}}
            },
            options.gap,

            --greedier mode scaling
            {
                str = 'greedier hp scaling',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeGMEnabled',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("GMEnabled","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("GMEnabled",options.bool_map[var],true)
                end,

                tooltip = {strset = {'does enemy', 'health scale', 'in greedier?'}}
            },
            {
                str = 'max enemy hp %',
                min = 10, max = 1000, increment = 10, suf = '%', setting = 150,
                variable = 'GodmodeGMEScale',

                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'greedier hp scaling' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,
                
                load = function()
                    return tonumber(GODMODE.save_manager.get_config("GMEScale","1.5"))*100
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("GMEScale",var/100.0,true)
                end,

                tooltip = {strset = {'enemy hp', 'scale cap','that is', 'present in', 'the shop'}}
            },
            {
                str = 'max boss hp %',
                min = 10, max = 1000, increment = 10, suf = '%', setting = 180,
                variable = 'GodmodeGMBScale',
                
                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'greedier hp scaling' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return tonumber(GODMODE.save_manager.get_config("GMBScale","1.8"))*100
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("GMBScale",var/100.0,true)
                end,

                tooltip = {strset = {'boss hp', 'scale cap','that is', 'present in', 'the shop'}}
            },
            options.gap,

            --general scaling
            {
                str = 'victory lap scaling',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeVLapEnabled',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("VLapEnabled","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("VLapEnabled",options.bool_map[var],true)
                end,

                tooltip = {strset = {'does enemy', 'health scale', 'with', 'victory laps', '(higher the', 'deeper you', 'are)'}}
            },
            options.gap,
            {
                str = 'hp scale ceiling',
                min = 0, max = 10000, increment = 50, pref="<= ", setting = 3000,
                variable = 'GodmodeScaleSelectorMax',
                
                load = function()
                    return tonumber(GODMODE.save_manager.get_config("ScaleSelectorMax","3000"))
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("ScaleSelectorMax",var,true)
                end,

                tooltip = {strset = {'if enemy/boss','has more hp','than this,','don\'t scale hp'}}
            },
            options.gap,
            {
                str = 'story boss hp buff',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeVanillaStoryHPBuff',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("VanillaStoryHPBuff","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("VanillaStoryHPBuff",options.bool_map[var],true)
                end,

                tooltip = {strset = {'do vanilla','story bosses','get similar,','scaling hp','buff to','godmode','story bosses?'}}
            },
            {
                str = 'max story hp buff',
                min = 0, max = 10000, increment = 50, suf=" hp", setting = 1000,

                variable = 'GodmodeVanillaStoryHPBuffCap',
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'story boss hp buff' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,
                
                load = function()
                    return tonumber(GODMODE.save_manager.get_config("VanillaStoryHPBuffCap","1000.0"))
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("VanillaStoryHPBuffCap",var,true)
                end,

                tooltip = {strset = {'how much','extra health','can vanilla','story bosses', 'get?','(seperate','from hp','scaling)'}}
            },

            options.gap,
            options.back_option,
        }
    },
    gameplay = {
        title = "gameplay",
        buttons = {
            --item functions
            {
                str = 'planetarium items',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeMultiPlanetItems',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("MultiPlanetItems","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("MultiPlanetItems",options.bool_map[var],true)
                end,

                tooltip = {strset = {'can you take','more than one','planetarium','item','(or spawn lens','if only one','is present)'}}
            },
            {
                str = 'both alt path items',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeBothRepPathItems',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("BothRepPathItems","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("BothRepPathItems",options.bool_map[var],true)
                end,

                tooltip = {strset = {'can you take','more than one','alt path','item'}}
            },
            {
                str = 't. lost mom\'s wish',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeTaintedLostWish',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("TaintedLostWish","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("TaintedLostWish",options.bool_map[var],true)
                end,

                tooltip = {strset = {'does t. lost','start with','mom\'s wish'}}
            },

            options.gap,
            --time functions
            {
                str = 'boss rush time',
                min = 0, max = 60, increment = 1, suf=' mins', setting = 20,
                variable = 'GodmodeBRTimeMins',
                
                load = function()
                    return tonumber(GODMODE.save_manager.get_config("BRTimeMins","3000"))
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("BRTimeMins",var,true)
                end,

                tooltip = {strset = {'when does the','boss rush','door close'}}
            },
            {
                str = 'blue womb time',
                min = 0, max = 60, increment = 1, suf=' mins', setting = 35,
                variable = 'GodmodeHushTimeMins',
                
                load = function()
                    return tonumber(GODMODE.save_manager.get_config("HushTimeMins","3000"))
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("HushTimeMins",var,true)
                end,

                tooltip = {strset = {'when does the','blue womb','door close'}}
            },
            {
                str = 'blue womb rework',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeBlueWombRework',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("BlueWombRework","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("BlueWombRework",options.bool_map[var],true)
                end,

                tooltip = {strset = {'replace blue','womb chests','with 8','red keys'}}
            },

            options.gap,
            --call of the void
            {
                str = 'call of the void',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeCallOfTheVoid',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("CallOfTheVoid","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("CallOfTheVoid",options.bool_map[var],true)
                end,

                tooltip = {strset = {'in hard','spawns a','deity to','punish taking','too much time','on a stage'}}
            },
            {
                str = 'cotv spawn time',
                min = 0, max = 60, increment = 0.5, suf=' mins', setting = 8,
                variable = 'GodmodeVoidEnterTime',

                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'call of the void' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,
                
                load = function()
                    return (tonumber(GODMODE.save_manager.get_config("VoidEnterTime",tostring(30*60*4+5)))-5) / 30 / 60
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("VoidEnterTime",var*30*60+5,true)
                end,

                tooltip = {strset = {'when does','call of','the void','spawn'}}
            },
            {
                str = 'cotv strength',
                min = 1, max = 12, increment = 1, suf=' charges', setting = 4,
                variable = 'GodmodeVoidStrength',

                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'call of the void' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,
                
                load = function()
                    return tonumber(GODMODE.save_manager.get_config("VoidStrength","4"))
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("VoidStrength",var,true)
                end,

                tooltip = {strset = {'how many','charges does','call of','the void','receive on','spawn?'}}
            },
            options.gap,
            {
                str = 'faithless decay',
                min = 1, max = 12, increment = 1, suf=' charges', setting = 2,
                variable = 'GodmodeFaithlessDecay',
                
                load = function()
                    return tonumber(GODMODE.save_manager.get_config("FaithlessStageDecay","2"))
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("FaithlessStageDecay",var,true)
                end,

                tooltip = {strset = {'how many','faithless','hearts get','removed','when entering','a new stage?'}}
            },

            options.gap,
            --door hazard
            {
                str = 'door hazard chance',
                min = 0, max = 100, increment = 5, suf='%', setting = 10,
                variable = 'GodmodeDoorHazardChanceMod',
                
                load = function()
                    return math.floor(tonumber(GODMODE.save_manager.get_config("DoorHazardChanceMod","0.1"))*100.0)
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("DoorHazardChanceMod",var/100.0,true)
                end,

                tooltip = {strset = {'how likely','are door','hazards to','spawn'}}
            },
            {
                str = 'cotv door hazards',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeCOTVDoorHazardFX',

                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'call of the void' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("COTVDoorHazardFX","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("COTVDoorHazardFX",options.bool_map[var],true)
                end,

                tooltip = {strset = {'when cotv','spawns, do','additional','cotv door','hazards spawn?'}}
            },
            options.gap,
            -- correction room
            {
                str = 'correction room',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeStatHelp',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("StatHelp","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("StatHelp",options.bool_map[var],true)
                end,

                tooltip = {strset = {'if you','are weak,','get access to','a special','room to','become','stronger'}}
            },
            {
                str = 'correction %',
                min = 0, max = 200, increment = 5, suf='%', setting = 10,
                variable = 'GodmodeStatHelpMod',
                
                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'correction room' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return math.floor(tonumber(GODMODE.save_manager.get_config("StatHelpMod","0.8"))*100.0)
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("StatHelpMod",var/100.0,true)
                end,


                tooltip = {strset = {'what %','of scaled','base stats to','receive help'}}
            },
            options.gap,
            {
                str = 'toxic decay rate',
                min = 10, max = 240, increment = 1, suf=' secs', setting = 120,
                variable = 'GodmodeToxicDecayRate',

                load = function()
                    return tonumber(GODMODE.save_manager.get_config("ToxicDecayRate","120.0"))
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("ToxicDecayRate",var,true)
                end,

                tooltip = {strset = {'how long','does it take','for t. recluse','to lose','toxic charge'}}
            },
            options.gap,
            -- more options rework
            {
                str = 'more options redo',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeMoreOptionsRework',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("MoreOptionsRework","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("MoreOptionsRework",options.bool_map[var],true)
                end,

                tooltip = {strset = {'reworked','version','allows you', 'to grab up to','1+count',"items per","room, shown"," by marks"}}
            },
            options.gap,
            {
                str = 'chest infestors',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeChestInfestToggle',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("ChestInfestToggle","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("ChestInfestToggle",options.bool_map[var],true)
                end,

                tooltip = {strset = {'t. isaac unlock','-----------','enable chest','infestors,','if unlocked?'}}
            },
            {
                str = 'chest infest chance',
                min = 0, max = 100, increment = 2.5, suf='%', setting = 30,
                variable = 'GodmodeChestInfestChance',
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'chest infestors' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,
                
                load = function()
                    return tonumber(GODMODE.save_manager.get_config("ChestInfestChance","30.0"))
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("ChestInfestChance",var,true)
                end,

                tooltip = {strset = {'t. isaac unlock','-----------','what chance','for','chest infestor','to spawn','per chest?'}}
            },

            options.gap,
            {
                str = 'safe boss rooms',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeDehazardBossRooms',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("DehazardBossRooms","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("DehazardBossRooms",options.bool_map[var],true)
                end,

                tooltip = {strset = {'do hazards','get cleared','after beating','a boss','or miniboss?'}}
            },
            options.gap,
            {
                str = 'light item rooms',
                choices = options.bool_choices, setting = 1,
                variable = 'GodmodeLighterTreasure',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("LighterTreasure","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("LighterTreasure",options.bool_map[var],true)
                end,

                tooltip = {strset = {'only 1 item','per item room', 'or get','all items?','','(just makes','godmode','multi rooms','a choice)'}}
            },
            -- -- new autofire mechanic!
            -- {
            --     str = 'auto attack',
            --     choices = options.bool_choices, setting = 2,
            --     variable = 'GodmodeAutoChargeAttack',

            --     load = function()
            --         return options.str_bool_map[GODMODE.save_manager.get_config("AutoChargeAttack","true")] or 2
            --     end,
            --     store = function(var)
            --         GODMODE.save_manager.set_config("AutoChargeAttack",options.bool_map[var],true)
            --     end,

            --     tooltip = {strset = {'with charged','weapons, auto','use when full',' charge and ','enemies in','room > 0?', "(repentogon","needed)"}}
            -- },            
            -- options.gap,
            options.back_option,
        }
    },
    unlocks = {
        title = "unlocks",
        buttons = { -- auto populated below for items
            {
                str = 'palace clears',
                choices = options.palace_clear_options, setting = 1,
                variable = 'GodmodePalaceKills',
                
                load = function()
                    return math.min(6,tonumber(GODMODE.save_manager.get_persistant_data("PalaceKills","0"))+1)
                end,
                store = function(var)
                    GODMODE.save_manager.set_persistant_data("PalaceKills",var-1,true)
                    GODMODE.save_manager.set_persistant_data("PalaceComplete", tostring(var == 6))
                end,

                unlock_but = true,

                tooltip = {strset = {'times the','fallen light', 'and the sign', 'have been', 'defeated', '(changes base', 'stats of', 'the sign)'}}
            },
            options.gap,
        }
    },
    cosmetic = {
        title = "cosmetic",
        buttons = {
            {
                str = 'sheol resprite',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeSheolResprite',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("SheolToPalace","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("SheolToPalace",options.bool_map[var],true)
                end,
                unlock_but = true,
                tooltip = {strset = {'use og','godmode stage','aesthetics?','','sheol','=','palace (night)'}}
            },
            options.gap,
            {
                str = 'cathedral resprite',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeCathedralResprite',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("CathedralToPalace","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("CathedralToPalace",options.bool_map[var],true)
                end,

                tooltip = {strset = {'use og','godmode stage','aesthetics?','','cathedral','=','palace (day)'}}
            },
            options.gap,
            {
                str = 'shop theme',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeShopTheme',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("ShopTheme","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("ShopTheme",options.bool_map[var],true)
                end,

                tooltip = {strset = {'use godmode','theme for','shops?'}}
            },
            {
                str = 'cathedral theme',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeCathedralTheme',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("CathedralTheme","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("CathedralTheme",options.bool_map[var],true)
                end,

                tooltip = {strset = {'use godmode','theme for ','cathedral','when using', 'godmode','background?'}}
            },
            -- options.gap,
            -- {
            --     str = 'dark room resprite',
            --     choices = options.bool_choices, setting = 2,
            --     variable = 'GodmodeDarkRoomResprite',

            --     load = function()
            --         return options.str_bool_map[GODMODE.save_manager.get_config("DarkRoomToFurnace","true")] or 2
            --     end,
            --     store = function(var)
            --         GODMODE.save_manager.set_config("DarkRoomToFurnace",options.bool_map[var],true)
            --     end,

            --     tooltip = {strset = {'use og','godmode stage','aesthetics?','','dark room','=','furnace'}}
            -- },
            options.gap,
            {
                str = 'chest resprite',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeChestResprite',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("ChestToSanctuary","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("ChestToSanctuary",options.bool_map[var],true)
                end,

                tooltip = {strset = {'use og','godmode stage','aesthetics?','', 'chest','=','sanctuary'}}
            },
            options.gap,
            options.gap,
            {
                str = 'void overlay',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeVoidOverlay',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("VoidOverlay","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("VoidOverlay",options.bool_map[var],true)
                end,

                tooltip = {strset = {'render','cosmetic','shadow around','the screen','in the void?'}}
            },
            options.gap,
            {
                str = 'keepah',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeShopParrot',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("ShopParrot","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("ShopParrot",options.bool_map[var],true)
                end,

                tooltip = {strset = {'spawn keepah','the shop','parrot in','every shop?'}}
            },
            {
                str = 'mute keepah?',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeMuteShopParrot',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("MuteShopBird","false")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("MuteShopBird",options.bool_map[var],true)
                end,

                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'keepah' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                tooltip = {strset = {'mute keepah?','','(he is sad but','understands)'}}
            },
            options.gap,
            {
                str = 'mod reqs prompt',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeReqsPrompt',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("ReqsPrompt","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("ReqsPrompt",options.bool_map[var],true)
                end,

                tooltip = {strset = {'prompt you','the first run','each session','if you are','missing any','core mods?'}}
            },

            options.gap,
            --cotv timer
            {
                str = 'cotv timer',
                choices = options.bool_choices, setting = 2,
                variable = 'GodmodeCOTVDisplay',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("COTVDisplay","true")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("COTVDisplay",options.bool_map[var],true)
                end,

                tooltip = {strset = {'display a','timer to','indicate','how long','until cotv','spawns?'}}
            },
            {
                str = 'timer x',
                min = 0, max = 100, increment = 5, suf='% width', setting = 50,
                variable = 'GodmodeCOTVDisplayX',
                
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'cotv timer' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return math.floor(tonumber(GODMODE.save_manager.get_config("COTVDisplayX","0.5"))*100.0)
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("COTVDisplayX",var/100.0,true)
                    GODMODE.util.cotv_pos = nil
                end,

                changefunc = function(button, item, menuObj)
                    GODMODE.save_manager.set_config("COTVDisplayX",button.setting/100.0,false)
                    GODMODE.util.cotv_pos = nil
                end,

                tooltip = {strset = {'the x','position','of the','cotv timer','display'}}
            },
            {
                str = 'timer y',
                min = 0, max = 100, increment = 5, suf='% height', setting = 20,
                variable = 'GodmodeCOTVDisplayY',
                
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'cotv timer' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return math.floor(tonumber(GODMODE.save_manager.get_config("COTVDisplayY","0.5"))*100.0)
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("COTVDisplayY",var/100.0,true)
                    GODMODE.util.cotv_pos = nil
                end,

                changefunc = function(button, item, menuObj)
                    GODMODE.save_manager.set_config("COTVDisplayY",button.setting/100.0,false)
                    GODMODE.util.cotv_pos = nil
                end,


                tooltip = {strset = {'the y','position','of the','cotv timer','display'}}
            },

            options.gap,
            --fractal key chance
            {
                str = 'fractal chance',
                choices = options.fractal_display_choices, setting = 3,
                variable = 'GodmodeFractalDisplay',

                load = function()
                    return tonumber(GODMODE.save_manager.get_config("FractalDisplay","3")) or 3
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("FractalDisplay",var,true)
                end,
                changefunc = function(button, item, menuObj)
                    GODMODE.save_manager.set_config("FractalDisplay",""..button.setting,false)
                end,

                tooltip = {strset = {'display the','current chance','granted by','fractal key?'}}
            },
            {
                str = 'fractal x',
                min = 0, max = 100, increment = 5, suf='% width', setting = 50,
                variable = 'GodmodeFractalDisplayX',
                
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'fractal chance' and btn.setting ~= 2 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return math.floor(tonumber(GODMODE.save_manager.get_config("FractalDisplayX","0.5"))*100.0)
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("FractalDisplayX",var/100.0,true)
                end,

                changefunc = function(button, item, menuObj)
                    GODMODE.save_manager.set_config("FractalDisplayX",button.setting/100.0,false)
                end,

                tooltip = {strset = {'the x','position','of the','fractal chance','display'}}
            },
            {
                str = 'fractal y',
                min = 0, max = 100, increment = 5, suf='% height', setting = 20,
                variable = 'GodmodeFractalDisplayY',
                
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'fractal chance' and btn.setting ~= 2 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return math.floor(tonumber(GODMODE.save_manager.get_config("FractalDisplayY","0.5"))*100.0)
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("FractalDisplayY",var/100.0,true)
                end,

                changefunc = function(button, item, menuObj)
                    GODMODE.save_manager.set_config("FractalDisplayY",button.setting/100.0,false)
                end,


                tooltip = {strset = {'the y','position','of the','fractal chance','display'}}
            },

            options.gap,
            {
                str = 't. xaphan trail',
                min = 0, max = 50, increment = 1, suf=' shadows', setting = 6,
                variable = 'GodmodeTXaphanTrail',

                load = function()
                    return tonumber(GODMODE.save_manager.get_config("TXaphanTrail","6"))
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("TXaphanTrail",var,true)
                end,

                tooltip = {strset = {'the length','of t. xaphan\'s','shadow trail'}}
            },

            options.gap,
            {
                str = 'red juice shader',
                choices = options.red_juice_choices, setting = 1,
                variable = 'GodmodeRedJuiceSetting',

                load = function()
                    return tonumber(GODMODE.save_manager.get_config("RedJuiceSetting","1")) or 1
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("RedJuiceSetting",var,true)
                end,
                changefunc = function(button, item, menuObj)
                    GODMODE.save_manager.set_config("RedJuiceSetting",""..button.setting,false)
                end,

                tooltip = {strset = {'change shader','settings','for the','red juice?'}}
            },

            options.gap,
            options.back_option,
        }
    },
    controls = {
        title = "controls",
        buttons = {
            options.dssmod.gamepadToggleButton,
            options.dssmod.menuKeybindButton,
            options.dssmod.paletteButton,
            options.dssmod.menuHintButton,
            options.dssmod.menuBuzzerButton,
            {
                str = 'hud keybind',

                -- A keybind option lets you bind a key!
                keybind = true,
                -- -1 means no key set, otherwise use the Keyboard enum!
                setting = Keyboard.KEY_TAB,

                variable = "RedCoinCounterKey",

                load = function()
                    return tonumber(GODMODE.save_manager.get_config("RedCoinCounterKey",Keyboard.KEY_TAB)) or -1
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("RedCoinCounterKey",var,true)
                end,

                tooltip = {strset = {'keybind for','viewing godmode','hud above','players'}},
            },
            {
                str = 'tutorial skip',

                -- A keybind option lets you bind a key!
                keybind = true,
                -- -1 means no key set, otherwise use the Keyboard enum!
                setting = Keyboard.KEY_ENTER,

                variable = "RedCoinCounterKey",

                load = function()
                    return tonumber(GODMODE.save_manager.get_config("TutorialSkipKey",Keyboard.KEY_ENTER)) or -1
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("TutorialSkipKey",var,true)
                end,

                tooltip = {strset = {'keybind for','skipping to ', 'the next ','tutorial step'}},
            },

            options.gap,
            options.back_option,
        }
    },
    godmode = {
        title = "godmode",
        buttons = {
            {str = "yes, godmode.", dest="godmode2"},
            {str = 'back', dest="settings"},
        }
    },
    godmode2 = {
        title = "what'd you expect?",
        buttons = {
            {
                str = 'godmode',
                choices = options.bool_choices, setting = 1,
                variable = 'GodmodeToggle',

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_config("Godmode","false")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("Godmode",options.bool_map[var],true)
                end,

                tooltip = {strset = {'it\'s a mod','for pro','i love god','i love','godmode','its nice mode'}}
            },
            options.gap,
            {str = "back", dest="settings"},
        }
    },
    tutorials = {
        title = "godmode tutorials",
        buttons = {

        }
    },
    reset = {
        title = "reset data?",
        buttons = {
            {
                str = default_reset,

                -- If you want a button to do something unusual, you can have it call a function
                -- using the "func" tag! The function passes in "button", which is this button
                -- object, "item", which is the item object containing these buttons, and "menuObj",
                -- which is what you pass into AddMenu (contains DirectoryKey and Directory!)
                func = function(button, item, menuObj)
                    local next = next_reset[button.str] or nil 
                    
                    if next then 
                        button.str = next 

                        if next_reset[button.str] == nil then 
                            GODMODE.log("Resetting all Godmode data...", true)
                            GODMODE.save_manager.set_default_persistant_data(true, false)
                        end
                    end
                end,

                generate = function(button, item, tbl)
                    button.str = default_reset
                end,
                tooltip = { strset = { 'this will', 'reset all', 'godmode', 'progress' } }
            },
            {
                str= default_conf_reset,
                func = function(button)
                    local next = next_conf_reset[button.str] or nil 
                    
                    if next then 
                        button.str = next 

                        if next_conf_reset[button.str] == nil then 
                            GODMODE.log("Resetting Godmode config...", true)
                            GODMODE.save_manager.set_default_persistant_data(false, true)
                        end
                    end
                end,

                generate = function(button, item, tbl)
                    button.str = default_conf_reset
                end,

                tooltip = { strset = { 'this will', 'set godmode', 'config to', 'default', 'values' } }
            },
            options.gap,
            options.back_option,
        }
    },
    credits = include("godmode.scripts.definitions.credits").factory(options.back_button),
}

options.populate_options = function()
    -- populate unlocks view
    for key,val in pairs(GODMODE.achievements.item_map) do 
        local config = Isaac.GetItemConfig():GetCollectible(key)

        if config and config:IsCollectible() and not config.Hidden then
            local name = config.Name:lower()

            table.insert(options.layout.unlocks.buttons, {
                str = name,
                choices = options.unlock_choices, setting = options.str_bool_map[false],
                variable = 'GodmodeUnlock'..name,

                -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
                -- It passes in all the same args as "func"
                -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
                displayif = function(button, item, menuObj)
                    if item and item.buttons then
                        for _, btn in ipairs(item.buttons) do
                            if btn.str == 'global bypass' and btn.setting == 1 then
                                return false
                            end
                        end
                    end

                    return true
                end,

                load = function()
                    return options.str_bool_map[GODMODE.save_manager.get_persistant_data("Unlock."..val,"false")] or 2
                end,
                store = function(var)
                    GODMODE.save_manager.set_persistant_data("Unlock."..val,options.bool_map[var],true)
                end,

                tooltip = {strset = {'is',name,'unlocked?'}},
                unlock_but = true,
            })
            table.insert(options.layout.unlocks.buttons, options.gap)
        end
    end

    local non_item_unlocks = {{"chest infestors","ChestInfest","achievement_chest_infest"},{"sugar pills","SugarPills","achievement_sugar_pills"}}

    for _,data in ipairs(non_item_unlocks) do 
        table.insert(options.layout.unlocks.buttons, {
            str = data[1],
            choices = options.unlock_choices, setting = options.str_bool_map[GODMODE.save_manager.get_persistant_data("Unlock."..data[3],"false") == "true"],
            variable = 'GodmodeUnlock'..data[2],

            -- "displayif" allows you to dynamically hide or show a button. If you return true, it will display, and if you return false, it won't!
            -- It passes in all the same args as "func"
            -- In this example, this button will be hidden if the "slider option" button above is set to its maximum value.
            displayif = function(button, item, menuObj)
                if item and item.buttons then
                    for _, btn in ipairs(item.buttons) do
                        if btn.str == 'global bypass' and btn.setting == 1 then
                            return false
                        end
                    end
                end

                return true
            end,

            load = function()
                return options.str_bool_map[GODMODE.save_manager.get_persistant_data("Unlock."..data[3],"false")] or 2
            end,
            store = function(var)
                GODMODE.save_manager.set_persistant_data("Unlock."..data[3],options.bool_map[var],true)
            end,

            unlock_but = true,
            tooltip = {strset = {'is',data[1],'unlocked?'}}
        })
        table.insert(options.layout.unlocks.buttons, options.gap)
    end

    table.insert(options.layout.unlocks.buttons, 1, options.gap)
    table.insert(options.layout.unlocks.buttons, 1, options.gap)
    table.insert(options.layout.unlocks.buttons, 1, {
        str = 'global bypass',
        choices = options.bypass_choices, setting = 2,
        variable = 'GodmodeUnlocks',

        load = function()
            return options.str_bool_map[GODMODE.save_manager.get_config("Unlocks","true")] or 2
        end,
        store = function(var)
            GODMODE.save_manager.set_config("Unlocks",options.bool_map[var],true)
        end,

        unlock_but = true,
        tooltip = {strset = {'bypass','godmode','unlock','requirements,','unlocking','all secrets'}}
    })

    table.insert(options.layout.unlocks.buttons, options.back_option)
    
    table.insert(options.layout.tutorials.buttons, options.back_option)
    table.insert(options.layout.tutorials.buttons, options.gap)

    -- populate tutorial settings
    for key,dat in pairs(GODMODE.tutorials.list) do 
        if dat.unlock ~= true then 
            table.insert(options.layout.tutorials.buttons, {
                str = key:lower(),
                choices = options.tutorial_choices, setting = 1,
                variable = "Godmode"..key,

                load = function()
                    return tonumber(GODMODE.save_manager.get_config("Tutorial"..key,"1"))
                end,
                store = function(var)
                    GODMODE.save_manager.set_config("Tutorial"..key,var,true)
                end,
                tooltip = {strset = {'should the',key:lower(),"tutorial play",'once per file,','session, or','run?'}}
            })
            table.insert(options.layout.tutorials.buttons, options.gap)
        end
    end

    table.insert(options.layout.tutorials.buttons, options.gap)
    table.insert(options.layout.tutorials.buttons, options.back_option)

    options.layout_key = {
        Item = options.layout.main, -- This is the initial item of the menu, generally you want to set it to your main item
        Main = 'main', -- The main item of the menu is the item that gets opened first when opening your mod's menu.

        -- These are default state variables for the menu; they're important to have in here, but you don't need to change them at all.
        Idle = false,
        MaskAlpha = 1,
        Settings = {},
        SettingsChanged = false,
        Path = {},
    }


    DeadSeaScrollsMenu.AddMenu("Godmode Achieved", {
        -- The Run, Close, and Open functions define the core loop of your menu. Once your menu is
        -- opened, all the work is shifted off to your mod running these functions, so each mod can have
        -- its own independently functioning menu. The `init` function returns a table with defaults
        -- defined for each function, as "runMenu", "openMenu", and "closeMenu". Using these defaults
        -- will get you the same menu you see in Bertran and most other mods that use DSS. But, if you
        -- did want a completely custom menu, this would be the way to do it!

        -- This function runs every render frame while your menu is open, it handles everything!
        -- Drawing, inputs, etc.
        Run = options.dssmod.runMenu,
        -- This function runs when the menu is opened, and generally initializes the menu.
        Open = options.dssmod.openMenu,
        -- This function runs when the menu is closed, and generally handles storing of save data /
        -- general shut down.
        Close = options.dssmod.closeMenu,
        -- If UseSubMenu is set to true, when other mods with UseSubMenu set to false / nil are enabled,
        -- your menu will be hidden behind an "Other Mods" button.
        -- A good idea to use to help keep menus clean if you don't expect players to use your menu very
        -- often!
        UseSubMenu = false,
        Directory = options.layout,
        DirectoryKey = options.layout_key
    })
end


return options