local ret = {}
ret.achievement_list = {
    fallen_light = {
        [PlayerType.PLAYER_ISAAC] = "achievement_fuzzy_dice",
        [PlayerType.PLAYER_ISAAC_B] = "achievement_chest_infest",

        [PlayerType.PLAYER_MAGDALENA] = "achievement_cloth_of_gold",
        [PlayerType.PLAYER_MAGDALENA_B] = "achievement_sugarpills",

        [PlayerType.PLAYER_CAIN] = "achievement_arcade_ticket",
        [PlayerType.PLAYER_CAIN_B] = "achievement_fractal_key",

        [PlayerType.PLAYER_JUDAS] = "achievement_burnt_diary",
        [PlayerType.PLAYER_JUDAS_B] = "achievement_devils_tongue",
        [PlayerType.PLAYER_BLACKJUDAS] = "achievement_burnt_diary",

        [PlayerType.PLAYER_XXX] = "achievement_morphine",
        [PlayerType.PLAYER_XXX_B] = "achievement_hush_hearts",

        [PlayerType.PLAYER_EVE] = "achievement_tramp",
        [PlayerType.PLAYER_EVE_B] = "achievement_tramp",

        [PlayerType.PLAYER_SAMSON] = "achievement_heart_arrest",
        [PlayerType.PLAYER_SAMSON_B] = "achievement_heart_arrest",

        [PlayerType.PLAYER_AZAZEL] = "achievement_blood_pudding",
        [PlayerType.PLAYER_AZAZEL_B] = "achievement_blood_pudding",

        [PlayerType.PLAYER_LAZARUS] = "achievement_luc_wings",
        [PlayerType.PLAYER_LAZARUS_B] = "achievement_luc_wings",
        [PlayerType.PLAYER_LAZARUS2] = "achievement_luc_wings",
        [PlayerType.PLAYER_LAZARUS2_B] = "achievement_luc_wings",

        [PlayerType.PLAYER_EDEN] = "achievement_costume_bin",
        [PlayerType.PLAYER_EDEN_B] = "achievement_costume_bin",

        [PlayerType.PLAYER_THELOST] = "achievement_late_delivery",
        [PlayerType.PLAYER_THELOST_B] = "achievement_late_delivery",

        [PlayerType.PLAYER_LILITH] = "achievement_sharing_caring",
        [PlayerType.PLAYER_LILITH_B] = "achievement_sharing_caring",

        [PlayerType.PLAYER_KEEPER] = "achievement_book_of_saints",
        [PlayerType.PLAYER_KEEPER_B] = "achievement_book_of_saints",

        [PlayerType.PLAYER_APOLLYON] = "achievement_anguish_jar",
        [PlayerType.PLAYER_APOLLYON_B] = "achievement_anguish_jar",

        [PlayerType.PLAYER_THEFORGOTTEN] = "achievement_crossbones",
        [PlayerType.PLAYER_THESOUL] = "achievement_crossbones",

        [PlayerType.PLAYER_THEFORGOTTEN_B] = "achievement_crossbones",
        [PlayerType.PLAYER_THESOUL_B] = "achievement_crossbones",

        [PlayerType.PLAYER_BETHANY] = "achievement_orb_of_radience",
        [PlayerType.PLAYER_BETHANY_B] = "achievement_orb_of_radience",

        [PlayerType.PLAYER_JACOB] = "achievement_marsh_scarf",
        [PlayerType.PLAYER_JACOB_B] = "achievement_marsh_scarf",
        [PlayerType.PLAYER_JACOB2_B] = "achievement_marsh_scarf",
        [PlayerType.PLAYER_ESAU] = "achievement_marsh_scarf",

        [GODMODE.registry.players.recluse] = "achievement_chiggers",
        [GODMODE.registry.players.t_recluse] = "achievement_fruit_fly",

        [GODMODE.registry.players.xaphan] = "achievement_adra_blessing",
        [GODMODE.registry.players.t_xaphan] = "achievement_fatal_attraction",

        [GODMODE.registry.players.elohim] = "achievement_holy_chalice",
        [GODMODE.registry.players.t_elohim] = "achievement_divine_wrath",

        [GODMODE.registry.players.deli] = "achievement_papal_cross",
        [GODMODE.registry.players.t_deli] = "achievement_hysteria",

        [GODMODE.registry.players.gehazi] = "achievement_crown_of_gold",
        [GODMODE.registry.players.t_gehazi] = "achievement_greedy_glance",

        [GODMODE.registry.players.the_sign] = "achievement_opia",
        -- [Isaac.GetPlayerTypeByName("The Sign",true)] = "achievement_opia",
    },
    sign_achievement_prefix = "achievement_sign"
}

