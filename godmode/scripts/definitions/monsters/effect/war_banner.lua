local monster = {}
monster.name = "War Banner"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.anims = {"WarBanner", "AuraRed", "AuraBlue", "AuraYellow"}
monster.stats = {
    function(player, data, state)
		data.attack_banners = math.max(0,(data.attack_banners or 0) + 1*state)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()    
    end,
    function(player, data, state)
		data.speed_banners = math.max(0,(data.speed_banners or 0) + 1*state)
		player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()    
    end,
    function(player, data, state)
		data.shotspeed_banners = math.max(0,(data.shotspeed_banners or 0) + 1*state)
		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED)
		player:EvaluateItems()    
    end,
}

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    local anim = math.max(0,math.min(#monster.stats, ent.SubType))+1

    if ent.FrameCount == 1 or ent:GetSprite():IsPlaying(monster.anims[anim].."Appear") then
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        ent:GetSprite():Play(monster.anims[anim].."Appear", false)
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
    end

    data.start_pos = data.start_pos or ent.Position
    ent.Position = data.start_pos
    ent.Velocity = ent.Velocity * 0.5

    if ent:GetSprite():IsFinished(monster.anims[anim].."Appear") then 
        ent:GetSprite():Play(monster.anims[anim], true)
    end

    data.bff_flag = data.bff_flag or false
    if ent:IsFrame(30,1) and ent.SpawnerEntity ~= nil and ent.SpawnerEntity:ToPlayer() then 
        data.bff_flag = ent.SpawnerEntity:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
    end 

    if data.bff_flag then 
        data.target_scale = 1.5
        data.target_size = 80
    else
        data.target_scale = 1.333
        data.target_size = 64
    end

    data.target_scale = data.target_scale or ent.Scale 
    data.target_size = data.target_size or ent.Size
    ent.Scale = (ent.Scale * 29 + data.target_scale) / 30.0
    ent.Size = (ent.Size * 29 + data.target_size) / 30.0


    if ent.SubType > 0 then 
        ent.DepthOffset = -100

        data.players = data.players or {}
        for hash,player in pairs(data.players) do 
            if player then 
                local dist = (player.Position - ent.Position):Length()

                if dist > ent.Size then 
                    data.players[hash] = nil
                    monster.stats[math.max(1,math.min(#monster.stats, ent.SubType))](player, GODMODE.get_ent_data(player), -1)
                end
            end
        end
    end
end

monster.player_collide = function(self,player,ent,entfirst)
    if ent.SubType > 0 then 
        local data = GODMODE.get_ent_data(ent)

        data.players = data.players or {}
        if data.players[GetPtrHash(player)] == nil then 
            data.players[GetPtrHash(player)] = player
            monster.stats[math.max(1,math.min(#monster.stats, ent.SubType))](player, GODMODE.get_ent_data(player), 1)      
        end
    end

    return true
end

return monster