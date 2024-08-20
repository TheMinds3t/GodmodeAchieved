local godhook = {}
-- A helper class to hook all Godmode classes to the mod callbacks within a single callback, rather than registering all or iterating through all.  
-- If you desire, you can add items or monsters to the lists "GODMODE.items" or "GODMODE.monsters" and call GODMODE.godhooks.register_items_and_ents() and it should incorporate custom classes!

--connects functions from files to a singular string to function dictionary
godhook.hook = {monsters={},monster_keys={},bypass_monster_keys={},items={},item_keys={},hooks_added={}}
godhook.hook.monsters = {}
godhook.hook.items = {}
godhook.effect_data_list = {}

--[[
    example of how data is stored:

    godhook.hook = {
        monsters = {
            ["npc_update"] = {
                ["700.0"] = update_function from monster file,
                ["700.1"] = update_function from monster file,
                ...
            },
            ["player_collide"] = {
                ["700.0"] = collide_function from monster file,
                ["700.1"] = collide_function from monster file,
                ...
            },
            ...
        },
        bypass_monster_keys = {
            ["npc_init"] = {"700.0","700.1",...} <- used to bypass individual qualifiers for certain functions, like npc_init. Allows one file to handle multiple entity types
        },
        monster_keys = {
            ["npc_update"] = {"700.0","700.1",...},  <-- used so that each hook has a cache of what monster files actually use the hook 
            ...                                         so iterating through all monsters for each hook isn't necessary
        },
        items = {
            ["npc_update"] = {
                [GODMODE.registry.items.adramolechs_blessing] = update_function from item file,
                [GODMODE.registry.items.morphine] = update_function from item file,
                ...
            },
            ...
        },
        item_keys = {
            ["npc_update"] = {GODMODE.registry.items.adramolechs_blessing,GODMODE.registry.items.morphine}, <-- used so that each hook has a cache of what item files actually use the hook 
            ...                                                                                                       so iterating through all items for each hook isn't necessary
        },
        hooks_added = {"npc_update","player_collide",...} <-- used to register api callbacks once per hook
    }

]]--

--Registry of functions to hook classes into
godhook.functions = {}
godhook.functions.player_collide = function(self, player,ent,entfirst)
    local p_data = GODMODE.get_ent_data(player)
    if godhook.hook.monsters["player_collide"] then 
        if godhook.hook.bypass_monster_keys["player_collide"] then
            for ind=1, #godhook.hook.bypass_monster_keys["player_collide"] do
                local ret = godhook.hook.bypass_monster_keys["player_collide"][ind](self,player,ent,entfirst,p_data)

                if ret ~= nil then
                    return ret
                end
            end
        end

        if godhook.hook.monsters["player_collide"][ent.Type..","..ent.Variant] ~= nil then
            local ret = godhook.hook.monsters["player_collide"][ent.Type..","..ent.Variant](self,player,ent,entfirst,p_data)

            if ret ~= nil then
                return ret
            end
        end
    end

    if godhook.hook.items["player_collide"] then
        for ind=1, #godhook.hook.item_keys["player_collide"] do
            local func = godhook.hook.items["player_collide"][godhook.hook.item_keys["player_collide"][ind]]
            if func then
                local ret = func(self,player,ent,entfirst,p_data)

                if ret ~= nil then
                    return ret 
                end
            end
        end
    end
end
godhook.functions.pickup_collide = function(self, pickup,ent,entfirst)
    if godhook.hook.monsters["pickup_collide"] then
        if godhook.hook.monsters["pickup_collide"][ent.Type..","..ent.Variant] ~= nil then 
            local ret = godhook.hook.monsters["pickup_collide"][ent.Type..","..ent.Variant](self,pickup,ent,entfirst)

            if ret ~= nil then
                return ret
            end
        end
    end

    if godhook.hook.bypass_monster_keys["pickup_collide"] then
        for ind=1, #godhook.hook.bypass_monster_keys["pickup_collide"] do
            local ret2 = godhook.hook.bypass_monster_keys["pickup_collide"][ind](self,pickup,ent,entfirst)
            if ret2 ~= nil then
                return ret2
            end
        end
    end    

    if godhook.hook.items["pickup_collide"] then
        for ind=1, #godhook.hook.item_keys["pickup_collide"] do
            local func = godhook.hook.items["pickup_collide"][godhook.hook.item_keys["pickup_collide"][ind]]
            if func then
                local ret = func(self,pickup,ent,entfirst)

                if ret ~= nil then
                    return ret 
                end
            end
        end
    end
end
godhook.functions.tear_collide = function(self, tear,ent,entfirst)
    if godhook.hook.monsters["tear_collide"] and godhook.hook.monsters["tear_collide"][ent.Type..","..ent.Variant] ~= nil then
        local ret = godhook.hook.monsters["tear_collide"][ent.Type..","..ent.Variant](self,tear,ent,entfirst)

        if ret ~= nil then
            return ret
        end
    end

    if godhook.hook.items["tear_collide"] then
        for ind=1, #godhook.hook.item_keys["tear_collide"] do
            local func = godhook.hook.items["tear_collide"][godhook.hook.item_keys["tear_collide"][ind]]
            if func then
                local ret = func(self,tear,ent,entfirst)

                if ret ~= nil then
                    return ret 
                end
            end
        end
    end
end
godhook.functions.laser_collide = function(self, laser,ent,entfirst)
    if godhook.hook.monsters["laser_collide"] and godhook.hook.monsters["laser_collide"][ent.Type..","..ent.Variant] ~= nil then
        local ret = godhook.hook.monsters["laser_collide"][ent.Type..","..ent.Variant](self,laser,ent,entfirst)

        if ret ~= nil then
            return ret
        end
    end

    if godhook.hook.items["laser_collide"] then
        for ind=1, #godhook.hook.item_keys["laser_collide"] do
            local func = godhook.hook.items["laser_collide"][godhook.hook.item_keys["laser_collide"][ind]]
            if func then
                local ret = func(self,laser,ent,entfirst)

                if ret ~= nil then
                    return ret 
                end
            end
        end
    end
end
godhook.functions.familiar_collide = function(self, fam,ent,entfirst)
    if godhook.hook.monsters["familiar_collide"] and godhook.hook.monsters["familiar_collide"][fam.Type..","..fam.Variant] ~= nil then
        local ret = godhook.hook.monsters["familiar_collide"][fam.Type..","..fam.Variant](self,fam,ent,entfirst)

        if ret ~= nil then
            return ret
        end
    elseif godhook.hook.monsters["familiar_collide"] and godhook.hook.monsters["familiar_collide"][ent.Type..","..ent.Variant] ~= nil then
        local ret = godhook.hook.monsters["familiar_collide"][ent.Type..","..ent.Variant](self,fam,ent,entfirst)

        if ret ~= nil then
            return ret
        end
    end

    if godhook.hook.items["familiar_collide"] then
        for ind=1, #godhook.hook.item_keys["familiar_collide"] do
            local func = godhook.hook.items["familiar_collide"][godhook.hook.item_keys["familiar_collide"][ind]]
            if func then
                local ret = func(self,fam,ent,entfirst)

                if ret ~= nil then
                    return ret 
                end
            end
        end
    end
