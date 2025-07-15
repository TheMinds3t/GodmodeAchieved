local monster = {}
monster.name = "Chigger"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.familiar_update = function(self, fam)
	local data = GODMODE.get_ent_data(fam)
    local player = fam.Player

    if fam.Type == monster.type and fam.Variant == monster.variant then
        if fam.FrameCount % 20 == 2 and (fam.Target == nil or not GODMODE.util.is_valid_enemy(fam.Target)) then
            local ents = Isaac.GetRoomEntities()
            for i,ent in ipairs(ents) do
                if GODMODE.util.is_valid_enemy(ent,true,true) then
                    if fam.Target == nil or ent.HitPoints > fam.Target.HitPoints then 
                        if ent.Size > 3 then fam.Target = ent end 
                    end
                end
            end
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) and data.hive_mind ~= true then
            fam.SpriteScale = Vector(1.25,1.25)
            fam.CollisionDamage = fam.CollisionDamage * 2.0
            data.hive_mind = true
        end

        if fam:GetSprite():IsFinished("Appear") then
            fam:GetSprite():Play("Idle", false)
        end

        if fam.Target ~= nil and fam.FrameCount % 2 == 1 or fam.FramCount == 1 then
            fam.Velocity = fam.Velocity + ((fam.Target.Position - fam.Position):Resized(2.65+math.abs(math.cos(fam.FrameCount / 2) * 0.5)))
            fam.Velocity = fam.Velocity * 0.8
        end

        if data.cooldown_time == nil then data.cooldown_time = 10 end
        data.cooldown_time = data.cooldown_time - 1

        if fam.Target == nil or fam.Target:IsDead() then 
            fam.Velocity = fam.Velocity * 0.7 + (player.Position - fam.Position) * (1 / 120.0) + RandomVector()*(1.5+fam:GetDropRNG():RandomFloat()*0.5)
        end
        if fam.Velocity:Length() > 8 then fam.Velocity:Resize(8) end
    end
end

monster.familiar_collide = function(self, fam, ent, entfirst)
    if not (fam.Type == monster.type and fam.Variant == monster.variant) then return end
    local data = GODMODE.get_ent_data(fam)
    if data.cooldown_time == nil then data.cooldown_time = 10 if fam.SubType == 1 then data.cooldown_time = 5 end end

    if data.cooldown_time > 0 then
        return true
    end
    
    if ent:IsVulnerableEnemy() and data.cooldown_time <= 0 then
        fam.HitPoints = fam.HitPoints - 1 / fam.Player:GetCollectibleNum(Isaac.GetItemIdByName("Larval Therapy"))
        if fam.HitPoints <= 0 then fam:Kill() end
        ent:TakeDamage(fam.CollisionDamage, 0, EntityRef(fam), 1)
        data.cooldown_time = 15
        return true
    end
end

return monster