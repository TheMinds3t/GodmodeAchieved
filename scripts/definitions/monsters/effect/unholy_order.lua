local monster = {}
monster.name = "Unholy Order"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.tell = Sprite()
monster.tell:Load("gfx/effect_unholy_order.anm2", true)

monster.data_init = function(self, params)
    local ent = params[1]
    local data = params[2]
    ent:GetSprite():Play("Order",true)
    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
end
monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    ent.SpriteRotation = ent.SubType + 90
    ent.Velocity = Vector(0,0)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

    if ent.Parent ~= nil and ent.Parent:IsDead() and (data.remove_on_dead or false) == true then 
        ent:Remove()
    end

    if data then
        data.fire_time = (data.fire_time or 30) - 1
        data.max_fire_time = data.max_fire_time or (data.fire_time + 1)
    
        if ent:GetSprite():IsEventTriggered("Fire") or data.fire_time <= 0 then
            local e = Isaac.GetRoomEntities()
            local x = ent.Parent
            if x == nil then 
                x = ent 
            end
    
            local l = EntityLaser.ShootAngle(1,ent.Position,ent.SubType,6,Vector(0,0),x)

            if (data.laser_timeout or -1) ~= -1 then
                l:SetTimeout(data.laser_timeout)
            end
    
            if (data.laser_length or -1) ~= -1 then
                l.MaxDistance = data.laser_length
            end
    
            l.ParentOffset = ent.SpriteOffset
            l.Parent = x
            l.DisableFollowParent = (data.follow_parent or true)
            ent:Kill()
            l.Velocity = Vector(0,0)
            l.ParentOffset = ent.SpriteOffset
            l.DepthOffset = ent.DepthOffset
        end    
    else
        ent:Remove()
    end
end

monster.npc_post_render = function(self, ent, offset)
	local data = GODMODE.get_ent_data(ent)

	if monster.tell ~= nil and data.max_fire_time then
        monster.tell.Color = Color(1,1,1,1.0-(data.fire_time/data.max_fire_time)*1.0,0,0,0)
        monster.tell:SetFrame("Tell", ent:GetSprite():GetFrame())
        monster.tell.Rotation = ent.SubType + 90
        local laser_dir = Vector(math.cos(math.rad(ent.SubType+90)),math.sin(math.rad(ent.SubType+90))):Resized(1)
        -- local hit,pos = Game():GetRoom():CheckLine(ent.Position,ent.Position+Vector(math.cos(math.rad(ent.SubType)),math.sin(math.rad(ent.SubType))):Resized(5000), 3, false, true)
        local pos = EntityLaser.CalculateEndPoint(ent.Position,ent.Position+laser_dir,Vector.Zero, nil,0)
        local dist = Isaac.WorldToScreen(ent.Position):Distance(pos)--pos:Distance(Isaac.WorldToScreenDistance((pos - ent.Position)))
        -- local dist = pos:Distance(ent.Position)

        local laser_screen_length = (laser_dir:Resized(Isaac.WorldToScreenDistance(laser_dir:Resized(data.laser_length or 512)):Length() or 512)):Length()
        local clamp = Vector(0,math.max(0,512-math.min(dist,laser_screen_length)))

		monster.tell:Render(Isaac.WorldToScreen(ent.Position+ent.SpriteOffset),clamp,Vector.Zero)
	end
end

return monster