end
godhook.functions.npc_collide = function(self, ent,ent2,entfirst)
    if godhook.hook.monsters["npc_collide"] and godhook.hook.monsters["npc_collide"][ent.Type..","..ent.Variant] ~= nil then
        local ret = godhook.hook.monsters["npc_collide"][ent.Type..","..ent.Variant](self,ent,ent2,entfirst)

        if ret ~= nil then
            return ret
        end
    end

    if godhook.hook.items["npc_collide"] then
        for ind=1, #godhook.hook.item_keys["npc_collide"] do
            local func = godhook.hook.items["npc_collide"][godhook.hook.item_keys["npc_collide"][ind]]
            if func then
                local ret = func(self,ent,ent2,entfirst)

                if ret ~= nil then
                    return ret 
                end
            end
        end
    end
end
godhook.functions.knife_collide = function(self, ent,ent2,entfirst)
    if godhook.hook.monsters["knife_collide"] and godhook.hook.monsters["knife_collide"][ent2.Type..","..ent2.Variant] ~= nil then
        local ret = godhook.hook.monsters["knife_collide"][ent2.Type..","..ent2.Variant](self,ent,ent2,entfirst)

        if ret ~= nil then
            return ret
        end
    end

    if godhook.hook.items["knife_collide"] then
        for ind=1, #godhook.hook.item_keys["knife_collide"] do
            local func = godhook.hook.items["knife_collide"][godhook.hook.item_keys["knife_collide"][ind]]
            if func then
                local ret = func(self,ent,ent2,entfirst)

                if ret ~= nil then
                    return ret 
                end
            end
        end
    end
end
godhook.functions.projectile_collide = function(self,ent,ent2,entfirst)
    if godhook.hook.monsters["projectile_collide"] then
        for ind=1, #godhook.hook.monster_keys["projectile_collide"] do
            local func = godhook.hook.monsters["projectile_collide"][godhook.hook.monster_keys["projectile_collide"][ind]]
            if func then
                func(self,ent,ent2,entfirst)
            end
        end
    end
    if godhook.hook.items["projectile_collide"] then
        for ind=1, #godhook.hook.item_keys["projectile_collide"] do
            local func = godhook.hook.items["projectile_collide"][godhook.hook.item_keys["projectile_collide"][ind]]
            if func then
                func(self)
            end
        end
    end
end
godhook.functions.projectile_init = function(self,ent,ent2,entfirst)
    if godhook.hook.monsters["projectile_init"] then
        for ind=1, #godhook.hook.monster_keys["projectile_init"] do
            local func = godhook.hook.monsters["projectile_init"][godhook.hook.monster_keys["projectile_init"][ind]]
            if func then
                func(self,ent,ent2,entfirst)
            end
        end
    end
    if godhook.hook.items["projectile_init"] then
        for ind=1, #godhook.hook.item_keys["projectile_init"] do
            local func = godhook.hook.items["projectile_init"][godhook.hook.item_keys["projectile_init"][ind]]
            if func then
                func(self)
            end
        end
    end
end
godhook.functions.familiar_update = function(self, fam)
    local data = GODMODE.get_ent_data(fam)
    local sprite = fam:GetSprite()

    if godhook.hook.monsters["familiar_update"] and godhook.hook.monsters["familiar_update"][fam.Type..","..fam.Variant] ~= nil then
        godhook.hook.monsters["familiar_update"][fam.Type..","..fam.Variant](self,fam,data,sprite)
    end

    if godhook.hook.items["familiar_update"] then
        for ind=1, #godhook.hook.item_keys["familiar_update"] do
            local func = godhook.hook.items["familiar_update"][godhook.hook.item_keys["familiar_update"][ind]]
            if func then
                func(self,fam,data,sprite)
            end
        end
    end
end
godhook.functions.post_render = function(self)
    if godhook.hook.monsters["post_render"] then
        for ind=1, #godhook.hook.monster_keys["post_render"] do
            local func = godhook.hook.monsters["post_render"][godhook.hook.monster_keys["post_render"][ind]]
            if func then
                func(self)
            end
        end
    end
    if godhook.hook.items["post_render"] then
        for ind=1, #godhook.hook.item_keys["post_render"] do
            local func = godhook.hook.items["post_render"][godhook.hook.item_keys["post_render"][ind]]
            if func then
                func(self)
            end
        end
    end
end
godhook.functions.post_update = function(self)
    if godhook.hook.monsters["post_update"] then
        for ind=1, #godhook.hook.monster_keys["post_update"] do
            local func = godhook.hook.monsters["post_update"][godhook.hook.monster_keys["post_update"][ind]]
            if func then
                func(self)
            end
        end
    end
    if godhook.hook.items["post_update"] then
        for ind=1, #godhook.hook.item_keys["post_update"] do
            local func = godhook.hook.items["post_update"][godhook.hook.item_keys["post_update"][ind]]
            if func then
                func(self)
            end
        end
    end
end

godhook.functions.new_room = function(self)
    GODMODE.room = Game():GetRoom()

    if godhook.hook.monsters["new_room"] then
        for ind=1, #godhook.hook.monster_keys["new_room"] do
            local func = godhook.hook.monsters["new_room"][godhook.hook.monster_keys["new_room"][ind]]
            if func then
                func(self)
            end
        end
    end
    if godhook.hook.items["new_room"] then
        for ind=1, #godhook.hook.item_keys["new_room"] do
            local func = godhook.hook.items["new_room"][godhook.hook.item_keys["new_room"][ind]]
            if func then
                func(self)
            end
        end
    end
end

godhook.functions.new_level = function(self)
    GODMODE.level = Game():GetLevel()

    if godhook.hook.monsters["new_level"] then
        for ind=1, #godhook.hook.monster_keys["new_level"] do
            local func = godhook.hook.monsters["new_level"][godhook.hook.monster_keys["new_level"][ind]]
            if func then
                func(self)
            end
        end
    end
    if godhook.hook.items["new_level"] then
        for ind=1, #godhook.hook.item_keys["new_level"] do
            local func = godhook.hook.items["new_level"][godhook.hook.item_keys["new_level"][ind]]
            if func then
                func(self)
            end
        end
    end
end

