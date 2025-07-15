local monster = {}
monster.name = "Door Hazard"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
monster.explode_checks = {} 
local explosion_size = 48

monster.hazard_profile = {
    ["Webbed"]={
        alive_anim = "Webbed",
        dead_anim = "WebbedDead",
        health = 5.0,
        touch_effect = function(ent,player) 
            GODMODE.get_ent_data(player).door_hazard_webbed = 150
            player:SetColor(Color(0.9,0.9,0.9,1,0.1,0.1,0.1),90,1,false,true)    
            return true
        end,
        new_room = function() end
    },
    ["Void"]={
        alive_anim = "Void",
        dead_anim = "VoidDead",
        health = 10.0,
        touch_effect = function(ent,player) 
            local flag = false 

            GODMODE.util.macro_on_enemies(nil,Isaac.GetEntityTypeByName("Call of the Void"),Isaac.GetEntityVariantByName("Call of the Void"),nil,function(void)
                if flag == false then 
                    GODMODE.save_manager.set_data("VoidDMProj",tonumber(GODMODE.save_manager.get_data("VoidDMProj","0"))+1)
                end

                flag = true
            end)

            if not flag then 
                local void = Isaac.Spawn(Isaac.GetEntityTypeByName("Call of the Void"),Isaac.GetEntityVariantByName("Call of the Void"),0,Game():GetRoom():GetCenterPos(),Vector.Zero,nil):ToNPC()
                local data = GODMODE.get_ent_data(void)
                data.spent = 0
                void.I2 = 1 
                data.persistent_state = GODMODE.persistent_state.between_rooms
                void:GetSprite().PlaybackSpeed = 1.25
            end

            ent:Kill()
            monster.npc_kill(nil,ent)

            return true
        end,
        new_room = function() end
    },
    ["Spiked"]={
        alive_anim = "Spiked",
        dead_anim = "SpikedDead",
        health = 10.0,
        touch_effect = function(ent,player) 
            player:TakeDamage(1,DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_SPAWN_RED_HEART,EntityRef(ent),0)
            ent:Kill()
            monster.npc_kill(nil,ent)
            return true
        end,
        new_room = function() end
    },
    ["Wired"]={
        alive_anim = "Wired",
        dead_anim = "WiredDead",
        health = 10.0,
        touch_effect = function(ent,player) 
            ent = ent:ToNPC()
            local slot = GODMODE.util.find_uncharged_active_slot(player)

            if slot > -1 and player:GetActiveItem(slot) > 0 and player:GetActiveCharge(slot) > 0 and ent.I2 == 0 then 
                local charge_lost = math.min(player:GetActiveCharge(slot),2)
                player:SetActiveCharge(player:GetActiveCharge(slot)-charge_lost)
                ent.I2 = 60
                local off = -48
                if charge_lost == 1 then off = -32 end 

                for i=1,charge_lost do 
                    local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.HEART,3,player.Position+Vector(off+i*32,-64),Vector.Zero,ent)
                    fx.DepthOffset = 100                        
                end
                SFXManager():Play(SoundEffect.SOUND_BATTERYDISCHARGE)
                ent:Kill()
                monster.npc_kill(nil,ent)
            end
            return true
        end,
        new_room = function() end
    },
    ["Spooked"]={
        alive_anim = "Spooked",
        dead_anim = "Empty",
        health = 15.0,
        touch_effect = function(ent,player) 
            player:AddFear(EntityRef(ent),120)
            return true
        end,
        new_room = function() end
    },
    ["WiredGood"]={
        alive_anim = "WiredGood",
        dead_anim = "WiredGoodDead",
        health = 5.0,
        touch_effect = function(ent,player) 
            ent = ent:ToNPC()
            local slot = GODMODE.util.find_uncharged_active_slot(player)
            if slot > -1 and player:GetActiveItem(slot) > 0 and ent.I2 == 0 then 
                player:SetActiveCharge(player:GetActiveCharge(slot)+1,slot)
                ent.I2 = 60
                local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.HEART,1,player.Position+Vector(0,-64),Vector.Zero,ent)
                fx.DepthOffset = 100                        
                SFXManager():Play(SoundEffect.SOUND_BEEP)
                ent:Kill()
                monster.npc_kill(nil,ent)
            end
            return true
        end,
        new_room = function() end
    },
}

monster.data_init = function(self, params)
    local ent = params[1]
    local data = params[2]
    data.persistent_state = GODMODE.persistent_state.single_room
    data.hazard_profile = data.hazard_profile or "Webbed"
