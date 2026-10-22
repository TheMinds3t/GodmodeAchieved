local monster = {}
monster.name = "[GODMODE] Biggest Star"
monster.type = GODMODE.registry.entities.biggest_star.type
monster.variant = GODMODE.registry.entities.biggest_star.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()

    if data.real_time == 2 then --After the bat plays it's appear animation
        sprite:Play("Fly",true)
    end    

    local targ = (player.Position - ent.Position)
    ent.Velocity = ent.Velocity * (0.85+data.rage_state * 0.075) + targ:Resized(math.min(targ:Length()/26.0,0.65))

    -- If there is still time before it rages then decrease the timer by 1.
    if data.rage_timer > 0 then data.rage_timer = data.rage_timer - 1 else -- ELSE if the timer is at or below 0
        if data.rage_state == 0 then
            if sprite:GetAnimation() ~= "Transform" then 
                sprite:Play("Transform", true) --Play the transform animation
            end

            if sprite:IsFinished("Transform") then --Once the transform animation is done, then
                sprite:Play("IdleRage", true) --Play the raging idle animation and set the
                data.rage_state = 1 --Current rage state to 1 so it knows not to play the transform animation
                -- Again.
            end
        end
    end

    if sprite:IsEventTriggered("SFX") then 
        GODMODE.sfx:Play(SoundEffect.SOUND_SHAKEY_KID_ROAR,3.0*Options.SFXVolume)
    end
end

return monster