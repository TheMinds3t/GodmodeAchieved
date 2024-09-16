local monster = {}
monster.name = "Ratty"
monster.type = GODMODE.registry.entities.ratty.type
monster.variant = GODMODE.registry.entities.ratty.variant
local anims = {"WalkRight","WalkDown","WalkLeft","WalkUp"}
local pickup_predicate = function(ent) 
    return (ent.Variant == PickupVariant.PICKUP_HEART or ent.Variant == PickupVariant.PICKUP_COIN or 
    ent.Variant == PickupVariant.PICKUP_KEY or ent.Variant == PickupVariant.PICKUP_BOMB or ent.Variant == PickupVariant.PICKUP_PILL or ent.Variant == GODMODE.registry.entities.fruit.variant)
    and ent.SpriteOffset:Length() == 0
end
local pickup_off = Vector(0,-10)
local rat_tunnel_dist = 128

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	

    if sprite:IsPlaying("Appear") or ent.FrameCount < 2 then 
        sprite.PlaybackSpeed = 1.0
        return
    elseif not sprite:IsPlaying("DigIn") or ent.I1 == 0 then 
        if ent.Velocity:Length() > 0.25 then 
            if math.abs(ent.Velocity.X) > math.abs(ent.Velocity.Y) then 
                if ent.Velocity.X > 0 then 
                    sprite:Play("WalkLeft",false)
                else
                    sprite:Play("WalkRight",false)
                end
            else
                if ent.Velocity.Y > 0 then 
                    sprite:Play("WalkDown",false)
                else
                    sprite:Play("WalkUp",false)
                end
            end    
        end

        sprite.PlaybackSpeed = math.min(1.2,ent.Velocity:Length()/4/ent.Scale)
    elseif sprite:IsPlaying("DigIn") then
        ent.Velocity = ent.Velocity * 0.1
        sprite.PlaybackSpeed = 1.0
    end
    
    local player = ent:GetPlayerTarget()
    local target = player.Position

    if data.cur_pickup ~= nil then 
        if data.cur_pickup:IsDead() then 
            data.cur_pickup.SpriteOffset = Vector(0,0)
            data.cur_pickup = nil
        else 
            data.cur_pickup.Velocity = ((ent.Position)-data.cur_pickup.Position)
            data.cur_pickup.SpriteOffset = pickup_off
            data.cur_pickup.DepthOffset = 20
            ent.I1 = ent.I1 + 1
            ent.I2 = 0
            target = ent.Position + (ent.Position - player.Position):Resized(32)
    
            if (player.Position - ent.Position):Length() > rat_tunnel_dist then 
                if ent.I1 > 100 and not sprite:IsPlaying("DigIn") then 
                    sprite:Play("DigIn",true)
                end
    
                target = ent.Position
            end
    
            data.pickup = nil    
        end
    else
        ent.I1 = 0

        if ent.FrameCount > 30 and ent:IsFrame(30,1) and (data.pickup == nil or GODMODE.get_ent_data(data.pickup).rat_target ~= nil) then 
            local pickup_target = nil
            GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_PICKUP,nil,nil,function(pickup)
                if pickup_target == nil or (pickup_target.Position - ent.Position):Length() > (pickup.Position-ent.Position):Length() then 
                    pickup_target = pickup
                end
            end, pickup_predicate)
    
            if pickup_target ~= nil then 
                data.pickup = pickup_target
            else 
                ent.I2 = ent.I2 + 1
            end

            if ent.I2 >= 10 then 
                sprite:Play("DigIn",true)
            end
        elseif data.pickup ~= nil then 
            target = data.pickup.Position

            if data.pickup.SpriteOffset:Length() ~= 0 then 
                data.pickup = nil 
            elseif (data.pickup.Position - ent.Position):Length() < ent.Size * 2 then 
                data.cur_pickup = data.pickup 
                GODMODE.get_ent_data(data.cur_pickup).rat_target = ent

                GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(rats) 
                    if GetPtrHash(rats) ~= GetPtrHash(ent) then 
                        if data.pickup ~= nil and GODMODE.get_ent_data(rats).pickup ~= nil and GetPtrHash(GODMODE.get_ent_data(rats).pickup) == GetPtrHash(data.pickup) then 
                            GODMODE.get_ent_data(rats).pickup = nil
                        end
    
                        if data.cur_pickup ~= nil and GODMODE.get_ent_data(rats).cur_pickup ~= nil and GetPtrHash(GODMODE.get_ent_data(rats).cur_pickup) == GetPtrHash(data.cur_pickup) then 
                            GODMODE.get_ent_data(rats).cur_pickup = nil
                        end
                    end
                end)

                data.pickup = nil
            end
        end    
    end

    local pathfinding = GODMODE.util.ground_ai_movement(ent,target,0.8*ent.Scale,true)

    if pathfinding ~= nil then 
        ent.Velocity = ent.Velocity * 0.75 + pathfinding 
    elseif target ~= nil then 
        ent.Pathfinder:FindGridPath(target,0.6*ent.Scale,0,true)
    end

    if sprite:IsEventTriggered("Dig") then 
        ent:Remove()

        if data.cur_pickup ~= nil then 
            data.cur_pickup:Remove()
        end
    end

    -- if sprite:IsEventTriggered("Fall") and data.cur_pickup ~= nil then 
    --     GODMODE.get_ent_data(data.cur_pickup).rat_target = nil
    -- end
end

monster.pickup_update = function(self,pickup)
    local rat = GODMODE.get_ent_data(pickup).rat_target
    if rat == nil or rat:IsDead() or (GODMODE.get_ent_data(pickup).fall or false) == true then 
        pickup.SpriteOffset = (pickup.SpriteOffset * 3 + Vector.Zero) / 5.0
        GODMODE.get_ent_data(pickup).rat_target = nil

        if pickup.SpriteOffset:Length() < 0.025 then 
            pickup.SpriteOffset = Vector.Zero
            GODMODE.get_ent_data(pickup).rat_target = nil
            GODMODE.get_ent_data(pickup).fall = nil
        end
    end
end

monster.npc_kill = function(self,ent)
    local pickup = GODMODE.get_ent_data(ent).cur_pickup or GODMODE.get_ent_data(ent).pickup
    if pickup ~= nil then 
        pickup.SpriteOffset = Vector(0,0)
        GODMODE.get_ent_data(pickup).rat_target = nil
        -- pickup.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
        -- pickup.Position = GODMODE.room:FindFreePickupSpawnPosition(pickup.Position)
        -- pickup:GetSprite():SetFrame("Appear",14)
    end
end

return monster