godhook.functions.room_rewards = function(self,rng,pos)
    if godhook.hook.monsters["room_rewards"] then
        for ind=1, #godhook.hook.monster_keys["room_rewards"] do
            local func = godhook.hook.monsters["room_rewards"][godhook.hook.monster_keys["room_rewards"][ind]]
            if func then
                func(self,rng,pos)
            end
        end
    end
    if godhook.hook.items["room_rewards"] then
        for ind=1, #godhook.hook.item_keys["room_rewards"] do
            local func = godhook.hook.items["room_rewards"][godhook.hook.item_keys["room_rewards"][ind]]
            if func then
                func(self,rng,pos)
            end
        end
    end
end

godhook.functions.eval_cache = function(self,player,cache)
    local data = GODMODE.get_ent_data(player)
    if godhook.hook.monsters["eval_cache"] then
        for ind=1, #godhook.hook.monster_keys["eval_cache"] do
            local func = godhook.hook.monsters["eval_cache"][godhook.hook.monster_keys["eval_cache"][ind]]
            if func then
                func(self,player,cache,data)
            end
        end
    end
    if godhook.hook.items["eval_cache"] then
        for ind=1, #godhook.hook.item_keys["eval_cache"] do
            local func = godhook.hook.items["eval_cache"][godhook.hook.item_keys["eval_cache"][ind]]
            if func then
                func(self,player,cache,data)
            end
        end
    end
end

godhook.functions.player_init = function(self,player)
    if godhook.hook.monsters["player_init"] then
        for ind=1, #godhook.hook.monster_keys["player_init"] do
            local func = godhook.hook.monsters["player_init"][godhook.hook.monster_keys["player_init"][ind]]
            if func then
                func(self,player)
            end
        end
    end
    if godhook.hook.items["player_init"] then
        for ind=1, #godhook.hook.item_keys["player_init"] do
            local func = godhook.hook.items["player_init"][godhook.hook.item_keys["player_init"][ind]]
            if func then
                func(self,player)
            end
        end
    end
end
godhook.functions.player_update = function(self,player)
    local data = GODMODE.get_ent_data(player)

    if godhook.hook.monsters["player_update"] then
        for ind=1, #godhook.hook.monster_keys["player_update"] do
            local func = godhook.hook.monsters["player_update"][godhook.hook.monster_keys["player_update"][ind]]
            if func then
                func(self,player,data)
            end
        end
    end
    
    if godhook.hook.items["player_update"] then
        for ind=1, #godhook.hook.item_keys["player_update"] do
            local func = godhook.hook.items["player_update"][godhook.hook.item_keys["player_update"][ind]]
            if func then
                func(self,player,data)
            end
        end
    end
end
godhook.functions.player_render = function(self,player,offset)
    if godhook.hook.monsters["player_render"] then
        for ind=1, #godhook.hook.monster_keys["player_render"] do
            local func = godhook.hook.monsters["player_render"][godhook.hook.monster_keys["player_render"][ind]]
            if func then
                func(self,player,offset)
            end
        end
    end
    if godhook.hook.items["player_render"] then
        for ind=1, #godhook.hook.item_keys["player_render"] do
            local func = godhook.hook.items["player_render"][godhook.hook.item_keys["player_render"][ind]]
            if func then
                func(self,player,offset)
            end
        end
    end
end

godhook.functions.npc_init = function(self, ent)
    local data = GODMODE.get_ent_data(ent)
    if godhook.hook.monsters["npc_init"] then 
        if godhook.hook.monsters["npc_init"][ent.Type..","..ent.Variant] ~= nil then
            godhook.hook.monsters["npc_init"][ent.Type..","..ent.Variant](self,ent,data)
        end
    
        if godhook.hook.bypass_monster_keys["npc_init"] then
            for ind=1, #godhook.hook.bypass_monster_keys["npc_init"] do
                local func = godhook.hook.bypass_monster_keys["npc_init"][ind]
                if func then
                    func(self,ent,data)
                end
            end
        end    
    end

    if godhook.hook.items["npc_init"] then
        for ind=1, #godhook.hook.item_keys["npc_init"] do
            local func = godhook.hook.items["npc_init"][godhook.hook.item_keys["npc_init"][ind]]
            if func then
                func(self,ent,data)
            end
        end
    end
end
godhook.functions.npc_update = function(self, ent)
    ent = ent:ToNPC()
    local data = GODMODE.get_ent_data(ent)
    local sprite = ent:GetSprite() --adding common vars to ease up callbacks
    if godhook.hook.monsters["npc_update"] and godhook.hook.monsters["npc_update"][ent.Type..","..ent.Variant] ~= nil then 
        godhook.hook.monsters["npc_update"][ent.Type..","..ent.Variant](self,ent,data,sprite)

        if GODMODE.util.is_delirium() then     
            if godhook.hook.monsters["set_delirium_visuals"][ent.Type..","..ent.Variant] ~= nil and ent:IsBoss() and (data.delirium_visuals_changed or false) == false then
                if ent:HasEntityFlags(EntityFlag.FLAG_APPEAR) then ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR) end
                godhook.hook.monsters["set_delirium_visuals"][ent.Type..","..ent.Variant](self,ent,data,sprite)
                data.delirium_visuals_changed = true
            end
        end
    end

    if godhook.hook.items["npc_update"] then
        for ind=1, #godhook.hook.item_keys["npc_update"] do
            local func = godhook.hook.items["npc_update"][godhook.hook.item_keys["npc_update"][ind]]
            if func then
                func(self,ent,data,sprite)
            end
        end
    end
end
godhook.functions.pre_npc_update = function(self, ent)
    if godhook.hook.monsters["pre_npc_update"] and godhook.hook.monsters["pre_npc_update"][ent.Type..","..ent.Variant] ~= nil then
        local ret = godhook.hook.monsters["pre_npc_update"][ent.Type..","..ent.Variant](self,ent)
        
        if ret ~= nil then return ret end
    end

    if godhook.hook.items["pre_npc_update"] then
        for ind=1, #godhook.hook.item_keys["pre_npc_update"] do
            local func = godhook.hook.items["pre_npc_update"][godhook.hook.item_keys["pre_npc_update"][ind]]
            if func then
                local ret = func(self,ent)
                if ret ~= nil then return ret end
            end
        end
    end
end
godhook.functions.npc_kill = function(self, ent)
    if godhook.hook.monsters["npc_kill"] and godhook.hook.monsters["npc_kill"][ent.Type..","..ent.Variant] ~= nil then
        godhook.hook.monsters["npc_kill"][ent.Type..","..ent.Variant](self,ent)
    end

    if godhook.hook.items["npc_kill"] then
        for ind=1, #godhook.hook.item_keys["npc_kill"] do
            local func = godhook.hook.items["npc_kill"][godhook.hook.item_keys["npc_kill"][ind]]
            if func then
                func(self,ent)
            end
        end
    end
