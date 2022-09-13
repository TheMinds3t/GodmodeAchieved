local monster = {}
monster.name = "Crack The Sky (With Tell)"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()
    --When the entity first spawns, play the idle animation.
    if ent.FrameCount == 1 then
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        ent:GetSprite():Play("Spotlight",true)
        ent.SplatColor = Color(0,0,0,0,255,255,255)
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
    end

    if ent:GetSprite():IsEventTriggered("Enable") then
        data.dangerous = true
        Game():ShakeScreen(5)
    end
    if ent:GetSprite():IsEventTriggered("Disable") then
        data.dangerous = false
    end

    if ent:GetSprite():IsEventTriggered("Kill") then
        ent:Remove()
    end

    if data.dangerous == nil then data.dangerous = false end

    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    ent.Velocity = Vector(0,0)

    --Calculate the distance between the player and the beggar
    local dist = math.abs(player.Position.X - ent.Position.X) + math.abs(player.Position.Y - ent.Position.Y)
    if dist < ent.Size+22 and data.dangerous and not player:IsInvincible() then
        player:TakeDamage(2.0,DamageFlag.DAMAGE_LASER,EntityRef(ent),1)
    end
end

return monster