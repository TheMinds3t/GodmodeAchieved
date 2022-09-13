local ret = {}
ret.achievement_list = {
    fallen_light = {
        [PlayerType.PLAYER_ISAAC] = "achievement_fuzzy_dice",
        [PlayerType.PLAYER_ISAAC_B] = "achievement_fuzzy_dice",

        [PlayerType.PLAYER_MAGDALENA] = "achievement_cloth_of_gold",
        [PlayerType.PLAYER_MAGDALENA_B] = "achievement_cloth_of_gold",

        [PlayerType.PLAYER_CAIN] = "achievement_arcade_ticket",
        [PlayerType.PLAYER_CAIN_B] = "achievement_arcade_ticket",

        [PlayerType.PLAYER_JUDAS] = "achievement_burnt_diary",
        [PlayerType.PLAYER_JUDAS_B] = "achievement_burnt_diary",
        [PlayerType.PLAYER_BLACKJUDAS] = "achievement_burnt_diary",

        [PlayerType.PLAYER_XXX] = "achievement_morphine",
        [PlayerType.PLAYER_XXX_B] = "achievement_morphine",

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

        [Isaac.GetPlayerTypeByName("Recluse",false)] = "achievement_chiggers",
        [Isaac.GetPlayerTypeByName("Recluse",true)] = "achievement_fruit_fly",

        [Isaac.GetPlayerTypeByName("Xaphan",false)] = "achievement_adra_blessing",
        [Isaac.GetPlayerTypeByName("Xaphan",true)] = "achievement_fatal_attraction",

        [Isaac.GetPlayerTypeByName("Elohim",false)] = "achievement_holy_chalice",
        [Isaac.GetPlayerTypeByName("Elohim",true)] = "achievement_holy_chalice",

        [Isaac.GetPlayerTypeByName("Deli",false)] = "achievement_papal_cross",
        [Isaac.GetPlayerTypeByName("Deli",true)] = "achievement_papal_cross",

        [Isaac.GetPlayerTypeByName("Gehazi",false)] = "achievement_crown_of_gold",
        [Isaac.GetPlayerTypeByName("Gehazi",true)] = "achievement_crown_of_gold",

        [Isaac.GetPlayerTypeByName("The Sign",false)] = "achievement_opia",
        [Isaac.GetPlayerTypeByName("The Sign",true)] = "achievement_opia",
    },
    sign_achievement_prefix = "achievement_sign"
}

