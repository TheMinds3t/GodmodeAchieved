local monster = {}
monster.name = "Holy Chalice"
monster.type = GODMODE.registry.entities.holy_chalice.type
monster.variant = GODMODE.registry.entities.holy_chalice.variant

monster.familiar_init = function(self, fam)
    if fam.Type == monster.type and fam.Variant == monster.variant then
        fam:AddToFollowers()
    end
end
monster.familiar_update = function(self, fam, data)
    local player = fam.Player
    if fam.Type == monster.type and fam.Variant == monster.variant then
        fam.SubType = GODMODE.get_ent_data(player).chalice_level or 0
        fam:GetSprite():Play("Filled"..fam.SubType,false)
        fam:FollowParent()
    end
end

return monster