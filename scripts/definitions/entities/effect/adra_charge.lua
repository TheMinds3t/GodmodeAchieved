local monster = {}
monster.name = "Adramolech's Fuel"
monster.type = GODMODE.registry.entities.adramolechs_fuel.type
monster.variant = GODMODE.registry.entities.adramolechs_fuel.variant

local subtypes = {
    adra = 0,
    t_adra = 1,
    deli = 2
}

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        if ent.SubType ~= subtypes.t_adra then 
            data.persistent_state = GODMODE.persistent_state.between_rooms
        end
    end
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    if not sprite:IsPlaying("Charge") and ent.FrameCount < 3 then
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
        sprite:Play("Charge",true)

        if ent.SubType == 1 then
            sprite:ReplaceSpritesheet(1,"gfx/effects/adra_charge_red.png")
            sprite:LoadGraphics()
        end
    end

    ent.DepthOffset = 100
    local player = data.player_target
    local dir = (player.Position - ent.Position)
    local flag = player ~= nil and ent.FrameCount > (data.seek_time or 0)

    if ent.SubType == subtypes.t_adra then 
        flag = dir:Length() < player.Size * 8
        ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
    end

    if flag then 
        ent.Velocity = ent.Velocity * math.min(ent.FrameCount/15,0.95 - (ent.SubType == subtypes.t_adra and 0.05 or 0)) + dir:Resized(math.max(0,math.min(dir:Length(),7)))
    else 
        ent.Velocity = ent.Velocity * 0.9
    end

    if sprite:IsFinished("ChargeDisappear") then 
        ent:Remove()
    end

    if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
        ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
    end
end

local charge_collide_func = function(data,player,ent,entfirst)
    data.collided = true
    local kills = tonumber(GODMODE.save_manager.get_player_data(player,"AdraChampCounter","0")) + 1
    if ent.SubType == 1 then kills = kills + 3 end

    if kills < 4 then 
        GODMODE.sfx:Play(SoundEffect.SOUND_BEEP)
    end

    while kills >= 4 do
        local slot = GODMODE.util.get_active_slot(player, GODMODE.registry.items.adramolechs_blessing)
        if slot == -1 then slot = GODMODE.util.get_active_slot(player, GODMODE.registry.items.adramolechs_fury) end
        local charge = 1
        if (player:GetPlayerType() == GODMODE.registry.players.xaphan) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then charge = 2 end
        if player:GetActiveItem(slot) == GODMODE.registry.items.adramolechs_blessing or player:GetActiveItem(slot) == GODMODE.registry.items.adramolechs_fury then
            player:SetActiveCharge(player:GetActiveCharge(slot) + charge, slot)
            Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.BATTERY,0,player.Position-Vector(0,64),Vector.Zero,player)
            GODMODE.sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
            GODMODE.game:GetHUD():FlashChargeBar(player, slot)

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
        GODMODE.get_ent_data(player).adra_display = 100
        -- GODMODE.log("hi!",true)
    end
end

monster.collide_funcs = {
    [subtypes.adra] = charge_collide_func,
    [subtypes.t_adra] = charge_collide_func,
    [subtypes.deli] = function(data,player,ent,entfirst)
        local clamped_subtype = ent:ToNPC().State
        if clamped_subtype == 0 then clamped_subtype = 1 end
        local add = tonumber(GODMODE.save_manager.get_player_data(player,"DeliStat"..clamped_subtype,"0"))
        GODMODE.save_manager.set_player_data(player,"DeliStat"..clamped_subtype,add+0.5,true)
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
    end,
}

monster.player_collide = function(self,player,ent,entfirst)
    local data = GODMODE.get_ent_data(ent)
    if entfirst then 
        if not data.collided and GetPtrHash(player) == GetPtrHash(data.player_target) and ent.FrameCount > (data.seek_time or 0) and not ent:GetSprite():IsPlaying("ChargeDisappear") then 
            if monster.collide_funcs[ent.SubType] then 
                (monster.collide_funcs[ent.SubType] or monster.collide_funcs[subtypes.adra])(data,player,ent,entfirst)
            end
    
            if not ent:GetSprite():IsPlaying("ChargeDisappear") then
                ent:GetSprite():Play("ChargeDisappear",true)
            end
        end    
    end

    return true
end

return monster