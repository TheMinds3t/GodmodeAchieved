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
                    if item2 ~= Isaac.GetItemIdByName("Jack-of-all-Trades") then 
                        EID:assignTransformation("collectible", item2, item.eid_transform)
                    end
                end
            end
        end
    
    
        EID:addCollectible(Isaac.GetItemIdByName("Jack-of-all-Trades"), "Counts as one item towards all transformations")
        EID:addCollectible(Isaac.GetItemIdByName("Rock Fragment"), "Part 1 of 4, allows access to the Gatekeeper in Sheol#!!!!!!!!!NOTE!!!!!!!!! NOT CURRENTLY IMPLEMENTED!")
        EID:addCollectible(Isaac.GetItemIdByName("Holy Stone"), "Part 2 of 4, allows access to the Gatekeeper in Sheol#!!!!!!!!!NOTE!!!!!!!!! NOT CURRENTLY IMPLEMENTED!")
        EID:addCollectible(Isaac.GetItemIdByName("Tablet Fragment"), "Part 3 of 4, allows access to the Gatekeeper in Sheol#!!!!!!!!!NOTE!!!!!!!!! NOT CURRENTLY IMPLEMENTED!")
        EID:addCollectible(Isaac.GetItemIdByName("Final Slate"), "Part 4 of 4, allows access to the Gatekeeper in Sheol#!!!!!!!!!NOTE!!!!!!!!! NOT CURRENTLY IMPLEMENTED!")
        EID:addCollectible(Isaac.GetItemIdByName("Blood Key"), "Allows you to enter the Ivory Palace in Sheol")
        EID:assignTransformation("collectible", Isaac.GetItemIdByName("Jack-of-all-Trades"), GODMODE.util.eid_transforms.JACK_OF_ALL_TRADES)
        EID:addCollectible(Isaac.GetItemIdByName("Brass Cross"), "↑ +2 Soul Hearts#↑ +25% chance to encounter a blessed floor")
        EID:addCollectible(CollectibleType.COLLECTIBLE_MORE_OPTIONS, "↑ Treasure rooms have more items# Each item is sequentially assigned a group, 1 to (1+More Options Quantity), indicated on the item pedestal# You can only pick one item from each group")    
    end

    if EID.addBirthright then
        for name,player in pairs(GODMODE.players) do
            if player.eid_birthright then
                EID:addBirthright(Isaac.GetPlayerTypeByName(name,player.tainted == true),player.eid_birthright,name)
            end
        end

        GODMODE.log("Loaded Godmode External Items Description Integration!")
    end
end

