local monster = {}
monster.name = "Heart Container (Pickup)"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

-- monster.data_init = function(self, params)
--     local ent = params[1]
--     local data = params[2]
--     -- data.persistent_state = GODMODE.persistent_state.single_room
--     ent.SplatColor = Color(0,0,0,0,0,0,0)
--     ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_PLAYER_CONTROL )
--     -- ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
-- end

monster.pickup_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    ent.Velocity = ent.Velocity * 0.97
    if ent.Velocity:Length() <= 0.1 then ent.Velocity = Vector.Zero end

    if ent:GetSprite():IsFinished("Collect") then
        ent:Remove()
    elseif ent:GetSprite():IsFinished("Appear") or not ent:GetSprite():IsPlaying("Collect") then
        if not ent:GetSprite():IsPlaying("Appear") then 
            ent:GetSprite():Play("Idle",false)
        end
    end
    
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY

    -- GODMODE.log("hi!",true)

    if Game():GetNumPlayers() == 1 and Isaac.GetPlayer(0):GetName() == "Keeper" then
        ent:Remove()
        for i=1,6 do
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR,FamiliarVariant.BLUE_FLY,0,ent.Position,Vector.Zero,Isaac.GetPlayer(0))
        end
    end
end

-- monster.new_room = function(self)
--     GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,-1,function(ent)
--         if ent.FrameCount > 5 then
--             ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
--         end
--     end)
-- end

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
            if player:GetName() == "Keeper" then
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
            SFXManager():Play(SoundEffect.SOUND_SUPERHOLY)
            SFXManager():Play(SoundEffect.SOUND_UNHOLY)
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