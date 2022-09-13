local monster = {}
monster.name = "Ritual Candle (Familiar)"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.familiar_update = function(self, fam)
    if fam.Type == monster.type and fam.Variant == monster.variant then
        local data = GODMODE.get_ent_data(fam)
        local player = fam.Player
        if GODMODE.save_manager.get_player_data(player, "Cultist", "false") == "false" then fam:Remove() end

        fam.SpriteOffset = Vector(0,0)

        if fam:GetSprite():IsFinished("Appear") then 
            fam:GetSprite():Play("Idle", true)
        end

        if fam:GetSprite():IsFinished("Idle") then 
            fam.Target = nil
            fam:PickEnemyTarget(256.0, 1, 5, Vector.Zero, 180)

            if fam.Target == nil then 
                fam:GetSprite():Play("Idle", true)
            else
                if fam.Target ~= nil then 
                    fam:GetSprite():Play("Attack", true)
                else
                    fam:GetSprite():Play("Idle", true)
                end
            end
        end

        if fam:GetSprite():IsFinished("Attack") or fam.Target == nil and not fam:GetSprite():IsPlaying("Idle") then 
            fam:GetSprite():Play("Idle", true)
        end

        if fam:GetSprite():IsEventTriggered("Attack") and fam.Target ~= nil then 
            local dir = (fam.Target.Position - fam.Position)
            dir = dir:Resized(math.min(math.max(2,dir:Length()),8))
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLUE_FLAME, 0, fam.Position, dir, fam.Player):ToEffect()
            effect:SetTimeout(60)
            effect.CollisionDamage = 5.0 + fam.Player.Damage * Game():GetLevel():GetAbsoluteStage() / 13.0
        end

        local dir = (fam.Player.Position - fam.Position)

        if fam:GetSprite():IsEventTriggered("Move") then 
            dir = dir:Resized(math.min(math.max(3,dir:Length()),8))
            fam.Velocity = fam.Velocity * 0.8 + dir
        end

        fam.Velocity = fam.Velocity * 0.9 + dir * (1 / 200)
    end
end

return monster