local monster = {}
--fruit cellar famine
monster.name = "(GODMODE) Death without horse"
monster.type = GODMODE.registry.entities.godmode_death_no_horse.type
monster.variant = GODMODE.registry.entities.godmode_death_no_horse.variant

monster.npc_init = function(self,ent)
    if ent.SpawnerEntity ~= nil and ent.SpawnerEntity.Type == monster.type and ent.SpawnerEntity.Variant == monster.variant and ent.SpawnerEntity.SubType == 700 then 
    -- if ent.Type == monster.type and ent.Variant == 0 then 
        ent:Morph(GODMODE.registry.entities.pooglobin.type,GODMODE.registry.entities.pooglobin.variant,0,-1)    
        ent.Scale = 1.15
        ent.MaxHitPoints = ent.MaxHitPoints * 2
        ent.HitPoints = ent.HitPoints

        Isaac.Spawn(GODMODE.registry.entities.pooglobin.type,GODMODE.registry.entities.pooglobin.variant,0,ent.Position+RandomVector()*ent.Size,Vector.Zero,nil)
    end
end

monster.bypass_hooks = {["npc_init"] = true}

return monster