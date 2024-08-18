local monster = {}
monster.name = "Hush Heart (Pickup)"
monster.type = GODMODE.registry.entities.hush_heart.type
monster.variant = GODMODE.registry.entities.hush_heart.variant

monster.pickup_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    ent.Velocity = ent.Velocity * 0.97
    if ent.Velocity:Length() <= 0.1 then ent.Velocity = Vector.Zero end

    if sprite:IsFinished("Collect") then
        ent:Remove()
    elseif sprite:IsFinished("Appear") or not sprite:IsPlaying("Collect") then
        if not sprite:IsPlaying("Appear") then 
            sprite:Play("Idle",false)
        end
    end
    
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY

    -- GODMODE.log("hi!",true)

    if GODMODE.game:GetNumPlayers() == 1 and (Isaac.GetPlayer(0):GetPlayerType() == PlayerType.PLAYER_KEEPER or Isaac.GetPlayer(0):GetPlayerType() == PlayerType.PLAYER_KEEPER_B) then
        ent:Remove()
        for i=1,6 do
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR,FamiliarVariant.BLUE_FLY,0,ent.Position,Vector.Zero,Isaac.GetPlayer(0))
        end
    end
end

monster.pickup_init = function(self,ent)
    if GODMODE.util.is_mirror() and ent.Type == monster.type and ent.Variant == monster.variant then ent:Remove() end
    ent:GetSprite():Play("Appear",true)
end

monster.player_collide = function(self, player,ent,entfirst)
    if (ent.Type == monster.type and ent.Variant == monster.variant) then 
        -- GODMODE.log("hi",true)
        if ent:GetSprite():IsPlaying("Appear") or ent.FrameCount < 3 then
            return true
        end

        if not ent:GetSprite():IsPlaying("Collect") then
            if player:GetPlayerType() == PlayerType.PLAYER_KEEPER then
                ent:Remove()
                for i=1,6 do
                    Isaac.Spawn(EntityType.ENTITY_FAMILIAR,FamiliarVariant.BLUE_FLY,0,ent.Position,Vector.Zero,player)
                end
            elseif player:GetMaxHearts() + player:GetBrokenHearts() * 2 < 24 then
                player:AddMaxHearts(2)
            else 
                return false
            end

            ent:GetSprite():Play("Collect", true)
            GODMODE.sfx:Play(SoundEffect.SOUND_SUPERHOLY)
            GODMODE.sfx:Play(SoundEffect.SOUND_UNHOLY)
        end
        
        return true
    end
end

-- monster.use_item = function(self, coll,rng,player,flags,slot,var_data)
--     if coll == CollectibleType.COLLECTIBLE_D20 then
--         GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(item)
--             item:Remove()
--             Isaac.Spawn(EntityType.ENTITY_PICKUP,0,0,item.Position,Vector.Zero,item.SpawnerEntity)
--         end)
--     end
-- end

return monster