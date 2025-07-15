local monster = {}
monster.name = "Bowl Play (Corny)"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

local subs = {
    corny_head = 0,
    head = 1,
    corny_body = 2,
    body = 3
}

local body_y_size = 25
local body_fly_vel = 7.0

local status_flags = {EntityFlag.FLAG_POISON,EntityFlag.FLAG_BURN,EntityFlag.FLAG_BLEED_OUT,EntityFlag.FLAG_BAITED}

monster.spawn_flat_tear = function(self, ent, ang, speed, height)
    if curve == nil then curve = 0 end
    if height == nil then height = 1.0 end
    local ang = math.rad(ang)
    local spd = speed
    local vel = Vector(math.cos(ang)*spd,math.sin(ang)*spd)
    local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_CORN,0,ent.Position+vel,vel,ent)
    tear = tear:ToProjectile()
    tear.Height = tear.Height * height
    tear.FallingAccel = (-5.0/60.0)
    local size_dif = 0.5
    tear.Scale = 1.0+size_dif-ent:GetDropRNG():RandomFloat()*size_dif
    return tear
end

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()

    if (data.enraged or 0) == 1 then 
        ent:SetColor(Color(1,1,1,1,0.25,0,0),999,1,false,true)
        ent:GetSprite().PlaybackSpeed = 1.2
    end

    if ent.SubType == subs.corny_head or ent.SubType == subs.head then 
        ent.GroupIdx = ent.SubType + 1 

        if data.body == nil then 
            data.body = {}
            ent.I1 = 3

            for i=0,ent.I1-1 do 
                local body_seg = Isaac.Spawn(monster.type,monster.variant,ent.SubType + 2,ent.Position,Vector.Zero,ent):ToNPC()
                GODMODE.get_ent_data(body_seg).head = ent 
                table.insert(data.body, body_seg)
                body_seg.I1 = #data.body
                body_seg.GroupIdx = ent.GroupIdx
                body_seg.Parent = ent
            end
        else 
            local targ_y = -body_y_size * (#data.body)+math.cos(ent.FrameCount / 30.0)*8 + 8
            ent.SpriteOffset = Vector(0,(ent.SpriteOffset.Y*9 + targ_y) / 10.0)
            ent.DepthOffset = -targ_y

            data.anchor_pos = (data.anchor_pos or ent.Position)

            if ent.SubType == subs.corny_head then 
                ent.V1 = Vector(math.cos(ent.FrameCount/25.0)*80,math.sin(ent.FrameCount/25.0)*96)
            else
                ent.V1 = Vector(math.cos(ent.FrameCount/25.0+7.5)*80,math.sin(ent.FrameCount/25.0+7.5)*96)
            end

            ent.Velocity = ent.Velocity * 0.5 + (((data.anchor_pos or Game():GetRoom():GetCenterPos())+ent.V1) - ent.Position) / 120.0
            ent.I1 = #data.body
        end

        if not ent:GetSprite():IsPlaying("Head"..ent.GroupIdx) and not ent:GetSprite():IsPlaying("Attack"..ent.GroupIdx) and not ent:GetSprite():IsPlaying("Launch"..ent.GroupIdx) then 
            data.enraged = 1 - GODMODE.util.count_enemies(nil,ent.Type,ent.Variant,(ent.SubType+1)%2)
            local intro_flag = ent.FrameCount > 40
            if intro_flag and (data.fire_cooldown or 0) == 0 and ent:GetDropRNG():RandomFloat() < 0.5 and #data.body > math.max(1,1+math.floor((ent.HitPoints+ent.MaxHitPoints/2)/ent.MaxHitPoints)-(data.enraged or 0)) then 
                ent:GetSprite():Play("Launch"..ent.GroupIdx,true)
            else
                local min_spread = math.min(1.0,1.0 - math.floor((ent.HitPoints+ent.MaxHitPoints/4*3)/ent.MaxHitPoints)+(data.enraged or 0))
                if (data.fire_cooldown or 0) == 1 or intro_flag and (data.spread_mod or 0) == min_spread and ent:GetDropRNG():RandomFloat() < 0.5 then 
                    ent:GetSprite():Play("Attack"..ent.GroupIdx,true) 
                    data.spread_mod = min_spread
                    data.fire_cooldown = 0
                else
                    ent:GetSprite():Play("Head"..ent.GroupIdx,true) 
                    data.spread_mod = math.max(min_spread,(data.spread_mod or 0) - 1)
                    -- GODMODE.log("state="..(data.spread_mod or 0),true)
                end
            end
        end

        if ent:GetSprite():IsEventTriggered("Attack") then 
            local count = 1 + (data.spread_mod or 0)
            local ang = (player.Position - ent.Position):GetAngleDegrees()
            local spread = (115+count * 25)/count
            for i=-count,count do 
                local tear = monster:spawn_flat_tear(ent,
                    ang+i*spread/2.0,
                    2.25+(3-(data.spread_mod or 0))*1.5+(Game().Difficulty % 2)*3+(data.enraged or 0),
                    1.125)
            end

            data.spread_mod = (data.spread_mod or 0) + 1 
        end

        if ent:GetSprite():IsEventTriggered("Launch") and #data.body > 1 then 
            local body = data.body[ent.I1]
            table.remove(data.body,ent.I1)
            ent.I1 = ent.I1 - 1

            data.fire_cooldown = (data.enraged or 0)

            body.GroupIdx = 0
            body.I2 = 40
            body.Parent = nil

            if player ~= nil then 
                local spread = 5
                body.Velocity = (player.Position - ent.Position):Rotated(spread/2 + ent:GetDropRNG():RandomFloat()*spread):Resized(body_fly_vel+(data.enraged or 0)*3)
            else 
                body.Velocity = RandomVector():Resized(body_fly_vel+(data.enraged or 0)*2)
            end

            body.I1 = 0    
        end
    else --body
        local max = 1
        local off = 20/max
        local dampened_off = math.min(off,(1 / ((max+1 - ent.I1)*off)))
        local rot_adjust = -ent.SpriteRotation * 0.9

        if ent.Parent ~= nil then 
            local head = ent.Parent:ToNPC()
            max = math.max(1,head.I1)
            dampened_off = math.min(off,(1 / ((max+1 - ent.I1)*off)))

            if head.FrameCount > 3 and ent.GroupIdx > 0 then 
                local off = 120/max
    
                if head.I1 ~= 0 then 
                    ent.Velocity = ent.Velocity * 0.9 + (head.Position-ent.Position) * math.min(off,(1 / ((max+1 - ent.I1)*off)))
                end    
            end

            for _,flag in ipairs(status_flags) do 
                if ent:HasEntityFlags(flag) then 
                    ent:ClearEntityFlags(flag)
                end
            end

            rot_adjust = ent.SpriteRotation + (head.Position.X - ent.Position.X) * dampened_off
            data.enraged = GODMODE.get_ent_data(ent.Parent).enraged 

            if ent.Parent:IsDead() then 
                ent.GroupIdx = 0
                ent.I2 = 40
                ent.Parent = nil
                ent.I1 = 0
                ent.Velocity = RandomVector():Resized(body_fly_vel + (data.enraged or 0)*2)    
            end

        else 
            ent.SpriteOffset = Vector(0,ent.SpriteOffset.Y * 4 / 5.0)
        end
            
        if ent.I2 > 0 then ent.I2 = ent.I2 - 1 end

        local targ_y = -body_y_size * (ent.I1-1)+math.cos(ent.FrameCount / 30.0)*(8-8*dampened_off) + 8

        if ent.GroupIdx == 0 then 
            targ_y = 0 
            ent.SpriteRotation = math.floor((ent.SpriteRotation * 19 + 0) / 20.0)
            if math.abs(ent.SpriteRotation) < 2 then ent.SpriteRotation = 0 end 
            if ent.V1:Length() == 0 then 
                ent.V1 = ent.Velocity
            end

            ent.Velocity = ent.Velocity:Resized(body_fly_vel + (data.enraged or 0)*2)
            -- GODMODE.log("fly="..(body_fly_vel)..",en="..(data.enraged or 0)*3,true)

            if ent.Velocity.X > 0 and ent.V1.X < 0 or ent.Velocity.X < 0 and ent.V1.X > 0 or ent.Velocity.Y > 0 and ent.V1.Y < 0 or ent.Velocity.Y < 0 and ent.V1.Y > 0 then 
                local poop = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOP_EXPLOSION,0,ent.Position,Vector.Zero,ent)
                poop.DepthOffset = -100
                ent:BloodExplode()

                if GODMODE.util.count_enemies(nil,ent.Type,ent.Variant,subs.head)+GODMODE.util.count_enemies(nil,ent.Type,ent.Variant,subs.corny_head) == 0 then 
                    ent:Kill()
                end
            end

            if ent.Velocity:Length() > 0 then 
                ent.V1 = ent.Velocity
            elseif not ent:HasEntityFlags(EntityFlag.FLAG_FREEZE) then 
                ent.Velocity = ent.V1
            end

            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        else 
            ent.SpriteRotation = math.min(10,math.max(-10,rot_adjust))
            ent.HitPoints = math.min(ent.MaxHitPoints,ent.HitPoints+0.5)
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end

        ent.SpriteOffset = Vector(0,(ent.SpriteOffset.Y*19 + targ_y) / 20.0)
        ent.DepthOffset = -targ_y

        if not ent:GetSprite():IsPlaying("Body"..(ent.SubType-1)..(ent.Index % 2 + 1)) then 
            ent:GetSprite():Play("Body"..(ent.SubType-1)..(ent.Index % 2 + 1),true)
        end
    end
