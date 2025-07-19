
-- creates the Godmode api for other mods to hook into! 
-- To access, replace "god_api" with GODMODE.api (i.e. GODMODE.api.set_cotv_charges(1,0))

local god_api = {}

-- adds a new stat to the stat score system for Correction Rooms. 
-- stat_name: string stat identifier
-- stat_max: float maximum stat value
-- stat_calc_func: function to get the current stat value (this value is automatically clamped to stat_max if it is higher than it)
god_api.add_stat_to_score = function(stat_name, stat_max, stat_calc_func)
    stat_calc_func = stat_calc_func == nil and function(player) return 0 end or stat_calc_func
    GODMODE.util.stat_dist[stat_name] = stat_max or 0
    -- this requires patching into the correction shrine code if you want to add another "buffable" stat inside the correction room.
    GODMODE.util.stat_buff[stat_name] = false
    GODMODE.util.stat_scale[stat_name] = function(player) return math.min(stat_max, stat_calc_func(player)) end
end

-- adds a new tearflag to the tearflag stat score. 
-- tearflag: custom TearFlag
-- add_val: function. Check for and return the statscore modifier for your custom tearflag. The max value for the tearflag stat score is 12, so keep that in mind.
-- examples of basegame values:
--[[
	TearFlags.TEAR_SPECTRAL = 0.3,
	TearFlags.TEAR_PIERCING = 0.4,
	TearFlags.TEAR_HOMING = 0.5,
	TearFlags.TEAR_SLOW = 0.1,
]] 
god_api.add_tearflag_to_statscore = function(tearflag, add_val)
    GODMODE.util.tearflag_mods[tearflag] = add_val or function(player) return 0 end
end

-- adds a new transformation to the transformation stat score. 
-- transform: string. transformation name
-- add_val: function. Check for and return the statscore modifier for your custom transformation. The max value for the transformation stat score is 12, so keep that in mind.
-- examples of basegame values:
--[[
	PlayerForm.PLAYERFORM_GUPPY = 2.5,
	PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES = 2.0,
	PlayerForm.PLAYERFORM_MUSHROOM = 0.1,
	PlayerForm.PLAYERFORM_ANGEL = 0.75,
]] 
god_api.add_transform_to_statscore = function(transform, add_val)
    GODMODE.util.transform_mods[transform] = add_val or function(player) return 0 end
end

-- sets the faithless heart and damage charges for Call of the Void. Damage charges are gained from the door hazard, faithless hearts are gained from passing the time limit.
-- faithless: int. The number of faithless heart charges active
-- damaging: int. The number of damaging charges active
god_api.set_cotv_charges = function(faithless, damaging)
    GODMODE.save_manager.set_data("VoidBHProj",faithless)
    GODMODE.save_manager.set_data("VoidDMProj",damaging,true)
end

-- gets the current number of charges active for Call of the Void, with the faithless parameter dictating whether you're getting the faithless heart charges or the damaging charges.
-- faithless: boolean. True to get the # of faithless charges, false to get the # of damaging charges
god_api.get_cotv_charges = function(faithless)
    faithless = faithless == nil and true or faithless 
    return faithless and tonumber(GODMODE.save_manager.get_data("VoidBHProj","0")) or tonumber(GODMODE.save_manager.get_data("VoidDMProj","0"))
end

-- registers a custom file to the godmode godhook system.
-- file: include() file. This should return an object with the godmode functions, ideally just copy paste an existing item/monster and use that for a reference.
-- note that for entities and items you need specific variables in your returned userdata:
-- entities: type (int), variant (int)
-- items: instance (int)
-- these should just be set to Isaac.GetXByName() or your existing registry 
god_api.add_to_godhooks = function(file)
    GODMODE.godhooks.register_object(file)
end

-- creates a new observatory in the stage.
-- returns the RoomDescriptor if the room was generated succesfully, false if it was not.
god_api.generate_observatory = function()
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
god_api.set_observatory = function(safegrididx, observatory)
    safegrididx = safegrididx == nil and GODMODE.level:GetCurrentRoomDesc().SafeGridIndex or safegrididx
    observatory = observatory == nil and true or observatory 

    if observatory then 
        GODMODE.save_manager.add_list_data("ObservatoryGridIdx",safegrididx,true)
    else
        GODMODE.save_manager.remove_list_data("ObservatoryGridIdx",safegrididx,true)
    end
    
    GODMODE.cached_observatory_ids = nil 
    GODMODE.observatory_door_cache = nil
