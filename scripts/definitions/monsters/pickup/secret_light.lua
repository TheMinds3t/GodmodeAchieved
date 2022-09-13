local monster = {}
monster.name = "Secret Light"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

-- monster.data_init = function(self, params)
--     local data = params[2]
--     -- data.persistent_state = GODMODE.persistent_state.single_room
-- end

monster.pickup_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY

    if ent:GetSprite():IsFinished("Found") then
        Isaac.Spawn(5,0,0,ent.Position,Vector(0,0),nil)
        ent:Remove()
    end

    if not ent:GetSprite():IsPlaying("Idle") and not ent:GetSprite():IsPlaying("Found") or ent:GetSprite():IsFinished("Appear") then
        ent:GetSprite():Play("Idle",false)
        ent.SplatColor = Color(0,0,0,0,255,255,255)
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_PLAYER_CONTROL )
    end

    -- ent.V1 = ent.V1 or ent.Position
    ent.Position = Game():GetRoom():GetGridPosition(Game():GetRoom():GetGridIndex(ent.Position))

    ent.Velocity = Vector(0,0)
end

-- monster.new_room = function(self)
--     GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,-1,function(ent)
--         if ent.FrameCount > 5 and ent:HasEntityFlags(EntityFlag.FLAG_APPEAR) then
--             ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
--         end
--     end)
-- end

monster.pickup_init = function(self,ent)
    if GODMODE.util.is_mirror() and ent.Type == monster.type and ent.Variant == monster.variant then ent:Remove() end
    ent:GetSprite():Play("Appear",true)

end

monster.player_collide = function(self, player,ent,entfirst)
    if (ent.Type == monster.type and ent.Variant == monster.variant) then 
        if ent:GetSprite():IsPlaying("Found") then return true end

        -- if not ent:GetSprite():IsPlaying("Found") and GODMODE.get_ent_data(ent).found ~= true and ent.FrameCount > 2 then
        if not ent:GetSprite():IsPlaying("Found") and ent.FrameCount > 2 then
            player:AnimateHappy()
            ent:GetSprite():Play("Found", true)
            -- GODMODE.get_ent_data(ent).found = true
        end
        
        return true
    end
end


return monster