ret.item_map = {
    --base unlocks from fallen light
    [GODMODE.registry.items.fuzzy_dice] = "achievement_fuzzy_dice",
    [GODMODE.registry.items.cloth_of_gold] = "achievement_cloth_of_gold",
    [GODMODE.registry.items.arcade_ticket] = "achievement_arcade_ticket",
    [GODMODE.registry.items.burnt_diary] = "achievement_burnt_diary",
    [GODMODE.registry.items.morphine] = "achievement_morphine",
    [GODMODE.registry.items.tramp_of_babylon] = "achievement_tramp",
    [GODMODE.registry.items.heart_arrest] = "achievement_heart_arrest",
    [GODMODE.registry.items.blood_pudding] = "achievement_blood_pudding",
    [GODMODE.registry.items.wings_of_betrayal] = "achievement_luc_wings",
    [GODMODE.registry.items.late_delivery] = "achievement_late_delivery",
    [GODMODE.registry.items.sharing_is_caring] = "achievement_sharing_caring",
    [GODMODE.registry.items.book_of_saints] = "achievement_book_of_saints",
    [GODMODE.registry.items.anguish_jar] = "achievement_anguish_jar",
    [GODMODE.registry.items.crossbones] = "achievement_crossbones",
    [GODMODE.registry.items.orb_of_radiance] = "achievement_orb_of_radience",
    [GODMODE.registry.items.marshall_scarf] = "achievement_marsh_scarf",
    [GODMODE.registry.items.jack_of_all_trades] = "achievement_costume_bin",

    --tainted unlocks from fallen light
    [GODMODE.registry.items.fractal_key] = "achievement_fractal_key",

    --godmode unlocks
    [GODMODE.registry.items.larval_therapy] = "achievement_chiggers",
    [GODMODE.registry.items.adramolechs_blessing] = "achievement_adra_blessing",
    [GODMODE.registry.items.holy_chalice] = "achievement_holy_chalice",
    [GODMODE.registry.items.papal_cross_unholy] = "achievement_papal_cross",
    [GODMODE.registry.items.papal_cross_holy] = "achievement_papal_cross",
    [GODMODE.registry.items.crown_of_gold] = "achievement_crown_of_gold",
    [GODMODE.registry.items.opia] = "achievement_opia",

    --tainted godmode unlocks
    [GODMODE.registry.items.fruit_flies] = "achievement_fruit_fly",
    [GODMODE.registry.items.fatal_attraction] = "achievement_fatal_attraction",
    [GODMODE.registry.items.divine_wrath] = "achievement_divine_wrath",
    [GODMODE.registry.items.hysteria] = "achievement_hysteria",
    [GODMODE.registry.items.greedy_glance] = "achievement_greedy_glance",

    --misc unlocks
    [GODMODE.registry.items.impending_doom] = "achievement_calendar",
    [GODMODE.registry.items.vajra] = "achievement_vajra",
    [GODMODE.registry.items.prayer_mat] = "achievement_prayer_mat",

    --challenge unlocks
    [GODMODE.registry.items.sugar] = "achievement_sugar",

    [GODMODE.registry.items.celestial_paw] = "achievement_celestial",
    [GODMODE.registry.items.celestial_tail] = "achievement_celestial",
    [GODMODE.registry.items.celestial_collar] = "achievement_celestial",

    [GODMODE.registry.items.a_second_thought] = "achievement_secondthought",
}