end
godhook.functions.npc_remove = function(self, ent)
    if godhook.hook.monsters["npc_remove"] and godhook.hook.monsters["npc_remove"][ent.Type..","..ent.Variant] ~= nil then
        godhook.hook.monsters["npc_remove"][ent.Type..","..ent.Variant](self,ent)
    end

    if godhook.hook.items["npc_remove"] then
        for ind=1, #godhook.hook.item_keys["npc_remove"] do
            local func = godhook.hook.items["npc_remove"][godhook.hook.item_keys["npc_remove"][ind]]
            if func then
                func(self,ent)
            end
        end
    end
end
godhook.functions.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local returned = nil
    if godhook.hook.monsters["npc_hit"] then
        for ind=1, #godhook.hook.monster_keys["npc_hit"] do
            local func = godhook.hook.monsters["npc_hit"][godhook.hook.monster_keys["npc_hit"][ind]]
            if func then
                local ret = func(self,enthit,amount,flags,entsrc,countdown)
                -- if ret ~= nil then GODMODE.log("ret is "..tostring(ret).." from "..godhook.hook.monster_keys["npc_hit"][ind],true) return ret end
                if ret ~= nil and returned ~= false then returned = ret end
            end
        end
    end
    if godhook.hook.items["npc_hit"] then
        for ind=1, #godhook.hook.item_keys["npc_hit"] do
            local func = godhook.hook.items["npc_hit"][godhook.hook.item_keys["npc_hit"][ind]]
            if func then
                local ret = func(self,enthit,amount,flags,entsrc,countdown)
                if ret ~= nil and returned ~= false then returned = ret end
            end
        end
    end

    if returned ~= nil then 
        return returned        
    end
end
godhook.functions.pre_entity_spawn = function(self,type,variant,subtype,pos,vel,spawner,seed)
    if godhook.hook.monsters["pre_entity_spawn"] and godhook.hook.monsters["pre_entity_spawn"][type..","..variant] ~= nil then
        local ret = godhook.hook.monsters["pre_entity_spawn"][type..","..variant](self,type,variant,subtype,pos,vel,spawner,seed)
        if ret ~= nil then return ret end
    end

    if godhook.hook.items["pre_entity_spawn"] then
        for ind=1, #godhook.hook.item_keys["pre_entity_spawn"] do
            local func = godhook.hook.items["pre_entity_spawn"][godhook.hook.item_keys["pre_entity_spawn"][ind]]
            if func then
                local ret = func(self,type,variant,subtype,pos,vel,spawner,seed)
                if ret ~= nil then return ret end
            end
        end
    end
end
godhook.functions.pickup_update = function(self, ent)
    local data = GODMODE.get_ent_data(ent)
    local sprite = ent:GetSprite()
    if godhook.hook.monsters["pickup_update"] and godhook.hook.monsters["pickup_update"][ent.Type..","..ent.Variant] ~= nil then
        godhook.hook.monsters["pickup_update"][ent.Type..","..ent.Variant](self,ent,data,sprite)
    else 
        if godhook.hook.monsters["pickup_update"] then
            for ind=1, #godhook.hook.monster_keys["pickup_update"] do
                local func = godhook.hook.monsters["pickup_update"][godhook.hook.monster_keys["pickup_update"][ind]]
                if func then
                    func(self,ent,data,sprite)
                end
            end
        end    
    end

    if godhook.hook.items["pickup_update"] then
        for ind=1, #godhook.hook.item_keys["pickup_update"] do
            local func = godhook.hook.items["pickup_update"][godhook.hook.item_keys["pickup_update"][ind]]
            if func then
                func(self,ent,data,sprite)
            end
        end
    end
end
godhook.functions.use_item = function(self, coll,rng,player,flags,slot,var_data)
    if godhook.hook.items["use_item"] then
        for ind=1, #godhook.hook.item_keys["use_item"] do
            local func = godhook.hook.items["use_item"][godhook.hook.item_keys["use_item"][ind]]
            if func then
                local ret = func(self,coll,rng,player,flags,slot,var_data)
                if ret ~= nil then return ret end
            end
        end
    end
    if godhook.hook.monsters["use_item"] then
        for ind=1, #godhook.hook.monster_keys["use_item"] do
            local func = godhook.hook.monsters["use_item"][godhook.hook.monster_keys["use_item"][ind]]
            if func then
                local ret = func(self,coll,rng,player,flags,slot,var_data)
                if ret ~= nil then return ret end
            end
        end
    end
end
godhook.functions.tear_fire = function(self, ent)
    local tear_data = GODMODE.get_ent_data(ent)
    if godhook.hook.monsters["tear_fire"] and godhook.hook.monsters["tear_fire"][ent.Type..","..ent.Variant] ~= nil then
        godhook.hook.monsters["tear_fire"][ent.Type..","..ent.Variant](self,ent,tear_data)
    end

    if godhook.hook.items["tear_fire"] then
        for ind=1, #godhook.hook.item_keys["tear_fire"] do
            local func = godhook.hook.items["tear_fire"][godhook.hook.item_keys["tear_fire"][ind]]
            if func then
                func(self,ent,tear_data)
            end
        end
    end
end
godhook.functions.tear_init = function(self, ent)
    local tear_data = GODMODE.get_ent_data(ent)

    if godhook.hook.monsters["tear_init"] and godhook.hook.monsters["tear_init"][ent.Type..","..ent.Variant] ~= nil then
        godhook.hook.monsters["tear_init"][ent.Type..","..ent.Variant](self,ent,tear_data)
    end

    if godhook.hook.items["tear_init"] then
        for ind=1, #godhook.hook.item_keys["tear_init"] do
            local func = godhook.hook.items["tear_init"][godhook.hook.item_keys["tear_init"][ind]]
            if func then
                func(self,ent,tear_data)
            end
        end
    end
end
godhook.functions.pickup_init = function(self, ent)
    local data = GODMODE.get_ent_data(ent)
    local sprite = ent:GetSprite()
    if godhook.hook.monsters["pickup_init"] then
        if godhook.hook.monsters["pickup_init"][ent.Type..","..ent.Variant] ~= nil then 
            godhook.hook.monsters["pickup_init"][ent.Type..","..ent.Variant](self,ent,data,sprite)
        end

        if godhook.hook.bypass_monster_keys["pickup_init"] then
            for ind=1, #godhook.hook.bypass_monster_keys["pickup_init"] do
                local func = godhook.hook.bypass_monster_keys["pickup_init"][ind]
                if func then
                    func(self,ent,data,sprite)
                end
            end
        end    
    end

    if godhook.hook.items["pickup_init"] then
        for ind=1, #godhook.hook.item_keys["pickup_init"] do
            local func = godhook.hook.items["pickup_init"][godhook.hook.item_keys["pickup_init"][ind]]
            if func then
                func(self,ent)
            end
        end
    end
