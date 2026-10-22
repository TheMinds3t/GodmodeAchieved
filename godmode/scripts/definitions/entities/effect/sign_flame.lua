local monster = {}
monster.name = "[GODMODE] The Sign's Flame"
monster.type = GODMODE.registry.entities.sign_flame.type
monster.variant = GODMODE.registry.entities.sign_flame.variant

monster.familiar_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS

    if not ent:GetSprite():IsPlaying("Flame") then
        ent:GetSprite():Play("Flame",false)
    end

    if ent.Player ~= nil then
        ent.Position = ent.Player.Position-Vector(4,8)
        -- ent.Velocity = (ent.Player.Position - Vector(0,4)) - ent.Position
    end

    ent.Velocity = Vector(0,0)
end

monster.tear_update = function(self, tear, data)
    local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer() or nil

    if tear.FrameCount > 1 and player and (player.Position - tear.Position):Length() < player.Size * 2 and (
        tear.TearFlags & TearFlags.TEAR_SPLIT ~= 0 or tear.TearFlags & TearFlags.TEAR_QUADSPLIT ~= 0    
    ) and player:GetPlayerType() == GODMODE.registry.players.the_sign then 
        tear:Die() 
    end
end

return monster