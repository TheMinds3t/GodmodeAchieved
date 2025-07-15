local monster = {}
monster.name = "Crossbones Shield"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, params)
    local ent = params[1]
    local data = params[2]
    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
end
monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
    ent.DepthOffset = 100

    if ent.SpawnerEntity ~= nil then 
        ent.Velocity = ent.SpawnerEntity.Position - Vector(0,18) - ent.Position
    end

    if data.plays_left == nil then
        if ent.SubType == 1 then
            data.plays_left = 20
        else
            data.plays_left = 3
        end

        ent:GetSprite():Play("Form", false)
    end


    if ent:GetSprite():IsEventTriggered("Time") then
        if ent:GetSprite():IsPlaying("Form") then
            ent:GetSprite():Play("Idle", false)
        else
            data.plays_left = data.plays_left - 1
            if data.plays_left == 0 then
                ent:GetSprite():Play("Break", true)
            end
        end
    end

    if ent:GetSprite():IsFinished("Break") then
        ent:Remove()
    end
end

return monster