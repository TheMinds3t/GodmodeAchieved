local monster = {}
monster.name = "Late Delivery"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.familiar_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    local data = GODMODE.get_ent_data(ent)
    ent:GetSprite():Play("Give",false)
    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.Velocity = ent.Velocity * 0
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

    if ent:GetSprite():IsEventTriggered("Spawn") then
        Isaac.Spawn(5,100,ent.SubType,(ent.Position - Vector(0,1)), Vector(0,0), ent)
    end



    if ent:GetSprite():IsFinished("Give") and ent.FrameCount > 30 then
        ent:Remove()
        for i=0,8 do
            if i < 8 then
                local door = Game():GetRoom():GetDoor(i)

                if door and not door:IsOpen() then
                    door:Open()
                end
            end
        end
    else
        for i=0,8 do
            if i < 8 then
                local door = Game():GetRoom():GetDoor(i)

                if door and door:IsOpen() then
                    door:Close(true)
                end
            end
        end
    end
end

return monster