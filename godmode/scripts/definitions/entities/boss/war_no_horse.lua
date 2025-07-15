local monster = {}
--fruit cellar famine
monster.name = "(GODMODE) War without horse"
monster.type = GODMODE.registry.entities.godmode_war_no_horse.type
monster.variant = GODMODE.registry.entities.godmode_war_no_horse.variant
local max_slow = 20

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant and ent.SubType == 700) then return end	
    data.vel_slow = math.max((data.vel_slow or max_slow)-1,0)
    ent.Velocity = ent.Velocity * (1.0 - data.vel_slow / max_slow)
end

return monster