end
godhook.functions.familiar_init = function(self, ent)
    if godhook.hook.monsters["familiar_init"] and godhook.hook.monsters["familiar_init"][ent.Type..","..ent.Variant] ~= nil then
        godhook.hook.monsters["familiar_init"][ent.Type..","..ent.Variant](self,ent)
    end

    if godhook.hook.items["familiar_init"] then
        for ind=1, #godhook.hook.item_keys["familiar_init"] do
            local func = godhook.hook.items["familiar_init"][godhook.hook.item_keys["familiar_init"][ind]]
            if func then
                func(self,ent)
            end
        end
    end
end
godhook.functions.game_start = function(self,continue)
    if godhook.hook.monsters["game_start"] then
        for ind=1, #godhook.hook.monster_keys["game_start"] do
            local func = godhook.hook.monsters["game_start"][godhook.hook.monster_keys["game_start"][ind]]
            if func then
                func(self,continue)
            end
        end
    end
    if godhook.hook.items["game_start"] then
        for ind=1, #godhook.hook.item_keys["game_start"] do
            local func = godhook.hook.items["game_start"][godhook.hook.item_keys["game_start"][ind]]
            if func then
                func(self,continue)
            end
        end
    end
end
godhook.functions.game_end = function(self,gameover)
    if godhook.hook.monsters["game_end"] then
        for ind=1, #godhook.hook.monster_keys["game_end"] do
            local func = godhook.hook.monsters["game_end"][godhook.hook.monster_keys["game_end"][ind]]
            if func then
                func(self,gameover)
            end
        end
    end
    if godhook.hook.items["game_end"] then
        for ind=1, #godhook.hook.item_keys["game_end"] do
            local func = godhook.hook.items["game_end"][godhook.hook.item_keys["game_end"][ind]]
            if func then
                func(self,gameover)
            end
        end
    end
end
godhook.functions.game_exit = function(self,save)
    if godhook.hook.monsters["game_exit"] then
        for ind=1, #godhook.hook.monster_keys["game_exit"] do
            local func = godhook.hook.monsters["game_exit"][godhook.hook.monster_keys["game_exit"][ind]]
            if func then
                func(self,save)
            end
        end
    end
    if godhook.hook.items["game_exit"] then
        for ind=1, #godhook.hook.item_keys["game_exit"] do
            local func = godhook.hook.items["game_exit"][godhook.hook.item_keys["game_exit"][ind]]
            if func then
                func(self,save)
            end
        end
    end
end
godhook.functions.pre_get_collectible = function(self,pool,decrease,seed)
    if godhook.hook.monsters["pre_get_collectible"] then
        for ind=1, #godhook.hook.monster_keys["pre_get_collectible"] do
            local func = godhook.hook.monsters["pre_get_collectible"][godhook.hook.monster_keys["pre_get_collectible"][ind]]
            if func then
                local ret = func(self,pool,decrease,seed)
                if ret ~= nil then return ret end
            end
        end
    end
    if godhook.hook.items["pre_get_collectible"] then
        for ind=1, #godhook.hook.item_keys["pre_get_collectible"] do
            local func = godhook.hook.items["pre_get_collectible"][godhook.hook.item_keys["pre_get_collectible"][ind]]
            if func then
                local ret = func(self,pool,decrease,seed)
                if ret ~= nil then return ret end
            end
        end
    end
end
godhook.functions.post_get_collectible = function(self,coll,pool,decrease,seed)
    if godhook.hook.monsters["post_get_collectible"] then
        for ind=1, #godhook.hook.monster_keys["post_get_collectible"] do
            local func = godhook.hook.monsters["post_get_collectible"][godhook.hook.monster_keys["post_get_collectible"][ind]]
            if func then
                local ret = func(self,coll,pool,decrease,seed)
                if ret ~= nil then return ret end
            end
        end
    end
    if godhook.hook.items["post_get_collectible"] then
        for ind=1, #godhook.hook.item_keys["post_get_collectible"] do
            local func = godhook.hook.items["post_get_collectible"][godhook.hook.item_keys["post_get_collectible"][ind]]
            if func then
                local ret = func(self,coll,pool,decrease,seed)
                if ret ~= nil then return ret end
            end
        end
    end
end
godhook.functions.get_trinket = function(self,trinket,rng)
    if godhook.hook.monsters["get_trinket"] then
        for ind=1, #godhook.hook.monster_keys["get_trinket"] do
            local func = godhook.hook.monsters["get_trinket"][godhook.hook.monster_keys["get_trinket"][ind]]
            if func then
                local ret = func(self,trinket,rng)
                if ret ~= nil then return ret end
            end
        end
    end
    if godhook.hook.items["get_trinket"] then
        for ind=1, #godhook.hook.item_keys["get_trinket"] do
            local func = godhook.hook.items["get_trinket"][godhook.hook.item_keys["get_trinket"][ind]]
            if func then
                local ret = func(self,trinket,rng)
                if ret ~= nil then return ret end
            end
        end
    end
end
godhook.functions.choose_curse = function(self,curses)
    if godhook.hook.monsters["choose_curse"] then
        for ind=1, #godhook.hook.monster_keys["choose_curse"] do
            local func = godhook.hook.monsters["choose_curse"][godhook.hook.monster_keys["choose_curse"][ind]]
            if func then
                local ret = func(self,curses)
                if ret ~= nil then return ret end
            end
        end
    end
    if godhook.hook.items["choose_curse"] then
        for ind=1, #godhook.hook.item_keys["choose_curse"] do
            local func = godhook.hook.items["choose_curse"][godhook.hook.item_keys["choose_curse"][ind]]
            if func then
                local ret = func(self,curses)
                if ret ~= nil then return ret end
            end
        end
    end
end
godhook.functions.npc_post_render = function(self,ent,offset)
    if godhook.hook.monsters["npc_post_render"] and godhook.hook.monsters["npc_post_render"][ent.Type..","..ent.Variant] ~= nil then
        godhook.hook.monsters["npc_post_render"][ent.Type..","..ent.Variant](self,ent,offset)
    end

    if godhook.hook.items["npc_post_render"] then
        for ind=1, #godhook.hook.item_keys["npc_post_render"] do
            local func = godhook.hook.items["npc_post_render"][godhook.hook.item_keys["npc_post_render"][ind]]
            if func then
                local ret = func(self,ent,offset)
                if ret ~= nil then return ret end
            end
        end
    end
