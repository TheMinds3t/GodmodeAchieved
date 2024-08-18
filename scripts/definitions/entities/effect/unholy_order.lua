local monster = {}
monster.name = "Unholy Order"
monster.type = GODMODE.registry.entities.unholy_order.type
monster.variant = GODMODE.registry.entities.unholy_order.variant

monster.tell = Sprite()
monster.tell:Load("gfx/effect_unholy_order.anm2", true)
monster.laser_sprite_size = 1024
monster.laser_tip_pad = 12


-- monster.data_init = function(self, ent,data)
-- 	if ent.Type == monster.type and ent.Variant == monster.variant then 
--         ent:GetSprite():Play("Order",true)
--         ent.SplatColor = Color(0,0,0,0,255,255,255)
--         ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
--     end
-- end

monster.effect_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    ent.SpriteRotation = ent.SubType + 90
    ent.Velocity = Vector(0,0)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

    if not sprite:IsPlaying("Order") then 
        sprite:Play("Order",true)
        ent.SplatColor = Color(1,1,1,1,1,1,1)
    end

    if ent.Parent ~= nil and ent.Parent:IsDead() and (data.remove_on_dead or false) == true then 
        ent:Remove()
    end

    if data then
        data.fire_time = (data.fire_time or 30) - 1
        data.max_fire_time = data.max_fire_time or (data.fire_time + 1)
    
        if sprite:IsEventTriggered("Fire") or data.fire_time <= 0 then
            local e = Isaac.GetRoomEntities()
            local x = ent.Parent
            if x == nil then 
                x = ent 
            end
    
            local l = EntityLaser.ShootAngle(1,ent.Position+ent.SpriteOffset,ent.SubType,6,Vector(0,0),x)

            if (data.laser_timeout or -1) ~= -1 then
                l:SetTimeout(data.laser_timeout)
            end
    
            if (data.laser_length or -1) ~= -1 then
                l.MaxDistance = data.laser_length
            end
    
            l.ParentOffset = ent.SpriteOffset
            l.Parent = x
            l.DisableFollowParent = (data.follow_parent or true)
            ent:Remove()
            l.Velocity = Vector(0,0)
            l.DepthOffset = ent.DepthOffset
            -- l.SpriteOffset = ent.SpriteOffset
        end    
    else
        ent:Remove()
    end
end

monster.effect_post_render = function(self, ent, offset)
	local data = GODMODE.get_ent_data(ent)

    -- pseudo-beam action
	if monster.tell ~= nil and data.max_fire_time then
        monster.tell.Color = Color(1,1,1,1.0-(data.fire_time/data.max_fire_time)*1.0,0,0,0)
        monster.tell:SetFrame("Tell", ent:GetSprite():GetFrame())
        monster.tell.Rotation = ent.SubType + 90

        --real coords
        local start_pos = ent.Position + ent.SpriteOffset
        local end_pos = EntityLaser.CalculateEndPoint(ent.Position,Vector(1,0):Rotated(ent.SubType),Vector.Zero, ent.Parent or ent.SpawnerEntity or nil,0)
        --get screen dist, clamp it 
        local len = (Isaac.WorldToScreen(end_pos) - Isaac.WorldToScreen(start_pos)):Length()

        --get screen dist length
        local laser_length = 
            (Isaac.WorldToScreen(start_pos + Vector(1,0):Rotated(ent.SubType + 90):Resized(data.laser_length or len))
            - Isaac.WorldToScreen(start_pos)):Length()

        local max_len = math.min(data.laser_length and laser_length or len, monster.laser_sprite_size)

        local clamp = Vector(0,monster.laser_sprite_size - math.min(len,max_len) - monster.laser_tip_pad)

        if GODMODE.validate_rgon() then 
            local null_frame = ent:GetSprite():GetNullFrame("LaserScale")

            if null_frame then 
                clamp = clamp * Vector(1,1 + (math.abs(null_frame:GetScale().Y) - 1) / Isaac.GetScreenPointScale())
            end
        end

        monster.tell:Render(Isaac.WorldToScreen(start_pos),clamp,Vector.Zero)
	end
end

return monster