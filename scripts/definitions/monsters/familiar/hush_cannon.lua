local monster = {}
monster.name = "Hush Cannon"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.familiar_update = function(self, fam)
    if fam.Type == monster.type and fam.Variant == monster.variant then

        local player = fam.Player
        fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS

        if fam.SubType == 0 then
            fam.Position = player.Position
            fam.Velocity = Vector(0,0)
            fam.SpriteOffset = Vector(0,-28)

            if fam.FrameCount % 18 == 0 then
                player:PlayExtraAnimation("UseItem")
            end
            player.FireDelay = player.MaxFireDelay
        else
            local v = player:GetShootingJoystick()--Vector(math.sin(math.rad(d)), math.cos(math.rad(d)))
            fam.Velocity = fam.Velocity * 0.9 + v * 1.25
            local tl = Game():GetRoom():GetTopLeftPos()
            local br = Game():GetRoom():GetBottomRightPos()

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
            --fam.SpriteOffset = Vector(0,-600)
        end

        if fam:GetSprite():IsEventTriggered("End") then
            fam:Kill()
        end

        if fam:GetSprite():IsPlaying("Down") and fam:IsFrame(2,1) then
            local creep = Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_WHITE, fam.Position, Vector(0,0),fam, 0, fam.InitSeed)
            creep.CollisionDamage = 10.0
        end

        if fam:GetSprite():IsEventTriggered("Start") then
            if fam.SubType == 0 then
                if fam.HitPoints == 0 then
                    fam.HitPoints = 1
                    local e = Game():Spawn(monster.type, monster.variant, player.Position, Vector(0,0), player, 1, player.InitSeed)
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