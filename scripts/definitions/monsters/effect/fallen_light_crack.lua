local monster = {}
monster.name = "Fallen Light Crack"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	

    --ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    if ent.FrameCount == 1 then
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_QUERY)

        if ent.SubType == 0 then 
            ent:GetSprite():Play("Crack"..(ent:GetDropRNG():RandomInt(2)+1),true)
        else
            ent:GetSprite():Play("Crack"..ent.SubType,true)
        end

        ent:BloodExplode()
    end

    ent.DepthOffset = -100
    ent.Velocity = Vector.Zero

    if ent:GetSprite():IsFinished("Crack1") or ent:GetSprite():IsFinished("Crack2") then
        ent:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR | EntityFlag.FLAG_FRIENDLY_BALL)
    end
end

return monster