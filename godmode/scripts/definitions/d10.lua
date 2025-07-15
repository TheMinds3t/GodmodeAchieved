local d10 = {}

d10.conversion_list = {
     [GODMODE.registry.entities.trailer.type..","..GODMODE.registry.entities.trailer.variant..",10"]
     = {die=true},
     [GODMODE.registry.entities.purple_heart.type..","..GODMODE.registry.entities.purple_heart.variant..",1"]
     = {die=true},
     [GODMODE.registry.entities.chanter.type..","..GODMODE.registry.entities.chanter.variant]
     = {type=GODMODE.registry.entities.marshall_pawn.type,variant=GODMODE.registry.entities.marshall_pawn.variant},
     [GODMODE.registry.entities.pooglobin.type..","..GODMODE.registry.entities.pooglobin.variant]
     = {grid=true,type=GridEntityType.GRID_POOP},
     [GODMODE.registry.entities.parabit.type..","..GODMODE.registry.entities.parabit.variant..",700"]
     = {die=true},
     [GODMODE.registry.entities.ratty.type..","..GODMODE.registry.entities.ratty.variant]
     = {die=true},
     [Isaac.GetEntityTypeByName("Cursed Apple (Vengeance)")..","..Isaac.GetEntityVariantByName("Cursed Apple (Vengeance)")..",1"]
     = {type=GODMODE.registry.entities.fruit.type,variant=GODMODE.registry.entities.fruit.variant,subtype=3},


     --     [GODMODE.registry.entities.dream.type..","..GODMODE.registry.entities.dream.variant]
--          = {type=EntityType.ENTITY_THE_HAUNT,variant=10},
--     [GODMODE.registry.entities.trailer.type..","..GODMODE.registry.entities.trailer.variant..",0"]
--          = {type=EntityType.ENTITY_GUSHER,variant=0},
--     [GODMODE.registry.entities.trailer.type..","..GODMODE.registry.entities.trailer.variant..",1"]
--          = {type=EntityType.ENTITY_HORF,variant=0},
--     [GODMODE.registry.entities.trailer.type..","..GODMODE.registry.entities.trailer.variant..",10"]
--          = {die=true},
--     [GODMODE.registry.entities.grubby.type..","..GODMODE.registry.entities.grubby.variant]
--          = {type=EntityType.ENTITY_POOTER,variant=0},
--     [GODMODE.registry.entities.cluster.type..","..GODMODE.registry.entities.cluster.variant]
--          = {type=EntityType.ENTITY_MOTER},
--     [GODMODE.registry.entities.harf.type..","..GODMODE.registry.entities.harf.variant]
--          = {type=EntityType.ENTITY_GUSHER},
--     [GODMODE.registry.entities.purple_heart.type..","..GODMODE.registry.entities.purple_heart.variant..",0"]
--          = {type=EntityType.ENTITY_HEART},
--     [GODMODE.registry.entities.purple_heart.type..","..GODMODE.registry.entities.purple_heart.variant..",1"]
--          = {die=true},
--     [GODMODE.registry.entities.fetal_baby.type..","..GODMODE.registry.entities.fetal_baby.variant]
--          = {type=EntityType.ENTITY_EMBRYO},
--     [GODMODE.registry.entities.planter.type..","..GODMODE.registry.entities.planter.variant]
--          = {type=EntityType.ENTITY_HOPPER,variant=1},
--     [GODMODE.registry.entities.big_dipper.type..","..GODMODE.registry.entities.big_dipper.variant]
--          = {type=EntityType.ENTITY_SQUIRT},
--     [GODMODE.registry.entities.barfer.type..","..GODMODE.registry.entities.barfer.variant]
--          = {type=EntityType.ENTITY_FULL_FLY},
--     [GODMODE.registry.entities.hover.type..","..GODMODE.registry.entities.hover.variant]
--          = {type=EntityType.ENTITY_HIVE},
--     [GODMODE.registry.entities.spiked_host.type..","..GODMODE.registry.entities.spiked_host.variant]
--          = {type=EntityType.ENTITY_HOST},
--     [GODMODE.registry.entities.spiked_flesh_host.type..","..GODMODE.registry.entities.spiked_flesh_host.variant]
--          = {type=EntityType.ENTITY_HOST,variant=1},
--     [GODMODE.registry.entities.chanter.type..","..GODMODE.registry.entities.chanter.variant]
--          = {type=GODMODE.registry.entities.marshall_pawn.type,variant=GODMODE.registry.entities.marshall_pawn.variant},
--     [GODMODE.registry.entities.paracolony.type..","..GODMODE.registry.entities.paracolony.variant]
--          = {type=EntityType.ENTITY_PARA_BITE},
--     [GODMODE.registry.entities.blood_baby.type..","..GODMODE.registry.entities.blood_baby.variant]
--          = {type=EntityType.ENTITY_EMBRYO},
--     [GODMODE.registry.entities.fallen_angelic_baby.type..","..GODMODE.registry.entities.fallen_angelic_baby.variant]
--          = {type=EntityType.ENTITY_EMBRYO},
--     [GODMODE.registry.entities.queen_fly.type..","..GODMODE.registry.entities.queen_fly.variant]
--          = {type=EntityType.ENTITY_POOTER,variant=1},
--     [GODMODE.registry.entities.godleg.type..","..GODMODE.registry.entities.godleg.variant]
--          = {type=EntityType.ENTITY_CRAZY_LONG_LEGS},
--     [GODMODE.registry.entities.marshall_pawn.type..","..GODMODE.registry.entities.marshall_pawn.variant]
--          = {type=EntityType.ENTITY_EMBRYO},
--     [GODMODE.registry.entities.arch_bishop.type..","..GODMODE.registry.entities.arch_bishop.variant..",0"]
--          = {type=EntityType.ENTITY_CULTIST},
--     [GODMODE.registry.entities.pooglobin.type..","..GODMODE.registry.entities.pooglobin.variant]
--          = {grid=true,type=GridEntityType.GRID_POOP},
--     [GODMODE.registry.entities.mum.type..","..GODMODE.registry.entities.mum.variant]
--          = {type=EntityType.ENTITY_NULL},
--     [GODMODE.registry.entities.the_id.type..","..GODMODE.registry.entities.the_id.variant..",700"]
--          = {type=EntityType.ENTITY_BEGOTTEN},
--     [GODMODE.registry.entities.parabit.type..","..GODMODE.registry.entities.parabit.variant..",700"]
--          = {die=true},
--     [GODMODE.registry.entities.winged_spider.type..","..GODMODE.registry.entities.winged_spider.variant]
--          = {type=EntityType.ENTITY_SWARM_SPIDER},
--     [GODMODE.registry.entities.ludomini.type..","..GODMODE.registry.entities.ludomini.variant]
--          = {type=EntityType.ENTITY_PSY_HORF},
--     [GODMODE.registry.entities.ratty.type..","..GODMODE.registry.entities.ratty.variant]
--          = {die=true},
--     [GODMODE.registry.entities.infested_membrain.type..","..GODMODE.registry.entities.infested_membrain.variant]
--          = {type=EntityType.ENTITY_BRAIN},
--     [GODMODE.registry.entities.vengeance.type..","..GODMODE.registry.entities.vengeance.variant]
--          = {type=EntityType.ENTITY_GAPER},
--     [Isaac.GetEntityTypeByName("Cursed Apple (Vengeance)")..","..Isaac.GetEntityVariantByName("Cursed Apple (Vengeance)")..",1"]
--          = {type=GODMODE.registry.entities.fruit.type,variant=GODMODE.registry.entities.fruit.variant,subtype=3},
}

