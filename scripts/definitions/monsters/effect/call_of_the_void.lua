local monster = {}
monster.name = "Call of the Void"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, params)

    if params[1].SubType > 0 then
        params[2].persistent_state = GODMODE.persistent_state.between_rooms
        params[1].EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    else
        params[1]:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        params[1]:GetSprite():Play("Appear",true)
        params[2].power = params[2].power or 1 
    end

    params[1]:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
    params[1].GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    
end

local get_type_to_spawn = function(ent)
    if ent.I2 > 0 then 
        return 2
    elseif tonumber(GODMODE.save_manager.get_data("VoidBHProj","0")) == 0 then 
        if tonumber(GODMODE.save_manager.get_data("VoidDMProj","0")) == 0 then 
            return -1
        else 
            return 2
        end
    else 
        return 1
    end
end

local get_power = function()
    return tonumber(GODMODE.save_manager.get_data("VoidBHProj","0"))
end

local spawn_proj = function(ent)
    local type = get_type_to_spawn(ent)
    if type == -1 and ent.I2 == 0 then return elseif ent.I2 > 0 then type = 2 end --out of power! OR a door spawned/added to the projectile count
    
    local p = Isaac.Spawn(ent.Type,ent.Variant,type,ent.Position,Vector.Zero,ent)

    if ent.I2 > 0 then 
        ent.I2 = ent.I2 - 1
    elseif type == 1 then 
        GODMODE.save_manager.set_data("VoidBHProj",tonumber(GODMODE.save_manager.get_data("VoidBHProj","0"))-1)
    elseif type == 2 then 
        GODMODE.save_manager.set_data("VoidDMProj",tonumber(GODMODE.save_manager.get_data("VoidDMProj","0"))-1)
    end

    p:GetSprite():Play("OrbSpawn", true)
    p:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    p.Position = ent.Position
    GODMODE.get_ent_data(ent).cache_projs = (GODMODE.get_ent_data(ent).cache_projs or 0) + 1
end


monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    if not data then return end
    local player = ent:GetPlayerTarget()
    if data.real_time == 1 then
        ent:AddEntityFlags(EntityFlag.FLAG_TRANSITION_UPDATE | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_DONT_OVERWRITE | EntityFlag.FLAG_NO_DAMAGE_BLINK)
    end

    if ent.SubType == 1 or ent.SubType == 2 then
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY

        if ent:IsFrame(20,1) and GODMODE.util.total_item_count(Isaac.GetItemIdByName("A Second Thought")) > 0 then 
            ent:GetSprite():Play("OrbKill",false)
            ent.Velocity = ent.Velocity * 0.5
        end

        if ent:GetSprite():IsFinished("OrbSpawn") then
            ent:GetSprite():Play("Orb", true)
        end

        if ent:GetSprite():IsFinished("Orb") or ent:GetSprite():IsFinished("OrbMove") then
            if player:ToPlayer() and player:ToPlayer():IsExtraAnimationFinished() and not ent:GetSprite():IsFinished("OrbMove") then
                ent:GetSprite():Play("OrbMove", true)
            else
                ent:GetSprite():Play("Orb", true)
            end
        end

        ent.Velocity = ent.Velocity * 0.9
        local target = data.target_pos or player.Position
        if ent:GetSprite():IsEventTriggered("Attack") then
            ent.Velocity = ent.Velocity + (target - ent.Position):Resized(math.max(12,math.min(256,(target - ent.Position):Length()/48-12)))
            SFXManager():Play(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,0.85)
        end

        if ent:GetSprite():IsFinished("OrbKill") then
            ent:Remove()
        end

        if ent:GetSprite():IsEventTriggered("SFX") then
            if ent:GetSprite():IsPlaying("OrbKill") then
                SFXManager():Play(SoundEffect.SOUND_HOLY,1,2,false,0.5)
                SFXManager():Play(SoundEffect.SOUND_FIREDEATH_HISS,1,2,false,0.85)
                SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE,1,2,false,0.85)
                Game():ShakeScreen(10)
            else 
                SFXManager():Play(SoundEffect.SOUND_HOLY,1,2,false,0.95)
                SFXManager():Play(SoundEffect.SOUND_SUPERHOLY,0.25,2,false,0.75)
            end
        end

        ent:GetSprite().PlaybackSpeed = 0.6

        if data.target_pos ~= nil and (ent.Position - data.target_pos):Length() < ent.Size then
            ent:Die()
        end

    else
        if ent:IsFrame(20,1) and GODMODE.util.total_item_count(Isaac.GetItemIdByName("A Second Thought")) > 0 and not ent:GetSprite():IsPlaying("Disappear") then 
            ent:GetSprite():Play("Disappear",true)
            ent.Velocity = ent.Velocity * 0.5
        end

        local ang = player.Position - ent.Position
        ent.Velocity = ent.Velocity * 0.975
        if ang:Length() > ent.Size*2 and ent:GetSprite():IsPlaying("Idle") and ((data.spent or -1) < 0) then
            ent.Velocity = ent.Velocity * 0.9 + ang:Resized(math.min(ang:Length(),math.max(32,math.min(128,(player.Position - ent.Position):Length()/6-12))))/200
        end
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

        if ent:GetSprite():IsFinished("Appear") then
            ent:GetSprite().PlaybackSpeed = 1.0
            ent:GetSprite():Play("Idle", true)
        end

        if ent.I1 == 0 then 
            ent.I1 = 1
        end

        if ent:GetSprite():IsPlaying("Idle") and data.time % 50 == 0 and ent:GetDropRNG():RandomFloat() < 0.85 and Game():GetRoom():IsClear() and not Game():GetRoom():HasCurseMist()
            and ((ent.I2 > 0 or get_type_to_spawn(ent) ~= -1) or (data.spent or -1) < 0) and (data.opacity or 0.8) >= 0.5 then

            if player:ToPlayer() and player:ToPlayer():IsExtraAnimationFinished() or not player:ToPlayer() then
                local max = (data.power or 0)

                if (data.cache_projs or 0) < ent.I1 then
                    ent:GetSprite():Play("Attack", true)
                end
            end
        end

        if ent:GetSprite():IsFinished("Attack")  then
            ent:GetSprite():Play("Idle", true)
        end

        if (data.halt or 0) > 0 then
            data.halt = data.halt - 1
        end

        data.opacity = data.opacity or 0.8

        if (data.opacity or 0) >= 0.5 and ent.FrameCount > 10 then 
            data.spent = (data.spent or 1) - 1 
            local timecheck = 100
            if Game().Challenge == Isaac.GetChallengeIdByName("Out Of Time") then timecheck = 5 end 

            if data.cache_projs == nil or data.time % timecheck == 0 then 
                data.cache_projs = GODMODE.util.count_enemies(ent,ent.Type,ent.Variant,1) + GODMODE.util.count_enemies(ent,ent.Type,ent.Variant,2)
            end

            if data.spent <= 0 and data.cache_projs == 0 and get_type_to_spawn(ent) == -1 then 
                -- GODMODE.log("spent="..data.spent..",cache="..data.cache_projs..",type="..get_type_to_spawn(ent)..",i2="..ent.I2,true)
                ent:GetSprite():Play("Disappear",false)
            end
        end

        if ent:GetSprite():IsFinished("Disappear") then
            ent:Remove()
        end

        if ent:GetSprite():IsEventTriggered("Attack") then
            data.halt = 30
            spawn_proj(ent)
        end

        if ent:GetSprite():IsEventTriggered("SFX") then
            SFXManager():Play(SoundEffect.SOUND_BLACK_POOF,1,2,false,0.5)
            SFXManager():Play(SoundEffect.SOUND_MAW_OF_VOID,1,2,false,0.75)
        end

        if ent:GetSprite():IsEventTriggered("SFX2") then
            if ent:GetSprite():IsPlaying("Attack") then
                Game():ShakeScreen(5)

                if ent:GetDropRNG():RandomInt(2) == 1 then
                    SFXManager():Play(SoundEffect.SOUND_MONSTER_YELL_A,1,2,false,0.5)
                else
                    SFXManager():Play(SoundEffect.SOUND_MONSTER_YELL_B,1,2,false,0.5)
                end    
            else
                SFXManager():Play(SoundEffect.SOUND_MONSTER_ROAR_0,1,2,false,0.5)
            end
        end

        ent:SetColor(Color(data.opacity,data.opacity,data.opacity,data.opacity,0,0,0,0),999,999,false,false)
        if not Game():GetRoom():IsClear() then 
            data.opacity = math.max(0.1,data.opacity - 1/60.0)
        else
            data.opacity = math.min(math.cos(math.rad(data.real_time*3))*0.15+0.7,data.opacity + 1/60.0)
        end
    end

