local monster = {}
monster.name = "The Sign's Flame"
monster.type = GODMODE.registry.entities.sign_flame.type
monster.variant = GODMODE.registry.entities.sign_flame.variant

monster.familiar_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

    if not ent:GetSprite():IsPlaying("Flame") then
        ent:GetSprite():Play("Flame",false)
    end


    if ent.Player ~= nil then
        ent.Position = ent.Player.Position-Vector(4,8)
        -- ent.Velocity = (ent.Player.Position - Vector(0,4)) - ent.Position
    else
        ent:Kill()
    end

    ent.Velocity = Vector(0,0)
end

monster.new_room = function(self)
    GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(flame) flame:Remove() end)
end

return monster