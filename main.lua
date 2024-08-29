
GODMODE = GODMODE or {}
GODMODE.rgon_version = "1.0.11b"

-- added version checker for RGON, will notify the user if the installed RGON version is different from the Godmode build
GODMODE.validate_rgon = function()
    if REPENTOGON == nil then return false else 
        return REPENTOGON.Version == "dev build" or REPENTOGON.Version >= GODMODE.rgon_version
    end
end

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
    GODMODE.log("The Binding of Isaac: Repentance is required to play with Godmode: Achieved. There is an Afterbirth+ version on the workshop, check that one out instead. Preventing further code from execution...", true)
    return
else
    -- add new validation step to make sure that REPENTOGON.Version == GODMODE.rgon_version! 
    if REPENTOGON and not GODMODE.validate_rgon() then 
        GODMODE.log("[ERROR] Unable to load Repentogon integration, as your version of Repentogon ("..REPENTOGON.Version..") is not considered more recent than the Repentogon build Godmode is using ("..GODMODE.rgon_version.."). Please validate your Repentogon installation and try again.", true)
    end
    
    GODMODE.mod_id = "AOIGodmodeAchieved"
    GODMODE.mod_object = RegisterMod(GODMODE.mod_id, 1)
    GODMODE.repentance = true --unleashed had same modid
    GODMODE.godmode_ent_type = 700
    GODMODE.registry = include("scripts.definitions.registry")
    GODMODE.console_logging = true --enables/disables log outputting to console for messages that do
    GODMODE.debug_logging = true --enables/disables log outputting to log.txt for messages that do
    
    -- organize extra variables attached to godmode a bit more
    GODMODE.sprites = {}

    -- constants that get updated so that references can be faster
    GODMODE.game = Game()
    GODMODE.room = GODMODE.game:GetRoom()
    GODMODE.level = GODMODE.game:GetLevel()
    GODMODE.sfx = SFXManager()

    GODMODE.paused = false -- just a reference for if mod menus are open

    GODMODE.convert_ent_to = { --temp fix for really odd bug
        ["700.204"] = {type=GODMODE.registry.entities.secret_light.type,variant=GODMODE.registry.entities.secret_light.variant},
        ["700.205"] = {spawn=false,type=GODMODE.registry.entities.red_coin.type,variant=GODMODE.registry.entities.red_coin.variant},
        -- ["700.204"] = {type=GODMODE.registry.entities.heart_container.type,variant=GODMODE.registry.entities.heart_container.variant},
    }

    --A set of checks to ensure it's valid to add godmode data to the specified entity
    function GODMODE.can_have_ent_data(ent)
        return ent ~= nil and type(ent) == "userdata" and ent.GetData ~= nil and type(ent:GetData()) == "table" 
            and (ent.Type < 1000 
                or (GODMODE.godhooks.effect_data_list 
                    and GODMODE.godhooks.effect_data_list[ent.Variant] == true))
    end

    --Had to be on top for save_manager
    function GODMODE.get_ent_data(ent)
        if not GODMODE.can_have_ent_data(ent) then return nil end
        if type(ent) == "userdata" and ent:GetData() ~= nil and type(ent:GetData()) == "table" and ent:GetData()["godmodeachieved"] == nil and ent:GetDropRNG():GetSeed() > 0 then
            ent:GetData()["godmodeachieved"] = {time = -1 + ent:GetDropRNG():RandomInt(1000), real_time = 0}

            if GODMODE.godhooks then 
                GODMODE.godhooks.call_hook_param("data_init",ent.Type,ent,ent:GetData()["godmodeachieved"],ent:GetSprite())
            end
            -- GODMODE.push_monsters("data_init", function(monster, ent, data) return ent.Type == monster.type and ent.Variant == monster.variant end, ent, ent:GetData()["godmodeachieved"])
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
        GODMODE.players = include("scripts.definitions.players")
        GODMODE.armor_blacklist = include("scripts.definitions.armor_blacklist")
        GODMODE.room_override = include("scripts.room_override")
        GODMODE.roomgen = include("scripts.roomgen")
        GODMODE.loaded_rooms = include("scripts.definitions.roomlist")
        GODMODE.bosses = include("scripts.definitions.bosslist")
        GODMODE.cards_pills = include("scripts.definitions.cards_pills")
        GODMODE.d10 = include("scripts.definitions.d10")
        GODMODE.itempools = include("scripts.definitions.itempools")
        GODMODE.achievements = include("scripts.definitions.achievements")
        GODMODE.menu = include("scripts.godmodemenucore")
        GODMODE.options = include("scripts.options") -- DSS
        GODMODE.repentogon = include("scripts.definitions.repentogon")
        GODMODE.special_items = include("scripts.definitions.special_items")
        GODMODE.special_items:fill_item_lists()
        GODMODE.registry = include("scripts.definitions.registry")
        
        GODMODE.shader_params = GODMODE.shader_params or {}
        GODMODE.shader_params.godmode_trinket_time = 0
        GODMODE.shader_params.divine_wrath_time = 0

        if GODMODE.preloads then 
            for _,func in ipairs(preloads) do 
                func()
            end
        end
    end

    GODMODE.save_manager = require("scripts.save_manager")
    GODMODE.mod_object:load_core()
    include("scripts.mod_integration") --EID, ModConfig, StageAPI, Encyclopedia, Enhanced Boss Bars, MiniMapAPI, Soundtrack Menu, Mod Music Callback (MMC), Preappearance, 

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

    function GODMODE.play_ending() 
        if GODMODE.playing_ending then GODMODE.log("Already played Godmode ending!",true) return else 
            if GODMODE.validate_rgon() then 
                Isaac.PlayCutscene(GODMODE.registry.cutscenes.ending)
                GODMODE.playing_ending = Isaac.GetPlayer().InitSeed 
                GODMODE.shader_params.ending_shader = 0.0
            else 
                local ending = Sprite()
                ending:Load("gfx/cutscenes/ending.anm2", true)
                ending.PlaybackSpeed = 0.666
                GODMODE.cur_splash = ending 
                GODMODE.playing_ending = Isaac.GetPlayer().InitSeed 
                MusicManager():Play(GODMODE.registry.music.twinkles, 1.0)
                MusicManager():UpdateVolume()    
            end
    
            GODMODE.log("Playing Godmode ending!",true)    
        end
    end

    function GODMODE.is_in_secrets() 
        return GODMODE.game.Challenge == GODMODE.registry.challenges.secrets
    end

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
        GODMODE.playing_ending = nil 
        GODMODE.shader_params.ending_shader = nil
        GODMODE.save_manager.allow_persistent_load = true
        GODMODE.godhooks.call_hook("game_start",continued)
        -- GODMODE.push_items_monsters("game_start", function(item,continued) return #GODMODE.util.does_player_have(item.instance) > 0 end, function(monster,continued) return GODMODE.util.count_enemies(nil, monster.type, monster.variant) > 0 end, continued)
        GODMODE.cotv_timer_st_cache = nil

        -- THE FUTURE support!
        if TheFuture and not TheFuture.ModdedCharacterDialogue["Recluse"] then 
            TheFuture.ModdedCharacterDialogue["Recluse"] = {"yeesh, can you see me enough?","talk about having too many eyes..."}
            TheFuture.ModdedTaintedCharacterDialogue["Tainted Recluse"] = {"you seem like you make a lot of friends...","shame that they don't seem to like you though..."}
            TheFuture.ModdedCharacterDialogue["Xaphan"] = {"dang, you commit yourself to follow him?","he tends to be merciless, but you do you."}
            TheFuture.ModdedTaintedCharacterDialogue["Tainted Xaphan"] = {"you seem to have taken his word quite literally,","good for you i guess?"}
            TheFuture.ModdedCharacterDialogue["Deli"] = {"oof, you've looked better.","maybe the future can help you."}
            TheFuture.ModdedTaintedCharacterDialogue["Tainted Deli"] = {"you look kinda slimey man stay sober,","you can see what happens if you don't..."}
            TheFuture.ModdedCharacterDialogue["Gehazi"] = {"i do not have any coins for you buddy,","sorry. i can show you your future, at least"}
            TheFuture.ModdedTaintedCharacterDialogue["Tainted Gehazi"] = {"sorry i REALLY do not have any coins for you.","I will let you see the future, deal?"}
            TheFuture.ModdedCharacterDialogue["Elohim"] = {"oh hey there,","you seem to have a handle on what is going on here.","good for you!"}
            TheFuture.ModdedTaintedCharacterDialogue["Tainted Elohim"] = {"DONT HURT ME PLEASE!","I see your eyes, I'll just let you through"}
            TheFuture.ModdedCharacterDialogue["The Sign"] = {"your future is bleak, dang...","enjoy it while it lasts..."}
        end
    end

    function GODMODE.mod_object:game_end(won)
        GODMODE.playing_ending = nil 
    end 

    function GODMODE.mod_object:game_exit(should_save)
        if should_save then
            GODMODE.save_manager_lock = true

            for _,ent in ipairs(Isaac.GetRoomEntities()) do 
                local data = GODMODE.get_ent_data(ent)

                if data ~= nil and data.persistent_data ~= nil then 
                    GODMODE.save_manager.add_persistent_entity_data(ent)
                    ent:Remove()
                end
            end

            GODMODE.save_manager.save()
            GODMODE.save_manager_lock = false
        end

        GODMODE.save_manager.has_loaded = false
        GODMODE.save_manager.allow_persistent_load = false

        MusicManager():Enable()
        GODMODE.sfx:Stop(GODMODE.registry.sounds.ending_voiceover)
        GODMODE.sfx:Stop(GODMODE.registry.sounds.ending_voiceover_joke)
        GODMODE.cur_splash = nil
    end 

    function GODMODE.mod_object:post_update()
        GODMODE.paused = (ModConfigMenu ~= nil and ModConfigMenu.IsVisible or false) or (DeadSeaScrollsMenu == nil and false or DeadSeaScrollsMenu.IsOpen())
        -- used to blacken screen after taking damage
        GODMODE.shader_params.godmode_trinket_time = math.max(0,(GODMODE.shader_params.godmode_trinket_time or 0)-1)
        GODMODE.shader_params.divine_wrath_time = math.max(0,(GODMODE.shader_params.divine_wrath_time or 0)-1)

        if GODMODE.timers ~= nil and #GODMODE.timers > 0 then 
            for i=1, #GODMODE.timers do 
                local timer = GODMODE.timers[i]
                timer.delay = timer.delay - 1

                if timer.delay <= 0 then 
                    timer.call()
                    table.remove(GODMODE.timers,i)
                    break
                end
            end
        end

        local mcm_flag = not ModConfigMenu or ModConfigMenu and not ModConfigMenu.IsVisible
        if GODMODE.mcm_reset ~= nil and mcm_flag then GODMODE.mcm_reset = 5 end --resets wiping data counter if modconfigmenu is closed

        --fullscreen animations
        if GODMODE.cur_splash ~= nil then
            GODMODE.cur_splash:Play("Scene", false)

            if GODMODE.playing_ending == Isaac.GetPlayer().InitSeed and Input.IsButtonPressed(Keyboard.KEY_SPACE,Isaac.GetPlayer().ControllerIndex) then 
                GODMODE.game:FinishChallenge()
                GODMODE.playing_ending = nil
            end

            if GODMODE.cur_splash:IsEventTriggered("LuciferTransition") then --palace!
                Isaac.ExecuteCommand("cstage IvoryPalace")
            end
            
            if GODMODE.cur_splash:IsEventTriggered("Start") then 
                if GODMODE.save_manager.get_data("EndingAchieved","false") == "true" and Isaac.GetPlayer():GetDropRNG():RandomFloat() < 0.3 then 
                    GODMODE.sfx:Play(GODMODE.registry.sounds.ending_voiceover_joke,3)
                    GODMODE.log("mlg moment",true)
                else 
                    GODMODE.sfx:Play(GODMODE.registry.sounds.ending_voiceover,3)
                end

                GODMODE.save_manager.set_data("EndingAchieved","true",true)
            end

            if GODMODE.cur_splash:IsEventTriggered("EndGame") then 
                GODMODE.game:FinishChallenge()
                GODMODE.playing_ending = nil
            end
        end

        if not GODMODE.is_animating() then 
            GODMODE.cur_splash = nil 
            GODMODE.cur_splash_timeout = math.max(0, (GODMODE.cur_splash_timeout or 5) - 1)
        else
            GODMODE.cur_splash:Update()
        end

        local room = GODMODE.room
        local level = GODMODE.level


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
        if GODMODE.sprites.red_coin_sprite ~= nil then
            GODMODE.sprites.red_coin_sprite:Update()
        end

        if GODMODE.sprites.void_sprite ~= nil then
            GODMODE.sprites.void_sprite:Update()
        end

        GODMODE.achievements.update()

        --update godmode stage
        if StageAPI and StageAPI.Loaded and StageAPI.GetCurrentStage and StageAPI.GetCurrentStage() ~= nil and GODMODE.stages ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name] ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name].stage_update ~= nil then
            GODMODE.stages[StageAPI.GetCurrentStage().Name]:stage_update()
        end

        --spawn call of the void when charges exist
        if tonumber(GODMODE.save_manager.get_data("VoidBHProj","0")) + tonumber(GODMODE.save_manager.get_data("VoidDMProj","0")) > 0 and GODMODE.game:GetFrameCount() % 30 == 0 then 
            --spawn new if none exists
            if GODMODE.util.count_enemies(nil,GODMODE.registry.entities.call_of_the_void.type, GODMODE.registry.entities.call_of_the_void.variant, -1) == 0 then
                local void = Isaac.Spawn(GODMODE.registry.entities.call_of_the_void.type, GODMODE.registry.entities.call_of_the_void.variant,0,room:GetCenterPos(),Vector.Zero,nil)
                GODMODE.get_ent_data(void).persistent_state = GODMODE.persistent_state.between_floors

                GODMODE.save_manager.set_data("VoidPower",tonumber(GODMODE.save_manager.get_data("VoidPower","0")) + 1)
            end
        end

        --increment counter to increment charges
        if (GODMODE.util.is_cotv_counting() or GODMODE.game.Challenge == GODMODE.registry.challenges.out_of_time) and GODMODE.save_manager.get_data("VoidSpawned","false") == "false" then
            local time = math.min(tonumber(GODMODE.save_manager.get_data("FloorEnterTime","120000")),tonumber(GODMODE.save_manager.get_config("VoidEnterTime","9005")))
            local time_inc = 1

            if GODMODE.util.has_curse(LevelCurse.CURSE_OF_LABYRINTH) then time_inc = 0.5 end

            GODMODE.save_manager.set_data("FloorEnterTime",""..time-time_inc)

            if time <= 0 or GODMODE.game.Challenge == GODMODE.registry.challenges.out_of_time then
                GODMODE.save_manager.set_data("VoidSpawned", "true")
                GODMODE.save_manager.set_data("VoidBHProj",tonumber(GODMODE.save_manager.get_data("VoidBHProj","0")) + 4)
                GODMODE.save_manager.set_data("VoidPower",tonumber(GODMODE.save_manager.get_data("VoidPower","0")) + 1)
                -- GODMODE.save_manager.set_data("VoidDMProj",tonumber(GODMODE.save_manager.get_data("VoidDMProj","0"))+3)

                local rooms = GODMODE.level:GetRooms()
                local chance = 0.01
                GODMODE.save_manager.set_data("SOCSpawnSeed","-1")

                -- spawn stream of consciousness and save godmode data after finding selected room
                local depth = 10

                while GODMODE.save_manager.get_data("SOCSpawnSeed","-1") == "-1" and depth > 0 do
                    depth = depth - 1

                    for i=0, rooms.Size-1 do
                        local room = rooms:Get(i)
                        if room.Data.Type == RoomType.ROOM_DEFAULT and room.DecorationSeed ~= GODMODE.room:GetDecorationSeed() then
                            if GODMODE.util.random() < chance then
                                GODMODE.save_manager.set_data("SOCSpawnSeed",room.DecorationSeed, true)
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

        if GODMODE.util.has_curse(GODMODE.registry.blessings.faith,true) and level:GetAngelRoomChance() < 1 then
            level:AddAngelRoomChance(1.0)
        end

        if GODMODE.eden_grind_cmd == true then 
            if room:GetType() == RoomType.ROOM_BOSS and GODMODE.level:GetStage() == LevelStage.STAGE4_2 then 
                if room:IsClear() then 
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

        if GODMODE.get_observatory_ids then 
            local ids = GODMODE.get_observatory_ids()
            local cur_flag = ids[level:GetCurrentRoomIndex()] == true
            
            for slot=0,DoorSlot.NUM_DOOR_SLOTS-1 do 
                -- if GODMODE.util.get_max_doors()
                local door = room:GetDoor(slot)

                if door ~= nil then 
                    local cache_ind = ids[door.TargetRoomIndex] == true and level:GetCurrentRoomIndex() or door.TargetRoomIndex

                    if (ids[door.TargetRoomIndex] == true or door.TargetRoomType == RoomType.ROOM_DICE and cur_flag) then
                        if (GODMODE.observatory_door_cache == nil or GODMODE.observatory_door_cache[cache_ind] ~= true) then 
                            if (door:GetSprite():IsFinished("Open") or door:GetSprite():IsFinished("Opened")) then 
                                door:GetSprite():Play("Opened",true)
                            elseif (door:GetSprite():IsFinished("Close") or door:GetSprite():IsFinished("Closed")) then 
                                door:GetSprite():Play("Closed",true)
                            end
                                
                            GODMODE.observatory_door_cache = GODMODE.observatory_door_cache or {}
                            GODMODE.observatory_door_cache[cache_ind] = true
                            GODMODE.paint_observatory_door(door)
                        end
                        
                        if door:IsLocked() and room:IsClear() then 
                            door:TryUnlock(Isaac.GetPlayer(),true)
                        end
                    end    
                end
            end
        end

        if GODMODE.util.is_correction() then 
            for i=0,GODMODE.game:GetFrameCount() % 2 do 
                local pos = room:GetCenterPos()+RandomVector():Resized(math.cos(GODMODE.game:GetFrameCount())*128)*Vector(2,1.4)
                local depth = 5
                while math.abs(pos.X - room:GetCenterPos().X) < 64 and math.abs(pos.Y - room:GetTopLeftPos().Y) < 64 and depth > 0 do 
                    pos = room:GetCenterPos()+RandomVector():Resized(math.cos(GODMODE.game:GetFrameCount())*128)*Vector(2,1.4)
                    depth = depth - 1
                end

                local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, 
                    pos, Vector.Zero, nil):ToEffect()
                fx:SetTimeout(10)
                fx.LifeSpan = 40
                fx.Scale = math.sin(GODMODE.game:GetFrameCount()) * 0.5 + 0.6
                fx:SetColor(Color(0,0,0,0.95),999,1,false,false)
                fx.DepthOffset = -100    
            end
        end
    end

    local heart_ui_anim_size = {
        ["Faithless"] = 30,
        ["Delirious"] = 68,
        ["Delirious_Empty"] = 2,
        ["Delirious_Close"] = 8,
        ["Delirious_Open"] = 8,
    }

    function GODMODE.mod_object:base_player_hud(player)
        local data = GODMODE.get_ent_data(player)

        if GODMODE.sprites.temp_bh_sprite == nil then
            GODMODE.sprites.temp_bh_sprite = Sprite()
            GODMODE.sprites.temp_bh_sprite:Load("gfx/grid/fatal_attraction.anm2", true)
            GODMODE.sprites.temp_bh_sprite:Play("BrokenHud",true)
        end

        if GODMODE.sprites.heart_ui_sprite == nil then
            GODMODE.sprites.heart_ui_sprite = Sprite()
            GODMODE.sprites.heart_ui_sprite:Load("gfx/ui/ui_godmode_hearts.anm2", true)
        end

        -- --render broken heart sprite
        local broken = tonumber(GODMODE.save_manager.get_player_data(player,"FaithlessHearts","0"))
        -- local broken_flag = broken > 0
        -- local opac = math.cos(math.rad(GODMODE.game:GetFrameCount()*5+broken * 3))*0.3 + 0.6
        -- if not broken_flag then opac = 0 end 
        -- local space_between = 24
        -- GODMODE.sprites.temp_bh_sprite.Color = Color(1,1,1,(GODMODE.sprites.temp_bh_sprite.Color.A + opac) / 2.0)
        -- local pos = GODMODE.util.get_hud_corner_pos(GODMODE.util.get_player_index(player))+Vector(8,12-space_between/2)
        -- GODMODE.sprites.temp_bh_sprite:SetFrame("BrokenHud",0)
        -- GODMODE.sprites.temp_bh_sprite:Render(pos,Vector.Zero,Vector.Zero)
        -- GODMODE.sprites.temp_bh_sprite:SetFrame("Cost",broken)
        -- GODMODE.sprites.temp_bh_sprite:Render(pos+Vector(-7,14),Vector.Zero,Vector.Zero)

        --render godmode hearts 
        --faithless
        if broken > 0 and not GODMODE.util.has_curse(LevelCurse.CURSE_OF_THE_UNKNOWN) then 
            local cur = broken 
            local anim_name = "Faithless"
            GODMODE.sprites.heart_ui_sprite.Color = Color.Default

            while cur > 0 do 
                local spot = GODMODE.util.get_heart_pos_for(player,GODMODE.util.get_heart_ind_for(player,GODMODE.registry.hearts.faithless) + cur)
                if spot ~= nil then 
                    GODMODE.sprites.heart_ui_sprite:SetFrame(anim_name,math.floor(GODMODE.game:GetFrameCount() / 2 % (heart_ui_anim_size[anim_name] * 2)))
                    GODMODE.sprites.heart_ui_sprite:Render(spot)    
                end

                cur = cur - 1
            end
        end

        if player:GetPlayerType() == GODMODE.registry.players.t_deli then 
            local spot = GODMODE.util.get_heart_pos_for(player,GODMODE.util.get_heart_ind_for(player,GODMODE.registry.hearts.delirious))
            local anim_name = "Delirious"
            local hidden = tonumber(GODMODE.save_manager.get_player_data(player,"EyesOpen","16")) == 0 or GODMODE.save_manager.get_player_data(player,"RingHidden","false") == "true"

            data.deli_heart_opacity = ((data.deli_heart_opacity or 1) * 19 + (hidden and 0 or 1)) / 20
            GODMODE.sprites.heart_ui_sprite.Color = Color(1,1,1,data.deli_heart_opacity)

            if spot ~= nil then 
                GODMODE.sprites.heart_ui_sprite:SetFrame(anim_name,math.floor(GODMODE.game:GetFrameCount() / 2 % (heart_ui_anim_size[anim_name] * 2)))
                GODMODE.sprites.heart_ui_sprite:Render(spot)    
            end
        elseif player:GetPlayerType() == GODMODE.registry.players.t_recluse then 
            local ind = GODMODE.util.get_heart_ind_for(player,GODMODE.registry.hearts.toxic)
            local anim_name = "Toxic"
            local thearts = 6
            local toxic = tonumber(GODMODE.save_manager.get_player_data(player,"ToxicPerc","1.0"))
            local state = tonumber(GODMODE.save_manager.get_player_data(player,"ToxicState","1"))

            data.toxic_heart_opacity = ((data.toxic_heart_opacity or 1) * 4 + 1) / 5
            GODMODE.sprites.heart_ui_sprite.Color = Color(1,1,1,data.toxic_heart_opacity,(0 + math.min(0.5,(data.toxic_cd or 0) / 30.0)),math.max(0,math.abs(math.cos(math.rad(Isaac.GetFrameCount() * 3))) * 0.2 * (state - 1.0)),0)
            local toxic_temp = toxic 

            for i=1,thearts do 
                local spot = GODMODE.util.get_heart_pos_for(player,ind + i)
                local perc = math.max(0,math.min((toxic - (1.0/thearts) * (i - 1)), (1.0/thearts))) / (1 / thearts)
                
                if spot ~= nil then 
                    GODMODE.sprites.heart_ui_sprite:SetFrame(anim_name,math.floor(perc*11))
                    GODMODE.sprites.heart_ui_sprite:Render(spot)    
                end
            end
        end

        if data ~= nil then 
            data.red_coin_count = tonumber(GODMODE.save_manager.get_player_data(player, "RedCoinCount", "0"))
            data.red_coin_display = data.red_coin_display or 0

            if Input.IsButtonPressed (tonumber(GODMODE.save_manager.get_config("RedCoinCounterKey",Keyboard.KEY_TAB)), player.ControllerIndex) or Input.IsActionPressed (tonumber(GODMODE.save_manager.get_config("RedCoinCounterButton",ButtonAction.ACTION_MAP)), player.ControllerIndex) then
                data.red_coin_display = math.min(50,data.red_coin_display + 5)
            end

            if data.red_coin_display > 0 then
                local opacity = math.min(1.0, data.red_coin_display / 50.0)
                pos = Isaac.WorldToScreen(player.Position + Vector(-32,16))

                if GODMODE.sprites.red_coin_sprite == nil then
                    GODMODE.sprites.red_coin_sprite = Sprite()
                    GODMODE.sprites.red_coin_sprite:Load("gfx/pickup_redcoin.anm2", true)
                end

                GODMODE.sprites.red_coin_sprite.Color = Color(1,1,1,opacity)
                GODMODE.sprites.red_coin_sprite:Play("HudClasp",true)
                GODMODE.sprites.red_coin_sprite:Render(pos,Vector.Zero,Vector.Zero)
                GODMODE.sprites.red_coin_sprite:Play("Hud",true)
                data.red_coin_display = data.red_coin_display - 1

                for i=1,5 do
                    if data.red_coin_count >= i then 
                        GODMODE.sprites.red_coin_sprite:Render(pos+Vector(i*7,0),Vector.Zero,Vector.Zero)
                    end
                end
            end
        end
    end

    function GODMODE.mod_object:post_player_render(player,offset)
        if GetPtrHash(player) == GetPtrHash(Isaac.GetPlayer()) and StageAPI and StageAPI.GetCurrentStage and StageAPI.GetCurrentStage() ~= nil and GODMODE.stages ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name] ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name].stage_render ~= nil then
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
            GODMODE.cotv_timer_st_cache = GODMODE.cotv_timer_st_cache or (GODMODE.util.total_item_count(GODMODE.registry.items.a_second_thought))
            return "Second Thought Count: "..GODMODE.cotv_timer_st_cache
        end,
        function()
            return "Room Clear: "..tostring(GODMODE.room:IsClear())
        end,
        function()
            local room = GODMODE.room
            return "Room Type: "..tostring((room:GetType() == RoomType.ROOM_CHALLENGE and Isaac.CountEnemies()+Isaac.CountBosses() == 0 or room:GetType() ~= RoomType.ROOM_CHALLENGE) and room:GetType() ~= RoomType.ROOM_BOSSRUSH and room:GetType() ~= RoomType.ROOM_ARCADE and room:GetType() ~= RoomType.ROOM_ISAACS) 
        end,
        function()
            return "Challenge Override: "..tostring(GODMODE.game.Challenge == GODMODE.registry.challenges.out_of_time) 
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
            return "DSS Open:"..tostring(not (DeadSeaScrollsMenu == nil or not DeadSeaScrollsMenu.IsOpen()))
        end,
        function()
            return "In secrets:"..tostring(GODMODE.is_in_secrets())
        end,

    }

    function GODMODE.mod_object:post_render()
        if GODMODE.level:GetStage() == LevelStage.STAGE7 and GODMODE.save_manager.get_config("VoidOverlay","true") == "true" then
            if GODMODE.sprites.void_sprite == nil then
                GODMODE.sprites.void_sprite = Sprite()
                GODMODE.sprites.void_sprite:Load("gfx/backdrop/voidoverlay.anm2", true)
                GODMODE.log("Loaded Void overlay!")
            end
            GODMODE.sprites.void_sprite:Render(GODMODE.room:GetRenderSurfaceTopLeft(), Vector(0,0), Vector(0,0))
            GODMODE.sprites.void_sprite:Play("Stage",false)
        end

        if GODMODE.sprites.vs_sprite == nil then
            GODMODE.sprites.vs_sprite = Sprite()
            GODMODE.sprites.vs_sprite:Load("gfx/ui/boss/god_versusscreen.anm2", true)
            GODMODE.log("Loaded Godmode Vs. overlay!")
        end

        if GODMODE.sprites.cotv_timer_sprite == nil then 
            GODMODE.sprites.cotv_timer_sprite = Sprite()
            GODMODE.sprites.cotv_timer_sprite:Load("gfx/ui/ui_cotv.anm2", true)
            GODMODE.log("Loaded Godmode COTV timer!")
        elseif GODMODE.save_manager.get_config("COTVDisplay","true") == "true" then 
            local anim_type = "Timer"
            if not GODMODE.util.is_cotv_counting() and not GODMODE.util.is_cotv_spawned() then 
                anim_type = "TimerPaused"
            end

            if GODMODE.level:GetAbsoluteStage() > LevelStage.STAGE5 or (GODMODE.cotv_timer_st_cache or 0) > 0 then 
                anim_type = "TimerDisabled"
            end

            local challenge_flag = GODMODE.game.Challenge == GODMODE.registry.challenges.out_of_time
            local cotv_spawned = GODMODE.util.is_cotv_spawned()
            local power = tonumber(GODMODE.save_manager.get_data("VoidBHProj","0"))+tonumber(GODMODE.save_manager.get_data("VoidDMProj","0"))
            local active_skull_off = Vector.Zero
            local inc_flag = (GODMODE.save_manager.get_config("CallOfTheVoid","true") ~= "true" or cotv_spawned or GODMODE.game.Difficulty ~= Difficulty.DIFFICULTY_HARD) and not challenge_flag

            if inc_flag then 
                GODMODE.cotv_timer_counter = math.max((GODMODE.cotv_timer_counter or 0)-1,0)
            else 
                GODMODE.cotv_timer_counter = math.min((GODMODE.cotv_timer_counter or 0)+1,100)
            end
            

            if power > 0 or (GODMODE.cotv_skull_counter or 0) > 0 then 
                if inc_flag then 
                    active_skull_off = Vector(24,0)
                end

                if power > 0 then 
                    GODMODE.cotv_skull_counter = math.min((GODMODE.cotv_skull_counter or 0)+1,100)
                else 
                    GODMODE.cotv_skull_counter = math.max((GODMODE.cotv_skull_counter or 0)-1,0)
                end

                local col_mod = GODMODE.cotv_skull_counter/100.0
                GODMODE.sprites.cotv_timer_sprite.Color = Color(col_mod,col_mod,col_mod,col_mod)
                GODMODE.sprites.cotv_timer_sprite:SetFrame("Skull",GODMODE.game:GetFrameCount()%12)

                local skull_text_dist = Vector(4,0)
                GODMODE.sprites.cotv_timer_sprite:RemoveOverlay()
                GODMODE.sprites.cotv_timer_sprite:Render(GODMODE.util.get_cotv_counter_pos()-skull_text_dist+active_skull_off, Vector(0,0), Vector(0,0))
                Isaac.RenderScaledText(""..power,(GODMODE.util.get_cotv_counter_pos()+skull_text_dist+active_skull_off).X-2,(GODMODE.util.get_cotv_counter_pos()+skull_text_dist).Y-5,0.75,0.75, col_mod,col_mod,col_mod,col_mod)
                active_skull_off = Vector(-24,0)
            end

            GODMODE.cotv_timer_counter = GODMODE.cotv_timer_counter or 0
            local max_time = tonumber(GODMODE.save_manager.get_config("VoidEnterTime","9005"))
            local time = tonumber(GODMODE.save_manager.get_data("FloorEnterTime",""..max_time))
            local perc = 1.0-time/max_time 

            if challenge_flag then perc = 1.0 end

            local col_mod = GODMODE.cotv_timer_counter/100.0
            GODMODE.sprites.cotv_timer_sprite.Color = Color(col_mod,col_mod,col_mod,col_mod)
            GODMODE.sprites.cotv_timer_sprite:SetFrame(anim_type,math.floor(perc*73))
            GODMODE.sprites.cotv_timer_sprite:Render(GODMODE.util.get_cotv_counter_pos()+active_skull_off, Vector(0,0), Vector(0,0))
            GODMODE.sprites.cotv_timer_sprite.PlaybackSpeed = 0.0
            
            if anim_type ~= "TimerDisabled" and not challenge_flag and (GODMODE.cotv_timer_counter or 0) > 0 then 
                GODMODE.sprites.cotv_timer_sprite:SetOverlayFrame("TimerHand",math.floor(perc*73))
            else
                GODMODE.sprites.cotv_timer_sprite:RemoveOverlay()
            end

            -- if GODMODE.game:GetFrameCount() % 20 == 0 then 
            --     GODMODE.cotv_timer_st_cache = nil
            -- end

            GODMODE.cotv_timer_st_cache = GODMODE.cotv_timer_st_cache or (GODMODE.util.total_item_count(GODMODE.registry.items.a_second_thought))

            
            if GODMODE.cotv_timer_st_cache > 0 then 
                GODMODE.sprites.cotv_timer_sprite:SetFrame("TimerBackST",GODMODE.game:GetFrameCount()%40)
            else 
                GODMODE.sprites.cotv_timer_sprite:SetFrame("TimerBack",GODMODE.game:GetFrameCount()%40)
            end
            GODMODE.sprites.cotv_timer_sprite:Render(GODMODE.util.get_cotv_counter_pos()+active_skull_off, Vector(0,0), Vector(0,0))
        end

        if (GODMODE.cotv_debug or false) == true then 
            local pos = Isaac.WorldToScreen(GODMODE.util.get_center_of_screen()*Vector(0.85,0.5))
            for ind,func in ipairs(cotv_debug_map) do 
                local render_pos = pos+Vector(0,ind*10)
                Isaac.RenderScaledText(func(),render_pos.X,render_pos.Y,0.75,0.75,1,1,1,1)
            end
        end

        if GODMODE.cur_splash ~= nil then
            GODMODE.cur_splash_pos = GODMODE.util.get_center_of_screen()
            if GODMODE.playing_ending == Isaac.GetPlayer().InitSeed then 
                GODMODE.cur_splash_pos = GODMODE.util.get_center_of_screen()
            end

            GODMODE.cur_splash:Render(GODMODE.cur_splash_pos, Vector(0,0), Vector(0,0))
        end

        GODMODE.util.macro_on_players(function (player) 
            GODMODE.mod_object:base_player_hud(player)
            GODMODE.godhooks.call_hook("render_player_ui",player,GODMODE.util.get_player_index(player))
        end)
    end

    function GODMODE.mod_object:npc_hit( dmg_target , dmg_amount, dmg_flag, dmg_dealer, dmg_frames)
        local double_damage_flag = GODMODE.is_at_palace and GODMODE.is_at_palace() 
            or (dmg_target:ToPlayer() and dmg_target:ToPlayer():GetPlayerType() == GODMODE.registry.players.t_recluse
                and tonumber(GODMODE.save_manager.get_player_data(dmg_target, "ToxicPerc", "0.0")) <= 0.0) and dmg_flag & DamageFlag.DAMAGE_NO_PENALTIES ~= 0

        if double_damage_flag and dmg_target.Type == EntityType.ENTITY_PLAYER and dmg_amount == 1 then 
            if not dmg_target:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_WAFER) then 
                dmg_target:TakeDamage(2, dmg_flag, dmg_dealer, dmg_frames)
                return false     
            end
        end

        if (GODMODE.get_ent_data(dmg_target).toxic_cd or 0) > 0 then 
            return false 
        elseif dmg_target:ToPlayer() and dmg_target:ToPlayer():GetPlayerType() == GODMODE.registry.players.t_recluse then 
            local player = dmg_target:ToPlayer()
            local toxic = tonumber(GODMODE.save_manager.get_player_data(player,"ToxicPerc","1.0"))

            if toxic > 0.0 then 
                if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then 
                    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.PLAYER_CREEP_GREEN,0,player.Position,Vector.Zero,player)
                    creep = creep:ToEffect()
                    creep.Timeout = math.floor(100 + 100 * toxic) 
                    creep.Scale = 1.0 + 3.0 * toxic
                    creep.CollisionDamage = 1.0 + 4.0 * toxic
                    creep:Update()
                end

                GODMODE.save_manager.set_player_data(player,"ToxicPerc", 0.0)
                GODMODE.save_manager.set_player_data(player,"ToxicState", 0, true)
                player:TakeDamage(dmg_amount,dmg_flag | DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_IV_BAG,dmg_dealer,dmg_frames)
                player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
                player:EvaluateItems()
                GODMODE.get_ent_data(player).toxic_cd = 30
                return false
            end
        end

        if dmg_dealer.Entity and (dmg_dealer.Entity:ToPlayer() or (dmg_dealer.Entity.SpawnerEntity and dmg_dealer.Entity.SpawnerEntity:ToPlayer()) or (dmg_dealer.Entity.Parent and dmg_dealer.Entity.Parent:ToPlayer())) and GODMODE.util.is_valid_enemy(dmg_target,true) then
            local player = dmg_dealer.Entity:ToPlayer() or dmg_dealer.Entity.SpawnerEntity and dmg_dealer.Entity.SpawnerEntity:ToPlayer() or dmg_dealer.Entity.Parent and dmg_dealer.Entity.Parent:ToPlayer()

            if player:GetPlayerType() == GODMODE.registry.players.t_gehazi and dmg_flag & DamageFlag.DAMAGE_LASER ~= 0 then 
                local play_dat = GODMODE.get_ent_data(player)
                local redo = play_dat.t_gehazi_laser
                play_dat.t_gehazi_laser = true
                
                if Isaac.GetFrameCount() % 2 == 0 and player:GetNumCoins() > 0 then 
                    if dmg_target:GetDropRNG():RandomInt(2) <= (player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2) and 0 or 1) == 0 then 
                    end
    
                    player:AddCoins(-1)
                    GODMODE.players[player:GetPlayerType()]:spawn_coin(dmg_target, player, dmg_target, true)
                end
    
                if redo == false then 
                    dmg_target:TakeDamage(dmg_amount / GODMODE.players[player:GetPlayerType()].dmg_split, dmg_flag, dmg_dealer, dmg_frames)
                    return false 
                end    
            elseif player:GetPlayerType() == GODMODE.registry.players.t_recluse and dmg_dealer.Type ~= EntityType.ENTITY_EFFECT then 
                local toxic = tonumber(GODMODE.save_manager.get_player_data(player,"ToxicPerc","1.0"))

                if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and not dmg_target:HasEntityFlags(EntityFlag.FLAG_POISON) and toxic > 0.0 then 
                    dmg_target:AddPoison(dmg_dealer,60,player.Damage * 0.05)
                end

                if dmg_target.HitPoints - dmg_amount <= 0 and GODMODE.save_manager.get_player_data(player,"ToxicState","1") == "0" 
                    and not (dmg_target.Type == GODMODE.registry.entities.winged_spider.type and dmg_target.Variant == GODMODE.registry.entities.winged_spider.variant) then 
                    GODMODE.save_manager.set_player_data(player,"ToxicState","2",true)
                elseif GODMODE.save_manager.get_player_data(player,"ToxicState","1") ~= "0" then
                    local toxic = tonumber(GODMODE.save_manager.get_player_data(player,"ToxicPerc","1.0"))
                    GODMODE.save_manager.set_player_data(player,"ToxicPerc",math.min(1.0,toxic + dmg_amount / 100.0 + (1/128.0)),true)
                    player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
                    player:EvaluateItems()    
                end
            end
        end

        if dmg_flag & DamageFlag.DAMAGE_CURSED_DOOR ~= 0 and GODMODE.get_observatory_ids then
            local ids = GODMODE.get_observatory_ids()
            local cur_room = GODMODE.level:GetCurrentRoomIndex()
            local red_side = ids[cur_room] == true

            for slot=0,DoorSlot.NUM_DOOR_SLOTS-1 do 
                -- if GODMODE.util.get_max_doors()
                local door = GODMODE.room:GetDoor(slot)

                if door ~= nil and ids[door.TargetRoomIndex] == true and door.CurrentRoomType == RoomType.ROOM_DICE then 
                end
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
    end

    local persistent_flags = EntityFlag.FLAG_TRANSITION_UPDATE | EntityFlag.FLAG_PERSISTENT

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
                data.dark_light.Velocity = ent.Position - data.dark_light.Position 
            end

            data.time = data.time + 1
            data.real_time = data.real_time + 1

            --Persistence functionality
            if data.persistent_state and data.persistent_state > GODMODE.persistent_state.none then
                if not ent:HasEntityFlags(persistent_flags) then
                    ent:AddEntityFlags(persistent_flags)
                end

                if not data.persistent_data then
                    data.persistent_data = saved_data or {
                        room = GODMODE.room:GetDecorationSeed(),
                        in_room = true,
                        floor = GODMODE.level:GetStage(),
                    }
                end

                if data.persistent_state == GODMODE.persistent_state.single_room then
                    if ent:IsFrame(10,1) and GODMODE.level:GetStage() ~= data.persistent_data.floor then 
                        ent:Remove()
                    end
                    
                    if GODMODE.room:GetDecorationSeed() ~= data.persistent_data.room then

                        data.persistent_data.in_room = false
                        ent.Visible = false
                        -- ent.Position = Vector(-1000,-1000)
                        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                        ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                        ent:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY)
                        if data.exit_room ~= nil then data.exit_room(ent) end
                    else
                        if data.persistent_data.position_x and data.persistent_data.position_y and data.persistent_data.in_room == false then
                            ent.GridCollisionClass = data.persistent_data.grid_coll_class or ent.GridCollisionClass
                            ent.EntityCollisionClass = data.persistent_data.ent_coll_class or ent.EntityCollisionClass
                            ent:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_FRIENDLY)
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
                    if GODMODE.room:GetDecorationSeed() ~= data.persistent_data.room then
                        local door_pos = GODMODE.level.EnterDoor
                        if GODMODE.room:GetDoor(door_pos) ~= nil then 
                            local dir = GODMODE.room:GetDoor(door_pos).Direction
                            if door_pos_mods[dir] ~= nil then 
                                if door_pos ~= -1 then
                                    ent.Position = ent.Position - GODMODE.room:GetBottomRightPos() * door_pos_mods[dir]
                                    data.persistent_data.room = GODMODE.room:GetDecorationSeed()
                                end
                            else
                                GODMODE.log("doorpos \'"..dir.."\' not registered, please fix")
                            end
                        else
                            GODMODE.log("Door index \'"..door_pos.."\' is not registered, please fix")
                        end
                    end

                    if ent:IsFrame(15,1) and data.persistent_data.floor ~= GODMODE.level:GetStage() then
                        if data.persistent_state == GODMODE.persistent_state.between_floors then
                            data.persistent_data.floor = GODMODE.level:GetStage()
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

        if GODMODE.util.is_valid_enemy(ent,true) and ((GODMODE.game.Difficulty == Difficulty.DIFFICULTY_HARD and hard_enabled) or (GODMODE.game.Difficulty == Difficulty.DIFFICULTY_GREEDIER and greed_enabled)) then
            local percent = GODMODE.util.get_health_scale(ent, tonumber(GODMODE.save_manager.get_config("HPScaleMode","2")))

            ent.MaxHitPoints = math.floor(ent.MaxHitPoints * percent)
            ent.HitPoints = ent.MaxHitPoints
            
            -- local max_stage = 12
            -- local scale = tonumber(GODMODE.save_manager.get_config("HMEScale","2.0"))

            -- if GODMODE.game.Difficulty > Difficulty.DIFFICULTY_HARD then 
            --     max_stage = 7 
            --     scale = tonumber(GODMODE.save_manager.get_config("GMEScale","1.5"))
            -- end

            -- if (GODMODE.room:GetType() == RoomType.ROOM_BOSS or GODMODE.room:GetType() == RoomType.ROOM_MINIBOSS) and ent:IsBoss() then
            --     if GODMODE.game.Difficulty > 1 then
            --         scale = tonumber(GODMODE.save_manager.get_config("GMBScale","1.8"))
            --     else
            --         scale = tonumber(GODMODE.save_manager.get_config("HMBScale","2.3"))
            --     end
            -- end

            -- -- if GODMODE.level:GetStageType() > StageType.STAGETYPE_GREEDMODE then 
            -- --     scale = scale * 0.8 
            -- -- end --make repentance stages easier since less items generally compared to main path

            -- local max_health = tonumber(GODMODE.save_manager.get_config("ScaleSelectorMax","3000"))
            
            -- local cur_stage = GODMODE.level:GetAbsoluteStage()

            -- if StageAPI and StageAPI.Loaded and GODMODE.stages ~= nil and StageAPI.GetCurrentStage ~= nil and StageAPI.GetCurrentStage() ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name] ~= nil and GODMODE.stages[StageAPI.GetCurrentStage().Name].simulating_stage ~= nil then
            --     cur_stage = GODMODE.stages[StageAPI.GetCurrentStage().Name].simulating_stage
            -- end

            -- if ent.MaxHitPoints < max_health and not GODMODE.armor_blacklist:has_armor(ent) then
            --     local percent = (cur_stage-1) / math.max(1,max_stage-1) * math.max(1.0,scale-1.0)
            --     --GODMODE.log("hp scale: "..((1.0 + (scale-1) * (GODMODE.game:GetVictoryLap() + 1) * percent)), true)
            --     ent.MaxHitPoints = ent.MaxHitPoints * (1.0 + (scale-1) * (GODMODE.game:GetVictoryLap() + 1) * percent)
            --     ent.HitPoints = ent.MaxHitPoints
            -- end
        end

        if (GODMODE.room:GetType() == RoomType.ROOM_MINIBOSS or GODMODE.room:GetType() == RoomType.ROOM_BOSS) and ent:IsBoss() then
            ent:AddEntityFlags(EntityFlag.FLAG_NO_SPIKE_DAMAGE)
        end

        if GODMODE.save_manager.get_config("VanillaStoryHPBuff","true") == "true" and GODMODE.armor_blacklist.story_bosses[ent.Type] ~= nil then 
            ent.HitPoints = ent.HitPoints + math.min(tonumber(GODMODE.save_manager.get_config("VanillaStoryHPBuffCap","1000.0")),(GODMODE.util.get_basic_dps(nil) / 3.5) * 100)
            ent.MaxHitPoints = ent.HitPoints
        end
    end

    function GODMODE.mod_object:new_level()
        GODMODE.level = GODMODE.game:GetLevel()
        GODMODE.room_override.wipe_overrides()

        if StageAPI and StageAPI.Loaded and StageAPI.GetCurrentStage ~= nil then
            if GODMODE.game.Challenge == Challenge.CHALLENGE_NULL and not StageAPI.InNewStage() then 
                GODMODE.try_switch_stage()
            end

            GODMODE.save_manager.clear_key("ObservatoryGridIdx",true)
            GODMODE.cached_observatory_ids = nil
        
            local save_val = GODMODE.save_manager.get_data("ObservatoryChance","0.0")

            if save_val ~= "X" then
                local observatory_chance = tonumber(save_val)

                if GODMODE.util.random() < observatory_chance then 
                    if GODMODE.gen_observatory_in_stage() then 
                        GODMODE.save_manager.set_data("ObservatoryChance","X",true)
                        GODMODE.log("generated observatory!",true)

                        local level = GODMODE.level
                    end
                elseif #GODMODE.util.get_curse_list(false) > 0 then  
                    local increase = 0.1
                    GODMODE.save_manager.set_data("ObservatoryChance",math.min(1,observatory_chance + increase),true)
                end                        
            end
        end

        -- --revelations integration - NOTE: NO LONGER NEEDED WITH FC 2
        -- if StageAPI and StageAPI.Loaded and StageAPI.GetCurrentStage and StageAPI.GetCurrentStage() and StageAPI.GetCurrentStage().Name == "FruitCellar" and REVEL then 
        --     local trapdoor = REVEL.GRIDENT.HUB_TRAPDOOR:Spawn(
        --         REVEL.room:GetGridIndex(REVEL.room:GetTopLeftPos() + Vector(40, 40)), 
        --         nil, 
        --         false, 
        --         {StartingRoomHub = true}
        --     )
        --     trapdoor:GetSprite():Play("Open Animation", true)
        -- end

        GODMODE.vs_played_in = {}
        GODMODE.save_manager.set_data("FloorEnterTime",""..GODMODE.save_manager.get_config("VoidEnterTime","9005"))
        GODMODE.save_manager.set_data("VoidSpawned","false")
        GODMODE.save_manager.set_data("Deterioration","1")
        GODMODE.save_manager.set_data("FortitudeCards","0",true)

        local rooms = GODMODE.level:GetRooms()
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
            GODMODE.save_manager.has_loaded = false 

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
            else
                -- -- fixes weird stageapi bug
                -- if not GODMODE.fixed_stageapi_bug then 
                --     GODMODE.fixed_stageapi_bug = true    
                --     Isaac.ExecuteCommand("cstage FruitCellar")
                --     Isaac.ExecuteCommand("restart")
                -- end
            end

            GODMODE.save_manager.save_override = false 
            GODMODE.godhooks.call_hook("first_level")
            -- GODMODE.push_items_monsters("first_level", true, function(monster) return true end, nil)
            GODMODE.save_manager.save_override = true 
            GODMODE.save_manager.clear_key("ObservatoryGridIdx")
            GODMODE.cached_observatory_ids = nil
        end

        if GODMODE.level:GetStage() == LevelStage.STAGE4_3 and GODMODE.save_manager.get_config("BlueWombRework","true",true) == "true" then
            for _,ent in ipairs(Isaac.GetRoomEntities()) do
                if ent.Type == EntityType.ENTITY_PICKUP then
                    ent:Remove()
                    -- ent:ToPickup():Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,Card.CARD_CRACKED_KEY)
                    -- Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,Card.CARD_CRACKED_KEY,ent.Position,Vector(0,2),ent)
                end
            end
            local key_count = 8
            local keys = {
                Card.CARD_CRACKED_KEY,
                GODMODE.cards_pills.cards.pok_2,
                GODMODE.cards_pills.cards.pok_3,
                GODMODE.cards_pills.cards.pok_4,
                GODMODE.cards_pills.cards.pok_5,
                GODMODE.cards_pills.cards.pok_6,
                GODMODE.cards_pills.cards.pok_7,
                GODMODE.cards_pills.cards.pok_8
            }

            local count = 8/GODMODE.game:GetNumPlayers()

            while key_count > 0 do 
                Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,keys[math.floor((8/GODMODE.game:GetNumPlayers()))],GODMODE.room:GetCenterPos()-Vector(0,64),Vector.Zero,ent)
                key_count = key_count - (8/GODMODE.game:GetNumPlayers())
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

            local broken = tonumber(GODMODE.save_manager.get_player_data(player,"FaithlessHearts","0"))
            if broken > 0 then 
                GODMODE.save_manager.set_player_data(player, "FaithlessHearts", broken - 1,true)
                Isaac.Spawn(GODMODE.registry.entities.temp_broken_fx.type,GODMODE.registry.entities.temp_broken_fx.variant,GODMODE.registry.entities.temp_broken_fx.subtype,
                            player.Position,Vector.Zero,nil)
            end
        end)

        if GODMODE.is_at_palace and GODMODE.is_at_palace() then
            local mural = Isaac.Spawn(GODMODE.registry.entities.palace_mural.type, GODMODE.registry.entities.palace_mural.variant, 0, GODMODE.room:GetCenterPos(), Vector.Zero, nil)
            mural:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            mural:Update()
        end

        if GODMODE.save_manager.get_config("StatHelp","true") == "true" then 
            local correction = false
            GODMODE.save_manager.set_data("CorrectionPortalSpawned","false")

            GODMODE.util.macro_on_players(function(player) 
                local base = tonumber(GODMODE.save_manager.get_player_data(player,"BaseStats",""..GODMODE.util.get_stat_score(player).score))
                local scale = GODMODE.util.get_stat_scale()
                local stat_thres = base * scale + 0.1
                local stats = GODMODE.util.get_stat_score(player)
                GODMODE.log("Stat score = "..stats.score..", threshold ="..stat_thres, true)

                if stats.score < stat_thres then 
                    correction = true
                    GODMODE.log("Stat score of "..stats.score.." is lower than the threshold (currently "..stat_thres..")", true)
                end
            end)
            if correction == true and GODMODE.save_manager.get_config("StatHelp","true") == "true" then 
                GODMODE.save_manager.set_data("CorrectionNeeded","true")
            end
        end

        if GODMODE.save_manager.get_data("CorrectionNeeded","false") == "true" 
            and GODMODE.save_manager.get_data("CorrectionPortalSpawned","false") == "false" 
            and ((GODMODE.level:GetStage() <= LevelStage.STAGE4_1 and GODMODE.level:GetStage() > LevelStage.STAGE1_1)
            or GODMODE.util.total_item_count(GODMODE.registry.trinkets.bone_feather,true) > 0) then 

            GODMODE.log("GOTO CORRECTION",true)
            Isaac.Spawn(GODMODE.registry.entities.correction_portal.type, GODMODE.registry.entities.correction_portal.variant, 1, 
                GODMODE.room:GetGridPosition(GODMODE.room:GetGridIndex(GODMODE.room:GetCenterPos() + Vector(-102,-32))), Vector.Zero, nil)
            GODMODE.save_manager.set_data("CorrectionPortalSpawned","true")
        end
    end

    local door_hazards = {"Webbed","Void","Spiked","Wired","Spooked","WiredGood"}
    local door_hazards_good = {["WiredGood"] = true}

    function GODMODE.mod_object:new_room()
        GODMODE.room = GODMODE.game:GetRoom()

        if not GODMODE.save_manager.has_loaded then 
            if not GODMODE.util.is_start_of_run() then
                GODMODE.save_manager_lock = true
                GODMODE.save_manager.load()
                GODMODE.save_manager.wipe_persistent_entities()
                GODMODE.save_manager_lock = false
            else
                GODMODE.save_manager.wipe()
                GODMODE.save_manager.wipe_persistent_entities()
            end
    
            GODMODE.util.init_rand()
            -- GODMODE.save_manager.save()

            GODMODE.util.macro_on_players(function(player)
                local data = GODMODE.get_ent_data(player)
                data.red_coin_count = tonumber(GODMODE.save_manager.get_player_data(player, "RedCoinCount", "0"))
    
                if data.red_coin_count > 0 then
                    data.red_coin_display = 100
                end
            end)
    
            GODMODE.game.BlueWombParTime = tonumber(GODMODE.save_manager.get_config("HushTimeMins","35"))*60*30
            GODMODE.game.BossRushParTime = tonumber(GODMODE.save_manager.get_config("BRTimeMins","20"))*60*30    
        end

        local room = GODMODE.room
        local level = GODMODE.level

        local stat_help = GODMODE.save_manager.get_config("StatHelp","true") == "true"
        GODMODE.save_manager.set_data("PlayerCount","0",true)
        GODMODE.util.macro_on_players(function(player) 
            if stat_help and GODMODE.util.is_start_of_run() then 
                local score = GODMODE.util.get_stat_score(player).score
                local old = tonumber(GODMODE.save_manager.get_player_data(player,"BaseStats",""..score))
                GODMODE.save_manager.set_player_data(player,"BaseStats",(old + score) / 2)
            end

            GODMODE.mod_object:register_player(player)
        end)

        if GODMODE.util.is_correction() then 
            GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_EFFECT,EffectVariant.EFFECT_ISAACS_CARPET,nil,function(carpet)
                carpet:GetSprite():ReplaceSpritesheet(0,"gfx/grid/correction_carpet.png")
                carpet:GetSprite():LoadGraphics()
            end)

            MusicManager():Crossfade(GODMODE.registry.music.misfortunate)
            GODMODE.save_manager.set_data("CorrectionNeeded","false")
            GODMODE.save_manager.set_data("CorrectionPortalSpawned","false",true)

            GODMODE.paint_correction_room_fx()
        end

        -- configurable godmode reskins
        local bd_key = level:GetAbsoluteStage()..","..level:GetStageType()
        if GODMODE.backdrop_config_toggles and GODMODE.backdrop_overrides[bd_key] and GODMODE.save_manager.get_config(GODMODE.backdrop_config_toggles[bd_key],"false") == "true" and GODMODE.backdrop_roomtypes[room:GetType()] == true then 
            StageAPI.ChangeRoomGfx(GODMODE.backdrop_overrides[bd_key])
        end 

        -- unlocks preview room for challenge
        if GODMODE.is_in_secrets() then 
            if room:GetType() == RoomType.ROOM_CHEST then 
                local ind = 1
                local start_grid = -2
                local row_size = 8 
                local item_list = GODMODE.achievements.item_map
                local last_grid = 0

                for item,_ in pairs(item_list) do 
                    local ped = Isaac.Spawn(GODMODE.registry.entities.unlock_pedestal.type,GODMODE.registry.entities.unlock_pedestal.variant,ind,Vector.Zero,Vector.Zero,nil)
                    last_grid = (start_grid+math.ceil(ind/row_size)*(56+4))+(ind-1)*3
                    ped.Position = room:GetGridPosition(last_grid)
                    ped:Update()
                    ped.Velocity = Vector.Zero
                    ped.Position = GODMODE.get_ent_data(ped).anchor_pos

                    ind = ind + 1 
                end

                local ped = Isaac.Spawn(GODMODE.registry.entities.unlock_pedestal.type,GODMODE.registry.entities.unlock_pedestal.variant,0,Vector.Zero,Vector.Zero,nil)
                ped.Position = room:GetGridPosition(last_grid+3)
                ped:Update()
                ped.Velocity = Vector.Zero
                ped.Position = GODMODE.get_ent_data(ped).anchor_pos

                if StageAPI and StageAPI.Loaded and StageAPI.GetCurrentStage ~= nil then 
                    StageAPI.ChangeRoomGfx(GODMODE.backdrops.unlock_room_gfx)
                end

                Isaac.ExecuteCommand("debug 8")
                Isaac.ExecuteCommand("debug 3")
            elseif GODMODE.game:GetFrameCount() > 10 then 
                GODMODE.game:FinishChallenge()
            else 
                if level:GetStageType() ~= StageType.STAGETYPE_ORIGINAL then 
                    Isaac.ExecuteCommand("stage 1")
                end
                
                Isaac.ExecuteCommand("goto s.chest.10000")
            end
        end

        if GODMODE.is_at_palace and GODMODE.is_at_palace() then            
            if room:GetType() == RoomType.ROOM_ERROR then
                GODMODE.util.macro_on_grid(GridEntityType.GRID_TRAPDOOR,-1,function(grident,ind,pos) 
                    GODMODE.room:RemoveGridEntity(ind,0,true)
                    grident:Update()
                end)

                Isaac.Spawn(GODMODE.registry.entities.ivory_portal.type, GODMODE.registry.entities.ivory_portal.variant, 0, GODMODE.room:FindFreePickupSpawnPosition(GODMODE.room:GetCenterPos()), Vector.Zero, nil)
            elseif room:GetType() == RoomType.ROOM_BOSS then
                if not StageAPI.InExtraRoom() then 
                    StageAPI.SetRoomFromList(GODMODE.fallen_light_entrance, true, false, true, room:GetDecorationSeed(), room:GetRoomShape(), false)
                    GODMODE.set_palace_stage(GODMODE.get_palace_stage())                        

                    GODMODE.util.macro_on_grid(GridEntityType.GRID_DOOR,-1,function(grident,ind,pos) 

                        if grident:ToDoor().TargetRoomType ~= RoomType.ROOM_DEFAULT then 
                            GODMODE.room:RemoveGridEntity(ind,0,true)
                            grident:Update()    
                        end
                    end)
                else
                    GODMODE.util.macro_on_players(function(player) 
                        player.Position = room:GetCenterPos() + Vector(-24,160)
                    end)
                end
            elseif room:GetType() ~= RoomType.ROOM_SECRET and room:IsFirstVisit() then 
                for slot=0,DoorSlot.NUM_DOOR_SLOTS do 
                    local door = room:GetDoor(slot)
                    if door ~= nil and door.TargetRoomType == RoomType.ROOM_SECRET then 
                        local pos = room:GetDoorSlotPosition(slot)
                        local angle = slot % 4 * 90
                        local off = Vector(-1,0):Rotated(angle+180):Resized(40)
                        local indicator = Isaac.Spawn(GODMODE.registry.entities.palace_mural.type, GODMODE.registry.entities.palace_mural.variant, 1+slot, pos+off, Vector.Zero, nil)
                        indicator:GetSprite().Rotation = angle + 90
                    end
                end
            elseif room:GetType() == RoomType.ROOM_SECRET and GODMODE.util.count_enemies(nil,GODMODE.registry.entities.masked_angel_statue.type,GODMODE.registry.entities.masked_angel_statue.variant,nil) == 0 and room:IsFirstVisit() then 
                local statue = Isaac.Spawn(GODMODE.registry.entities.masked_angel_statue.type,GODMODE.registry.entities.masked_angel_statue.variant,1,room:FindFreePickupSpawnPosition(room:GetCenterPos()),Vector.Zero,nil)
                statue:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            end
        end
        
        local room_data = level:GetCurrentRoomDesc().Data

        if room:GetType() == RoomType.ROOM_DEVIL and room_data.Name == "Adramolech's Fury" then
            GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,nil,function(pickup) 
                pickup = pickup:ToPickup()
                pickup.OptionsPickupIndex = 1
                pickup:GetSprite():ReplaceSpritesheet(5,"gfx/grid/options_altar_"..pickup.OptionsPickupIndex..".png")
                pickup:GetSprite():LoadGraphics()
            end)
        end

        local enter_door = level.EnterDoor
        local feather_duster_ct = GODMODE.util.total_item_count(GODMODE.registry.items.feather_duster)
        
        if GODMODE.game.Challenge == Challenge.CHALLENGE_NULL and enter_door > -1 
            and not room:HasCurseMist() 
                and (room:IsFirstVisit() or GODMODE.save_manager.get_data("VoidSpawned","false") == "true" and GODMODE.save_manager.get_config("COTVDoorHazardFX", "true") == "true") 
                and not GODMODE.util.is_death_certificate() then 
            local room_rng = RNG()
            room_rng:SetSeed(room:GetDecorationSeed()+(level:GetCurrentRoomDesc().VisitedCount-1)*10,1)
            local hazard_type = GODMODE.registry.entities.door_hazard.type
            local hazard_var = GODMODE.registry.entities.door_hazard.variant
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

                    local door = Isaac.Spawn(hazard_type,hazard_var,0,room:GetDoorSlotPosition(slot),Vector.Zero,nil):ToNPC()
                    local door_data = GODMODE.get_ent_data(door)
                    -- door_data.door_slot = slot+1
                    door.I1 = slot + 1
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

        --observatory check
        if GODMODE.get_observatory_ids then 
            GODMODE.observatory_door_cache = nil
            local ids = GODMODE.get_observatory_ids()

            --Minimapi things (STOLEN from HEAVEN'S CALL, check that bomb ass mod out)------------------------------------------------------------
            if MinimapAPI then
                for roomidx, valid in pairs(ids) do
                    local minimaproom = MinimapAPI:GetRoomByIdx(roomidx)
                    GODMODE.util.schedule_function(function()
                        if minimaproom then
                            minimaproom.Color = Color(MinimapAPI.Config.DefaultRoomColorR, MinimapAPI.Config.DefaultRoomColorG, MinimapAPI.Config.DefaultRoomColorB, 1, 0, 0, 0)
                            minimaproom.PermanentIcons = {"GODMODEObservatory"}
                        end
                    end, 0)
                end
            end

            local cur_room = level:GetCurrentRoomDesc().SafeGridIndex
            local red_side = ids[cur_room] == true

            for slot=0,DoorSlot.NUM_DOOR_SLOTS-1 do 
                -- if GODMODE.util.get_max_doors()
                local door = room:GetDoor(slot)

                if door ~= nil and ((ids[door.TargetRoomIndex] == true and door.TargetRoomType == RoomType.ROOM_DICE) or red_side) then 
                    GODMODE.paint_observatory_door(door)
                end
            end

            if red_side then 
                room:SetFloorColor(Color(1,1,1,1))
                room:SetWallColor(Color(1,1,1,1))

                -- add minimap icon
                if MinimapAPI and #GODMODE.roomgen.minimaprooms > 0 then
                    for i, roomidx in pairs(GODMODE.roomgen.minimaprooms) do
                        local minimaproom = MinimapAPI:GetRoomByIdx(roomidx)
                        local ids = GODMODE.get_observatory_ids()
                        local cur_flag = ids[GODMODE.room:GetDecorationSeed()] == true

                        if minimaproom then
                            minimaproom.Color = Color(MinimapAPI.Config.DefaultRoomColorR, MinimapAPI.Config.DefaultRoomColorG, MinimapAPI.Config.DefaultRoomColorB, 1, 0, 0, 0)
                            if cur_flag then
                                minimaproom.PermanentIcons = {"GODMODEObservatory"}
                            end
                            GODMODE.roomgen.minimaprooms[i] = nil
                        end
                    end
                else
                    GODMODE.roomgen.minimaprooms = {}
                end            
                
                -- if room:IsFirstVisit() then 
                --     StageAPI.SetRoomFromList(GODMODE.observatory_rooms, nil, false, false, true, room:GetDecorationSeed(), room:GetRoomShape(), false)
                -- end
                
                MusicManager():Crossfade(GODMODE.registry.music.the_stars_gaze_back)
                MusicManager():UpdateVolume()

                StageAPI.ChangeRoomGfx(GODMODE.backdrops.observatory_gfx)
                GODMODE.paint_observatory_room_fx()
                local cur_rewards = tonumber(GODMODE.save_manager.get_data("ObservatoryRewards","0"))

                if GODMODE.room:IsFirstVisit() then 
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
    
                        if GODMODE.itempools.is_in_pool("observatory",pickup.SubType) or GODMODE.itempools.is_in_pool("observatory_items",pickup.SubType)
                        or GODMODE.itempools.is_in_pool("observatory_tarots",pickup.SubType) or GODMODE.itempools.is_in_pool("observatory_souls",pickup.SubType) then 
                            index = (index == -1 and GODMODE.util.get_options_index(pickup) or index)
                            pickup:ToPickup().OptionsPickupIndex = index
                        end
                    end)    
                end

                -- -- populate with trinket choices
                -- if cur_rewards < GODMODE.util.get_num_players() and room:IsFirstVisit() then 
                --     local trinkets = GODMODE.itempools.get_pool("observatory")

                --     for _,trinket in ipairs(trinkets) do 
                --         -- no dupes
                --         if GODMODE.util.total_item_count(trinket,true) == 0 then 
                --             Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,trinket,room:FindFreePickupSpawnPosition(room:GetCenterPos()),Vector.Zero,nil):ToPickup()
                --         end
                --     end
                -- end
            end
        end

        -- correction room 
        if GODMODE.util.is_correction() then 
            for slot=0,DoorSlot.NUM_DOOR_SLOTS-1 do 
                -- if GODMODE.util.get_max_doors()
                local door = room:GetDoor(slot)

                if door ~= nil then 
                    GODMODE.paint_correction_door(door)
                end
            end
        end

        GODMODE.alt_entries.alt_room_count = {}
        GODMODE.override_attempted = false
        -- for vengeful dagger
        GODMODE.room_ents = {}

        for i,ent in ipairs(Isaac.GetRoomEntities()) do
            table.insert(GODMODE.room_ents,{x=ent.Position.X,y=ent.Position.Y,seed=ent.InitSeed,ent=ent})

            for ind,alt in ipairs(GODMODE.alt_entries.entries) do
                if alt.rep_type == ent.Type and alt.rep_variant == ent.Variant and (alt.rep_subtype == nil or alt.rep_subtype == ent.SubType) then
                    GODMODE.alt_entries.alt_room_count[alt.rep_type..","..alt.rep_variant..","..alt.rep_subtype] = (GODMODE.alt_entries.alt_room_count[alt.rep_type..","..alt.rep_variant..","..alt.rep_subtype] or 0) + 1
                end
            end
        end

        local subtype = level:GetCurrentRoomDesc().Data.Subtype
        if room:GetType() == RoomType.ROOM_TREASURE and (subtype == 1 or subtype == 3) then
            if GODMODE.save_manager.get_config("BothRepPathItems", "true") == "false" and level:GetStageType() > StageType.STAGETYPE_AFTERBIRTH or level:GetStageType() < StageType.STAGETYPE_REPENTANCE then

                if GODMODE.util.count_enemies(nil, GODMODE.registry.entities.golden_scale.type, GODMODE.registry.entities.golden_scale.variant) == 0 then 
                    local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())
                    local scale = Isaac.Spawn(GODMODE.registry.entities.golden_scale.type, GODMODE.registry.entities.golden_scale.variant, 0, pos, Vector(0,0), nil)
                    scale:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                end

                -- more options rework 
                local more_options = GODMODE.util.total_item_count(CollectibleType.COLLECTIBLE_MORE_OPTIONS)
                if more_options > 0 and GODMODE.save_manager.get_config("MoreOptionsRework","true") == "true" then 
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

        if level:GetStage() == LevelStage.STAGE4_3 and GODMODE.save_manager.get_config("BlueWombRework","true",true) == "true" and room:GetType() == RoomType.ROOM_DEFAULT then
            room:SetWallColor(Color.Default)
            room:SetFloorColor(Color.Default)
        end

        if room:GetDecorationSeed() == tonumber(GODMODE.save_manager.get_data("SOCSpawnSeed","-1")) then 
            Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,GODMODE.cards_pills.cards.soc,room:FindFreePickupSpawnPosition(room:GetCenterPos()),Vector.Zero,nil)
            GODMODE.save_manager.set_data("SOCSpawnSeed","-1")
        end

        if GODMODE.util.has_curse(GODMODE.registry.blessings.patience,true) and not room:IsClear() then 
            local enemies = Isaac.GetRoomEntities()

            for _,enemy in ipairs(enemies) do 
                if enemy:IsVulnerableEnemy() then 
                    enemy:AddFreeze(EntityRef(Isaac.GetPlayer()), 45)
                end
            end

            GODMODE.util.macro_on_players(function(player) GODMODE.get_ent_data(player).patience_counter = 21 end)
        end

        if GODMODE.util.has_curse(GODMODE.registry.blessings.opportunity,true) and room:IsFirstVisit() and room:IsClear() then 
            Isaac.GetPlayer():UseCard(Card.CARD_SOUL_ISAAC,UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
        end

        if room:GetType() == RoomType.ROOM_BOSS then 
            GODMODE.util.macro_on_players(function(player) 
                if player.SubType == GODMODE.registry.players.t_elohim then 
                    GODMODE.save_manager.set_player_data(player,"BossDMG",player:GetTotalDamageTaken())
                end
            end)
        end

        -- dehazard boss and miniboss rooms by replacing spiked rocks, breaking spikes, etc
        if room:IsClear() and room:GetType() == RoomType.ROOM_BOSS or room:GetType() == RoomType.ROOM_MINIBOSS or room_data.SurpriseMiniboss == true then 
            if GODMODE.save_manager.get_config("DehazardBossRooms","true") == "true" then 
                GODMODE.util.dehazard_room()
            end
        end

        -- resprite secret trapdoor to match destination for fruit cellar
        if StageAPI and StageAPI.Loaded and StageAPI.GetCurrentStage and StageAPI.GetCurrentStage() and StageAPI.GetCurrentStage().Name == "FruitCellar" then
            if room:GetType() == RoomType.ROOM_SECRET_EXIT or room:GetType() == RoomType.ROOM_BOSS then
                --redraw and redo requirements for secret entrance to downpour
                for slot=0,DoorSlot.NUM_DOOR_SLOTS do 
                    local door = room:GetDoor(slot)

                    if door ~= nil and door:GetSprite():GetFilename() == "gfx/grid/Door_Mines.anm2" then 
                        door:GetSprite():Load("gfx/grid/Door_Downpour.anm2",true)
                        door:SetLocked(true)
                        break 
                    end
                end
                 
                if room:GetType() == RoomType.ROOM_SECRET_EXIT then 
                    local grident = room:GetGridEntityFromPos(room:GetCenterPos())

                    if grident then 
                        grident:GetSprite():Load("gfx/grid/trapdoor_downpour.anm2",true)                
                    end
                end
            end
        end

        local sugar_pill_entries = GODMODE.save_manager.get_list_data("TempRoomColls",false,function(entry) 
            local args = GODMODE.util.string_split(entry,",")
            return {player=GODMODE.util.get_player_by_seed(tonumber(args[1])),coll=tonumber(args[2])} 
        end)

        if #sugar_pill_entries > 0 then 
            for _,entry in ipairs(sugar_pill_entries) do 
                if entry and entry.player then 
                    entry.player:GetEffects():RemoveCollectibleEffect(entry.coll)
                end
            end
        end
    end

    function GODMODE.mod_object:room_rewards(rng, pos)
        local level = GODMODE.level
        local room = GODMODE.room
        if level:GetStage() == LevelStage.STAGE5 and GODMODE.is_at_palace and room:GetType() == RoomType.ROOM_BOSS and GODMODE.util.total_item_count(GODMODE.registry.items.blood_key) > 0 then --palace entrance!
            local portal = Isaac.Spawn(GODMODE.registry.entities.ivory_portal.type, GODMODE.registry.entities.ivory_portal.variant, 0, room:FindFreePickupSpawnPosition(room:GetCenterPos()+Vector(-64,0)),Vector.Zero,nil)
            portal:Update()
        end

        -- dehazard boss and miniboss rooms by replacing spiked rocks, breaking spikes, etc
        if room:GetType() == RoomType.ROOM_BOSS or room:GetType() == RoomType.ROOM_MINIBOSS or room_data.SurpriseMiniboss == true then 
            if GODMODE.save_manager.get_config("DehazardBossRooms","true") == "true" then 
                GODMODE.util.dehazard_room()
            end
        end

        local room_data = GODMODE.level:GetCurrentRoomDesc()
        if (room:GetType() == RoomType.ROOM_MINIBOSS or room_data.SurpriseMiniboss == true) and room_data.Data.SubType ~= 15 then --15 = Krampus
            local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())
            local rewards = {
                function() 
                    Isaac.Spawn(GODMODE.registry.entities.heart_container.type, GODMODE.registry.entities.heart_container.variant, 0, pos, Vector.Zero, nil)
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
                if player.SubType == GODMODE.registry.players.t_elohim then 
                    local dmg = tonumber(GODMODE.save_manager.get_player_data(player,"BossDMG","0"))

                    if dmg <= player:GetTotalDamageTaken() then 
                        player:AddBrokenHearts(-2+-(math.min(1,player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHRIGHT))))
                        player:AddEternalHearts(2)
                    end
                end
            end)

            if StageAPI and StageAPI.Loaded and StageAPI.GetCurrentStage and StageAPI.GetCurrentStage() and StageAPI.GetCurrentStage().Name == "FruitCellar" then
                --redraw and redo requirements for secret entrance to downpour
                for slot=0,DoorSlot.NUM_DOOR_SLOTS do 
                    local door = room:GetDoor(slot)

                    if door ~= nil and door:GetSprite():GetFilename() == "gfx/grid/Door_Mines.anm2" then 
                        door:GetSprite():Load("gfx/grid/Door_Downpour.anm2",true)
                        door:SetLocked(true)
                        break 
                    end
                end
            end
        end


        if room:GetType() == RoomType.ROOM_DEFAULT then
            if GODMODE.util.has_curse(GODMODE.registry.blessings.fortitude,true) then
                if tonumber(GODMODE.save_manager.get_data("FortitudeCards","0")) < 2 then
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Card.CARD_HOLY, room:FindFreePickupSpawnPosition(pos), Vector.Zero, nil)
                    GODMODE.save_manager.set_data("FortitudeCards",tonumber(GODMODE.save_manager.get_data("FortitudeCards","0"))+1)
                    return true
                end
            end
            
            if GODMODE.util.has_curse(GODMODE.registry.blessings.justice,true) then
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

        if GODMODE.util.has_curse(GODMODE.registry.blessings.opportunity,true) and room:IsFirstVisit() and room:IsFirstEnemyDead() == true then 
            GODMODE.get_ent_data(Isaac.GetPlayer()).opportunity_cost = 1
        end
    end

    local thin_rooms = {
        [RoomShape.ROOMSHAPE_IH] = true,
        [RoomShape.ROOMSHAPE_IV] = true,
        [RoomShape.ROOMSHAPE_IIH] = true,
        [RoomShape.ROOMSHAPE_IIV] = true,
    }

    local alt_space_offsets = {
        Vector(-52,0),
        Vector(52,0),
        Vector(0,52),
        Vector(0,-52)
    }

    -- handle vanilla enemy Godmode alts!
    function GODMODE.mod_object:pre_entity_spawn(type,variant,subtype,pos,vel,spawner,seed)
        if GODMODE.util.is_start_of_run() or GODMODE.level.EnterDoor == -1 or seed == 0 then return end 

        local rng = RNG()
        rng:SetSeed(seed,35)
        local thin_flag = thin_rooms[Game():GetRoom():GetRoomShape()]
        local space_flag = true

        for _,off in ipairs(alt_space_offsets) do 
            if GODMODE.room:GetGridEntityFromPos(pos + off) ~= nil then space_flag = false break end 
        end

        if type < EntityType.ENTITY_EFFECT and (type > 9 or type == 5 or type == 6) then
            --Alt enemy / pickup generation
            local alt_enabled = (GODMODE.save_manager.get_config("EnemyAlts","true") == "true" and type > 9) 
                or (GODMODE.save_manager.get_config("PickupAlts","true") == "true" and (type == 5 or type == 6))
                
            if spawner == nil and alt_enabled and GODMODE.room:IsFirstVisit() and not GODMODE.room:IsFirstEnemyDead() then
                for ind,alt in ipairs(GODMODE.alt_entries.entries) do
                    --certain replacements are harder, and as such there is a qualifier for if they are allowed in thin rooms
                    if (alt.thin_rooms or true) == true or (alt.thin_rooms or true) == false and not thin_flag then 
                        -- add another qualifier for if the alt requires empty tiles in the cardinal directions next to the spawn position
                        if (alt.needs_surrounding_space or false) == false or (alt.needs_surrounding_space or false) == true and space_flag then 
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
        
                                if chance_function((alt.rep_chance[GODMODE.game.Difficulty+1] or alt.rep_chance[1]) * chance_modifier, alt.type, alt.variant, alt.subtype, alt.rep_type, alt.rep_variant, rng) then
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
        end
    end

    function GODMODE.mod_object:pre_npc_update(ent)
        if GODMODE.vs_played_in == nil then GODMODE.vs_played_in = {} end
        if GODMODE.bosses[ent.Variant] and GODMODE.room:GetType() == RoomType.ROOM_BOSS and GODMODE.vs_played_in[GODMODE.room:GetDecorationSeed()] ~= true and not StageAPI then
            GODMODE.sprites.vs_sprite:ReplaceSpritesheet(0, GODMODE.bosses[ent.Variant].portrait)
            GODMODE.sprites.vs_sprite:ReplaceSpritesheet(1, GODMODE.bosses[ent.Variant].name)
            GODMODE.sprites.vs_sprite:ReplaceSpritesheet(4, GODMODE.bosses[ent.Variant].spot)
            GODMODE.sprites.vs_sprite:LoadGraphics()
            GODMODE.vs_played_in[GODMODE.room:GetDecorationSeed()] = true
            GODMODE.cur_splash = GODMODE.sprites.vs_sprite
            GODMODE.cur_splash_pos = GODMODE.util.get_center_of_screen()
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
        if laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer() then
            local player = laser.SpawnerEntity:ToPlayer()
            local data = GODMODE.get_ent_data(player)

            if (player:GetPlayerType() == GODMODE.registry.players.deli or player:GetPlayerType() == GODMODE.registry.players.t_deli)
                    and (laser.FrameCount == 1 or laser.SpawnerEntity:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK))
                    -- and player:GetFireDirection() ~= Direction.NO_DIRECTION
                    and (not player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO) or player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_ZERO)
                            and not player:HasWeaponType(WeaponType.WEAPON_TEARS)) then

                if not (data.celeste_fire or false) then 
                    local flag = data.deli_last_fire_frame ~= GODMODE.game:GetFrameCount()

                    if player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) then
                        flag = GODMODE.game:GetFrameCount() - data.deli_last_fire_frame > 10
                    elseif player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
                        flag = GODMODE.game:GetFrameCount() % 20 == 1
                    end
                    
                    data.cur_deli_ang = laser.AngleDegrees
                    local margin = math.deg(math.abs(math.rad(laser.SpriteRotation) - math.rad(data.cur_deli_ang-90)))
    
                    if laser.FrameCount == 1 and laser:HasTearFlags(TearFlags.TEAR_LASERSHOT) and margin >= 45 then 
                        local col = laser:GetColor() 
                        laser:SetColor(Color(col.R,col.G,col.B,col.A * 0.15),99,10000,true,true)
                    end
    
                    if data.deli_last_fire_frame == nil or flag and not player:HasCollectible(CollectibleType.COLLECTIBLE_TRISAGION) then
                        data.proj_ref = laser
                        data.deli_last_fire_frame = GODMODE.game:GetFrameCount()
                        GODMODE.players[player:GetPlayerType()]:clone_fire(player, laser.Position, laser)
                    end
                end
            elseif player:GetPlayerType() == GODMODE.registry.players.t_gehazi and data.has_eyes == true then 
                if (laser.SubType == LaserSubType.LASER_SUBTYPE_LINEAR or laser.SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO)
                    and (laser.Position - player.Position):Length() < laser.Size+player.Size*2 then 
                    
                    if data.t_gehazi_laser then 
                        if laser.OneHit then 
                            player:AddCoins(-1)
                        end

                        data.t_gehazi_laser = false
                    end

                    if data.gold_stopwatch ~= true and 
                        (laser.FrameCount % (3+(laser.Variant == LaserVariant.THIN_RED and 5 or 0)) == 0 and not laser.OneHit 
                        or laser.OneHit and laser.FrameCount == 2) 
                        and player:GetNumCoins() > 0 then
                        
                        player:AddCoins(-1)
                        local c = Isaac.Spawn(GODMODE.registry.entities.shatter_coin.type,GODMODE.registry.entities.shatter_coin.variant,0,
                        player.Position,Vector(1,0):Rotated(laser:GetDropRNG():RandomInt(360)):Resized(laser:GetDropRNG():RandomInt(10)-5),player)
                        c:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        c.Velocity = Vector(laser:GetDropRNG():RandomInt(8)-4,laser:GetDropRNG():RandomInt(8)-4)    
                        data.laser_lost = true
                    end
                end
            end
        end
    end

    function GODMODE.mod_object:ent_kill(ent)
        if ent.Type == EntityType.ENTITY_TEAR then 
            local tear = ent:ToTear()
            
            if tear.Parent and tear.Parent:ToPlayer() then
                local player = tear.Parent:ToPlayer()
    
                if GODMODE.players[player:GetPlayerType()] and GODMODE.players[player:GetPlayerType()].tear_kill then
                    GODMODE.players[player:GetPlayerType()]:tear_kill(tear, player)
                end
            end    
        end
    end

    function GODMODE.mod_object:tear_collide(tear, ent2, first)
        if tear.Parent and tear.Parent:ToPlayer() then
            local player = tear.Parent:ToPlayer()

            if GODMODE.players[player:GetPlayerType()] and GODMODE.players[player:GetPlayerType()].tear_collide then
                GODMODE.players[player:GetPlayerType()]:tear_collide(tear, ent2, player)
            end
        end    
    end

    function GODMODE.mod_object:tear_init(tear)
        local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
        player = player or (tear.SpawnerEntity and tear.SpawnerEntity:ToTear() and tear.SpawnerEntity.Parent and tear.SpawnerEntity.Parent:ToPlayer())
        
        if player then
            if GODMODE.players[player:GetPlayerType()] and GODMODE.players[player:GetPlayerType()].tear_init then
                GODMODE.players[player:GetPlayerType()]:tear_init(tear, player)
            end
        end    
    end

    function GODMODE.mod_object:tear_fire(tear)
        if tear.Parent and tear.Parent:ToPlayer() then
            local player = tear.Parent:ToPlayer()

            if GODMODE.players[player:GetPlayerType()] and GODMODE.players[player:GetPlayerType()].tear_fire then
                GODMODE.players[player:GetPlayerType()]:tear_fire(tear, player)
            end

            if player:GetPlayerType() == GODMODE.registry.players.the_sign and not player:HasCollectible(CollectibleType.COLLECTIBLE_TRACTOR_BEAM) then
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
            elseif (player:GetPlayerType() == GODMODE.registry.players.deli or player:GetPlayerType() == GODMODE.registry.players.t_deli) and player:GetFireDirection() ~= Direction.NO_DIRECTION then
                local data = GODMODE.get_ent_data(player)

                if (data.deli_last_fire_frame == nil or data.deli_last_fire_frame ~= GODMODE.game:GetFrameCount()) and not data.celeste_fire then
                    data.proj_ref = tear
                    data.cur_deli_ang = tear.Velocity:GetAngleDegrees()
                    data.deli_last_fire_frame = GODMODE.game:GetFrameCount()
                    GODMODE.players[player:GetPlayerType()]:clone_fire(player, tear.Position - tear.Velocity, tear)
                end
            elseif (player:GetPlayerType() == GODMODE.registry.players.xaphan or player:GetPlayerType() == GODMODE.registry.players.t_elohim) and tear.Variant == TearVariant.BLUE then
                tear:ChangeVariant(TearVariant.BLOOD)
            end
        end
    end

    function GODMODE.mod_object:register_player(player)
        local existing_index = tonumber(GODMODE.save_manager.get_data("Player"..player.InitSeed,"-1")) > -1
        local cur = tonumber(GODMODE.save_manager.get_data("PlayerCount","0"))
        GODMODE.util.seeded_players[player.InitSeed] = player
 
        if not existing_index or GODMODE.util.is_start_of_run() then 
            -- GODMODE.log("existing?"..tostring(existing_index)..", start?"..tostring(GODMODE.util.is_start_of_run()),true)
            GODMODE.save_manager.set_data("PlayerCount", cur + 1)
            GODMODE.save_manager.set_data("Player"..(cur+1),player.InitSeed)
            GODMODE.save_manager.set_data("Player"..player.InitSeed,(cur+1),true)    
        elseif existing_index then 
            GODMODE.save_manager.set_data("PlayerCount", cur + 1)
        end
    end

    function GODMODE.mod_object:player_init(player)
        GODMODE.mod_object:register_player(player)
    end

    function GODMODE.mod_object:player_update(player)
        local data = GODMODE.get_ent_data(player)

        --little code experiment i had going on
        if GODMODE.validate_rgon() and GODMODE.save_manager.get_config("AutoChargeAttack","false") == "true" and false then  
            local weapon = player:GetWeapon(1)
            if weapon then 
                -- GODMODE.log("charge="..weapon:GetCharge()..", prev_charge="..tostring(data.prev_weapon_charge),true)

                if weapon:GetCharge() > 0 and weapon:GetCharge() == (data.prev_weapon_charge or (weapon:GetCharge() - 1)) then 
                    data.weapon_inc = (data.weapon_inc or 0) + 1
                    -- GODMODE.log("HELLO!",true)

                    if data.weapon_inc >= 10 and player:IsExtraAnimationFinished () then 
                        -- player:TakeDamage(0,DamageFlag.DAMAGE_FAKE,EntityRef(player),0)
                        -- player:TryForgottenThrow(player:GetShootingInput())
                    end
                else 
                    data.weapon_inc = nil
                end

                data.prev_weapon_charge = weapon:GetCharge()
            end
        end
        
        if GODMODE.birthday_mode and player:GetCollectibleNum(GODMODE.registry.items.party_hat) == 0 then 
            player:AddCollectible(GODMODE.registry.items.party_hat)
        end

        if GODMODE.validate_rgon() and GODMODE.playing_ending == Isaac.GetPlayer().InitSeed then 
            GODMODE.game:FinishChallenge()
        elseif GODMODE.is_animating() then
            player.ControlsEnabled = false
        elseif (GODMODE.cur_splash_timeout or 0) > 0 then
            player.ControlsEnabled = true
        end


        if tonumber(GODMODE.save_manager.get_player_data(player,"ControllerID","-1")) ~= player.ControllerIndex then 
            GODMODE.save_manager.set_player_data(player,"ControllerID",player.ControllerIndex)
        end

        local faithless = tonumber(GODMODE.save_manager.get_player_data(player,"FaithlessHearts","-1"))
        local hits = GODMODE.util.get_player_hits(player,true)
        local max_hits = 12 + (player:GetPlayerType() == PlayerType.PLAYER_MAGDALENE and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 6 or 0)

        if not player:IsCoopGhost() then 
            if faithless >= max_hits then 
                player:Kill()
                GODMODE.util.add_faithless(player,-1)
            end
            
            if faithless + hits + player:GetBrokenHearts() > max_hits then 
                -- GODMODE.save_manager.set_player_data(player,"FaithlessHearts",player:GetBrokenHearts())
                local dif = max_hits - (faithless + hits + player:GetBrokenHearts())
                if player:GetBoneHearts() > 0 then 
                    player:AddBoneHearts(dif)
                elseif player:GetSoulHearts() > 0 then 
                    player:AddSoulHearts(dif)
                elseif player:GetMaxHearts() > 0 then 
                    player:AddMaxHearts(dif)
                else 
                    GODMODE.util.add_faithless(player,max_hits - (faithless + hits + player:GetBrokenHearts()))
                end
            end    
        end



        if data then
            if (data.opportunity_cost or 0) > 0 then 
                player:UseCard(Card.CARD_SOUL_ISAAC,UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
                data.opportunity_cost = nil
            end

            data.time = data.time + 1
            data.real_time = data.real_time + 1
            
            if GODMODE.util.has_curse(GODMODE.registry.blessings.kindness,true) then
                if not GODMODE.room:IsClear() and not player:IsDead() then  
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
                            if GODMODE.room:GetType() == RoomType.ROOM_BOSS and (enemy.Type == EntityType.ENTITY_THE_HAUNT or GODMODE.util.count_enemies(nil,EntityType.ENTITY_GIDEON) > 0) or enemy:IsBoss() then 
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
                            GODMODE.sfx:Play(SoundEffect.SOUND_GASCAN_POUR,Options.SFXVolume + 0.25)
                            data.kindness_counter = 201
                        end
                    end
                else
                    data.kindness_counter = 201
                end
            end

            if GODMODE.util.has_curse(GODMODE.registry.blessings.patience,true) then 
                data.patience_counter = (data.patience_counter or 21) - 1

                if (data.patience_counter or 21) > 0 then 
                    data.patience_shoot = player.ControlsEnabled 
                    player.ControlsEnabled = false
                elseif (data.patience_counter or 21) == 0 then 
                    player.ControlsEnabled = data.patience_shoot or true
                end
            end
        end

        local player_data = GODMODE.players[player:GetPlayerType()]

        if (data.collectible_num_cache or -1) ~= player:GetCollectibleCount() then 
            if player_data and player_data.stats and player_data.stats["on_item_pickup"] then 
                player_data.stats["on_item_pickup"](player_data,player)
            end

            GODMODE.godhooks.call_hook("on_item_pickup",player)
            -- GODMODE.push_items("on_item_pickup",function(item) return player:HasCollectible(item.instance) end, player)

            data.collectible_num_cache = player:GetCollectibleCount()
        end
    
        if player_data then 
            if player.FrameCount < 3 then --start of run stuff
                if GODMODE.save_manager.get_player_data(player, "Init", "false") == "false" and GODMODE.level.EnterDoor == -1 then
                    if player_data and player_data.init then
                        player_data:init(player)
                    end
                    
                    if Isaac.GetChallenge() == GODMODE.registry.challenges.sugar_rush then 
                        for i=1,4 do 
                            player:AddCollectible(GODMODE.registry.items.sugar)
                        end
                    end
        
                    GODMODE.save_manager.set_player_data(player, "Init", "true", true)
                end    
            end

            if player_data.update then
                player_data:update(player, data)
            end

            if player_data.pocket_item and (player_data.pocket_valid == nil and player:GetActiveItem(ActiveSlot.SLOT_POCKET) ~= player_data.pocket_item or player_data.pocket_valid and player_data.pocket_valid[player:GetActiveItem(ActiveSlot.SLOT_POCKET)] ~= true) then
                player:AddCollectible(player_data.pocket_item, player_data.pocket_charge, true, ActiveSlot.SLOT_POCKET)
                -- player:SetActiveCharge(GODMODE.util.get_max_charge(player_data.pocket_item),ActiveSlot.SLOT_POCKET)
            end

            if player_data.red_health ~= nil and player_data.red_health == false then --remove red health for characters who cant have it
                if player:GetMaxHearts() > 0 then 
                    local hearts = player:GetMaxHearts()
                    player:AddMaxHearts(-hearts)

                    if player_data.soul_health ~= nil and player_data.soul_health == false then 
                        player:AddBlackHearts(hearts)
                    else
                        player:AddSoulHearts(hearts)
                    end
                end
        
                if player:GetHearts() > 0 then 
                    player:AddHearts(-player:GetHearts())
                end
            end

            if player_data.max_hits ~= nil then 
                local hits = GODMODE.util.get_player_hits(player,false,true)
                local max_hits = player_data.max_hits

                while hits > max_hits do 
                    if player:GetSoulHearts() > 0 then 
                        player:AddSoulHearts(-1)
                    elseif player:GetBoneHearts() > 0 then 
                        player:AddBoneHearts(-1) 
                    elseif player:GetMaxHearts() > 0 then 
                        player:AddMaxHearts(-2)
                    end

                    hits = GODMODE.util.get_player_hits(player)
                end
                if hits > max_hits then 
                end
            end
        end
    end

    function GODMODE.mod_object:eval_cache(player, cache)
        local player_data = GODMODE.players[player:GetPlayerType()]
        if player_data and player_data.stats then
            if player_data.stats[cache] then 
                player_data.stats[cache](player_data,player)
            end
        end

        if GODMODE.util.get_stage() > 0 and GODMODE.save_manager.get_player_data(player, "BaseStats","-1") == "-1" then 
            GODMODE.save_manager.set_player_data(player, "BaseStats",GODMODE.util.get_stat_score(player).score)
        end

        local penalty = tonumber(GODMODE.save_manager.get_player_data(player,"SOCPenalty","0"))
        if penalty > 0 then 
            if cache == CacheFlag.CACHE_DAMAGE then 
                player.Damage = player.Damage * (1.0-math.min(0.5,penalty*0.05))
            elseif cache == CacheFlag.CACHE_FIREDELAY then 
                player.MaxFireDelay = player.MaxFireDelay * (1.0+math.min(0.5,penalty*0.05))
            end
        end

        if GODMODE.validate_rgon() and player:HasPlayerForm(PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES) or player:HasPlayerForm(PlayerForm.PLAYERFORM_SPIDERBABY) then 
            Isaac.GetPersistentGameData():TryUnlock(GODMODE.registry.achievements.recluse)
        end
    end
        
    function GODMODE.mod_object:pickup_collide(pickup,ent,entfirst)
        local data = GODMODE.get_ent_data(pickup)
        
        if ent:ToPlayer() then
            local player = ent:ToPlayer()
            local pd = GODMODE.players[player:GetPlayerType()]

            if pd and GODMODE.players[player:GetPlayerType()].pickup_collide then
                local ret = GODMODE.players[player:GetPlayerType()]:pickup_collide(pickup, player)
                if ret ~= nil then return ret end
            end    
     
            if pickup.Variant == PickupVariant.PICKUP_COIN and player:GetPlayerType() == GODMODE.registry.players.t_gehazi then 
                player:AddCoins(1)
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                player:EvaluateItems()
                player:AddCoins(-1)
            end

            local red_heart = pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_HALF
                or pickup.SubType == HeartSubType.HEART_SCARED or pickup.SubType == HeartSubType.HEART_DOUBLEPACK or pickup.SubType == HeartSubType.HEART_ROTTEN
            local soul_heart = pickup.SubType == HeartSubType.HEART_SOUL or pickup.SubType == HeartSubType.HEART_HALF_SOUL
                or pickup.SubType == HeartSubType.HEART_BLACK or pickup.SubType == HeartSubType.HEART_BLENDED
            local valid_heart = pickup.SubType == HeartSubType.HEART_GOLDEN or pickup.SubType == HeartSubType.HEART_ROTTEN
            if pickup.Variant == PickupVariant.PICKUP_HEART and not valid_heart then 
                local max = (pd and pd.max_hits or 24)
                local full = max == GODMODE.util.get_player_hits(player,false,true)

                if pd and pd.max_hits and not full and not valid_heart
                    and not (soul_heart and player:HasCollectible(CollectibleType.COLLECTIBLE_ALABASTER_BOX) or not soul_heart)
                    and not (player:GetHearts() < player:GetMaxHearts() and red_heart or not red_heart) then 
                    return false 
                elseif not valid_heart and (GODMODE.get_ent_data(pickup) and GODMODE.get_ent_data(pickup).delirious_heart ~= true or true) 
                    and (pd and ((max <= 2) or ((pd.red_health ~= nil 
                    and pd.red_health == false) or not pd 
                    and red_heart) or 
                    pd.bone_health == false and pickup.SubType == HeartSubType.HEART_BONE)) then 

                    return pickup.Price > 0 and (pd == nil or (max > 2 or (pd.soul_health == true or pd.soul_health == false))) and not full
                        or (player:HasCollectible(CollectibleType.COLLECTIBLE_ALABASTER_BOX) 
                            and soul_heart and nil) or nil
                end
            end

            if (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM) and not pickup.Touched and not data.counted_collectible then 
                data.counted_collectible = true
                local pool = GODMODE.game:GetItemPool():GetPoolForRoom(GODMODE.room:GetType(), GODMODE.room:GetDecorationSeed())
                if pool == ItemPoolType.POOL_ANGEL then 
                    GODMODE.save_manager.add_player_list_data(player,"AngelCollected",pickup.SubType,true)
                elseif pool == ItemPoolType.POOL_DEVIL then 
                    GODMODE.save_manager.add_player_list_data(player,"DevilCollected",pickup.SubType,true)
                end

                GODMODE.save_manager.add_player_list_data(player,"ItemsCollected",pickup.SubType,true)
            end

            if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and pickup.Price < 0 and (pd and pd.devil_choice == true) then 
                pickup.OptionsPickupIndex = 665
                GODMODE.util.macro_on_enemies(nil,pickup.Type,pickup.Variant,nil,function(pick) 
                    pick = pick:ToPickup() 
                    if pick.Price < 0 then 
                        pick:Remove()
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pick.Position, Vector.Zero, ent)
                    end
                end)

                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, ent)
                player:AnimateCollectible(pickup.SubType)
                local config = Isaac.GetItemConfig():GetCollectible(pickup.SubType)
                player:QueueItem(config)
                GODMODE.game:GetHUD():ShowItemText(player,config)
                GODMODE.sfx:Play(SoundEffect.SOUND_DEVILROOM_DEAL,Options.SFXVolume * 2.0 + 1.0)
                pickup:Remove()
                return false 
            end

            if pickup.Variant == PickupVariant.PICKUP_TROPHY then 
                if GODMODE.game.Challenge == GODMODE.registry.challenges.sugar_rush then 
                    local sugar = GODMODE.registry.items.sugar
                    local flag = GODMODE.achievements.is_item_unlocked(sugar)
                    GODMODE.achievements.unlock_item(sugar)

                    if not flag then 
                        return true
                    end
                elseif GODMODE.game.Challenge == GODMODE.registry.challenges.the_galactic_approach then 
                    local paw = GODMODE.registry.items.celestial_paw
                    local flag = GODMODE.achievements.is_item_unlocked(paw)
                    GODMODE.achievements.unlock_item(paw)

                    if not flag then 
                        return true
                    end
                elseif GODMODE.game.Challenge == GODMODE.registry.challenges.out_of_time then 
                    local item = GODMODE.registry.items.a_second_thought
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

            if entfirst == false and GODMODE.room:GetType() ~= RoomType.ROOM_CURSE and pickup.Variant == PickupVariant.PICKUP_TAROTCARD and GODMODE.cards_pills.is_red_key(pickup.SubType) then 
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

            if pickup.Variant == PickupVariant.PICKUP_BIGCHEST and GODMODE.is_at_palace() then 
                GODMODE.play_ending()
                return false
            end

            -- update COTV timer visual!
            if (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM) and not pickup.Touched and pickup.SubType == GODMODE.registry.items.a_second_thought then 
                GODMODE.cotv_timer_st_cache = (GODMODE.cotv_timer_st_cache or 0) + 1
            end
        end
    end

    function GODMODE.mod_object:pickup_update(pickup)
        if pickup.Variant == PickupVariant.PICKUP_TAROTCARD and GODMODE.cards_pills.is_red_key(pickup.SubType) and pickup.FrameCount < 2 then 
            GODMODE.util.macro_on_players(function(player) 
                if GODMODE.get_ent_data(player).red_key_prevent_dupe == (GODMODE.game:GetFrameCount() - pickup.FrameCount) then 
                    pickup:Remove()
                    GODMODE.get_ent_data(player).red_key_prevent_dupe = nil
                end
            end)
        end

        if pickup.Variant == PickupVariant.PICKUP_COIN and pickup.CollisionDamage > 0 and pickup.Target ~= nil and pickup.Parent and pickup.Parent:ToPlayer() then
            if pickup.FrameCount < 30 then 
                pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            elseif pickup.GridCollisionClass == EntityGridCollisionClass.GRIDCOLL_WALLS then
                pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
            end

            if pickup:IsFrame(2,1) then 
                local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, pickup.Position+RandomVector():Resized(pickup.Size)+Vector(0,-pickup.Size/2), Vector.Zero, pickup):ToEffect()
                fx:SetTimeout(5)
                fx.LifeSpan = 20
                fx.Scale = pickup:GetDropRNG():RandomFloat() * 0.5 + 0.5
                fx:SetColor(Color(0.0,0.0,0.0,0.5,0.1,0.1,0.1),999,1,false,false)
                fx.DepthOffset = -100                    
            end

            local player = pickup.Parent:ToPlayer()
            local dir = (player.Position - pickup.Position)
            pickup.Velocity = pickup.Velocity + dir:Resized(pickup.FrameCount/90+dir:Length() * (1/256.0))

            if pickup:GetSprite().PlaybackSpeed == 1.0 and pickup:GetSprite():IsPlaying("Appear") then 
                pickup:GetSprite().PlaybackSpeed = 2.5
            elseif pickup:GetSprite().PlaybackSpeed ~= 1.0 then 
                pickup:GetSprite().PlaybackSpeed = 1.0
            end
        end

        if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM then
            if GODMODE.room:GetType() == RoomType.ROOM_PLANETARIUM and GODMODE.save_manager.get_config("MultiPlanetItems", "true") == "true" then
                pickup.OptionsPickupIndex = 0 --Enable more than one planetarium item to be picked up in certain rooms

                if pickup.FrameCount == 60 and GODMODE.util.count_enemies(nil,EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, nil) == 1 and GODMODE.util.count_enemies(nil,EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,TrinketType.TRINKET_TELESCOPE_LENS) == 0 and GODMODE.util.total_item_count(TrinketType.TRINKET_TELESCOPE_LENS, true) == 0 then 
                    Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,TrinketType.TRINKET_TELESCOPE_LENS,GODMODE.room:FindFreePickupSpawnPosition(GODMODE.room:GetCenterPos()), Vector.Zero, nil)
                end
            end
            
            if GODMODE.room:GetType() == RoomType.ROOM_TREASURE and GODMODE.level:GetStageType() > StageType.STAGETYPE_AFTERBIRTH and GODMODE.save_manager.get_config("BothRepPathItems", "true") == "true" then
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

        if GODMODE.util.has_curse(GODMODE.registry.blessings.charity,true) then
            pickup.Price = math.floor(pickup.Price / 2)
        end
    end

    function GODMODE.mod_object:post_get_collectible(coll,pool,decrease,seed)
        if not GODMODE.achievements.is_item_unlocked(coll) and GODMODE.reroll_loop_lock ~= true then
            GODMODE.log(coll.." is locked, rerolling")
            GODMODE.reroll_loop_lock = true
            local rep_item = GODMODE.game:GetItemPool():GetCollectible(pool,false,seed,CollectibleType.COLLECTIBLE_BREAKFAST)
            local depth = 50
            while not GODMODE.achievements.is_item_unlocked(rep_item) and depth > 0 do
                rep_item = GODMODE.game:GetItemPool():GetCollectible(pool,false,seed,CollectibleType.COLLECTIBLE_BREAKFAST)
                depth = depth - 1
            end
            GODMODE.reroll_loop_lock = nil

            return rep_item
        end
    end

    function GODMODE.mod_object:choose_curse(curses)
        if GODMODE.util.is_start_of_run() then 
            GODMODE.util.init_rand(GODMODE.game:GetSeeds():GetPlayerInitSeed())
        end
        local stage = GODMODE.level:GetStage()

        if GODMODE.game.Difficulty < Difficulty.DIFFICULTY_GREED and stage ~= LevelStage.STAGE4_3 and stage < LevelStage.STAGE7 then 
            local chance = 0.05 + math.min(0.95,GODMODE.util.total_item_count(GODMODE.registry.items.brass_cross) * 0.25)+0.1*GODMODE.util.total_item_count(GODMODE.registry.trinkets.white_candle,true)
            local hook_chance = GODMODE.godhooks.additive_call_hook("modify_blessing_chance",chance)
            GODMODE.log("Blessing chance for the stage is "..hook_chance.." (pre hook = "..chance.."), attempting roll...")
    
            if #GODMODE.util.get_curse_list(false) == 0 and GODMODE.util.random() < chance then
                local new_blessing = GODMODE.util.get_shifted_curse(GODMODE.registry.blessings[GODMODE.registry.blessing_keys[GODMODE.util.random(1,#GODMODE.registry.blessing_keys+1)]])
                GODMODE.log("Blessing \'"..new_blessing.."\' selected for stage!")
                return new_blessing
            end    
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

    function GODMODE.mod_object:use_pill(pill, player, flags)
        GODMODE.cards_pills.use_pill(pill,player,flags)
    end

    function GODMODE.mod_object:entity_removed(ent)
        local data = GODMODE.get_ent_data(ent)

        if data and data.persistent_data ~= nil and GODMODE.save_manager_lock ~= true then 
            GODMODE.save_manager.remove_persistent_entity_data(ent)
        end
    end

    function GODMODE.mod_object:choose_trinket(trinket,rng)
        if trinket == GODMODE.registry.trinkets.godmode then 
            return rng:RandomInt(TrinketType.NUM_TRINKETS-1)+1
        end
    end

    function GODMODE.mod_object:d10_use(coll,rng,player,useflags,slot,vardata)
        if GODMODE.d10 then 
            GODMODE.d10.on_d10_use(coll,rng,player,useflags,slot,vardata)
        end
    end

    function GODMODE.mod_object:pre_pickup_morph(pickup, type, variant, subtype, keep_price, keep_seed, ignore_mods)
        --picking a random collectible
        if pickup.Type == EntityType.ENTITY_PICKUP and pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE and type == pickup.Type and variant == pickup.Variant and subtype == 0 then 
            -- make sure we're looking at a godmode collectible
            if pickup.SubType >= GODMODE.registry.items.morphine and pickup.SubType <= GODMODE.registry.items.vessel_of_purity_3 then 
                local config = Isaac.GetItemConfig():GetCollectible(pickup.SubType)
                -- Godmode quest items cannot be morphed 
                if config.Tags & ItemConfig.TAG_QUEST == ItemConfig.TAG_QUEST then 
                    return false 
                end
            end
        end
    end

    function GODMODE.mod_object:shader_params(shaderName)
        GODMODE.shader_params = GODMODE.shader_params or {}
        if shaderName == 'GODMODE_RewindFx' then
            local params = {
                Time = GODMODE.shader_params.godmode_trinket_time or 0
            }
            return params
        elseif shaderName == 'GODMODE_BlackMushroom' then
            local params = {
                Time = GODMODE.game:GetFrameCount(),
                Intensity = GODMODE.shader_params.black_mushroom_intensity or 0,
            }
            return params
        elseif shaderName == 'GODMODE_DivineWrath' then 
            local params = {
                Time = GODMODE.shader_params.divine_wrath_time or 0,
            }
            return params
        elseif shaderName == 'GODMODE_EndingShader' then 
            local params = {
                Intensity = GODMODE.shader_params.ending_shader or 1.0,
            }
            return params
        end
    end

    function GODMODE.mod_object:mod_unloaded(unloaded_mod)
        if unloaded_mod.Name == GODMODE.mod_object.Name then 
            GODMODE.util = nil

            GODMODE.godhooks = nil
            GODMODE.items = nil
            GODMODE.monsters = nil
            
            GODMODE.alt_entries = nil
            GODMODE.players = nil
            GODMODE.armor_blacklist = nil
            GODMODE.room_override = nil
            GODMODE.loaded_rooms = nil
            GODMODE.bosses = nil
            GODMODE.cards_pills = nil
            GODMODE.d10 = nil
            GODMODE.itempools = nil
            GODMODE.achievements = nil
            GODMODE.menu = nil

            GODMODE.special_items = nil

            GODMODE.shader_params = nil 
            collectgarbage("collect")
        end
    end

    local correction_ents = {
        {GODMODE.registry.entities.correction_fx.type,GODMODE.registry.entities.correction_fx.variant,0},
        {GODMODE.registry.entities.correction_fx.type,GODMODE.registry.entities.correction_fx.variant,1},
        {GODMODE.registry.entities.correction_fx.type,GODMODE.registry.entities.correction_fx.variant,2},
        {GODMODE.registry.entities.correction_fx.type,GODMODE.registry.entities.correction_fx.variant,3},
    }

    GODMODE.paint_correction_room_fx = function()
        if StageAPI and StageAPI.Loaded and StageAPI.GetCurrentStage ~= nil then 
            StageAPI.ChangeRoomGfx(GODMODE.backdrops.correction_gfx)
        end
        
        local room = GODMODE.room
        local center = room:GetCenterPos()
        for _,ent in ipairs(correction_ents) do 
            Isaac.Spawn(ent[1],ent[2],ent[3],center,Vector.Zero,nil)
        end

        local poses = {
			{pos=GODMODE.room:GetCenterPos(),vel=RandomVector()*0.05},
			{pos=GODMODE.room:GetTopLeftPos(),vel=Vector(math.abs(RandomVector().X),math.abs(RandomVector().Y)*0.25)*0.05+Vector(0.05,0)},
			{pos=GODMODE.room:GetBottomRightPos(),vel=Vector(math.abs(RandomVector().X),math.abs(RandomVector().Y)*0.25)*-0.05-Vector(0.05,0)}
		}

		for _,pos in ipairs(poses) do
			local fog = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MIST, 0, pos.pos, pos.vel, nil)
			fog:Update()
			fog:Update()
			fog:Update()
            -- fog:SetColor(Color(8/255,0,0,1,-1,-1,-1),999,1,false,false)
		end
    end

    GODMODE.observatory_door_file = "gfx/grid/observatory_door.anm2"
    
    GODMODE.paint_observatory_door = function(door)
        if door:GetSprite():GetFilename() ~= GODMODE.observatory_door_file then 
            -- door.ExtraSprite = Sprite()
            -- door.ExtraSprite:Load("gfx/grid/observatory_flames.anm2",true)
            -- door.ExtraVisible = true
            local sprite = door:GetSprite()
            sprite:Load(GODMODE.observatory_door_file,true)

            local doorfx = Isaac.Spawn(GODMODE.registry.entities.observatory_fx.type,GODMODE.registry.entities.observatory_fx.variant,8,GODMODE.room:GetDoorSlotPosition(door.Slot),Vector.Zero,nil)
            doorfx:GetSprite():Load("gfx/grid/observatory_flames.anm2",true)
            doorfx:GetSprite().Rotation = door.Slot % 4 * 90-90

            if GODMODE.room:IsClear() then 
                sprite:Play("Opened",true)
                doorfx:GetSprite():Play("Opened",true)
                -- door.ExtraSprite:Play("Opened",false)
            else
                sprite:Play("Closed",true)
                doorfx:GetSprite():Play("Closed",true)
                -- door.ExtraSprite:Play("Closed",false)
            end
        end
    end

    GODMODE.correction_door_file = "gfx/grid/correction_door.anm2"
    GODMODE.correction_door2_file = "gfx/grid/correction_door2.anm2"
    
    GODMODE.paint_correction_door = function(door, corrupt)
        local sprite = door:GetSprite()
        sprite:Load(GODMODE.correction_door2_file,true)
        sprite:Play("Opened",true)
    end

    local observatory_ents = {
        {GODMODE.registry.entities.observatory_fx.type,GODMODE.registry.entities.observatory_fx.variant,0},
        {GODMODE.registry.entities.observatory_fx.type,GODMODE.registry.entities.observatory_fx.variant,1},
        {GODMODE.registry.entities.observatory_fx.type,GODMODE.registry.entities.observatory_fx.variant,2},
        {GODMODE.registry.entities.observatory_fx.type,GODMODE.registry.entities.observatory_fx.variant,3},
        {GODMODE.registry.entities.observatory_fx.type,GODMODE.registry.entities.observatory_fx.variant,4},
        {GODMODE.registry.entities.observatory_fx.type,GODMODE.registry.entities.observatory_fx.variant,5},
        {GODMODE.registry.entities.observatory_fx.type,GODMODE.registry.entities.observatory_fx.variant,6},
        {GODMODE.registry.entities.observatory_fx.type,GODMODE.registry.entities.observatory_fx.variant,7},
        {GODMODE.registry.entities.observatory_fx.type,GODMODE.registry.entities.observatory_fx.variant,9},
    }

    GODMODE.paint_observatory_room_fx = function()
        local room = GODMODE.room
        local center = room:GetCenterPos()
        for _,observatory_ents in ipairs(observatory_ents) do 
            Isaac.Spawn(observatory_ents[1],observatory_ents[2],observatory_ents[3],center,Vector.Zero,nil)
        end

        for i=0,DoorSlot.NUM_DOOR_SLOTS-1 do 
            local door_spot = room:GetDoor(i)
            if door_spot and door_spot:IsOpen() then 
                local door = Isaac.Spawn(GODMODE.registry.entities.observatory_fx.type,GODMODE.registry.entities.observatory_fx.variant,8,room:GetDoorSlotPosition(i),Vector.Zero,nil)
                door:GetSprite().Rotation = i % 4 * 90-90

                if door_spot.TargetRoomType ~= RoomType.ROOM_DEFAULT then 
                    door:GetSprite():Load(door_spot:GetSprite():GetFilename(),true)
                else 
                    local doorfx = Isaac.Spawn(GODMODE.registry.entities.observatory_fx.type,GODMODE.registry.entities.observatory_fx.variant,8,room:GetDoorSlotPosition(i),Vector.Zero,nil)
                    doorfx:GetSprite():Load("gfx/grid/observatory_flames.anm2",true)
                    doorfx:GetSprite().Rotation = i % 4 * 90-90
                end
            end
        end
    end

    GODMODE.gen_observatory = function(door_slot, grid_index)
        local level = GODMODE.level
        grid_index = grid_index or level:GetCurrentRoomIndex()
        local room = level:GetRoomByIdx(grid_index)

        if level:MakeRedRoomDoor(grid_index, door_slot) then 
            --new room will appear last in the list of rooms
            GODMODE.save_manager.add_list_data("ObservatoryGridIdx",level:GetRooms():Get(level:GetRooms().Size-1).SafeGridIndex)
            local door = GODMODE.room:GetDoor(door_slot)
            if door ~= nil then 
                GODMODE.paint_observatory_door(door)
            end

            GODMODE.cached_observatory_ids = nil
            return true
        end

        return false
    end

    GODMODE.get_observatory_ids = function()
        if GODMODE.cached_observatory_ids == nil then 
            local ret = {}
            GODMODE.save_manager.get_list_data("ObservatoryGridIdx",nil,function(val) 
                ret[tonumber(val)] = true
                return {}
            end)
            
            GODMODE.cached_observatory_ids = ret
        end

        return GODMODE.cached_observatory_ids
    end

    --used to check for existing grid indexes
    local doorslot_shifts = {
        [DoorSlot.LEFT0] = -1,
        [DoorSlot.UP0] = -13,
        [DoorSlot.RIGHT0] = 1,
        [DoorSlot.DOWN0] = 13,
        [DoorSlot.LEFT1] = 12,
        [DoorSlot.UP1] = -12,
        [DoorSlot.RIGHT1] = 15,
        [DoorSlot.DOWN1] = 14,
    }

    local shape_shifts = {
        [RoomShape.ROOMSHAPE_LTL] = 0,
        [RoomShape.ROOMSHAPE_LTR] = -1,
        [RoomShape.ROOMSHAPE_LBL] = -13,
        [RoomShape.ROOMSHAPE_LBR] = -14,
    }

    GODMODE.gen_observatory_in_stage = function(new_level) -- new level should be false if you are manually calling this
        new_level = new_level or false 
        if StageAPI and GODMODE.roomgen then 
            GODMODE.log("attempting to generate observatory...",true)

            local desc = GODMODE.roomgen:GenerateRoomFromLuarooms(GODMODE.observatory_rooms,new_level or true)            
            cached_observatory_ids = nil

            if desc ~= false and desc ~= nil then 
                GODMODE.log("generated observatory! sgid="..desc.SafeGridIndex,true)
                GODMODE.save_manager.add_list_data("ObservatoryGridIdx",desc.SafeGridIndex,true)
                GODMODE.observatory_door_cache = nil
                return desc
            else 
                GODMODE.log("no observatory generated",true)
                return false 
            end
        else 
            local level = GODMODE.level
            local rooms = level:GetRooms()
            local chance = 0.01
            local gen_success = false 
            local depth = 50
    
            local grid_map = {}
            local room_list = {}
    
            -- create gridid map first
            for i=0, rooms.Size-1 do
                local room = rooms:Get(i)
                grid_map[room.GridIndex] = true
                table.insert(room_list,room)
            end
    
            -- for x=0,13 do
            --     local row = "" 
            --     for y=0,13 do 
            --         local index = x*13 + y
    
            --         if grid_map[index] ~= true then 
            --             row = row.."0 "
            --         else 
            --             row = row.."X "
            --         end
            --     end
    
            --     GODMODE.log(row,true)
            -- end
    
            while not gen_success and depth > 0 do 
                local list_copy = GODMODE.util.deep_copy(room_list)
    
                while #list_copy > 0 do
                    local list_index = math.floor(GODMODE.util.random(1,#list_copy+1))
                    local room = list_copy[list_index]
    
                    local index = (room.GridIndex)
                    -- GODMODE.log("index="..index,true)
                    
                    if room.Data.Type == RoomType.ROOM_DEFAULT then
                        if GODMODE.util.random() < chance then
                            local max_slots = DoorSlot.NUM_DOOR_SLOTS
                            local slot_list = {}
    
                            while max_slots > 0 do 
                                local slot = math.floor(GODMODE.util.random(1,max_slots))
    
                                if slot_list[slot] ~= true then 
                                    slot_list[slot] = true
    
                                    if slot+1 > GODMODE.util.get_max_doors(room.Data.Shape) then break end 
                                    local shifted_index = index+(doorslot_shifts[slot] or 0)+(shape_shifts[room.Data.Shape] or 0)
        
                                    -- GODMODE.log("checking room "..index
                                    --     .." (shifted id="..shifted_index
                                    --     ..", slot="..slot
                                    --     ..", present? "..tostring(grid_map[shifted_index]),true)
                                    
                                    -- 168 is 13x13-1 for the maximum grid index
                                    if shifted_index >= 0 and shifted_index <= 168 and grid_map[shifted_index] ~= true then 
                                        if GODMODE.gen_observatory(slot, room.SafeGridIndex) then 
                                            GODMODE.log("generated observatory in room "..index.." for doorslot "..slot.."!",false)
                                            GODMODE.save_manager.add_list_data("ObservatoryGridIdx",""..room.SafeGridIndex,true)
                                            gen_success = room
                                        end    
                                    end
    
                                    max_slots = max_slots - 1
                                end
                            end
    
                            break
                        else
                            chance = chance + 0.09
                        end
                    end 
    
                    table.remove(list_copy,list_index)
                end
    
                depth = depth - 1
            end

            cached_observatory_ids = nil
            GODMODE.observatory_door_cache = nil

            level:UpdateVisibility()
    
            return gen_success
        end
    end

    -- modders: to set a room to use the observatory aesthetic, 
    --      add to ObservatoryGridIdx the safe grid index of the room using GODMODE.save_manager.add_list_data("ObservatoryGridIdx", value, save or false)
    --      To remove a room from the list use GODMODE.save_manager.remove_list_data("ObservatoryGridIdx", value, save or false)
    GODMODE.is_in_observatory = function()
        local in_flag = GODMODE.save_manager.list_contains("ObservatoryGridIdx",nil,function(ele) return ele == ""..GODMODE.level:GetCurrentRoomDesc().SafeGridIndex end) 
        
        return in_flag
    end

    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_GAME_STARTED , GODMODE.mod_object.game_start)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_GAME_END, GODMODE.mod_object.game_end)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, GODMODE.mod_object.game_exit)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, GODMODE.mod_object.shader_params)
    
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, GODMODE.mod_object.new_level)
    GODMODE.mod_object:AddPriorityCallback(ModCallbacks.MC_POST_CURSE_EVAL, CallbackPriority.LATE, GODMODE.mod_object.choose_curse)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, GODMODE.mod_object.new_room)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, GODMODE.mod_object.room_rewards)
    
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_UPDATE, GODMODE.mod_object.post_update)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_RENDER, GODMODE.mod_object.post_render)  
    
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, GODMODE.mod_object.player_init)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, GODMODE.mod_object.player_update)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, GODMODE.mod_object.post_player_render)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, GODMODE.mod_object.tear_fire)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, GODMODE.mod_object.tear_init)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, GODMODE.mod_object.tear_collide, EntityType.EntityTear)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE , GODMODE.mod_object.laser_update)  
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, GODMODE.mod_object.eval_cache)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_GET_CARD, GODMODE.mod_object.choose_card)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_USE_CARD, GODMODE.mod_object.use_card)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_USE_PILL, GODMODE.mod_object.use_pill)

    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, GODMODE.mod_object.pre_npc_update)  
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_NPC_UPDATE, GODMODE.mod_object.npc_update)  
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_NPC_INIT, GODMODE.mod_object.npc_init)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, GODMODE.mod_object.npc_kill)

    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, GODMODE.mod_object.pre_entity_spawn)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, GODMODE.mod_object.npc_hit)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, GODMODE.mod_object.entity_removed)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, GODMODE.mod_object.ent_kill, EntityType.ENTITY_TEAR)

    GODMODE.mod_object:AddCallback(ModCallbacks.MC_USE_ITEM, GODMODE.mod_object.d10_use, CollectibleType.COLLECTIBLE_D10)  
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, GODMODE.mod_object.post_get_collectible)

    GODMODE.mod_object:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, GODMODE.mod_object.pickup_update)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_PICKUP_MORPH, GODMODE.mod_object.pre_pickup_morph)
    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, GODMODE.mod_object.pickup_collide)

    GODMODE.mod_object:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, GODMODE.mod_object.familiar_update)  

    GODMODE.mod_object:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, GODMODE.mod_object.mod_unloaded)  
    
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

        elseif cmd == "stagetester" then  --debug command to execute a sequence of commands to set up for testing persistent data
            Isaac.ExecuteCommand("debug 8")
            Isaac.ExecuteCommand("g c84")
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
            Isaac.ExecuteCommand("g c115")

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
        elseif cmd == "statscore" then 
            local player_id = params[1] or nil 
            local display_func = function(player)
                local score = GODMODE.util.get_stat_score(player)
                local base_score = tonumber(GODMODE.save_manager.get_player_data(player,"BaseStats","-1"))

                Isaac.ConsoleOutput("Score for player "..player.ControllerIndex.." ("..player:GetName().."):")

                for stat,score in pairs(score.breakdown) do 
                    Isaac.ConsoleOutput("\n"..stat..": "..score.."/"..GODMODE.util.stat_dist[stat])
                end

                Isaac.ConsoleOutput("\nTotal Score: "..score.score.."/60")

                if base_score == -1 then 
                    Isaac.ConsoleOutput("\nBase Score is still being calculated. It will be an average of this score throughout the first floor.")
                else
                    Isaac.ConsoleOutput("\nBase Score ("..base_score.."/60) Scaled Value: "..(base_score * GODMODE.util.get_stat_scale()).."/60")
                end
            end

            if player_id == nil then 
                Isaac.ConsoleOutput("Stat scores of all players (use the player index as an argument to view 1 score):\n")
                GODMODE.util.macro_on_players(function(player) display_func(player) end)
            else
                display_func(Isaac.GetPlayer(tonumber(player_id)))
            end 
        elseif cmd == "gm_setconfig" or cmd == "gm_sc" then 
            params = GODMODE.util.string_split(params," ")
            local key = params[1] or nil 
            local val = params[2] or nil
            if key == "" then key = nil end 

            if key ~= nil and val == nil then 
                local cur_val = GODMODE.save_manager.get_config(key,nil)
                if key ~= "list" then
                    if cur_val ~= nil then 
                        Isaac.ConsoleOutput("Config Key \'"..key.."\' is currently set to \'"..cur_val.."\'")                        
                    else
                        Isaac.ConsoleOutput("Config Key \'"..key.."\' does not exist. Try \'gm_setconfig list\' to see valid config keys")
                    end
                elseif GODMODE.save_manager.god_data ~= nil then 
                    local list = (GODMODE.save_manager.god_data.config or {})
                    Isaac.ConsoleOutput("All currently registered config keys: \n")
                    local sep = 0
                    local cur = ""

                    for key,val in pairs(list) do 
                        cur = cur..key.." ("..val..") | "
                        sep = sep + 1

                        if sep >= 3 then 
                            sep = 0 
                            Isaac.ConsoleOutput(cur.."\n")
                            cur = ""
                        end
                    end
                end
            elseif key ~= nil and val ~= nil then 
                GODMODE.save_manager.set_config(key, val, true)
                Isaac.ConsoleOutput("Set config key \'"..key.."\' to \'"..val.."\'!")
            else
                Isaac.ConsoleOutput("Usage: \'gm_setconfig <key> <value>\' or \'gm_setconfig list\'")
            end
        elseif cmd == "keepah_mode" then 
            GODMODE.keepah_mode = not GODMODE.keepah_mode
            Isaac.ConsoleOutput("Keepah Mode Toggled for this session!!")
        elseif cmd == "birthday_mode" then 
            GODMODE.birthday_mode = not GODMODE.birthday_mode
            Isaac.ConsoleOutput("Birthday Mode Toggled for this session!! Enjoy the cake!")
        elseif cmd == "gm_setdata" or cmd == "gm_sd" then 
            params = GODMODE.util.string_split(params," ")
            local key = params[1] or nil 
            local val = params[2] or nil
            if key == "" then key = nil end 

            if key ~= nil and val == nil then 
                local cur_val = GODMODE.save_manager.get_config(key,nil)
                if key ~= "list" then
                    if cur_val ~= nil then 
                        Isaac.ConsoleOutput("Run Key \'"..key.."\' is currently set to \'"..cur_val.."\'")                        
                    else
                        Isaac.ConsoleOutput("Run Key \'"..key.."\' does not exist. Try \'gm_setdata list\' to see valid data keys")
                    end
                elseif GODMODE.save_manager.god_data ~= nil then 
                    local list = (GODMODE.save_manager.god_data.dynamic or {})
                    Isaac.ConsoleOutput("All currently registered run keys: \n")
                    local sep = 0
                    local cur = ""

                    for key,val in pairs(list) do 
                        if not (type(val) == "table" or type(val) == "userdata") then 
                            cur = cur..key.." ("..val..") | "
                            sep = sep + 1
    
                            if sep >= 3 then 
                                sep = 0 
                                Isaac.ConsoleOutput(cur.."\n")
                                cur = ""
                            end    
                        end
                    end
                end
            elseif key ~= nil and val ~= nil then 
                GODMODE.save_manager.set_config(key, val, true)
                Isaac.ConsoleOutput("Set run key \'"..key.."\' to \'"..val.."\'!")
            else
                Isaac.ConsoleOutput("Usage: \'gm_setdata <key> <value>\' or \'gm_setdata list\'")
            end
        end
    end)


    GODMODE.log("Loaded Successfully! (V0.9)\nGodmode commands to try: gm_setconfig, cotv_debug, fabrun, statscore", true)
end