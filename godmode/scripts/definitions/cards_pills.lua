local cards_pills = {}

local pok_transition = {
    [GODMODE.registry.cards.pok_8] = GODMODE.registry.cards.pok_7,
    [GODMODE.registry.cards.pok_7] = GODMODE.registry.cards.pok_6,
    [GODMODE.registry.cards.pok_6] = GODMODE.registry.cards.pok_5,
    [GODMODE.registry.cards.pok_5] = GODMODE.registry.cards.pok_4,
    [GODMODE.registry.cards.pok_4] = GODMODE.registry.cards.pok_3,
    [GODMODE.registry.cards.pok_3] = GODMODE.registry.cards.pok_2,
    [GODMODE.registry.cards.pok_2] = Card.CARD_CRACKED_KEY,
}

local pok_count = { --count for helper function
    [GODMODE.registry.cards.pok_8] = 8,
    [GODMODE.registry.cards.pok_7] = 7,
    [GODMODE.registry.cards.pok_6] = 6,
    [GODMODE.registry.cards.pok_5] = 5,
    [GODMODE.registry.cards.pok_4] = 4,
    [GODMODE.registry.cards.pok_3] = 3,
    [GODMODE.registry.cards.pok_2] = 2,
    [Card.CARD_CRACKED_KEY] = 1,
}

cards_pills.is_red_key = function(subtype)
    return pok_transition[subtype] ~= nil or subtype == Card.CARD_CRACKED_KEY
end

cards_pills.get_red_key_count = function(player)
    local count = 0 

    for _,card in pairs(GODMODE.registry.cards) do 
        if card ~= GODMODE.registry.cards.torn_page then 
            if pok_count[card] and player:GetCard(0) == card or player:GetCard(1) == card or player:GetCard(2) == card or player:GetCard(3) == card then 
                local off = math.abs(GODMODE.registry.cards.pok_2 - card) + 2
                count = count + pok_count[card]
            end
        end
    end

    return count
end

cards_pills.get_red_key_for_count = function(count)
    if count > 1 and count < 9 then
        return GODMODE.registry.cards.pok_2 - (count - 2)
    elseif count == 1 then 
        return Card.CARD_CRACKED_KEY
    end
end

local max_doors = { --used for pile of keys
    [RoomShape.ROOMSHAPE_1x1] = 4,
    [RoomShape.ROOMSHAPE_IH] = 2,
    [RoomShape.ROOMSHAPE_IV] = 2,
    [RoomShape.ROOMSHAPE_1x2] = 6,
    [RoomShape.ROOMSHAPE_IIV] = 2,
    [RoomShape.ROOMSHAPE_2x1] = 6,
    [RoomShape.ROOMSHAPE_IIH] = 2,
    [RoomShape.ROOMSHAPE_2x2] = 8,
    [RoomShape.ROOMSHAPE_LTL] = 8,
    [RoomShape.ROOMSHAPE_LTR] = 8,
    [RoomShape.ROOMSHAPE_LBL] = 8,
    [RoomShape.ROOMSHAPE_LBR] = 8,
}

local pok_use_effect = function(card,player,flags) 
    local echo_chamber = player:HasCollectible(CollectibleType.COLLECTIBLE_ECHO_CHAMBER)

    if echo_chamber == true then 
        local data = GODMODE.get_ent_data(player)

        if (data.use_frame or -1) == (GODMODE.frame_count or GODMODE.game:GetFrameCount()) then 
            return
        elseif data.use_frame ~= nil then 
            data.use_frame = nil 
        end

        data.use_frame = (GODMODE.frame_count or GODMODE.game:GetFrameCount())
    end

    local level = GODMODE.level
    local room = GODMODE.room
    local door_count = 0
    local closest_door = nil

    for doorslot=0,DoorSlot.NUM_DOOR_SLOTS-1 do 
        if doorslot+1 > GODMODE.util.get_max_doors(room:GetRoomShape()) then break end 

        if room:GetDoor(doorslot) ~= nil then 
            door_count = door_count + 1 
        end

        local door_pos = room:GetDoorSlotPosition(doorslot)
            
        if closest_door == nil or (player.Position - room:GetDoorSlotPosition(closest_door)):Length() > (player.Position - door_pos):Length() then 
            closest_door = doorslot
        end
    end

    local success = level:MakeRedRoomDoor(level:GetCurrentRoomIndex(), closest_door)
    player:AnimateCard(Card.CARD_CRACKED_KEY)
    
    local doors = {}
    local door_count2 = 0
    local bluewomb_flag = level:GetStage() == LevelStage.STAGE4_3 and GODMODE.save_manager.get_config("BlueWombRework","true","true") == "true"
    
    for doorslot=0,DoorSlot.NUM_DOOR_SLOTS-1 do 
        local door = room:GetDoor(doorslot)
        if door ~= nil then 
            door_count2 = door_count2 + 1 
            -- table.insert(doors, room:GetDoor(doorslot))
            if door.TargetRoomIndex == GridRooms.ROOM_ERROR_IDX and bluewomb_flag then
                door:TryBlowOpen(true,player)
            end
        end
    end    
    
    if door_count2 == door_count then 
        player:AddCard(card)

        if player:HasTrinket(TrinketType.TRINKET_ENDLESS_NAMELESS) then 
            GODMODE.get_ent_data(player).red_key_prevent_dupe = (GODMODE.frame_count or GODMODE.game:GetFrameCount())
        end
    else
        if pok_transition[card] then 
            player:AddCard(pok_transition[card])
        end
    end
