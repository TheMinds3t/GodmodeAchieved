local con_pre = {}

-- presets made by yours truly 
con_pre.gen_vanilla_presets = function()
    con_pre.presets = con_pre.presets or {} 
    
    con_pre.presets["lite"] = {
        ["EnemyAlts"] = "false",
        ["EnemyModifier"] = "1.0",
        ["EnemyCapModifier"] = "0",
        ["PickupAlts"] = "false",
        ["PickupModifier"] = "1.0",
        ["PickupCapModifier"] = "0",
        ["HMEnable"] = "false",
        ["HMEScale"] = "1.0",
        ["HMBScale"] = "1.0",
        ["GMEnable"] = "false",
        ["GMEScale"] = "1.0",
        ["GMBScale"] = "1.0",
        ["ScaleSelectorMax"] = "3000",
        ["BossesEnabled"] = "true",
        ["MajorBossPercent"] = "1.0",
        ["MinorBossPercent"] = "1.0",
        ["VLapEnabled"] = "false",
        ["MultiPlanetItems"] = "false",
        ["BothRepPathItems"] = "false",
        ["TaintedLostWish"] = "false",
        ["ShopParrot"] = "false",
        ["HushTimeMins"] = "30",
        ["BRTimeMins"] = "20",
        ["DoorHazardChanceMod"] = "1.0",
        ["ReqsPrompt"] = "true",
        ["Unlocks"] = "true",
        ["BlueWombRework"] = "false",
        ["CallOfTheVoid"] = "false",
        ["COTVDoorHazardFX"] = "false",
        ["VoidEnterTime"] = tostring(30*60*7+5),
        ["RedCoinCounterKey"] = ""..Keyboard.KEY_TAB,
        ["RedCoinCounterButton"] = ""..ButtonAction.ACTION_MAP,
        ["DoorHazardChanceMod"] = "1.0",
        ["GodmodeStageChance"] = "0.25",
        ["AltHorsemanChance"] = "0.2",
        ["TXaphanTrail"] = "7",
        ["StatHelp"] = "false",
        ["StatHelpScale"] = "0.8",
        ["ToxicDecayRate"] = "120.0",
        ["MoreOptionsRework"] = "false",
        ["SheolToPalace"] = "false",
        ["CathedralToPalace"] = "false",
        ["DarkRoomToFurnace"] = "false",
        ["ChestToSanctuary"] = "false",
        ["ShopTheme"] = "false",
        ["CathedralTheme"] = "false",
        ["SugarPillChance"] = "0.2",
        ["ChestInfestChance"] = "30.0",
        ["ChestInfestToggle"] = "false",
        ["HPScaleMode"] = "2",
        ["VanillaStoryHPBuff"] = "false",
        ["VanillaStoryHPBuffCap"] = "1000.0",
        ["FaithlessStageDecay"] = "2",
        ["VoidStrength"] = "1",
        ["LighterTreasure"] = "true"
    }

    con_pre.presets["default"] = true

    con_pre.presets["amplified"] = {
        ["EnemyAlts"] = "true",
        ["EnemyModifier"] = "1.2",
        ["EnemyCapModifier"] = "1",
        ["PickupAlts"] = "true",
        ["PickupModifier"] = "1.0",
        ["PickupCapModifier"] = "0",
        ["HMEnable"] = "true",
        ["HMEScale"] = "3.0",
        ["HMBScale"] = "5.0",
        ["GMEnable"] = "true",
        ["GMEScale"] = "2.5",
        ["GMBScale"] = "5",
        ["ScaleSelectorMax"] = "5000",
        ["BossesEnabled"] = "true",
        ["MajorBossPercent"] = "1.0",
        ["MinorBossPercent"] = "1.0",
        ["VLapEnabled"] = "true",
        ["MultiPlanetItems"] = "true",
        ["BothRepPathItems"] = "true",
        ["TaintedLostWish"] = "true",
        ["ShopParrot"] = "true",
        ["HushTimeMins"] = "35",
        ["BRTimeMins"] = "20",
        ["DoorHazardChanceMod"] = "1.0",
        ["ReqsPrompt"] = "true",
        ["Unlocks"] = "true",
        ["BlueWombRework"] = "true",
        ["CallOfTheVoid"] = "true",
        ["COTVDoorHazardFX"] = "true",
        ["VoidEnterTime"] = tostring(30*60*3.5+5),
        ["RedCoinCounterKey"] = ""..Keyboard.KEY_TAB,
        ["RedCoinCounterButton"] = ""..ButtonAction.ACTION_MAP,
        ["DoorHazardChanceMod"] = "1.0",
        ["GodmodeStageChance"] = "0.25",
        ["AltHorsemanChance"] = "0.33",
        ["TXaphanTrail"] = "7",
        ["StatHelp"] = "true",
        ["StatHelpScale"] = "0.66",
        ["ToxicDecayRate"] = "120.0",
        ["MoreOptionsRework"] = "true",
        ["SheolToPalace"] = "true",
        ["CathedralToPalace"] = "true",
        ["DarkRoomToFurnace"] = "true",
        ["ChestToSanctuary"] = "true",
        ["ShopTheme"] = "true",
        ["CathedralTheme"] = "true",
        ["SugarPillChance"] = "0.2",
        ["ChestInfestChance"] = "35.0",
        ["ChestInfestToggle"] = "true",
        ["HPScaleMode"] = "2",
        ["VanillaStoryHPBuff"] = "true",
        ["VanillaStoryHPBuffCap"] = "5000.0",
        ["FaithlessStageDecay"] = "1",
        ["VoidStrength"] = "4",
        ["LighterTreasure"] = "false"
    }
end

local format_preset_name = function(name,custom)
    return string.lower((custom and "custom_" or "")..name)
end

con_pre.add_preset = function(name,preset,custom)
    custom = custom or custom == nil and true
    con_pre.presets[format_preset_name(name,custom)] = preset
end

con_pre.load_preset = function(name, custom)
    custom = custom or custom == nil and true
    local preset = con_pre.presets[format_preset_name(name,custom)]

    if preset ~= nil then 
        if name == "default" then 
            GODMODE.save_manager.set_default_persistant_data(false,true) --reduce redundancy
        else
            for key,val in pairs(preset) do 
                GODMODE.save_manager.set_config(key,val)
            end    
        end

        GODMODE.save_manager.save()
        GODMODE.save_manager.load()
    end
end

con_pre.save_as_preset = function(name, custom)
    custom = custom or custom == nil and true  
    local new_preset = {}

    for key,val in pairs(GODMODE.save_manager.god_data.config) do 
        new_preset[key] = val
    end

    con_pre.presets[format_preset_name(name,custom)] = new_preset
    return new_preset
end

con_pre.get_preset = function(name, custom)
    custom = custom or custom == nil and true 
    return con_pre.presets[format_preset_name(name,custom)]
end

con_pre.get_presets = function()
    return con_pre.presets
end



return con_pre