local monster = {}
monster.name = "Delirious Halo"
monster.type = GODMODE.registry.entities.deli_halo.type
monster.variant = GODMODE.registry.entities.deli_halo.variant

local bounce_strength = 32
local bounce_strength_proj = 16
local bounce_anim_length = 10
local max_bounce_anim = 30
local bounce_size = 0.05
local bounce_dampen = 3

local num_eyes = 16
local start_layer = 1
-- local min_eye_dist = 65
-- local max_eye_dist = 68
-- local cached_eyesets = {}

-- local eye_frames = 18
local eye_sprite = Sprite()
eye_sprite:Load("gfx/famil_delihalo_static.anm2",true)
eye_sprite:Play("Eyes",true)

local ring_sway_ang = 90
local ring_sway_speed = 0.5

-- for dynamic eye placement
-- local get_eye_positions = function(ent)
--     if cached_eyesets[ent.InitSeed] then 
--         return cached_eyesets[ent.InitSeed]
--     else
--         local max_range = 360 / (num_eyes * 1.2)
--         local ret = {}
    
--         for i=0,num_eyes - 1 do 
--             local ang = math.rad(i * (360/num_eyes) + max_range / 2.0 + (ent.InitSeed + i * 20) % (max_range / 2.0))
--             local dist = (ent.InitSeed - i * 27.5) % (max_eye_dist - min_eye_dist) + min_eye_dist
--             table.insert(ret, Vector(math.cos(ang) * dist,math.sin(ang) * dist))
--         end

--         cached_eyesets[ent.InitSeed] = ret
--         return ret
--     end
-- end

local blink_time = 6
local num_blinking = 3

local deli_tear_rotate_ang = 360/100
local max_immune_frames = 15

local is_eye_closed = function(eye, fam)
    return tonumber(GODMODE.save_manager.get_player_data(fam.Player,"EyesOpen",num_eyes)) < eye
end

monster.br_splash = function(self, fam)
    local count = 16 
    local slice = (360 / count)
    
    for i=1,count do 
        local direction = slice * i + (fam:GetDropRNG():RandomFloat() - 0.5) * 0.2 * slice
        local tear = fam:FireProjectile(Vector(0,1):Rotated(direction):Resized(0.5 + fam:GetDropRNG():RandomFloat()*0.25))
        tear.Height = tear.Height + fam:GetDropRNG():RandomInt(10)
        tear:AddTearFlags(TearFlags.TEAR_BONE)
        tear:SetWaitFrames(fam:GetDropRNG():RandomInt(10))
        tear.FallingSpeed = -8 + fam:GetDropRNG():RandomInt(2)
        tear.FallingAcceleration = 1.25 - fam:GetDropRNG():RandomFloat() * 0.2
        tear.CollisionDamage = 5
        tear.Scale = 1.2 + fam:GetDropRNG():RandomFloat() * 0.3
    end
end

monster.familiar_update = function(self, fam, data)
    local player = fam.Player
    fam.Velocity = (player.Position - fam.Position)
    fam.SpriteOffset = Vector(0,-8)

    if fam:GetSprite():IsFinished("Halo") then 
        fam:GetSprite():Play("Halo",true)
        GODMODE.get_ent_data(player).halo = fam
    end

    if fam.State > 0 then 
        fam.State = fam.State - 1
    end

    --anim cooldown
    if fam.Hearts > 0 then 
        fam.Hearts = fam.Hearts - 1
    end

    --immunity frames
    if fam.Coins > 0 then 
        fam.Coins = fam.Coins - 1
        fam.Color = Color(fam.Color.R,fam.Color.G,fam.Color.B,fam.Color.A,fam.Coins / max_immune_frames, fam.Coins / max_immune_frames, fam.Coins / max_immune_frames)
    end

    local pd = GODMODE.get_ent_data(player)

    if (pd.t_deli_immune or 0) > 0 then 
        pd.t_deli_immune = pd.t_deli_immune - 1 
        fam.Color = Color(fam.Color.R,fam.Color.G,fam.Color.B,((pd.t_deli_immune or 0) % 8 < 4 and 1 or 0))
    end

    local eyes = tonumber(GODMODE.save_manager.get_player_data(fam.Player,"EyesOpen",num_eyes))

    if eyes == 0 or GODMODE.save_manager.get_player_data(fam.Player,"RingHidden","false") == "true" then fam.Keys = 0 else fam.Keys = 1 end

    local anim_rad = math.rad((fam.State % bounce_anim_length) * (360 / bounce_anim_length) + (fam.FrameCount * 6) % 360)
    local anim_size = fam.State / bounce_anim_length * bounce_size + 0.01
    data.real_anim_size = ((data.real_anim_size or 0) * (bounce_dampen - 1) + anim_size) / bounce_dampen
    data.br = (data.br == nil or fam:IsFrame(20,1)) and player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHRIGHT) or data.br
    
    -- toggle hidden
    if fam.Keys == 0 then 
        -- BR splash
        if data.br > 0 and data.real_scale > 0.9 then
            monster.br_splash(self,fam)
            data.real_scale = 0.9
        end

        data.real_scale = ((data.real_scale or 1) * (bounce_dampen - 1) + 0) / bounce_dampen
    else
        -- BR splash
        if data.br > 0 and data.real_scale < 0.01 then
            monster.br_splash(self,fam)
            data.real_scale = 0.01
        end

        data.real_scale = ((data.real_scale or 1) * (bounce_dampen - 1) + 1) / bounce_dampen
    end

    fam:GetSprite().Scale = Vector((data.real_scale or 1) + math.cos(anim_rad)*data.real_anim_size,(data.real_scale or 1) + math.sin(anim_rad)*data.real_anim_size)
    fam:GetSprite().Rotation = math.cos(math.rad((fam.FrameCount * ring_sway_speed) % 360))*ring_sway_ang
    fam.Visible = (data.real_scale or 1) > 0.1
