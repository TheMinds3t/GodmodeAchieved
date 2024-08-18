local monster = {}
monster.name = "Fallen Light Crack"
monster.type = GODMODE.registry.entities.fallen_light_crack.type
monster.variant = GODMODE.registry.entities.fallen_light_crack.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	

    --ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    if ent.FrameCount == 1 then
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
            ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
        end
        
        if ent.SubType == 0 then 
            sprite:Play("Crack"..(ent:GetDropRNG():RandomInt(2)+1),true)
        else
            sprite:Play("Crack"..ent.SubType,true)
        end

        ent:BloodExplode()
    end

    ent.DepthOffset = -100
    ent.Velocity = Vector.Zero

    if sprite:IsFinished("Crack1") or sprite:IsFinished("Crack2") then
        ent:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR | EntityFlag.FLAG_FRIENDLY_BALL)
    end
end

return monster