local monster = {}
monster.name = "Call of the Void"
monster.type = GODMODE.registry.entities.call_of_the_void.type
monster.variant = GODMODE.registry.entities.call_of_the_void.variant

monster.data_init = function(self, ent,data,sprite)
	if ent.Type == monster.type and ent.Variant == monster.variant then     
        data.persistent_state = GODMODE.persistent_state.between_rooms
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
        ent:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_PERSISTENT)
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        sprite:Play("Appear",true)
    end    
end

local get_type_to_spawn = function(ent)
    if tonumber(GODMODE.save_manager.get_data("VoidBHProj","0")) > 0 then 
        return 1 
    elseif tonumber(GODMODE.save_manager.get_data("VoidDMProj","0")) > 0 then 
        return 2
    else 
        return 0
    end
end

local get_power = function()
    return tonumber(GODMODE.save_manager.get_data("VoidPower","0"))
end

local type_to_projid = {"VoidBHProj","VoidDMProj"}

local spawn_proj = function(ent)
    local type = get_type_to_spawn(ent)
    --out of power!
    if type == -1 then return else 
        local p = Isaac.Spawn(ent.Type,ent.Variant,type,ent.Position,Vector.Zero,ent)
        GODMODE.save_manager.set_data(type_to_projid[type],tonumber(GODMODE.save_manager.get_data(type_to_projid[type],"0"))-1,true)
        p:GetSprite():Play("OrbSpawn", true)
        -- slow it down
        p:GetSprite().PlaybackSpeed = 0.6
        p:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        p.Position = ent.Position
    end

    GODMODE.get_ent_data(ent).cache_projs = GODMODE.util.count_enemies(nil,ent.Type,ent.Variant,1) + GODMODE.util.count_enemies(nil,ent.Type,ent.Variant,2)
end

