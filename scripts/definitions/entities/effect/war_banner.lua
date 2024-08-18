local monster = {}
monster.name = "War Banner"
monster.type = GODMODE.registry.entities.war_banner.type
monster.variant = GODMODE.registry.entities.war_banner.variant

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

local sample_scale = 40
local sample_offs = {{1,0},{-1,0},{0,1},{0,-1},{0,0}}
local color_sample_scale = {0.9,1.25,1.3}

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    local anim = math.max(0,math.min(#monster.stats, ent.SubType))+1

    if ent.FrameCount == 1 or sprite:IsPlaying(monster.anims[anim].."Appear") then
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        sprite:Play(monster.anims[anim].."Appear", false)
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
    end

    data.start_pos = data.start_pos or ent.Position
    ent.Position = data.start_pos
    ent.Velocity = ent.Velocity * 0.5

    if sprite:IsFinished(monster.anims[anim].."Appear") then 
        sprite:Play(monster.anims[anim], true)
    end

    data.bff_flag = data.bff_flag or false
    if ent:IsFrame(30,1) and ent.SpawnerEntity ~= nil and ent.SpawnerEntity:ToPlayer() then 
        data.bff_flag = ent.SpawnerEntity:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
    end 

    if data.bff_flag then 
        data.target_scale = 1.0
        data.target_size = 124
    else
        data.target_scale = 0.75
        data.target_size = 88
    end

    if anim == 1 then 
        data.target_scale = math.max(1,data.target_scale * 0.75)
    end

    data.target_scale = data.target_scale or ent.Scale 
    data.target_size = data.target_size or ent.Size
    ent.Scale = (ent.Scale * 29 + data.target_scale) / 30.0
    ent.Size = (ent.Size * 29 + data.target_size) / 30.0


    if ent.SubType > 0 then 
        ent.DepthOffset = -100

        if GODMODE.validate_rgon() and ent:IsFrame(10,1) then 
            if data.floor_col_avg == nil then 
                local avg = 0
                for _,pos in ipairs(sample_offs) do 
                    local floor_col = GODMODE.util.get_floor_color(ent.Position + Vector(pos[1],pos[2]) * sample_scale)
                    avg = avg + (floor_col.R + floor_col.G + floor_col.B) / 3.0
                end
    
                avg = avg / #sample_offs
                data.floor_col_avg = Color(1,1,1,0.3 + avg*1.2*color_sample_scale[anim - 1])
            end
            
            ent:SetColor(data.floor_col_avg or Color(1,1,1,1), 20, 1, false, false)
        end

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

monster.player_collide = function(self,player,ent,entfirst,player_data)
    if ent.SubType > 0 then 
        local data = GODMODE.get_ent_data(ent)

        data.players = data.players or {}
        if data.players[GetPtrHash(player)] == nil then 
            data.players[GetPtrHash(player)] = player
            monster.stats[math.max(1,math.min(#monster.stats, ent.SubType))](player, player_data, 1)      
        end
    end

    return true
end

return monster