end

monster.new_level = function(self)
    GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,1,function(ent) 
        ent:Remove()
    end)
end

monster.npc_collide = function(self,ent,ent2,entfirst)
    if ent2.Type == EntityType.ENTITY_PLAYER then
        if not ent:GetSprite():IsPlaying("OrbKill") and not ent:GetSprite():IsPlaying("OrbSpawn") and not GODMODE.get_ent_data(ent).spent and ent.SubType > 0 then
            ent:GetSprite():Play("OrbKill",true)
            ent.Velocity = Vector.Zero
            GODMODE.get_ent_data(ent).spent = true

            if not ent2:ToPlayer():HasInvincibility() then 
                local player = ent2:ToPlayer()
                if player:HasTrinket(Isaac.GetTrinketIdByName("Mood Ring (Blue)")) or player:HasTrinket(Isaac.GetTrinketIdByName("Mood Ring (Yellow)")) or player:HasTrinket(Isaac.GetTrinketIdByName("Mood Ring (Green)")) then
                    local next = Isaac.GetTrinketIdByName("Mood Ring (Yellow)")
                    if player:HasTrinket(Isaac.GetTrinketIdByName("Mood Ring (Yellow)")) then next = Isaac.GetTrinketIdByName("Mood Ring (Green)") end 
                    if player:HasTrinket(Isaac.GetTrinketIdByName("Mood Ring (Green)")) then next = Isaac.GetTrinketIdByName("Mood Ring (Black)") end 
                    player:TryRemoveTrinket(Isaac.GetTrinketIdByName("Mood Ring (Blue)"))
                    player:TryRemoveTrinket(Isaac.GetTrinketIdByName("Mood Ring (Yellow)"))
                    player:TryRemoveTrinket(Isaac.GetTrinketIdByName("Mood Ring (Green)"))
                    player:AddTrinket(next)
    
                    if not player:HasTrinket(next) then 
                        Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,next,Game():GetRoom():FindFreePickupSpawnPosition(player.Position),Vector.Zero,nil)
                    else 
                        player:AnimateTrinket(next)
                    end
                else 
                    if ent.SubType == 1 then
                        player:AddBrokenHearts(1)
                    else
                        player:TakeDamage(1,DamageFlag.DAMAGE_NO_MODIFIERS | DamageFlag.DAMAGE_INVINCIBLE,EntityRef(ent),1)
                    end    
                end
            end

            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIPPLE_POOF, 0, ent.Position, Vector.Zero, ent)
            if ent.SpawnerEntity and ent.SpawnerEntity.Type == monster.type then
                GODMODE.get_ent_data(ent.SpawnerEntity).spent = 100
            end
        end

        return true
    end
end

return monster