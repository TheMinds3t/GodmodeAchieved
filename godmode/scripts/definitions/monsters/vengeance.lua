local monster = {}
monster.name = "Vengeance"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
monster.states = {
    pre = 1,
    transition = 2,
    mad = 3,
    attack = 4,
}
monster.update_apple_targets = function(self,ent)
    if ent ~= nil then
        if not ent:IsDead() then  
            GODMODE.util.macro_on_enemies(nil,ent.Type,ent.Variant,0,function(veng)
                if veng:ToNPC().I1 <= monster.states.mad then 
                    local veng_data = GODMODE.get_ent_data(veng) 
                    
                    if veng_data.apple_target == nil or (veng.Position-ent.Position):Length() < (veng.Position-veng_data.apple_target):Length() then 
                        veng_data.apple_target = ent.Position
                        veng_data.apple_obj = ent
                    end
                end
            end)
        end
    else 
        GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,1,function(apple)
            if not apple:IsDead() then 
                local num = 0
                GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,0,function(veng)
                    if veng:ToNPC().I1 <= monster.states.mad then 
                        num = num + 1
                        local veng_data = GODMODE.get_ent_data(veng) 
                    
                        if veng_data.apple_target == nil or (veng.Position-apple.Position):Length() < (veng.Position-veng_data.apple_target):Length() then 
                            veng_data.apple_target = apple.Position
                            veng_data.apple_obj = apple
                        end
                    end
                end)

                if num == 0 then apple:Kill() end
            end
        end)
    end
end

monster.should_attack = function(self,ent,player)
    return math.abs(player.Position.X - ent.Position.X) < 192.0
end

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    
    if ent.SubType == 1 then --apple!
        if ent:GetSprite():IsFinished("Appear") then 
            ent:GetSprite():PlayOverlay("Idle",true)
            ent:GetSprite():Play("GlowAppear",true)
        end

        if ent:GetSprite():IsFinished("GlowAppear") then 
            ent:GetSprite():Play("Glow",true)
            monster:update_apple_targets(ent)
        end

        if data.veng_obj and (data.veng_obj.Position - ent.Position):Length() > ent.Size * 6.0 then 
            data.veng_obj = nil
        end

        data.anchor_pos = data.anchor_pos or Game():GetRoom():GetGridPosition(Game():GetRoom():GetGridIndex(ent.Position))
        ent.Velocity = ent.Velocity * 0.9 + (data.anchor_pos - ent.Position) * (1/10.0)
    else --vengeance!
        local player = ent:GetPlayerTarget()

        if ent:GetSprite():IsFinished("Appear") then 
            ent.I1 = monster.states.pre
        end

        if ent.I1 == monster.states.pre then 
            ent:GetSprite():PlayOverlay("Head",false)
            ent:AnimWalkFrame("WalkHori","WalkVert",1.2)
        elseif ent.I1 >= monster.states.mad then 
            if ent:GetSprite():IsOverlayFinished("HeadConvert") then 
                ent:GetSprite():PlayOverlay("Head2Idle",false)
            end

            if ent:GetSprite():IsOverlayFinished("Head2Idle") then 
                if ent:GetDropRNG():RandomFloat() < 0.6+math.min(0.4,0.4-ent.I2) or player == nil or not monster:should_attack(ent,player) then 
                    ent:GetSprite():PlayOverlay("Head2Idle",true)
                    ent.I2 = ent.I2 + 1
                else
                    ent.I1 = monster.states.attack
                    ent.I2 = 0

                    if ent.Position.Y > player.Position.Y then 
                        ent:GetSprite():PlayOverlay("AttackUp",true)
                    else
                        ent:GetSprite():PlayOverlay("AttackDown",true)
                    end
                end
            end

            if ent:GetSprite():IsOverlayFinished("AttackUp") or ent:GetSprite():IsOverlayFinished("AttackDown") then 
                ent:GetSprite():PlayOverlay("Head2Idle",true)
                ent.I1 = monster.states.mad
            end

            ent:AnimWalkFrame("WalkHori2","WalkVert2",1.2)
        end

        if data.apple_obj ~= nil and ent.I1 ~= monster.states.mad then 
            if data.apple_obj:IsDead() then data.apple_obj = nil data.apple_target = nil else 
                local dist = (data.apple_obj.Position-ent.Position):Length()
            
                if dist<(data.apple_obj.Size+ent.Size)*3 and GetPtrHash(GODMODE.get_ent_data(data.apple_obj).veng_obj or player) == GetPtrHash(ent) then 
                    if ent:GetSprite():GetOverlayAnimation() ~= "HeadConvert" then 
                        ent:GetSprite():PlayOverlay("HeadConvert",true)
                        ent:GetSprite():Play("BodyConvert",true)
                    end
    
                    ent.I1 = monster.states.transition
                elseif not ent:GetSprite():GetOverlayAnimation() == "Head" then  
                    ent:GetSprite():PlayOverlay("Head",true)
                    ent:AnimWalkFrame("WalkHori","WalkVert",1.2)
                    ent.I1 = monster.states.pre
                end
    
                if ent:GetSprite():IsEventTriggered("Convert") then 
                    ent.I1 = monster.states.mad
                    data.apple_obj:Kill()

                    GODMODE.util.macro_on_enemies(nil,ent.Type,ent.Variant,0,function(veng)
                        local veng_data = GODMODE.get_ent_data(veng) 

                        if veng_data.apple_target == data.apple_target then 
                            veng_data.apple_target = nil
                            veng_data.apple_obj = nil
                        end
                    end)

                    -- data.apple_obj = nil 
                    -- data.apple_target = nil
                    ent.Scale = 1.25
                    ent.Mass = ent.Mass * 10
                    ent.MaxHitPoints = ent.MaxHitPoints * 4
                    ent.HitPoints = ent.MaxHitPoints
                    ent:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)

                end    
            end
        end

        if ent.I1 < monster.states.attack then 
            local target_pos = data.apple_target or player.Position

            if data.apple_obj ~= nil then 
                if GODMODE.get_ent_data(data.apple_obj).veng_obj then  
                    target_pos = GODMODE.get_ent_data(data.apple_obj).veng_obj.Position or target_pos
                end
            else 
                data.apple_target = nil
            end

            local pathfinding = GODMODE.util.ground_ai_movement(ent,target_pos,1.25 * (ent.I1 * 0.125 + 0.875),true)

            if pathfinding ~= nil then 
                ent.Velocity = ent.Velocity * 0.75 + pathfinding 
            elseif player ~= nil then 
                ent.Pathfinder:FindGridPath(target_pos,0.8 * (ent.I1 * 0.1 + 0.9),0,true)
            end    
        else
            ent.Velocity = ent.Velocity * 0.85
        end

        if ent:GetSprite():IsOverlayPlaying("AttackUp") or ent:GetSprite():IsOverlayPlaying("AttackDown") then 
            ent.FlipX = false
            local up = ent:GetSprite():IsOverlayPlaying("AttackUp")
            local frame = ent:GetSprite():GetOverlayFrame()
            local off = math.sin(math.rad((math.min(84,frame - 22))/84*360))*70
            
            if data.laser ~= nil then 
                data.laser.MaxDistance = math.min(360,data.laser.MaxDistance + math.abs(off) * 10/120)
                if up then 
                    data.laser.AngleDegrees = 270+off
                else
                    data.laser.AngleDegrees = 90+off
                end

                data.laser.Angle = data.laser.AngleDegrees
                data.laser.Timeout = math.max(0,84-(frame-22))

                if data.laser.Timeout == 0 then 
                    data.laser = nil
                end
            end

            if frame == 22 then 
                if up then 
                    data.laser = EntityLaser.ShootAngle(1,ent.Position+Vector(0,-8),270,48,Vector(0,-16),ent)
                else
                    data.laser = EntityLaser.ShootAngle(1,ent.Position+Vector(0,8),90,48,Vector(0,-24),ent)
                end
                data.laser.MaxDistance = 24
            end
        end
    end
