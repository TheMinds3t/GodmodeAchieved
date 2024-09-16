local monster = {}
monster.name = "Barfer"
monster.type = GODMODE.registry.entities.barfer.type
monster.variant = GODMODE.registry.entities.barfer.variant

monster.barf_radius = 192

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()

    if ent.SubType == 1 then
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        if data.real_time == 2 then
            sprite:Play("PukeUp", true)
            ent.Velocity = data.speed
        end

        if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
            ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
        end

        ent.Velocity = ent.Velocity * 0.9
        ent.SpriteOffset = ent.SpriteOffset * 0.9 + Vector(0,0) * 0.1
        ent.DepthOffset = 10

        if sprite:IsEventTriggered("Puke") and sprite:IsPlaying("PukeUp") then
            sprite:Play("PukeDown", true)
        end

        if sprite:IsEventTriggered("Puke") and sprite:IsPlaying("PukeDown") then
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
        local vel = ang:Resized(1.5+math.min(5,ang:Length()))
        ent.Velocity = ent.Velocity * 0.985 + vel * (1 / 3.5) / 10
        if data.real_time == 2 then
            sprite:Play("Idle", true)
        end       

        if sprite:IsPlaying("Idle") and (data.time) % 50 == 0 and ent:GetDropRNG():RandomFloat() < 0.85 and ang:Length() < monster.barf_radius then
            sprite:Play("Puke", true)
        end

        if sprite:IsFinished("Puke")  then
            sprite:Play("Idle", true)
        end

        ent.Velocity = ent.Velocity * 0.95

        if data.puke and data.puke > 0 then
            ent.Velocity = ent.Velocity * 0.5
            data.puke = data.puke - 1
        end

        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS

        if sprite:IsEventTriggered("Puke") then
            data.puke = 30
            local p = Isaac.Spawn(ent.Type,ent.Variant,1,ent.Position+vel*5,vel*0.15,ent)
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