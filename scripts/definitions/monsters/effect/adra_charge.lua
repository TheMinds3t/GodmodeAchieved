local monster = {}
monster.name = "Adramolech's Fuel"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, params)
    params[2].persistent_state = GODMODE.persistent_state.between_rooms
end

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    if ent.FrameCount == 1 then
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
        ent:GetSprite():Play("Charge",true)

        if ent.SubType == 1 then
            ent:GetSprite():ReplaceSpritesheet(1,"gfx/effects/adra_charge_red.png")
            ent:GetSprite():LoadGraphics()
        end
    end

    ent.DepthOffset = 100

    if data.player_target == nil then ent:Remove() end

    local player = data.player_target

    if player ~= nil and ent.FrameCount > (data.seek_time or 0) then 
        local len = (player.Position - ent.Position):Length()
        ent.Velocity = ent.Velocity * math.min(ent.FrameCount/15,0.95) + (player.Position - ent.Position):Resized(math.max(0,math.min(len,7)))
    end

    if ent:GetSprite():IsFinished("ChargeDisappear") then 
        ent:Remove()
    end
end

monster.player_collide = function(self,player,ent,entfirst)
    local data = GODMODE.get_ent_data(ent)
    if not data.collided and GetPtrHash(player) == GetPtrHash(data.player_target) and ent.FrameCount > (data.seek_time or 0) then 
        data.collided = true
        local kills = tonumber(GODMODE.save_manager.get_player_data(player,"AdraChampCounter","0")) + 1
        if ent.SubType == 1 then kills = kills + 3 end

        if kills < 4 then 
            SFXManager():Play(SoundEffect.SOUND_BEEP)
        end

        while kills >= 4 do
            local slot = GODMODE.util.get_active_slot(player, Isaac.GetItemIdByName("Adramolech's Blessing"))
            if slot == -1 then slot = GODMODE.util.get_active_slot(player, Isaac.GetItemIdByName("Adramolech's Fury")) end
            local charge = 1
            if (player:GetName() == "Xaphan") and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then charge = 2 end
            if player:GetActiveItem(slot) == Isaac.GetItemIdByName("Adramolech's Blessing") or player:GetActiveItem(slot) == Isaac.GetItemIdByName("Adramolech's Fury") then
                player:SetActiveCharge(player:GetActiveCharge(slot) + charge, slot)
                Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.BATTERY,0,player.Position-Vector(0,32),Vector.Zero,player)
                SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
                Game():GetHUD():FlashChargeBar(player, slot)

                if ent.SubType == 1 then 
                    player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SHOTSPEED)
                    player:EvaluateItems()            
                end
            end

            kills = kills - 4
        end

        ent.Velocity = ent.Velocity * 0.05
        if ent.SubType == 0 then
            GODMODE.save_manager.set_player_data(player,"AdraChampCounter",math.max(0,kills),true)
        end
        
        ent:GetSprite():Play("ChargeDisappear",false)
    end

    return true
end

return monster