d10.get_output_entity = function(ent)
    if d10.conversion_list[ent.Type..","..ent.Variant..","..ent.SubType] then 
        return d10.conversion_list[ent.Type..","..ent.Variant..","..ent.SubType]
    elseif d10.conversion_list[ent.Type..","..ent.Variant] then 
        return d10.conversion_list[ent.Type..","..ent.Variant]
    elseif d10.conversion_list[ent.Type] then 
        return d10.conversion_list[ent.Type]
    end
end

d10.on_d10_use = function(coll,rng,player,useflags,slot,vardata)
    local ents = Isaac.GetRoomEntities()

    for _,ent in ipairs(ents) do 
        if ent:ToNPC() then 
            ent = ent:ToNPC()
            local new_ent = d10.get_output_entity(ent)

            if new_ent then 
                if new_ent.type == nil then 
                    GODMODE.log("old ent = "..ent.Type..","..ent.Variant..","..ent.SubType.." - new ent = "..(new_ent.type or "NA")..","..(new_ent.variant or "NA")..","..(new_ent.subtype or "NA"),true)
                end
                
                if new_ent.die == true then 
                    ent:Kill()
                else
                    if new_ent.grid == true then 
                        Isaac.GridSpawn(new_ent.type,new_ent.variant or 0,ent.Position,false)
                        ent:Remove()
                    else 
                        ent:Morph(new_ent.type,new_ent.variant or 0, new_ent.subtype or 0, ent:GetChampionColorIdx())
                    end
                end

                local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,ent.Position,Vector.Zero,ent)
                fx:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            end    
        end
    end
end

return d10