local monster = {}
monster.name = "Mum"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
local speedup_time = 80
local max_friction = 1.0125
monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    ent.Friction = math.min(max_friction, math.max(0.25,ent.FrameCount*(max_friction/speedup_time)))
    
    local pathfinding = GODMODE.util.ground_ai_movement(ent,ent:GetPlayerTarget(),1.25,true)

    if pathfinding ~= nil then 
        ent.Velocity = ent.Velocity * 0.75 + pathfinding 
    elseif ent:GetPlayerTarget() ~= nil then 
        ent.Pathfinder:FindGridPath(ent:GetPlayerTarget().Position,0.8*ent.Friction,0,true)
    end

    ent:GetSprite():PlayOverlay("Head",false)
    ent:AnimWalkFrame("WalkHori","WalkVert",1.2)
    ent:GetSprite().PlaybackSpeed = math.min(1,ent.Friction+0.25)
end

return monster