end

monster.familiar_collide = function(self, fam, ent, entfirst)
    if fam.Type == monster.type and fam.Variant == monster.variant and (ent:IsVulnerableEnemy() or ent:ToProjectile()) and fam.Keys > 0 then
        local eyes = tonumber(GODMODE.save_manager.get_player_data(fam.Player,"EyesOpen",num_eyes))

        if eyes > 0 then 
            ent.Velocity = (ent.Position - fam.Player.Position):Resized(ent:ToProjectile() and bounce_strength_proj or bounce_strength)

            if fam.Hearts <= 0 then 
                local amt = math.ceil(ent.CollisionDamage * 1.5)
                fam.State = math.min(max_bounce_anim,fam.State + bounce_anim_length * amt)

                if fam.Coins <= 0 then 
                    GODMODE.save_manager.set_player_data(fam.Player,"EyesOpen", math.max((eyes == 1 and 0 or 1),eyes - amt), true)
                    fam.Coins = 5
                end

                GODMODE.sfx:Play(SoundEffect.SOUND_MEATY_DEATHS,Options.SFXVolume*1.5+0.75)

                if eyes - amt <= 0 then 
                    fam:BloodExplode()

                    if fam.Player:HasCollectible(GODMODE.registry.items.deli_oblivion) then 
                        fam.Player:UseActiveItem(GODMODE.registry.items.deli_oblivion,0,ActiveSlot.SLOT_POCKET)
                    end
                end
            end

            if ent:ToProjectile() then 
                ent:ToProjectile():AddProjectileFlags(ProjectileFlags.HIT_ENEMIES | ProjectileFlags.CANT_HIT_PLAYER)
            else 
                ent:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK | EntityFlag.FLAG_APPLY_IMPACT_DAMAGE)
                ent:TakeDamage((fam.Player.Damage * 2 + 1) * (fam.Coins > 0 and fam.Coins / max_immune_frames or 1),0,EntityRef(fam.Player),0)
            end

            ent.CollisionDamage = fam.Player.Damage * 2 + 10
            fam.Hearts = bounce_anim_length

            return true    
        end
    end
end

monster.famil_post_render = function(self, fam, off)
    -- local eyeset = get_eye_positions(fam)

    -- for i,vec in ipairs(eyeset) do 
    --     vec = Vector(vec.X * fam:GetSprite().Scale.X,vec.Y * fam:GetSprite().Scale.Y)
    --     local pos = Isaac.WorldToScreen(fam.Position + fam.SpriteOffset + vec:Rotated(fam:GetSprite().Rotation))
    --     eye_sprite:SetFrame("Eye",math.floor((GODMODE.game:GetFrameCount() + i * 6) / 2) % eye_frames)
    --     eye_sprite:Render(pos)
    -- end

    if fam.Visible then 
        eye_sprite.Rotation = fam:GetSprite().Rotation
        local base_col = fam:GetSprite().Color
        eye_sprite.Color = base_col
        eye_sprite.Scale = fam:GetSprite().Scale
        eye_sprite.Offset = fam:GetSprite().Offset
        local pos = Isaac.WorldToScreen(fam.Position)
        eye_sprite:RenderLayer(1,pos)
    
        for i=1,num_eyes do 
            local blinking = (GODMODE.game:GetFrameCount() + blink_time * i + i) % (num_eyes * blink_time / num_blinking)
            
            if is_eye_closed(i, fam) then 
                eye_sprite.Color = base_col
                eye_sprite:RenderLayer(start_layer + i,pos)
            elseif blinking <= blink_time then
                local perc = 1 - (math.abs(blinking - blink_time / 2) + blink_time / 2) / blink_time
                eye_sprite.Color = Color(base_col.R,base_col.G,base_col.B,base_col.A * perc * 2)
                eye_sprite:RenderLayer(start_layer + i,pos)
            end
        end    
    end
