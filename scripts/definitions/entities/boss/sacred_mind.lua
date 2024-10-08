local monster = {}
monster.name = "The Sacred Mind"
monster.type = GODMODE.registry.entities.sacred_mind.type
monster.variant = GODMODE.registry.entities.sacred_mind.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        data.period = 0
        data.timeout = -1
        data.hide_state = 0

        if ent:GetSprite():IsPlaying("Death") or ent.HitPoints <= 0  then return nil end
        ent:GetSprite():Play("Idle",true)
        data.body = Isaac.Spawn(GODMODE.registry.entities.sacred_body.type,GODMODE.registry.entities.sacred_body.variant, 0, ent.Position, Vector(0,0), ent)
        data.link_function = function(mind, body, soul)
            if soul.MaxHitPoints < mind.MaxHitPoints or body.MaxHitPoints < mind.MaxHitPoints then
                soul.MaxHitPoints = mind.MaxHitPoints
                soul.HitPoints = soul.MaxHitPoints
                body.MaxHitPoints = mind.MaxHitPoints
                body.HitPoints = body.MaxHitPoints
            else
                if mind.HitPoints < body.HitPoints and mind.HitPoints < soul.HitPoints then
                    body.HitPoints = mind.HitPoints
                    soul.HitPoints = mind.HitPoints
                end
                if body.HitPoints < mind.HitPoints and body.HitPoints < soul.HitPoints then
                    mind.HitPoints = body.HitPoints
                    soul.HitPoints = body.HitPoints
                end
                if soul.HitPoints < body.HitPoints and mind.HitPoints < soul.HitPoints then
                    body.HitPoints = soul.HitPoints
                    mind.HitPoints = soul.HitPoints
                end    
            end
        end
        data.phase = 0
        data.move_function = function(ent,phase,offset)
            local center = GODMODE.room:GetCenterPos()
            local circle_vec = Vector(math.cos((data.time+offset * 60) / 30)*128,math.sin((data.time+offset * 60) / 30)*128)
            local typ = 0
            if phase == offset then typ = 1 end

            if typ == 1 then
                circle_vec = Vector(0,0)
            end

            local target = center + circle_vec
            local targ = math.rad((target - ent.Position):GetAngleDegrees())
            ent.Velocity = ent.Velocity * 0.9 + Vector(math.cos(targ) * 0.375,math.sin(targ) * 0.375)
        end
        local bod = GODMODE.get_ent_data(data.body)
        bod.mind = ent
        bod.link_function = data.link_function
        bod.move_function = data.move_function
        ent.MaxHitPoints = ent.MaxHitPoints + math.min(1000,(GODMODE.util.get_basic_dps(ent) / 10.0) * 100)
        ent.HitPoints = ent.MaxHitPoints

        GODMODE.util.macro_on_players(function(player) player.Position = ent.Position + Vector(0,64) end)

        data.cur_light = 1
    end
end

--add unique boss music for the fight!
local music_flag = false
monster.npc_init = function(self, ent)
    if GODMODE.room:GetType() == RoomType.ROOM_BOSS and GODMODE.level:GetStage() == LevelStage.STAGE5 and GODMODE.level:GetStageType() == StageType.STAGETYPE_WOTL then 
        music_flag = true
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        ent:GetSprite():Play("Appear", true)
    end
end
local boss_music = GODMODE.registry.music.the_path_to_enlightenment
monster.post_update = function(self)
    if music_flag == true then 
        if MusicManager():GetCurrentMusicID() ~= boss_music and not GODMODE.room:IsClear() then 
            if GODMODE.util.count_enemies(nil,monster.type,monster.variant) > 0 then 
                if not MMC then 
                    MusicManager():Play(boss_music, 1.0)
                    MusicManager():UpdateVolume()
                end
            end    
        end
    end
    --GODMODE.sfx:AdjustVolume
end

if MMC then 
    MMC.AddMusicCallback(GODMODE.mod_object, function()
        if GODMODE.room:GetType() == RoomType.ROOM_BOSS and GODMODE.level:GetStage() == LevelStage.STAGE5 and GODMODE.level:GetStageType() == StageType.STAGETYPE_WOTL then
            if GODMODE.util.count_enemies(nil,monster.type,monster.variant,nil) > 0 then 
                return boss_music
            end
        end
    end, Music.MUSIC_ISAAC_BOSS)
