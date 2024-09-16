local monster = {}
monster.name = "COTV (Correction Room)"
monster.type = GODMODE.registry.entities.cotv_correct.type
monster.variant = GODMODE.registry.entities.cotv_correct.variant
local scale_frames = 20
local dampen_change = 40
local bh_spacing = 24
local render_spacing = 26

monster.player_collide = function(self,ent2,ent,ent_first)
    if ent2:ToPlayer() then
        if ent_first and ent:GetSprite():IsPlaying("Idle") then 
            local data = GODMODE.get_ent_data(ent)
            if ent2:ToPlayer():GetBrokenHearts() >= 12 - (data.reroll_cost or 1) then 
                data.queue_laugh = true
            else
                if data.player_target == nil then 
                    data.player_target = ent2:ToPlayer()
                    ent:GetSprite():Play("Attack",true)
                end
            end
        end

        return false 
    end
end



monster.npc_update = function(self, ent, data, sprite)
    data.origin = data.origin or ent.Position
    ent.Velocity = ((data.origin or ent.Position) - ent.Position) / 4

    if sprite:IsFinished("Appear") or sprite:IsFinished("Attack") or sprite:IsFinished("Cackle") or sprite:IsFinished("Idle") then 
        if data.queue_laugh == true then 
            sprite:Play("Cackle",true)
            data.queue_laugh = false
        else
            sprite:Play("Idle",true)
        end

        data.has_triggered = false
    end

    if ent.Child == nil and ent:IsFrame(1,20) then 
        local scale = nil 

        GODMODE.util.macro_on_enemies(nil,GODMODE.registry.entities.silver_scale.type,GODMODE.registry.entities.silver_scale.variant,GODMODE.registry.entities.silver_scale.subtype,function(scl)
            scale = scl
        end)

        if scale == nil then 
            scale = Isaac.Spawn(GODMODE.registry.entities.silver_scale.type,GODMODE.registry.entities.silver_scale.variant,GODMODE.registry.entities.silver_scale.subtype,ent.Position+Vector(0,48),Vector.Zero,ent)
        end

        if scale ~= nil then 
            ent.Child = scale 
            scale.Parent = ent
        end
    end
    
    if ent.Child ~= nil then 
        local scale = ent.Child:ToNPC()

        if ent:IsFrame(18,20) then 
            local old = data.cur_scale_lvl
            data.cur_scale_lvl = GODMODE.util.calc_broken_perc()
            if data.cur_scale_lvl > (old or 1) then 
                data.queue_laugh = true 
            end
        end

        data.display_scale_lvl = ((data.display_scale_lvl or 1) * (dampen_change - 1) + (data.cur_scale_lvl or 1)) / dampen_change
        scale:GetSprite():SetFrame("Judge",math.max(1,scale_frames - math.floor(data.display_scale_lvl * scale_frames)))

        if ent:IsFrame(8,1) and ent:GetDropRNG():RandomFloat() < (data.cur_scale_lvl or 0) then 
            local fx = Isaac.Spawn(GODMODE.registry.entities.correction_hand.type, GODMODE.registry.entities.correction_hand.variant, GODMODE.registry.entities.correction_hand.subtype, 
                GODMODE.room:GetCenterPos()
                +RandomVector():Resized(128)*Vector(3,2), Vector.Zero, nil)

            local targ = GODMODE.room:GetCenterPos()
            fx:GetSprite().Rotation = (targ - fx.Position):GetAngleDegrees() + 90
            
            local scale = fx:GetDropRNG():RandomFloat() * 0.5 + 0.0
            fx:GetSprite().Scale = Vector(scale,scale)
        end
    end


    if sprite:IsEventTriggered("Attack") and data.has_triggered ~= true then 
        GODMODE.util.macro_on_enemies(nil,GODMODE.registry.entities.correction_shrine.type,GODMODE.registry.entities.correction_shrine.variant,-1,function(shrine)
            shrine = shrine:ToPickup()
            shrine.State = 0
        end)

        for i=0,32 do 
            local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.COIN_PARTICLE, 0, 
                ent.Position+RandomVector():Resized(ent.Size)+Vector(0,-ent.Size/2), 
                RandomVector()*3, nil):ToEffect()
            fx:SetTimeout(10)
            fx.LifeSpan = 40
            fx.Scale = ent:GetDropRNG():RandomFloat() * 0.5 + 1.0
            fx:SetColor(Color(0,0,0,1),999,1,false,false)
            fx.DepthOffset = -100    
        end
        
        GODMODE.game:MakeShockwave(ent.Position, 0.0375, 0.005, 20)    
        GODMODE.sfx:Play(SoundEffect.SOUND_BLOOD_LASER_LARGER,Options.SFXVolume*12,1,false,0.8)
        GODMODE.sfx:Play(SoundEffect.SOUND_DEATH_BURST_BONE,Options.SFXVolume*12,1,false,1)
        GODMODE.util.add_faithless(data.player_target:ToPlayer() or ent:GetPlayerTarget():ToPlayer(),data.reroll_cost or 1)    
        data.reroll_cost = (data.reroll_cost or 1) + 1
        data.has_triggered = true
        data.player_target = nil

        GODMODE.util.macro_on_players(function(player) 
            local dir = (player.Position - ent.Position)
            local perc = math.min(1,dir:Length() / 52.0)
            player.Velocity = player.Velocity * (1 - perc) + dir:Resized(6 * perc)
        end)
    end

    -- audio
    if sprite:IsEventTriggered("SFX") then
        GODMODE.sfx:Play(SoundEffect.SOUND_BLACK_POOF,1,2,false,0.5)
        GODMODE.sfx:Play(SoundEffect.SOUND_MAW_OF_VOID,1,2,false,0.75)
    end

    if sprite:IsEventTriggered("SFX2") then
        if sprite:IsPlaying("Attack") or sprite:IsPlaying("Cackle") then
            local pitch = 0.5
            if sprite:IsPlaying("Attack") then
                GODMODE.game:ShakeScreen(5)
            else pitch = 0.75 end

            if ent:GetDropRNG():RandomInt(2) == 1 then
                GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A,1,2,false,pitch)
            else
                GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_YELL_B,1,2,false,pitch)
            end    
        else
            GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_0,1,2,false,0.5)
        end
    end

    if sprite:IsPlaying("Attack") or sprite:IsPlaying("Cackle") then 
        data.opacity = math.min(1,(data.opacity or 1) + 0.05)
    end

    data.opacity = ((data.opacity or 1) * 19.0 + math.cos(ent.FrameCount / 20) * 0.15 + 0.7) / 20.0
    ent:SetColor(Color(data.opacity,data.opacity,data.opacity,data.opacity),999,999,false,false)

    if true then--ent:IsFrame(2,1) then 
        local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, ent.Position+RandomVector():Resized(ent.Size), Vector.Zero, nil):ToEffect()
        fx:SetTimeout(10)
        fx.LifeSpan = 20
        fx.Scale = ent:GetDropRNG():RandomFloat() * 0.5 + 1.0
        fx:SetColor(Color(0,0,0,1),999,1,false,false)
        fx.DepthOffset = -100
    end

    if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
        ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
    end