-- for repentogon
ret.character_map = {
    [GODMODE.registry.players.t_recluse] = "achievement_trecluse",
    [GODMODE.registry.players.t_xaphan] = "achievement_txaphan",
    [GODMODE.registry.players.t_deli] = "achievement_tdeli",
    [GODMODE.registry.players.t_elohim] = "achievement_telohim",
    [GODMODE.registry.players.t_gehazi] = "achievement_tgehazi",
    -- [GODMODE.registry.players.t_sign] = "achievement_tsign"
}

ret.get_unlock_at_index = function(index)
    if ret.cached_unlock_list == nil then 
        local ind = 1
        ret.cached_unlock_list = {}

        for item,_ in pairs(ret.item_map) do 
            ret.cached_unlock_list[ind] = item 
            ind = ind + 1    
        end
    end

    return ret.cached_unlock_list[index]
end

ret.get_splash_for = function(item) 
    return ret.item_map[item]
end

ret.is_achievement_unlocked = function(achievement,bypass_unlock_bypass)
    return GODMODE.save_manager.get_config("Unlocks", "true") == "false" and (bypass_unlock_bypass ~= true) 
        or GODMODE.save_manager.get_persistant_data("Unlock."..achievement, "false") == "true"
end

ret.is_item_unlocked = function(item,bypass_unlock_bypass)
    return not ret.item_map[item] or ret.is_achievement_unlocked(ret.item_map[item],bypass_unlock_bypass)
end

ret.unlock_item = function(item)
    local name = ret.item_map[item]

    if name ~= nil and GODMODE.save_manager.get_persistant_data("Unlock."..name,"false") == "false" then
        if not GODMODE.validate_rgon() then 
            ret.play_splash(name)
        end

        GODMODE.save_manager.set_persistant_data("Unlock."..name, "true")
    end

    if GODMODE.validate_rgon() then 
        local name = ret.item_map_repentogon[item]

        if name ~= nil then 
            Isaac.GetPersistentGameData():TryUnlock(name)
        end
    end
end

ret.play_splash = function(name,speed)
    if Options.DisplayPopups then 
        ret.achievement_queue = ret.achievement_queue or {}
        table.insert(ret.achievement_queue, {name=name,speed=speed or 1.0})
    end
end

ret.update = function()
    local queue = ret.achievement_queue
    if not GODMODE.is_animating() and queue ~= nil and #queue > 0 then
        if GODMODE.sprites.unlock_sprite == nil then 
            GODMODE.sprites.unlock_sprite = Sprite()
            GODMODE.sprites.unlock_sprite:Load("gfx/achievements/achievements.anm2", true)
            GODMODE.log("Loaded achievement splash sprite!")
        end

        GODMODE.sprites.unlock_sprite:ReplaceSpritesheet(3,"gfx/achievements/"..ret.achievement_queue[1].name..".png")
        GODMODE.sprites.unlock_sprite:LoadGraphics()
        GODMODE.sprites.unlock_sprite:Play("Scene",true)
        GODMODE.cur_splash = GODMODE.sprites.unlock_sprite 
        GODMODE.cur_splash_pos = GODMODE.util.get_center_of_screen()/2
        GODMODE.cur_splash.PlaybackSpeed = ret.achievement_queue[1].speed
        table.remove(ret.achievement_queue,1)
    end
end

