local monster = {}
-- monster.data gets updated every callback
monster.name = "Wrinkly Fatty"
monster.type = GODMODE.registry.entities.wrinkled_fatty.type
monster.variant = GODMODE.registry.entities.wrinkled_fatty.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()
    ent.I1 = math.max(0,ent.I1 - 1)
    ent.SplatColor = Color(0.5,0.1,0.1,1.0,0.0,0.1,0.1)

    if sprite:IsEventTriggered("Move") then
        ent.I1 = 10
    end

    local pathfinding = GODMODE.util.ground_ai_movement(ent,ent:GetPlayerTarget(),0.4,true)

    if pathfinding ~= nil then 
        ent.Velocity = ent.Velocity * 0.75 + pathfinding * (1.0 + ent.I1 / 5.0 * 2)
    elseif ent:GetPlayerTarget() ~= nil then 
        ent.Pathfinder:FindGridPath(ent:GetPlayerTarget().Position,(0.2 + ent.I1 / 5.0 * 0.3)*ent.Friction,0,true)
    end
    local dir = math.floor((ent.Velocity:GetAngleDegrees()+45+180)/90)%4
    ent.FlipX = dir == 0

    if dir % 2 == 0 then 
        sprite:Play("WalkHori",false)
    elseif dir == 1 then
        sprite:Play("WalkUp",false)
    else
        sprite:Play("WalkDown",false)
    end

    if ent:IsFrame(60-ent.InitSeed%16,ent.InitSeed) then 
        local vol = 1.25+Options.SFXVolume
        local pitch = 0.6+ent:GetDropRNG():RandomFloat()*0.2
        if ent:GetDropRNG():RandomFloat() < 0.5 then 
            GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_0,vol,2,false,pitch)
        else
            GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_1,vol,2,false,pitch)
        end
    end
end

monster.npc_kill = function(self,ent)
    if not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then 
        for i=1,3 do 
            local bby = Isaac.Spawn(EntityType.ENTITY_BABY,3,0,ent.Position,Vector(1,0):Rotated(360/3*i):Resized(10.0),ent)
            bby:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            bby:GetSprite():Play("DashStart",true)
        end
    end
end

return monster