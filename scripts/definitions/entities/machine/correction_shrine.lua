local monster = {}
monster.name = "[GODMODE] Correction Shrine"
monster.type = GODMODE.registry.entities.correction_shrine.type
monster.variant = GODMODE.registry.entities.correction_shrine.variant

local render_spacing = 26
local bh_spacing = 26
local max_stat_types = 7 --stats that are buffable
local shrine_sprite_off = 6

local active_color = Color(1,1,1,1,0.8,0.8,0.8)
local active_radius = 128

monster.shrine_has = function(ent,item)
    GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(shrine) 
        if GetPtrHash(shrine) ~= GetPtrHash(ent) then 
            local data = GODMODE.get_ent_data(shrine)

            if data.buff and data.buff.type == "item" and data.buff.id == item then 
                return true
            end
        end
    end)
    
    return false 
end

monster.get_unique_item = function(ent,player,cache)
    local item = GODMODE.special_items:get_item_with_cache(cache,ent:GetDropRNG(),true)

    --if GODMODE.validate_rgon() is enabled, disable the correction shrines from giving you locked items
    local rep_unlock_flag = function(item) 
        if not GODMODE.validate_rgon() then return true else 
            local config = Isaac.GetItemConfig():GetCollectible(item)
            local gd = Isaac.GetPersistentGameData()
            return config and config:IsAvailable() and config:IsCollectible() and gd:Unlocked(config.AchievementID)
        end
    end

    while GODMODE.util.total_item_count(item) > 0 and not monster.shrine_has(ent,item) and rep_unlock_flag(item) do 
        item = GODMODE.special_items:get_item_with_cache(cache,ent:GetDropRNG(),true)
    end

    return item
end

local render_frame = {
    ["speed"] = 0,
    ["range"] = 1,
    ["firerate"] = 2,
    ["shotspeed"] = 3,
    ["damage"] = 4,
    ["luck"] = 5,
    ["health"] = 6,
}

local get_render_up_stat = function(ent)
    return math.floor(ent.SubType / 5)%6
end

monster.buff = {
    ["damage"] = function(ent,data,player) 
        data.buff = {type="item",id=monster.get_unique_item(ent,player,CacheFlag.CACHE_DAMAGE)}
    end,
    ["firerate"] = function(ent,data,player) 
        data.buff = {type="item",id=monster.get_unique_item(ent,player,CacheFlag.CACHE_FIREDELAY)}
    end,
    ["luck"] = function(ent,data,player) 
        data.buff = {type="item",id=monster.get_unique_item(ent,player,CacheFlag.CACHE_LUCK)}
    end,
    ["range"] = function(ent,data,player) 
        data.buff = {type="item",id=monster.get_unique_item(ent,player,CacheFlag.CACHE_RANGE)}
    end,
    ["shotspeed"] = function(ent,data,player) 
        data.buff = {type="item",id=monster.get_unique_item(ent,player,CacheFlag.CACHE_SHOTSPEED)}
    end,
    ["speed"] = function(ent,data,player) 
        data.buff = {type="item",id=monster.get_unique_item(ent,player,CacheFlag.CACHE_SPEED)}
    end,
    ["health"] = function(ent,data,player) 
        data.buff = {type="stat",val=2+ent:GetDropRNG():RandomInt(3)}
    end,
}

monster.spawn_fx = function(ent)
    ent:BloodExplode()

    for i=0,32 do 
        local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.COIN_PARTICLE, 0, 
            ent.Position+RandomVector():Resized(ent.Size)+Vector(0,-ent.Size/2), 
            RandomVector()*3, nil):ToEffect()
        fx:SetTimeout(10)
        fx.LifeSpan = 40
        fx.Scale = ent:GetDropRNG():RandomFloat() * 0.5 + 1.0
        fx:SetColor(Color(0,0,0,0.9),999,1,false,false)
        fx.DepthOffset = -100    
    end
    
    GODMODE.sfx:Play(SoundEffect.SOUND_BLOOD_LASER_LARGER,Options.SFXVolume*12,1,false,0.8)
    GODMODE.sfx:Play(SoundEffect.SOUND_DEATH_BURST_BONE,Options.SFXVolume*12,1,false,1)
end

