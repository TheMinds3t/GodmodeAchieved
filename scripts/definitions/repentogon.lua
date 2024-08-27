local ret = {}

if GODMODE.validate_rgon() then 
    -- register godmode commands
    Console.RegisterCommand("gm_setconfig",
        "Sets the specified Godmode config value, or use \'list\' to show all config keys and their values.",
        "gm_setconfig <config_key> <new_value>", true, AutocompleteType.CUSTOM)
    Console.RegisterCommand("statscore",
        "Displays the stat score for the specified player, or all players if none specified.",
        "statscore <player index>", true, AutocompleteType.PLAYER)
    Console.RegisterCommand("fabrun",
        "Approximates a combination of \'combo\' commands to generate a run's worth of items up to the specified stage.",
        "fabrun <stage count>", true, AutocompleteType.NONE)
    Console.RegisterCommand("cotv_debug",
        "Displays every qualifier to allow Call of the Void to spawn. Mostly used to debug situations that Call of the Void should or shouldn't be able to count down the timer in.",
        "cotv_debug", false, AutocompleteType.NONE)
    Console.RegisterCommand("keepah_mode",
        "Toggles the Keepah Update for this gameplay session (Keepah's siblings help you).",
        "keepah_mode", false, AutocompleteType.NONE)
    Console.RegisterCommand("birthday_mode",
        "Toggles the Birthday Mode for this gameplay session (all boss items are Birthday Slice).",
        "keepah_mode", false, AutocompleteType.NONE)
    ret.player_type_to_name = {}

    ret.gather_player_name_list = function()
        ret.player_type_to_name = {}
        local n = XMLData.GetNumEntries(XMLNode.PLAYER)

        for i=0,n do 
            local entry = XMLData.GetEntryByOrder(XMLNode.PLAYER, i)

            if entry then 
                local name = entry.name --player name
                local id = entry.id or Isaac.GetPlayerTypeByName(name)
    
                ret.player_type_to_name[id] = name
                GODMODE.log("PLAYERNAME |  "..id.." = '"..name.."'",true)
            end
        end
    end
    ret.gather_player_name_list()

    local level_to_seal = {
        ["0,0"] = 0,
        ["0,1"] = 3,
        ["0,2"] = 4,
        ["1,0"] = 1,
        ["1,1"] = 3,
        ["1,2"] = 4,
        ["2,0"] = 2,
        ["2,1"] = 3,
        ["2,2"] = 4,
    }

    ret.sign_strength_opac_time = 45 
    
    function GODMODE.mod_object:post_comp_mark_render(comp_sprite, pos, scale, playertype)
       
        local player_name = ret.player_type_to_name[""..playertype] or "unknown"
        local fl_state = tonumber(GODMODE.save_manager.get_persistant_data("FallenLightKilled."..player_name, "0"))
        local ts_state = tonumber(GODMODE.save_manager.get_persistant_data("TheSignKilled."..player_name, "0"))

        local seal = level_to_seal[fl_state..","..ts_state]

        local pause_menu = GODMODE.game:IsPauseMenuOpen()

        if GODMODE.sprites.mm_addon_sprite == nil then
            GODMODE.sprites.mm_addon_sprite = Sprite()
            GODMODE.sprites.mm_addon_sprite:Load("gfx/ui/main menu/god_mainmenu_addons.anm2", true)
            GODMODE.log("Loaded Fallen Light/The Sign Completion mark sprite!")
        end

        -- render sign level
        if not pause_menu and playertype == GODMODE.registry.players.the_sign and MenuManager.GetActiveMenu() == MainMenuType.CHARACTER then 
            local kills = tonumber(GODMODE.save_manager.get_persistant_data("PalaceKills","0",true))

            if kills > 0 then 
                GODMODE.sprites.mm_addon_sprite:SetFrame("SignStrength",math.min(5,kills))
                local render_pos = GODMODE.util.get_center_of_screen() - Vector(-1,46)
                ret.sign_stren_opac = math.min((ret.sign_stren_opac or 0) + 1 / ret.sign_strength_opac_time, 1)
                GODMODE.sprites.mm_addon_sprite.Color = Color(1,1,1,ret.sign_stren_opac or 0,0,0,0)
                GODMODE.sprites.mm_addon_sprite:Render(render_pos)
            end
        else 
            ret.sign_stren_opac = 0
        end

        -- draw fl seal
        if seal ~= nil then 
            local render_pos = pos + Vector(36,-6) * scale

            if pause_menu and MiniPauseMenuPlus_Mod == true then render_pos = render_pos + Vector(-8,8) end

            GODMODE.sprites.mm_addon_sprite:SetFrame("Seal",seal)
            GODMODE.sprites.mm_addon_sprite.Color = Color(1,1,1,1)
            GODMODE.sprites.mm_addon_sprite:Render(render_pos)
        end
    end

    function GODMODE.mod_object:post_saveslot_loaded(slot, selected, rawslot)
        GODMODE.save_manager.allow_persistent_load = false
        GODMODE.save_manager.load()
        GODMODE.achievements.sync_repentogon_with_godmode()
        GODMODE.save_manager.allow_persistent_load = nil
        -- GODMODE.save_manager.save()
    end

    function GODMODE.mod_object:pre_pickup_render(pickup, offset)
        local data = GODMODE.get_ent_data(pickup)
        local itempool_flag = GODMODE.itempools.is_in_pool("observatory",pickup.SubType) or GODMODE.itempools.is_in_pool("observatory_items",pickup.SubType)
        or GODMODE.itempools.is_in_pool("observatory_tarots",pickup.SubType) or GODMODE.itempools.is_in_pool("observatory_souls",pickup.SubType) 
        
        if not pickup.Touched and GODMODE.is_in_observatory() and itempool_flag then 
            local ret = offset + Vector(0,-32)
            
            if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then 
                ret = offset

                if (data.shifted or false) ~= true then 
                    pickup:GetSprite():ReplaceSpritesheet(5, "gfx/grid/cursed_altar.png")
                    pickup:GetSprite():LoadGraphics()
                    data.shifted = true     
                end
            else
                if GODMODE.sprites.cursed_altar == nil then
                    GODMODE.sprites.cursed_altar = Sprite()
                    GODMODE.sprites.cursed_altar:Load("gfx/grid/cursed_altar.anm2", true)
                    GODMODE.log("Loaded the Observatory cursed altar sprite!")
                end

                local altar_pos = Isaac.WorldToScreen(pickup.Position+offset)
                GODMODE.sprites.cursed_altar:SetFrame("Idle",pickup.FrameCount % GODMODE.sprites.cursed_altar:GetAnimationData("Idle"):GetLength())
                GODMODE.sprites.cursed_altar:Render(altar_pos)
                local item_nf = GODMODE.sprites.cursed_altar:GetNullFrame("ItemPos")
                pickup:GetSprite().Scale = item_nf:GetScale()
                pickup:GetSprite().Color = item_nf:GetColor()
                pickup:GetSprite():Render(altar_pos + item_nf:GetPos())
                
                return false 
            end

            return ret
        end
    end


    -- function GODMODE.mod_object:post_level_layout(room_slot, room_config, seed)

    -- end MC_PRE_PICKUP_RENDER

    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_COMPLETION_MARKS_RENDER, GODMODE.mod_object.post_comp_mark_render)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, GODMODE.mod_object.post_saveslot_loaded)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_PICKUP_RENDER, GODMODE.mod_object.pre_pickup_render)
    -- GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_LEVEL_LAYOUT_GENERATED, GODMODE.mod_object.post_level_layout)
    ret.loaded = true
else 
    ret = nil
end

return ret 