end

-- checks whether the specified room is an observatory.
-- safegrididx: int. This should just be the roomdescriptor's SafeGridIndex. Defaults to the current room's safe grid index.
god_api.is_observatory = function(safegrididx)
    safegrididx = safegrididx == nil and GODMODE.level:GetCurrentRoomDesc().SafeGridIndex or safegrididx
    return GODMODE.save_manager.list_contains("ObservatoryGridIdx",nil,function(ele) return roomdesc and tonumber(ele) == roomdesc.SafeGridIndex end)
end

-- blanket converts all existing collectibles and shop items into items from the varying Observatory pools when called. This is called on the first entry of a vanilla Observatory.
-- make_choose: boolean. True to make all converted observatory rewards share an OptionsPickupIndex
god_api.create_observatory_loot = function(make_choose)
    make_choose = make_choose or true 
    local index = -1
    GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_PICKUP,nil,nil,function(pickup) 
        local rng = pickup:GetDropRNG()
        local outcome = rng:RandomFloat()
        local reward = {}

        if pickup:ToPickup().Price > 0 then 
            if outcome <= 0.125 then 
                local item = GODMODE.itempools.get_from_pool("observatory_souls",rng,false)
                reward = {pickup.Type,PickupVariant.PICKUP_TAROTCARD,item}
            elseif outcome <= 0.25 then 
                local item = GODMODE.itempools.get_from_pool("observatory_tarots",rng,false)
                reward = {pickup.Type,PickupVariant.PICKUP_TAROTCARD,item}
            else 
                local item = GODMODE.itempools.get_from_pool("observatory",rng,false)
                reward = {pickup.Type,PickupVariant.PICKUP_TRINKET,item}
            end
        elseif pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and not GODMODE.itempools.is_in_pool("observatory_items",subtype) then 
            if outcome <= 0.5 then 
                local item = GODMODE.itempools.get_from_pool("observatory",rng,false)
                reward = {pickup.Type,PickupVariant.PICKUP_TRINKET,item}
            else 
                local item = GODMODE.itempools.get_from_pool("observatory_items",rng,false)
                reward = {pickup.Type,pickup.Variant,item}
            end
        end

        if #reward > 0 then 
            pickup:ToPickup():Morph(reward[1],reward[2],reward[3])
        end

        -- apply the choice here
        if (GODMODE.itempools.is_in_pool("observatory",pickup.SubType) or GODMODE.itempools.is_in_pool("observatory_items",pickup.SubType)
        or GODMODE.itempools.is_in_pool("observatory_tarots",pickup.SubType) or GODMODE.itempools.is_in_pool("observatory_souls",pickup.SubType)) and make_choose == true then 
            index = (index == -1 and GODMODE.util.get_options_index(pickup) or index)
            pickup:ToPickup().OptionsPickupIndex = index
        end
    end)    
end

-- adds a new pickup variant that chest infestors are allowed to manifest from.
-- pickup_variant: int. This should be a valid pickup variant "5.pickup_variant"
-- mimic_data: userdata. This holds all of the metadata for the chest infestor's manifestation of the pickup. An example is included for the default value.
god_api.add_chest_infest_variant = function(pickup_variant, mimic_data)
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

        -- called when the "PreAttack" animation event is triggered. Mostly useful for SFX, as this is the telegraph for the attack. 
        -- "ent" is the chest infestor, "data" is the non-persistent Godmode data table, "sprite" is a reference to ent:GetSprite()
        -- preattack=function(ent,data,sprite) end,

        -- called when the "Attack" animation event is triggered, main attack here. 
        -- if unlock=true then the chest opens here via chest infestor 
        -- "ent" is the chest infestor, "data" is the non-persistent Godmode data table, "sprite" is a reference to ent:GetSprite()
        -- attack=function(ent,data,sprite) 
                -- data.fire_ring = function(self,ent,count,spd,ang_offset,scale,flags)
                -- data.launch_ring = function(self,ent,count,spd,ang_offset,scale,flags)
                -- data.launch_bullet = function(self,ent,pos,scale,flags)
                -- data.fire_bullet = function(self,ent,ang,spd,scale,flags)
        --
        --     data:fire_ring(ent,10,7.5+(GODMODE.game.Difficulty % 2) * 2,ent:GetDropRNG():RandomFloat() * 36.0,1.25,ProjectileFlags.DECELERATE)
        -- end, 

        -- -- called each tick when the chest is infested. 
        -- "ent" is the chest infestor, "data" is the non-persistent Godmode data table, "sprite" is a reference to ent:GetSprite()
        -- atk_update = function(ent,data,sprite) end,
        
        -- -- called to add additional checks when trying to spawn a chest infestor for this pickup variant.
        -- can_spawn = function(pickup) return true end
    }
