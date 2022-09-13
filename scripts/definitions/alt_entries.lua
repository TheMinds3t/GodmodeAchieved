return {
    entries = {
        {
            type=EntityType.ENTITY_HORF, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Harf"), 
            rep_variant=Isaac.GetEntityVariantByName("Harf"), 
            rep_subtype=0,
            rep_chance={0.1,0.2,0.1,0.15}
        },
        {
            type=EntityType.ENTITY_SUB_HORF, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Harf"), 
            rep_variant=Isaac.GetEntityVariantByName("Harf"), 
            rep_subtype=0,
            rep_chance={0.1,0.2,0.1,0.15}
        },
        {
            type=EntityType.ENTITY_NERVE_ENDING, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Nerve Cluster"), 
            rep_variant=Isaac.GetEntityVariantByName("Nerve Cluster"), 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 4,
        },
        {
            type=EntityType.ENTITY_ATTACKFLY, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Cluster"), 
            rep_variant=Isaac.GetEntityVariantByName("Cluster"), 
            rep_subtype=0,
            rep_chance={0.0125,0.025,0.0125,0.025},
            max_in_room = 1,
        },
        {
            type=EntityType.ENTITY_POOTER, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Grubby"), 
            rep_variant=Isaac.GetEntityVariantByName("Grubby"), 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.025,0.05},
            max_in_room = 2,
        },
        {
            type=EntityType.ENTITY_POOTER, 
            variant=1, 
            rep_type=Isaac.GetEntityTypeByName("Grubby"), 
            rep_variant=Isaac.GetEntityVariantByName("Grubby"), 
            rep_subtype=0,
            rep_chance={0.1,0.125,0.05,0.075},
            max_in_room = 2,
        },
        -- {
        --     type=EntityType.ENTITY_MASK, 
        --     variant=0, 
        --     rep_type=Isaac.GetEntityTypeByName("Purple Heart"), 
        --     rep_variant=Isaac.GetEntityVariantByName("Purple Heart"), 
        --     rep_subtype=0,
        --     rep_chance={0.05,0.1,0.05,0.1},
        --     max_in_room = 4,
        -- },
        {
            type=EntityType.ENTITY_PARA_BITE, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Paracolony"), 
            rep_variant=Isaac.GetEntityVariantByName("Paracolony"), 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 1,
        },
        {
            type=EntityType.ENTITY_PARA_BITE, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Para-Bit"), 
            rep_variant=Isaac.GetEntityVariantByName("Para-Bit"), 
            rep_subtype=700,
            rep_chance={0.1,0.05,0.1,0.05},
            max_in_room = 4,
        },
        {
            type=EntityType.ENTITY_BABY, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Blood Baby"), 
            rep_variant=Isaac.GetEntityVariantByName("Blood Baby"), 
            rep_subtype=0,
            rep_chance={0.025,0.05,0.025,0.05},
            max_in_room = 2,
        },
        {
            type=EntityType.ENTITY_BABY, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Blood Baby"), 
            rep_variant=Isaac.GetEntityVariantByName("Blood Baby"), 
            rep_subtype=0,
            rep_chance={0.1,0.25,0.1,0.25},
            max_in_room = 4,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant)
                local stage = Game():GetLevel():GetStage()
                if stage == LevelStage.STAGE4_1 or stage == LevelStage.STAGE4_2 then --womb only
                    return GODMODE.util.random() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_BABY, 
            variant=1, 
            rep_type=Isaac.GetEntityTypeByName("Fallen Angelic Baby"), 
            rep_variant=Isaac.GetEntityVariantByName("Fallen Angelic Baby"), 
            rep_subtype=0,
            rep_chance={0.025,0.05,0.025,0.05},
            max_in_room = 1,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant)
                local stage = Game():GetLevel():GetStage()
                if stage >= LevelStage.STAGE4_2 then --caves onward
                    return GODMODE.util.random() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_HOST, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Spiked Host"), 
            rep_variant=Isaac.GetEntityVariantByName("Spiked Host"), 
            rep_subtype=0,
            rep_chance={0.025,0.05,0.025,0.05},
            max_in_room = 1,
        },
        {
            type=EntityType.ENTITY_HOST, 
            variant=1, 
            rep_type=Isaac.GetEntityTypeByName("Spiked Flesh Host"), 
            rep_variant=Isaac.GetEntityVariantByName("Spiked Flesh Host"), 
            rep_subtype=0,
            rep_chance={0.025,0.05,0.025,0.05},
            max_in_room = 1,
        },
        {
            type=EntityType.ENTITY_MULLIGAN, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Hover"), 
            rep_variant=Isaac.GetEntityVariantByName("Hover"), 
            rep_subtype=0,
            rep_chance={0.0125,0.025,0.0125,0.025},
            max_in_room = 1,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant)
                local stage = Game():GetLevel():GetStage()
                if stage >= LevelStage.STAGE2_1 then --caves onward
                    return GODMODE.util.random() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_HIVE, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Hover"), 
            rep_variant=Isaac.GetEntityVariantByName("Hover"), 
            rep_subtype=0,
            rep_chance={0.05,0.075,0.05,0.075},
            max_in_room = 1,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant)
                local stage = Game():GetLevel():GetStage()
                if stage >= LevelStage.STAGE2_1 then --caves onward
                    return GODMODE.util.random() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_FULL_FLY, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Barfer"), 
            rep_variant=Isaac.GetEntityVariantByName("Barfer"), 
            rep_subtype=0,
            rep_chance={0.125,0.15,0.125,0.15},
            max_in_room = 3,
        },
        {
            type=EntityType.ENTITY_FLY_L2, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Barfer"), 
            rep_variant=Isaac.GetEntityVariantByName("Barfer"), 
            rep_subtype=0,
            rep_chance={0.1,0.125,0.1,0.125},
            max_in_room = 2,
        },
        {
            type=EntityType.ENTITY_GAPER, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Mum"), 
            rep_variant=Isaac.GetEntityVariantByName("Mum"), 
            rep_subtype=250,
            rep_chance={0.35,0.5,0.35,0.5},
            max_in_room = 5,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant)
                local stage = Game():GetLevel():GetStage()
                if stage >= LevelStage.STAGE5 and stage <= LevelStage.STAGE6 and Game():GetLevel():IsAltStage() == false then --sheol+dark room
                    return GODMODE.util.random() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_HOPPER, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Drifter"), 
            rep_variant=Isaac.GetEntityVariantByName("Drifter"), 
            rep_subtype=700,
            rep_chance={0.35,0.5,0.35,0.5},
            max_in_room = 5,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant)
                local stage = Game():GetLevel():GetStage()
                if stage >= LevelStage.STAGE5 and stage <= LevelStage.STAGE6 and Game():GetLevel():IsAltStage() == true then --cathedral+chest
                    return GODMODE.util.random() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_CRAZY_LONG_LEGS, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Godleg"), 
            rep_variant=Isaac.GetEntityVariantByName("Godleg"), 
            rep_subtype=0,
            rep_chance={0.05,0.125,0.05,0.125},
            max_in_room = 1,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant)
                local stage = Game():GetLevel():GetStage()
                if stage >= LevelStage.STAGE2_1 then --caves onward
                    return GODMODE.util.random() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_BABY_LONG_LEGS, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Planter"), 
            rep_variant=Isaac.GetEntityVariantByName("Planter"), 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 1,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant)
                local stage = Game():GetLevel():GetStage()
                if stage >= LevelStage.STAGE2_1 then --caves onward
                    return GODMODE.util.random() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_POOTER, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Queen Fly"), 
            rep_variant=Isaac.GetEntityVariantByName("Queen Fly"), 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 2,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant)
                local stage = Game():GetLevel():GetStage()
                if stage >= LevelStage.STAGE3_1 then --depths onward
                    return GODMODE.util.random() < chance
                else
                    return GODMODE.util.random() < chance * 0.1
                end
            end
        },
        {
            type=EntityType.ENTITY_POOTER, 
            variant=1, 
            rep_type=Isaac.GetEntityTypeByName("Queen Fly"), 
            rep_variant=Isaac.GetEntityVariantByName("Queen Fly"), 
            rep_subtype=0,
            rep_chance={0.2,0.25,0.2,0.25},
            max_in_room = 2,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant)
                local stage = Game():GetLevel():GetStage()
                if stage >= LevelStage.STAGE3_1 then --depths onward
                    return GODMODE.util.random() < chance
                else
                    return GODMODE.util.random() < chance * 0.25
                end
            end
        },
        {
            type=EntityType.ENTITY_MORNINGSTAR, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Hexstar"), 
            rep_variant=Isaac.GetEntityVariantByName("Hexstar"), 
            rep_subtype=0,
            rep_chance={0.25,0.125,0.25,0.125},
            max_in_room = 2,
        },
        {
            type=EntityType.ENTITY_BEGOTTEN, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("The Id"), 
            rep_variant=Isaac.GetEntityVariantByName("The Id"), 
            rep_subtype=700,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 4,
        },
        {
            type=EntityType.ENTITY_MAW, 
            variant=1, 
            rep_type=Isaac.GetEntityTypeByName("Ludomini"), 
            rep_variant=Isaac.GetEntityVariantByName("Ludomini"), 
            rep_subtype=0,
            rep_chance={0.05,0.075,0.025,0.05},
            max_in_room = 2,
        },
        {
            type=EntityType.ENTITY_MEMBRAIN, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Infested MemBrain"), 
            rep_variant=Isaac.GetEntityVariantByName("Infested MemBrain"), 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 2,
        },
        {
            type=EntityType.ENTITY_FATTY, 
            variant=0, 
            rep_type=Isaac.GetEntityTypeByName("Wrinkly Fatty"), 
            rep_variant=Isaac.GetEntityVariantByName("Wrinkly Fatty"), 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 2,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant)
                local stage = Game():GetLevel():GetStage()
                if stage == LevelStage.STAGE5 and Game():GetLevel():GetStageType() == StageType.STAGETYPE_ORIGINAL then --womb only
                    return GODMODE.util.random() < chance
                else
                    return false
                end
            end
        },

        --RED COIN!
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_COIN,
            subtype=1, --penny 
            rep_type=Isaac.GetEntityTypeByName("Red Coin"), 
            rep_variant=Isaac.GetEntityVariantByName("Red Coin"), 
            rep_subtype=0,
            rep_chance={0.01},
            max_in_room = 1
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_COIN,
            subtype=2, --nickel 
            rep_type=Isaac.GetEntityTypeByName("Red Coin"), 
            rep_variant=Isaac.GetEntityVariantByName("Red Coin"), 
            rep_subtype=0,
            rep_chance={0.03},
            max_in_room = 1
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_COIN,
            subtype=3, --dime 
            rep_type=Isaac.GetEntityTypeByName("Red Coin"), 
            rep_variant=Isaac.GetEntityVariantByName("Red Coin"), 
            rep_subtype=0,
            rep_chance={0.05},
            max_in_room = 1
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_COIN,
            subtype=1, --double penny 
            rep_type=Isaac.GetEntityTypeByName("Red Coin"), 
            rep_variant=Isaac.GetEntityVariantByName("Red Coin"), 
            rep_subtype=0,
            rep_chance={0.02},
            max_in_room = 1
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_COIN,
            subtype=6, --sticky nickel 
            rep_type=Isaac.GetEntityTypeByName("Red Coin"), 
            rep_variant=Isaac.GetEntityVariantByName("Red Coin"), 
            rep_subtype=0,
            rep_chance={0.025},
            max_in_room = 1
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_HEART,
            subtype=1, --full heart
            rep_type=Isaac.GetEntityTypeByName("Fruit (Pickup)"), 
            rep_variant=Isaac.GetEntityVariantByName("Fruit (Pickup)"), 
            rep_subtype=0,
            rep_chance={0.05},
            max_in_room = 2
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_HEART,
            subtype=2, --half heart
            rep_type=Isaac.GetEntityTypeByName("Fruit (Pickup)"), 
            rep_variant=Isaac.GetEntityVariantByName("Fruit (Pickup)"), 
            rep_subtype=0,
            rep_chance={0.025},
            max_in_room = 2
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_HEART,
            subtype=5, --double heart
            rep_type=Isaac.GetEntityTypeByName("Fruit (Pickup)"), 
            rep_variant=Isaac.GetEntityVariantByName("Fruit (Pickup)"), 
            rep_subtype=0,
            rep_chance={0.1},
            max_in_room = 2
        },

        --MIMIC CHEST!
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_MEGACHEST,
            rep_type=Isaac.GetEntityTypeByName("Mimic Worm"), 
            rep_variant=Isaac.GetEntityVariantByName("Mimic Worm"), 
            rep_subtype=0,
            rep_chance={0.05,0.125,0.05,0.125},
            max_in_room = 4
        },
    },

    default_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant) 
        return GODMODE.util.random() < chance
    end
}