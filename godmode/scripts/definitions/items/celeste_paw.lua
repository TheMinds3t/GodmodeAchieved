local item = {}
item.instance = GODMODE.registry.items.celestial_paw
item.eid_description = "↑ All enemies get converted into half soul hearts on use# ↓ -1 Heart Container # Bosses take damage equal to 25% of their max health"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "On use:"},
      {str = " - Removes 1 heart container."},
      {str = " - All enemies in the room get converted into a half soul heart."},
      {str = " - All bosses take damage equal to 25% of their max health, and if they die from this they also spawn a half soul heart."},
    },
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
    if coll == item.instance then
        for _,ent in ipairs(Isaac.GetRoomEntities()) do
            if ent:IsVulnerableEnemy() and ent.Type ~= EntityType.ENTITY_FIREPLACE then
                local flag = not ent:IsBoss()

                if not flag then 
                    ent:TakeDamage(ent.MaxHitPoints * 0.25, DamageFlag.DAMAGE_INVINCIBLE, EntityRef(player), 1)
                    flag = (ent.HitPoints - ent.MaxHitPoints * 0.25) <= 0.0
                end

                if flag then
                    ent:Kill()
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF_SOUL, ent.Position, Vector.Zero, nil)
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_EXPLOSION, 0, ent.Position, Vector.Zero, player)
                    Isaac.Spawn(GODMODE.registry.entities.celestial_swipe.type, GODMODE.registry.entities.celestial_swipe.variant, 0, ent.Position, Vector.Zero, nil)
                end
            end
        end

        GODMODE.game:ShakeScreen(20)
        player:AddMaxHearts(-2)

        return true
    end
end

return item