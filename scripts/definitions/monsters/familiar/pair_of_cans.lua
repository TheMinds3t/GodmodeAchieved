local monster = {}
monster.name = "Pair of Cans"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.familiar_init = function(self, fam)

end
monster.familiar_update = function(self, fam)
    if fam.Type == monster.type and fam.Variant == monster.variant then
        local player = fam.Player
        if fam.SubType % 2 == 1 then
            fam:GetSprite():Play("String",false)
        end
        fam.SplatColor = Color(0,0,0,0,255,255,255)

        fam:AddToOrbit(4)
        fam.OrbitDistance = Vector(48,48)
        fam.OrbitSpeed = 0.035
        fam.OrbitAngleOffset = math.rad(fam.SubType * 90)

        if fam.SubType % 2 == 1 then
            fam.SpriteRotation = (player.Position - fam.Position):GetAngleDegrees() - 90
            fam.SpriteOffset = Vector(0,-16)
            fam.SpriteScale = Vector(0.465,0.6)
            fam.Size = 48
            fam.OrbitDistance = Vector(36,36)
        end

        fam.Velocity = fam:GetOrbitPosition(player.Position + player.Velocity) - fam.Position
        --fam.Position = player.Position + Vector(math.cos(ang) * (dist + xoff),math.sin(ang) * (dist + yoff))
    end
end

monster.familiar_collide = function(self, fam, enthit, entfirst)
    if not (fam.Type == monster.type and fam.Variant == monster.variant) then return end

    if enthit.Type == EntityType.ENTITY_PROJECTILE and not enthit:ToProjectile():HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) and fam.Type == monster.type and fam.Variant == monster.variant then
        enthit:Kill()
        fam.HitPoints = fam.HitPoints - 10 / (fam.Player:GetCollectibleNum(Isaac.GetItemIdByName("Pair of Cans")) + fam.Player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BFFS))
        if fam.HitPoints <= 0 then fam:Kill() end
    end
end

return monster