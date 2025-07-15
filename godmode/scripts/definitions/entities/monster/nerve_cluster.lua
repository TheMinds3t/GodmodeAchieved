local monster = {}
monster.name = "Nerve Cluster"
monster.type = GODMODE.registry.entities.nerve_cluster.type
monster.variant = GODMODE.registry.entities.nerve_cluster.variant

local max_time = 40
monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    

    if ent.SubType == 1 then 
        local perc = math.max(0,1-ent.FrameCount/max_time)
        ent:SetColor(Color(1,1,1,1,perc*0.8,0,0),99,10000,true,true)

        if perc == 0 then 
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        end
    end

    ent.Velocity = Vector(0,0)
    
    sprite:Play("Idle", false)
    if sprite:IsEventTriggered("Shoot") then--data.time % 30 == 0 or data.time % 30 == 15 then
        if ent.I1 >= 3 then ent.I1 = 0 else ent.I1 = ent.I1 + 1 end 
        local count = 3 
        if ent.SubType == 1 then --hostess variant
            count = 4
        end

        for i=1,count do
            local ang = math.rad(ent.I1 * (360/count/4) + i * (360/count))
            local spd = math.min(3.5,ent.FrameCount/60.0) + ent:GetDropRNG():RandomFloat()*0.2

            if ent.SubType == 1 then --hostess variant
                spd = 2.75
            end

            local t = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,Vector(ent.Position.X+math.cos(ang)*spd,ent.Position.Y+math.sin(ang)*spd),Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
            t = t:ToProjectile()
            t.Height = t.Height - 30
            t.FallingAccel = 0.3 - math.min(1,ent.SubType)*0.1
        end
    end
end

return monster