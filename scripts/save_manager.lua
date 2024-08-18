local json = require("json")

local save_manager = {}
save_manager.god_data = {persistant = {}, dynamic = {persistent_entities={}}, config={}, dss={}}
save_manager.version = "0.2" --used to refresh outdated save files for Godmode
save_manager.save_override = false 

save_manager.save = function()
    GODMODE.mod_object:SaveData(json.encode(save_manager.god_data))
    GODMODE.save_manager_lock = false
end
 
save_manager.has_loaded = false
save_manager.allow_persistent_load = false

save_manager.load = function()
    if Isaac.HasModData(GODMODE.mod_object) and Isaac.LoadModData(GODMODE.mod_object):len() > 0 then
        local decoded = json.decode(GODMODE.mod_object:LoadData())
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
        if #save_manager.god_data.dynamic.persistent_entities > 0 and save_manager.allow_persistent_load == true then 
    
            local ents = Isaac.GetRoomEntities()
            local total = 0

            -- --clear old entities
            -- for _,real_ent in ipairs(ents) do 
            --     local god_data = GODMODE.get_ent_data(real_ent)
            --     if god_data ~= nil and god_data.persistent_state ~= nil then 
            --         if god_data.persistent_data ~= nil and god_data.persistent_data.in_room == true then 
            --             local old_state = GODMODE.save_manager_lock
            --             GODMODE.save_manager_lock = false

            --             GODMODE.log("persist_debug seed:"..real_ent.InitSeed,true)

            --             real_ent:Remove()
            --             GODMODE.log("Persistence Loading Step 1: Remove Old Entity!",false)
            --             GODMODE.save_manager_lock = old_state
            --         end
            --     end
            -- end

            -- gather seed to entity map
            local existing = {} 

            -- keep track of duplicate seeds to remove entries
            local new = {}
            
            for ind,ent in pairs(Isaac.GetRoomEntities()) do 
                if ent ~= nil then 
                    if existing[ent.InitSeed] then 
                        GODMODE.log("found duplicate seed \'"..ent.InitSeed.."\', be aware",true)
                    else
                        existing[ent.InitSeed] = ent
                    end
                end
            end

            -- updated code, now searches via initseed and copies data to existing entity
            for index,ent in ipairs(save_manager.god_data.dynamic.persistent_entities) do 
                local seed = ent.seed 
                local spawner_seed = ent.spawner_seed 
                local data = ent.data 
                local type = ent.type
                local variant = ent.variant
                local subtype = ent.subtype

                if new[seed] == true then 
                    GODMODE.log("Found duplicate persistent entry for seed \'"..seed.."\', removing duplicate")
                    table.remove(save_manager.god_data.dynamic.persistent_entities,index)
                else
                    local persistent_ent = existing[seed]--GODMODE.util.get_entity_by_seed(seed)--GODMODE.game:Spawn(type,variant,Vector(ent.x,ent.y),Vector.Zero,GODMODE.util.get_entity_by_seed(spawner_seed),subtype,seed)
                    if persistent_ent ~= nil then 
                        GODMODE.log("Persistence Loading Step 2: Found Entity "..type..","..variant..","..subtype.." (seed="..seed.."!")
                        -- data.persistent_id = id
                        GODMODE.set_ent_data(persistent_ent, data)
                        persistent_ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        persistent_ent:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
                        
                        if GODMODE.room and GODMODE.room.GetDecorationSeed and data.persistent_data and data.persistent_data.room == GODMODE.room:GetDecorationSeed() then 
                            persistent_ent.Position = Vector(ent.x, ent.y)
                        end
                        -- persistent_ent:Update()
                        total = total + 1    
                    else 
                        GODMODE.log("Unable to find entity with seed \'"..seed.."\', creating entity")
                        local new_ent = GODMODE.game:Spawn(type, variant, Vector(ent.x, ent.y), Vector.Zero, existing[spawner_seed], subtype, seed)
                        GODMODE.set_ent_data(new_ent,data)
                        new_ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        new_ent:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
                        new[seed] = true
    
                        total = total + 1
                    end    
                end
            end
            
            -- save_manager.god_data.dynamic.persistent_entities = {}
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
        save_manager.god_data.persistant["PalaceKills"] = "0"
        save_manager.god_data.persistant["PalaceComplete"] = "false"
        save_manager.god_data.persistant["SaveVersion"] = save_manager.version
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
        save_manager.god_data.config["TXaphanTrail"] = "7"
        save_manager.god_data.config["StatHelp"] = "true"
        save_manager.god_data.config["StatHelpScale"] = "0.8"
        save_manager.god_data.config["ToxicDecayRate"] = "120.0"
        save_manager.god_data.config["MoreOptionsRework"] = "true"
        save_manager.god_data.config["SheolToPalace"] = "true"
        save_manager.god_data.config["CathedralToPalace"] = "true"
        save_manager.god_data.config["DarkRoomToFurnace"] = "true"
        save_manager.god_data.config["ChestToSanctuary"] = "true"
        save_manager.god_data.config["ShopTheme"] = "true"
        save_manager.god_data.config["CathedralTheme"] = "true"
        save_manager.god_data.config["SugarPillChance"] = "0.2"
        save_manager.god_data.config["FractalDisplay"] = "2"
        save_manager.god_data.config["FractalDisplayX"] = "0.05"
        save_manager.god_data.config["FractalDisplayY"] = "0.9"
        save_manager.god_data.config["ChestInfestChance"] = "30.0"
        save_manager.god_data.config["ChestInfestToggle"] = "true"
        -- save_manager.god_data.config["AutoChargeAttack"] = "false"
    end

    if config or persistent == true then 
        save_manager.save()
    end
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
            -- persistent_id = id,
            seed = entity.InitSeed,
            spawner_seed = entity.SpawnerEntity and entity.SpawnerEntity.InitSeed or nil,
            -- ptr = GetPtrseed(entity),
            x = entity.Position.X,
            y = entity.Position.Y,
        })

        GODMODE.log("Persistence Saving: Saved Entity type="..entity.Type..",var="..entity.Variant..",sub="..entity.SubType..",seed="..entity.InitSeed, true)
    end