end
godhook.functions.pickup_post_render = function(self,ent,offset)
    if godhook.hook.monsters["pickup_post_render"] and godhook.hook.monsters["pickup_post_render"][ent.Type..","..ent.Variant] ~= nil then
        godhook.hook.monsters["pickup_post_render"][ent.Type..","..ent.Variant](self,ent,offset)
    end

    if godhook.hook.bypass_monster_keys["pickup_post_render"] then
        for ind=1, #godhook.hook.bypass_monster_keys["pickup_post_render"] do
            local ret = godhook.hook.bypass_monster_keys["pickup_post_render"][ind](self,ent,offset)

            if ret ~= nil then
                return ret
            end
        end
    end

    if godhook.hook.items["pickup_post_render"] then
        for ind=1, #godhook.hook.item_keys["pickup_post_render"] do
            local func = godhook.hook.items["pickup_post_render"][godhook.hook.item_keys["pickup_post_render"][ind]]
            if func then
                local ret = func(self,ent,offset)
                if ret ~= nil then return ret end
            end
        end
    end
end
godhook.functions.famil_post_render = function(self,ent,offset)
    if godhook.hook.monsters["famil_post_render"] and godhook.hook.monsters["famil_post_render"][ent.Type..","..ent.Variant] ~= nil then
        godhook.hook.monsters["famil_post_render"][ent.Type..","..ent.Variant](self,ent,offset)
    end

    if godhook.hook.items["famil_post_render"] then
        for ind=1, #godhook.hook.item_keys["famil_post_render"] do
            local func = godhook.hook.items["famil_post_render"][godhook.hook.item_keys["famil_post_render"][ind]]
            if func then
                local ret = func(self,ent,offset)
                if ret ~= nil then return ret end
            end
        end
    end
end
godhook.functions.effect_post_render = function(self,ent,offset)
    if godhook.hook.monsters["effect_post_render"] and godhook.hook.monsters["effect_post_render"][ent.Type..","..ent.Variant] ~= nil then
        godhook.hook.monsters["effect_post_render"][ent.Type..","..ent.Variant](self,ent,offset)
    end

    if godhook.hook.items["effect_post_render"] then
        for ind=1, #godhook.hook.item_keys["effect_post_render"] do
            local func = godhook.hook.items["effect_post_render"][godhook.hook.item_keys["effect_post_render"][ind]]
            if func then
                local ret = func(self,ent,offset)
                if ret ~= nil then return ret end
            end
        end
    end
end
godhook.functions.bomb_init = function(self, ent)
    if godhook.hook.monsters["bomb_init"] then
        for ind=1, #godhook.hook.monster_keys["bomb_init"] do
            local func = godhook.hook.monsters["bomb_init"][godhook.hook.monster_keys["bomb_init"][ind]]
            if func then
                func(self,ent)
            end
        end
    end

    if godhook.hook.items["bomb_init"] then
        for ind=1, #godhook.hook.item_keys["bomb_init"] do
            local func = godhook.hook.items["bomb_init"][godhook.hook.item_keys["bomb_init"][ind]]
            if func then
                func(self,ent)
            end
        end
    end
end
godhook.functions.effect_init = function(self, ent)
    local data = GODMODE.get_ent_data(ent)

    if godhook.hook.monsters["effect_init"] then
        for ind=1, #godhook.hook.monster_keys["effect_init"] do
            local func = godhook.hook.monsters["effect_init"][godhook.hook.monster_keys["effect_init"][ind]]
            if func then
                func(self,ent,data)
            end
        end
    end
    if godhook.hook.items["effect_init"] then
        for ind=1, #godhook.hook.item_keys["effect_init"] do
            local func = godhook.hook.items["effect_init"][godhook.hook.item_keys["effect_init"][ind]]
            if func then
                func(self,ent,data)
            end
        end
    end
end
godhook.functions.effect_update = function(self, ent)

    if godhook.hook.monsters["effect_update"] and godhook.hook.monsters["effect_update"][ent.Type..","..ent.Variant] ~= nil then
        local data = GODMODE.get_ent_data(ent)
        local sprite = ent:GetSprite()
        godhook.hook.monsters["effect_update"][ent.Type..","..ent.Variant](self,ent,data,sprite)
    -- else 
        -- if godhook.hook.monsters["effect_update"] then
        --     local data = GODMODE.get_ent_data(ent)
        --     local sprite = ent:GetSprite()
        --     for ind=1, #godhook.hook.monster_keys["effect_update"] do
        --         local func = godhook.hook.monsters["effect_update"][godhook.hook.monster_keys["effect_update"][ind]]
        --         if func then
        --             GODMODE.log(godhook.hook.monster_keys["effect_update"][ind],true)
        --             func(self,ent,data,sprite)
        --         end
        --     end
        -- end    
    end

    if godhook.hook.items["effect_update"] then
        for ind=1, #godhook.hook.item_keys["effect_update"] do
            local func = godhook.hook.items["effect_update"][godhook.hook.item_keys["effect_update"][ind]]
            if func then
                func(self,ent,data,sprite)
            end
        end
    end
end
godhook.functions.tear_update = function(self, tear)
    local data = GODMODE.get_ent_data(tear)
    if godhook.hook.items["tear_update"] then
        for ind=1, #godhook.hook.item_keys["tear_update"] do
            local func = godhook.hook.items["tear_update"][godhook.hook.item_keys["tear_update"][ind]]
            if func then
                func(self,tear,data)
            end
        end
    end

    if godhook.hook.monsters["tear_update"] then
        for ind=1, #godhook.hook.monster_keys["tear_update"] do
            local func = godhook.hook.monsters["tear_update"][godhook.hook.monster_keys["tear_update"][ind]]
            if func then
                func(self,tear,data)
            end
        end
    end
end
godhook.functions.laser_update = function(self, laser)
    if godhook.hook.items["laser_update"] then
        for ind=1, #godhook.hook.item_keys["laser_update"] do
            local func = godhook.hook.items["laser_update"][godhook.hook.item_keys["laser_update"][ind]]
            if func then
                func(self,laser)
            end
        end
    end
end
godhook.functions.laser_init = function(self, laser)
    if godhook.hook.items["laser_init"] then
        for ind=1, #godhook.hook.item_keys["laser_init"] do
            local func = godhook.hook.items["laser_init"][godhook.hook.item_keys["laser_init"][ind]]
            if func then
                func(self,laser)
            end
        end
    end
end
godhook.functions.knife_update = function(self, knife)
    if godhook.hook.items["knife_update"] then
        for ind=1, #godhook.hook.item_keys["knife_update"] do
            local func = godhook.hook.items["knife_update"][godhook.hook.item_keys["knife_update"][ind]]
            if func then
                func(self,knife)
            end
        end
    end
