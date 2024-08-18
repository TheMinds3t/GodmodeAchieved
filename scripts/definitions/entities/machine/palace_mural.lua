local monster = {}
monster.name = "Lucifer's Palace Mural"
monster.type = GODMODE.registry.entities.palace_mural.type
monster.variant = GODMODE.registry.entities.palace_mural.variant

monster.pickup_update = function(self, ent, data, sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
	ent.Velocity = Vector(0,0)
	ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

	if ent.SubType >= 1 then 
		sprite:Play("SecretIdle",false)
		sprite.Rotation = 90*((ent.SubType-1)%4)-90

		if (ent.SubType-1) % 4 == 2 then 
			ent.SpriteOffset = Vector(1,0)
		elseif (ent.SubType-1) % 4 == 1 then 
			ent.SpriteOffset = Vector(0,-1)
		elseif (ent.SubType-1) % 4 == 3 then 
			ent.SpriteOffset = Vector(0,1)
		elseif (ent.SubType-1) % 4 == 0 then 
			ent.SpriteOffset = Vector(-1,0)
		end
	else 
		sprite:Play("Idle",false)
	end

	if ent.DepthOffset ~= -200 then
		ent.DepthOffset = -200
	end	
end

return monster