-- local spawn_shadow = function(ent,sprite)
--     local shadow = Isaac.Spawn(GODMODE.registry.entities.player_trail_fx.type, GODMODE.registry.entities.player_trail_fx.variant, 0, ent.Position+RandomVector()*(RandomFloat()*48.0+16.0), Vector.Zero, ent):ToEffect()
--     shadow.State = 5
--     shadow.Timeout = 12
--     shadow:Update()
--     shadow:GetSprite():Load(sprite:GetFilename(),true)
--     shadow:GetSprite():SetFrame(sprite:GetAnimation(),sprite:GetFrame())
--     local data = GODMODE.get_ent_data(shadow)
-- end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()

    if not ent:HasEntityFlags(EntityFlag.FLAG_TRANSITION_UPDATE) then
        ent:AddEntityFlags(EntityFlag.FLAG_TRANSITION_UPDATE | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_DONT_OVERWRITE | EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_QUERY)
    end

    if ent.SubType > 0 then --projectiles!
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
        ent.DepthOffset = 100

        -- kill existing cotv projectiles if A Second Thought is held
        if ent:IsFrame(5,1) and GODMODE.util.total_item_count(GODMODE.registry.items.a_second_thought) > 0
             and (ent.SpawnerEntity == nil or not (ent.SpawnerEntity.Type == GODMODE.registry.entities.the_fallen_light.type and ent.SpawnerEntity.Variant == GODMODE.registry.entities.the_fallen_light.variant)) then 
            sprite:Play("OrbKill",false)
            ent.Velocity = ent.Velocity * 0.5
        end

        -- Animate orb
        if sprite:IsFinished("OrbSpawn") or sprite:IsFinished("Idle") or sprite:IsPlaying("Appear") then
            sprite:Play("Orb", true)
        end

        if sprite:IsFinished("Orb") or sprite:IsFinished("OrbMove") then
            if player:ToPlayer() and player:ToPlayer():IsExtraAnimationFinished() and not sprite:IsFinished("OrbMove") then
                sprite:Play("OrbMove", true)
            else
                sprite:Play("Orb", true)
            end
        end

        -- momentum towards player on anim trigger
        ent.Velocity = ent.Velocity * 0.925
        local target = data.target_pos or player.Position

        -- colliding
        if not data.target_pos and (target - ent.Position):Length() < ent.Size * 5 and player:ToPlayer() and not player:ToPlayer():IsExtraAnimationFinished() then 
            ent.Velocity = ent.Velocity + (ent.Position - target):Resized(1)
        end

        if sprite:IsEventTriggered("Attack") then
            ent.Velocity = ent.Velocity + (target - ent.Position):Resized(math.max(9,math.min(20 - (data.target_pos and 9.5 or 0),(target - ent.Position):Length()/16-12)))
            GODMODE.sfx:Play(SoundEffect.SOUND_MEAT_JUMPS,1,2,false,0.85)
        end

        -- kill signal
        if sprite:IsFinished("OrbKill") then
            ent:Remove()
        end

        -- add sound fx
        if sprite:IsEventTriggered("SFX") then
            if sprite:IsPlaying("OrbKill") then
                GODMODE.sfx:Play(SoundEffect.SOUND_HOLY,1,2,false,0.5)
                GODMODE.sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS,1,2,false,0.85)
                GODMODE.sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE,1,2,false,0.85)
                GODMODE.game:ShakeScreen(10)
            else 
                GODMODE.sfx:Play(SoundEffect.SOUND_HOLY,1,2,false,0.95)
                GODMODE.sfx:Play(SoundEffect.SOUND_SUPERHOLY,0.25,2,false,0.75)
            end
        end

        -- remove projectile if it has a target position and reached it
        if data.target_pos ~= nil and (ent.Position - data.target_pos):Length() < ent.Size*2 then
            ent:Die()
        end
    else --call of the void!
        local correct_flag = GODMODE.util.is_correction()

        -- A Second Thought kill switch
        if ent:IsFrame(8,1) and GODMODE.util.total_item_count(GODMODE.registry.items.a_second_thought) > 0 and not sprite:IsPlaying("Disappear") then 
            sprite:Play("Disappear",true)
            ent.Velocity = ent.Velocity * 0.5
        end

        -- movement towards the player
        local ang = player.Position - ent.Position
        ent.Velocity = ent.Velocity * 0.975
        if ang:Length() > ent.Size*1.5 and sprite:IsPlaying("Idle") and ((data.pause or -1) < 0) then
            ent.Velocity = ent.Velocity * 0.9 + ang:Resized(math.min(ang:Length(),math.max(32,math.min(128,(player.Position - ent.Position):Length()/6-12))))/180
        end
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

        -- choose when to attack
        if sprite:IsFinished("Appear") or sprite:IsFinished("Idle") or sprite:IsFinished("Attack") then
            data.cache_projs = GODMODE.util.count_enemies(nil,ent.Type,ent.Variant,1) + GODMODE.util.count_enemies(nil,ent.Type,ent.Variant,2)
            sprite.PlaybackSpeed = 1.0

            if not correct_flag then 
                ent.I1 = ent.I1 + 1

                -- valid attack time?
                if ent:GetDropRNG():RandomFloat() > 2 - ent.I1 * 0.15 and GODMODE.room:IsClear() and not GODMODE.room:HasCurseMist() and (data.pause or -1) < 0 and (data.opacity or 0.8) >= 0.5 then 
                    ent.I1 = 0
                    if player:ToPlayer() and player:ToPlayer():IsExtraAnimationFinished() or not player:ToPlayer() then
                        local max = (data.power or 0)
                        data.cache_projs = GODMODE.util.count_enemies(nil,ent.Type,ent.Variant,1) + GODMODE.util.count_enemies(nil,ent.Type,ent.Variant,2)

                        -- can spawn attack? 
                        if get_type_to_spawn(ent) ~= 0 and data.cache_projs < tonumber(GODMODE.save_manager.get_data("VoidPower","0")) then
                            sprite:Play("Attack", true)
                        else 
                            sprite:Play("Idle", true)
                        end
                    else 
                        sprite:Play("Idle", true)
                    end
                else 
                    sprite:Play("Idle", true)
                end
            else 
                sprite:Play("Idle", true)
            end
        end

        -- hide COTV in uncleared rooms AND correction rooms
        data.opacity = data.opacity or 0.8

        if correct_flag then 
            data.opacity = 0.0
        elseif not GODMODE.room:IsClear() then 
            data.opacity = math.max(0.1,(data.opacity - 1/60.0))
        else
            data.opacity = math.min(math.cos(math.rad(data.real_time*3))*0.15+0.7,data.opacity + 1/60.0)
        end

        ent:SetColor(Color(data.opacity,data.opacity-(data.roar_fx or 0.0),data.opacity-(data.roar_fx or 0.0),math.min(data.opacity+(data.roar_fx or 0) * 2,1.0),(data.roar_fx or 0.0)/2.0,0,0,0),999,999,false,false)

        -- no projectiles left to spawn, checks for existing projectiles before disappearing once they are all gone
        if (data.opacity or 0) >= 0.5 and ent.FrameCount > 10 then 
            data.pause = (data.pause or 1) - 1 

            if data.pause <= 0 and get_type_to_spawn(ent) == 0 and not sprite:IsPlaying("Appear") then 
                if data.pause % 20 == 0 then 
                    data.cache_projs = GODMODE.util.count_enemies(nil,ent.Type,ent.Variant,1) + GODMODE.util.count_enemies(nil,ent.Type,ent.Variant,2)
                end
    
                if data.cache_projs == 0 then 
                    sprite:Play("Disappear",false)
                end
            end
        end

        if sprite:IsPlaying("Disappear") then 
            ent.Velocity = ent.Velocity * 0.2
        end

        if sprite:IsFinished("Disappear") then
            ent:Remove()
            GODMODE.save_manager.set_data("VoidPower","0",true)
        end

        if sprite:IsEventTriggered("Attack") then
            spawn_proj(ent)
            -- spawn_shadow(ent,sprite)
            -- spawn_shadow(ent,sprite)
            data.roar_fx = 0.2
        end

        if ent:IsFrame(5+math.floor(((ent.FrameCount - 1) % 10)/2) - 1,1) then 
            -- spawn_shadow(ent,sprite) 
        end

        if (data.roar_fx or 0) > 0 then 
            data.roar_fx = data.roar_fx * 0.975

            if data.roar_fx < 0.01 then data.roar_fx = 0.0 end 
        end

        if sprite:IsEventTriggered("SFX") then
            GODMODE.sfx:Play(SoundEffect.SOUND_BLACK_POOF,1,2,false,0.5)
            GODMODE.sfx:Play(SoundEffect.SOUND_MAW_OF_VOID,1,2,false,0.75)
        end

        if sprite:IsEventTriggered("SFX2") then
            if sprite:IsPlaying("Attack") then
                GODMODE.game:ShakeScreen(5)

                if ent:GetDropRNG():RandomInt(2) == 1 then
                    GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_YELL_A,1,2,false,0.5)
                else
                    GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_YELL_B,1,2,false,0.5)
                end    
            else
                GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_0,1,2,false,0.5)
            end
        end
    end

