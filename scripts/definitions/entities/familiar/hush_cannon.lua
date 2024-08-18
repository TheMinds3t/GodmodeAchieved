local monster = {}
monster.name = "Hush Cannon"
monster.type = GODMODE.registry.entities.hush_cannon.type
monster.variant = GODMODE.registry.entities.hush_cannon.variant

monster.familiar_update = function(self, fam, data)
    if fam.Type == monster.type and fam.Variant == monster.variant then
        local player = fam.Player
        fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

        if fam.SubType == 0 then
            fam.Position = player.Position
            fam.Velocity = Vector(0,0)
            fam.SpriteOffset = Vector(0,-28)

            if fam.FrameCount % 18 == 0 then
                player:AnimateCollectible(GODMODE.registry.items.anguish_jar)
            end
            player.FireDelay = player.MaxFireDelay
        else
            local v = player:GetShootingJoystick()--Vector(math.sin(math.rad(d)), math.cos(math.rad(d)))
            fam.Velocity = fam.Velocity * 0.75 + v * 3
            local tl = GODMODE.room:GetTopLeftPos()
            local br = GODMODE.room:GetBottomRightPos()

            if fam.Position.X < tl.X then 
                fam.Position.X = tl.X 
                if fam.Velocity.X < 0 then fam.Velocity.X = 0 end
            end

            if fam.Position.X > br.X then 
                fam.Position.X = br.X 
                if fam.Velocity.X > 0 then fam.Velocity.X = 0 end
            end

            if fam.Position.Y < tl.Y then 
                fam.Position.Y = tl.Y 
                if fam.Velocity.Y < 0 then fam.Velocity.Y = 0 end
            end

            if fam.Position.Y > br.Y then 
                fam.Position.Y = br.Y 
                if fam.Velocity.Y > 0 then fam.Velocity.Y = 0 end
            end

            local ge = GODMODE.room:GetGridEntityFromPos(fam.Position)
            if ge ~= nil and (ge:ToPoop() or ge:ToTNT()) then 
                ge:Destroy()
            end
            --fam.SpriteOffset = Vector(0,-600)
        end

        if fam:GetSprite():IsEventTriggered("End") then
            fam:Remove()
        end

        if fam:GetSprite():IsPlaying("Down") and fam:IsFrame(2,1) then
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_WHITE, 0, fam.Position, Vector(0,0),fam)
            creep:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            creep.CollisionDamage = 10.0
        end

        if fam:GetSprite():IsEventTriggered("Start") then
            if fam.SubType == 0 then
                if fam.HitPoints == 0 then
                    fam.HitPoints = 1
                    local e = Isaac.Spawn(monster.type, monster.variant, 1, player.Position, Vector(0,0), player)
                    e:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    e:GetSprite():Play("Downintro",true)
                end
                fam:GetSprite():Play("Up", true)
            else
                fam:GetSprite():Play("Down", true)
            end
        end

        if fam.FrameCount > 200-8*fam.SubType then
            if fam.SubType == 0 then
                fam:GetSprite():Play("Upexit", false)
            else
                fam:GetSprite():Play("Downexit", false)
            end
        end
    end
end

return monster