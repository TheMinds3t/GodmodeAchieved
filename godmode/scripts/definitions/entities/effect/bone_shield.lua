local monster = {}
monster.name = "Crossbones Shield"
monster.type = GODMODE.registry.entities.crossbones_shield.type
monster.variant = GODMODE.registry.entities.crossbones_shield.variant

-- monster.data_init = function(self, ent,data)
-- 	if ent.Type == monster.type and ent.Variant == monster.variant then 
--         ent.SplatColor = Color(0,0,0,0,255,255,255)
--         ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
--         ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
--     end
-- end
monster.offset = Vector(0,18)
monster.effect_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    ent.DepthOffset = 100
    -- if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
    --     ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
    -- end
    
    if ent.SpawnerEntity ~= nil then 
        ent.Velocity = ent.SpawnerEntity.Position - (monster.offset + ent.Position)

        if (ent.SpawnerEntity.Position - ent.Position):Length() > ent.SpawnerEntity.Size * 4 then 
            ent.Position = ent.SpawnerEntity.Position
            ent.Velocity = Vector.Zero
        end
    end

    -- 
    -- ent:FollowParent(ent.Parent or ent.SpawnerEntity)

    if data.plays_left == nil then
        if ent.SubType == 1 then
            data.plays_left = 20
        else
            data.plays_left = 3
        end

        sprite:Play("Form", true)
    end


    if sprite:IsEventTriggered("Time") or sprite:IsFinished("Form") then
        if sprite:GetAnimation() == "Form" then
            sprite:Play("Idle", false)
        else
            data.plays_left = data.plays_left - 1
            if data.plays_left == 0 then
                sprite:Play("Break", true)
            end
        end
    end

    if sprite:IsFinished("Break") then
        ent:Remove()
    end
end

return monster