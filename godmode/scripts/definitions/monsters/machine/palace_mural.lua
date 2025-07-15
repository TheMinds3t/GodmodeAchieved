local monster = {}
monster.name = "Lucifer's Palace Mural"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.pickup_update = function(self, ent)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
	local data = GODMODE.get_ent_data(ent)
	ent:GetSprite():Play("Idle",false)
	ent.Velocity = Vector(0,0)
	ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

	if ent.DepthOffset ~= -200 then
		ent.DepthOffset = -200
	end	
end

return monster