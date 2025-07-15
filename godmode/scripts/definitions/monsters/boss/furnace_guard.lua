local monster = {}
monster.name = "Furnace Guard"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, params)
    local ent = params[1]
    local data = params[2]
    local bonus = math.min(250,(GODMODE.util.get_basic_dps(ent) / 10.0) * 100)
    if ent.SubType > 0 then bonus = 0 end

    ent.MaxHitPoints = ent.MaxHitPoints + bonus
    ent.HitPoints = ent.MaxHitPoints
end
monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end    
    local player = ent:GetPlayerTarget()
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS 

    if ent.SubType == 0 then --large
        if not ent:GetSprite():IsPlaying("Idle") and not ent:GetSprite():IsPlaying("Dash") and not ent:GetSprite():IsPlaying("DashLeft") then
            ent:GetSprite():Play("Idle",true)
        end
    
        local ti = player.Position - ent.Position
        local spd = 2.35
        if not ent:GetSprite():IsPlaying("Idle") then spd = 1.0 end
        ent.Position = ent.Position + Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)
        
        if ent:GetDropRNG():RandomFloat() < 0.8 and ent:IsFrame(30,5) and ent:GetSprite():IsPlaying("Idle") then
            if player.Position.X > ent.Position.X then
                ent:GetSprite():Play("Dash",true)
            else
                ent:GetSprite():Play("DashLeft",true)
            end
        end
    
        if ent:GetSprite():IsEventTriggered("End") then
            ent:GetSprite():Play("Idle",true)
        end
    
        if ent:GetSprite():IsEventTriggered("Dash") then
            local ti = player.Position - ent.Position
            local spd = 4.5
            ent.Velocity = ent.Velocity + Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)
        end
    
        if ent:GetSprite():IsEventTriggered("EndDash") then
            ent.Velocity = ent.Velocity * 0.5
        end    
    else --small
        local data = GODMODE.get_ent_data(ent)
        data.rush_timer = (data.rush_timer or 0) - 1
        data.rush_offset = data.rush_offset or Vector(0,0)

        if not ent:GetSprite():IsPlaying("Appear") then
            ent:GetSprite():Play("Idle", false)
        end

        if data.rush_timer < 0 then
            ent.Velocity = ent.Velocity * 0.9
        else
            if data.rush_timer > 6 then
                local ti = (player.Position+data.rush_offset) - ent.Position
                local spd = 2.5
                ent.Velocity = ent.Velocity + Vector(
                        math.cos(math.rad(ti:Rotated(ent:GetDropRNG():RandomFloat()*90-45):GetAngleDegrees())) * spd,
                        math.sin(math.rad(ti:Rotated(ent:GetDropRNG():RandomFloat()*90-45):GetAngleDegrees())) * spd)    
            else
                ent.Velocity = ent.Velocity * 0.95
            end
        end

        if ent:GetSprite():IsEventTriggered("Rush") then
            data.rush_timer = 10
            local radius = 96
            data.rush_offset = Vector(ent:GetDropRNG():RandomFloat()*radius-radius/2,ent:GetDropRNG():RandomFloat()*radius-radius/2)
        end
    
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)

    if (enthit.Type == monster.type and enthit.Variant == monster.variant) and (enthit:GetSprite():IsPlaying("Appear") or flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER and entsrc.Type ~= 1) then 
        return false 
    end
end

return monster