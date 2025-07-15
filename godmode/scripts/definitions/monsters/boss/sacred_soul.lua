local monster = {}
monster.name = "The Sacred Soul"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, params)
    local ent = params[1]
    local data = params[2]

    if ent:IsDead() or ent.HitPoints <= 0 then return nil end 

    ent:GetSprite():Play("Idle",true)
    data.period = 0
    data.hide_state = 0
    data.cur_wave = 0

    data.tears = {}

    ent:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
end
monster.spawn_tear = function(self, ent, ang, speed, height, curve)
    if curve == nil then curve = 0 end
    if height == nil then height = 1.0 end
    local ang = math.rad(ang)
    local spd = speed
    local tear = Game():Spawn(EntityType.ENTITY_PROJECTILE,0,Vector(ent.Position.X+math.cos(ang)*spd,ent.Position.Y+math.sin(ang)*spd),Vector(math.cos(ang)*spd*1.2,math.sin(ang)*spd),ent,0,ent:GetPlayerTarget().InitSeed)
    tear = tear:ToProjectile()
    tear.Height = tear.Height * height
    tear.Scale = 1.0 / speed
    if curve > 0 then
        tear.ProjectileFlags = ProjectileFlags.SMART
        tear.HomingStrength = 0.5
        tear.CurvingStrength = curve
    end
    --tear.Position = tear.Position + off
    tear.Color = Color(0.25,0.25,0.25,1.0,(59.0)/255,(107.0)/255,(203.0)/255)
    table.insert(GODMODE.get_ent_data(ent).tears, {tear,tear.Height})
    tear.Height = -1000
    return tear
end
monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    local player = ent:GetPlayerTarget()
	local data = GODMODE.get_ent_data(ent)
    if ent:GetSprite():IsPlaying("Death") then
        data.link_function = nil
        return nil
    end

    if not data.mind then 
        ent:GetSprite():Play("Idle",false) else 

    data.move_function(ent, GODMODE.get_ent_data(data.mind).phase,2)
    if data.hide_state == nil then self:data_init(ent, data) end
    if data.hide_state <= 0 then ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS end
    if data.hide_state > 0 then ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE 
    end

    if data.body and data.mind then
        data.link_function(ent,data.body,data.mind)

        if data.body:IsDead() or data.mind:IsDead() and not ent:GetSprite():IsPlaying("Death") and not ent:IsDead() then
            ent:Kill()
        end
    end

    if GODMODE.get_ent_data(data.mind).phase ~= 2 and GODMODE.get_ent_data(data.mind).phase ~= 3 then data.period = 0 end
    if GODMODE.get_ent_data(data.mind).phase ~= 2 and GODMODE.get_ent_data(data.mind).phase ~= 3 then
        if data.hide_state == 0 then
            ent:GetSprite():Play("Hide",false)

            if ent:GetSprite():IsFinished("Hide") then
                data.hide_state = 1
                ent:GetSprite():Play("HiddenIdle",true)
            end
        end
    else
        if data.hide_state == 1 then
            if not ent:GetSprite():IsPlaying("GhostAppear") and not ent:GetSprite():IsPlaying("Idle") and GODMODE.get_ent_data(data.mind).phase == 2 then
                ent:ToNPC():PlaySound(GODMODE.sounds.sacred_appear, 0.3, 25, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
            end

            ent:GetSprite():Play("GhostAppear",false)

            if ent:GetSprite():IsFinished("GhostAppear") then
                data.hide_state = 0
                ent:GetSprite():Play("Idle", true)
            end
        end
    end

    if GODMODE.get_ent_data(data.mind).phase == 2 and data.hide_state == 0 and not ent:GetSprite():IsPlaying("Attack") then
        data.period = data.period + 1
        if data.period >= 60 then
            ent:GetSprite():Play("Attack", true)
            data.hide_state = -1
            data.period = 0
            ent:ToNPC():PlaySound(GODMODE.sounds.sacred_3, 1.0, 180, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
            
            local rings = 5
            local density = 6
            local tear_ang = 360 / density
            local off = ent:GetDropRNG():RandomFloat() * tear_ang / rings
            for i=1,rings do
                local ring_off = tear_ang / rings * i * 2 + off
                local speed = 1.2 - (i / rings) * 0.8
                for l=1,density do
                    local ang = ring_off + tear_ang * l
                    monster:spawn_tear(ent, ang, speed, 1.0, 0.0)
                end
            end
        end
    end
    if GODMODE.get_ent_data(data.mind).phase == 3 and not ent:GetSprite():IsPlaying("GroupAttack") then
        data.period = data.period + 1

        if data.period == 87 then
            ent:ToNPC():PlaySound(GODMODE.sounds.sacred_3, 1.0, 25, false, 1.0)
        end

        if data.period >= 88 then
            ent:GetSprite():Play("GroupAttack", true)
            data.hide_state = -1
            data.period = 0
        end
    end

    if ent:GetSprite():IsPlaying("Attack") and data.cur_wave == 0 then
        
        
    end

    if ent:GetSprite():IsFinished("Attack") then
        local e = Isaac.GetRoomEntities()
        data.hide_state = 0
        GODMODE.get_ent_data(data.mind).phase = GODMODE.get_ent_data(data.mind).phase + 1
        data.cur_wave = 0
        ent:GetSprite():Play("Idle", true)
    end
    if ent:GetSprite():IsFinished("GroupAttack") then
        data.hide_state = 0
        ent:GetSprite():Play("Idle", true)
    end

    if ent:GetSprite():IsEventTriggered("Attack") then
        if ent:GetSprite():IsPlaying("Attack") then
            data.cur_wave = data.cur_wave + 1
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
            local ra = ent:GetDropRNG():RandomInt(73)
            for i=0,2 do
                local cen = Game():GetRoom():GetCenterPos()
                local r = math.rad((data.mind.Position - ent.Position):GetAngleDegrees()+ent:GetDropRNG():RandomFloat() * 45 - 22.5)
                local off = Vector(math.cos(r)*192,math.sin(r)*192)
                p.Scale = 1.0
                p.VelocityMulti = 1.5
                p.HeightModifier = 2.0
                local bul = ent:ToNPC():FireBossProjectiles(1, ent.Position + off*2, 1.5, p)
            end
        end
    end


    if data.tears == nil then data.tears = {} else
        if #data.tears > 0 then
            for i=1,#data.tears do
                local tear = data.tears[i]
                if tear ~= nil then
                    if math.abs(tear[1].Height-data.tears[i][2]) > 0.05 then
                        tear[1].Height = (tear[1].Height * 9 + data.tears[i][2] * tear[1].Scale) / (9 + tear[1].Scale)
                    else
                        tear[1].Height = data.tears[i][2]
                        table.remove(data.tears, i)
                    end

                    local dir = 0
                    if tear[1].Position.X < ent.Position.X then dir = 1 else dir = -1 end
                    if data.cur_wave ~= 0 then dir = dir * -1 end
                    tear[1].Velocity = tear[1].Velocity * 1.0325 + Vector(dir * ent:GetSprite():GetFrame() / 7.5 * 0.01,0.0)
                end
            end
        end
    end

    end -- if spawned without a mind
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)

    if (enthit.Type == monster.type and enthit.Variant == monster.variant) 
        and (enthit.FrameCount < 120 or enthit:GetSprite():IsPlaying("Appear") or (flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION or flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER) and entsrc.Type ~= 1 or (entsrc.Type == EntityType.ENTITY_EFFECT and entsrc.Variant == EffectVariant.CRACK_THE_SKY)) then
        return false
    end
end

return monster