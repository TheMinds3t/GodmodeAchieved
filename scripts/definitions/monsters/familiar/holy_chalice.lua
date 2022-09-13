local monster = {}
monster.name = "Holy Chalice"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.familiar_init = function(self, fam)
    if fam.Type == monster.type and fam.Variant == monster.variant then
        fam:AddToFollowers()
    end
end
monster.familiar_update = function(self, fam)
	local data = GODMODE.get_ent_data(fam)
    local player = fam.Player
    if fam.Type == monster.type and fam.Variant == monster.variant then
        fam.SubType = GODMODE.get_ent_data(player).chalice_level or 0
        fam:GetSprite():Play("Filled"..fam.SubType,false)
        fam:FollowParent()
    end
end

return monster