end

monster.npc_post_render = function(self,ent,offset)
    local data = GODMODE.get_ent_data(ent)

    if data.second_sprite == nil then 
        data.second_sprite = Sprite()
        data.second_sprite:Load("gfx/grid/fatal_attraction.anm2",true)
        data.second_sprite.PlaybackSpeed = 0
    end

    --debuff
    data.second_sprite.Color = Color(1,1,1,1)
    data.second_sprite.Offset = ent.SpriteOffset

    local pos = Isaac.WorldToScreen(ent.Position + Vector(-bh_spacing,-2))
    data.second_sprite:SetFrame("Stat_Bitfont",8)
    data.second_sprite:Render(pos)

    data.second_sprite:SetFrame("Stat_Bitfont",7)

    local count = data.reroll_cost or 1 
    local max_count = count
    local base_off = math.min(1,math.ceil(count / 2)) * bh_spacing / -4
    -- draw sprites
    while count > 1 do 
        count = count - 1
        local off = math.rad((360 / max_count * count + (GODMODE.game:GetFrameCount() + ent.Index) * 6 + 180 + ent.Index * 30) % 360)

        local off_vec = Vector(math.cos(off),math.sin(off)):Resized(math.abs(math.sin(math.rad(math.deg(off)-(GODMODE.game:GetFrameCount() + ent.Index)*12))*4+2))
        
        data.second_sprite.Color = Color(1,1,1,math.sin(off)*0.15+0.2)
        data.second_sprite:Render(Isaac.WorldToScreen(ent.Position
            +Vector(math.floor(count / 2) * bh_spacing+20,
                    -count % 2 * bh_spacing-8)
                +off_vec
                ))
    end

    -- draw number
    data.second_sprite.Color = Color(1,1,1,1)
    pos = Isaac.WorldToScreen(ent.Position + Vector(bh_spacing,0))
    data.second_sprite:Render(pos)
    data.second_sprite:SetFrame("Cost",max_count)
    data.second_sprite:Render(Vector(pos.X + bh_spacing-18,pos.Y))
    -- Isaac.RenderScaledText("x"..max_count,pos.X + bh_spacing-20,pos.Y-8,1.0,1.0,1,1,1,1)
end

return monster