end

monster.new_level = function(self)
    GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,-1,function(ent) 
        if ent.SubType > 0 then 
            ent:Remove()
        end
    end)
end

monster.npc_collide = function(self,ent,ent2,entfirst)
    if ent2.Type == EntityType.ENTITY_PLAYER then
        local sprite = ent:GetSprite()
        if sprite:GetAnimation() ~= "OrbKill" and not sprite:IsPlaying("OrbSpawn") and ent.SubType > 0 and ent2:ToPlayer():IsExtraAnimationFinished() then
            sprite:Play("OrbKill",true)
            ent.Velocity = Vector.Zero

            if not ent2:ToPlayer():HasInvincibility() then 
                local player = ent2:ToPlayer()
                if player:HasTrinket(GODMODE.registry.trinkets.mood_ring_blue) or player:HasTrinket(GODMODE.registry.trinkets.mood_ring_yellow) or player:HasTrinket(GODMODE.registry.trinkets.mood_ring_green) then
                    local next = GODMODE.registry.trinkets.mood_ring_yellow
                    if player:HasTrinket(GODMODE.registry.trinkets.mood_ring_yellow) then next = GODMODE.registry.trinkets.mood_ring_green end 
                    if player:HasTrinket(GODMODE.registry.trinkets.mood_ring_green) then next = GODMODE.registry.trinkets.mood_ring_black end 
                    player:TryRemoveTrinket(GODMODE.registry.trinkets.mood_ring_blue)
                    player:TryRemoveTrinket(GODMODE.registry.trinkets.mood_ring_yellow)
                    player:TryRemoveTrinket(GODMODE.registry.trinkets.mood_ring_green)
                    player:AddTrinket(next)
    
                    if not player:HasTrinket(next) then 
                        Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,next,GODMODE.room:FindFreePickupSpawnPosition(player.Position),Vector.Zero,nil)
                    else 
                        player:AnimateTrinket(next)
                    end
                else 
                    if ent.SubType == 1 then
                        GODMODE.util.add_faithless(player,1)
                    else
                        player:TakeDamage(1,DamageFlag.DAMAGE_NO_MODIFIERS | DamageFlag.DAMAGE_INVINCIBLE,EntityRef(ent),1)
                    end    
                end
            end

            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RIPPLE_POOF, 0, ent.Position, Vector.Zero, ent)
            if ent.SpawnerEntity and ent.SpawnerEntity.Type == monster.type then
                local cotv_data = GODMODE.get_ent_data(ent.SpawnerEntity)
                cotv_data.pause = 100
                cotv_data.cache_projs = GODMODE.util.count_enemies(nil,ent.Type,ent.Variant,1) + GODMODE.util.count_enemies(nil,ent.Type,ent.Variant,2)
            end
        end

        return true
    end
end

return monster