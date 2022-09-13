local json = require("json")

local save_manager = {}
save_manager.god_data = {persistant = {}, dynamic = {persistent_entities={}}, config={}}
save_manager.version = "0.2" --used to refresh outdated save files for Godmode
save_manager.save_override = false 

save_manager.save = function()
    Isaac.SaveModData(GODMODE.mod_object, json.encode(save_manager.god_data))
    GODMODE.save_manager_lock = false
end
 
save_manager.has_loaded = false

save_manager.load = function()
    if Isaac.HasModData(GODMODE.mod_object) and Isaac.LoadModData(GODMODE.mod_object):len() > 0 then
        local decoded = json.decode(Isaac.LoadModData(GODMODE.mod_object))
        save_manager.god_data = decoded

        local persistent_flag = tostring(decoded["persistant"] == nil or (decoded["persistant"] and (not decoded["persistant"]["PalaceKills"] or tostring(decoded["persistant"]["SaveVersion"]) ~= save_manager.version)))
        local config_flag = tostring(decoded["config"] == nil or (decoded["config"] and not decoded["config"]["EnemyAlts"])) or (decoded["persistant"] and tostring(decoded["persistant"]["SaveVersion"]) ~= save_manager.version)
        local new_save = decoded["persistant"] and tostring(decoded["persistant"]["SaveVersion"]) ~= save_manager.version

        if new_save then
            GODMODE.achievements.play_splash("save_wiped", 0.6)
        end

        if persistent_flag == "true" or config_flag == "true" then
            save_manager.set_default_persistant_data(persistent_flag == "true", config_flag == "true")
        end

        save_manager.god_data.dynamic.persistent_entities = save_manager.god_data.dynamic.persistent_entities or {}

        -- for _,ent in ipairs(Isaac.GetRoomEntities()) do 
        --     local data = GODMODE.get_ent_data(ent)

        --     if data ~= nil and data.persistent_data ~= nil then ent:Remove() end 
        -- end

        --position each persistent godmode entity to the right spots
        if #save_manager.god_data.dynamic.persistent_entities > 0 then 
            local ents = Isaac.GetRoomEntities()
            local total = 0

            --clear old entities
            for _,real_ent in ipairs(ents) do 
                local god_data = GODMODE.get_ent_data(real_ent)
                if god_data ~= nil and god_data.persistent_state ~= nil then 
                    if god_data.persistent_data ~= nil and god_data.persistent_data.in_room == true then 
                        local old_state = GODMODE.save_manager_lock
                        GODMODE.save_manager_lock = false
                        real_ent:Remove()
                        GODMODE.log("Persistence Loading Step 1: Remove Old Entity!",false)
                        GODMODE.save_manager_lock = old_state
                    end
                end
            end

            --spawn new ones with old data!
            for index,ent in ipairs(save_manager.god_data.dynamic.persistent_entities) do 
                local id = ent.persistent_id 
                local data = ent.data 
                local type = ent.type
                local variant = ent.variant
                local subtype = ent.subtype

                local persistent_ent = Isaac.Spawn(type,variant,subtype,Vector(ent.x,ent.y),Vector.Zero,nil)
                GODMODE.log("Persistence Loading Step 2: Spawned Entity "..type..","..variant..","..subtype.."!",false)
                data.persistent_id = id
                GODMODE.set_ent_data(persistent_ent, data)
                persistent_ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                persistent_ent:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
                -- persistent_ent:Update()
                total = total + 1
            end
            
            save_manager.god_data.dynamic.persistent_entities = {}
            GODMODE.save_manager_lock = false
            -- save_manager.god_data.dynamic.persistent_entities = {}
            GODMODE.log("Found "..total.." persistent entities!")
        end
    else
        save_manager.god_data = {persistant={},dynamic={persistent_entities={}},config={}}
        save_manager.set_default_persistant_data(true, true)
    end

    if not save_manager.has_loaded then 
        GODMODE.log("Save manager loaded!",true)
    end

    save_manager.has_loaded = true
end

