local monster = {}
-- monster.data gets updated every callback
monster.name = "Devil Lock"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.projectile_init = function(self,proj)
    if proj.SpawnerEntity ~= nil and proj.SpawnerEntity.Type == monster.type and proj.SpawnerEntity.Variant == monster.variant then 
        -- proj.Velocity = proj.Velocity * 0.75
        -- proj.FallingSpeed = -(5/60)
        -- proj.FallingAccel = -5/60
    end
end

return monster