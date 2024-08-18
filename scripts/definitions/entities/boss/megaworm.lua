local monster = {}
-- monster.data gets updated every callback
monster.name = "Mega Worm"
monster.type = GODMODE.registry.entities.mega_worm.type
monster.variant = GODMODE.registry.entities.mega_worm.variant

-- monster.set_delirium_visuals = function(self,ent)
-- 	ent:GetSprite():ReplaceSpritesheet(0,"gfx/bosses/deliriumforms/gimmimick.png")
--     for i=3,6 do 
--         ent:GetSprite():ReplaceSpritesheet(i,"gfx/bosses/deliriumforms/gimmimick.png")
--     end
--     ent:GetSprite():LoadGraphics()
-- end

monster.set_delirium_visuals = function(self,ent)
    for i=0,1 do 
        ent:GetSprite():ReplaceSpritesheet(i,"gfx/bosses/deliriumforms/worm_boss.png")
    end
    ent:GetSprite():LoadGraphics()
end

local head_offset = function(ent) 
    local ret = Vector(-26,-36)
    if ent.FlipX then ret.X = -ret.X end 
    return ret
end

local atks = {"DigIn","Shoot","Summon"}
local sel_attack = function(data,ent)
    data.summon_cache = data.summon_cache or 0
    if data.last_atk == nil then 
        return "DigIn"
    elseif ent.FrameCount > 100 and ent:GetDropRNG():RandomFloat() < (0.45 - (data.summon_cache or 0)*0.15) and data.last_atk ~= "Summon" then 
        return "Summon"
    else
        local new = atks[ent:GetDropRNG():RandomInt(#atks)+1]

        if new == "Summon" and data.summon_cache >= 3 then 
            return "Shoot"
        end

        local depth = 10
        while data.last_atk == new and depth > 0 do 
            new = atks[ent:GetDropRNG():RandomInt(#atks)+1]
            depth = depth - 1

            if new == "Summon" and data.summon_cache >= 3 then 
                return "Shoot"
            end    
        end

        return new 
    end
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()

    -- GODMODE.log("hi!",true)

    if sprite:IsPlaying("DigOut") or ent.I2 == 0 then 
        data.init_pos = data.init_pos or ent.Position 
        ent.Position = (ent.Position * 2 + data.init_pos) / 3
        ent.Velocity = ent.Velocity * 0.25    
    end

    if sprite:IsFinished("Idle") or sprite:IsFinished("DigOut") or sprite:IsFinished("Shoot") or sprite:IsFinished("Summon") then 
        ent.I1 = ent.I1 + 2 + ent:GetDropRNG():RandomInt(3)

        if sprite:IsFinished("DigOut") and ent.HitPoints / ent.MaxHitPoints < 0.45 then 
            data.last_atk = "Shoot"
            sprite:Play("Shoot",true)
        elseif ent:GetDropRNG():RandomFloat() < (1.0 - ent.I1 * 0.075) or ent.FrameCount < 5 then 
            sprite:Play("Idle",true)
        else 
            data.summon_cache = GODMODE.util.count_enemies(ent,EntityType.ENTITY_ROUND_WORM,nil,nil)
            ent.I1 = 0
            local atk = sel_attack(data,ent)
            data.last_atk = atk
            sprite:Play(atk,true)

            if atk == "Summon" then 
                data.summon_count = 0
            end
        end

        ent.FlipX = player.Position.X > ent.Position.X
    end

    if sprite:IsPlaying("Shoot") then 
        ent.FlipX = player.Position.X > ent.Position.X
    end

    if sprite:IsPlaying("Summon") then 
        ent.FlipX = player.Position.X < ent.Position.X
        if sprite:GetFrame() == 41 then
            data.summon_cache = GODMODE.util.count_enemies(ent,EntityType.ENTITY_ROUND_WORM,nil,nil)
            data.summon_count = (data.summon_count or 0)
            local perc = ent.HitPoints / ent.MaxHitPoints 

            if perc < 0.6 and data.summon_count < 2 and data.summon_cache < 2 or perc < 0.3 and data.summon_count < 3 and data.summon_cache < 3 then 
                sprite:SetFrame(31)
            end
        end
    end

    if sprite:IsPlaying("DigIn") or sprite:IsFinished("DigIn") then --digging attack/fx
        if sprite:IsFinished("DigIn") and ent.I2 > 0 then 
            ent.I2 = ent.I2 - 1 
            local dir = (player.Position - ent.Position)
            ent.Velocity = (dir:Resized(math.max(3,dir:Length()/26.0))+ent.Velocity * 3) / 4.0
    
            if ent.I2 % 3 == 0 then 
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DIRT_PILE, 0, ent.Position+Vector(ent.Size,ent.Size):Resized(ent.Size/2):Rotated(ent:GetDropRNG():RandomFloat()*360), Vector.Zero, ent)
            end
            GODMODE.game:ShakeScreen(2)
    
            if ent.I2 < 15 then 
                local rock = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_EXPLOSION, 0, ent.Position+Vector(ent.Size,ent.Size):Resized(ent.Size):Rotated(ent:GetDropRNG():RandomFloat()*360), Vector.Zero, ent)
                rock:Update()
            end
    
            if ent.I2 == 0 then 
                sprite:Play("DigOut",true)
                local shock = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, ent.Position+Vector(ent.Size,ent.Size):Resized(ent.Size/2):Rotated(ent:GetDropRNG():RandomFloat()*360), Vector.Zero, ent)
                shock.Parent = ent
                GODMODE.game:MakeShockwave(ent.Position, 0.0375, 0.005, 20)
            end
        elseif ent.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE then
            local rock = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_EXPLOSION, 0, ent.Position+Vector(ent.Size,ent.Size):Resized(ent.Size):Rotated(ent:GetDropRNG():RandomFloat()*360), Vector.Zero, ent)
            rock:Update()
            GODMODE.game:ShakeScreen(2)
        end
    end

    if sprite:IsEventTriggered("Toggle") then 
        if sprite:IsPlaying("DigIn") then 
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
            ent.I2 = 60+math.floor(math.min(60,(player.Position-ent.Position):Length()/4))
            data.init_pos = nil
        else 
            GODMODE.sfx:Play(SoundEffect.SOUND_CHILD_ANGRY_ROAR,Options.SFXVolume*2.5)
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        end
    end

    if data.tears ~= nil and #data.tears > 0 then
        for ind,tear in ipairs(data.tears) do 
            if tear:IsDead() then 
                table.remove(data.tears,ind)
                break
            elseif tear.FrameCount % 2 == 0 then 
                local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED,0,tear.Position,Vector.Zero,ent):ToEffect()
                creep:SetTimeout(80)
            end
        end
    end

    if sprite:IsEventTriggered("Fire") then 
        local blood = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 2, ent.Position + head_offset(ent)-Vector(0,12), Vector.Zero, ent)
        blood:SetColor(Color(1,1,1,0.75,0.0,0.0,0.0),40,99,false,false)
        blood.DepthOffset = 100
        local ang = math.rad((player.Position-(ent.Position+head_offset(ent))):GetAngleDegrees())
        local spd = 8.0 + (GODMODE.game.Difficulty % 2) * 4.0
        local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position+head_offset(ent),Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
        tear = tear:ToProjectile()
        tear.Height = -20
        tear.FallingSpeed = 0.0
        tear.FallingAccel = -(5.1/60.0)
        tear.Scale = 2
        tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.BURST8 | ProjectileFlags.DECELERATE
        data.tears = data.tears or {}
        table.insert(data.tears,tear)
        GODMODE.sfx:Play(SoundEffect.SOUND_WEIRD_WORM_SPIT,Options.SFXVolume*1.0+0.75)
    end

    if sprite:IsEventTriggered("Summon") then 
        local worm = Isaac.Spawn(EntityType.ENTITY_ROUND_WORM,0,0,ent.Position+head_offset(ent)*Vector(1,0),Vector.Zero,ent)
        worm:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        worm:GetSprite():Play("DigIn",true)
        worm.MaxHitPoints = 4.5
        worm.HitPoints = worm.MaxHitPoints
        data.summon_cache = (data.summon_cache or 0) + 1
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 3, ent.Position + head_offset(ent)*Vector(1,0)+Vector(0,8), Vector.Zero, ent)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, ent.Position + head_offset(ent), Vector.Zero, ent)
        GODMODE.game:ShakeScreen(10)
        data.summon_count = (data.summon_count or 0) + 1
    end

    if sprite:IsEventTriggered("SFX") then 
        if sprite:IsPlaying("Summon") then 
            GODMODE.sfx:Play(SoundEffect.SOUND_MULTI_SCREAM,Options.SFXVolume*1.5+0.75)
        elseif sprite:IsPlaying("DigIn") then
            GODMODE.sfx:Play(SoundEffect.SOUND_CHILD_ANGRY_ROAR,Options.SFXVolume*1.5+0.75)
        end
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)
    if (enthit.Type == monster.type and enthit.Variant == monster.variant) and 
        (entsrc.Type == monster.type and entsrc.Variant == monster.variant) then 
            -- (entsrc.Entity and entsrc.Entity.Parent and entsrc.Entity.Parent.Type == monster.type and entsrc.Entity.Parent.Variant == monster.variant)) then
        return false
    end
end

return monster