end
godhook.functions.projectile_update = function(self,projectile)
    local data = GODMODE.get_ent_data(projectile)
    local sprite = projectile:GetSprite()
    if godhook.hook.monsters["projectile_update"] then
        for ind=1, #godhook.hook.monster_keys["projectile_update"] do
            local func = godhook.hook.monsters["projectile_update"][godhook.hook.monster_keys["projectile_update"][ind]]
            if func then
                func(self,projectile,data,sprite)
            end
        end
    end
    if godhook.hook.items["projectile_update"] then
        for ind=1, #godhook.hook.item_keys["projectile_update"] do
            local func = godhook.hook.items["projectile_update"][godhook.hook.item_keys["projectile_update"][ind]]
            if func then
                func(self,projectile,data,sprite)
            end
        end
    end
end
godhook.functions.input_event = function(self,ent,hook,action)
    if godhook.hook.monsters["input_event"] and godhook.hook.monsters["input_event"][ent.Type..","..ent.Variant] ~= nil then
        godhook.hook.monsters["input_event"][ent.Type..","..ent.Variant](self,ent,hook,action)
    end

    if godhook.hook.items["input_event"] then
        for ind=1, #godhook.hook.item_keys["input_event"] do
            local func = godhook.hook.items["input_event"][godhook.hook.item_keys["input_event"][ind]]
            if func then
                local ret = func(self,ent,hook,action)
                if ret ~= nil then return ret end
            end
        end
    end
end



local is_monster = function(object) return object.type and object.variant end

godhook.add_hook = function(funcname,object,hook)
    if is_monster(object) then
        if object.bypass_hooks ~= nil and object.bypass_hooks[funcname] then 
            godhook.hook.bypass_monster_keys[funcname] = godhook.hook.bypass_monster_keys[funcname] or {} 
            table.insert(godhook.hook.bypass_monster_keys[funcname],object[funcname])
        else 
            godhook.hook.monsters[funcname] = godhook.hook.monsters[funcname] or {} 
            godhook.hook.monsters[funcname][object.type..","..object.variant] = object[funcname]
            godhook.hook.monster_keys[funcname] = godhook.hook.monster_keys[funcname] or {} 
            table.insert(godhook.hook.monster_keys[funcname],object.type..","..object.variant)    
        end
    else
        godhook.hook.items[funcname] = godhook.hook.items[funcname] or {} 
        godhook.hook.items[funcname][object.instance] = object[funcname]
        godhook.hook.item_keys[funcname] = godhook.hook.item_keys[funcname] or {}
        table.insert(godhook.hook.item_keys[funcname],object.instance)
    end

    if godhook.hook.hooks_added[funcname] == nil then
        if hook ~= nil then 
            GODMODE.mod_object:AddCallback(hook,godhook.functions[funcname])
        end

        godhook.hook.hooks_added[funcname] = true
        GODMODE.log("Registered hook \'"..funcname.."\'!")
    end    
end

local function add_fx_data(object)
    if is_monster(object) then 
        godhook.effect_data_list[object.variant] = true
        GODMODE.log("adding fx data for \'"..object.variant.."\'!",true)
    end
end

