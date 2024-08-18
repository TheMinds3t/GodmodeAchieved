local monster = {}
monster.name = "The Sacred Body"
monster.type = GODMODE.registry.entities.sacred_body.type
monster.variant = GODMODE.registry.entities.sacred_body.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        ent:GetSprite():Play("Idle",true)
        data.period = 0
        data.hide_state = 0
        data.charge = -50
        if ent:GetSprite():IsPlaying("Death") or ent.HitPoints <= 0  then return nil end

        ent:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
    end
end
monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    local player = ent:GetPlayerTarget()
    local mind_data = GODMODE.get_ent_data(data.mind)

    if sprite:IsPlaying("Death") then
        data.link_function = nil
        return nil
    end
    if not data.charge then self:data_init(ent, data) end

    if not data.mind then 
        sprite:Play("Idle",false) 
    elseif not data.soul then
        data.soul = Isaac.Spawn(GODMODE.registry.entities.sacred_soul.type,GODMODE.registry.entities.sacred_soul.variant, 0, ent.Position, Vector(0,0), ent)
        local bod = GODMODE.get_ent_data(data.soul)
        bod.body = ent
        bod.link_function = data.link_function
        bod.move_function = data.move_function
        if data.mind ~= nil then
            bod.mind = data.mind
            mind_data.soul = data.soul
        end
    elseif data.charge <= -50 then
        data.move_function(ent,mind_data.phase,1)
    else
        if data.charge == -51 then
            ent:ToNPC():PlaySound(GODMODE.registry.sounds.sacred1, 1.0, 1, false, 0.6 + ent:GetDropRNG():RandomFloat() * 0.2)
        end

        data.charge = data.charge - 1
        if data.charge % 5 == 0 then
            ent.Velocity = ent.Velocity * 1.125
        end
        if data.charge % 3 == 0 then
            local p = ProjectileParams()
            p.BulletFlags = p.BulletFlags + ProjectileFlags.SMART
            p.FallingSpeedModifier = 0.01
            p.FallingAccelModifier = 0.01
            p.GridCollision = false
            p.Color = Color(0.25,0.65,0.65,1.0,200/255,200/255,200/255)
            local cen = GODMODE.room:GetCenterPos()
            local r = math.rad(ent.Velocity:GetAngleDegrees() - 180 + ent:GetDropRNG():RandomInt(46) - 22.5)
            local off = Vector(math.cos(r)*192,math.sin(r)*192)
            p.Scale = 1.0
            p.VelocityMulti = 1.0
            p.HeightModifier = 1.0
            p.HomingStrength = 0.25
            p.CurvingStrength = 0.05
            local bul = ent:ToNPC():FireBossProjectiles(1, ent.Position + off, 1.2+ent:GetDropRNG():RandomFloat()*0.25, p)
            bul:AddHeight(-25.0)
        end
        
        if data.charge == -40 and data.mind then
            mind_data.phase = mind_data.phase + 1
        end
    end

    if data.soul ~= nil then
        GODMODE.get_ent_data(data.soul).body = ent
        GODMODE.get_ent_data(data.soul).mind = data.mind
    end

    if data.hide_state <= 0 then ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS end
    if data.hide_state > 0 then ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE end

    if data.mind and data.soul then
        data.link_function(ent,data.mind,data.soul)

        if data.mind:IsDead() or data.soul:IsDead() and not sprite:IsPlaying("Death") and not ent:IsDead() then
            ent:Kill()
        end
    end 


    if mind_data.phase ~= 1 and mind_data.phase ~= 3 then data.period = 0 end
    if mind_data.phase ~= 1 and mind_data.phase ~= 3 then
        if data.hide_state == 0 then
            sprite:Play("Hide",false)

            if sprite:IsFinished("Hide") then
                data.hide_state = 1
                sprite:Play("HiddenIdle",true)
            end
        end
    else
        if data.hide_state == 1 then
            sprite:Play("GhostAppear",false)

            if sprite:IsFinished("GhostAppear") then
                data.hide_state = 0
                sprite:Play("Idle", true)
                ent:ToNPC():PlaySound(GODMODE.registry.sounds.sacred_appear, 0.5, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
            end
        end
    end

    if mind_data.phase == 1 and data.hide_state == 0 and not sprite:IsPlaying("Attack") then
        data.period = data.period + 1
        if data.period >= 60 then
            sprite:Play("Attack", true)
            data.period = 0
            data.hide_state = -1
            ent:ToNPC():PlaySound(GODMODE.registry.sounds.sacred_2, 1.0, 25, false, 0.6 + ent:GetDropRNG():RandomFloat() * 0.2)
        end
    end
    if mind_data.phase == 3 and not sprite:IsPlaying("GroupAttack") then
        data.period = data.period + 1

        if data.period == 91 then
            ent:ToNPC():PlaySound(GODMODE.registry.sounds.sacred_2, 1.0, 25, false, 0.8)
        end

        if data.period >= 92 then
            sprite:Play("GroupAttack", true)
            data.period = 0
            data.hide_state = -1
        end
    end

    if sprite:IsFinished("Attack") then
        data.hide_state = 0
        sprite:Play("Idle", true)
    end
    if sprite:IsFinished("GroupAttack") then
        data.hide_state = 0
        sprite:Play("Idle", true)
    end

    if sprite:IsEventTriggered("Attack") then
        if sprite:IsPlaying("Attack") then
            local ang = math.rad((player.Position - ent.Position):GetAngleDegrees())
            ent.Velocity = Vector(math.cos(ang)*6,math.sin(ang)*6)
            data.charge = 40
        else
            local p = ProjectileParams()
            p.BulletFlags = p.BulletFlags + ProjectileFlags.SMART
            p.FallingSpeedModifier = 0.001
            p.FallingAccelModifier = 0.001
            p.GridCollision = false
            p.Color = Color(0.25,0.65,0.65,1.0,200/255,200/255,200/255)
            p.HomingStrength = 0.5
            p.CurvingStrength = 0.05
            p.Spread = 180
            local ra = ent:GetDropRNG():RandomInt(72)
            for i=0,2 do
                local cen = GODMODE.room:GetCenterPos()
                local r = math.rad((data.soul.Position - ent.Position):GetAngleDegrees() + ent:GetDropRNG():RandomFloat() * 45 - 22.5)
                local off = Vector(math.cos(r)*192,math.sin(r)*192)
                p.Scale = 1.0
                p.VelocityMulti = 1.5
                p.HeightModifier = 2.0
                local bul = ent:ToNPC():FireBossProjectiles(1, ent.Position + off*2, 1.5, p)
            end
        end
    end --if spawned without a Mind
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