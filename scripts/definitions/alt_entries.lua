return {
    entries = {
        {
            type=EntityType.ENTITY_HORF, 
            variant=0, 
            rep_type=GODMODE.registry.entities.harf.type, 
            rep_variant=GODMODE.registry.entities.harf.variant, 
            rep_subtype=0,
            rep_chance={0.1,0.2,0.1,0.15}
        },
        {
            type=EntityType.ENTITY_SUB_HORF, 
            variant=0, 
            rep_type=GODMODE.registry.entities.harf.type, 
            rep_variant=GODMODE.registry.entities.harf.variant, 
            rep_subtype=0,
            rep_chance={0.1,0.2,0.1,0.15}
        },
        {
            type=EntityType.ENTITY_NERVE_ENDING, 
            variant=0, 
            rep_type=GODMODE.registry.entities.nerve_cluster.type, 
            rep_variant=GODMODE.registry.entities.nerve_cluster.variant, 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 4,
            thin_rooms = false,
            needs_surrounding_space = true,
        },
        {
            type=EntityType.ENTITY_ATTACKFLY, 
            variant=0, 
            rep_type=GODMODE.registry.entities.cluster.type, 
            rep_variant=GODMODE.registry.entities.cluster.variant, 
            rep_subtype=0,
            rep_chance={0.0125,0.025,0.0125,0.025},
            max_in_room = 1,
        },
        {
            type=EntityType.ENTITY_POOTER, 
            variant=0, 
            rep_type=GODMODE.registry.entities.grubby.type, 
            rep_variant=GODMODE.registry.entities.grubby.variant, 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.025,0.05},
            max_in_room = 2,
        },
        {
            type=EntityType.ENTITY_POOTER, 
            variant=1, 
            rep_type=GODMODE.registry.entities.grubby.type, 
            rep_variant=GODMODE.registry.entities.grubby.variant, 
            rep_subtype=0,
            rep_chance={0.1,0.125,0.05,0.075},
            max_in_room = 2,
        },
        -- {
        --     type=EntityType.ENTITY_MASK, 
        --     variant=0, 
        --     rep_type=GODMODE.registry.entities.purple_heart.type, 
        --     rep_variant=GODMODE.registry.entities.purple_heart.variant, 
        --     rep_subtype=0,
        --     rep_chance={0.05,0.1,0.05,0.1},
        --     max_in_room = 4,
        -- },
        {
            type=EntityType.ENTITY_PARA_BITE, 
            variant=0, 
            rep_type=GODMODE.registry.entities.paracolony.type, 
            rep_variant=GODMODE.registry.entities.paracolony.variant, 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 1,
        },
        {
            type=EntityType.ENTITY_PARA_BITE, 
            variant=0, 
            rep_type=GODMODE.registry.entities.parabit.type, 
            rep_variant=GODMODE.registry.entities.parabit.variant, 
            rep_subtype=700,
            rep_chance={0.1,0.05,0.1,0.05},
            max_in_room = 4,
        },
        {
            type=EntityType.ENTITY_BABY, 
            variant=0, 
            rep_type=GODMODE.registry.entities.blood_baby.type, 
            rep_variant=GODMODE.registry.entities.blood_baby.variant, 
            rep_subtype=0,
            rep_chance={0.025,0.05,0.025,0.05},
            max_in_room = 2,
            needs_surrounding_space = true,
        },
        {
            type=EntityType.ENTITY_BABY, 
            variant=0, 
            rep_type=GODMODE.registry.entities.blood_baby.type, 
            rep_variant=GODMODE.registry.entities.blood_baby.variant, 
            rep_subtype=0,
            rep_chance={0.1,0.25,0.1,0.25},
            max_in_room = 4,
            needs_surrounding_space = true,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng)
                local stage = GODMODE.level:GetStage()
                if stage == LevelStage.STAGE4_1 or stage == LevelStage.STAGE4_2 then --womb only
                    return rng:RandomFloat() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_BABY, 
            variant=1, 
            rep_type=GODMODE.registry.entities.fallen_angelic_baby.type, 
            rep_variant=GODMODE.registry.entities.fallen_angelic_baby.variant, 
            rep_subtype=0,
            rep_chance={0.025,0.05,0.025,0.05},
            max_in_room = 1,
            needs_surrounding_space = true,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng)
                local stage = GODMODE.level:GetStage()
                if stage >= LevelStage.STAGE4_2 then --caves onward
                    return rng:RandomFloat() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_HOST, 
            variant=0, 
            rep_type=GODMODE.registry.entities.spiked_host.type, 
            rep_variant=GODMODE.registry.entities.spiked_host.variant, 
            rep_subtype=0,
            rep_chance={0.025,0.05,0.025,0.05},
            max_in_room = 1,
            needs_surrounding_space = true,
        },
        {
            type=EntityType.ENTITY_HOST, 
            variant=1, 
            rep_type=GODMODE.registry.entities.spiked_flesh_host.type, 
            rep_variant=GODMODE.registry.entities.spiked_flesh_host.variant, 
            rep_subtype=0,
            rep_chance={0.025,0.05,0.025,0.05},
            max_in_room = 1,
            needs_surrounding_space = true,
        },
        {
            type=EntityType.ENTITY_MULLIGAN, 
            variant=0, 
            rep_type=GODMODE.registry.entities.hover.type, 
            rep_variant=GODMODE.registry.entities.hover.variant, 
            rep_subtype=0,
            rep_chance={0.0125,0.025,0.0125,0.025},
            max_in_room = 1,
            thin_rooms = false,
            needs_surrounding_space = true,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng)
                local stage = GODMODE.level:GetStage()
                if stage >= LevelStage.STAGE2_1 then --caves onward
                    return rng:RandomFloat() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_HIVE, 
            variant=0, 
            rep_type=GODMODE.registry.entities.hover.type, 
            rep_variant=GODMODE.registry.entities.hover.variant, 
            rep_subtype=0,
            rep_chance={0.05,0.075,0.05,0.075},
            max_in_room = 1,
            thin_rooms = false,
            needs_surrounding_space = true,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng)
                local stage = GODMODE.level:GetStage()
                if stage >= LevelStage.STAGE2_1 then --caves onward
                    return rng:RandomFloat() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_FULL_FLY, 
            variant=0, 
            rep_type=GODMODE.registry.entities.barfer.type, 
            rep_variant=GODMODE.registry.entities.barfer.variant, 
            rep_subtype=0,
            rep_chance={0.125,0.15,0.125,0.15},
            max_in_room = 3,
        },
        {
            type=EntityType.ENTITY_FLY_L2, 
            variant=0, 
            rep_type=GODMODE.registry.entities.barfer.type, 
            rep_variant=GODMODE.registry.entities.barfer.variant, 
            rep_subtype=0,
            rep_chance={0.1,0.125,0.1,0.125},
            max_in_room = 2,
        },
        {
            type=EntityType.ENTITY_GAPER, 
            variant=0, 
            rep_type=GODMODE.registry.entities.mum.type, 
            rep_variant=GODMODE.registry.entities.mum.variant, 
            rep_subtype=0,
            rep_chance={0.35,0.5,0.35,0.5},
            max_in_room = 5,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng)
                local stage = GODMODE.level:GetStage()
                if stage >= LevelStage.STAGE5 and stage <= LevelStage.STAGE6 and GODMODE.level:IsAltStage() == false then --sheol+dark room
                    return rng:RandomFloat() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_HOPPER, 
            variant=0, 
            rep_type=GODMODE.registry.entities.drifter.type, 
            rep_variant=GODMODE.registry.entities.drifter.variant, 
            rep_subtype=700,
            rep_chance={0.35,0.5,0.35,0.5},
            max_in_room = 5,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng)
                local stage = GODMODE.level:GetStage()
                if stage >= LevelStage.STAGE5 and stage <= LevelStage.STAGE6 and GODMODE.level:IsAltStage() == true then --cathedral+chest
                    return rng:RandomFloat() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_HOPPER, 
            variant=1, 
            rep_type=GODMODE.registry.entities.electrite.type, 
            rep_variant=GODMODE.registry.entities.electrite.variant, 
            rep_subtype=0,
            rep_chance={0.35,0.5,0.35,0.5},
            max_in_room = 2,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng)
                local stage = GODMODE.level:GetStage()
                if stage >= LevelStage.STAGE3_1 then --depths + onwards
                    return rng:RandomFloat() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_CRAZY_LONG_LEGS, 
            variant=0, 
            rep_type=GODMODE.registry.entities.godleg.type, 
            rep_variant=GODMODE.registry.entities.godleg.variant, 
            rep_subtype=0,
            rep_chance={0.05,0.125,0.05,0.125},
            max_in_room = 1,
            thin_rooms = false,
            needs_surrounding_space = true,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng)
                local stage = GODMODE.level:GetStage()
                if stage >= LevelStage.STAGE2_1 then --caves onward
                    return rng:RandomFloat() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_BABY_LONG_LEGS, 
            variant=0, 
            rep_type=GODMODE.registry.entities.planter.type, 
            rep_variant=GODMODE.registry.entities.planter.variant, 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 1,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng)
                local stage = GODMODE.level:GetStage()
                if stage >= LevelStage.STAGE2_1 then --caves onward
                    return rng:RandomFloat() < chance
                else
                    return false
                end
            end
        },
        {
            type=EntityType.ENTITY_POOTER, 
            variant=0, 
            rep_type=GODMODE.registry.entities.queen_fly.type, 
            rep_variant=GODMODE.registry.entities.queen_fly.variant, 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 2,
            thin_rooms = false,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng)
                local stage = GODMODE.level:GetStage()
                if stage >= LevelStage.STAGE3_1 then --depths onward
                    return rng:RandomFloat() < chance
                else
                    return rng:RandomFloat() < chance * 0.1
                end
            end
        },
        {
            type=EntityType.ENTITY_POOTER, 
            variant=1, 
            rep_type=GODMODE.registry.entities.queen_fly.type, 
            rep_variant=GODMODE.registry.entities.queen_fly.variant, 
            rep_subtype=0,
            rep_chance={0.2,0.25,0.2,0.25},
            max_in_room = 2,
            thin_rooms = false,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng)
                local stage = GODMODE.level:GetStage()
                if stage >= LevelStage.STAGE3_1 then --depths onward
                    return rng:RandomFloat() < chance
                else
                    return rng:RandomFloat() < chance * 0.25
                end
            end
        },
        {
            type=EntityType.ENTITY_MORNINGSTAR, 
            variant=0, 
            rep_type=GODMODE.registry.entities.hexstar.type, 
            rep_variant=GODMODE.registry.entities.hexstar.variant, 
            rep_subtype=0,
            rep_chance={0.25,0.125,0.25,0.125},
            max_in_room = 2,
        },
        {
            type=EntityType.ENTITY_BEGOTTEN, 
            variant=0, 
            rep_type=GODMODE.registry.entities.the_id.type, 
            rep_variant=GODMODE.registry.entities.the_id.variant, 
            rep_subtype=700,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 4,
        },
        {
            type=EntityType.ENTITY_MAW, 
            variant=1, 
            rep_type=GODMODE.registry.entities.ludomini.type, 
            rep_variant=GODMODE.registry.entities.ludomini.variant, 
            rep_subtype=0,
            rep_chance={0.05,0.075,0.025,0.05},
            max_in_room = 2,
            needs_surrounding_space = true,
        },
        {
            type=EntityType.ENTITY_MEMBRAIN, 
            variant=0, 
            rep_type=GODMODE.registry.entities.infested_membrain.type, 
            rep_variant=GODMODE.registry.entities.infested_membrain.variant, 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 2,
        },
        {
            type=EntityType.ENTITY_FATTY, 
            variant=0, 
            rep_type=GODMODE.registry.entities.wrinkled_fatty.type, 
            rep_variant=GODMODE.registry.entities.wrinkled_fatty.variant, 
            rep_subtype=0,
            rep_chance={0.05,0.1,0.05,0.1},
            max_in_room = 2,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng)
                local stage = GODMODE.level:GetStage()
                if stage == LevelStage.STAGE5 and GODMODE.level:GetStageType() == StageType.STAGETYPE_ORIGINAL then --womb only
                    return rng:RandomFloat() < chance
                else
                    return false
                end
            end
        },

        {
            type=EntityType.ENTITY_ONE_TOOTH, 
            variant=0, 
            rep_type=GODMODE.registry.entities.bathemo_devote.type, 
            rep_variant=GODMODE.registry.entities.bathemo_devote.variant, 
            rep_subtype=1,
            rep_chance={0.025,0.05,0.025,0.05},
            max_in_room = 1,
            thin_rooms = false,
            needs_surrounding_space = true,
            rep_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng)
                local stage = GODMODE.level:GetStage()
                if stage >= LevelStage.STAGE2_1 then --caves onward
                    return rng:RandomFloat() < chance
                else
                    return rng:RandomFloat() < chance * 0.25
                end
            end
        },


        --RED COIN!
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_COIN,
            subtype=CoinSubType.COIN_PENNY, --penny 
            rep_type=GODMODE.registry.entities.red_coin.type, 
            rep_variant=GODMODE.registry.entities.red_coin.variant, 
            rep_subtype=0,
            rep_chance={0.01},
            max_in_room = 1
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_COIN,
            subtype=CoinSubType.COIN_NICKEL, --nickel 
            rep_type=GODMODE.registry.entities.red_coin.type, 
            rep_variant=GODMODE.registry.entities.red_coin.variant, 
            rep_subtype=0,
            rep_chance={0.03},
            max_in_room = 1
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_COIN,
            subtype=CoinSubType.COIN_DIME, --dime 
            rep_type=GODMODE.registry.entities.red_coin.type, 
            rep_variant=GODMODE.registry.entities.red_coin.variant, 
            rep_subtype=0,
            rep_chance={0.05},
            max_in_room = 1
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_COIN,
            subtype=CoinSubType.COIN_DOUBLEPACK, --double penny 
            rep_type=GODMODE.registry.entities.red_coin.type, 
            rep_variant=GODMODE.registry.entities.red_coin.variant, 
            rep_subtype=0,
            rep_chance={0.02},
            max_in_room = 1
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_COIN,
            subtype=CoinSubType.COIN_STICKYNICKEL, --sticky nickel 
            rep_type=GODMODE.registry.entities.red_coin.type, 
            rep_variant=GODMODE.registry.entities.red_coin.variant, 
            rep_subtype=0,
            rep_chance={0.025},
            max_in_room = 1
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_HEART,
            subtype=HeartSubType.HEART_FULL, --full heart
            rep_type=GODMODE.registry.entities.fruit.type, 
            rep_variant=GODMODE.registry.entities.fruit.variant, 
            rep_subtype=0,
            rep_chance={0.05},
            max_in_room = 2
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_HEART,
            subtype=HeartSubType.HEART_HALF, --half heart
            rep_type=GODMODE.registry.entities.fruit.type, 
            rep_variant=GODMODE.registry.entities.fruit.variant, 
            rep_subtype=0,
            rep_chance={0.025},
            max_in_room = 2
        },
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_HEART,
            subtype=HeartSubType.HEART_DOUBLEPACK, --double heart
            rep_type=GODMODE.registry.entities.fruit.type, 
            rep_variant=GODMODE.registry.entities.fruit.variant, 
            rep_subtype=0,
            rep_chance={0.1},
            max_in_room = 2
        },

        --MIMIC CHEST!
        {
            type=EntityType.ENTITY_PICKUP, 
            variant=PickupVariant.PICKUP_MEGACHEST,
            rep_type=GODMODE.registry.entities.mimic_worm.type, 
            rep_variant=GODMODE.registry.entities.mimic_worm.variant, 
            rep_subtype=0,
            rep_chance={0.05,0.125,0.05,0.125},
            max_in_room = 4
        },

        --PILL BEGGAR!
        {
            type=EntityType.ENTITY_SLOT, 
            variant=4, --replace regular beggar
            rep_type=GODMODE.registry.entities.pill_beggar.type, 
            rep_variant=GODMODE.registry.entities.pill_beggar.variant, 
            rep_subtype=0,
            rep_chance={0.15},
        },
        -- FRUIT BEGGAR!
        {
            type=EntityType.ENTITY_SLOT, 
            variant=4, --replace regular beggar
            rep_type=GODMODE.registry.entities.fruit_beggar.type, 
            rep_variant=GODMODE.registry.entities.fruit_beggar.variant, 
            rep_subtype=0,
            rep_chance={0.15},
        },
    },

    default_chance_function = function(chance, type, variant, subtype, rep_type, rep_variant, rng) 
        return rng:RandomFloat() < chance
    end
}