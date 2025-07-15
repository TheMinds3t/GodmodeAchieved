local monster = {}
-- monster.data gets updated every callback
monster.name = "Lucifer"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
--monster.subtype = 0 --deobfuscated
--monster.subtype_sensitive = false --deobfuscated

monster.postUpdate = function(self)
end
monster.npcUpdate = function(self, ent)
	local data = self.data
    local player = Isaac.GetPlayer(0)
    ent.SplatColor = Color(0,0,0,0,255,255,255)
    if data.time == 1 then
        if ent.SubType == 0 then
                ent:GetSprite():Play("Eye", true)
                data.current_phase = 0
                data.cur_attack = ent:GetDropRNG():RandomFloat()
                data.attack_time = 200 + ent:GetDropRNG():RandomFloat() * 30
            elseif ent.SubType == 1 then
                ent:GetSprite():Play("Hand", true)
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                ent.Position = player.Position
            elseif ent.SubType == 2 then
                ent:GetSprite():Play("Eye", true)
                ent.Position = Game():GetRoom():GetCenterPos()
            elseif ent.SubType == 3 then
                data.attacks_left = 20 + ent:GetDropRNG():RandomFloat() * 8
                ent:GetSprite():Play("Invisible", true)
                data.attack_style = ent:GetDropRNG():RandomFloat()
            elseif ent.SubType == 4 then
                data.attacks_left = 20 + ent:GetDropRNG():RandomFloat() * 8
                ent:GetSprite():Play("Invisible", true)
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            elseif ent.SubType == 5 then
                ent:GetSprite():Play("Eye", true)
            elseif ent.SubType == 6 then
                data.attacks_left = 20 + ent:GetDropRNG():RandomFloat() * 8
                ent:GetSprite():Play("Invisible", true)
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            elseif ent.SubType == 7 then
                data.attacking = false
                ent:GetSprite():Play("Mouth", true)
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            elseif ent.SubType == 8 then
                data.attacking = false
                ent:GetSprite():Play("HandSlam", true)
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            end
    else
        if data.time == 2 then
            
        end
        
        local spr = ent:GetSprite()

        if ent.SubType == 8 then
            if ent:GetSprite():IsEventTriggered("Action") then
                Game():Spawn(1000, 63, ent.Position, Vector(0,0), player, 0, player.InitSeed)
                Game():Spawn(1000, 73, ent.Position, Vector(0,0), player, 0, player.InitSeed)
            end

        elseif ent.SubType == 0 then
            data.attack_time = data.attack_time - 1

            if data.attack_time <= 0 then
                local atc = nil
                if data.current_phase == 0 then
                    if data.cur_attack < 0.4 then
                        atc = Game():Spawn(800, 141, Vector(-256,-256), Vector(0,0), player, 2, player.InitSeed)
                        data.attack_time = 100 + ent:GetDropRNG():RandomFloat() * 30
                    elseif data.cur_attack < 0.75 then
                        atc = Game():Spawn(800, 141, Vector(-256,-256), Vector(0,0), player, 3, player.InitSeed)
                        data.attack_time = 150 + ent:GetDropRNG():RandomFloat() * 30
                    else
                        atc = Game():Spawn(800, 141, Vector(-256,-256), Vector(0,0), player, 4, player.InitSeed)
                        data.attack_time = 5000 + ent:GetDropRNG():RandomFloat() * 30
                    end
                elseif data.current_phase == 1 then
                    if data.cur_attack < 0.4 then
                        atc = Game():Spawn(800, 141, Vector(-64,-64), Vector(0,0), player, 2, player.InitSeed)
                        data.attack_time = 100 + ent:GetDropRNG():RandomFloat() * 30
                    elseif data.cur_attack < 0.6 then
                        atc = Game():Spawn(800, 141, Vector(-256,-256), Vector(0,0), player, 6, player.InitSeed)
                        data.attack_time = 150 + ent:GetDropRNG():RandomFloat() * 30
                    elseif data.cur_attack < 0.8 then
                        atc = Game():Spawn(800, 141, Vector(-256,-256), Vector(0,0), player, 4, player.InitSeed)
                        data.attack_time = 5000 + ent:GetDropRNG():RandomFloat() * 30
                    else
                        atc = Game():Spawn(800, 141, Vector(-256,-256), Vector(0,0), player, 7, player.InitSeed)
                        data.attack_time = 160 + ent:GetDropRNG():RandomFloat() * 30
                    end
                end

                if atc then
                    getEntData(atc).master = ent
                end
                data.cur_attack = ent:GetDropRNG():RandomFloat()
            end

            if data.current_phase == 1 and data.attack_time == 60 then
                local atc = nil
                if data.current_phase == 1 then
                    if data.cur_attack < 0.4 then
                        --atc = Game():Spawn(800, 141, Vector(-256,-256), Vector(0,0), player, 2, player.InitSeed)
                        --data.attack_time = 100 + ent:GetDropRNG():RandomFloat() * 30
                    elseif data.cur_attack < 0.6 then
                        --atc = Game():Spawn(800, 141, Vector(-256,-256), Vector(0,0), player, 3, player.InitSeed)
                        --data.attack_time = 150 + ent:GetDropRNG():RandomFloat() * 30
                    elseif data.cur_attack < 0.8 then
                        --atc = Game():Spawn(800, 141, Vector(-256,-256), Vector(0,0), player, 4, player.InitSeed)
                        --data.attack_time = 5000 + ent:GetDropRNG():RandomFloat() * 30
                    else

                    end
                end

                if atc then
                    getEntData(atc).master = ent
                end
            end
        end

        if data.time < 200 and ent.SubType == 0 then
            ent.MaxHitPoints = 3000
            ent.HitPoints = data.time * 15
        end

        if spr:IsPlaying("Eye") then
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            if spr:GetFrame() == 58 then
                if ent.SubType ~= 0 then ent:Kill() else
                end
            end

            if spr:GetFrame() == 20 and ent.SubType == 2 and getEntData(data.master).current_phase == 1 then
                local e = Game():Spawn(800, 141, Vector(-256,-256), Vector(0,0), player, 1, player.InitSeed)
                getEntData(e).master = data.master
            end
            if spr:GetFrame() == 40 and ent.SubType == 2 then
                local e = Game():Spawn(800, 141, Vector(-256,-256), Vector(0,0), player, 1, player.InitSeed)
                getEntData(e).master = data.master
            end
        end

        if spr:IsPlaying("Hand") and ent.SubType == 1 then
            ent.Position = ent.Position + player.Velocity / 4
            if not data.master or getEntData(data.master).current_phase == 1 then
                ent.Position = ent.Position + player.Velocity / 3
            end
            if spr:GetFrame() == 90 then
                ent:Kill()
            end
            if spr:GetFrame() == 5 then
                ent.CollisionDamage = 1
            end

            if spr:IsEventTriggered("Action") then
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            end
        end

        if ent.HitPoints <= 0 then ent:Kill() end
        if ent.HitPoints / ent.MaxHitPoints <= 0.5 and data.current_phase == 0 and data.time > 200 then data.current_phase = 1 data.roar_time = 100 ent.MaxHitPoints = 2500 end

        if data.roar_time and data.roar_time > 0 then
            Game():ShakeScreen(3)
            data.roar_time = data.roar_time - 1
            ent.HitPoints = math.floor(ent.MaxHitPoints / 2) + math.floor(ent.MaxHitPoints / 2 * (1.0 - data.roar_time / 100))
        end

        if ent.SubType == 3 then
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            if data.attack_style < 0.325 then
                if data.time % 10 == 0 then
                    for i=0,3 do
                        local ang = (data.time+data.time / 2+i*90) % 360 + 180
                        local v = Vector(math.cos(math.rad(ang)),math.sin(math.rad(ang)))
                        Game():Spawn(800, 200, Game():GetRoom():GetCenterPos() + v * 48, Vector(0,0), player, math.floor(ang), player.InitSeed)
                    end
                    data.attacks_left = data.attacks_left - 2
                end
            elseif data.attack_style < 0.65 then
                if data.time % 10 == 0 then
                    for i=0,3 do
                        local ang = (-data.time-data.time / 2+i*90) % 360 + 180
                        local v = Vector(math.cos(math.rad(ang)),math.sin(math.rad(ang)))
                        Game():Spawn(800, 200, Game():GetRoom():GetCenterPos() + v * 48, Vector(0,0), player, math.floor(ang), player.InitSeed)
                    end
                    data.attacks_left = data.attacks_left - 2
                end
            elseif data.attack_style < 1.0 then
                if data.time % 5 == 0 then
                    local ang = ent:GetDropRNG():RandomFloat() * 360
                    local v = Vector(math.cos(math.rad(ang)),math.sin(math.rad(ang)))
                    Game():Spawn(800, 200, Isaac.GetRandomPosition() + v * 48, Vector(0,0), player, math.floor(ang), player.InitSeed)
                    data.attacks_left = data.attacks_left - 1
                end
            end

            if data.attacks_left <= 0 then
                ent:Kill()
            end
        end

        if ent.SubType == 6 then
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            
            if data.time % 5 == 0 then
                local w = ent:GetDropRNG():RandomFloat()
                local r = Game():GetRoom()
                local tl = r:GetTopLeftPos()
                local br = r:GetBottomRightPos()
                local ws = {{tl.X,tl.Y,ent:GetDropRNG():RandomFloat()*(br.X-tl.X),0,180},{tl.X,tl.Y,0,ent:GetDropRNG():RandomFloat()*(br.Y-tl.Y),90},{br.X,br.Y,-ent:GetDropRNG():RandomFloat()*(br.X-tl.X),0,0},{br.X,br.Y,0,-ent:GetDropRNG():RandomFloat()*(br.Y-tl.Y),270}}
                local use = 0
                if w < 0.25 then use = 1 elseif w < 0.5 then use = 2 elseif w < 0.75 then use = 3 else use = 4 end
                for i=0,2 do
                    local ang = ws[use][5] - 90
                    local v = Vector(math.cos(math.rad(ang)),math.sin(math.rad(ang)))
                    Game():Spawn(EntityType.ENTITY_PROJECTILE, 0, Vector(ws[use][1]+ws[use][3],ws[use][2]+ws[use][4]) + v * 16, v * (4 + (i * 1.5)), player, 0, player.InitSeed)
                end
                data.attacks_left = data.attacks_left - 0.75
            end

            if data.attacks_left <= 0 then
                ent:Kill()
            end
        end

        if ent.SubType == 7 then
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            
            if spr:IsEventTriggered("Action") then
                data.attacking = not data.attacking
            end
            player.Position = player.Position + (ent.Position - player.Position) * (1 / 90)
            local room = Game():GetRoom()
            if data.time % 2 == 0 and data.attacking then
                local pos = ent.Position + Vector(ent:GetDropRNG():RandomFloat()*352-176,ent:GetDropRNG():RandomFloat()*288-144)
                local a = ent.Position - pos
                local ang = a:GetAngleDegrees()
                local v = Vector(math.cos(math.rad(ang)),math.sin(math.rad(ang)))
                Game():Spawn(EntityType.ENTITY_PROJECTILE, 0, pos - v * 16, v * (4 + ent:GetDropRNG():RandomFloat()), player, 0, player.InitSeed)
            end

            if spr:GetFrame() == 138 then
                ent:Kill()
            end
        end

        if ent.SubType == 4 then
            if data.time % 20 == 0 then
                local flag = false
                for i=1, #Isaac.GetRoomEntities() do
                    if Isaac.GetRoomEntities()[i]:IsVulnerableEnemy() and not Isaac.GetRoomEntities()[i].Type == 800 and not Isaac.GetRoomEntities()[i].Variant == 140 and not Isaac.GetRoomEntities()[i].Variant == 141 then
                        flag = true
                    end
                end
                if not flag then
                    if data.master then getEntData(data.master).attack_time = 0 end
                    ent:Kill()
                end
            end
        end

        if data.hidden then
            ent.Position = Vector(-128,-128)
        end
        ent.Velocity = Vector(0,0)
    end
end
monster.postRender = function(self)
end
monster.entityDamaged = function(self,enthit,amount,flags,entsrc,countdown)
    getEntData(enthit.Entity).master.HitPoints = getEntData(enthit.Entity).master.HitPoints - dmg_amount
    enthit.Entity.HitPoints = enthit.Entity.HitPoints + dmg_amount
    return false
end
monster.postRoomCleared = function(self)
end
monster.newRoom = function(self)
end
monster.newLevel = function(self)
end
return monster