end

monster.npc_kill = function(self,ent)
    if ent.Type == monster.type and ent.Variant == monster.variant then
        if ent.SubType == 1 then  
            GODMODE.util.macro_on_enemies(nil,ent.Type,ent.Variant,0,function(veng)
                local veng_data = GODMODE.get_ent_data(veng) 
                veng_data.apple_target = nil

                if veng:ToNPC().I1 == monster.states.transition then 
                    veng:ToNPC().I1 = monster.states.pre 
                    veng:GetSprite():PlayOverlay("Head",true)
                    veng:ToNPC():AnimWalkFrame("WalkHori","WalkVert",1.2)

                end
            end)
        else 
            local apple = GODMODE.get_ent_data(ent).apple_obj

            if apple ~= nil then 
                GODMODE.get_ent_data(apple).veng_obj = nil
            end
        end

        monster:update_apple_targets()
    end
end

monster.npc_collide = function(self,ent,ent2,entfirst)
    if ent.Type == ent2.Type and ent.Variant == ent2.Variant and ent.Type == monster.type and ent.Variant == monster.variant then 
        if ent2.SubType == 1 and ent2:GetSprite():IsPlaying("Glow") and GODMODE.get_ent_data(ent2).veng_obj == nil then 
            GODMODE.get_ent_data(ent).apple_obj = ent2
            GODMODE.get_ent_data(ent2).veng_obj = ent
        end
    end
end

-- monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
--     local data = GODMODE.get_ent_data(enthit)
--     if enthit.Type == monster.type and enthit.Variant == monster.variant and flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER and entsrc.Type ~= 1 then 
--         return false 
--     end
-- end

return monster