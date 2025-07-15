local monster = {}
monster.name = "Teether"
monster.type = GODMODE.registry.entities.teether.type
monster.variant = GODMODE.registry.entities.teether.variant

monster.npc_update = function(self, ent, data, sprite)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()

    if data.real_time == 2 then --After the bat plays it's appear animation
        sprite:Play("Idle",true)
    end    

    data.rage_state = data.rage_state or 0
    data.rage_timer = data.rage_timer or (150 + ent:GetDropRNG():RandomInt(31))

    if ent.HitPoints < ent.MaxHitPoints then -- If the bat has less health than it's max health then
        if not data.group_rage then
            data.group_rage = true
            GODMODE.util.macro_on_enemies(nil,ent.Type,ent.Variant,nil,function(teether)
                GODMODE.get_ent_data(teether).rage_timer = teether:GetDropRNG():RandomFloat() * 15 --This sets the rage timer to zero, which triggers the rage.
                GODMODE.get_ent_data(teether).group_rage = true
            end)
        end

        data.rage_timer = 0
    end

    local targ = (player.Position - ent.Position)
    ent.Velocity = ent.Velocity * (0.85+data.rage_state * 0.075) + targ:Resized(math.min(targ:Length()/26.0,0.4 + data.rage_state * 0.25))
    --^Moves the bat towards the player.
    ent.CollisionDamage = data.rage_state --Sets the collision damage for the bat to what the rage state is.
    -- This changes to 1 after it's enraged, otherwise stays at 0, or harmless to touch.

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