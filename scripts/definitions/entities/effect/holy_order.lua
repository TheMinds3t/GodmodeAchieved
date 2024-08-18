local monster = {}
-- monster.data gets updated every callback
monster.name = "Holy Order"
monster.type = GODMODE.registry.entities.holy_order.type
monster.variant = GODMODE.registry.entities.holy_order.variant

monster.tell = Sprite()
monster.tell:Load("gfx/effect_holy_order.anm2", true)

-- monster.data_init = function(self, ent,data)
-- 	if ent.Type == monster.type and ent.Variant == monster.variant then 
--     end
-- end

monster.effect_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end 
    if not sprite:IsPlaying("Order") then 
        sprite:Play("Order",true)
        ent.SplatColor = Color(1,1,1,1,1,1,1)
    end

    ent.SpriteRotation = ent.SubType + 90
    ent.Velocity = Vector(0,0)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    -- if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
    --     ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
    -- end

    if data then
        data.fire_time = (data.fire_time or 30) - 1
        data.max_fire_time = data.max_fire_time or (data.fire_time + 1)

        if sprite:IsEventTriggered("Fire") or data.fire_time == 0 then
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
            ent:Remove()
            l.Velocity = Vector(0,0)
            l.ParentOffset = ent.SpriteOffset
        end    
    else
        ent:Remove()
    end
end

monster.effect_post_render = function(self, ent, offset)
	local data = GODMODE.get_ent_data(ent)

	if monster.tell ~= nil and data.max_fire_time then
        local yellow_scale = GODMODE.is_at_palace and GODMODE.is_at_palace() and 0.8 or 0.0
        monster.tell.Color = Color(1,1,1,0.8-(data.fire_time/data.max_fire_time)*0.8,yellow_scale,yellow_scale*0.8,0)
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