monster.pickup_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    sprite:SetFrame("Stat_Bitfont",10)
    sprite.Rotation = ent.InitSeed % 360
    sprite.PlaybackSpeed = 0

    ent.Velocity = ent.Velocity * 0.1
    if ent.Velocity:Length() <= 0.1 then ent.Velocity = Vector.Zero end

    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    ent.SpriteOffset = Vector(0,-render_spacing / 2+4+shrine_sprite_off)
    ent.DepthOffset = 100
    data.fade_time = (data.fade_time or 0) + 1
    
    data.nearest_player = data.nearest_player or nil

    if data.nearest_player == nil or ent:IsFrame(10,1) then 
        local players = Isaac.FindInRadius(ent.Position,active_radius,EntityPartition.PLAYER)

        if #players > 0 then 
            local cur_closest = nil
            for _,player in ipairs(players) do 
                if cur_closest == nil 
                    or (ent.Position-cur_closest.Position):Length() > (ent.Position-player.Position):Length() then 
                    cur_closest = player
                end
            end

            data.nearest_player = cur_closest:ToPlayer()
        end
    elseif data.nearest_player ~= nil then
        local dist = (ent.Position - data.nearest_player.Position):Length() / active_radius
        local perc = math.min(1,math.max(0,1 - dist * 1.25))
        ent:SetColor(Color.Lerp(Color(1,1,1,math.min(1,(data.fade_time or 0) / 60.0)),active_color,perc),999,1,false,false)

        -- if dist > perc then 
        --     data.nearest_player = nil
        -- end
    end

    if true then--ent:IsFrame(2,1) then 
        local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, ent.Position+RandomVector():Resized(ent.Size * math.min(1,((data or {fade_time = 0}).fade_time or 0) / 60.0)), Vector.Zero, nil):ToEffect()
        fx:SetTimeout(10)
        fx.LifeSpan = 20
        fx.Scale = ent:GetDropRNG():RandomFloat() * 0.5 + 1.0
        fx:SetColor(Color(0,0,0,0.9),999,1,false,false)
        fx.DepthOffset = -100
    end

    -- set new deal
    if ent.State == 0 then 
        --pick random player
        local player = Isaac.GetPlayer(ent:GetDropRNG():RandomInt(GODMODE.game:GetNumPlayers())+1)
        local stats = GODMODE.util.get_stat_score(player)
    
        --random out of lowest 4 stats
        local ind = max_stat_types - ent:GetDropRNG():RandomInt(5)
        local sel_stat = stats.order[ind]
        local need = -(ind - max_stat_types)
    
        monster.buff[sel_stat](ent,data,player)
        data.buff.stat_type = sel_stat
        data.debuff = math.max(2,5 - need - ent:GetDropRNG():RandomInt(2))

        if data.buff.type == "item" then 
            local config = Isaac.GetItemConfig():GetCollectible(data.buff.id)
            data.debuff = math.max(data.debuff,math.min(4,1 + config.Quality))
        end
        
        ent.State = 1 
        monster.spawn_fx(ent)
        data.fade_time = 0
        data.replaced_second_sprite = false
    end

    -- execute deal
    if ent.State == 69 then 
        local player = data.player_target

        -- buff
        if data.buff then 
            if data.buff.type == "item" then 
                Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,data.buff.id,ent.Position,Vector.Zero,ent)
            elseif data.buff.type == "stat" then 
                if data.buff.stat_type == "health" then 
                    for i=1,data.buff.val do 
                        Isaac.Spawn(GODMODE.registry.entities.heart_container.type,GODMODE.registry.entities.heart_container.variant,0,ent.Position,RandomVector():Resized(1.5+RandomFloat()*2),nil)
                    end
                end
            end    
        end

        --debuff
        GODMODE.util.add_faithless(player, data.debuff)
        monster.spawn_fx(ent)
        GODMODE.game:MakeShockwave(ent.Position, 0.0375, 0.005, 20)
        player.Velocity = player.Velocity * 0.5 + (player.Position - ent.Position):Resized(6)
        ent:Remove()
    end
end

-- monster.player_init = function(self,player)
--     if player:GetPlayerType() == GODMODE.registry.players.t_gehazi and GetPtrHash(player) ~= GetPtrHash(Isaac.GetPlayer(0)) then 
--         monster.spawn_shrine(GODMODE.room,player)
--     end
-- end

monster.pickup_init = function(self,ent)
    if GODMODE.util.is_mirror() and ent.Type == monster.type and ent.Variant == monster.variant then ent:Remove() end
    ent:GetSprite():Play("Appear",true)
end

monster.player_collide = function(self, player,ent,entfirst)
    if (ent.Type == monster.type and ent.Variant == monster.variant) and player:GetBrokenHearts() < 12 then 
        if ent:GetSprite():IsPlaying("Appear") or ent.FrameCount < 3 then
            return true
        end

        ent = ent:ToPickup()

        if ent.State ~= 69 then 
            ent.State = 69
            GODMODE.get_ent_data(ent).player_target = player
        end
        
        return false
    end
end

