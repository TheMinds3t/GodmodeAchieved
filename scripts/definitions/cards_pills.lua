local cards_pills = {}
cards_pills.cards = {
    torn_page = Isaac.GetCardIdByName("Torn Page"),
    pok_8 = Isaac.GetCardIdByName("Key Cluster (8)"),
    pok_7 = Isaac.GetCardIdByName("Key Cluster (7)"),
    pok_6 = Isaac.GetCardIdByName("Key Cluster (6)"),
    pok_5 = Isaac.GetCardIdByName("Key Cluster (5)"),
    pok_4 = Isaac.GetCardIdByName("Key Cluster (4)"),
    pok_3 = Isaac.GetCardIdByName("Key Cluster (3)"),
    pok_2 = Isaac.GetCardIdByName("Key Cluster (2)"),
    soc = Isaac.GetCardIdByName("Stream of Consciousness"),
}
cards_pills.pills = {
    
}

cards_pills.is_red_key = function(subtype)
    return subtype >= cards_pills.cards.pok_8 and subtype <= cards_pills.cards.pok_2 or subtype == Card.CARD_CRACKED_KEY
end

cards_pills.get_red_key_count = function(player)
    local skip_page = 1 
    local count = 0 

    for _,card in pairs(cards_pills.cards) do 
        if card ~= cards_pills.cards.torn_page then 
            if player:GetCard(0) == card or player:GetCard(1) == card or player:GetCard(2) == card or player:GetCard(3) == card then 
                local off = math.abs(GODMODE.cards_pills.cards.pok_2 - card) + 2
                if card == Card.CARD_CRACKED_KEY then off = 1 end
                if card == cards_pills.cards.pok_8 then off = 8 end
                count = count + off 
            end
        end
    end

    return count
end

cards_pills.get_red_key_for_count = function(count)
    if count > 1 and count < 9 then
        return cards_pills.cards.pok_2 - (count - 2)
    elseif count == 1 then 
        return Card.CARD_CRACKED_KEY
    end
end

local pok_use_effect = function(card,player,flags) 
    local echo_chamber = player:HasCollectible(CollectibleType.COLLECTIBLE_ECHO_CHAMBER)

    if echo_chamber == true then 
        local data = GODMODE.get_ent_data(player)

        if (data.use_frame or -1) == Game():GetFrameCount() then 
            return
        elseif data.use_frame ~= nil then 
            data.use_frame = nil 
        end

        data.use_frame = Game():GetFrameCount()
    end

    local room = Game():GetRoom()
    local door_count = 0
    for doorslot=0,DoorSlot.NUM_DOOR_SLOTS do 
        if room:GetDoor(doorslot) ~= nil then door_count = door_count + 1 end
    end

    local old_active = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)
    local old_charge = player:GetActiveCharge(ActiveSlot.SLOT_PRIMARY)

    local schoolbag_flag = player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) ~= 0 and player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)
    or not player:HasCollectible(CollectibleType.COLLECTIBLE_SCHOOLBAG)

    player:AddCollectible(CollectibleType.COLLECTIBLE_RED_KEY, 4, false)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_RED_KEY, false, true, true, false)
    player:AnimateCard(Card.CARD_CRACKED_KEY)
    player:RemoveCollectible(CollectibleType.COLLECTIBLE_RED_KEY)

    if schoolbag_flag then
        player:AddCollectible(old_active,old_charge,false)
    end
    
    local doors = {}
    local door_count2 = 0
    local bluewomb_flag = Game():GetLevel():GetStage() == LevelStage.STAGE4_3 and GODMODE.save_manager.get_config("BlueWombRework","true","true") == "true"
    for doorslot=0,DoorSlot.NUM_DOOR_SLOTS do 
        local door = room:GetDoor(doorslot)
        if door ~= nil then 
            door_count2 = door_count2 + 1 
            -- table.insert(doors, room:GetDoor(doorslot))
            if door.TargetRoomIndex == GridRooms.ROOM_ERROR_IDX and bluewomb_flag then --blow up error rooms in blue womb rework
                door:TryBlowOpen(true,player)
            end
        end
    end

    -- local closest_door = nil
    -- for _,door in ipairs(doors) do 
    --     local pos = room:GetDoorSlotPosition(door.Slot)

    --     if closest_door == nil or (player.Position - pos):Length() < (player.Position - room:GetDoorSlotPosition(closest_door.Slot)):Length() then 
    --         closest_door = door
    --     end
    -- end

    -- Game():GetLevel():MakeRedRoomDoor(Game():GetLevel():GetCurrentRoomIndex(), closest_door.Slot)
    
    if door_count2 == door_count then 
        player:AddCard(card)

        if player:HasTrinket(TrinketType.TRINKET_ENDLESS_NAMELESS) then 
            GODMODE.get_ent_data(player).red_key_prevent_dupe = Game():GetFrameCount()
        end
    else
        if card < cards_pills.cards.pok_2 then 
            player:AddCard(card+1)
        else
            player:AddCard(Card.CARD_CRACKED_KEY)
        end
    end
end

cards_pills.card_actions = {
    [cards_pills.cards.torn_page] = {
        choice_params = {chance=0.0375,playing=true,runes=false,only_runes=false},
        use_effect = function(card,player,flags) 
            local book = GODMODE.special_items:get_book_item()

            if book ~= nil then 
                player:UseActiveItem(book, true, true, true, true)
            end
        end
    },
    [cards_pills.cards.soc] = {
        choice_params = {chance=0.0,playing=false,runes=false,only_runes=false},
        use_effect = function(card,player,flags) 
            local killed = false 
            GODMODE.util.macro_on_enemies(nil,Isaac.GetEntityTypeByName("Call of the Void"),Isaac.GetEntityVariantByName("Call of the Void"),nil,function(cotv)
                if cotv.SubType > 0 and killed == false then 
                    cotv.Velocity = cotv.Velocity * 0.25
                    GODMODE.get_ent_data(cotv).spent = true
                    cotv:GetSprite():Play("OrbKill",true)
                    killed = true
                end
            end)

            GODMODE.save_manager.set_player_data(player,"SOCPenalty",tonumber(GODMODE.save_manager.get_player_data(player,"SOCPenalty","0"))+1,true)
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()

            local count = tonumber(GODMODE.save_manager.get_data("VoidBHProj","0")) + tonumber(GODMODE.save_manager.get_data("VoidDMProj","0"))

            if count > 0 then 
                local rooms = Game():GetLevel():GetRooms()
                local chance = 0.01
                GODMODE.save_manager.set_data("SOCSpawnSeed","-1")
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
                end    
            end
        end
    },
    [cards_pills.cards.pok_8] = {
        choice_params = {chance=0.000000001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
    [cards_pills.cards.pok_7] = {
        choice_params = {chance=0.00000001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
    [cards_pills.cards.pok_6] = {
        choice_params = {chance=0.0000001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
    [cards_pills.cards.pok_5] = {
        choice_params = {chance=0.000001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
    [cards_pills.cards.pok_4] = {
        choice_params = {chance=0.00001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
    [cards_pills.cards.pok_3] = {
        choice_params = {chance=0.0001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
    [cards_pills.cards.pok_2] = {
        choice_params = {chance=0.001,playing=false,runes=false,only_runes=false},
        use_effect = pok_use_effect
    },
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

return cards_pills