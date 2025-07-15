local monster = {}

monster.name = "Shade Hand"
monster.type = GODMODE.registry.entities.shade.type
monster.variant = GODMODE.registry.entities.shade.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    ent.Velocity = Vector(0,0)
    
    if not sprite:IsPlaying("Darkness") then
	    sprite:Play("Idle", false)
    end

    if sprite:IsFinished("Idle") then
    	sprite:Play("Darkness",false)
    end
    if sprite:IsEventTriggered("Darkness") then
    	GODMODE.game:Darken(math.min(1.0,0.55 + 0.05 * GODMODE.util.count_enemies(nil, monster.type, monster.variant)),156)
    end
end

monster.npc_kill = function(self, ent)
    if ent:GetSprite():IsPlaying("Darkness") then
        local num = GODMODE.util.count_enemies(nil, monster.type, monster.variant)

        if num == 1 then 
            GODMODE.game:Darken(0.55,30) 
        else
            GODMODE.game:Darken(math.min(1.0,0.50 + 0.05 * num),156-(ent:GetSprite():GetFrame()-23))
        end
    end
end

return monster