end

monster.new_level = function(self)
    music_flag = false
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    local player = ent:GetPlayerTarget()
    if data.time < 2 then return nil end
    if sprite:IsPlaying("Death") then
        data.link_function = nil
        return nil
    end
    if data.body ~= nil then
        GODMODE.get_ent_data(data.body).mind = ent
    end
    data.move_function(ent,data.phase,0)

    if data.time % 10 == 0 then
        local x = GODMODE.room:GetTopLeftPos().X + 20              
        local x2 = GODMODE.room:GetBottomRightPos().X-8
        local y = GODMODE.room:GetTopLeftPos().Y+23
        local y2 = GODMODE.room:GetBottomRightPos().Y+11
        local e = EffectVariant.CRACK_THE_SKY
        if data.phase == 3 then e = EffectVariant.CROSS_POOF end
        for i=0,(y2 - y) / ((y2 - y) / 7)-1 do
            local pos = Vector(x,y+i*((y2 - y) / 7))
            local pos2 = Vector(x2,y+i*((y2 - y) / 7))
            if ent:GetDropRNG():RandomFloat() < 0.45 then
                Isaac.Spawn(EntityType.ENTITY_EFFECT,e,0,pos,Vector(0,0),flame1)
            end
            if ent:GetDropRNG():RandomFloat() < 0.45 then
                Isaac.Spawn(EntityType.ENTITY_EFFECT,e,0,pos2-Vector(16,0),Vector(0,0),flame2)
            end
        end
    end

    if data.hide_state <= 0 then 
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS 
    end
    if data.hide_state > 0 then ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE end

    if data.time == 2 then
        sprite:Play("Idle", true)
    end

    data.timeout = data.timeout - 1
    if data.timeout == 5 then data.phase = 0 end
    if data.phase ~= 0 and data.phase ~= 3 then data.period = 0 end

    if data.phase ~= 0 and data.phase ~= 3 and data.period == 0 then
        if data.hide_state == 0 then
            sprite:Play("Hide",false)

            if sprite:IsFinished("Hide") then
                data.hide_state = 1
                sprite:Play("HiddenIdle",true)
            end
        end
    else
        if data.hide_state == 1 then
            if not sprite:IsPlaying("GhostAppear") and not sprite:IsPlaying("Idle") and data.phase == 0 then
                ent:ToNPC():PlaySound(GODMODE.registry.sounds.sacred_appear, 0.5, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
            end
            sprite:Play("GhostAppear",false)

            if sprite:IsFinished("GhostAppear") then
                data.hide_state = 0
                sprite:Play("Idle", true)
            end
        end
    end

    if data.body and data.soul then
        data.link_function(ent,data.body,data.soul)

        if data.body:IsDead() or data.soul:IsDead() and not sprite:IsPlaying("Death") and not ent:IsDead() then
            ent:Kill()
        end
    end

    if data.phase == 0 and data.hide_state == 0 and not sprite:IsPlaying("Attack") and data.timeout < 0 then
        data.period = data.period + 1
        if data.period >= 60 then
            ent:ToNPC():PlaySound(GODMODE.registry.sounds.sacred_1, 1.0, 25, false, 0.8 + ent:GetDropRNG():RandomFloat() * 0.2)
            sprite:Play("Attack", true)
            data.period = 0
            data.hide_state = -1
        end
    end
    if data.phase == 3 and not sprite:IsPlaying("GroupAttack") then
        data.period = data.period + 1
        if data.period == 89 then
            ent:ToNPC():PlaySound(GODMODE.registry.sounds.sacred_1, 1.0, 25, false, 0.9)
        end

        if data.period >= 90 then
            sprite:Play("GroupAttack", true)
            data.period = 0
            data.hide_state = -1            
        end
    end

    if sprite:IsFinished("Attack") and data.hide_state == -1 then
        data.hide_state = 0
        sprite:Play("Idle", true)
    end
    if sprite:IsFinished("GroupAttack") and data.hide_state == -1 then
        data.hide_state = 0
        sprite:Play("Idle", true)
    end

    if sprite:IsEventTriggered("Attack") then
        if sprite:IsPlaying("Attack") then
            data.phase = data.phase + 1
            local ang = (player.Position) - ent.Position
            local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,Vector(ent.Position.X,ent.Position.Y),Vector(0,0),ent)
            tear = tear:ToProjectile()
            tear.Height = tear.Height - 180
            tear.Scale = 3.0
            tear.FallingSpeed = 0.125
            tear.FallingAccel = (-0.05/60.0)
            tear.Color = Color(0.25,0.65,0.65,1.0,200/255,200/255,200/255)
            tear.ProjectileFlags = tear.ProjectileFlags + ProjectileFlags.EXPLODE 
            --tear.Position = tear.Position + off
            data.big_tear = tear
            data.big_tear.Color = Color(0.25,0.65,0.65,1.0,200/255,200/255,200/255)
           
            
        else
            data.timeout = 60
            local p = ProjectileParams()
            p.BulletFlags = p.BulletFlags + ProjectileFlags.SMART
            p.FallingSpeedModifier = 0.001
            p.FallingAccelModifier = 0.001
            p.GridCollision = false
            p.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
            p.HomingStrength = 0.5
            p.CurvingStrength = 0.05
            p.Spread = 180
            local ra = ent:GetDropRNG():RandomInt(73)
            for i=0,2 do
                local cen = GODMODE.room:GetCenterPos()
                local r = math.rad((data.body.Position - ent.Position):GetAngleDegrees() + ent:GetDropRNG():RandomFloat() * 45 - 22.5)
                local off = Vector(math.cos(r)*192,math.sin(r)*192)
                p.Scale = 1.0
                p.VelocityMulti = 1.5
                p.HeightModifier = 2.0
                local bul = ent:ToNPC():FireBossProjectiles(1, ent.Position + off*2, 1.5, p)
            end
        end
    end

    if data.big_tear ~= nil then
        data.big_tear.Position = (data.big_tear.Position * 29 + player.Position) / 30.0
        data.big_tear.Scale = data.big_tear.Scale - (1 / 60.0)

        if data.big_tear.Height ~= -30.0 then data.big_tear.Height = (data.big_tear.Height * 29 + -30) / 30.0 end
        if data.big_tear.Scale <= 1.6 then 
            data.big_tear:Kill()
        end
    end

    local order_flag = ent.HitPoints / ent.MaxHitPoints <= 0.5 and ent:IsFrame(70,0)
    if ent.HitPoints / ent.MaxHitPoints <= 0.3333 then order_flag = ent:IsFrame(45,0) end
    if ent.HitPoints / ent.MaxHitPoints <= 0.1 then order_flag = ent:IsFrame(30,0) end
    if ent.HitPoints / ent.MaxHitPoints <= 0.05 then order_flag = ent:IsFrame(20,0) end

    if order_flag then
        local x = GODMODE.room:GetTopLeftPos().X + 26
        local x2 = GODMODE.room:GetBottomRightPos().X - 26
        local y = GODMODE.room:GetTopLeftPos().Y - 16
        local order_poses = { Vector(x,y), Vector(x2,y) }

        local order_pos = order_poses[data.cur_light + 1]
        local f = (player.Position) - order_pos
        f = f:GetAngleDegrees()
        Isaac.Spawn(GODMODE.registry.entities.holy_order.type,GODMODE.registry.entities.holy_order.variant, math.floor(f), order_pos, Vector(0,0), ent)
        data.cur_light = (data.cur_light + 1) % 2
    end

end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)
    if (enthit.Type == monster.type and enthit.Variant == monster.variant) and 
        (enthit.FrameCount < 60 or enthit:GetSprite():IsPlaying("Appear") 
        or ((flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION or flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER)
            and GODMODE.util.get_player_from_attack(entsrc) == nil)
        or (entsrc.Type == EntityType.ENTITY_EFFECT and entsrc.Variant == EffectVariant.CRACK_THE_SKY)) then
        return false
    end
end

return monster