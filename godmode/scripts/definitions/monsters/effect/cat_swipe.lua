local monster = {}
monster.name = "Celestial Swipe"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)

    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    if ent.FrameCount == 1 then
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
        ent:GetSprite():Play("FX",true)
    end

    ent.DepthOffset = 100

    ent.Velocity = ent.Velocity * 0.8

    if ent:GetSprite():IsFinished("FX") then
        ent:Remove()
    end
end

return monster