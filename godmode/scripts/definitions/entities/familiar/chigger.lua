local monster = {}
monster.name = "Chigger"
monster.type = GODMODE.registry.entities.chigger.type
monster.variant = GODMODE.registry.entities.chigger.variant

local max_idle_speed = 3.0
local min_idle_speed = 1.7
local max_speed = 7

monster.familiar_update = function(self, fam, data)
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

        if fam.Target ~= nil and fam.FrameCount % 2 == 1 then
            fam.Velocity = fam.Velocity * 0.8 + (((fam.Target.Position + Vector(fam.Target.Size,fam.Target.Size):Rotated(fam:GetDropRNG():RandomInt(360))) - fam.Position):Resized(2.65+math.abs(math.cos(fam.FrameCount / 2) * 0.5)))
        end

        if data.cooldown_time == nil then data.cooldown_time = 10 end
        data.cooldown_time = data.cooldown_time - 1

        if fam.Target == nil or fam.Target:IsDead() then 
            local vel = ((player.Position 
            + Vector(64,64):Rotated((fam.InitSeed + fam.FrameCount * (2 + fam.InitSeed % 10 / 10.0)) % 360):Resized(math.cos(math.rad((fam.InitSeed - fam.FrameCount) % 360))*24 + 40)) 
            - fam.Position) * (1.0/20.0)

            fam.Velocity = fam.Velocity * 0.7 + vel:Resized(math.min(vel:Length(),fam:GetDropRNG():RandomFloat() * (max_idle_speed - min_idle_speed) + min_idle_speed))
                 + RandomVector()*(1.5+fam:GetDropRNG():RandomFloat()*0.5)
        end

        if fam.Velocity:Length() > max_speed then fam.Velocity:Resize(max_speed) end
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
        fam.HitPoints = fam.HitPoints - 1 / (fam.Player:GetCollectibleNum(GODMODE.registry.items.larval_therapy) + fam.Player:GetCollectibleNum(GODMODE.registry.items.reclusive_tendencies))
        if fam.HitPoints <= 0 then 
            if fam.SubType == 1 then 
                local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.PLAYER_CREEP_GREEN,0,fam.Position,Vector.Zero,fam.Player)
                creep = creep:ToEffect()
                creep.Timeout = 100
                creep.Scale = 1.0
                creep.CollisionDamage = fam.CollisionDamage * 0.25
                creep:Update()
            end

            fam:Kill() 
        end


        ent:TakeDamage(fam.CollisionDamage, 0, EntityRef(fam), 1)
        data.cooldown_time = 15
        return true
    end
end

return monster