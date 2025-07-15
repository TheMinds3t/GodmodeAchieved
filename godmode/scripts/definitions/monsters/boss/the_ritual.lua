local monster = {}
-- monster.data gets updated every callback
monster.name = "The Ritual"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
--monster.subtype = 0 --deobfuscated
--monster.subtype_sensitive = false --deobfuscated

monster.data_init = function(self, params)
    local ent = params[1]
    local data = params[2]

    if ent.SubType == 0 then
        ent.HitPoints = ent.HitPoints + math.min(1000,(GODMODE.util.get_basic_dps(ent) / 10.0) * 100)
        ent.MaxHitPoints = ent.HitPoints
    end
end
monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()
	if ent.SubType == 1 then
        if data.streams == nil then
            ent:GetSprite():Play("Idle", false)
            data.fire = false
            data.overlit = false
            data.lit = true
            data.lit_state = 1
            data.pushed = false
            data.dead = false
            data.streams = {}
            data.spawn = true
        end

        if data.master and data.index then
            local master_data = GODMODE.get_ent_data(data.master)
            local off = master_data:get_offset(data.master, ent, data.index)
            local pos = master_data:get_position(data.master, ent, data.index)
            if off and pos then
                ent.Velocity = ent.Velocity * 0.92 + ((pos + off) - ent.Position) * (1 / 60)
                
                if master_data.cur_attack == 2 then
                    ent.Velocity = ent.Velocity * 0.9 + ((pos + off) - ent.Position) * (1 / 20)
                end
            end

            ent.SplatColor = Color(0,0,0,0,1,1,1)
            if data.streams ~= nil and #data.streams > 0 then
                for i=1, #data.streams do
                    local str = data.streams[i]
                    if str then
                        str.fire_time = str.fire_time - 1
                        if str.targ_ang ~= nil and str.fire_time > 0 and data.time % str.fire_rate == 0 then
                            local vec = Vector(math.cos(math.rad(str.targ_ang())),math.sin(math.rad(str.targ_ang())))
                            local speed = str.speed
                            if (master_data.cur_attack == 5 or master_data.last_attack == 5) and data.time % 20 == 0 then speed = speed / 3 end
                            local fire = Isaac.Spawn(EntityType.ENTITY_PROJECTILE, 2, 0, ent.Position, vec:Rotated(ent:GetDropRNG():RandomFloat() * str.spread - str.spread / 2) * speed, ent)                
                            fire:SetColor(Color(50/255,50/255,255/255,1,100/255,100/255,255/255),999,999,false,false)
                        end

                        if str.fire_time <= 0 then
                            local s = {}

                            for l=1,#data.streams do
                                if data.streams[l] and data.streams[l].fire_time > 0 then
                                    table.insert(s, data.streams[l])
                                end
                            end

                            data.streams = s
                        end
                    end
                end
            end

            if data.master:IsDead() or data.master == nil or data.master:GetSprite():IsPlaying("Death") then
                ent:GetSprite():Play("CandleDeath",false)
                data.dead = true
            end

            if master_data.cur_attack ~= 4 then
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                ent.DepthOffset = 0
            else 
                ent.DepthOffset = 100
            end

            master_data:get_anim(data.master, ent, data.index)

            if data.laser then
                if data.laser:IsDead() then 
                    data.laser = nil
                else
                    local ang = (data.master.Position - ent.Position):GetAngleDegrees() + 180
                    data.laser.Angle = ang
                end
            end

            if ent:GetSprite():IsEventTriggered("Attack") then
                if ent:GetSprite():IsPlaying("PutOut") then
                    if master_data.cur_attack == 3 then
                        local dir = (data.master.Position - ent.Position):GetAngleDegrees()
                        local ra = math.rad(dir)
                        local vec = Vector(math.cos(ra),math.sin(ra))
                        if data.index <= master_data.phase + 2 then
                            Isaac.Spawn(Isaac.GetEntityTypeByName("Mum"), Isaac.GetEntityVariantByName("Mum"), 0, ent.Position + vec * 16, Vector(0,0), ent)
                        end
                    end
                elseif ent:GetSprite():IsPlaying("CandleDeath") then
                    ent:Kill()
                elseif ent:GetSprite():IsPlaying("Attack") then
                    ent:ToNPC():PlaySound(SoundEffect.SOUND_DEVILROOM_DEAL, 1.0, 1, false, 1.4 + ent:GetDropRNG():RandomFloat() * 0.2)
                    if master_data.cur_attack == 2 then
                        local dir = (player.Position - ent.Position):GetAngleDegrees()
                        local ra = math.rad(dir)
                        local vec = Vector(math.cos(ra),math.sin(ra))
                        local fire = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,2,0,ent.Position,vec * 10.0,ent)   
                        fire:SetColor(Color(50/255,50/255,255/255,1,100/255,100/255,255/255),999,999,false,false)
                    end
                elseif ent:GetSprite():IsPlaying("Overlight") then
                    ent:ToNPC():PlaySound(SoundEffect.SOUND_DEVILROOM_DEAL, 1.0, 1, false, 0.4 + ent:GetDropRNG():RandomFloat() * 0.2)
                    if master_data.cur_attack == 5 then
                        local str = {}
                        str.targ_ang = function()
                            return (data.master.Position - ent.Position):GetAngleDegrees() + 180
                        end
                        str.fire_time = 130
                        str.fire_rate = 2
                        str.spread = 10
                        str.speed = 15
                        table.insert(data.streams, str)
                        --local l = EntityLaser.ShootAngle(1, data.master.Position, ang, 130, Vector(0,-32), data.master)
                        --data.laser = l
                    elseif master_data.cur_attack == 1 then
                        for i=2, #master_data.attack_data.lit do
                            if data.index ~= 1 and master_data.phase > 0 or data.index == 1 then
                                local targ_candle = master_data.candles[master_data.attack_data.lit[i]]
                                if targ_candle and GODMODE.get_ent_data(targ_candle).lit and data.lit and GODMODE.get_ent_data(targ_candle).index ~= data.index then
                                    local ang = (targ_candle.Position - ent.Position):GetAngleDegrees()
                                    local str = {}
                                    str.targ_ang = function()
                                        return ang
                                    end
                                    str.fire_rate = 4
                                    str.spread = 0
                                    if data.index ~= 1 then str.fire_rate = 7 str.speed = 10 str.spread = 0 end
                                    str.fire_time = 30

                                    for i=1,4 do 
                                        local entry = GODMODE.util.deep_copy(str)
                                        entry.speed = 10 + ent:GetDropRNG():RandomFloat() * 7.5
                                        table.insert(data.streams, entry)
                                    end
                                    --local l = EntityLaser.ShootAngle(1, ent.Position, ang, 30, Vector(0,-32), ent)
                                end
                            end
                        end
                    end
                end
            end
        end
        if not data.dead then
            if data.lit then
                if data.fire == true then
                    ent:GetSprite():Play("Attack", false)
                elseif data.overlit == true then
                    ent:GetSprite():Play("Overlight", false)
                end

                if ent:GetSprite():IsFinished("Overlight") then
                    data.overlit = false
                    ent:GetSprite():Play("Idle", false)
                end
                if ent:GetSprite():IsFinished("Attack") then
                    data.fire = false
                    ent:GetSprite():Play("Idle", false)
                end

                if data.lit_state == 0 then
                    ent:GetSprite():Play("Light", false)
                end

                if ent:GetSprite():IsFinished("Light") then
                    data.lit_state = 1
                    ent:GetSprite():Play("Idle", false)
                end
            else
                if data.lit_state == 1 then
                    ent:GetSprite():Play("PutOut", false)
                end

                if ent:GetSprite():IsFinished("PutOut") then
                    data.lit_state = 0
                    ent:GetSprite():Play("IdleOut")
                end
            end

            if ent:GetSprite():IsFinished("Appear") and not data.master:GetSprite():IsFinished("Appear") then
                ent:GetSprite():Play("Idle", false)
            end
        end
	end -- CANDLE END

	if ent.SubType == 0 then
		-- Attacks:
        -- 0 - Idle
        -- 1 - Four corners
        -- 2 - Orbit player
        -- 3 - Darken
        -- 4 - Bounce
        -- 5 - Circle of fire

        if data.candles == nil then
            ent:ToNPC():PlaySound(SoundEffect.SOUND_SATAN_RISE_UP, 1.0, 1, false, 0.4 + ent:GetDropRNG():RandomFloat() * 0.2)
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            data.phase = 0
            data.attack_time = 0
            data.attack_times = {150, 250, 80, 300, 220}
            data.put_out = 0
            data.trans_time = 0
            data.cur_attack = 0
            data.last_attack = -1
            data.attack_data = {}
            data.candles = {}
            data.get_anim = function(self, ent, candle, index)
                local candle_data = GODMODE.get_ent_data(candle)
                if self.cur_attack == 0 then
                    candle_data.lit = true
                elseif self.cur_attack == 1 then
                    if not self.attack_data:isLit(index) then
                        candle_data.lit = false
                    else
                        candle_data.lit = true
                        if self.attack_time == 100 then
                            candle_data.overlit = true
                            ent:ToNPC():PlaySound(SoundEffect.SOUND_SATAN_GROW, 1.0, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2) 
                        end
                    end
                elseif self.cur_attack == 2 then
                    candle_data.lit = true
                    if self.attack_time % (20-data.phase * 2) == 0 then
                        self.attack_data.cur_candle = ent:GetDropRNG():RandomInt(6)
                    end

                    if self.attack_time % (20-data.phase * 2) == 1 and index == self.attack_data.cur_candle then
                        candle_data.fire = true
                    end
                elseif self.cur_attack == 3 then
                    candle_data.lit = false
                elseif self.cur_attack == 4 then
                    candle_data.lit = true

                    if self.put_out == 1 then
                        candle_data.pushed = true
                        ent:ToNPC():PlaySound(SoundEffect.SOUND_SATAN_SPIT, 1.0, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2) 
                    end
                elseif self.cur_attack == 5 and self.put_out == 1 then
                    candle_data.overlit = true
                    ent:ToNPC():PlaySound(SoundEffect.SOUND_SATAN_GROW, 1.0, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2) 
                end
            end
            data.get_offset = function(self, ent, candle, index)
                local candle_data = GODMODE.get_ent_data(candle)
                if self.cur_attack == 5 or #candle_data.streams > 0 and self.last_attack == 5 then
                    return Vector(math.cos(math.rad(index * 72.0 + self.time * 2.0))*32,math.sin(math.rad(index * 72.0 + self.time * 2.0))*32)
                elseif self.cur_attack == 1 then
                    return Vector(0,0)
                elseif self.cur_attack == 4 then
                    local play_dir = (candle:GetPlayerTarget().Position - candle.Position)
                    if self.attack_time % 30 > 15 then 
                        if self.attack_time % 60 > 30 then
                            candle.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

                            if self.attack_time % 30 == 17 or self.attack_time % 30 == 28 then
                                return RandomVector():Resized(256+(ent:GetDropRNG():RandomFloat()-0.5)*256.0+64*self.phase)
                            else 
                                return -(play_dir):Resized(math.min(math.max(0,192-play_dir:Length()),24+8*self.phase))
                            end
                        else
                            candle.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
                            candle:SetColor(Color(1.0,1.0,1.0,1.0,1,0,0),17,20,true,true)
                            return play_dir:Normalized()*32.0*(self.phase + 1) 
                        end
                    else return candle.Velocity * 0.98 end
                elseif self.cur_attack == 2 then
                    return Vector(math.cos(math.rad(index * 72.0 + self.time * 2.0))*100,math.sin(math.rad(index * 72.0 + self.time * 2.0))*100)
                else
                    return Vector(math.cos(math.rad(index * 72.0 + self.time * 2.0))*80,math.sin(math.rad(index * 72.0 + self.time * 2.0))*80)
                end
            end
            data.get_position = function(self, ent, candle, index)
                local candle_data = GODMODE.get_ent_data(candle)
                local room = Game():GetRoom()
                if self.cur_attack == 1 then
                    candle.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
                    if index == 1 then 
                        return room:GetCenterPos() 
                    elseif index == 2 then
                        return Vector(room:GetTopLeftPos().X + 26, room:GetTopLeftPos().Y + 26)
                    elseif index == 3 then
                        return Vector(room:GetBottomRightPos().X - 26, room:GetTopLeftPos().Y + 26)
                    elseif index == 4 then
                        return Vector(room:GetBottomRightPos().X - 26, room:GetBottomRightPos().Y - 26)
                    elseif index == 5 then
                        return Vector(room:GetTopLeftPos().X + 26, room:GetBottomRightPos().Y - 26)
                    else
                        return ent.Position
                    end
                elseif self.cur_attack == 2 then
                    candle.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
                    return player.Position
                elseif self.cur_attack == 4 then
                    candle.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
                    return candle.Position
                else
                    candle.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
                    return ent.Position
                end
            end
            data.hidden = 1.0
            if not data.spawned then
                data.spawned = true
                for i=0,4 do
                    local e = Isaac.Spawn(Isaac.GetEntityTypeByName("The Ritual's Candle"), Isaac.GetEntityVariantByName("The Ritual's Candle"), 1, ent.Position, Vector(0,0), ent)
                    GODMODE.get_ent_data(e).master = ent
                    GODMODE.get_ent_data(e).index = i + 1
                    e.Position = data:get_position(ent, e, i + 1)
                    table.insert(data.candles, e)
                end
                data.cur_attack = 0
            end
        end

        data.cur_attack = data.cur_attack or 0
        if data.cur_attack ~= 0 then
            if data.hidden > 0 then
                data.hidden = data.hidden - (1 / 40)
            else
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                data.hidden = 0
            end
        else
            if data.hidden > 0.45 then
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            end
            if data.hidden < 1 then
                data.hidden = data.hidden + (1 / 60)
            else
                data.hidden = 1
            end
        end

        ent:SetColor(Color(1.0,1.0,1.0,data.hidden,0,0,0),2,9999,true,true)

        if data.real_time == 2 then
            ent:ToNPC():PlaySound(SoundEffect.SOUND_SATAN_APPEAR, 1.0, 1, false, 0.4 + ent:GetDropRNG():RandomFloat() * 0.2)
            data.phase = 0
            data.attack_time = 0
            data.trans_time = 0
        end
        
        local perce = ent.HitPoints / ent.MaxHitPoints
        if perce <= 0.75 and data.phase < 1 and data.attack_time <= 0 then
            data.phase = 1
            data.trans_time = 1
            ent:GetSprite():Play("Light0", false)
            ent:ToNPC():PlaySound(SoundEffect.SOUND_SATAN_HURT, 1.0, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
        end
        if perce <= 0.5 and data.phase < 2 and data.attack_time <= 0 then
            data.phase = 2
            data.trans_time = 1
            ent:GetSprite():Play("Light1", false)
            ent:ToNPC():PlaySound(SoundEffect.SOUND_SATAN_HURT, 1.0, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
        end
        if perce <= 0.25 and data.phase < 3 and data.attack_time <= 0 then
            data.phase = 3
            data.trans_time = 1
            ent:GetSprite():Play("Light2", false)
            ent:ToNPC():PlaySound(SoundEffect.SOUND_SATAN_HURT, 1.0, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
        end

        if data.phase == 1 and ent:GetSprite():IsFinished("Light0") then
            data.trans_time = 0
        end
        if data.phase == 2 and ent:GetSprite():IsFinished("Light1") then
            data.trans_time = 0
        end
        if data.phase == 3 and ent:GetSprite():IsFinished("Light2") then
            data.trans_time = 0
        end

        ent.FlipX = player.Position.X < ent.Position.X
        data.attack_time = data.attack_time or 0
        data.cur_attack = data.cur_attack or 0
        data.trans_time = data.trans_time or 0
        
        if data.attack_time <= -80+data.phase * 10 and data.trans_time == 0 and data.cur_attack == 0 then
            ent:ToNPC():PlaySound(SoundEffect.SOUND_SATAN_STOMP, 1.0, 1, false, 0.4 + ent:GetDropRNG():RandomFloat() * 0.2)
            local idle_s = "Attack"..tostring(data.phase)
            ent:GetSprite():Play(idle_s, true)

            if data.last_attack <= 0 then 
                data.cur_attack = ent:GetDropRNG():RandomInt(5)
                if data.phase == 3 and ent:GetDropRNG():RandomFloat() < 0.3 then data.cur_attack = 5 end
            else
                while data.cur_attack == data.last_attack do
                    data.cur_attack = ent:GetDropRNG():RandomInt(5)
                    if data.phase == 3 and ent:GetDropRNG():RandomFloat() < 0.3 then data.cur_attack = 5 end
                end    
            end

            data.attack_time = data.attack_times[data.cur_attack]
            data.attack_data = {}

            if data.cur_attack == 2 then 
                data.attack_data.cur_candle = ent:GetDropRNG():RandomInt(6)
            end

            if data.cur_attack == 1 then
                data.attack_data.lit = {1}
                while #data.attack_data.lit < (data.phase + 2) do
                    local ind = ent:GetDropRNG():RandomInt(5)+1
                    local flag = false
                    local recalc = function()
                        flag = true
                        for i=1,#data.attack_data.lit do
                            if data.attack_data.lit[i] == ind then
                                ind = ent:GetDropRNG():RandomInt(5)+1
                                flag = false
                            end
                        end
                    end

                    repeat
                        recalc()
                    until flag == true

                    table.insert(data.attack_data.lit, ind)
                end

                data.attack_data.isLit = function(self, index)
                    for i=1, #self.lit do
                        if self.lit[i] == index then
                            return true
                        end
                    end

                    return false
                end
            end
        end

        local r_off = Vector(math.cos(data.time / 40.0) * 32, math.sin(data.time / 40.0) * 32)
        local targ = Game():GetRoom():GetCenterPos() + r_off
        if data.cur_attack == 5 then targ = Game():GetRoom():GetCenterPos() + r_off * 0.2 end
        ent.Velocity = ent.Velocity * 0.9 + (targ - ent.Position) * (1 / 50)

        if ent:GetSprite():IsEventTriggered("Attack") then
            ent:ToNPC():PlaySound(SoundEffect.SOUND_SATAN_CHARGE_UP, 1.0, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)            
            data.put_out = 30
            if data.cur_attack == 3 then 
                data.put_out = 120
                if GODMODE.util.count_enemies(nil, Isaac.GetEntityTypeByName("Silent"), Isaac.GetEntityVariantByName("Silent")) == 0 then 
                    local silent = Isaac.Spawn(Isaac.GetEntityTypeByName("Silent"),Isaac.GetEntityVariantByName("Silent"),0,ent.Position,ent.Velocity * 0.25,ent)
                    silent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                end
            end
        end

        if data.put_out > 0 then
            data.put_out = data.put_out - 1
        else
            data.put_out = 0
        end

        data.attack_time = (data.attack_time or 0) - 1
        if data.attack_time <= 0 then
            data.last_attack = data.cur_attack
            data.cur_attack = 0
        end
        local att_s = "Attack"..tostring(data.phase)

        if data.attack_time <= 0 and data.trans_time == 0 or ent:GetSprite():IsFinished(att_s) then
            local idle_s = "Idle"..tostring(data.phase)
            ent:GetSprite():Play(idle_s, false)
        end
	end
end

--add unique boss music for the fight!
local music_flag = false
monster.npc_init = function(self, ent)
    if Game():GetRoom():GetType() == RoomType.ROOM_BOSS and Game():GetLevel():GetStage() == LevelStage.STAGE5 and Game():GetLevel():GetStageType() == StageType.STAGETYPE_ORIGINAL then 
        music_flag = true
    end
end
local boss_music = Music.MUSIC_SATAN_BOSS--Isaac.GetMusicIdByName("The Path To Enlightenment")
monster.post_update = function(self)
    if music_flag == true then 
        if MusicManager():GetCurrentMusicID() ~= boss_music and not Game():GetRoom():IsClear() then 
            if GODMODE.util.count_enemies(nil,monster.type,monster.variant) > 0 then 
                MusicManager():Play(boss_music, 1.0)
                MusicManager():UpdateVolume()
            end    
        end
    end

    --SFXManager():AdjustVolume
end
monster.new_level = function(self)
    music_flag = false
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)

    if (enthit.Type == monster.type and enthit.Variant == monster.variant) and (enthit:GetSprite():IsPlaying("Appear") or enthit.Type == monster.type and enthit.Variant == monster.variant and enthit.SubType == 1) then
        return false
    end
end

return monster