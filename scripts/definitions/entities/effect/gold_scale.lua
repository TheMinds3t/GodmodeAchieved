local monster = {}

monster.name = "Golden Scale"
monster.type = GODMODE.registry.entities.golden_scale.type
monster.variant = GODMODE.registry.entities.golden_scale.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local anim = "Scale"
    data.ori_position = ent.Position

    if ent.SubType == 0 then 
        if not sprite:IsPlaying(anim) then
            sprite:Play(anim,false)
            ent.SplatColor = Color(0,0,0,0,255,255,255)
            if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
                ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
            end
        end    
    end

    ent.Velocity = Vector(0,0)
end

return monster