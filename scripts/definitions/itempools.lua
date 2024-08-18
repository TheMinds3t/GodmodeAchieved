local pools = {}

pools.pool_list = {
    ["observatory"] = { --trinket pool
        GODMODE.registry.trinkets.cursed_pendant,
        GODMODE.registry.trinkets.shattered_moonrock,
        GODMODE.registry.trinkets.cracked_nazar,
        GODMODE.registry.trinkets.white_candle,
    },
    ["observatory_items"] = { --item pool
        GODMODE.registry.items.foreign_treatment,
        GODMODE.registry.items.odd_dice,
    },
    ["observatory_tarots"] = {
        Card.CARD_REVERSE_FOOL,
        Card.CARD_REVERSE_MAGICIAN,
        Card.CARD_REVERSE_HIGH_PRIESTESS,
        Card.CARD_REVERSE_EMPRESS,
        Card.CARD_REVERSE_EMPEROR,
        Card.CARD_REVERSE_HIEROPHANT,
        Card.CARD_REVERSE_LOVERS,
        Card.CARD_REVERSE_CHARIOT,
        Card.CARD_REVERSE_JUSTICE,
        Card.CARD_REVERSE_HERMIT,
        Card.CARD_REVERSE_WHEEL_OF_FORTUNE,
        Card.CARD_REVERSE_STRENGTH,
        Card.CARD_REVERSE_HANGED_MAN,
        Card.CARD_REVERSE_DEATH,
        Card.CARD_REVERSE_TEMPERANCE,
        Card.CARD_REVERSE_DEVIL,
        Card.CARD_REVERSE_TOWER,
        Card.CARD_REVERSE_STARS,
        Card.CARD_REVERSE_MOON,
        Card.CARD_REVERSE_SUN,
        Card.CARD_REVERSE_JUDGEMENT,
        Card.CARD_REVERSE_WORLD,
    },
    ["observatory_souls"] = {
        Card.RUNE_HAGALAZ,
        Card.RUNE_JERA,
        Card.RUNE_EHWAZ,
        Card.RUNE_DAGAZ,
        Card.RUNE_ANSUZ,
        Card.RUNE_PERTHRO,
        Card.RUNE_BERKANO,
        Card.RUNE_ALGIZ,

        Card.CARD_SOUL_ISAAC,
        Card.CARD_SOUL_MAGDALENE,
        Card.CARD_SOUL_CAIN,
        Card.CARD_SOUL_JUDAS,
        Card.CARD_SOUL_BLUEBABY,
        Card.CARD_SOUL_EVE,
        Card.CARD_SOUL_SAMSON,
        Card.CARD_SOUL_AZAZEL,
        Card.CARD_SOUL_LAZARUS,
        Card.CARD_SOUL_EDEN,
        Card.CARD_SOUL_LOST,
        Card.CARD_SOUL_LILITH,
        Card.CARD_SOUL_KEEPER,
        Card.CARD_SOUL_APOLLYON,
        Card.CARD_SOUL_FORGOTTEN,
        Card.CARD_SOUL_BETHANY,
        Card.CARD_SOUL_JACOB,
    },
    ["pill_beggar"] = {
        CollectibleType.COLLECTIBLE_PLACEBO,
        CollectibleType.COLLECTIBLE_PLAN_C,
        CollectibleType.COLLECTIBLE_PHD,
        CollectibleType.COLLECTIBLE_FALSE_PHD,
        CollectibleType.COLLECTIBLE_WAVY_CAP,
        CollectibleType.COLLECTIBLE_MOMS_BOTTLE_OF_PILLS,
        CollectibleType.COLLECTIBLE_LIL_SPEWER,
        CollectibleType.COLLECTIBLE_MOMS_COIN_PURSE,
        CollectibleType.COLLECTIBLE_LITTLE_BAGGY,
        CollectibleType.COLLECTIBLE_ACID_BABY,
        CollectibleType.COLLECTIBLE_FORGET_ME_NOW,
        CollectibleType.COLLECTIBLE_KIDNEY_STONE,
        GODMODE.registry.items.sharing_is_caring,
    },
    ["fruit_beggar"] = {
        CollectibleType.COLLECTIBLE_ROTTEN_TOMATO,
        CollectibleType.COLLECTIBLE_CANDY_HEART,
        CollectibleType.COLLECTIBLE_YUM_HEART,
        CollectibleType.COLLECTIBLE_FRUIT_CAKE,
        CollectibleType.COLLECTIBLE_APPLE,
        CollectibleType.COLLECTIBLE_GHOST_PEPPER,
        CollectibleType.COLLECTIBLE_BIRDS_EYE,
        CollectibleType.COLLECTIBLE_COMPOST,
        GODMODE.registry.items.dragon_fruit,
        GODMODE.registry.items.fruit_salad,
        GODMODE.registry.items.fruit_flies,
        GODMODE.registry.items.the_carrot,
    },
    ["sugar_pill"] = {
        CollectibleType.COLLECTIBLE_ROID_RAGE,
        CollectibleType.COLLECTIBLE_SPEED_BALL,
        CollectibleType.COLLECTIBLE_EXPERIMENTAL_TREATMENT,
        CollectibleType.COLLECTIBLE_EUTHANASIA,
        CollectibleType.COLLECTIBLE_BRIMSTONE,
        CollectibleType.COLLECTIBLE_MONTEZUMAS_REVENGE,
        CollectibleType.COLLECTIBLE_AQUARIUS,
        GODMODE.registry.items.uncommon_cough,
        GODMODE.registry.items.morphine,
        GODMODE.registry.items.sugar,
    }
}

pools.inverse_search = {}

for pool_id,pool in pairs(pools.pool_list) do 
    pools.inverse_search[pool_id] = {}

    for _,item in ipairs(pool) do 
        pools.inverse_search[pool_id][item] = true
    end
end

pools.get_from_pool = function(pool_id,rng,ignore_unlocks,decrease_pool)
    if GODMODE.validate_rgon() then --repentogon new itempool support!
        local rep_pool = GODMODE.registry.itempools[pool_id]

        if rep_pool ~= nil and rep_pool ~= -1 then 
            local itempool = GODMODE.game:GetItemPool() 
            return itempool:GetCollectibleFromList(
                GODMODE.util.for_each(itempool:GetCollectiblesFromPool(rep_pool), function(key,val) return val.itemID end), 
                Random(), CollectibleType.COLLECTIBLE_BREAKFAST, decrease_pool or false, ignore_unlocks or false)
        end
    end

    -- if the new itempool doesn't line up then do it with the custom itempool system
    local list = pools.pool_list[pool_id] or {} 

    if #list > 0 then 
        local sel = nil
        local depth = #list * 3

        while depth > 0 and 
            (sel == nil 
            or sel ~= nil and not GODMODE.achievements.is_item_unlocked(sel,ignore_unlocks or false)
            or sel ~= nil and GODMODE.save_manager.list_contains("Itempool"..pool_id,nil,function(ele) return ele == ""..sel end)) do 

            sel = list[rng:RandomInt(#list)+1]
            depth = depth - 1
        end

        if (decrease_pool or true) == true then 
            GODMODE.save_manager.add_list_data("Itempool"..pool_id,sel,true)
        end

        return sel
    else
        GODMODE.log("Pool \'"..pool_id.."\' is not registered or is empty",true) 
        return CollectibleType.COLLECTIBLE_BREAKFAST
    end
end

pools.get_pool = function(pool_id)
    return pools.pool_list[pool_id] or {}
end

pools.is_in_pool = function(pool_id,item)
    local list = pools.inverse_search[pool_id] or {}

    return list[item] == true
end

return pools