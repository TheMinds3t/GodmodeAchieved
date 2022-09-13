local monster = {}

monster.name = "Golden Scale"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    local anim = "Scale"

    if not ent:GetSprite():IsPlaying(anim) then
        ent:GetSprite():Play(anim,false)
        ent.SplatColor = Color(0,0,0,0,255,255,255)
        data.ori_position = ent.Position
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
    end

    ent.Velocity = Vector(0,0)
end

return monster