end

-- registers a playertype to hide Godmode heart UI for. In vanilla, just PLAYER_THEFORGOTTEN_B, PLAYER_THELOST, and PLAYER_THELOST_B
-- playertype: PlayerType. the numeric playertype for the player in question.
-- hidden: boolean. Whether to hide the UI or not, if not specified this function toggles the current state of the playertype.
god_api.add_player_to_ui_blacklist = function(playertype, hidden)
    GODMODE.registry.hidden_heart_players[playertype] = hidden or not GODMODE.registry.hidden_heart_players[playertype]
end

-- retrieves the run's current gilded chance (value range 0 - 1)
god_api.get_gilded_chance = function()
    return tonumber(GODMODE.save_manager.get_data("GildedChance","0.0"))
end

-- set the run's current gilded chance (value range 0 - 1)
god_api.set_gilded_chance = function(amt)
    amt = amt == nil and god_api.get_gilded_chance(player) or amt 
    GODMODE.save_manager.set_data("GildedChance",math.max(0,math.min(1,amt)),true)
end

-- add to the run's current gilded chance (value range 0 - 1)
god_api.add_gilded_chance = function(amt)
    god_api.set_gilded_chance(god_api.get_gilded_chance() + amt)
end

-- returns the current chance to convert a pickup to its golden variant based on the current gilded chance. (value range 0 - 1)
god_api.get_gilded_convert_chance = function()
    return GODMODE.util.get_gilded_chance(god_api.get_gilded_chance())
end

-- check if any, or a specific, tutorial(s) are active currently.
-- tutorial_id: string/GODMODE.tutorials.list key. Leave nil to check for *any* active tutorials.
god_api.is_tutorial_active = function(tutorial_id)
    if tutorial_id == nil then 
        return #(GODMODE.tutorials.active_id_queue or {}) > 0
    elseif GODMODE.tutorials.list[tutorial_id] then 
        for _,dat in ipairs(GODMODE.tutorials.active_id_queue) do 
            if dat.id == tutorial_id then 
                return true 
            end
        end

        return false 
    end
end

-- activates a tutorial with the given tutorial ID.
-- tutorial_id: string/GODMODE.tutorials.list key. 
-- args: an array {} of parameters the tutorial requires. This changes per-tutorial, but usually is just an array with a player reference {Isaac.GetPlayer()}
god_api.activate_tutorial = function(tutorial_id, args)
    if GODMODE.tutorials.list[tutorial_id] then 
        GODMODE.tutorials.activate_tutorial(tutorial_id, args)
    else
        GODMODE.log("[API/ERROR] Tutorial ID \'"..tutorial_id.."\' does not exist, cannot activate.")
    end
end

-- returns the current number of Faithless hearts the player has.
-- player: EntityPlayer obj. 
-- returns: # of faithless hearts (int, 0-12)
god_api.get_faithless_hearts = function(player)
    return GODMODE.util.get_faithless(player)
end

-- adds to the current number of faithless hearts the player has.
-- player: EntityPlayer obj.
-- amount: integer (0-12)
god_api.add_faithless_hearts = function(player, amount)
    GODMODE.util.add_faithless(player, amount)
end

-- sets the current number of faithless hearts the player has.
-- player: EntityPlayer obj.
-- amount: integer (0-12)
god_api.set_faithless_hearts = function(player, amount)
    god_api.add_faithless(player, amount - god_api.get_faithless_hearts(player))
end


return god_api