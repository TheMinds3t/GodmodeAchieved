local monster = {}
-- monster.data gets updated every callback
monster.name = "Callen Skull"
monster.type = GODMODE.registry.entities.callen_skull.type
monster.variant = GODMODE.registry.entities.callen_skull.variant


monster.sprite = Sprite()
monster.sprite:Load("gfx/45_callen_skull.anm2", true)

local min_speed = 0.9
local max_speed = 2
local effect_radius = 6

local callen_skull_effect = 60
local effect_decay = 0.25

local haemo_off = Vector(0,-20)

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()
    
    if sprite:IsFinished("Appear") then
        sprite:Play("Back",false)
        sprite:PlayOverlay("Idle",false)
    end

    local dir = player.Position - ent.Position
    local p_data = GODMODE.get_ent_data(player)
    local fx_val = p_data.callen_skull

    if dir:Length() > player.Size * effect_radius then 
        ent.Velocity = ent.Velocity * (1/3) + dir:Resized(math.min(math.max(min_speed,dir:Length()*(1/120)),max_speed))
        ent.I1 = math.max(math.floor(p_data.callen_skull or 0),ent.I1 - 3)

    else
        ent.Velocity = ent.Velocity * 0.95
        p_data.callen_skull = math.min((p_data.callen_skull or 0) + 1+effect_decay, callen_skull_effect+1)
        ent.I1 = math.min(callen_skull_effect*3, math.max(ent.I1 + 3,math.floor(p_data.callen_skull or 0)))
    end

    if ent:IsFrame(2,1) then 
        local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, ent.Position+RandomVector():Resized(ent.Size), Vector.Zero, nil):ToEffect()
        fx:SetTimeout(10)
        fx.LifeSpan = 20
        fx.Scale = ent:GetDropRNG():RandomFloat() * 0.5 + 1.0
        fx:SetColor(Color(0,0,0,0.8),999,1,false,false)
        fx.DepthOffset = -100
        fx.SpriteOffset = haemo_off
    end

    if ent.I2 > 0 then 
        ent.I2 = ent.I2 - 1
        for i=1,16-(ent.I2) do 
            local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, ent.Position+RandomVector():Resized(ent.Size), RandomVector():Resized(4-ent:GetDropRNG():RandomFloat()*6+ent.I2*2), nil):ToEffect()
            fx:SetTimeout(13)
            fx.LifeSpan = 20
            fx.Scale = ent:GetDropRNG():RandomFloat() * 0.5 + 1.0
            fx:SetColor(Color(0,0,0,0.8),999,1,false,false)
            fx.DepthOffset = 100
            fx.SpriteOffset = haemo_off
            fx:Update() fx:Update() fx:Update()
        end

        if ent.I2 == 3 then --push
            GODMODE.game:MakeShockwave(ent.Position+haemo_off, 0.0375, 0.005, 20)
            GODMODE.sfx:Play(SoundEffect.SOUND_BLOOD_LASER_LARGER,Options.SFXVolume*12,1,false,0.8)

            player.Velocity = player.Velocity * 0.5 + (dir:Resized(6))
        end
    end
end

monster.npc_post_render = function(self, ent, offset)
    monster.sprite:SetFrame(ent:GetSprite():GetOverlayAnimation().."Shadow",ent:GetSprite():GetFrame())
    local perc = math.min(ent.I1 / callen_skull_effect, 1)
    local r_perc = 1.0 - math.min(ent.I1 / callen_skull_effect, 3) / 3
    monster.sprite.Color = Color(1,r_perc,r_perc,perc*0.9)
    monster.sprite:Render(Isaac.WorldToScreen(ent.Position))
end

monster.player_update = function(self, player, data)

    if data.callen_skull ~= nil then 
        data.callen_skull = math.max(data.callen_skull - effect_decay, 0)
        if data.callen_skull >= callen_skull_effect then 
            player:AddBrokenHearts(1)
            data.callen_skull = nil
            GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(skull)
                skull = skull:ToNPC()
                skull.I1 = 0
                skull.I2 = 4
            end)

            if player:GetBrokenHearts() >= 12 then 
                player:Die()
            end
        elseif data.callen_skull <= 0 then 
            data.callen_skull = nil
        end
    end
end

return monster