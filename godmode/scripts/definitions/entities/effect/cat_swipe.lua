local monster = {}
monster.name = "Celestial Swipe"
monster.type = GODMODE.registry.entities.celestial_swipe.type
monster.variant = GODMODE.registry.entities.celestial_swipe.variant

-- this is just a generic one-off animation entity
monster.effect_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	

    -- if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
    --     ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
    -- end

    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    if ent.FrameCount == 1 then
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
        sprite:Play("FX",true)
    end
    
    ent.DepthOffset = 100

    ent.Velocity = ent.Velocity * 0.8

    if sprite:IsFinished("FX") then
        ent:Remove()
    end

    -- subtype specific effects
    if sprite:IsEventTriggered("Fire") then 
        if ent.SubType == GODMODE.registry.entities.feather_dust.subtype then 
            local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.DUST_CLOUD,0,ent.Position,Vector.Zero,nil):ToEffect()
            cloud:SetTimeout(100)        
        end
    end
end

return monster