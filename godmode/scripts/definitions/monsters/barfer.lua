local monster = {}
monster.name = "Barfer"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()

    if ent.SubType == 1 then
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        if data.real_time == 2 then
            ent:GetSprite():Play("PukeUp", true)
            ent.Velocity = data.speed
        end            

        ent.Velocity = ent.Velocity * 0.95
        ent.SpriteOffset = ent.SpriteOffset * 0.9 + Vector(0,0) * 0.1
        ent.DepthOffset = 10

        if ent:GetSprite():IsEventTriggered("Puke") and ent:GetSprite():IsPlaying("PukeUp") then
            ent:GetSprite():Play("PukeDown", true)
        end

        if ent:GetSprite():IsEventTriggered("Puke") and ent:GetSprite():IsPlaying("PukeDown") then
            if ent.owner and ent.owner:IsDead() then ent:Kill() else
                for u=0,8+ent:GetDropRNG():RandomFloat()*3 do
                    local params = ProjectileParams() 
                    params.Variant = ProjectileVariant.PROJECTILE_PUKE
                    params.FallingAccelModifier = 1.25
                    params.GridCollision = false
                    ent:FireBossProjectiles(1,ent.Position+RandomVector():Resized(16-ent:GetDropRNG():RandomFloat()*8),0.35,params)
                    -- t.Color = Color(0.3,0.4,0.1,1.0,50/255,50/255,50/255)
                end                
                ent:Kill()
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_A, 10, ent.Position, Vector.Zero, ent)
            end
        end
    else
        local ang = player.Position - ent.Position
        local vel = Vector(math.cos(math.rad(ang:GetAngleDegrees())) * 3.5, math.sin(math.rad(ang:GetAngleDegrees())) * 3.5)
        ent.Velocity = ent.Velocity * 0.985 + vel * (1 / 3.5) / 10
        if data.real_time == 2 then
            ent:GetSprite():Play("Idle", true)
        end       

        if ent:GetSprite():IsPlaying("Idle") and (data.time) % 50 == 0 and ent:GetDropRNG():RandomFloat() < 0.85 then
            ent:GetSprite():Play("Puke", true)
        end

        if ent:GetSprite():IsFinished("Puke")  then
            ent:GetSprite():Play("Idle", true)
        end

        ent.Velocity = ent.Velocity * 0.95

        if data.puke and data.puke > 0 then
            ent.Velocity = ent.Velocity * 0.5
            data.puke = data.puke - 1
        end

        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS

        if ent:GetSprite():IsEventTriggered("Puke") then
            data.puke = 30
            local p = Isaac.Spawn(ent.Type,ent.Variant,1,ent.Position+vel*5,vel,ent)
            p:GetSprite():Play("PukeUp", true)
            p:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            p.SpriteOffset = Vector(0,-16)
            local r = vel * (2.0 + ent:GetDropRNG():RandomFloat()*2)
            p.Velocity = r
            local d = GODMODE.get_ent_data(p)
            d.speed = r
            d.owner = ent
            p.Position = ent.Position
        end
    end

end

return monster