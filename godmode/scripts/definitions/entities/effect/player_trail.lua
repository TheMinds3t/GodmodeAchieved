local monster = {}
monster.name = "Player Trail FX"
monster.type = GODMODE.registry.entities.player_trail_fx.type
monster.variant = GODMODE.registry.entities.player_trail_fx.variant

local far_color = Color(0.15,0,0,0.25)
local base_color = Color(0,0,0,0)
local trail_merge_speed = 70

local xaphan_layers = {
    [4] = "gfx/costumes/xaphan_head_tainted.png",
    [1] = "gfx/costumes/xaphan_body_tainted.png",
}

monster.effect_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
   
    if ent.Timeout == -1 then 
        if ent.SpawnerEntity ~= nil and ent.SpawnerEntity:ToPlayer() then 
            ent.State = math.max(100,tonumber(GODMODE.save_manager.get_config("TXaphanTrail", "7"))*10)
        end
        ent.Timeout = ent.State
    end

    local spawner = ent.SpawnerEntity or ent 
    local min_range = spawner.Size * 0.75
    local max_range = spawner.Size * 4
    local life_perc = ent.Timeout / (ent.State + 1)
    ent.State = math.min(1,ent.State)
    local off = Vector(1.1,1.1)*life_perc

    if data.stationary ~= true then 
        off = (ent.Position - spawner.Position - spawner.Velocity*2)/52
        ent.Velocity = ent.Velocity * 0.8 + (spawner.Position - ent.Position) / trail_merge_speed
    end

    local perc = math.min(1,math.max(0,off:Length()-0.1))
    local xaphan_flag = spawner:ToPlayer() and spawner:ToPlayer():GetPlayerType() == GODMODE.registry.players.t_xaphan

    if data.effect_init == false then 
        ent:GetSprite():Load(spawner:GetSprite():GetFilename(),true)
        if xaphan_flag then 
            ent:GetSprite():ReplaceSpritesheet(1,"gfx/characters/xaphan_tainted/xaphan_grey.png")
            ent:GetSprite():ReplaceSpritesheet(4,"gfx/characters/xaphan_tainted/xaphan_grey.png")
            ent:GetSprite():LoadGraphics()
        end
        data.effect_init = true
    end

    sprite.Color = far_color--Color.Lerp(base_color,data.far_color or far_color,perc*life_perc)
    if xaphan_flag then 
        local spawner_sprite = spawner:GetSprite() 
        sprite:SetFrame(spawner_sprite:GetAnimation(),spawner_sprite:GetFrame())
        sprite:SetOverlayFrame(spawner_sprite:GetOverlayAnimation(),spawner_sprite:GetOverlayFrame())
        -- GODMODE.log("new spritesheet is "..spawner_sprite:GetFilename().." playing \'"..spawner_sprite:GetAnimation().."\'!",true)
    end

    local dist = (ent.Position - spawner.Position):Length() / 4

    if dist > 4 then 
        ent.Timeout = ent.Timeout - (math.floor(dist / 2) - 4)
    end

    ent.DepthOffset = 100
    ent.Velocity = ent.Velocity * 0.8

    if ent.Timeout <= 0 then
        ent:Remove()
    end
end

return monster