save_manager.set_default_persistant_data = function(persistant, config)
    local save = false 
    if persistant == true then
        save_manager.god_data.persistant = {}
        save_manager.god_data.persistant["PalaceKills"] = "1"
        save_manager.god_data.persistant["PalaceComplete"] = "false"
        save_manager.god_data.persistant["SaveVersion"] = save_manager.version
        save = true
    end

    if config == true then
        save_manager.god_data.config = {}
        save_manager.god_data.config["EnemyAlts"] = "true"
        save_manager.god_data.config["EnemyModifier"] = "1.0"
        save_manager.god_data.config["EnemyCapModifier"] = "0"
        save_manager.god_data.config["PickupAlts"] = "true"
        save_manager.god_data.config["PickupModifier"] = "1.0"
        save_manager.god_data.config["PickupCapModifier"] = "0"
        save_manager.god_data.config["VoidOverlay"] = "true" 
        save_manager.god_data.config["HMEnable"] = "true"
        save_manager.god_data.config["HMEScale"] = "2.0"
        save_manager.god_data.config["HMBScale"] = "2.3"
        save_manager.god_data.config["GMEnable"] = "true"
        save_manager.god_data.config["GMEScale"] = "1.5"
        save_manager.god_data.config["GMBScale"] = "1.8"
        save_manager.god_data.config["ScaleSelectorMax"] = "3000"
        save_manager.god_data.config["BossesEnabled"] = "true"
        save_manager.god_data.config["MajorBossPercent"] = "1.0"
        save_manager.god_data.config["MinorBossPercent"] = "1.0"
        save_manager.god_data.config["VLapEnabled"] = "true"
        save_manager.god_data.config["MultiPlanetItems"] = "true"
        save_manager.god_data.config["BothRepPathItems"] = "true"
        save_manager.god_data.config["TaintedLostWish"] = "true"
        save_manager.god_data.config["ShopParrot"] = "true"
        save_manager.god_data.config["HushTimeMins"] = "35"
        save_manager.god_data.config["BRTimeMins"] = "20"
        save_manager.god_data.config["DoorHazardChanceMod"] = "1.0"
        save_manager.god_data.config["ReqsPrompt"] = "true"
        save_manager.god_data.config["Unlocks"] = "true"
        save_manager.god_data.config["BlueWombRework"] = "true"
        save_manager.god_data.config["CallOfTheVoid"] = "true"
        save_manager.god_data.config["COTVDoorHazardFX"] = "true"
        save_manager.god_data.config["COTVDisplay"] = "true"
        save_manager.god_data.config["COTVDisplayX"] = "0.5"
        save_manager.god_data.config["COTVDisplayY"] = "0.1"
        save_manager.god_data.config["VoidEnterTime"] = tostring(30*60*3.5+5)
        save_manager.god_data.config["RedCoinCounterKey"] = ""..Keyboard.KEY_TAB
        save_manager.god_data.config["RedCoinCounterButton"] = ""..ButtonAction.ACTION_MAP
        save_manager.god_data.config["DoorHazardChanceMod"] = "1.0"
        save_manager.god_data.config["GodmodeStageChance"] = "0.25"
        save_manager.god_data.config["AltHorsemanChance"] = "0.2"
        save = true
    end

    if save then 
        save_manager.save()
    end
end

save_manager.set_persistant_data = function(key, value)
    save_manager.god_data.persistant[key] = tostring(value)
    save_manager.save()
    return value
end

save_manager.get_persistant_data = function(key, default_val)
    return save_manager.god_data.persistant[key] or tostring(default_val)
end

save_manager.set_config = function(key, value)
    save_manager.god_data.config[key] = tostring(value)
    save_manager.save()
    save_manager.load()
end

save_manager.get_config = function(key, default_val, load)
    if load == true then save_manager.load() end
    return save_manager.god_data.config[key] or tostring(default_val)
end



save_manager.set_data = function(key, value, save)
    save_manager.god_data.dynamic[key] = tostring(value)

    if save == true and save_manager.save_override ~= true then 
        save_manager.save()
    end

    return value
end

save_manager.get_data = function(key, default_val, load)
    if load == true then save_manager.load() end
    return save_manager.god_data.dynamic[key] or tostring(default_val)
end

--A helper function to make player unique data storing easier
save_manager.set_player_data = function(player, key, value, save)
    return save_manager.set_data(key..player:GetName()..player.ControllerIndex, value, save)
end

--A helper function to make player unique data storing easier
save_manager.get_player_data = function(player, key, default_val, load)
    return save_manager.get_data(key..player:GetName()..player.ControllerIndex, default_val, load)
end

save_manager.has_player_data = function(player, key)
    return save_manager.god_data.dynamic[key..player:GetName()..player.ControllerIndex] ~= nil
end

save_manager.clear_key = function(key)
    save_manager.god_data.dynamic[key] = nil
end


save_manager.add_persistent_entity_data = function(entity)
    local data = GODMODE.get_ent_data(entity)

    if data ~= nil and data.persistent_state ~= nil and data.persistent_data ~= nil and entity:ToNPC() then 
        save_manager.god_data.dynamic.persistent_entities = save_manager.god_data.dynamic.persistent_entities or {}
        local id = #save_manager.god_data.dynamic.persistent_entities+1
        table.insert(save_manager.god_data.dynamic.persistent_entities, {
            type = entity.Type,
            variant = entity.Variant,
            subtype = entity.SubType,
            data = data,
            persistent_id = id,
            x = entity.Position.X,
            y = entity.Position.Y,
        })

        GODMODE.log("Persistence Saving: Saved Entity type="..entity.Type..",var="..entity.Variant..",sub="..entity.SubType)
    end
end

save_manager.remove_persistent_entity_data = function(entity)
    if entity:ToNPC() then 
        save_manager.god_data.dynamic.persistent_entities = save_manager.god_data.dynamic.persistent_entities or {}
        local id = entity:ToNPC().I1
        -- GODMODE.log("searching for data on id "..id.."..",true)

        for ind,save_data in ipairs(save_manager.god_data.dynamic.persistent_entities) do 
            if save_data.persistent_id == id then 
                table.remove(save_manager.god_data.dynamic.persistent_entities,ind)
            end
        end
    end
end

save_manager.wipe_persistent_entities = function()
    save_manager.god_data.dynamic.persistent_entities = {}
end

save_manager.wipe = function()
    GODMODE.log("WIPED DYNAMIC DATA!",true)
    save_manager.god_data.dynamic = {persistent_entities={}}
end

save_manager.load()

return save_manager