end

monster.npc_collide = function(self,ent,ent2,entfirst)
    if ent.Type == monster.type and ent.Variant == monster.variant and ent2.Type == ent.Type and ent2.Variant == ent.Variant then 
        if ent.FrameCount < 3 then 
            return true 
        else
            local body = ent 
            local head = ent2
            
            if ent2.SubType > subs.head then 
                body = ent2 
                head = ent 
            end

            if body.SubType > subs.head and head.SubType <= subs.head and 
                (body.Parent == nil and body.GroupIdx == 0) 
                    and body:ToNPC().I2 == 0 then --add the body to the new head
    
                body.Parent = head 
                local new_body = GODMODE.get_ent_data(head).body 

                if GODMODE.get_ent_data(head).body ~= nil then                         
                    for i,body2 in ipairs(new_body) do 
                        body2:ToNPC().I1 = body2:ToNPC().I1 + 1
                    end        

                    body:ToNPC().I1 = 1
                    body:ToNPC().GroupIdx = head:ToNPC().GroupIdx
                    table.insert(GODMODE.get_ent_data(head).body,1,body)

                    head:ToNPC().I1 = #GODMODE.get_ent_data(head).body
                end
            end
    
            return true     
        end
    end
end

monster.tear_collide = function(self,tear,ent,entfirst)
    if ent.Type == monster.type and ent.Variant == monster.variant then 
        if ent.SubType > subs.head and ent:ToNPC().GroupIdx ~= 0 then 
            return true
        end
    end
end

return monster