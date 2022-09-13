
GODMODE = {}
function GODMODE.log(msg, console)
    console = console or false

    if console and GODMODE.console_logging then 
        Isaac.ConsoleOutput("[GODMODE_ACHIEVED] "..msg.."\n")
    end

    if GODMODE.debug_logging then
        Isaac.DebugString("[GODMODE_ACHIEVED] "..msg)
    end
end

if REPENTANCE ~= true then
    GODMODE.log("The Binding of Isaac: Repentance is required to play with Godmode: Achieved. Preventing further code from execution...", true)
    return
else
    GODMODE.mod_id = "AOIGodmodeAchieved"
    GODMODE.mod_object = RegisterMod(GODMODE.mod_id, 1)
    GODMODE.repentance = true --unleashed had same modid
    GODMODE.godmode_ent_type = 700

    GODMODE.convert_ent_to = { --temp fix for really odd bug
        ["700.204"] = {type=Isaac.GetEntityTypeByName("Secret Light"),variant=Isaac.GetEntityVariantByName("Secret Light")},
        ["700.205"] = {spawn=false,type=Isaac.GetEntityTypeByName("Red Coin"),variant=Isaac.GetEntityVariantByName("Red Coin")},
        -- ["700.204"] = {type=Isaac.GetEntityTypeByName("Heart Container (Pickup)"),variant=Isaac.GetEntityVariantByName("Heart Container (Pickup)")},
    }


    --used for godmode hooks
    function GODMODE.push_items_monsters(funcname, qualifier_items, qualifier_monsters, params)
        if GODMODE.godhooks and GODMODE.godhooks.hook_list[funcname] == nil then
            local item_ret = GODMODE.push_items(funcname, qualifier_items, params)
            local monster_ret = GODMODE.push_monsters(funcname, qualifier_monsters, params)
        
            if item_ret ~= nil or monster_ret ~= nil then
                if item_ret ~= nil then 
                    --GODMODE.log("item_ret is "..tostring(item_ret), true) 
                    return item_ret 
                else
                    return monster_ret
                end
            end    
        end
    end

    --used for godmode hooks
    local trinket_qualifier = function(item)
        return #GODMODE.util.does_player_have(item.instance, true) > 0
    end

    --used for godmode hooks
    function GODMODE.push_items(funcname,qualifier,params)
        if GODMODE.godhooks and GODMODE.godhooks.hook_list[funcname] == nil then
            local list = GODMODE.items
        
            for i=1,#list do
                local item = list[i]
                item.bypass_qualifier = item.bypass_qualifier or {}
                local qualified = item.transformation

                if qualifier == true then qualified = true else 
                    if item.transformation ~= true then 
                        qualified = qualifier(item, params) == true
                        if item.trinket == true then qualified = trinket_qualifier(item) end
                    end
                end

                if (qualified or item.bypass_qualifier[funcname] ~= nil) and
                    (not qualified and item[item.bypass_qualifier[funcname]] or qualified and item[funcname]) then
                    local actual = funcname 
                    if not qualified then actual = item.bypass_qualifier[funcname] end

                    local ret = item[actual](item, params)
                    --GODMODE.log("Ret for item "..item.instance..", func "..funcname.." is \'"..tostring(ret).."\'", true)
                    if ret ~= nil then return ret end
                end
            end
        end
    end

    --used for godmode hooks
    function GODMODE.push_monsters(funcname,qualifier,params)
        if GODMODE.godhooks and GODMODE.godhooks.hook_list[funcname] == nil then
            for i=1,#GODMODE.monsters do
                local monster = GODMODE.monsters[i]
                monster.bypass_qualifier = monster.bypass_qualifier or {}
                local qualified = qualifier(monster, params) == true

                if (qualified or monster.bypass_qualifier[funcname] ~= nil) and
                    (not qualified and monster[monster.bypass_qualifier[funcname]] or qualified and monster[funcname]) then
                    local actual = funcname 
                    if not qualified then actual = monster.bypass_qualifier[funcname] end

                    local ret = monster[actual](monster, params)
                    if ret ~= nil then return ret end
                end
            end
        end
    end

    --A set of checks to ensure it's valid to add godmode data to the specified entity
    function GODMODE.can_have_ent_data(ent)
        return ent ~= nil and type(ent) == "userdata" and ent.GetData ~= nil and type(ent:GetData()) == "table" 
            and (ent.Type < 1000 
            or (GODMODE.godhooks.effect_data_list and GODMODE.godhooks.effect_data_list.monsters 
                and GODMODE.godhooks.effect_data_list.monsters[ent.Type..","..ent.Variant] == true))
    end

    --Had to be on top for save_manager
    function GODMODE.get_ent_data(ent)
        if not GODMODE.can_have_ent_data(ent) then return nil end
        if type(ent) == "userdata" and ent:GetData() ~= nil and type(ent:GetData()) == "table" and ent:GetData()["godmodeachieved"] == nil and ent:GetDropRNG():GetSeed() > 0 then
            ent:GetData()["godmodeachieved"] = {time = -1 + ent:GetDropRNG():RandomInt(1000), real_time = 0}
            GODMODE.push_monsters("data_init", function(monster, params) return params[1].Type == monster.type and params[1].Variant == monster.variant end, {ent, ent:GetData()["godmodeachieved"]})
            --GODMODE.log("Registered data for \'"..ent.Type.."."..ent.Variant.."."..ent.SubType.."\'!")
        end

        return ent:GetData()["godmodeachieved"]
    end

    --Had to be on top for save_manager
    function GODMODE.set_ent_data(ent, data)
        if not GODMODE.can_have_ent_data(ent) then return nil end
        ent:GetData()["godmodeachieved"] = data
    end

    GODMODE.mod_object.load_core = function(self)
        GODMODE.util = include("scripts.util")
        GODMODE.godhooks = include("scripts.godhook_converter")
        GODMODE.items = include("scripts.definitions.itemlist")
        GODMODE.monsters = include("scripts.definitions.monsterlist")
        GODMODE.godhooks.register_items_and_ents()
        
        GODMODE.alt_entries = include("scripts.definitions.alt_entries")
        GODMODE.sounds = include("scripts.definitions.sounds")
        GODMODE.players = include("scripts.definitions.players")
        GODMODE.armor_blacklist = include("scripts.definitions.armor_blacklist")
        GODMODE.room_override = include("scripts.room_override")
        GODMODE.loaded_rooms = include("scripts.definitions.roomlist")
        GODMODE.bosses = include("scripts.definitions.bosslist")
        GODMODE.cards_pills = include("scripts.definitions.cards_pills")

        GODMODE.special_items = include("scripts.definitions.special_items")
        GODMODE.special_items:fill_item_lists()
        GODMODE.shader_params = GODMODE.shader_params or {}

        GODMODE.shader_params.godmode_trinket_time = 0
    end

    GODMODE.achievements = include("scripts.definitions.achievements")
    GODMODE.save_manager = require("scripts.save_manager")
    GODMODE.console_logging = true --enables/disables log outputting to console for messages that do
    GODMODE.debug_logging = true --enables/disables log outputting to log.txt for messages that do

    GODMODE.persistent_state = {
        none = 0,
        single_room = 1,
        between_rooms = 2,
        between_floors = 3,
    }

    function GODMODE.is_animating()
        local flag = GODMODE.cur_splash ~= nil and GODMODE.cur_splash:IsPlaying("Scene")
        if flag == true then
            GODMODE.cur_splash_timeout = 5
        end
        return flag
    end

    function GODMODE.add_angel_collected(player,coll)
        local angel_col = GODMODE.save_manager.get_player_data(player,"AngelCollected","")

        if angel_col == "" then 
            GODMODE.save_manager.set_player_data(player,"AngelCollected",""..coll,true)
        else
            GODMODE.save_manager.set_player_data(player,"AngelCollected",angel_col..","..coll,true)
        end
    end

    function GODMODE.remove_angel_collected(player,coll)
        local angel_col = GODMODE.save_manager.get_player_data(player,"AngelCollected","")
        coll = ""..coll
        if angel_col == coll then 
            GODMODE.save_manager.set_player_data(player,"AngelCollected","",true)
        elseif GODMODE.util.string_starts(angel_col,coll) then 
            GODMODE.save_manager.set_player_data(player,"AngelCollected",angel_col:sub(coll:len()+1),true)
        else
            GODMODE.save_manager.set_player_data(player,"AngelCollected",angel_col:gsub(","..coll,""),true)
        end
    end

    function GODMODE.get_angel_collected(player)
        local ret = {}
        local angel_col = GODMODE.util.string_split(GODMODE.save_manager.get_player_data(player,"AngelCollected",""),",")

        if angel_col ~= "" then 
            for _,col in ipairs(angel_col) do 
                table.insert(ret,tonumber(col))
            end
        end
        
        return ret
    end

    function GODMODE.play_ending() 
        local ending = Sprite()
        ending:Load("gfx/ui/ending/ending.anm2", true)
        ending.PlaybackSpeed = 0.666
        GODMODE.cur_splash = ending 
        GODMODE.playing_ending = true 
        GODMODE.log("Playing Godmode ending!",true)
        MusicManager():Pause()
        MusicManager():Disable()
    end

    function GODMODE.is_in_secrets() 
        return Game().Challenge == Isaac.GetChallengeIdByName("[GODMODE] Secrets")
    end

    GODMODE.mod_object:load_core()
    include("scripts.mod_integration") --EID, ModConfig, StageAPI, Encyclopedia, Enhanced Boss Bars

    function GODMODE.mod_object:game_start(continued)

        -- if continued then
        --     GODMODE.util.init_rand(tonumber(GODMODE.save_manager.get_data("RandSeed","64")))
        --     GODMODE.save_manager.load()
        --     GODMODE.save_manager_lock = true
        -- else
        --     GODMODE.save_manager.wipe()
        --     GODMODE.save_manager.wipe_persistent_entities()
        --     GODMODE.util.init_rand()
        -- end

        -- GODMODE.save_manager.save()

        GODMODE.push_items_monsters("game_start", function(item,continued) return #GODMODE.util.does_player_have(item.instance) > 0 end, function(monster,continued) return GODMODE.util.count_enemies(nil, monster.type, monster.variant) > 0 end, continued)
        GODMODE.cotv_timer_st_cache = nil
    end

    function GODMODE.mod_object:game_end(won)
    end 

    function GODMODE.mod_object:game_exit(should_save)
        if should_save then
            GODMODE.save_manager_lock = true

            for _,ent in ipairs(Isaac.GetRoomEntities()) do 
                if GODMODE.get_ent_data(ent) ~= nil and GODMODE.get_ent_data(ent).persistent_data ~= nil then 
                    ent:ClearEntityFlags(EntityFlag.FLAG_PERSISTENT)
                    GODMODE.save_manager.add_persistent_entity_data(ent)
                    ent:Remove()
                end
            end

            GODMODE.save_manager.save()
            GODMODE.save_manager_lock = false
        end

        GODMODE.save_manager.has_loaded = false

        MusicManager():Enable()
    end 

    function GODMODE.mod_object:post_update()
        -- used to blacken screen after taking damage
        GODMODE.shader_params.godmode_trinket_time = math.max(0,(GODMODE.shader_params.godmode_trinket_time or 0)-1)

        local mcm_flag = not ModConfigMenu or ModConfigMenu and not ModConfigMenu.IsVisible
        if GODMODE.mcm_reset ~= nil and mcm_flag then GODMODE.mcm_reset = 5 end --resets wiping data counter if modconfigmenu is closed

        --fullscreen animations
        if GODMODE.cur_splash ~= nil then
            GODMODE.cur_splash:Play("Scene", false)

            if GODMODE.cur_splash:IsEventTriggered("LuciferTransition") then --palace!
                Isaac.ExecuteCommand("cstage IvoryPalace")
            end
            
            if GODMODE.cur_splash:IsEventTriggered("Start") then 
                SFXManager():Play(GODMODE.sounds.ending_voiceover)
            end

            if GODMODE.cur_splash:IsEventTriggered("EndGame") then 
                Game():FinishChallenge()
            end
        end

        if not GODMODE.is_animating() then 
            GODMODE.cur_splash = nil 
            GODMODE.cur_splash_timeout = math.max(0, (GODMODE.cur_splash_timeout or 5) - 1)
        else
            GODMODE.cur_splash:Update()
        end

        local room = Game():GetRoom()
        local level = Game():GetLevel()

        --try to override room
        if not room:IsClear() and room:GetType() == RoomType.ROOM_BOSS then
            if Isaac.CountEnemies() + Isaac.CountBosses() >= 0 and GODMODE.override_attempted ~= true then 
                GODMODE.override_attempted = true
                GODMODE.room_override.try_override_room(level:GetCurrentRoomDesc().GridIndex)
            end
        end

        --try to override first treasure
        if room:GetType() == RoomType.ROOM_TREASURE and level:GetStage() == LevelStage.STAGE1_1 and GODMODE.override_attempted ~= true then
            GODMODE.room_override.try_override_room(level:GetCurrentRoomDesc().GridIndex)
            GODMODE.override_attempted = true
        end

        --update sprites
        if GODMODE.red_coin_sprite ~= nil then
            GODMODE.red_coin_sprite:Update()
        end

        if GODMODE.void_sprite ~= nil then
            GODMODE.void_sprite:Update()
        end

        GODMODE.achievements.update()

        --update godmode stage
        if StageAPI and StageAPI.GetCurrentStage() ~= nil and GODMODE.stages ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name] ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name].stage_update ~= nil then
            GODMODE.stages[StageAPI.GetCurrentStage().Name]:stage_update()
        end

        --spawn call of the void
        if GODMODE.util.is_cotv_counting() then
            local time = math.min(tonumber(GODMODE.save_manager.get_data("FloorEnterTime","120000")),tonumber(GODMODE.save_manager.get_config("VoidEnterTime","9005")))
            local time_inc = 1

            if GODMODE.util.has_curse(LevelCurse.CURSE_OF_LABYRINTH) then time_inc = 0.5 end

            GODMODE.save_manager.set_data("FloorEnterTime",""..time-time_inc)

            if time <= 0 or Game().Challenge == Isaac.GetChallengeIdByName("Out Of Time") then
                GODMODE.save_manager.set_data("VoidSpawned","true")
                GODMODE.save_manager.set_data("VoidBHProj",tonumber(GODMODE.save_manager.get_data("VoidBHProj","0"))+1)
                GODMODE.save_manager.set_data("VoidDMProj",tonumber(GODMODE.save_manager.get_data("VoidDMProj","0"))+3)

                local flag = true
                GODMODE.util.macro_on_enemies(nil,Isaac.GetEntityTypeByName("Call of the Void"), Isaac.GetEntityVariantByName("Call of the Void"),0,function(ent)
                    flag = false
                    ent = ent:ToNPC()
                    if ent.I1 > 0 and ent.I2 == 0 then 
                        ent.I1 = ent.I1 + 1
                    end
                end)

                if flag == true then
                    local void = Isaac.Spawn(Isaac.GetEntityTypeByName("Call of the Void"), Isaac.GetEntityVariantByName("Call of the Void"),0,room:GetCenterPos(),Vector.Zero,nil)
                    GODMODE.get_ent_data(void).persistent_state = GODMODE.persistent_state.between_floors
                end

                local rooms = Game():GetLevel():GetRooms()
                local chance = 0.01
                GODMODE.save_manager.set_data("SOCSpawnSeed","-1")

                -- spawn stream of consciousness
                local depth = 10

                while GODMODE.save_manager.get_data("SOCSpawnSeed","-1") == "-1" and depth > 0 do
                    depth = depth - 1

                    for i=0, rooms.Size-1 do
                        local room = rooms:Get(i)
                        if room.Data.Type == RoomType.ROOM_DEFAULT and room.DecorationSeed ~= Game():GetRoom():GetDecorationSeed() then
                            if GODMODE.util.random() < chance then
                                GODMODE.save_manager.set_data("SOCSpawnSeed",room.DecorationSeed)
                                break
                            else
                                chance = chance + 0.09
                            end
                        end 
                    end    

                    GODMODE.log("SOC spawn index = "..GODMODE.save_manager.get_data("SOCSpawnSeed","-1"))
                end
            end
        end

        if GODMODE.util.has_curse(Isaac.GetCurseIdByName("Blessing of Faith!")) and level:GetAngelRoomChance() < 1 then
            level:AddAngelRoomChance(1.0)
        end

        if Game():GetFrameCount() % 300 == 0 then 
            GODMODE.delirious_count = 1
        end

        if GODMODE.eden_grind_cmd == true then 
            if Game():GetRoom():GetType() == RoomType.ROOM_BOSS and Game():GetLevel():GetStage() == LevelStage.STAGE4_2 then 
                if Game():GetRoom():IsClear() then 
                    GODMODE.eden_grind_cooldown = (GODMODE.eden_grind_cooldown or 15) - 1

                    if GODMODE.eden_grind_cooldown <= 0 then 
                        Isaac.ExecuteCommand("reseed")
                    end
                else 
                    GODMODE.eden_grind_cooldown = 15
                end
            else 
                Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_BLANK_CARD,UseFlag.USE_NOANIM)
            end
        end
    end

    function GODMODE.mod_object:post_player_render(player,offset)
        local data = GODMODE.get_ent_data(player)

        if data ~= nil then 
            data.red_coin_count = tonumber(GODMODE.save_manager.get_player_data(player, "RedCoinCount", "0"))
            data.red_coin_display = data.red_coin_display or 0

            if Input.IsActionPressed (ButtonAction.ACTION_MAP, player.ControllerIndex) then
                data.red_coin_display = math.min(50,data.red_coin_display + 5)
            end

            if data.red_coin_display > 0 then
                local opacity = math.min(1.0, data.red_coin_display / 50.0)
                local pos = Isaac.WorldToScreen(player.Position + Vector(-32,16))

                if GODMODE.red_coin_sprite == nil then
                    GODMODE.red_coin_sprite = Sprite()
                    GODMODE.red_coin_sprite:Load("gfx/pickup_redcoin.anm2", true)
                end

                GODMODE.red_coin_sprite.Color = Color(1,1,1,opacity)
                GODMODE.red_coin_sprite:Play("HudClasp",true)
                GODMODE.red_coin_sprite:Render(pos,Vector.Zero,Vector.Zero)
                GODMODE.red_coin_sprite:Play("Hud",true)
                data.red_coin_display = data.red_coin_display - 1

                for i=1,5 do
                    if data.red_coin_count >= i then 
                        GODMODE.red_coin_sprite:Render(pos+Vector(i*7,0),Vector.Zero,Vector.Zero)
                    end
                end
            end
        end

        if GetPtrHash(player) == GetPtrHash(Isaac.GetPlayer()) and StageAPI and StageAPI.GetCurrentStage() ~= nil and GODMODE.stages ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name] ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name].stage_render ~= nil then
            GODMODE.stages[StageAPI.GetCurrentStage().Name]:stage_render()
        end
    end

    local cotv_debug_map = {
        function() 
            return "Can COTV Countdown: "..tostring(GODMODE.util.is_cotv_counting())
        end,
        function() 
            return "COTV ticks remaining: "..GODMODE.save_manager.get_data("FloorEnterTime","120000")
        end,
        function() 
            GODMODE.cotv_timer_st_cache = GODMODE.cotv_timer_st_cache or (GODMODE.util.total_item_count(Isaac.GetItemIdByName("A Second Thought")))
            return "Second Thought Count: "..GODMODE.cotv_timer_st_cache
        end,
        function()
            return "Room Clear: "..tostring(Game():GetRoom():IsClear())
        end,
        function()
            local room = Game():GetRoom()
            return "Room Type: "..tostring((room:GetType() == RoomType.ROOM_CHALLENGE and Isaac.CountEnemies()+Isaac.CountBosses() == 0 or room:GetType() ~= RoomType.ROOM_CHALLENGE) and room:GetType() ~= RoomType.ROOM_BOSSRUSH and room:GetType() ~= RoomType.ROOM_ARCADE and room:GetType() ~= RoomType.ROOM_ISAACS) 
        end,
        function()
            return "Challenge Override: "..tostring(Game().Challenge == Isaac.GetChallengeIdByName("Out Of Time")) 
        end,
        function()
            return "Palace Flag:"..tostring(not GODMODE.is_at_palace or not GODMODE.is_at_palace())
        end,
        function()
            return "COTV Enabled:"..tostring(GODMODE.save_manager.get_config("CallOfTheVoid","false") == "true")
        end,
        function()
            return "COTV Spawned:"..tostring(GODMODE.save_manager.get_config("VoidSpawned","false") == "true")
        end,
        function()
            return "MCM Open:"..tostring(not (ModConfigMenu == nil or not ModConfigMenu.IsVisible))
        end,
        function()
            return "In secrets:"..tostring(GODMODE.is_in_secrets())
        end,

    }

    function GODMODE.mod_object:post_render()
        if Game():GetLevel():GetStage() == LevelStage.STAGE7 and GODMODE.save_manager.get_config("VoidOverlay","true") == "true" then
            if GODMODE.void_sprite == nil then
                GODMODE.void_sprite = Sprite()
                GODMODE.void_sprite:Load("gfx/backdrop/voidoverlay.anm2", true)
                GODMODE.log("Loaded Void overlay!")
            end
            GODMODE.void_sprite:Render(Game():GetRoom():GetRenderSurfaceTopLeft(), Vector(0,0), Vector(0,0))
            GODMODE.void_sprite:Play("Stage",false)
        end

        if GODMODE.vs_sprite == nil then
            GODMODE.vs_sprite = Sprite()
            GODMODE.vs_sprite:Load("gfx/ui/boss/god_versusscreen.anm2", true)
            GODMODE.log("Loaded Godmode Vs. overlay!")
        end

        if GODMODE.cotv_timer_sprite == nil then 
            GODMODE.cotv_timer_sprite = Sprite()
            GODMODE.cotv_timer_sprite:Load("gfx/ui/ui_cotv.anm2", true)
            GODMODE.log("Loaded Godmode COTV timer!")
        elseif GODMODE.save_manager.get_config("COTVDisplay","true") == "true" then 
            local anim_type = "Timer"
            if not GODMODE.util.is_cotv_counting() and not GODMODE.util.is_cotv_spawned() then 
                anim_type = "TimerPaused"
            end

            if Game():GetLevel():GetAbsoluteStage() > LevelStage.STAGE5 or (GODMODE.cotv_timer_st_cache or 0) > 0 then 
                anim_type = "TimerDisabled"
            end

            local challenge_flag = Game().Challenge == Isaac.GetChallengeIdByName("Out Of Time")

            if (GODMODE.save_manager.get_config("CallOfTheVoid","true") ~= "true" or GODMODE.util.is_cotv_spawned() or Game().Difficulty ~= Difficulty.DIFFICULTY_HARD) and not challenge_flag then 
                GODMODE.cotv_timer_counter = math.max((GODMODE.cotv_timer_counter or 0)-1,0)
            else 
                GODMODE.cotv_timer_counter = math.min((GODMODE.cotv_timer_counter or 0)+1,100)
            end

            GODMODE.cotv_timer_counter = GODMODE.cotv_timer_counter or 0
            local max_time = tonumber(GODMODE.save_manager.get_config("VoidEnterTime","9005"))
            local time = tonumber(GODMODE.save_manager.get_data("FloorEnterTime",""..max_time))
            local perc = 1.0-time/max_time 

            if challenge_flag then perc = 1.0 end

            GODMODE.cotv_timer_sprite.Color = Color(GODMODE.cotv_timer_counter/100.0,GODMODE.cotv_timer_counter/100.0,GODMODE.cotv_timer_counter/100.0,GODMODE.cotv_timer_counter/100.0)
            GODMODE.cotv_timer_sprite:SetFrame(anim_type,math.floor(perc*73))
            GODMODE.cotv_timer_sprite:Render(GODMODE.util.get_cotv_counter_pos(), Vector(0,0), Vector(0,0))
            GODMODE.cotv_timer_sprite.PlaybackSpeed = 0.0
            
            if anim_type ~= "TimerDisabled" and not challenge_flag then 
                GODMODE.cotv_timer_sprite:SetOverlayFrame("TimerHand",math.floor(perc*73))
            else
                GODMODE.cotv_timer_sprite:RemoveOverlay()
            end

            -- if Game():GetFrameCount() % 20 == 0 then 
            --     GODMODE.cotv_timer_st_cache = nil
            -- end

            GODMODE.cotv_timer_st_cache = GODMODE.cotv_timer_st_cache or (GODMODE.util.total_item_count(Isaac.GetItemIdByName("A Second Thought")))

            
            if GODMODE.cotv_timer_st_cache > 0 then 
                GODMODE.cotv_timer_sprite:SetFrame("TimerBackST",Game():GetFrameCount()%16)
            else 
                GODMODE.cotv_timer_sprite:SetFrame("TimerBack",Game():GetFrameCount()%16)
            end
            GODMODE.cotv_timer_sprite:Render(GODMODE.util.get_cotv_counter_pos(), Vector(0,0), Vector(0,0))
        end

        if (GODMODE.cotv_debug or false) == true then 
            local pos = Isaac.WorldToScreen(GODMODE.util.get_center_of_screen()*Vector(0.85,0.5))
            for ind,func in ipairs(cotv_debug_map) do 
                local render_pos = pos+Vector(0,ind*10)
                Isaac.RenderScaledText(func(),render_pos.X,render_pos.Y,0.75,0.75,1,1,1,1)
            end
        end

        if GODMODE.cur_splash ~= nil then
            if GODMODE.cur_splash_pos == nil then GODMODE.cur_splash_pos = GODMODE.util.get_center_of_screen() end
            if GODMODE.playing_ending == true then 
                GODMODE.cur_splash_pos = GODMODE.util.get_center_of_screen() * Vector(0.5,0.5)
            end

            GODMODE.cur_splash:Render(GODMODE.cur_splash_pos, Vector(0,0), Vector(0,0))
        end
    end

    function GODMODE.mod_object:npc_hit( dmg_target , dmg_amount, dmg_flag, dmg_dealer, dmg_frames)
        if GODMODE.is_at_palace and GODMODE.is_at_palace() and dmg_target.Type == EntityType.ENTITY_PLAYER and dmg_amount == 1 then 
            if not dmg_target:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then 
                dmg_target:TakeDamage(2, dmg_flag, dmg_dealer, dmg_frames)
                return false     
            end
        end

        if dmg_target:GetSprite():IsPlaying("BossDeath") then 
            return false
        end
    end

    local door_pos_mods = {
        [Direction.LEFT] = Vector(1,0),
        [Direction.RIGHT] = Vector(-1,0),
        [Direction.UP] = Vector(0,1),
        [Direction.DOWN] = Vector(0,-1),
        [Direction.NO_DIRECTION] = Vector(0,0)
    }

    function GODMODE.mod_object:npc_kill(ent) 
        local data = GODMODE.get_ent_data(ent)

        if data.dark_light ~= nil then data.dark_light:Die() end

        if (GODMODE.delirious_count or 0) > 0 and (GODMODE.tainted_deli or false) == true and not (ent.Type == Isaac.GetEntityTypeByName("Delirious Pile") and ent.Variant == Isaac.GetEntityVariantByName("Delirious Pile")) then 
            GODMODE.delirious_count = GODMODE.delirious_count - 1
            GODMODE.util.macro_on_players(function(player) 
                if player:GetName() == "Tainted Deli" then 
                    local pile = Isaac.Spawn(Isaac.GetEntityTypeByName("Delirious Pile"), Isaac.GetEntityVariantByName("Delirious Pile"), player:GetDropRNG():RandomInt(3), Game():GetRoom():FindFreePickupSpawnPosition(ent.Position), Vector.Zero, player)
                    pile:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    pile:GetSprite():Play("Appear", true)
                end
            end)
        end
    end

    function GODMODE.mod_object:npc_update(ent)
        local data = GODMODE.get_ent_data(ent)

        if ent.Type == GODMODE.godmode_ent_type and GODMODE.convert_ent_to["700."..ent.Variant] ~= nil then 
            if ent.I1 ~= 1 then 
                Isaac.Spawn(GODMODE.convert_ent_to["700."..ent.Variant].type,GODMODE.convert_ent_to["700."..ent.Variant].variant,0,ent.Position,Vector.Zero,nil)
            end
            
            ent:Remove()
            ent.I1 = 1
        end

        if data and GODMODE.save_manager_lock ~= true then
            if data.dark_light ~= nil then 
                data.dark_light.Position = ent.Position 
            end

            data.time = data.time + 1
            data.real_time = data.real_time + 1

            --Persistence functionality
            if data.persistent_state and data.persistent_state > GODMODE.persistent_state.none then
                if not ent:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) then
                    ent:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
                end

                if not data.persistent_data then
                    data.persistent_data = saved_data or {
                        room = Game():GetRoom():GetDecorationSeed(),
                        in_room = true,
                        floor = Game():GetLevel():GetStage(),
                    }
                end

                if data.persistent_state == GODMODE.persistent_state.single_room then
                    if ent:IsFrame(10,1) and Game():GetLevel():GetStage() ~= data.persistent_data.floor then 
                        ent:Remove()
                    end
                    
                    if Game():GetRoom():GetDecorationSeed() ~= data.persistent_data.room then

                        data.persistent_data.in_room = false
                        ent.Visible = false
                        -- ent.Position = Vector(-1000,-1000)
                        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                        ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                        ent:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_NO_QUERY)
                        if data.exit_room ~= nil then data.exit_room(ent) end
                    else
                        if data.persistent_data.position_x and data.persistent_data.position_y and data.persistent_data.in_room == false then
                            ent.GridCollisionClass = data.persistent_data.grid_coll_class or ent.GridCollisionClass
                            ent.EntityCollisionClass = data.persistent_data.ent_coll_class or ent.EntityCollisionClass
                            ent:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_NO_QUERY)
                            ent.Position.X = data.persistent_data.position_x or ent.Position.X
                            ent.Position.Y = data.persistent_data.position_y or ent.Position.Y
                            ent.Visible = true
                            if data.enter_room ~= nil then data.enter_room(ent) end
                        end

                        data.persistent_data.in_room = true
                        data.persistent_data.position_x = ent.Position.X
                        data.persistent_data.position_y = ent.Position.Y
                        data.persistent_data.ent_coll_class = ent.EntityCollisionClass
                        data.persistent_data.grid_coll_class = ent.GridCollisionClass
                    end
                elseif data.persistent_state >= GODMODE.persistent_state.between_rooms then
                    if Game():GetRoom():GetDecorationSeed() ~= data.persistent_data.room then
                        local door_pos = Game():GetLevel().EnterDoor
                        if Game():GetRoom():GetDoor(door_pos) ~= nil then 
                            local dir = Game():GetRoom():GetDoor(door_pos).Direction
                            if door_pos_mods[dir] ~= nil then 
                                if door_pos ~= -1 then
                                    ent.Position = ent.Position - Game():GetRoom():GetBottomRightPos() * door_pos_mods[dir]
                                    data.persistent_data.room = Game():GetRoom():GetDecorationSeed()
                                end
                            else
                                GODMODE.log("doorpos \'"..dir.."\' not registered, please fix")
                            end
                        else
                            GODMODE.log("Door index \'"..door_pos.."\' is not registered, please fix")
                        end
                    end

                    if ent:IsFrame(30,1) and data.persistent_data.floor ~= Game():GetLevel():GetStage() then
                        if data.persistent_state == GODMODE.persistent_state.between_floors then
                            data.persistent_data.floor = Game():GetLevel():GetStage()
                        else
                            ent:Remove()
                        end
                    end
                end
            end
        end
    end

    function GODMODE.mod_object:npc_init(ent)
        local hard_enabled = tostring(GODMODE.save_manager.get_config("HMEnable","true")) == "true"
        local greed_enabled = tostring(GODMODE.save_manager.get_config("GMEnable","true")) == "true"

        if GODMODE.util.is_valid_enemy(ent,true) and ((Game().Difficulty == Difficulty.DIFFICULTY_HARD and hard_enabled) or (Game().Difficulty == Difficulty.DIFFICULTY_GREEDIER and greed_enabled)) then
            local max_stage = 12
            local scale = tonumber(GODMODE.save_manager.get_config("HMEScale","2.0"))

            if Game().Difficulty > Difficulty.DIFFICULTY_HARD then 
                max_stage = 7 
                scale = tonumber(GODMODE.save_manager.get_config("GMEScale","1.5"))
            end

            if (Game():GetRoom():GetType() == RoomType.ROOM_BOSS or Game():GetRoom():GetType() == RoomType.ROOM_MINIBOSS) and ent:IsBoss() then
                if Game().Difficulty > 1 then
                    scale = tonumber(GODMODE.save_manager.get_config("GMBScale","1.8"))
                else
                    scale = tonumber(GODMODE.save_manager.get_config("HMBScale","2.3"))
                end
            end

            -- if Game():GetLevel():GetStageType() > StageType.STAGETYPE_GREEDMODE then 
            --     scale = scale * 0.8 
            -- end --make repentance stages easier since less items generally compared to main path

            local max_health = tonumber(GODMODE.save_manager.get_config("ScaleSelectorMax","3000"))
            local cur_stage = Game():GetLevel():GetAbsoluteStage()

            if StageAPI and GODMODE.stages ~= nil and StageAPI.GetCurrentStage() ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name] ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name].simulating_stage ~= nil then
                cur_stage = GODMODE.stages[StageAPI.GetCurrentStage().Name].simulating_stage
            end

            if ent.MaxHitPoints < max_health and not GODMODE.armor_blacklist:has_armor(ent) then
                local percent = (cur_stage-1) / math.max(1,max_stage-1) * math.max(1.0,scale-1.0)
                --GODMODE.log("hp scale: "..((1.0 + (scale-1) * (Game():GetVictoryLap() + 1) * percent)), true)
                ent.MaxHitPoints = ent.MaxHitPoints * (1.0 + (scale-1) * (Game():GetVictoryLap() + 1) * percent)
                ent.HitPoints = ent.MaxHitPoints
            end
        end

        if (Game():GetRoom():GetType() == RoomType.ROOM_MINIBOSS or Game():GetRoom():GetType() == RoomType.ROOM_BOSS) and ent:IsBoss() then
            ent:AddEntityFlags(EntityFlag.FLAG_NO_SPIKE_DAMAGE)
        end
    end

    function GODMODE.mod_object:new_level()
        GODMODE.room_override.wipe_overrides()

        if StageAPI and Game().Challenge == Challenge.CHALLENGE_NULL and not StageAPI.InNewStage() then 
            GODMODE.try_switch_stage()
        end

        if GODMODE.save_manager.get_data("StageReseed"..Game():GetLevel():GetStage(),"false") == "true" then 
            if not GODMODE.util.is_start_of_run() and Game():GetFrameCount() > 5 then 
                GODMODE.save_manager.set_data("StageReseed"..Game():GetLevel():GetStage(),"false",true)

                if (not GODMODE.is_at_palace or not GODMODE.is_at_palace()) then 
                    Isaac.ExecuteCommand("reseed")
                else 
                    Isaac.ExecuteCommand("creseed")
                end
            end
        end

        GODMODE.vs_played_in = {}
        GODMODE.save_manager.set_data("FloorEnterTime",""..GODMODE.save_manager.get_config("VoidEnterTime","9005"))
        GODMODE.save_manager.set_data("VoidSpawned","false")
        GODMODE.save_manager.set_data("Deterioration","1")
        GODMODE.save_manager.set_data("FortitudeCards","0",true)

        local rooms = Game():GetLevel():GetRooms()
        local enabled = tostring(GODMODE.save_manager.get_config("BossesEnabled", "true")) == "true"

        if enabled and not StageAPI then
            for variant,boss in pairs(GODMODE.bosses) do
                if boss and boss.chance and boss.chance() > 0 then
                    for i=0, rooms.Size-1 do
                        local roomdesc = rooms:Get(i)
                        if roomdesc.Data.Type == RoomType.ROOM_BOSS then
                            GODMODE.log("Adding possible boss override with variant "..variant..", chance is "..(boss.chance() * 100).."%")
                            GODMODE.room_override.set_override(roomdesc.GridIndex,
                            GODMODE.room_override.load_override_room(boss.roomfile,-1,roomdesc.GridIndex), boss.chance())
                            break
                        end
                    end
                end
            end
        end

        if GODMODE.util.is_start_of_run() then 
            GODMODE.tainted_deli = false 

            if not StageAPI then 
                --guarantee two treasures in first treasure room
                for i=0, rooms.Size-1 do
                    local roomdesc = rooms:Get(i)

                    if roomdesc.Data.Type == RoomType.ROOM_TREASURE then
                        GODMODE.room_override.set_override(roomdesc.GridIndex,
                            GODMODE.room_override.load_override_room("first_treasure",-1,roomdesc.GridIndex), 1.0)
                        break
                    end
                end
            end

            GODMODE.save_manager.save_override = false 
            GODMODE.push_items_monsters("first_level", true, function(monster) return true end, nil)
            GODMODE.save_manager.save_override = true 
            GODMODE.save_manager.save()
        end

        if Game():GetLevel():GetStage() == LevelStage.STAGE4_3 and GODMODE.save_manager.get_config("BlueWombRework","true",true) == "true" then
            for _,ent in ipairs(Isaac.GetRoomEntities()) do
                if ent.Type == EntityType.ENTITY_PICKUP then
                    ent:Remove()
                    -- ent:ToPickup():Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,Card.CARD_CRACKED_KEY)
                    -- Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,Card.CARD_CRACKED_KEY,ent.Position,Vector(0,2),ent)
                end
            end
            local key_count = 8
            local keys = {
                GODMODE.cards_pills.cards.pok_1,
                GODMODE.cards_pills.cards.pok_2,
                GODMODE.cards_pills.cards.pok_3,
                GODMODE.cards_pills.cards.pok_4,
                GODMODE.cards_pills.cards.pok_5,
                GODMODE.cards_pills.cards.pok_6,
                GODMODE.cards_pills.cards.pok_7,
                GODMODE.cards_pills.cards.pok_8
            }

            local count = 8/Game():GetNumPlayers()

            while key_count > 0 do 
                Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,keys[math.floor((8/Game():GetNumPlayers()))],Game():GetRoom():GetCenterPos()-Vector(0,64),Vector.Zero,ent)
                key_count = key_count - (8/Game():GetNumPlayers())
            end
        end

        GODMODE.util.macro_on_players(function(player) 
            GODMODE.save_manager.set_player_data(player,"SOCPenalty","0")
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()

            for i=0,4 do 
                if player:GetCard(i) == GODMODE.cards_pills.cards.soc then 
                    player:SetCard(i,Card.CARD_NULL)
                end
            end
        end)

        if GODMODE.is_at_palace and GODMODE.is_at_palace() then
            local mural = Isaac.Spawn(Isaac.GetEntityTypeByName("Lucifer's Palace Mural"), Isaac.GetEntityVariantByName("Lucifer's Palace Mural"), 0, Game():GetRoom():GetCenterPos(), Vector.Zero, nil)
            mural:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            mural:Update()
        end
    end

    local door_hazards = {"Webbed","Void","Spiked","Wired","Spooked","WiredGood"}
    local door_hazards_good = {["WiredGood"] = true}

    function GODMODE.mod_object:new_room()
        if not GODMODE.save_manager.has_loaded then 
            if not GODMODE.util.is_start_of_run() then
                GODMODE.util.init_rand(tonumber(GODMODE.save_manager.get_data("RandSeed","64")))
                GODMODE.save_manager.load()
                GODMODE.save_manager_lock = true
            else
                GODMODE.save_manager.wipe()
                GODMODE.save_manager.wipe_persistent_entities()
                GODMODE.util.init_rand()
            end
    
            GODMODE.save_manager.save()    
            GODMODE.save_manager.load()

            GODMODE.util.macro_on_players(function(player)
                local data = GODMODE.get_ent_data(player)
                data.red_coin_count = tonumber(GODMODE.save_manager.get_player_data(player, "RedCoinCount", "0"))
    
                if data.red_coin_count > 0 then
                    data.red_coin_display = 100
                end
            end)
    
            Game().BlueWombParTime = tonumber(GODMODE.save_manager.get_config("HushTimeMins","35",true))*60*30
            Game().BossRushParTime = tonumber(GODMODE.save_manager.get_config("BRTimeMins","20"))*60*30    
        end

        local room = Game():GetRoom()

        if GODMODE.is_in_secrets() then 
            if room:GetType() == RoomType.ROOM_CHEST then 
                local ind = 1
                local start_grid = -2
                local row_size = 8 
                local item_list = GODMODE.achievements.item_map
                local last_grid = 0

                for item,_ in pairs(item_list) do 
                    local ped = Isaac.Spawn(Isaac.GetEntityTypeByName("[GODMODE] Unlock Pedestal"),Isaac.GetEntityVariantByName("[GODMODE] Unlock Pedestal"),ind,Vector.Zero,Vector.Zero,nil)
                    last_grid = (start_grid+math.ceil(ind/row_size)*(56+4))+(ind-1)*3
                    ped.Position = room:GetGridPosition(last_grid)
                    ped:Update()
                    ped.Velocity = Vector.Zero
                    ped.Position = GODMODE.get_ent_data(ped).anchor_pos

                    ind = ind + 1 

                end

                local ped = Isaac.Spawn(Isaac.GetEntityTypeByName("[GODMODE] Unlock Pedestal"),Isaac.GetEntityVariantByName("[GODMODE] Unlock Pedestal"),0,Vector.Zero,Vector.Zero,nil)
                ped.Position = room:GetGridPosition(last_grid+3)
                ped:Update()
                ped.Velocity = Vector.Zero
                ped.Position = GODMODE.get_ent_data(ped).anchor_pos


                if StageAPI then 
                    StageAPI.ChangeRoomGfx(GODMODE.make_room_gfx(GODMODE.unlock_room_gfx))
                end

                Isaac.ExecuteCommand("debug 8")
                Isaac.ExecuteCommand("debug 3")
            elseif Game():GetFrameCount() > 10 then 
                Game():FinishChallenge()
            else 
                if Game():GetLevel():GetStageType() ~= StageType.STAGETYPE_ORIGINAL then 
                    Isaac.ExecuteCommand("stage 1")
                end
                
                Isaac.ExecuteCommand("goto s.chest.10000")
            end
        end

        if GODMODE.is_at_palace and GODMODE.is_at_palace() then            
            if room:GetType() == RoomType.ROOM_BOSS then
                if not StageAPI.InExtraRoom() then 
                    StageAPI.SetRoomFromList(GODMODE.fallen_light_entrance, true, false, true, room:GetDecorationSeed(), room:GetRoomShape(), false)
                    GODMODE.set_palace_stage(GODMODE.get_palace_stage())                        
                else
                    GODMODE.util.macro_on_players(function(player) 
                        player.Position = room:GetCenterPos() + Vector(-24,160)
                    end)
                end
            end
        end
        
        local room_data = Game():GetLevel():GetCurrentRoomDesc().Data

        if room:GetType() == RoomType.ROOM_DEVIL and room_data.Name == "Adramolech's Fury" then
            local ind = 0
            GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,nil,function(pickup) 
                pickup = pickup:ToPickup()
                pickup.OptionsPickupIndex = 1
                pickup:GetSprite():ReplaceSpritesheet(5,"gfx/grid/options_altar_"..pickup.OptionsPickupIndex..".png")
                pickup:GetSprite():LoadGraphics()
                ind = ind + 1
            end)
        end

        local enter_door = Game():GetLevel().EnterDoor
        local feather_duster_ct = GODMODE.util.total_item_count(Isaac.GetItemIdByName("Feather Duster"))
        
        if Game().Challenge == Challenge.CHALLENGE_NULL and enter_door > -1 and not room:HasCurseMist() and (room:IsFirstVisit() or GODMODE.save_manager.get_data("VoidSpawned","false") == "true" and GODMODE.save_manager.get_config("COTVDoorHazardFX", "true") == "true") then 
            local room_rng = RNG()
            room_rng:SetSeed(room:GetDecorationSeed()+(Game():GetLevel():GetCurrentRoomDesc().VisitedCount-1)*10,1)
            local hazard_type = Isaac.GetEntityTypeByName("Door Hazard")
            local hazard_var = Isaac.GetEntityVariantByName("Door Hazard")
            local void_spawned = GODMODE.save_manager.get_data("VoidSpawned","false") == "true"

            local hazard_mod = 1.0
            if not room:IsFirstVisit() then 
                hazard_mod = 4.0                 
                
                GODMODE.util.macro_on_enemies(nil,hazard_type,hazard_var,nil,function(hazard)
                    hazard:Remove()
                end)
            end        

            for slot=0,DoorSlot.NUM_DOOR_SLOTS do 
                local door = room:GetDoor(slot)
                if slot ~= enter_door and door ~= nil and not door.TargetRoomType ~= RoomType.ROOM_SECRET and door.TargetRoomType ~= RoomType.ROOM_SUPERSECRET
                        and not door:IsRoomType(RoomType.ROOM_SUPERSECRET) and not door:IsRoomType(RoomType.ROOM_SECRET)
                        and room_rng:RandomFloat() < 0.1 * tonumber(GODMODE.save_manager.get_config("DoorHazardChanceMod","1.0")) * hazard_mod then

                    local door = Isaac.Spawn(hazard_type,hazard_var,0,room:GetDoorSlotPosition(slot),Vector.Zero,nil)
                    local door_data = GODMODE.get_ent_data(door)
                    door_data.door_slot = slot+1
                    if not void_spawned or room:IsFirstVisit() then 
                        door_data.hazard_profile = door_hazards[room_rng:RandomInt(#door_hazards)+1]
                    else 
                        door_data.hazard_profile = "Void" 
                    end
                    door:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    door:Update()

                    if door_hazards_good[door_data.hazard_profile] ~= true and feather_duster_ct > 0 and room:IsFirstVisit() then 
                        door:Remove()
                    end
                end
            end                    
        end

        GODMODE.alt_entries.alt_room_count = {}
        GODMODE.override_attempted = false
        GODMODE.delirious_count = 1

        for i,ent in ipairs(Isaac.GetRoomEntities()) do
            for ind,alt in ipairs(GODMODE.alt_entries.entries) do
                if alt.rep_type == ent.Type and alt.rep_variant == ent.Variant and (alt.rep_subtype == nil or alt.rep_subtype == ent.SubType) then
                    GODMODE.alt_entries.alt_room_count[alt.rep_type..","..alt.rep_variant..","..alt.rep_subtype] = (GODMODE.alt_entries.alt_room_count[alt.rep_type..","..alt.rep_variant..","..alt.rep_subtype] or 0) + 1
                end
            end
        end

        local subtype = Game():GetLevel():GetCurrentRoomDesc().Data.Subtype
        if room:GetType() == RoomType.ROOM_TREASURE and (subtype == 1 or subtype == 3) then
            if GODMODE.save_manager.get_config("BothRepPathItems", "true") == "false" and Game():GetLevel():GetStageType() > StageType.STAGETYPE_AFTERBIRTH or Game():GetLevel():GetStageType() < StageType.STAGETYPE_REPENTANCE then

                if GODMODE.util.count_enemies(nil, Isaac.GetEntityTypeByName("Golden Scale"), Isaac.GetEntityVariantByName("Golden Scale")) == 0 then 
                    local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())
                    local scale = Isaac.Spawn(Isaac.GetEntityTypeByName("Golden Scale"), Isaac.GetEntityVariantByName("Golden Scale"), 0, pos, Vector(0,0), nil)
                    scale:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                end

                local more_options = GODMODE.util.total_item_count(CollectibleType.COLLECTIBLE_MORE_OPTIONS)
                if more_options > 0 then 
                    local cur_index = 0
                    GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,nil,function(item)
                        item:ToPickup().OptionsPickupIndex = cur_index+1
                        item:GetSprite():ReplaceSpritesheet(5,"gfx/grid/options_altar_"..(cur_index+1)..".png")
                        item:GetSprite():LoadGraphics()
                        cur_index = ((cur_index + 1) % math.min(5,more_options + 1))
                    end)
                end
            end
        end

        if Game():GetLevel():GetStage() == LevelStage.STAGE4_3 and GODMODE.save_manager.get_config("BlueWombRework","true",true) == "true" and room:GetType() == RoomType.ROOM_DEFAULT then
            room:SetWallColor(Color.Default)
            room:SetFloorColor(Color.Default)
        end

        if room:GetDecorationSeed() == tonumber(GODMODE.save_manager.get_data("SOCSpawnSeed","-1")) then 
            Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,GODMODE.cards_pills.cards.soc,room:FindFreePickupSpawnPosition(room:GetCenterPos()),Vector.Zero,nil)
            GODMODE.save_manager.set_data("SOCSpawnSeed","-1")
        end

        if GODMODE.util.has_curse(Isaac.GetCurseIdByName("Blessing of Patience!")) and not room:IsClear() then 
            local enemies = Isaac.GetRoomEntities()

            for _,enemy in ipairs(enemies) do 
                if enemy:IsVulnerableEnemy() then 
                    enemy:AddFreeze(EntityRef(Isaac.GetPlayer()), 60)
                end
            end

            GODMODE.util.macro_on_players(function(player) GODMODE.get_ent_data(player).patience_counter = 41 end)
        end

        if room:GetType() == RoomType.ROOM_BOSS then 
            GODMODE.util.macro_on_players(function(player) 
                if player.SubType == Isaac.GetPlayerTypeByName("Tainted Elohim",true) then 
                    GODMODE.save_manager.set_player_data(player,"BossDMG",player:GetTotalDamageTaken())
                end
            end)
        end
    end

    function GODMODE.mod_object:room_rewards(rng, pos)
        local level = Game():GetLevel()
        local room = Game():GetRoom()
        if level:GetStage() == LevelStage.STAGE5 and level:GetStageType() == StageType.STAGETYPE_ORIGINAL and GODMODE.is_at_palace and room:GetType() == RoomType.ROOM_BOSS and GODMODE.util.total_item_count(Isaac.GetItemIdByName("Blood Key")) > 0 then --palace entrance!
            local portal = Isaac.Spawn(Isaac.GetEntityTypeByName("Ivory Portal"), Isaac.GetEntityVariantByName("Ivory Portal"), 0, room:FindFreePickupSpawnPosition(room:GetCenterPos()+Vector(-64,0)),Vector.Zero,nil)
            portal:Update()
        end
    

        local room_data = Game():GetLevel():GetCurrentRoomDesc()
        if (room:GetType() == RoomType.ROOM_MINIBOSS or room_data.SurpriseMiniboss == true) and room_data.Data.SubType ~= 15 then --15 = Krampus
            local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())
            local rewards = {
                function() 
                    Isaac.Spawn(Isaac.GetEntityTypeByName("Heart Container (Pickup)"), Isaac.GetEntityVariantByName("Heart Container (Pickup)"), 0, pos, Vector.Zero, nil)
                end,
                function() 
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, pos, Vector(Isaac.GetPlayer():GetDropRNG():RandomFloat()*4-2,Isaac.GetPlayer():GetDropRNG():RandomFloat()*4-2), nil)
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, 0, pos, Vector(Isaac.GetPlayer():GetDropRNG():RandomFloat()*4-2,Isaac.GetPlayer():GetDropRNG():RandomFloat()*4-2), nil)
                end,
                function() 
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_ETERNALCHEST, 0, pos, Vector.Zero, nil)
                end
            }

            rewards[Isaac.GetPlayer():GetDropRNG():RandomInt(#rewards)+1]()            
            return true
        end

        if room:GetType() == RoomType.ROOM_BOSS then 
            GODMODE.util.macro_on_players(function(player) 
                if player.SubType == Isaac.GetPlayerTypeByName("Tainted Elohim",true) then 
                    local dmg = tonumber(GODMODE.save_manager.get_player_data(player,"BossDMG","0"))

                    if dmg <= player:GetTotalDamageTaken() then 
                        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then 
                            GODMODE.save_manager.set_player_data(player,"ElohimBRStatBoost", tonumber(GODMODE.save_manager.get_player_data(player,"ElohimBRStatBoost","0"))+1)
                            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_RANGE)
                            player:EvaluateItems()
                        end

                        player:AddBrokenHearts(-2+-(math.min(1,player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHRIGHT))))
                        player:AddEternalHearts(2)
                    end
                end
            end)
        end

        if room:GetType() == RoomType.ROOM_DEFAULT then
            if GODMODE.util.has_curse(Isaac.GetCurseIdByName("Blessing of Fortitude!")) then
                if tonumber(GODMODE.save_manager.get_data("FortitudeCards","0")) < 2 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_HOLY, room:FindFreePickupSpawnPosition(pos), Vector.Zero, nil)
                    GODMODE.save_manager.set_data("FortitudeCards",tonumber(GODMODE.save_manager.get_data("FortitudeCards","0"))+1)
                    return true
                end
            end
            
            if GODMODE.util.has_curse(Isaac.GetCurseIdByName("Blessing of Justice!")) then
                local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())
                local rewards = {
                    function() 
                        local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, pos, Vector.Zero, nil)
                        pickup:ToPickup().OptionsPickupIndex = 120
                    end,
                    function() 
                        local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, 0, pos, Vector.Zero, nil)
                        pickup:ToPickup().OptionsPickupIndex = 120
                    end,
                    function() 
                        local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, 0, pos, Vector.Zero, nil)
                        pickup:ToPickup().OptionsPickupIndex = 120
                    end,
                    function() 
                        local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, 0, pos, Vector.Zero, nil)
                        pickup:ToPickup().OptionsPickupIndex = 120
                    end
                }

                for i=1,#rewards do
                    pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())
                    rewards[i]()       
                end

                return true
            end
        end
    end


    function GODMODE.mod_object:pre_entity_spawn(type,variant,subtype,pos,vel,spawner,seed)
        if type < EntityType.ENTITY_EFFECT and (type > 9 or type == 5 or type == 6) then
            --Alt enemy / pickup generation
            local alt_enabled = (GODMODE.save_manager.get_config("EnemyAlts","true") == "true" and type > 9) 
                or (GODMODE.save_manager.get_config("PickupAlts","true") == "true" and (type == 5 or type == 6))
                
            if spawner == nil and alt_enabled and Game():GetRoom():IsFirstVisit() and not Game():GetRoom():IsFirstEnemyDead() then
                for ind,alt in ipairs(GODMODE.alt_entries.entries) do
                    local alt_cap = alt.max_in_room

                    if alt_cap then 
                        if type == 5 or type == 6 then 
                            alt_cap = alt_cap + tonumber(GODMODE.save_manager.get_config("PickupCapModifier","0"))
                        else 
                            alt_cap = alt_cap + tonumber(GODMODE.save_manager.get_config("EnemyCapModifier","0"))
                        end
                    end

                    if type == alt.type and variant == alt.variant and (alt.subtype == nil or subtype == alt.subtype) and (alt.max_in_room == nil or GODMODE.alt_entries.alt_room_count and GODMODE.alt_entries.alt_room_count[alt.rep_type..","..alt.rep_variant..","..alt.rep_subtype] == nil or GODMODE.alt_entries.alt_room_count and GODMODE.alt_entries.alt_room_count[alt.rep_type..","..alt.rep_variant..","..alt.rep_subtype] < alt_cap) then
                        local chance_function = alt.rep_chance_function or GODMODE.alt_entries.default_chance_function
                        local chance_modifier = 1.0
                        
                        if type == 5 or type == 6 then 
                            chance_modifier = tonumber(GODMODE.save_manager.get_config("PickupModifier","1.0"))                            
                        else 
                            chance_modifier = tonumber(GODMODE.save_manager.get_config("EnemyModifier","1.0"))                            
                        end


                        if chance_function((alt.rep_chance[Game().Difficulty+1] or alt.rep_chance[1]) * chance_modifier, alt.type, alt.variant, alt.subtype, alt.rep_type, alt.rep_variant) then
                            GODMODE.alt_entries.alt_room_count = GODMODE.alt_entries.alt_room_count or {}
                            GODMODE.alt_entries.alt_room_count[alt.rep_type..","..alt.rep_variant..","..alt.rep_subtype] = (GODMODE.alt_entries.alt_room_count[alt.rep_type..","..alt.rep_variant..","..alt.rep_subtype] or 0) + 1
                            --GODMODE.log("[GODMODE_ACHIEVED] Replaced entity \'"..alt.type.."\' with entity \'"..alt.rep_type.."\', chance is "..(chance*100).."%", true)
                            return {alt.rep_type, alt.rep_variant, alt.rep_subtype or 0, seed}
                        end
                    end
                end
            end
        end
    end

    function GODMODE.mod_object:pre_npc_update(ent)
        if GODMODE.vs_played_in == nil then GODMODE.vs_played_in = {} end
        if GODMODE.bosses[ent.Variant] and Game():GetRoom():GetType() == RoomType.ROOM_BOSS and GODMODE.vs_played_in[Game():GetRoom():GetDecorationSeed()] ~= true and not StageAPI then
            GODMODE.vs_sprite:ReplaceSpritesheet(0, GODMODE.bosses[ent.Variant].portrait)
            GODMODE.vs_sprite:ReplaceSpritesheet(1, GODMODE.bosses[ent.Variant].name)
            GODMODE.vs_sprite:ReplaceSpritesheet(4, GODMODE.bosses[ent.Variant].spot)
            GODMODE.vs_sprite:LoadGraphics()
            GODMODE.vs_played_in[Game():GetRoom():GetDecorationSeed()] = true
            GODMODE.cur_splash = GODMODE.vs_sprite
            GODMODE.cur_splash_pos = Vector(128,128)
        end

        if GODMODE.is_animating() then
            ent.Velocity = ent.Velocity * 0.2
            return true
        end
    end

    function GODMODE.mod_object:familiar_update(fam)
        if GODMODE.is_animating() then
            fam:AddEntityFlags(EntityFlag.FLAG_FREEZE)
        elseif (GODMODE.cur_splash_timeout or 0) > 1 then
            fam:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
        end
    end

    function GODMODE.mod_object:laser_update(laser)
        if laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer() and (laser.FrameCount == 1 or laser.SpawnerEntity:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)) then
            local player = laser.SpawnerEntity:ToPlayer()

            if ((player:GetName() == "Deli" or player:GetName() == "Tainted Deli") and player:GetFireDirection() ~= Direction.NO_DIRECTION)
                and (not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO) and not player:HasWeaponType(WeaponType.WEAPON_TEARS)) then
                local data = GODMODE.get_ent_data(player)
                local flag = data.deli_last_fire_frame ~= Game():GetFrameCount()

                if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then
                    flag = Game():GetFrameCount() - data.deli_last_fire_frame > 10
                elseif player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
                    flag = Game():GetFrameCount() % 20 == 1
                end
                
                data.cur_deli_ang = laser.SpriteRotation
                local margin = math.deg(math.abs(math.rad(laser.SpriteRotation) - math.rad(data.cur_deli_ang-90)))

                if laser.FrameCount == 1 and laser:HasTearFlags(TearFlags.TEAR_LASERSHOT) and margin >= 45 then 
                    local col = laser:GetColor() 
                    laser:SetColor(Color(col.R,col.G,col.B,col.A * 0.15),99,10000,true,true)
                end

                if data.deli_last_fire_frame == nil or flag and not player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) then
                    data.proj_ref = laser
                    data.deli_last_fire_frame = Game():GetFrameCount()
                    GODMODE.players["Deli"].clone_fire(player, laser.Position, laser)
                end
            end
        end
    end

    -- function GODMODE.mod_object:laser_init(laser)
    --     if laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer() then
    --         local player = laser.SpawnerEntity:ToPlayer()

    --         if player:GetName() == "The Sign" then
    --             local data = GODMODE.get_ent_data(player)
    --             if data.sign_not == true then else 
    --                 laser.Position = EntityLaser.CalculateEndPoint(player.Position,Vector(-1,0):Resized(1):Rotated(player:GetHeadDirection()*90),laser.ParentOffset,player,16)
    --                 laser.EndPoint = player.Position 
    --                 -- laser.StartAngleDegrees = (laser.StartAngleDegrees + 180) % 360
    --                 -- laser.LastAngleDegrees = laser.StartAngleDegrees
    --                 -- laser.Angle = math.rad((math.deg(laser.Angle) + 180) % 360)
    --                 -- laser.RotationDegrees = (laser.RotationDegrees + 180) % 360
    --                 -- laser.AngleDegrees = (laser.AngleDegrees + 180) % 360
    --                 laser:SetActiveRotation(0,360,360,false)
    --                 laser:Update()
    --                 laser.MaxDistance = (player.Position - laser.Position):Length()
    --                 laser.DisableFollowParent = true

    --                 -- local start = laser.EndPoint 
    --                 -- data.sign_not = true 
    --                 -- local laser2 = EntityLaser.ShootAngle(laser.Variant,start,(laser.AngleDegrees + 180) % 360,laser.Timeout,laser.ParentOffset,player)
    --                 -- data.sign_not = false
    --                 -- laser2.EndPoint = player.Position
    --                 -- GODMODE.log("HI!!",true)
    --                 -- tear.Position = tear.Position + (Vector(1,1):Resized(1)*player.TearRange):Rotated(tear.Velocity:GetAngleDegrees()-45)
    --                 -- local vel = player:GetTearMovementInheritance(player.Velocity)*0.25
    --                 -- if player:GetFireDirection() == Direction.LEFT or player:GetFireDirection() == Direction.RIGHT then 
    --                 --     vel.Y = 0 else vel.X = 0 end
    --                 -- tear.Velocity = -tear.Velocity + vel * 6
    --                 -- data.sign_tears = data.sign_tears or {}
    --                 -- table.insert(data.sign_tears, tear)
    --             end
    --         end
    --     end
    -- end

    function GODMODE.mod_object:tear_fire(tear)
        if tear.Parent and tear.Parent:ToPlayer() then
            local player = tear.Parent:ToPlayer()

            if player:GetName() == "The Sign" and not player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM) then
                local data = GODMODE.get_ent_data(player)
                if data.sign_not == true or data.celeste_fire == true then else 
                    tear.Position = tear.Position + (Vector(1,1):Resized(1)*player.TearRange):Rotated(tear.Velocity:GetAngleDegrees()-45)
                    local vel = player:GetTearMovementInheritance(player.Velocity)*0.25
                    if player:GetFireDirection() == Direction.LEFT or player:GetFireDirection() == Direction.RIGHT then 
                        vel.Y = 0 else vel.X = 0 end
                    if tear.Velocity.X > 0 and vel.X < 0 then vel.X = vel.X * 3 elseif tear.Velocity.X < 0 and vel.X > 0 then vel.X = vel.X * 3 end 
                    if tear.Velocity.Y > 0 and vel.Y < 0 then vel.Y = vel.Y * 3 elseif tear.Velocity.Y < 0 and vel.Y > 0 then vel.Y = vel.Y * 3 end 
                    tear.Velocity = -tear.Velocity + vel * 2
                    data.sign_tears = data.sign_tears or {}
                    table.insert(data.sign_tears, tear)
                end
            elseif (player:GetName() == "Deli" or player:GetName() == "Tainted Deli") and player:GetFireDirection() ~= Direction.NO_DIRECTION then
                local data = GODMODE.get_ent_data(player)

                if data.deli_last_fire_frame == nil or data.deli_last_fire_frame ~= Game():GetFrameCount() then
                    data.proj_ref = tear
                    data.cur_deli_ang = tear.Velocity:GetAngleDegrees()
                    data.deli_last_fire_frame = Game():GetFrameCount()
                    GODMODE.players["Deli"].clone_fire(player, tear.Position - tear.Velocity, tear)
                end
            elseif player:GetName() == "Tainted Elohim" and tear.Variant == TearVariant.BLUE then
                tear:ChangeVariant(TearVariant.BLOOD)
            end
        end
    end

    function GODMODE.mod_object:player_init(player)
        
    end

    function GODMODE.mod_object:player_update(player)
        if GODMODE.is_animating() then
            player.ControlsEnabled = false
        elseif (GODMODE.cur_splash_timeout or 0) > 0 then
            player.ControlsEnabled = true
        end

        local data = GODMODE.get_ent_data(player)

        if data then
            data.player_inited = GODMODE.save_manager.get_player_data(player, "Init", "false") == "true"
    
            if data.player_inited == false then
                if GODMODE.players[player:GetName()] and GODMODE.players[player:GetName()].init then
                    GODMODE.players[player:GetName()].init(player)
                end
                
                data.player_inited = true
    
                if Isaac.GetChallenge() == Isaac.GetChallengeIdByName("Sugar Rush!") then 
                    for i=1,4 do 
                        player:AddCollectible(Isaac.GetItemIdByName("Sugar!"))
                    end
                -- elseif Isaac.GetChallenge() == Isaac.GetChallengeIdByName("The Galactic Approach") then 
                --     local celeste_items = {
                --         Isaac.GetItemIdByName("Celestial Paw"),
                --         Isaac.GetItemIdByName("Celestial Tail"),
                --         Isaac.GetItemIdByName("Celestial Collar"),
                --     }
    
                    
    
                --     GODMODE.save_manager.set_player_data(player, "CelestialItems", "3")
                --     GODMODE.save_manager.set_player_data(player, "Celestial", "true")
                end
    
                GODMODE.save_manager.set_player_data(player, "Init", "true")
            end

            data.time = data.time + 1
            data.real_time = data.real_time + 1
            
            if data.player_light ~= nil then 
                local count = #data.player_light - 1
                local ang_inc = math.rad(360/count)
                local dist = 64
                for i=1,count+1 do
                    if not (data.player_light[i].Type == EntityType.ENTITY_EFFECT and data.player_light[i].Variant == EffectVariant.LIGHT) then
                        data.player_light[i]:Remove()
                        table.remove(data.player_light, i)
                        break
                    end

                    if i > 1 then 
                        local off = Vector(math.cos(ang_inc*i)*dist,math.sin(ang_inc*i)*dist)
                        data.player_light[i].Position = player.Position + off

                    else
                        data.player_light[i].Position = player.Position
                    end
                end
            end

            if GODMODE.util.has_curse(Isaac.GetCurseIdByName("Blessing of Kindness!")) then
                if not Game():GetRoom():IsClear() and not player:IsDead() then  
                    data.kindness_counter = (data.kindness_counter or 201) - 1

                    if player:GetFireDirection() ~= Direction.NO_DIRECTION then 
                        data.kindness_counter = 201
                    end

                    local percent = (201 - data.kindness_counter or 201) / 201
                    player:SetColor(Color.Lerp(player:GetColor(), Color(1,1,0.95,1,0.5,0.2,0.2),percent), 1, 99, false, false)

                    if (data.kindness_counter or 201) <= 0 then 
                        local enemies = Isaac.FindInRadius(player.Position,1024.0, EntityPartition.ENEMY)
                        local enemy = nil
                        local depth = 10

                        for _,en in ipairs(enemies) do 
                            if (enemy == nil or (player.Position-en.Position):Length() < (player.Position-enemy.Position):Length() and en:IsVulnerableEnemy() 
                                and GODMODE.util.is_valid_enemy(en)) and not en:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM) then 
                                enemy = en
                            end
                        end

                        if enemy then 
                            if Game():GetRoom():GetType() == RoomType.ROOM_BOSS and (enemy.Type == EntityType.ENTITY_THE_HAUNT or GODMODE.util.count_enemies(nil,EntityType.ENTITY_GIDEON) > 0) or enemy:IsBoss() then 
                                enemy:TakeDamage(enemy.MaxHitPoints * 0.05, 0, EntityRef(player), 1)
                            else 
                                enemy:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)
                            end

                            local dist = ((enemy.Position-Vector(0,enemy.Size)*enemy.SizeMulti) - player.Position)
                            local count = dist:Length() / 26
                            for i=0, count do 
                                local scale = i / count
                                local pos = player.Position + dist * scale
                                -- local pos = (player.Position-Vector(0,player.Size)*player.SizeMulti) * scale + (enemy.Position-Vector(0,enemy.Size)*enemy.SizeMulti) * (1.0-scale)
                                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 1, pos, Vector.Zero, player)                                
                            end

                            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIPPLE_POOF, 1, enemy.Position-Vector(0,enemy.Size)*enemy.SizeMulti, Vector.Zero, enemy)    
                            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIPPLE_POOF, 1, player.Position-Vector(0,8)*player.SizeMulti, Vector.Zero, player)    
                            SFXManager():Play(SoundEffect.SOUND_GASCAN_POUR,Options.SFXVolume + 0.25)
                            data.kindness_counter = 201
                        end
                    end
                else
                    data.kindness_counter = 201
                end
            end

            if GODMODE.util.has_curse(Isaac.GetCurseIdByName("Blessing of Patience!")) then 
                data.patience_counter = (data.patience_counter or 21) - 1

                if (data.patience_counter or 21) > 0 then 
                    data.patience_shoot = player.ControlsEnabled 
                    player.ControlsEnabled = false
                elseif (data.patience_counter or 21) == 0 then 
                    player.ControlsEnabled = data.patience_shoot or true
                end
            end
        end

        if GODMODE.players[player:GetName()] then 
            if GODMODE.players[player:GetName()].update then
                GODMODE.players[player:GetName()].update(player)
            end
            if GODMODE.players[player:GetName()].pocket_item and player:GetActiveItem(ActiveSlot.SLOT_POCKET) ~= GODMODE.players[player:GetName()].pocket_item then
                player:AddCollectible(GODMODE.players[player:GetName()].pocket_item, GODMODE.players[player:GetName()].pocket_charge, true, ActiveSlot.SLOT_POCKET)
            end

            if GODMODE.players[player:GetName()].red_health ~= nil and GODMODE.players[player:GetName()].red_health == false then --remove red health for characters who cant have it
                if player:GetMaxHearts() > 0 then 
                    local hearts = player:GetMaxHearts()
                    player:AddMaxHearts(-hearts)

                    if GODMODE.players[player:GetName()].soul_health ~= nil and GODMODE.players[player:GetName()].soul_health == false then 
                        player:AddBlackHearts(hearts)
                    else
                        player:AddSoulHearts(hearts)
                    end
                end
        
                if player:GetHearts() > 0 then 
                    player:AddHearts(-player:GetHearts())
                end
            end
        end
    end

    function GODMODE.mod_object:eval_cache(player, cache)
        if player.GetName ~= nil and GODMODE.players[player:GetName()] and GODMODE.players[player:GetName()].stats then
            if GODMODE.players[player:GetName()].stats[cache] then 
                GODMODE.players[player:GetName()].stats[cache](player)
            end
        end

        local penalty = tonumber(GODMODE.save_manager.get_player_data(player,"SOCPenalty","0"))
        if penalty > 0 then 
            if cache == CacheFlag.CACHE_DAMAGE then 
                player.Damage = player.Damage * (1.0-math.min(0.5,penalty*0.05))
            elseif cache == CacheFlag.CACHE_FIREDELAY then 
                player.MaxFireDelay = player.MaxFireDelay * (1.0+math.min(0.5,penalty*0.05))
            end
        end
    end
        
    function GODMODE.mod_object:pickup_collide(pickup,ent,entfirst)
        local data = GODMODE.get_ent_data(pickup)
        if ent:ToPlayer() then
            local player = ent:ToPlayer()

            if pickup.Variant == PickupVariant.PICKUP_HEART and GODMODE.players[player:GetName()] and GODMODE.players[player:GetName()].red_health ~= nil and GODMODE.players[player:GetName()].red_health == false 
                and (pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_HALF or pickup.SubType == HeartSubType.HEART_BLENDED or pickup.SubType == HeartSubType.HEART_SCARED or pickup.SubType == HeartSubType.HEART_DOUBLEPACK or pickup.SubType == HeartSubType.HEART_ROTTEN) then 
                return pickup.Price > 0
            end

            if (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM) and (Game():GetItemPool():GetPoolForRoom(Game():GetRoom():GetType(), Game():GetRoom():GetDecorationSeed()) == ItemPoolType.POOL_ANGEL) and not pickup.Touched and not data.added_to_angel then 
                data.added_to_angel = true
                GODMODE.add_angel_collected(player,pickup.SubType)
            end

            if pickup.Variant == PickupVariant.PICKUP_TROPHY then 
                if Game().Challenge == Isaac.GetChallengeIdByName("Sugar Rush!") then 
                    local sugar = Isaac.GetItemIdByName("Sugar!")
                    local flag = GODMODE.achievements.is_item_unlocked(sugar)
                    GODMODE.achievements.unlock_item(sugar)

                    if not flag then 
                        return true
                    end
                elseif Game().Challenge == Isaac.GetChallengeIdByName("The Galactic Approach") then 
                    local paw = Isaac.GetItemIdByName("Celestial Paw")
                    local flag = GODMODE.achievements.is_item_unlocked(paw)
                    GODMODE.achievements.unlock_item(paw)

                    if not flag then 
                        return true
                    end
                elseif Game().Challenge == Isaac.GetChallengeIdByName("Out Of Time") then 
                    local item = Isaac.GetItemIdByName("A Second Thought")
                    local flag = GODMODE.achievements.is_item_unlocked(item)
                    GODMODE.achievements.unlock_item(item)

                    if not flag then 
                        return true 
                    end
                end
            end

            if GODMODE.cur_splash ~= nil then 
                return false
            end

            if entfirst == false and Game():GetRoom():GetType() ~= RoomType.ROOM_CURSE and pickup.Variant == PickupVariant.PICKUP_TAROTCARD and GODMODE.cards_pills.is_red_key(pickup.SubType) then 
                local sub = pickup.SubType 

                if sub > GODMODE.cards_pills.cards.pok_8 and sub <= GODMODE.cards_pills.cards.pok_2 or sub == Card.CARD_CRACKED_KEY then 
                    local off = math.abs(GODMODE.cards_pills.cards.pok_2 - sub) + 2
                    if sub == Card.CARD_CRACKED_KEY then off = 1 end
                    local cur_count = GODMODE.cards_pills.get_red_key_count(player)
                    off = off + cur_count

                    local new = GODMODE.cards_pills.get_red_key_for_count(off)

                    if new ~= nil then 
                        if off < 9 then 
                            local old = GODMODE.cards_pills.get_red_key_for_count(cur_count)

                            if old ~= nil then 
                                local slot = GODMODE.util.get_card_slot(player,old)

                                if slot > -1 then
                                    player:SetCard(slot, new)
                                    player:AnimateCard(new)
                                    pickup:Remove()
                                    return false
                                end
                            end
                        end
                    end
                end
            end

            -- update COTV timer visual!
            if (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM) and not pickup.Touched and pickup.SubType == Isaac.GetItemIdByName("A Second Thought") then 
                GODMODE.cotv_timer_st_cache = (GODMODE.cotv_timer_st_cache or 0) + 1
            end
        end
    end

    function GODMODE.mod_object:pickup_update(pickup)
        if pickup.Variant == PickupVariant.PICKUP_TAROTCARD and GODMODE.cards_pills.is_red_key(pickup.SubType) and pickup.FrameCount < 2 then 
            GODMODE.util.macro_on_players(function(player) 
                if GODMODE.get_ent_data(player).red_key_prevent_dupe == (Game():GetFrameCount() - pickup.FrameCount) then 
                    pickup:Remove()
                    GODMODE.get_ent_data(player).red_key_prevent_dupe = nil
                end
            end)
        end

        if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM then
            if Game():GetRoom():GetType() == RoomType.ROOM_PLANETARIUM and GODMODE.save_manager.get_config("MultiPlanetItems", "true") == "true" then
                pickup.OptionsPickupIndex = 0 --Enable more than one planetarium item to be picked up in certain rooms

                if pickup.FrameCount == 60 and GODMODE.util.count_enemies(nil,EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, nil) == 1 and GODMODE.util.count_enemies(nil,EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,TrinketType.TRINKET_TELESCOPE_LENS) == 0 and GODMODE.util.total_item_count(TrinketType.TRINKET_TELESCOPE_LENS, true) == 0 then 
                    Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,TrinketType.TRINKET_TELESCOPE_LENS,Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()), Vector.Zero, nil)
                end
            end
            
            if Game():GetRoom():GetType() == RoomType.ROOM_TREASURE and Game():GetLevel():GetStageType() > StageType.STAGETYPE_AFTERBIRTH and GODMODE.save_manager.get_config("BothRepPathItems", "true") == "true" then
                pickup.OptionsPickupIndex = 0
            end

            -- if GODMODE.save_manager.get_config("ShopQualityScale","true") == "true" and pickup:IsShopItem() and false then
            --     local config = Isaac.GetItemConfig():GetCollectible(pickup.SubType)
            --     local data = GODMODE.get_ent_data(pickup)

            --     if config:IsCollectible() and data.priced ~= true then
            --         GODMODE.log("changing!",true)
            --         if pickup.AutoUpdatePrice == false then
            --             data.priced = true 
            --         end
            --         local raw = math.floor(pickup.Price * (0.5 + config.Quality * 0.25))
            --         pickup.Price = math.min(raw, (math.floor(raw/5)+1)*5)
            --     end
            -- end
        end

        if GODMODE.util.has_curse(Isaac.GetCurseIdByName("Blessing of Charity!")) then
            pickup.Price = math.floor(pickup.Price / 2)
        end
    end

    function GODMODE.mod_object:post_get_collectible(coll,pool,decrease,seed)
        if not GODMODE.achievements.is_item_unlocked(coll) and GODMODE.reroll_loop_lock ~= true then
            GODMODE.log(coll.." is locked, rerolling", true)
            GODMODE.reroll_loop_lock = true
            local rep_item = Game():GetItemPool():GetCollectible(pool,false,seed,CollectibleType.COLLECTIBLE_BREAKFAST)
            local depth = 50
            while not GODMODE.achievements.is_item_unlocked(rep_item) and depth > 0 do
                rep_item = Game():GetItemPool():GetCollectible(pool,false,seed,CollectibleType.COLLECTIBLE_BREAKFAST)
                depth = depth - 1
            end
            GODMODE.reroll_loop_lock = nil

            return rep_item
        end
    end

    local blessings = {
        Isaac.GetCurseIdByName("Blessing of Faith!"),
        Isaac.GetCurseIdByName("Blessing of Charity!"),
        Isaac.GetCurseIdByName("Blessing of Fortitude!"),
        Isaac.GetCurseIdByName("Blessing of Justice!"),
        Isaac.GetCurseIdByName("Blessing of Patience!"),
        Isaac.GetCurseIdByName("Blessing of Kindness!"),
    }

    function GODMODE.mod_object:choose_curse(curses)
        local chance = 0.05 + math.min(0.95,GODMODE.util.total_item_count(Isaac.GetItemIdByName("Brass Cross")) * 0.25)
        -- return 2^(Isaac.GetCurseIdByName("Blessing of Patience!")-1)
        local stage = Game():GetLevel():GetStage()
        if Game():GetLevel():GetCurses() & 0 >= 0 and GODMODE.util.random() < chance and Game().Difficulty < Difficulty.DIFFICULTY_GREED and stage ~= LevelStage.STAGE4_3 and stage < LevelStage.STAGE7 then
            return 2^(blessings[GODMODE.util.random(1,#blessings+1)]-1)
        end
    end

    function GODMODE.mod_object:choose_card(rng, card, playing, runes, only_runes)
        local ret = GODMODE.cards_pills.choose_card(rng, card, playing, runes, only_runes)

        if ret ~= Card.CARD_RANDOM then 
            return ret 
        end
    end
    
    function GODMODE.mod_object:use_card(card, player, flags)
        GODMODE.cards_pills.use_card(card,player,flags)
    end

    function GODMODE.mod_object:entity_removed(ent)
        local data = GODMODE.get_ent_data(ent)

        if data and data.persistent_data ~= nil and GODMODE.save_manager_lock ~= true then 
            GODMODE.save_manager.remove_persistent_entity_data(ent)
        end
    end

    function GODMODE.mod_object:choose_trinket(trinket,rng)
        if trinket == Isaac.GetTrinketIdByName("Godmode") then 
            return rng:RandomInt(TrinketType.NUM_TRINKETS-1)+1
        end
    end

    function GODMODE.mod_object:shader_params(shaderName)
        GODMODE.shader_params = GODMODE.shader_params or {}
        if shaderName == 'GODMODE_RewindFx' then
            local playerPos = Isaac.GetPlayer().Position
            local params = {
                    Time = GODMODE.shader_params.godmode_trinket_time
                }
            return params;
        elseif shaderName == 'GODMODE_BlackMushroom' then
            local playerPos = Isaac.GetPlayer().Position
            local params = {
                    Time = Game():GetFrameCount(),
                    Intensity = GODMODE.shader_params.black_mushroom_intensity or 0,
                }
            return params;
        end
    end

    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, GODMODE.mod_object.room_rewards)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, GODMODE.mod_object.eval_cache)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, GODMODE.mod_object.new_level)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, GODMODE.mod_object.new_room)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_UPDATE, GODMODE.mod_object.post_update)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_RENDER, GODMODE.mod_object.post_render)  
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, GODMODE.mod_object.player_init)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, GODMODE.mod_object.player_update)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, GODMODE.mod_object.post_player_render)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_NPC_INIT, GODMODE.mod_object.npc_init)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_NPC_UPDATE, GODMODE.mod_object.npc_update)  
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, GODMODE.mod_object.pre_npc_update)  
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, GODMODE.mod_object.npc_hit)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, GODMODE.mod_object.npc_kill)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, GODMODE.mod_object.pre_entity_spawn)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, GODMODE.mod_object.pickup_update)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, GODMODE.mod_object.pickup_collide)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, GODMODE.mod_object.shader_params)
    -- GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, GODMODE.mod_object.pickup_collide)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, GODMODE.mod_object.familiar_update)  
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, GODMODE.mod_object.tear_fire)  
    -- GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_LASER_INIT , GODMODE.mod_object.laser_init)  
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE , GODMODE.mod_object.laser_update)  
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_GAME_STARTED , GODMODE.mod_object.game_start)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_GAME_END, GODMODE.mod_object.game_end)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, GODMODE.mod_object.game_exit)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, GODMODE.mod_object.post_get_collectible)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, GODMODE.mod_object.choose_curse)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_GET_CARD, GODMODE.mod_object.choose_card)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_USE_CARD, GODMODE.mod_object.use_card)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, GODMODE.mod_object.entity_removed)
    
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, cmd, params)
        if cmd == "fabrun" then --debugging command to simulate runs better than spamming combo
            if params == nil or params == "" or params == "info" or params == "help" or params == "?" then
                Isaac.ConsoleOutput("[Godmode Achieved]\n\nSimulates a run to a specified floor depth. \nIncludes treasure, boss, shop, secret room, beggar, and either devil or angel rooms.\n\n\t Usage: fabrun x\n\t\t x is the depth of floors to simulate")
            else
                local stage = tonumber(params)
                local angel = GODMODE.util.random() < 0.5

                if stage > 0 then 
                    for i=1,stage do
                        if i < 6 then
                            local range = GODMODE.util.random(1,3)
                            if GODMODE.util.random() < 0.05 then range = 4 end
                            if i == 1 then range = 2 end
                            
                            for l=1,range do
                                Isaac.ExecuteCommand("combo 0")
                            end
                        end
            
                        Isaac.ExecuteCommand("combo 2")
            
                        if GODMODE.util.random() < 0.3 then
                            Isaac.ExecuteCommand("combo 1")
                        end
            
                        if i > 0 and GODMODE.util.random() < 0.25 then
                            if angel then
                                Isaac.ExecuteCommand("combo 3")
                            else
                                Isaac.ExecuteCommand("combo 4")
                            end
                        end

                        if GODMODE.util.random() < 0.1 then
                            Isaac.ExecuteCommand("combo 5")
                        end

                        if GODMODE.util.random() < 0.05 then
                            Isaac.ExecuteCommand("combo 6")
                        end
                        if GODMODE.util.random() < 0.05 then
                            Isaac.ExecuteCommand("combo 7")
                        end
                        if GODMODE.util.random() < 0.05 then
                            Isaac.ExecuteCommand("combo 8")
                        end
                        if GODMODE.util.random() < 0.05 then
                            Isaac.ExecuteCommand("combo 9")
                        end
                    end    

                    Isaac.ConsoleOutput("Successfully simulated a run to stage "..params.."\n")
                else
                    Isaac.ConsoleOutput("Stage number needs to be greater than 0\n")
                end
            end

        elseif cmd == "bosstester" then  --debug command to execute a sequence of commands to set up for testing bosses
            Isaac.ExecuteCommand("debug 3")
            Isaac.ExecuteCommand("debug 4")
            Isaac.ExecuteCommand("debug 8")
            Isaac.ExecuteCommand("g c286")
            Isaac.ExecuteCommand("g k5")
            Isaac.ExecuteCommand("g c330")
            Isaac.ExecuteCommand("g c1")
            Isaac.ExecuteCommand("g c1")
            Isaac.ExecuteCommand("g c3")
            Isaac.ExecuteCommand("g c260")
            Isaac.ExecuteCommand("g c179")
            Isaac.ExecuteCommand("g c27")
            Isaac.ExecuteCommand("g c4")

            if params ~= nil and tonumber(params) ~= nil then 
                Isaac.ExecuteCommand("stage "..tonumber(params)) 
            end
        elseif cmd == "dbdps" and params ~= nil and tonumber(params) then 
            local count = tonumber(params)

            for i=0,count do 
                Isaac.ExecuteCommand("g c4")
                Isaac.ExecuteCommand("g c1")

                if i % 2 == 0 then 
                    Isaac.ExecuteCommand("g c16")    
                end
            end
        elseif cmd == "edengrind" then 
            GODMODE.eden_grind_cmd = not (GODMODE.eden_grind_cmd or true)
        elseif cmd == "cotv_debug" then 
            GODMODE.cotv_debug = not (GODMODE.cotv_debug or false)
        end
    end)


    GODMODE.log("Loaded Successfully! (V0.1)", true)
end