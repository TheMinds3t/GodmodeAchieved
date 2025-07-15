local monster = {}
monster.name = "Shatter Coin"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)

    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    if ent.FrameCount == 1 then
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
    end

    ent:GetSprite():Play("Shatter")

    if data.velocity_flag ~= true then 
        ent.Velocity = ent.Velocity * 1.05
    else
        ent.Velocity = ent.Velocity * 0.875
    end

    if ent:GetSprite():IsEventTriggered("VelocityFlag") then
        data.velocity_flag = true
    end

    if ent:GetSprite():IsFinished("Shatter") then
        ent:Remove()
    end
end

return monster