end

cards_pills.card_actions = {
    [GODMODE.registry.cards.torn_page] = {
        choice_params = {chance=0.0375,playing=true,runes=false,only_runes=false},
        use_effect = function(card,player,flags) 
            local book = GODMODE.special_items:get_book_item(player:GetDropRNG())

            if book ~= nil then 
                player:UseActiveItem(book, true, true, true, true)
            end
        end
    },
    [GODMODE.registry.cards.soc] = {
        choice_params = {chance=0.0,playing=false,runes=false,only_runes=false},
        use_effect = function(card,player,flags) 
            local killed = false 
            GODMODE.log("soc used!",true)

            GODMODE.util.macro_on_enemies(nil,GODMODE.registry.entities.call_of_the_void.type,GODMODE.registry.entities.call_of_the_void.variant,-1,function(cotv)
                GODMODE.log("checking? sub="..cotv.SubType,true)
                if cotv.SubType > 0 then 
                    cotv.Velocity = cotv.Velocity * 0.25
                    GODMODE.get_ent_data(cotv).spent = true
                    cotv:GetSprite():Play("OrbKill",true)
                    killed = true
                    GODMODE.log("found one! sub="..cotv.SubType,true)
                end
            end, nil, true)

            if killed then 
                GODMODE.save_manager.set_player_data(player,"SOCPenalty",tonumber(GODMODE.save_manager.get_player_data(player,"SOCPenalty","0"))+1,true)
                player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
                player:EvaluateItems()
    
                local count = tonumber(GODMODE.save_manager.get_data("VoidBHProj","0")) + tonumber(GODMODE.save_manager.get_data("VoidDMProj","0"))
    
                if count > 0 then 
                    local rooms = GODMODE.level:GetRooms()
                    local chance = 0.01
                    GODMODE.save_manager.set_data("SOCSpawnSeed","-1")
                    local depth = 10
        
                    while GODMODE.save_manager.get_data("SOCSpawnSeed","-1") == "-1" and depth > 0 do
                        depth = depth - 1
                        for i=0, rooms.Size-1 do
                            local room = rooms:Get(i)
                            if room.Data.Type == RoomType.ROOM_DEFAULT and room.DecorationSeed ~= (GODMODE.room_decor_seed or GODMODE.room:GetDecorationSeed()) then
                                if GODMODE.util.random() < chance then
                                    GODMODE.save_manager.set_data("SOCSpawnSeed",room.DecorationSeed)
                                    break
                                else
                                    chance = chance + 0.09
                                end
                            end 
                        end
                    end    
                end    
                
                return {Discharge=true,Remove=true,ShowAnim=true}
            else 
                return {Discharge=false,Remove=false,ShowAnim=true}
            end
        end
    },
    [GODMODE.registry.cards.pok_8] = {
        choice_params = {chance=0.000000001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
    [GODMODE.registry.cards.pok_7] = {
        choice_params = {chance=0.00000001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
    [GODMODE.registry.cards.pok_6] = {
        choice_params = {chance=0.0000001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
    [GODMODE.registry.cards.pok_5] = {
        choice_params = {chance=0.000001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
    [GODMODE.registry.cards.pok_4] = {
        choice_params = {chance=0.00001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
    [GODMODE.registry.cards.pok_3] = {
        choice_params = {chance=0.0001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
    [GODMODE.registry.cards.pok_2] = {
        choice_params = {chance=0.001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
}

cards_pills.pill_actions = {
    [GODMODE.registry.pills.opiate] = function(pill, player, flags, horsepill)
        player:GetEffects():AddCollectibleEffect(GODMODE.registry.items.sugar, true)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()

        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_WHITE, 0,player.Position,Vector.Zero,player):ToEffect()
        creep:SetTimeout(140-player:GetPillRNG(pill):RandomInt(40))
        creep.Scale = 1.5-player:GetPillRNG(pill):RandomFloat()*0.25
        creep:Update()

        for i=1, 16 do 
            local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TOOTH_PARTICLE, 0,player.Position,RandomVector():Resized((player:GetPillRNG(pill):RandomFloat() * 2 - 1) * 12),player):ToEffect()
            fx:SetTimeout(140-player:GetPillRNG(pill):RandomInt(40))
            fx.Scale = 2.5-player:GetPillRNG(pill):RandomFloat()*0.4
            fx:SetColor(Color(1,1,1,1,1,1,1), 999, 1, false, false)
            fx:Update()

            if i % 4 == 0 then 
                fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_ATTRACT, 0,player.Position,Vector.Zero,player):ToEffect()
                fx:SetTimeout(5 + i * 5)
                fx:Update()
            end
        end

        GODMODE.sfx:Play(SoundEffect.SOUND_MAGGOT_BURST_OUT)
        GODMODE.sfx:Play(SoundEffect.SOUND_CHILD_HAPPY_ROAR_SHORT)

        if horsepill then 
            player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP, false, true, true, false)
        end

        return true
    end,
    [GODMODE.registry.pills.gild_pilled] = function(pill, player, flags, horsepill)
        player:AnimateHappy()
        local amt = (0.1 + (horsepill and 0.3 or 0.0))
        GODMODE.api.add_gilded_chance(amt)
        return true
    end,
    [GODMODE.registry.pills.multivitamin] = function(pill, player, flags, horsepill)
        player:AnimateHappy()
        return true
    end,
    [GODMODE.registry.pills.somethings_changed] = function(pill, player, flags, horsepill)
        player:AnimateSad()
        local coins = math.ceil(player:GetNumCoins() * 0.66)
        local keys = math.ceil(player:GetNumKeys() * 0.66)
        local bombs = math.ceil(player:GetNumBombs() * 0.66)
        player:AddCoins(-coins)
        player:AddKeys(-keys)
        player:AddBombs(-bombs)
        local pool = (coins + keys + bombs) * (horsepill and 1.25 or 1)

        while pool > 0 do
            local spot = player:GetPillRNG(pill):RandomFloat()

            if spot < 1 / 3 then
                player:AddKeys(1)
            elseif spot < 2 / 3 then
                player:AddBombs(1)
            else 
                player:AddCoins(1)
            end
            
            pool = pool - 1
        end

        return true
    end
}

cards_pills.choose_card = function(rng, card, playing, runes, only_runes)
    for ref_card,actions in pairs(cards_pills.card_actions) do 
        local flag = false 
        if ref_card == card then flag = true end
        local choice = actions.choice_params 

        if rng:RandomFloat() < choice.chance then 
            if playing == choice.playing or runes == choice.runes or only_runes == choice.only_runes then 
                return ref_card
            elseif flag then 
                return Card.CARD_RANDOM
            end
        elseif flag then 
            return Card.CARD_RANDOM
        end
    end
end

cards_pills.use_card = function(card, player, flags)
    if cards_pills.card_actions[card] ~= nil then 
        cards_pills.card_actions[card].use_effect(card,player,flags)
    end
end

cards_pills.use_pill = function(pill, player, flags, color) --color is RGON specific
    local fx = cards_pills.pill_actions[pill]

    if fx ~= nil then 
        -- if GODMODE.validate_rgon() then 
            -- fx(pill, player, flags, color & PillColor.PILL_GIANT_FLAG > 0)
        -- else
            local col = tonumber(GODMODE.save_manager.get_player_data(player,"LastPillCol","0"))
            fx(pill, player, flags, col > 0 and col & PillColor.PILL_GIANT_FLAG > 0)
        -- end
    end

    local sugar_uses = tonumber(GODMODE.save_manager.get_player_data(player,"SugarPillRolls","0"))

    if sugar_uses > 0 then 
        local sel_item = GODMODE.itempools.get_from_pool("sugar_pill",player:GetDropRNG(),false,false)
        local config = Isaac.GetItemConfig():GetCollectible(sel_item)
        
        player:GetEffects():AddCollectibleEffect(sel_item,true,1)
        player:AddCacheFlags(config.CacheFlags)
        player:EvaluateItems()

        GODMODE.save_manager.add_list_data("TempRoomColls", player.InitSeed..","..sel_item)
        local red_perc = player:GetHearts() / (player:GetMaxHearts() + player:GetBoneHearts() * 2)

        if red_perc < 1 then player:AddHearts(1) else player:AddSoulHearts(1) end
        GODMODE.save_manager.set_player_data(player, "SugarPillRolls", math.max(sugar_uses - 1,0), true)
        GODMODE.log("added \'"..config.Name.."\' due to Sugar Pills!", true)
    end
end

return cards_pills