end

monster.room_rewards = function(self, rng, pos)
    GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(ring) 
        ring = ring:ToFamiliar()
        GODMODE.save_manager.set_player_data(ring.Player,"EyesOpen",math.min(num_eyes, tonumber(GODMODE.save_manager.get_player_data(ring.Player,"EyesOpen",num_eyes)) + 1), true)
        ring.Player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED)
        ring.Player:EvaluateItems()
    end)
end

monster.tear_update = function(self, tear, data)
    if data and data.deli_rotate ~= nil then 
        local ang_off = data.deli_rotate and deli_tear_rotate_ang or -deli_tear_rotate_ang
        tear.Velocity = tear.Velocity:Rotated(math.cos(math.rad(tear.FrameCount * (10 + tear.Velocity:Length()))) * ang_off)

        if data.col_mod ~= true then 
            data.col_mod = true 
            local new_size = 1 + deli_tear_rotate_ang / 360 * 2 
            tear.SizeMulti = tear.SizeMulti * Vector(new_size,new_size)
        end
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown) 

    if enthit:ToPlayer() then 
        local player = enthit:ToPlayer()

        if player:GetPlayerType() == GODMODE.registry.players.t_deli then
            local data = GODMODE.get_ent_data(player)
            -- GODMODE.log("hi",true)
            
            if (data.t_deli_immune or 0) > 0 then return false elseif GODMODE.save_manager.get_player_data(player,"RingHidden","false") == "false"
                or flags & DamageFlag.DAMAGE_NO_PENALTIES == 1 or flags & DamageFlag.DAMAGE_IV_BAG == 1 then 
                local eyes = tonumber(GODMODE.save_manager.get_player_data(player,"EyesOpen","16"))
                -- GODMODE.log("hi2",true)

                if eyes > 0 then 
                    -- GODMODE.log("hi3",true)
                    local amt = math.max(1,math.ceil(amount * 1.5) - player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHRIGHT))
                    eyes = eyes - amt
                    GODMODE.save_manager.set_player_data(player,"EyesOpen",eyes,true)
                    data.t_deli_immune = amount * 30
                    player:PlayExtraAnimation("Hit")
                    player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
                    player:EvaluateItems()
                    GODMODE.sfx:Play(SoundEffect.SOUND_MEATY_DEATHS,Options.SFXVolume*1.5+0.75)

                    GODMODE.util.macro_on_enemies(player,monster.type,monster.variant,-1,function(halo) 
                        halo = halo:ToFamiliar()
                        halo.State = math.min(max_bounce_anim,halo.State + bounce_anim_length * amt)
                    end)

                    enthit:TakeDamage(amount,flags | DamageFlag.DAMAGE_FAKE & ~DamageFlag.DAMAGE_IV_BAG
                    ,entsrc,countdown)

                    return false 
                end
            end
        end
    end
end

monster.pickup_init = function(self,pickup)
    if pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType == HeartSubType.HEART_SOUL then 
        local birthright_mod = 0
        local need = false 

        GODMODE.util.macro_on_players(function(player) if player:GetPlayerType() == GODMODE.registry.players.t_deli and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then 
            birthright_mod = birthright_mod + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHRIGHT) * 0.2

            if tonumber(GODMODE.save_manager.get_player_data(player,"EyesOpen",num_eyes)) < num_eyes and need == false then 
                need = true 
                birthright_mod = 0.1
            end
        end end)

        if pickup:GetDropRNG():RandomFloat() < birthright_mod then 
            GODMODE.get_ent_data(pickup).delirious_heart = true 
            pickup:GetSprite():Load("gfx/pickup_deli_heart.anm2",true)
            pickup:GetSprite():Play("Appear",true)
        end
    end
end

monster.pickup_collide = function(self,pickup,ent2,entfirst)
    if GODMODE.get_ent_data(pickup).delirious_heart == true and 
        pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType == HeartSubType.HEART_SOUL and 
        ent2:ToPlayer() and 
        pickup:GetSprite():IsPlaying("Idle") then 

        local player = ent2:ToPlayer()

        if player:GetPlayerType() == GODMODE.registry.players.t_deli then 
            GODMODE.save_manager.set_player_data(player,"EyesOpen",math.min(num_eyes,GODMODE.save_manager.get_player_data(player,"EyesOpen",num_eyes)+1),true)
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FAMILIARS | CacheFlag.CACHE_SHOTSPEED)
            player:EvaluateItems()
            pickup:GetSprite():Play("Collect",true)
            return true
        else
            return false
        end
    end
end

monster.bypass_hooks = {["pickup_init"] = true, ["pickup_collide"] = true}


return monster