ret.unlock_fallen_light = function(player)
    local name = ret.achievement_list.fallen_light[player.SubType]
    GODMODE.save_manager.set_persistant_data("FallenLightKilled."..player:GetName(), (GODMODE.game.Difficulty % 2) + 1)

    if name ~= nil and GODMODE.save_manager.get_persistant_data("Unlock."..name,"false") == "false" then
        if not GODMODE.validate_rgon() then 
            ret.play_splash(name)
        end

        GODMODE.save_manager.set_persistant_data("Unlock."..name, "true", true)
    end

    if GODMODE.validate_rgon() then 
        name = ret.achievement_list_repentogon.fallen_light[player.SubType]

        if name ~= nil then 
            Isaac.GetPersistentGameData():TryUnlock(name)
        end
    end
end

ret.kill_sign = function(player)
    GODMODE.save_manager.set_persistant_data("TheSignKilled."..player:GetName(), (GODMODE.game.Difficulty % 2) + 1)
end

ret.unlock_sign_buff = function()
    if GODMODE.validate_rgon() and not Isaac.GetPersistentGameData():Unlocked(GODMODE.registry.achievements.the_sign) then 
        Isaac.GetPersistentGameData():TryUnlock(GODMODE.registry.achievements.the_sign)        
    else
        
        local kills = tonumber(GODMODE.save_manager.get_persistant_data("PalaceKills","0"))
        GODMODE.save_manager.set_persistant_data("PalaceKills", math.min(5,kills + 1))

        if kills+1 < 5 then
            if GODMODE.validate_rgon() then 
                Isaac.GetPersistentGameData():TryUnlock(GODMODE.registry.achievements["thesign"..kills])
            else 
                ret.play_splash(sign_achievement_prefix..kills+1)
            end
        elseif kills+1 == 5 then
            if GODMODE.validate_rgon() then 
                Isaac.GetPersistentGameData():TryUnlock(GODMODE.registry.achievements.thesign_complete)
            else 
                ret.play_splash("achievement_signcomplete")
            end
    
            GODMODE.save_manager.set_persistant_data("PalaceComplete", "true")
        end    
    end


    GODMODE.save_manager.save()
end


