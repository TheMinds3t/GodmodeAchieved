local monster = {}
--fruit cellar famine
monster.name = "(GODMODE) War without horse"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
local max_slow = 20

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant and ent.SubType == 700) then return end	
    local data = GODMODE.get_ent_data(ent)
    data.vel_slow = math.max((data.vel_slow or max_slow)-1,0)
    ent.Velocity = ent.Velocity * (1.0 - data.vel_slow / max_slow)
end

return monster