local monster = {}
-- monster.data gets updated every callback
monster.name = "Holy Order"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.tell = Sprite()
monster.tell:Load("gfx/effect_holy_order.anm2", true)

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

    if data then
        data.fire_time = (data.fire_time or 30) - 1
        data.max_fire_time = data.max_fire_time or (data.fire_time + 1)

        if ent:GetSprite():IsEventTriggered("Fire") or data.fire_time == 0 then
            local e = Isaac.GetRoomEntities()
            local x = ent.Parent
            local l = EntityLaser.ShootAngle(5,ent.Position,ent.SubType,6,Vector(0,0),ent)
            if x == nil then 
                x = ent 
            end
    
            if (data.laser_timeout or -1) ~= -1 then
                l:SetTimeout(data.laser_timeout)
            end
    
            if (data.laser_length or -1) ~= -1 then
                l.LaserLength = data.laser_length
            end    
    
            l.DisableFollowParent = true
            l.Parent = x
            ent:Kill()
            l.Velocity = Vector(0,0)
            l.ParentOffset = ent.SpriteOffset
        end    
    else
        ent:Remove()
    end
end

monster.npc_post_render = function(self, ent, offset)
	local data = GODMODE.get_ent_data(ent)

	if monster.tell ~= nil and data.max_fire_time then
        monster.tell.Color = Color(0,0,0,0.8-(data.fire_time/data.max_fire_time)*0.8,1,1,1)
        monster.tell:SetFrame("Tell", ent:GetSprite():GetFrame())
        monster.tell.Rotation = ent.SubType + 90
        local clamp = Vector(0,0)

        if (data.laser_length or 0) > 0 then
            clamp = Vector(0,math.max(0,512-data.laser_length))
        end

		monster.tell:Render(Isaac.WorldToScreen(ent.Position+ent.SpriteOffset),clamp,Vector.Zero)
	end
end

return monster