-- ENCYCLOPEDIA SUPPORT
if Encyclopedia then 
    -- Encyclopedia.HideItem(Isaac.GetItemIdByName("Morphine Used"))
    for _,item in ipairs(GODMODE.items) do
        if item.encyc_entry then
            if item.trinket then
                EID:addTrinket(item.instance, item.eid_description)

                if item.eid_transforms ~= nil then 
                    EID:assignTransformation("trinket", item.instance, ""..item.eid_transforms)
                end
            else
                Encyclopedia.AddItem({
                    Class = "Godmode Achieved",
                    ID = item.instance,
                    WikiDesc = item.encyc_entry,
                    ModName = "Godmode Achieved",
                },"items")
            end
        end
    end

    Encyclopedia.AddItem({
        Class = "Godmode Achieved",
        ID = Isaac.GetItemIdByName("Morphine Used"),
        ModName = "Godmode Achieved",
        Hide = true,
    },"items")

    Encyclopedia.AddItem({
        Class = "Godmode Achieved",
        ID = Isaac.GetItemIdByName("Jack-of-all-Trades"),
        ModName = "Godmode Achieved",
        WikiDesc = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Grants an entry to every base transformation as well as Godmode transformation."},
            },
        }
    },"items")
    Encyclopedia.AddItem({
        Class = "Godmode Achieved",
        ID = Isaac.GetItemIdByName("Brass Cross"),
        ModName = "Godmode Achieved",
        WikiDesc = {
            { -- Effects
                {str = "Effects", fsize = 2, clr = 3, halign = 0},
                {str = "Grants +2 soul hearts, and the chance to encounter a floor blessing is increased by 25%."},
            },
        }
    },"items")
    Encyclopedia.AddItem({
        Class = "Godmode Achieved",
        ID = Isaac.GetItemIdByName("Blood Key"),
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

-- MOD CONFIG MENU SUPPORT 
if not ModConfigMenu and GODMODE.save_manager.get_config("ReqsPrompt", "true") == "true" then
    GODMODE.achievements.play_splash("modconfigmenu_request", 0.6)
elseif ModConfigMenu then
    local godmode_cat = "Godmode Achieved"
    GODMODE.mcm_reset = 5

    ModConfigMenu.RemoveCategory(godmode_cat)
    ModConfigMenu.UpdateCategory(godmode_cat, {
        Info = "Overhaul mod that adds and modifies content to create a higher risk, higher reward playstyle",
    })

    local bool_read = {
        ["true"]="Enabled",
        ["false"]="Disabled",
        ["nil"]="ERROR"
    }

    local mcm_reset_titles = {
        [5] = "Chances: 5",
        [4] = "Chances: 4",
        [3] = "Chances: 3",
        [2] = "Chances: 2",
        [1] = "LAST CHANCE!!!",
        [0] = "Data was wiped.."
    } 

    ModConfigMenu.AddSetting(godmode_cat, "Alts", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return math.floor(tonumber(GODMODE.save_manager.get_config("GodmodeStageChance", "0.25")) * 100) end,

        Minimum = 0,
        Maximum = 100,

        Display = function() return "Godmode Stage Chance: " .. (tonumber(GODMODE.save_manager.get_config("GodmodeStageChance", "0.25"))*100) .."%" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("GodmodeStageChance",val/100)
        end,

        Info = {"This specifies the chance that Godmode Stages will override base game stages when applicable. Defaults to 25%."}
    })
    ModConfigMenu.AddSpace(godmode_cat,"Alts")
    ModConfigMenu.AddSetting(godmode_cat, "Alts", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("BossesEnabled", "true") == "true" end,
        Display = function() return "Alternate Bosses: " .. bool_read[tostring(GODMODE.save_manager.get_config("BossesEnabled", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("BossesEnabled",tostring(val) == "true")
        end,

        Info = {"If enabled, Godmode will naturally replace vanilla bosses with Godmode bosses. If false, Godmode bosses will not be spawned (Aside from the new final boss)."}
    })
    ModConfigMenu.AddSetting(godmode_cat, "Alts", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return tonumber(GODMODE.save_manager.get_config("MajorBossPercent", "0.5")) * 10 end,

        Minimum = 0,
        Maximum = 100,

        Display = function() return "Godmode End-Boss Chance: " .. (tonumber(GODMODE.save_manager.get_config("MajorBossPercent", "0.5"))*100) .."%" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("MajorBossPercent",val/10)
            ModConfigMenu.AddSpace(godmode_cat,"Alts")
            ModConfigMenu.AddText(godmode_cat,"Please reload the mod")
        end,

        Info = {"This specifies a weight modifier for endgame Godmode bosses to appear. Defaults to 100%. MUST RESTART FOR CHANGES TO BE REFLECTED."}
    })
    ModConfigMenu.AddSetting(godmode_cat, "Alts", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return tonumber(GODMODE.save_manager.get_config("MinorBossPercent", "1.0")) * 10 end,

        Minimum = 0,
        Maximum = 100,

        Display = function() return "Godmode Boss Chance: " .. (tonumber(GODMODE.save_manager.get_config("MinorBossPercent", "1.0"))*100) .."%" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("MinorBossPercent",val/10)
            GODMODE.add_base_bosses()
        end,

        Info = {"This specifies a weight modifier for regular Godmode bosses to appear. Defaults to 100%. MUST RESTART FOR CHANGES TO BE REFLECTED."}
    })
    ModConfigMenu.AddSpace(godmode_cat,"Alts")

    ModConfigMenu.AddSetting(godmode_cat, "Alts", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("EnemyAlts", "true") == "true" end,
        Display = function() return "Alternate Enemies: " .. bool_read[tostring(GODMODE.save_manager.get_config("EnemyAlts", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("EnemyAlts",tostring(val) == "true")
        end,

        Info = {"If enabled, Godmode will naturally replace vanilla enemies with Godmode enemies. If false, they will only show in their designated rooms."}
    })
    ModConfigMenu.AddSetting(godmode_cat, "Alts", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return tonumber(GODMODE.save_manager.get_config("EnemyModifier", "1.0")) * 10 end,

        Minimum = 0,
        Maximum = 100,

        Display = function() return "Enemy Alt Weight: " .. (tonumber(GODMODE.save_manager.get_config("EnemyModifier", "1.0"))*100) .."%" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("EnemyModifier",val/10)
        end,

        Info = {"This specifies a weight modifier for Godmode enemies to replace regular ones. The higher the weight, the more likely they will appear. Defaults to 100%"}
    })
    ModConfigMenu.AddSetting(godmode_cat, "Alts", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return tonumber(GODMODE.save_manager.get_config("EnemyCapModifier", "0")) end,

        Minimum = 0,
        Maximum = 20,

        Display = function() return "Enemy Cap Addition: +" .. (tonumber(GODMODE.save_manager.get_config("EnemyCapModifier", "0"))) .."" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("EnemyCapModifier",val)
        end,

        Info = {"This specifies an override to allow more Godmode enemy alts to be rolled. Each entry has a cap, this is added to that cap. Defaults to 0"}
    })
    ModConfigMenu.AddSpace(godmode_cat,"Alts")
    ModConfigMenu.AddSetting(godmode_cat, "Alts", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("PickupAlts", "true") == "true" end,
        Display = function() return "Alternate Pickups: " .. bool_read[tostring(GODMODE.save_manager.get_config("PickupAlts", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("PickupAlts",tostring(val) == "true")
        end,

        Info = {"If enabled, Godmode will naturally replace vanilla pickups with Godmode pickups. If false, they will only show in their designated rooms."}
    })
    ModConfigMenu.AddSetting(godmode_cat, "Alts", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return tonumber(GODMODE.save_manager.get_config("PickupModifier", "1.0")) * 10 end,

        Minimum = 0,
        Maximum = 100,

        Display = function() return "Pickup Alt Weight: " .. (tonumber(GODMODE.save_manager.get_config("PickupModifier", "1.0"))*100) .."%" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("PickupModifier",val/10)
        end,

        Info = {"This specifies a weight modifier for Godmode pickups to replace regular ones. The higher the weight, the more likely they will appear. Defaults to 100%"}
    })
    ModConfigMenu.AddSetting(godmode_cat, "Alts", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return tonumber(GODMODE.save_manager.get_config("PickupCapModifier", "0")) end,

        Minimum = 0,
        Maximum = 20,

        Display = function() return "Pickup Cap Addition: +" .. (tonumber(GODMODE.save_manager.get_config("PickupCapModifier", "0"))) .."" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("PickupCapModifier",val)
        end,

        Info = {"This specifies an override to allow more Godmode pickup alts to be rolled. Each entry has a cap, this is added to that cap. Defaults to 0"}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Alts", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return tonumber(GODMODE.save_manager.get_config("AltHorsemanChance", "0.2")) * 10 end,

        Minimum = 0,
        Maximum = 100,

        Display = function() return "Horseman Champion Chance: " .. (tonumber(GODMODE.save_manager.get_config("AltHorsemanChance", "0.2"))*100) .."%" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("AltHorsemanChance",val/10)
        end,

        Info = {"This specifies the chance for Godmode Harbinger champions to be selected when a horseman spawns. The higher the percent, the more likely they will appear. Defaults to 20%"}
    })


    ModConfigMenu.AddSetting(godmode_cat, "Scaling", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("HMEnabled", "true") == "true" end,
        Display = function() return "Hardmode Scaling: " .. bool_read[GODMODE.save_manager.get_config("HMEnabled", "true")] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("HMEnabled",tostring(val) == "true")
        end,

        Info = {"If true, Godmode will scale enemy health depending on the level in Hardmode. Think Gungeon."}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Scaling", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return GODMODE.save_manager.get_config("HMEScale", 2.0) * 10 end,

        Minimum = 10,
        Maximum = 50,

        Display = function() return "Hardmode Enemy Max HP Scale: " .. (GODMODE.save_manager.get_config("HMEScale", 2.0)*100) .."%" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("HMEScale",val/10)
        end,

        Info = {"Specifies the maximum scaled hp for enemies in the last stages. Defaults to 200%"}
    })
    ModConfigMenu.AddSetting(godmode_cat, "Scaling", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return GODMODE.save_manager.get_config("HMBScale", 2.3) * 10 end,

        Minimum = 10,
        Maximum = 50,

        Display = function() return "Hardmode Boss Max HP Scale: " .. (GODMODE.save_manager.get_config("HMBScale", 2.3)*100) .."%" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("HMBScale",val/10)
        end,

        Info = {"Specifies the maximum scaled hp for bosses in the last stages. Defaults to 230%"}
    })
    ModConfigMenu.AddSpace(godmode_cat,"Scaling")
    ModConfigMenu.AddSetting(godmode_cat, "Scaling", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("GMEnabled", "true") == "true" end,
        Display = function() return "Greedier Mode Scaling: " .. bool_read[tostring(GODMODE.save_manager.get_config("GMEnabled", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("GMEnabled",tostring(val) == "true")
        end,


        Info = {"If true, Godmode will scale enemy health depending on the level in Greedier mode. Think Gungeon."}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Scaling", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return GODMODE.save_manager.get_config("GMEScale", 1.5) * 10 end,

        Minimum = 10,
        Maximum = 50,

        Display = function() return "Greedier Enemy Max HP Scale: " .. (GODMODE.save_manager.get_config("GMEScale", 1.5)*100) .."%" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("GMEScale",val/10)
        end,

        Info = {"Specifies the maximum scaled hp for enemies in the last stages of Greedier mode. Defaults to 150%"}
    })
    ModConfigMenu.AddSetting(godmode_cat, "Scaling", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return GODMODE.save_manager.get_config("GMBScale", 1.8) * 10 end,

        Minimum = 10,
        Maximum = 50,

        Display = function() return "Greedier Boss Max HP Scale: " .. (GODMODE.save_manager.get_config("GMBScale", 1.8)*100) .."%" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("GMBScale",val/10)
        end,

        Info = {"Specifies the maximum scaled hp for bosses in the last stages of Greedier mode. Defaults to 180%"}
    })
    ModConfigMenu.AddSpace(godmode_cat,"Scaling")
    ModConfigMenu.AddSetting(godmode_cat, "Scaling", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("VLapEnabled", "true") == "true" end,
        Display = function() return "Victory Lap Scaling: " .. bool_read[tostring(GODMODE.save_manager.get_config("VLapEnabled", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("VLapEnabled",tostring(val) == "true")
        end,

        Info = {"If enabled, Godmode will naturally scale health for enemies further on each victory lap. If false, regular scaling will be applied."}
    })
    ModConfigMenu.AddSetting(godmode_cat, "Scaling", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return tonumber(GODMODE.save_manager.get_config("ScaleSelectorMax", "3000")) / 50 end,

        Minimum = 1,
        Maximum = 200,

        Display = function() return "Scaling Cap: " .. (GODMODE.save_manager.get_config("ScaleSelectorMax", 3000)) end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("ScaleSelectorMax",val*50)
        end,

        Info = {"If an enemy or boss has health greater than or equal to this value, Godmode does not scale its HP. Defaults to 3000"}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Gameplay", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("MultiPlanetItems", "true") == "true" end,
        Display = function() return "Multiple Planetarium Items: " .. bool_read[tostring(GODMODE.save_manager.get_config("MultiPlanetItems", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("MultiPlanetItems",tostring(val) == "true")
        end,


        Info = {"If enabled, Godmode will enable multiple items to be taken from planetariums."}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Gameplay", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("BothRepPathItems", "true") == "true" end,
        Display = function() return "Both Alt Path Items: " .. bool_read[tostring(GODMODE.save_manager.get_config("BothRepPathItems", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("BothRepPathItems",tostring(val) == "true")
        end,


        Info = {"If enabled, you will be able to take both items on alt path."}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Gameplay", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("TaintedLostWish", "true") == "true" end,
        Display = function() return "Tainted Lost has Mom's Wish: " .. bool_read[tostring(GODMODE.save_manager.get_config("TaintedLostWish", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("TaintedLostWish",tostring(val) == "true")
        end,


        Info = {"If enabled, Godmode will add Mom's Wish to the start of Tainted Lost."}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Gameplay", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return tonumber(GODMODE.save_manager.get_config("BRTimeMins", "20")) end,

        Minimum = 10,
        Maximum = 60,

        Display = function() return "Boss Rush Time Max: " .. (GODMODE.save_manager.get_config("BRTimeMins", 20)) .. " minutes" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("BRTimeMins",val)
            Game().BossRushParTime = tonumber(GODMODE.save_manager.get_config("BRTimeMins","20"))*60*30
        end,

        Info = {"This modifies the time you need to beat Mom by to see the entrance to the boss rush. Defaults to 20"}
    })
    ModConfigMenu.AddSetting(godmode_cat, "Gameplay", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return tonumber(GODMODE.save_manager.get_config("HushTimeMins", "35")) end,

        Minimum = 10,
        Maximum = 60,

        Display = function() return "Blue Womb Time Max: " .. (GODMODE.save_manager.get_config("HushTimeMins", 35)) .. " minutes" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("HushTimeMins",val)
            Game().BlueWombParTime = tonumber(GODMODE.save_manager.get_config("HushTimeMins","35"))*60*30

        end,

        Info = {"This modifies the time you need to beat Mom's Heart/It Lives by to see the entrance to the blue womb. Defaults to 35"}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Gameplay", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("BlueWombRework", "true") == "true" end,
        Display = function() return "Blue Womb Rework: " .. bool_read[tostring(GODMODE.save_manager.get_config("BlueWombRework", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("BlueWombRework",tostring(val) == "true")
        end,


        Info = {"If enabled, Godmode will remove chests from the Blue Womb and add a Pile of Keys (8) instead."}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Gameplay", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("CallOfTheVoid", "true") == "true" end,
        Display = function() return "Call of the Void: " .. bool_read[tostring(GODMODE.save_manager.get_config("CallOfTheVoid", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("CallOfTheVoid",tostring(val) == "true")
        end,


        Info = {"If enabled, in hardmode Godmode will summon a stage hazard if you take too much time on a stage. High risk, high reward"}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Gameplay", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return (tonumber(GODMODE.save_manager.get_config("VoidEnterTime", tostring(30*60*5+5)))-5)/30/30 end,

        Minimum = 0,
        Maximum = 60,

        Display = function() return "Call of the Void Spawn Time: " .. (tonumber(GODMODE.save_manager.get_config("VoidEnterTime", tostring(30*60*5+5)))-5) / 30 / 60 .. " minutes" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("VoidEnterTime",val*30*30+5)
        end,

        Info = {"If Call of the Void is enabled, specifies how long to spend on a stage before it spawns."}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Gameplay", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return GODMODE.save_manager.get_config("DoorHazardChanceMod", 1.0) * 10 end,

        Minimum = 0,
        Maximum = 100,

        Display = function() return "Door Hazard Chance: " .. (GODMODE.save_manager.get_config("DoorHazardChanceMod", 1.0)*10) .."%" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("DoorHazardChanceMod",val/10)
        end,

        Info = {"The chance for other doors to have a hazard generated on entering a room. Defaults to 10.0%"}
    })
    
    ModConfigMenu.AddSetting(godmode_cat, "Gameplay", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("COTVDoorHazardFX", "true") == "true" end,
        Display = function() return "COTV Door Hazard Effect: " .. bool_read[tostring(GODMODE.save_manager.get_config("COTVDoorHazardFX", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("COTVDoorHazardFX",tostring(val) == "true")
        end,


        Info = {"If enabled, once COTV has spawned there is an additional chance to spawn more door hazards that strengthen/summon COTV as you traverse both cleared and uncleared rooms."}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Gameplay", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("Unlocks", "true") == "true" end,
        Display = function() return "Godmode Unlocks: " .. bool_read[tostring(GODMODE.save_manager.get_config("Unlocks", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("Unlocks",tostring(val) == "true")
        end,


        Info = {"If set to enabled, some of Godmode's items will be locked before its unlock condition is met."}
    })

    
    ModConfigMenu.AddSetting(godmode_cat, "Cosmetic", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("VoidOverlay", "true") == "true" end,
        Display = function() return "Void Overlay: " .. bool_read[tostring(GODMODE.save_manager.get_config("VoidOverlay", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("VoidOverlay",tostring(val) == "true")
        end,


        Info = {"If enabled, Godmode will render a visual overlay in the void."}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Cosmetic", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("ShopParrot", "true") == "true" end,
        Display = function() return "Spawn a lovable bird in shops: " .. bool_read[tostring(GODMODE.save_manager.get_config("ShopParrot", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("ShopParrot",tostring(val) == "true")
        end,


        Info = {"If enabled, Godmode will add a cosmetic friend in shops. Kind of a nod to previous versions of Godmode, mostly fun!"}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Cosmetic", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("ReqsPrompt", "true") == "true" end,
        Display = function() return "Mod Requirements Prompt: " .. bool_read[tostring(GODMODE.save_manager.get_config("ReqsPrompt", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("ReqsPrompt",tostring(val) == "true")
        end,


        Info = {"If enabled, Godmode will notify you of any missing requirements for content, such as StageAPI, at the start of the run."}
    })
    ModConfigMenu.AddSetting(godmode_cat, "Cosmetic", {

        Type = ModConfigMenu.OptionType.BOOLEAN,

        CurrentSetting = function() return GODMODE.save_manager.get_config("COTVDisplay", "true") == "true" end,
        Display = function() return "COTV Timer: " .. bool_read[tostring(GODMODE.save_manager.get_config("COTVDisplay", "true"))] end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("COTVDisplay",tostring(val) == "true")
        end,


        Info = {"If enabled, Godmode shows how much time you have remaining until CotV spawns and when the timer is counting down. Enabled by default."}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Cosmetic", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return GODMODE.save_manager.get_config("COTVDisplayX", 0.5) * 20 end,

        Minimum = 0,
        Maximum = 20,

        Display = function() return "COTV Timer X: " .. (GODMODE.save_manager.get_config("COTVDisplayX", 0.5)*100) .."%" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("COTVDisplayX",val/20)
            GODMODE.util.cotv_pos = nil
        end,

        Info = {"The horizontal position of the Call of the Void indicator. Defaults to 50%."}
    })
    ModConfigMenu.AddSetting(godmode_cat, "Cosmetic", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return GODMODE.save_manager.get_config("COTVDisplayY", 0.2) * 20 end,

        Minimum = 0,
        Maximum = 20,

        Display = function() return "COTV Timer Y: " .. (GODMODE.save_manager.get_config("COTVDisplayY", 0.2)*100) .."%" end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("COTVDisplayY",val/20)
            GODMODE.util.cotv_pos = nil
        end,

        Info = {"The vertical position of the Call of the Void indicator. Defaults to 10%."}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Controls", {

        Type = ModConfigMenu.OptionType.KEYBIND_KEYBOARD,

        CurrentSetting = function() return tonumber(GODMODE.save_manager.get_config("RedCoinCounterKey", Keyboard.KEY_TAB)) end,
        Display = function() return "Red Coin Keybind: " .. GODMODE.save_manager.get_config("RedCoinCounterKey", Keyboard.KEY_TAB)  end,
        Display = function() return "Red Coin Keybind: " .. InputHelper.KeyboardToString[tonumber(GODMODE.save_manager.get_config("RedCoinCounterKey", ""..Keyboard.KEY_TAB))]  end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("RedCoinCounterKey",tostring(val))
        end,


        Info = {"Set the keybind to view how many red coins players have."}
    })

    ModConfigMenu.AddSetting(godmode_cat, "Controls", {

        Type = ModConfigMenu.OptionType.KEYBIND_CONTROLLER,

        CurrentSetting = function() return tonumber(GODMODE.save_manager.get_config("RedCoinCounterButton", ""..ButtonAction.ACTION_MAP)) end,
        Display = function() return "Red Coin Controller bind: " .. InputHelper.ControllerToString[tonumber(GODMODE.save_manager.get_config("RedCoinCounterButton", ""..ButtonAction.ACTION_MAP))]  end,

        OnChange = function(val)
            GODMODE.save_manager.set_config("RedCoinCounterButton",tostring(val))
        end,


        Info = {"Set the controller bind to view how many red coins players have."}
    })



    ModConfigMenu.AddSetting(godmode_cat, "Reset", {

        Type = ModConfigMenu.OptionType.NUMBER,

        CurrentSetting = function() return GODMODE.mcm_reset end,

        Minimum = 0,
        Maximum = 5,

        Display = function() return "Wipe Godmode Data? " .. mcm_reset_titles[GODMODE.mcm_reset] end,

        OnChange = function(val)
            GODMODE.mcm_reset = GODMODE.mcm_reset - 1

            if GODMODE.mcm_reset == 0 then 
                GODMODE.log("Resetting all Godmode data...", true)
                GODMODE.save_manager.set_default_persistant_data(true, true)
            end
        end,

        Info = {"Wipes all Godmode data if chances are emptied. USE WITH CAUTION, IRREVERSABLE"}
    })

    GODMODE.log("Loaded Godmode ModConfigMenu Integration!")
end

-- ENHANCED BOSS BARS

if HPBars then -- check if the mod is installed
    local bar_path = "gfx/ui/boss/bar_icons/"
    HPBars.Conditions["isSubtype"] = function(entity,args) return entity.SubType == args[1] end 
	HPBars.BossDefinitions[Isaac.GetEntityTypeByName("Souleater").."."..Isaac.GetEntityVariantByName("Souleater")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."souleater.png", -- path to the .png file that will be used as the icon for this boss
		conditionalSprites = {
			{"isHPSmallerPercent", bar_path.."souleater2.png", {40}}
		},
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
	HPBars.BossDefinitions[Isaac.GetEntityTypeByName("The Ritual").."."..Isaac.GetEntityVariantByName("The Ritual")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."ritual_0.png", -- path to the .png file that will be used as the icon for this boss
		conditionalSprites = {
			{"isHPSmallerPercent", bar_path.."ritual_3.png", {25}},
			{"isHPSmallerPercent", bar_path.."ritual_2.png", {50}},
			{"isHPSmallerPercent", bar_path.."ritual_1.png", {75}},
		},
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
	HPBars.BossDefinitions[Isaac.GetEntityTypeByName("The Grand Marshall").."."..Isaac.GetEntityVariantByName("The Grand Marshall")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."grand_marshal.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
	HPBars.BossDefinitions[Isaac.GetEntityTypeByName("Bowl Play (Corny)").."."..Isaac.GetEntityVariantByName("Bowl Play (Corny)")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."bowl_play_corny.png", -- path to the .png file that will be used as the icon for this boss
        conditionalSprites = {
			{"isSubtype", bar_path.."bowl_play_smiley.png", {1}},
		},
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("The Sacred Mind").."."..Isaac.GetEntityVariantByName("The Sacred Mind")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."sacred_mind.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("The Sacred Body").."."..Isaac.GetEntityVariantByName("The Sacred Body")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."sacred_body.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("The Sacred Soul").."."..Isaac.GetEntityVariantByName("The Sacred Soul")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."sacred_soul.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("The Fallen Light").."."..Isaac.GetEntityVariantByName("The Fallen Light")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
        sprite = bar_path.."fl_0.png", -- path to the .png file that will be used as the icon for this boss
        conditionalSprites = {
            {"isHPSmallerPercent", bar_path.."fl_2.png", {44.4}},
            {"isHPSmallerPercent", bar_path.."fl_1.png", {66.6}},
        },
        offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
    }
    HPBars.BossIgnoreList[Isaac.GetEntityTypeByName("The Fallen Light").."."..Isaac.GetEntityVariantByName("The Fallen Light")] = function(entity) 
		return GODMODE.get_ent_data(entity) ~= nil and GODMODE.get_ent_data(entity).soul_made == true
	end
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("The Sign").."."..Isaac.GetEntityVariantByName("The Sign")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
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
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("Mega Worm").."."..Isaac.GetEntityVariantByName("Mega Worm")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."megaworm.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("Blightfly").."."..Isaac.GetEntityVariantByName("Blightfly")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."blight_fly.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("Bubbly Plum").."."..Isaac.GetEntityVariantByName("Bubbly Plum")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."bubbly_plum.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("Bathemo Swarm").."."..Isaac.GetEntityVariantByName("Bathemo Swarm")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."bathemo_swarm.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("Bathemo").."."..Isaac.GetEntityVariantByName("Bathemo")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."bathemo.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("Ludomaw").."."..Isaac.GetEntityVariantByName("Ludomaw")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."ludomaw.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("(GODMODE) Famine").."."..Isaac.GetEntityVariantByName("(GODMODE) Famine")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."famine.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("(GODMODE) War").."."..Isaac.GetEntityVariantByName("(GODMODE) War")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."war.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    
    if HPBars.BossDefinitions["65.10"].conditionalSprites ~= nil then 
        table.insert(HPBars.BossDefinitions["65.10"].conditionalSprites, {"isSubtype", bar_path.."war_phase2.png", {700}})
    else
        HPBars.BossDefinitions["65.10"].conditionalSprites = {{"isSubtype", bar_path.."war_phase2.png", {700}}}
    end

    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("Hostess").."."..Isaac.GetEntityVariantByName("Hostess")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."hostess.png", -- path to the .png file that will be used as the icon for this boss
        conditionalSprites = {
            {"animationNameContains", bar_path.."hostess_2.png", {"2"}},
            {"animationNameEqual", bar_path.."hostess_2.png", {"Phase"}},
            {"animationNameContains", bar_path.."hostess_3.png", {"3"}},
        },
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("Hostess Cluster").."."..Isaac.GetEntityVariantByName("Hostess Cluster")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."hostess_tendril.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("Furnace Knight").."."..Isaac.GetEntityVariantByName("Furnace Knight")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."furnace_guard.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("Bloody Uriel").."."..Isaac.GetEntityVariantByName("Bloody Uriel")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."bloody_uriel.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
    HPBars.BossDefinitions[Isaac.GetEntityTypeByName("Bloody Gabriel").."."..Isaac.GetEntityVariantByName("Bloody Gabriel")] = { -- the table BossDefinitions is used to define boss specific content. Entries are defined with "Type.Variant" of the boss
		sprite = bar_path.."bloody_gabriel.png", -- path to the .png file that will be used as the icon for this boss
		offset = Vector(-5, 0) -- number of pixels the icon should be moved from its center versus the left-side of the bar
	}
end


-- STAGEAPI 

if not StageAPI and GODMODE.save_manager.get_config("ReqsPrompt", "true") == "true" then
    GODMODE.achievements.play_splash("stageapi_request", 0.6)
elseif StageAPI ~= nil then
    GODMODE.stage_progression = {}
    GODMODE.stages = {}
    StageAPI.UnregisterCallbacks(GODMODE.mod_id)


    function create_stage(stage_file)
        local stage_file = include("scripts.definitions.stages."..stage_file)

        if not StageAPI.CustomStages[stage_file.api_id] then
            if stage_file.second ~= nil then
                local stage = GODMODE.stages[stage_file.second].stage(stage_file.second,stage_file.override_stage)
                stage.DisplayName = stage_file.display_name
                stage_file.stage = stage
                GODMODE.stages[stage_file.api_id] = stage_file            
            else
                local stage = StageAPI.CustomStage(stage_file.api_id,stage_file.override_stage)
                stage_file.backdrop_copy = {GODMODE.util.deep_copy(stage_file.graphics.backdrop_gfx),GODMODE.util.deep_copy(stage_file.graphics.backdrop_prefix),GODMODE.util.deep_copy(stage_file.graphics.backdrop_suffix)}
                local floor_room = StageAPI.BackdropHelper(stage_file.backdrop_copy[1], stage_file.backdrop_copy[2], stage_file.backdrop_copy[3])
                stage:SetName(stage_file.api_id)
                stage.DisplayName = stage_file.display_name

                if stage.simulating_stage then 
                    GODMODE.save_manager.set_data("StageReseed"..stage.simulating_stage,"false",true)
                end
                
                stage:SetMusic(Isaac.GetMusicIdByName(stage_file.music or "Basement"), stage_file.music_rooms or {RoomType.ROOM_DEFAULT,RoomType.ROOM_TREASURE,RoomType.ROOM_CHALLENGE,RoomType.ROOM_SACRIFICE,RoomType.ROOM_CURSE,RoomType.ROOM_DUNGEON,RoomType.ROOM_ERROR,RoomType.ROOM_ISAACS,RoomType.ROOM_BARREN,RoomType.ROOM_CHEST,RoomType.ROOM_DICE,RoomType.ROOM_BLACK_MARKET})
                if stage_file.boss_music ~= nil then
                    local over = Music.MUSIC_BOSS_OVER
                    if stage_file.boss_music_over ~= nil then
                        over = Isaac.GetMusicIdByName(stage_file.boss_music_over)
                    end
            
                    stage:SetBossMusic(Isaac.GetMusicIdByName(stage_file.boss_music), over)
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
            
                stage:SetRoomGfx(StageAPI.RoomGfx(floor_room, room_grid, "_default", stage_file.graphics.shading), {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BOSS})
                stage:SetSpots(stage_file.graphics.player_spot, stage_file.graphics.boss_spot)    
                stage.GenerateLevel = StageAPI.GenerateBaseLevel
                -- stage:SetReplace(stage_file:override(stage))

                -- local boss_rooms = assert(include(stage_file.boss_room_path), "[GODMODE_ACHIEVED] AN ERROR OCCURRED WHILE ATTEMPTING TO LOAD BOSS ROOMS FOR \'"..stage_file.api_id.."\' at \'"..stage_file.boss_room_path.."\'")
            
                if stage_file.rooms ~= nil then
                    for i=1,#stage_file.rooms do
                        local room_set = assert(include(stage_file.rooms[i].path),"[GODMODE_ACHIEVED] AN ERROR OCCURRED WHILE ATTEMPTING TO LOAD STAGE ROOMS FOR \'"..stage_file.api_id.."\' at \'"..stage_file.rooms[i].path.."\'")
                        stage:SetRooms(StageAPI.RoomsList(stage_file.api_id.."_"..stage_file.rooms[i].id, room_set), stage_file.rooms[i].type)
                    end
                else
                    local regular_rooms = assert(include(stage_file.room_path),"[GODMODE_ACHIEVED] AN ERROR OCCURRED WHILE ATTEMPTING TO LOAD STAGE ROOMS FOR \'"..stage_file.api_id.."\' at \'"..stage_file.room_path.."\'")
                    stage:SetRooms(StageAPI.RoomsList(stage_file.api_id.."_General", regular_rooms), RoomType.ROOM_DEFAULT)
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
            if stage_file.next ~= nil and GODMODE.stage_progression ~= nil then
                GODMODE.stage_progression[stage_file.api_id]= true
            end
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
                    Game():GetRoom():EmitBloodFromWalls(5,10)
                    --Isaac.Spawn(Isaac.GetEntityTypeByName("Ivory Portal"), Isaac.GetEntityVariantByName("Ivory Portal"), 0, Isaac.GetPlayer(0).Position, Vector(0,0), nil)) 
                end

                Game():ShakeScreen(10)
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

    StageAPI.AddCallback(GODMODE.mod_id, "PRE_SELECT_NEXT_STAGE", 2, function(currentStage)
        if currentStage ~= nil then
            for _,stage in pairs(GODMODE.stages) do
                if stage.next and stage.api_id == currentStage.Name then                     
                    GODMODE.save_manager.set_data("StageReseed"..Game():GetLevel():GetStage(),"true",true)

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

    GODMODE.try_switch_stage = function()
        if GODMODE.first_level_load ~= true then GODMODE.first_level_load = true return end
        local level = Game():GetLevel()
        if not level:IsAscent() and Game().Difficulty < Difficulty.DIFFICULTY_GREED and Game():GetLevel():GetStageType() <= StageType.STAGETYPE_AFTERBIRTH then  
            for _,stage in pairs(GODMODE.stages) do
                if stage.try_switch then 
                    local allowed = stage:try_switch()
                    if allowed and GODMODE.util.random() < tonumber(GODMODE.save_manager.get_config("GodmodeStageChance","0.25")) and not GODMODE.is_at_palace() then 
                        -- Isaac.ExecuteCommand("cstage "..stage.api_id)
                        StageAPI.GotoCustomStage(StageAPI.CustomStages[stage.api_id],false)
                        local remove_labrynth_reseed = function()
                            local depth = 30

                            while GODMODE.util.has_curse(LevelCurse.CURSE_OF_LABYRINTH) and depth > 0 do 
                                Isaac.ExecuteCommand("creseed")
                                depth = depth -1 
                            end
                        end

                        remove_labrynth_reseed()

                        if stage.api_id == "FruitCellar" or stage.api_id == "IvoryPalace" then --reduce planetarium chance artificially
                            local rooms = Game():GetLevel():GetRooms()
                            local depth = 10
                            local has_planetarium = function()
                                for i=0, rooms.Size-1 do
                                    local room = rooms:Get(i)
                                    if room.Data and room.Data.Type == RoomType.ROOM_PLANETARIUM then
                                        return true 
                                    end 
                                end

                                return false 
                            end
                            
                            if has_planetarium() and (GODMODE.util.random() > (0.01/0.21) and stage.api_id == "FruitCellar" or stage.api_id ~= "FruitCellar") then 
                                while has_planetarium() and depth > 0 do
                                    depth = depth - 1
                                    remove_labrynth_reseed()
                                end    
                            end

                            Game():GetLevel():DisableDevilRoom()
                        end

                        -- StageAPI.GotoCustomStage(stage.stage, false, false)
                        break
                    end
                end
            end
        end
    end

    GODMODE.unlock_room_gfx = {
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
    }

    GODMODE.log("Loaded Godmode StageAPI Integration!")
end

-- if DetailedRespawnGlobalAPI then
--     DetailedRespawnGlobalAPI.AddCustomRespawn({
--         name = "GODMODEEdibleSoul",
--         itemId = Isaac.GetItemIdByName("Edible Soul"),
--         -- positionModifier = Vector.Zero
--     }, DetailedRespawnGlobalAPI.RespawnPosition.Last)
-- end