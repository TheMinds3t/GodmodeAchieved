local monster = {}
monster.name = "Burnt Page"
monster.type = GODMODE.registry.entities.burnt_page.type
monster.variant = GODMODE.registry.entities.burnt_page.variant

monster.familiar_update = function(self, fam, data)
    local player = fam.Player
    if fam.Type == monster.type and fam.Variant == monster.variant then
        fam:MoveDiagonally(1.0+math.abs(math.cos(fam.InitSeed + fam.FrameCount / 12.5) * 0.125))
    end
end

monster.familiar_collide = function(self, fam, ent, entfirst)
    if fam.Type == monster.type and fam.Variant == monster.variant and ent:IsVulnerableEnemy() then
        fam:Kill()
        ent:AddBurn(EntityRef(fam),60*5,5.0)
        ent:TakeDamage(5.0, 0, EntityRef(fam), 1)
        return false
    end
end

return monster