monster.pickup_post_render = function(self,ent,offset)
    local data = GODMODE.get_ent_data(ent)

    if data.buff == nil then return end

    if data.second_sprite == nil then 
        data.second_sprite = Sprite()
        data.second_sprite:Load(ent:GetSprite():GetFilename(),true)
        data.second_sprite.PlaybackSpeed = 0
    end

    data.second_sprite.Offset = ent.SpriteOffset - Vector(0,shrine_sprite_off)
    -- ent:GetSprite().Color = Color(1,1,1,math.min(1,(data.fade_time or 0) / 60.0),ent:GetColor().RO,ent:GetColor().BO,ent:GetColor().GO)
    data.second_sprite.Color = Color(1,1,1,math.min(1,(data.fade_time or 0) / 60.0))

    if data.buff.type == "stat" then 
        local count = data.buff.val or 0
        local max_count = count
        local base_off = -12
        data.second_sprite:SetFrame("Stat_Bitfont",render_frame[data.buff.stat_type] or 1)
        -- draw sprites
        while count > 1 do 
            count = count - 1
            local off = math.rad((360 / max_count * count + (GODMODE.game:GetFrameCount() + ent.Index) * 6 + ent.Index * 30) % 360)
            local off_vec = Vector(math.cos(off),math.sin(off)):Resized(math.sin(math.rad(off-GODMODE.game:GetFrameCount()*12))*4+4)
            data.second_sprite.Color = Color(1,1,1,math.sin(off)*0.1+0.125)
            data.second_sprite:Render(Isaac.WorldToScreen(ent.Position
                +Vector(math.floor(count / 2) * -bh_spacing+base_off,
                        -count % 2 * bh_spacing)
                    +off_vec
                    ))
        end
        -- draw number
        data.second_sprite.Color = Color(1,1,1,math.min(1,(data.fade_time or 0) / 60.0))
        local pos = Isaac.WorldToScreen(ent.Position + Vector(-bh_spacing,8))
        data.second_sprite:Render(pos)
        data.second_sprite:SetFrame("Cost",max_count)
        data.second_sprite:Render(Vector(pos.X + -bh_spacing+34,pos.Y))
        -- Isaac.RenderScaledText("x"..max_count,pos.X + -bh_spacing+22,pos.Y-16,1.0,1.0,1,1,1,1)
    
    elseif data.buff.type == "item" then 
        if data.replaced_second_sprite ~= true then 
            local config = Isaac.GetItemConfig():GetCollectible(data.buff.id)
            data.second_sprite:ReplaceSpritesheet(1,config.GfxFileName)
            data.second_sprite:LoadGraphics()
            data.replaced_second_sprite = true
        end

        data.second_sprite:SetFrame("Item",ent.FrameCount % 20)
        data.second_sprite:Render(Isaac.WorldToScreen(ent.Position+Vector(-bh_spacing+4,29)))
    end

    --debuff
    data.second_sprite:SetFrame("Stat_Bitfont",7)
    local pos = Isaac.WorldToScreen(ent.Position + Vector(bh_spacing,8))
    local count = data.debuff 
    local death_flag = false 

    if data.nearest_player and data.nearest_player and data.nearest_player:GetBrokenHearts() + count >= 12 then 
        local dist = (ent.Position - data.nearest_player.Position):Length() / active_radius

        if dist <= 1 then 
            data.second_sprite:SetFrame("Stat_Bitfont",9)
            death_flag = true    
            count = 8
        end
    end

    local max_count = count
    local base_off = math.min(1,math.ceil(count / 2)) * bh_spacing / -4
    -- draw sprites
    while count > 1 do 
        count = count - 1
        local off = math.rad((360 / max_count * count + (GODMODE.game:GetFrameCount() + ent.Index) * 6 + 180 + ent.Index * 30) % 360)
        local off_vec = Vector(math.cos(off),math.sin(off)):Resized(math.sin(math.rad(math.deg(off)-(GODMODE.game:GetFrameCount() + ent.Index*20)*12))*8+6)

        if death_flag then 
            data.second_sprite.Scale = Vector(0.8+count*0.06125,0.8+count*0.06125)+Vector(math.cos(off),math.sin(off)):Resized(0.2)
            off_vec = off_vec + Vector(0,-8)
        end

        data.second_sprite.Color = Color(1,1,1,math.sin(off)*0.075+0.1)
        data.second_sprite:Render(Isaac.WorldToScreen(ent.Position
            +Vector(bh_spacing,--math.floor(count / 2) * bh_spacing+20,
                    8)---count % 2 * bh_spacing)
                +off_vec
                ))
    end

    -- draw number
    data.second_sprite.Scale = Vector(1,1)
    data.second_sprite.Color = Color(1,1,1,math.min(1,(data.fade_time or 0) / 60.0))
    local pos = Isaac.WorldToScreen(ent.Position + Vector(bh_spacing,8))
    data.second_sprite:Render(pos)

    if not death_flag then 
        data.second_sprite:SetFrame("Cost",max_count)
        data.second_sprite:Render(Vector(pos.X + bh_spacing-18,pos.Y))    
    end

    -- Isaac.RenderScaledText("x"..max_count,pos.X + bh_spacing-22,pos.Y-16,1.0,1.0,1,1,1,1)
end

monster.use_item = function(self, coll,rng,player,flags,slot,var_data)
    if coll == CollectibleType.COLLECTIBLE_D6 then
        GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(item)
            item:Remove()
            Isaac.Spawn(EntityType.ENTITY_PICKUP,0,0,item.Position,Vector.Zero,item.SpawnerEntity)
        end)
    end
end

return monster