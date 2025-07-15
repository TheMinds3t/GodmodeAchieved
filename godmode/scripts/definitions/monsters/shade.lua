local monster = {}

monster.name = "Shade Hand"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    ent.Velocity = Vector(0,0)
    
    if not ent:GetSprite():IsPlaying("Darkness") then
	    ent:GetSprite():Play("Idle", false)
    end

    if ent:GetSprite():IsFinished("Idle") then
    	ent:GetSprite():Play("Darkness",false)
    end
    if ent:GetSprite():IsEventTriggered("Darkness") then
    	Game():Darken(math.min(1.0,0.55 + 0.05 * GODMODE.util.count_enemies(nil, monster.type, monster.variant)),156)
    end
end

monster.npc_kill = function(self, ent)
    if ent:GetSprite():IsPlaying("Darkness") then
        local num = GODMODE.util.count_enemies(nil, monster.type, monster.variant)

        if num == 1 then 
            Game():Darken(0.55,30) 
        else
            Game():Darken(math.min(1.0,0.50 + 0.05 * num),156-(ent:GetSprite():GetFrame()-23))
        end
    end
end

return monster