end

save_manager.remove_persistent_entity_data = function(entity)
    if entity:ToNPC() then 
        save_manager.god_data.dynamic.persistent_entities = save_manager.god_data.dynamic.persistent_entities or {}
        local id = entity.InitSeed
        -- GODMODE.log("searching for data on id "..id.."..",true)

        for ind,save_data in ipairs(save_manager.god_data.dynamic.persistent_entities) do 
            if save_data.seed == id then 
                table.remove(save_manager.god_data.dynamic.persistent_entities,ind)
            end
        end
    end
end

save_manager.wipe_persistent_entities = function()
    save_manager.god_data.dynamic.persistent_entities = {}
    save_manager.save()
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
    return save_manager.set_data(key..player.InitSeed, value, save)
end

--A helper function to make player unique data storing easier
save_manager.get_player_data = function(player, key, default_val, load)
    return save_manager.get_data(key..player.InitSeed, default_val, load)
end

--A helper function to make entity unique data storing easier
save_manager.set_ent_data = function(ent, key, value, save)
    return save_manager.set_data(key..ent.InitSeed, value, save)
end

--A helper function to make entity unique data storing easier
save_manager.get_ent_data = function(ent, key, default_val, load)
    return save_manager.get_data(key..ent.InitSeed, default_val, load)
end

save_manager.has_player_data = function(player, key)
    return save_manager.god_data.dynamic[key..player.InitSeed] ~= nil
end

save_manager.add_list_data = function(key,value,save)
    local existing = save_manager.get_data(key,"")

    if existing == "" then 
        save_manager.set_data(key,""..value,save)
    else
        save_manager.set_data(key,existing..","..value,save)
    end
end

save_manager.remove_list_data = function(key,value,save)
    local existing = save_manager.get_data(key,"")
    value = ""..value

    if existing == value then 
        save_manager.set_data(key,"",save)
    elseif GODMODE.util.string_starts(existing,value) then 
        save_manager.set_data(key,existing:sub(value:len()+1),save)
    else
        save_manager.set_data(key,existing:gsub(","..value,""),save)
    end
end

save_manager.get_list_data = function(key,load,transform_func)
    if save_manager.god_data.dynamic[key] == nil then return {} end 
    
    local ret = {}
    local existing = GODMODE.util.string_split(GODMODE.save_manager.get_data(key,"",load),",")
    transform_func = transform_func or function(val) return val end 

    if existing ~= "" then 
        for _,val in ipairs(existing) do 
            table.insert(ret,transform_func(val))
        end
    end
    
    return ret
end

save_manager.list_contains = function(key,transform_func,predicate)
    if save_manager.god_data.dynamic[key] == nil then return false end 
    local list = save_manager.get_list_data(key,false,transform_func)
    predicate = predicate or function(ele) return false end 

    for _,ele in ipairs(list) do 
        if predicate(ele) then return true end
    end

    return false 
end

save_manager.add_player_list_data = function(player,key,value,save)
    local existing = save_manager.get_player_data(player,key,"")

    if existing == "" then 
        save_manager.set_player_data(player,key,""..value,save)
    else
        save_manager.set_player_data(player,key,existing..","..value,save)
    end
end

save_manager.remove_player_list_data = function(player,key,value,save)
    local existing = save_manager.get_player_data(player,key,"")
    value = ""..value

    if existing == value then 
        save_manager.set_player_data(player,key,"",save)
    elseif GODMODE.util.string_starts(existing,value) then 
        save_manager.set_player_data(player,key,existing:sub(value:len()+1),save)
    else
        save_manager.set_player_data(player,key,existing:gsub(","..value,""),save)
    end
end

save_manager.get_player_list_data = function(player,key,load,transform_func)
    local ret = {}
    local existing = GODMODE.util.string_split(GODMODE.save_manager.get_player_data(player,key,"",load),",")
    transform_func = transform_func or function(val) return val end 

    if existing ~= "" then 
        for _,val in ipairs(existing) do 
            table.insert(ret,transform_func(val))
        end
    end
    
    return ret
end

save_manager.clear_key = function(key,save)
    save_manager.god_data.dynamic[key] = nil

    if save then 
        save_manager.save()
    end
end

save_manager.get_dss = function()
    return save_manager.god_data.dss or {}
end

save_manager.set_dss = function(dss,save)
    save_manager.god_data.dss = dss 

    if save then 
        save_manager.save()
    end
end

save_manager.wipe = function()
    GODMODE.log("WIPED DYNAMIC DATA!",true)
    save_manager.god_data.dynamic = {persistent_entities={}}
end

save_manager.load()

return save_manager