end

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    local profile = monster.hazard_profile[data.hazard_profile or "Webbed"]
    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.Velocity = Vector.Zero

    if not ent:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then 
        ent:AddEntityFlags(EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_REWARD | EntityFlag.FLAG_NO_PLAYER_CONTROL | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_QUERY | EntityFlag.FLAG_BACKDROP_DETAIL)

        if ent.SubType == 0 then 
            ent.MaxHitPoints = profile.health
            ent.HitPoints = ent.MaxHitPoints    
        end
    end

    if ent.I2 > 0 then 
        ent.I2 = ent.I2 - 1
    end

    if ent.SubType == 0 then 
        if not ent:GetSprite():IsPlaying(profile.alive_anim) then 
            ent:GetSprite():Play(profile.alive_anim,false)
        end

        if Game():GetRoom():IsClear() then 
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        else 
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end
    else
        ent:GetSprite():Play(profile.dead_anim,false)
        data.fadeout_time = math.max(-20,(data.fadeout_time or 101)-1)
        ent:SetColor(Color(1,1,1,math.max(0,data.fadeout_time or 101)/100.0,0,0,0),5,99,false,false)

        if (data.fadeout_time or 101) <= -20 then ent:Remove() end
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    end

    if (data.door_slot or 0) > 0 then 
        if Game():GetRoom():IsDoorSlotAllowed(data.door_slot-1) then 
            local door_pos = Game():GetRoom():GetDoorSlotPosition(data.door_slot-1)
            local ang = math.floor((Game():GetRoom():GetCenterPos() - door_pos):GetAngleDegrees()/90)*90
            ent.Position = door_pos
            ent.SpriteRotation = ((data.door_slot-1)%4)*90-90
        end
    end

    --enables dr. fetus and other explosion based attacks to break the hazards, super fucky but their fault for not adding effect_collide lol
    for index,explode in ipairs(monster.explode_checks) do 
        if (explode.pos - ent.Position):Length() < explode.size then 
            table.remove(monster.explode_checks,index)
            ent:Kill()
            break
        elseif explode.time - Game():GetFrameCount() < -5 then 
            table.remove(monster.explode_checks,index)
            break
        end
    end
end

monster.player_update = function(self, player)
    local data = GODMODE.get_ent_data(player)

    if (data.door_hazard_webbed or 0) > 0 then 
        player.Velocity = player.Velocity * 0.9
        data.door_hazard_webbed = data.door_hazard_webbed - 1
    end
end

monster.npc_kill = function(self, ent)
    local door = Isaac.Spawn(monster.type,monster.variant,1,ent.Position,Vector.Zero,nil)
    door:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    local data = GODMODE.get_ent_data(door)
    data.door_slot = GODMODE.get_ent_data(ent).door_slot
    data.hazard_profile = GODMODE.get_ent_data(ent).hazard_profile
    door:Update()
    door:Update()
end

monster.new_room = function(self)
    GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(door)
        monster.hazard_profile[GODMODE.get_ent_data(door).hazard_profile or "Webbed"].new_room()
    end)
    monster.explode_checks = {}
end

monster.knife_collide = function(self,knife,ent,entfirst)
    if entfirst then 
        ent:TakeDamage(knife.CollisionDamage,0,EntityRef(knife.SpawnerEntity or knife.Parent or knife),0)
    end
end

monster.familiar_collide = function(self,fam,ent,entfirst)
    if entfirst then 
        ent:TakeDamage(fam.CollisionDamage,0,EntityRef(fam.SpawnerEntity or fam.Parent or fam),0)
    end
end


monster.player_collide = function(self,player,ent,entfirst)
    if entfirst and ent.SubType == 0 then 
        local ret = monster.hazard_profile[GODMODE.get_ent_data(ent).hazard_profile or "Webbed"].touch_effect(ent,player)
        if ret ~= nil then
            return ret
        end
    end
end

monster.tear_collide = function(self,tear,ent,entfirst)
    if ent.Type == monster.type and ent.Variant == monster.variant then 
        ent:TakeDamage(tear.CollisionDamage,0,EntityRef(tear.SpawnerEntity or tear.Parent or tear),0)
    end
end

monster.effect_update = function(self,fx)
    if fx.Variant == EffectVariant.BOMB_EXPLOSION and fx.FrameCount == 1 then 
        -- GODMODE.log("test!",true)
        table.insert(monster.explode_checks, {time=Game():GetFrameCount(),pos=fx.Position,size=fx.Scale*explosion_size})

        -- GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(door)
        --     GODMODE.log("hi? len = "..((hazard.Position-fx.Position):Length()),true)
        --     if (hazard.Position-fx.Position):Length() < fx.Size*2 then 
        --         GODMODE.log("hi!",true)
        --         hazard:Kill() 
        --     end 
        -- end)
    end
end

return monster