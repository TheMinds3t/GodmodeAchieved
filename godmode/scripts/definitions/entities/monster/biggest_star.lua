local monster = {}
monster.name = "[GODMODE] Biggest Star"
monster.type = GODMODE.registry.entities.biggest_star.type
monster.variant = GODMODE.registry.entities.biggest_star.variant

local attack_cooldown = 80
monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()

    if not sprite:IsPlaying("Appear") and not sprite:IsPlaying("Fly") and not sprite:IsPlaying("Attack") then --After the bat plays it's appear animation
        sprite:Play("Fly", true)
    end


    local targ = (player.Position - ent.Position)
    data.attack_cooldown = (data.attack_cooldown or attack_cooldown) - 1
    local dist = targ:Length()

    if sprite:IsPlaying("Fly") and dist < 96 and (data.attack_cooldown or 0) <= 0 then 
        sprite:Play("Attack", true)
        data.attack_cooldown = attack_cooldown
    end

    ent.FlipX = targ.X < 0
    ent.Velocity = ent.Velocity * (0.85 - (dist < 128 and 0.3 or 0)) + targ:Resized(math.min(targ:Length()/26.0,0.65))

    if sprite:IsEventTriggered("SFX") then 
        GODMODE.sfx:Play(SoundEffect.SOUND_ANGEL_WING,0.7)
    end
end

return monster