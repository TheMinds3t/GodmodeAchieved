local monster = {}
monster.name = "Mum"
monster.type = GODMODE.registry.entities.mum.type
monster.variant = GODMODE.registry.entities.mum.variant
local speedup_time = 80
local max_friction = 1.0125
monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    ent.Friction = math.min(max_friction, math.max(0.25,ent.FrameCount*(max_friction/speedup_time)))
    
    local pathfinding = GODMODE.util.ground_ai_movement(ent,ent:GetPlayerTarget(),1.25,true)

    if pathfinding ~= nil then 
        ent.Velocity = ent.Velocity * 0.75 + pathfinding 
    elseif ent:GetPlayerTarget() ~= nil then 
        ent.Pathfinder:FindGridPath(ent:GetPlayerTarget().Position,0.8*ent.Friction,0,true)
    end

    sprite:PlayOverlay("Head",false)
    ent:AnimWalkFrame("WalkHori","WalkVert",1.2)
    sprite.PlaybackSpeed = math.min(1,ent.Friction+0.25)
end

return monster