--Dictionary registering a godmode class function to a modcallback.
godhook.hook_list = {
    ["room_rewards"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD)
    end,
    ["eval_cache"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_EVALUATE_CACHE)
    end,
    ["new_level"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_NEW_LEVEL)
    end,
    ["new_room"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_NEW_ROOM)
    end,
    ["post_update"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_UPDATE)
    end,
    ["post_render"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_RENDER)
    end,
    ["player_init"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_PLAYER_INIT)
    end,
    ["player_update"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_PLAYER_UPDATE)
    end,
    ["player_render"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_PLAYER_RENDER)
    end,
    ["npc_init"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_NPC_INIT)
    end,
    ["npc_update"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_NPC_UPDATE)
    end,
    ["pre_npc_update"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_PRE_NPC_UPDATE)
    end,
    ["npc_hit"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_ENTITY_TAKE_DMG)
    end,
    ["npc_kill"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_ENTITY_KILL)
    end,
    ["npc_remove"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_ENTITY_REMOVE)
    end,
    ["pre_entity_spawn"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_PRE_ENTITY_SPAWN)
    end,
    ["npc_post_render"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_NPC_RENDER)
    end,
    ["pickup_update"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_PICKUP_UPDATE)
    end,
    ["tear_update"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_TEAR_UPDATE)
    end,
    ["pickup_post_render"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_PICKUP_RENDER)
    end,
    ["famil_post_render"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_FAMILIAR_RENDER)
    end,
    ["effect_post_render"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_EFFECT_RENDER)
        add_fx_data(object)
    end,
    ["use_item"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_USE_ITEM)
    end,
    ["familiar_update"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_FAMILIAR_UPDATE)
    end,
    ["familiar_collide"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_PRE_FAMILIAR_COLLISION)
    end,
    ["player_collide"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_PRE_PLAYER_COLLISION)
    end,
    ["pickup_collide"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_PRE_PICKUP_COLLISION)
    end,
    ["tear_collide"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_PRE_TEAR_COLLISION)
    end,
    ["projectile_collide"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_PRE_PROJECTILE_COLLISION)
    end,
    ["projectile_update"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_PROJECTILE_UPDATE)
    end,
    ["projectile_init"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_PROJECTILE_INIT)
    end,
    ["npc_collide"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_PRE_NPC_COLLISION)
    end,
    ["knife_collide"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_PRE_KNIFE_COLLISION)
    end,
    ["tear_fire"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_FIRE_TEAR)
    end,
    ["tear_init"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_TEAR_INIT)
    end,
    ["bomb_init"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_BOMB_INIT)
    end,
    ["pickup_init"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_PICKUP_INIT)
    end,
    ["familiar_init"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_FAMILIAR_INIT)
    end,
    ["game_start"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_GAME_STARTED)
    end,
    ["game_end"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_GAME_END)
    end,
    ["game_exit"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_PRE_GAME_EXIT)
    end,
    ["pre_get_collectible"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_PRE_GET_COLLECTIBLE)
    end,
    ["post_get_collectible"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_GET_COLLECTIBLE)
    end,
    ["get_trinket"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_GET_TRINKET)
    end,
    ["choose_curse"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_CURSE_EVAL)
    end,
    ["effect_init"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_EFFECT_INIT)
        add_fx_data(object)
    end,
    ["effect_update"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_EFFECT_UPDATE)
        add_fx_data(object)
    end,
    ["laser_update"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_LASER_UPDATE)
    end,
    ["laser_init"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_LASER_INIT)
    end,
    ["knife_update"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_POST_KNIFE_UPDATE)
    end,
    ["input_event"] = function(funcname, object)
        godhook.add_hook(funcname,object,ModCallbacks.MC_INPUT_ACTION)
    end,
    ["set_delirium_visuals"] = function(funcname, object)
        godhook.add_hook(funcname,object,nil)
    end,

    --custom hooks
    ["first_level"] = true, --called for the first level of the run, use to init variables. Takes no return values. | first_level()
    ["on_item_pickup"] = true, --just for when items are grabbed, doesn't tell what item. Takes no return values. | on_item_pickup(player)
    ["data_init"] = true, --when godmode data is inited this is called, set default data values here. Takes no return values. | data_init(ent,data)
    ["render_player_ui"] = true, --render godmode ui. Takes no return values. | render_player_ui(player)
    ["pre_godmode_restart"] = true, --godmode trinket, pre rewind. Takes no return values. | pre_godmode_restart()
    ["post_godmode_restart"] = true, --godmode trinket, post rewind. Takes no return values. | post_godmode_restart()
    ["modify_blessing_chance"] = true, --called when choosing curses, starts with the default value. | set_blessing_chance(cur_chance)


    -- RGON callbacks
    ["pre_player_damaged"] = function(funcname, object)
        if GODMODE.validate_rgon() then 
            godhook.add_hook(funcname,object,ModCallbacks.MC_PRE_PLAYER_TAKE_DMG)
        end
    end,


    -- I'll take time to add a bunch of callbacks to make my mod easily manageable and expandable
    -- ["pre_scale_enemy_hp"] = true, 
    -- -- for hardmode/greedier hp scaling, before it is applied. Return float for new scale factor (1.0 = 100%)
    -- -- | pre_scale_enemy_hp(Entity ent, float scale_factor)
    -- ["post_scale_enemy_hp"] = true, -- for hardmode/greedier hp scaling, after it is applied. Takes no return values.
    -- -- | post_scale_enemy_hp(Entity ent,float scale_factor)

    -- ["alt_enemy_select"] = true, -- called when Godmode alt entries are attempting to replace an enemy. return new table for new entity, or return false to prevent replacement.
    -- -- | alt_enemy_select()
    -- ["alt_pickup_select"] = true, -- called when Godmode alt entries are attempting to replace a pickup. return new table for new entity, or return false to prevent replacement.

    -- ["get_cotv_time_rate"] = true, --how fast the timer counts down. Return the new value to decrement each tick (defaults to 1, or 0.5 on curse of the Labrynth) | get_cotv_time_rate()
    -- ["can_cotv_spawn"] = true, --can cotv spawn this frame? Return true/false to overwrite the spawning rules for COTV. | can_cotv_spawn()
    -- ["on_cotv_spawn"] = true, --called when cotv spawns. Takes no return values. (on_cotv_spawn)

    -- ["door_hazard_spawn_chance"] = true, --get the door hazard spawn chance. Return a float to override the spawn chance (1 = 100%) | door_hazard_spawn_chance(door,chance,feather_duster)
    -- ["select_door_hazard_profile"] = true, --get the hazard profile to use for this door hazard. Return a string to override to another vanilla profile, or return a table with the values. | select_door_hazard_profile(door,chance,feather_duster)
    -- ["post_door_hazard_spawn"] = true, --when the door hazard spawns. Takes no return values | post_door_hazard_spawn(door,hazard,hazard_profile)
    -- ["pre_apply_door_hazard_fx"] = true, --when a player collides with a door hazard. Return false to prevent vanilla interactions. | pre_apply_door_hazard_fx(door,hazard,hazard_profile,player)

    -- ["get_correct_room_scale"] = true, --get the scaled base stat % to use for determining correction room. Defaults to the config value specified. | get_correct_room_scale(cur_player_scale)
    -- ["on_enter_correct_room"] = true, --when a correction room is physically entered. Takes no return values. | on_enter_correct_room()
}

local function registerObject(object)
    for func,register in pairs(godhook.hook_list) do
        if object[func] ~= nil then 
            if register == true then -- custom hooks
                if is_monster(object) then 
                    GODMODE.mod_object:AddCallback(GODMODE.mod_id.."_"..func,object[func],object.type)
                else 
                    GODMODE.mod_object:AddCallback(GODMODE.mod_id.."_"..func,object[func])
                end
            else 
                register(func,object)
            end    
        end
    end
end

function godhook.register_items_and_ents()
    godhook.hook.monsters = {}
    godhook.hook.items = {}
    godhook.hook.bypass_monster_keys = {}

    for _,item in pairs(GODMODE.items) do
        registerObject(item)
        GODMODE.log("Registered "..(item.transformation == true and "playerform" or item.trinket == true and "trinket" or "item").." id \'"..tostring(item.instance).."\'!")
    end

    for _,monster in pairs(GODMODE.monsters) do
        registerObject(monster)
        GODMODE.log("Registered monster \'"..tostring(monster.type).."."..tostring(monster.variant).."\'!")
    end
end

-- nice alt version of calling the hook so that each entry can get a hand in modifying what it has, rather than getting overwritten by a later entry.
function godhook.additive_call_hook(hook,base,...)
    call_id = GODMODE.mod_id.."_"..hook
    -- Isaac.RunCallback(call_id,...)
    local hookRet = base
    local callbacks = Isaac.GetCallbacks(call_id)

    for _, callback in ipairs(callbacks) do
        local ret = callback.Function(callback.Mod,hookRet,...)
        if ret ~= nil then
            hookRet = hookRet + ret
        end
    end

    return hookRet
end

function godhook.call_hook(hook,...)
    call_id = GODMODE.mod_id.."_"..hook
    -- Isaac.RunCallback(call_id,...)
    local hookRet = nil
    local callbacks = Isaac.GetCallbacks(call_id)

    for _, callback in ipairs(callbacks) do
        local ret = callback.Function(callback.Mod,...)
        if ret ~= nil then
            hookRet = ret
        end
    end

    return hookRet
end

function godhook.call_hook_param(hook,param,...)
    -- Isaac.RunCallbackWithParam(GODMODE.mod_id.."_"..hook,param,...)

    call_id = GODMODE.mod_id.."_"..hook
    -- Isaac.RunCallback(call_id,...)
    local hookRet = nil
    local callbacks = Isaac.GetCallbacks(call_id)

    for _, callback in ipairs(callbacks) do
        local ret = callback.Function(callback.Mod,...)
        if ret ~= nil then
            hookRet = ret
        end
    end

    return hookRet
end

--in case someone somewhere decides they like my structure, you can add to it!
function godhook.register_object(object)
    for func,register in pairs(godhook.hook_list) do
        if object[func] ~= nil then
            register(func,object)
            GODMODE.log("Registered external object for function \'"..func.."\'")
        end
    end
end

return godhook