if GODMODE.validate_rgon() then 
    ret.achievement_list_repentogon = {
        fallen_light = {
            [PlayerType.PLAYER_ISAAC] = GODMODE.registry.achievements.fl_isaac,
            [PlayerType.PLAYER_ISAAC_B] = GODMODE.registry.achievements.fl_tisaac,
    
            [PlayerType.PLAYER_MAGDALENA] = GODMODE.registry.achievements.fl_maggy,
            [PlayerType.PLAYER_MAGDALENA_B] = GODMODE.registry.achievements.fl_tmaggy,
    
            [PlayerType.PLAYER_CAIN] = GODMODE.registry.achievements.fl_cain,
            [PlayerType.PLAYER_CAIN_B] = GODMODE.registry.achievements.fl_tcain,
    
            [PlayerType.PLAYER_JUDAS] = GODMODE.registry.achievements.fl_judas,
            [PlayerType.PLAYER_JUDAS_B] = GODMODE.registry.achievements.fl_judas,
            [PlayerType.PLAYER_BLACKJUDAS] = GODMODE.registry.achievements.fl_judas,
    
            [PlayerType.PLAYER_XXX] = GODMODE.registry.achievements.fl_xxx,
            [PlayerType.PLAYER_XXX_B] = GODMODE.registry.achievements.fl_xxx,
    
            [PlayerType.PLAYER_EVE] = GODMODE.registry.achievements.fl_eve,
            [PlayerType.PLAYER_EVE_B] = GODMODE.registry.achievements.fl_eve,
    
            [PlayerType.PLAYER_SAMSON] = GODMODE.registry.achievements.fl_samson,
            [PlayerType.PLAYER_SAMSON_B] = GODMODE.registry.achievements.fl_samson,
    
            [PlayerType.PLAYER_AZAZEL] = GODMODE.registry.achievements.fl_azazel,
            [PlayerType.PLAYER_AZAZEL_B] = GODMODE.registry.achievements.fl_azazel,
    
            [PlayerType.PLAYER_LAZARUS] = GODMODE.registry.achievements.fl_lazarus,
            [PlayerType.PLAYER_LAZARUS_B] = GODMODE.registry.achievements.fl_lazarus,
            [PlayerType.PLAYER_LAZARUS2] = GODMODE.registry.achievements.fl_lazarus,
            [PlayerType.PLAYER_LAZARUS2_B] = GODMODE.registry.achievements.fl_lazarus,
    
            [PlayerType.PLAYER_EDEN] = GODMODE.registry.achievements.fl_eden,
            [PlayerType.PLAYER_EDEN_B] = GODMODE.registry.achievements.fl_eden,
    
            [PlayerType.PLAYER_THELOST] = GODMODE.registry.achievements.fl_thelost,
            [PlayerType.PLAYER_THELOST_B] = GODMODE.registry.achievements.fl_thelost,
    
            [PlayerType.PLAYER_LILITH] = GODMODE.registry.achievements.fl_lilith,
            [PlayerType.PLAYER_LILITH_B] = GODMODE.registry.achievements.fl_lilith,
    
            [PlayerType.PLAYER_KEEPER] = GODMODE.registry.achievements.fl_keeper,
            [PlayerType.PLAYER_KEEPER_B] = GODMODE.registry.achievements.fl_keeper,
    
            [PlayerType.PLAYER_APOLLYON] = GODMODE.registry.achievements.fl_apollyon,
            [PlayerType.PLAYER_APOLLYON_B] = GODMODE.registry.achievements.fl_apollyon,
    
            [PlayerType.PLAYER_THEFORGOTTEN] = GODMODE.registry.achievements.fl_forgotten,
            [PlayerType.PLAYER_THESOUL] = GODMODE.registry.achievements.fl_forgotten,
    
            [PlayerType.PLAYER_THEFORGOTTEN_B] = GODMODE.registry.achievements.fl_forgotten,
            [PlayerType.PLAYER_THESOUL_B] = GODMODE.registry.achievements.fl_forgotten,
    
            [PlayerType.PLAYER_BETHANY] = GODMODE.registry.achievements.fl_bethany,
            [PlayerType.PLAYER_BETHANY_B] = GODMODE.registry.achievements.fl_bethany,
    
            [PlayerType.PLAYER_JACOB] = GODMODE.registry.achievements.fl_jacobesau,
            [PlayerType.PLAYER_JACOB_B] = GODMODE.registry.achievements.fl_jacobesau,
            [PlayerType.PLAYER_JACOB2_B] = GODMODE.registry.achievements.fl_jacobesau,
            [PlayerType.PLAYER_ESAU] = GODMODE.registry.achievements.fl_jacobesau,
    
            [GODMODE.registry.players.recluse] = GODMODE.registry.achievements.fl_recluse,
            [GODMODE.registry.players.t_recluse] = GODMODE.registry.achievements.fl_trecluse,
    
            [GODMODE.registry.players.xaphan] = GODMODE.registry.achievements.fl_xaphan,
            [GODMODE.registry.players.t_xaphan] = GODMODE.registry.achievements.fl_txaphan,
    
            [GODMODE.registry.players.elohim] = GODMODE.registry.achievements.fl_elohim,
            [GODMODE.registry.players.t_elohim] = GODMODE.registry.achievements.fl_telohim,
    
            [GODMODE.registry.players.deli] = GODMODE.registry.achievements.fl_deli,
            [GODMODE.registry.players.t_deli] = GODMODE.registry.achievements.fl_tdeli,
    
            [GODMODE.registry.players.gehazi] = GODMODE.registry.achievements.fl_gehazi,
            [GODMODE.registry.players.t_gehazi] = GODMODE.registry.achievements.fl_tgehazi,
    
            [GODMODE.registry.players.the_sign] = GODMODE.registry.achievements.fl_thesign,
            -- [Isaac.GetPlayerTypeByName("The Sign",true)] = "achievement_opia",
        },
        sign_achievement_prefix = "achievement_sign"
    }

    ret.item_map_repentogon = {
        --base unlocks
        [GODMODE.registry.items.fuzzy_dice] = GODMODE.registry.achievements.fl_isaac,
        [GODMODE.registry.items.cloth_of_gold] = GODMODE.registry.achievements.fl_maggy,
        [GODMODE.registry.items.cloth_on_a_string] = GODMODE.registry.achievements.fl_maggy,
        [GODMODE.registry.items.arcade_ticket] = GODMODE.registry.achievements.fl_cain,
        [GODMODE.registry.items.fractal_key] = GODMODE.registry.achievements.fl_tcain,
        [GODMODE.registry.items.fractal_key_inverse] = GODMODE.registry.achievements.fl_tcain,
        [GODMODE.registry.items.burnt_diary] = GODMODE.registry.achievements.fl_judas,
        [GODMODE.registry.items.morphine] = GODMODE.registry.achievements.fl_xxx,
        [GODMODE.registry.items.tramp_of_babylon] = GODMODE.registry.achievements.fl_eve,
        [GODMODE.registry.items.heart_arrest] = GODMODE.registry.achievements.fl_samson,
        [GODMODE.registry.items.blood_pudding] = GODMODE.registry.achievements.fl_azazel,
        [GODMODE.registry.items.wings_of_betrayal] = GODMODE.registry.achievements.fl_lazarus,
        [GODMODE.registry.items.late_delivery] = GODMODE.registry.achievements.fl_thelost,
        [GODMODE.registry.items.sharing_is_caring] = GODMODE.registry.achievements.fl_lilith,
        [GODMODE.registry.items.book_of_saints] = GODMODE.registry.achievements.fl_keeper,
        [GODMODE.registry.items.anguish_jar] = GODMODE.registry.achievements.fl_apollyon,
        [GODMODE.registry.items.crossbones] = GODMODE.registry.achievements.fl_forgotten,
        [GODMODE.registry.items.orb_of_radiance] = GODMODE.registry.achievements.fl_bethany,
        [GODMODE.registry.items.marshall_scarf] = GODMODE.registry.achievements.fl_jacobesau,
        [GODMODE.registry.items.jack_of_all_trades] = GODMODE.registry.achievements.fl_eden,
    
        --godmode unlocks
        [GODMODE.registry.items.larval_therapy] = GODMODE.registry.achievements.fl_recluse,
        [GODMODE.registry.items.adramolechs_blessing] = GODMODE.registry.achievements.fl_xaphan,
        [GODMODE.registry.items.holy_chalice] = GODMODE.registry.achievements.fl_elohim,
        [GODMODE.registry.items.papal_cross_unholy] = GODMODE.registry.achievements.fl_deli,
        [GODMODE.registry.items.papal_cross_holy] = GODMODE.registry.achievements.fl_deli,
        [GODMODE.registry.items.crown_of_gold] = GODMODE.registry.achievements.fl_gehazi,
        [GODMODE.registry.items.opia] = GODMODE.registry.achievements.fl_thesign,
    
        --tainted godmode unlocks
        [GODMODE.registry.items.fruit_flies] = GODMODE.registry.achievements.fl_trecluse,
        [GODMODE.registry.items.fatal_attraction] = GODMODE.registry.achievements.fl_txaphan,
        [GODMODE.registry.items.divine_wrath] = GODMODE.registry.achievements.fl_telohim,
        [GODMODE.registry.items.hysteria] = GODMODE.registry.achievements.fl_tdeli,
        [GODMODE.registry.items.greedy_glance] = GODMODE.registry.achievements.fl_tgehazi,
    
        --misc unlocks
        [GODMODE.registry.items.impending_doom] = GODMODE.registry.achievements.impending_doom,
        [GODMODE.registry.items.vajra] = GODMODE.registry.achievements.vajra,
        [GODMODE.registry.items.prayer_mat] = GODMODE.registry.achievements.prayer_mat,
    
        --challenge unlocks
        [GODMODE.registry.items.sugar] = GODMODE.registry.achievements.sugar_rush,
    
        [GODMODE.registry.items.celestial_paw] = GODMODE.registry.achievements.celestial_approach,
        [GODMODE.registry.items.celestial_tail] = GODMODE.registry.achievements.celestial_approach,
        [GODMODE.registry.items.celestial_collar] = GODMODE.registry.achievements.celestial_approach,
    
        [GODMODE.registry.items.a_second_thought] = GODMODE.registry.achievements.out_of_time,
    }

    ret.char_map = {
        [GODMODE.registry.players.t_recluse] = GODMODE.registry.achievements.t_recluse,
        [GODMODE.registry.players.recluse] = GODMODE.registry.achievements.t_recluse,
        [GODMODE.registry.players.t_xaphan] = GODMODE.registry.achievements.t_xaphan,
        [GODMODE.registry.players.xaphan] = GODMODE.registry.achievements.t_xaphan,
        [GODMODE.registry.players.t_deli] = GODMODE.registry.achievements.t_deli,
        [GODMODE.registry.players.deli] = GODMODE.registry.achievements.t_deli,
        [GODMODE.registry.players.t_elohim] = GODMODE.registry.achievements.t_elohim,
        [GODMODE.registry.players.elohim] = GODMODE.registry.achievements.t_elohim,
        [GODMODE.registry.players.t_gehazi] = GODMODE.registry.achievements.t_gehazi,
    }

    ret.sync_repentogon_with_godmode = function()
        if not GODMODE.save_manager.has_loaded then 
            GODMODE.log("Save manager is not loaded yet, not syncing Repentogon with Godmode...",true)
        else 
            for key,val in pairs(ret.item_map) do 
                if ret.is_achievement_unlocked(val) then 
                    if not ret.item_map_repentogon[key] or ret.item_map_repentogon[key] == -1 then 
                        GODMODE.log("[ERROR]: Invalid achievement key/val pair \'"..key.."\'/\'"..val.."\' mapped to \'"..tostring(ret.item_map_repentogon[key]).."\'",true) 
                    elseif Isaac.GetPersistentGameData():TryUnlock(ret.item_map_repentogon[key]) then 
                        GODMODE.log("Synced achievement \'"..val.."\' from Godmode achievements to Repentogon!")
                    end
                end
            end
    
            if Isaac.GetPersistentGameData():Unlocked(Achievement and Achievement.LIL_DELIRIUM or 357) then 
                Isaac.GetPersistentGameData():TryUnlock(GODMODE.registry.achievements.deli)
            end
    
            if Isaac.GetPersistentGameData():IsItemInCollection(CollectibleType.COLLECTIBLE_REDEMPTION) then 
                Isaac.GetPersistentGameData():TryUnlock(GODMODE.registry.achievements.elohim)
            end
    
            local clears = tonumber(GODMODE.save_manager.get_persistant_data("PalaceKills","0"))
            local complete = (clears >= 5) and true or GODMODE.save_manager.get_persistant_data("PalaceComplete","false") == "true"
    
            for i=0,clears do 
                if GODMODE.registry.achievements["thesign"..i] then 
                    Isaac.GetPersistentGameData():TryUnlock(GODMODE.registry.achievements["thesign"..i])
                end
            end
    
            if complete then 
                Isaac.GetPersistentGameData():TryUnlock(GODMODE.registry.achievements.thesign_complete)
            end    
        end
    end

    ret.unlock_character = function(char)
        if ret.char_map[char] then 
            Isaac.GetPersistentGameData():TryUnlock(ret.char_map[char])
        end
    end
end

return ret