ret.item_map = {
    [Isaac.GetItemIdByName("Fuzzy Dice")] = "achievement_fuzzy_dice",
    [Isaac.GetItemIdByName("Cloth of Gold")] = "achievement_cloth_of_gold",
    [Isaac.GetItemIdByName("Arcade Ticket")] = "achievement_arcade_ticket",
    [Isaac.GetItemIdByName("Burnt Diary")] = "achievement_burnt_diary",
    [Isaac.GetItemIdByName("Morphine")] = "achievement_morphine",
    [Isaac.GetItemIdByName("Tramp of Babylon")] = "achievement_tramp",
    [Isaac.GetItemIdByName("Heart Arrest")] = "achievement_heart_arrest",
    [Isaac.GetItemIdByName("Blood Pudding")] = "achievement_blood_pudding",
    [Isaac.GetItemIdByName("Lucifer's Wings")] = "achievement_luc_wings",
    [Isaac.GetItemIdByName("Late Delivery")] = "achievement_late_delivery",
    [Isaac.GetItemIdByName("Sharing is Caring")] = "achievement_sharing_caring",
    [Isaac.GetItemIdByName("Book of Saints")] = "achievement_book_of_saints",
    [Isaac.GetItemIdByName("Anguish Jar")] = "achievement_anguish_jar",
    [Isaac.GetItemIdByName("Crossbones")] = "achievement_crossbones",
    [Isaac.GetItemIdByName("Orb of Radiance")] = "achievement_orb_of_radience",
    [Isaac.GetItemIdByName("Marshall Scarf")] = "achievement_marsh_scarf",
    [Isaac.GetItemIdByName("Jack-of-all-Trades")] = "achievement_costume_bin",

    [Isaac.GetItemIdByName("Larval Therapy")] = "achievement_chiggers",
    [Isaac.GetItemIdByName("Adramolech's Blessing")] = "achievement_adra_blessing",
    [Isaac.GetItemIdByName("Holy Chalice")] = "achievement_holy_chalice",
    [Isaac.GetItemIdByName("Papal Cross")] = "achievement_papal_cross",
    [Isaac.GetItemIdByName(" Papal Cross ")] = "achievement_papal_cross",
    [Isaac.GetItemIdByName("Crown of Gold")] = "achievement_crown_of_gold",
    [Isaac.GetItemIdByName("Opia")] = "achievement_opia",

    [Isaac.GetItemIdByName("Fruit Flies")] = "achievement_fruit_fly",
    [Isaac.GetItemIdByName("Fatal Attraction")] = "achievement_fatal_attraction",


    [Isaac.GetItemIdByName("Impending Doom")] = "achievement_calendar",
    [Isaac.GetItemIdByName("Vajra")] = "achievement_vajra",
    [Isaac.GetItemIdByName("Prayer Mat")] = "achievement_prayer_mat",

    [Isaac.GetItemIdByName("Sugar!")] = "achievement_sugar",

    [Isaac.GetItemIdByName("Celestial Paw")] = "achievement_celestial",
    [Isaac.GetItemIdByName("Celestial Tail")] = "achievement_celestial",
    [Isaac.GetItemIdByName("Celestial Collar")] = "achievement_celestial",

    [Isaac.GetItemIdByName("A Second Thought")] = "achievement_secondthought",
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

ret.is_item_unlocked = function(item,bypass_unlock_bypass)
    return GODMODE.save_manager.get_config("Unlocks", "true") == "false" and (bypass_unlock_bypass ~= true) or ret.item_map[item] and GODMODE.save_manager.get_persistant_data("Unlock."..ret.item_map[item], "false") == "true" or not ret.item_map[item]
end

ret.unlock_item = function(item)
    local name = ret.item_map[item]

    if name ~= nil and GODMODE.save_manager.get_persistant_data("Unlock."..name,"false") == "false" then
        ret.play_splash(name)
        GODMODE.save_manager.set_persistant_data("Unlock."..name, "true")
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
        if GODMODE.unlock_sprite == nil then 
            GODMODE.unlock_sprite = Sprite()
            GODMODE.unlock_sprite:Load("gfx/achievements/achievements.anm2", true)
            GODMODE.log("Loaded achievement splash sprite!")
        end

        GODMODE.unlock_sprite:ReplaceSpritesheet(3,"gfx/achievements/"..ret.achievement_queue[1].name..".png")
        GODMODE.unlock_sprite:LoadGraphics()
        GODMODE.unlock_sprite:Play("Scene",true)
        GODMODE.cur_splash = GODMODE.unlock_sprite 
        GODMODE.cur_splash_pos = GODMODE.util.get_center_of_screen()/2
        GODMODE.cur_splash.PlaybackSpeed = ret.achievement_queue[1].speed
        table.remove(ret.achievement_queue,1)
    end
end

ret.unlock_fallen_light = function(player)
    local name = ret.achievement_list.fallen_light[player.SubType]

    if name ~= nil and GODMODE.save_manager.get_persistant_data("Unlock."..name,"false") == "false" then
        ret.play_splash(name)
        GODMODE.save_manager.set_persistant_data("Unlock."..name, "true")
    end
end

ret.unlock_sign_buff = function()
    local kills = tonumber(GODMODE.save_manager.get_persistant_data("PalaceKills","0"))
    GODMODE.save_manager.set_persistant_data("PalaceKills", math.min(5,kills + 1))

    if kills+1 < 5 then
        ret.play_splash("achievement_sign"..kills+1)
    elseif kills+1 == 5 then
        ret.play_splash("achievement_signcomplete")
        GODMODE.save_manager.set_persistant_data("PalaceComplete", "true")
    end
end

return ret