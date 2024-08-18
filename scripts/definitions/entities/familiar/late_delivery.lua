local monster = {}
monster.name = "Late Delivery"
monster.type = GODMODE.registry.entities.late_delivery.type
monster.variant = GODMODE.registry.entities.late_delivery.variant

monster.familiar_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    sprite:Play("Give",false)
    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.Velocity = ent.Velocity * 0
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

    if sprite:IsEventTriggered("Spawn") then
        Isaac.Spawn(5,100,ent.SubType,(ent.Position - Vector(0,1)), Vector(0,0), ent)
    end



    if sprite:IsFinished("Give") and ent.FrameCount > 30 then
        ent:Remove()
        for i=0,8 do
            if i < 8 then
                local door = GODMODE.room:GetDoor(i)

                if door and not door:IsOpen() then
                    door:Open()
                end
            end
        end
    else
        for i=0,8 do
            if i < 8 then
                local door = GODMODE.room:GetDoor(i)

                if door and door:IsOpen() then
                    door:Close(true)
                end
            end
        end
    end
end

return monster