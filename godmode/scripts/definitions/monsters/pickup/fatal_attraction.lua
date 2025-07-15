local monster = {}
monster.name = "Fatal Attraction Helper"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

local stat_up_mod = 0.1
local stat_down_mod = 0.075
local render_spacing = 26

local stats = {
    CacheFlag.CACHE_SPEED,
    CacheFlag.CACHE_RANGE,
    CacheFlag.CACHE_FIREDELAY,
    CacheFlag.CACHE_SHOTSPEED,
    CacheFlag.CACHE_DAMAGE,
    CacheFlag.CACHE_LUCK
}

local render_frame = {
    [CacheFlag.CACHE_SPEED] = 0,
    [CacheFlag.CACHE_RANGE] = 1,
    [CacheFlag.CACHE_FIREDELAY] = 2,
    [CacheFlag.CACHE_SHOTSPEED] = 3,
    [CacheFlag.CACHE_DAMAGE] = 4,
    [CacheFlag.CACHE_LUCK] = 5,
}

local get_render_up_stat = function(ent)
    return math.floor(ent.SubType / 5)%6
end

local get_render_down_stat = function(ent)
    local stat = (ent.SubType) % 5
    if stat >= get_render_up_stat(ent) then
        stat = (stat + 1) % 6
    end
    return stat
end

monster.eval_cache = function(self, player,cache)
    if render_frame[cache] ~= nil then 
        local mod = tonumber(GODMODE.save_manager.get_player_data(player,"FAStat"..cache,"0"))

        GODMODE.util.modify_stat(player,cache,1.0+mod,true)
    end
end

monster.pickup_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    ent.Velocity = ent.Velocity * 0.1
    ent:GetSprite():SetFrame("Stat_Bitfont",7)
    ent:GetSprite().PlaybackSpeed = 0
    if ent.Velocity:Length() <= 0.1 then ent.Velocity = Vector.Zero end
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    ent.SpriteOffset = Vector(0,-render_spacing / 2+4)
    ent.DepthOffset = 100

    if true then--ent:IsFrame(2,1) then 
        local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, ent.Position+RandomVector():Resized(ent.Size), Vector.Zero, nil):ToEffect()
        fx:SetTimeout(10)
        fx.LifeSpan = 20
        fx.Scale = ent:GetDropRNG():RandomFloat() * 0.5 + 1.0
        fx:SetColor(Color(0,0,0,1),999,1,false,false)
        fx.DepthOffset = -100
    end
end

monster.pickup_post_render = function(self,ent,offset)
    local data = GODMODE.get_ent_data(ent)

    if data.second_sprite == nil then 
        data.second_sprite = Sprite()
        data.second_sprite:Load(ent:GetSprite():GetFilename(),true)
        data.second_sprite.PlaybackSpeed = 0
    end

    data.second_sprite.Offset = ent.SpriteOffset

    ent:GetSprite():SetFrame("Stat_Mod",0)
    ent:GetSprite():Render(Isaac.WorldToScreen(ent.Position))
    data.second_sprite:SetFrame("Stat_Bitfont",get_render_up_stat(ent))
    data.second_sprite:Render(Isaac.WorldToScreen(ent.Position))
    data.second_sprite:SetFrame("Stat_Mod",1)
    data.second_sprite:Render(Isaac.WorldToScreen(ent.Position+Vector(0,render_spacing)))
    data.second_sprite:SetFrame("Stat_Bitfont",get_render_down_stat(ent))
    data.second_sprite:Render(Isaac.WorldToScreen(ent.Position+Vector(0,render_spacing)))
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
end

monster.player_collide = function(self, player,ent,entfirst)
    if (ent.Type == monster.type and ent.Variant == monster.variant) then 
        ent = ent:ToPickup()
        if ent.State == 0 then
            local up_key = "FAStat"..stats[get_render_up_stat(ent)+1]
            local down_key = "FAStat"..stats[get_render_down_stat(ent)+1]
            GODMODE.save_manager.set_player_data(player,up_key,tonumber(GODMODE.save_manager.get_player_data(player,up_key,"0"))+stat_up_mod)
            GODMODE.save_manager.set_player_data(player,down_key,tonumber(GODMODE.save_manager.get_player_data(player,down_key,"0"))-stat_down_mod,true)
            player:AddCacheFlags(stats[get_render_up_stat(ent)+1] | stats[get_render_down_stat(ent)+1])
            player:EvaluateItems()
            SFXManager():Play(SoundEffect.SOUND_HOLY,1,2,false,0.5)
            SFXManager():Play(SoundEffect.SOUND_FIREDEATH_HISS,1,2,false,0.85)
            SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE,1,2,false,0.85)
            Game():ShakeScreen(10)


            GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(choice) 
                choice:Remove() 
                local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, choice.Position, Vector.Zero, nil) 
                fx:SetColor(Color(0,0,0,1),999,1,false,false)
                
            end)
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