local monster = {}
--enables the player to safely open mimic chests for free if they shoot them first
monster.name = "Mimic Chest"
monster.type = Isaac.GetEntityTypeByName("Mimic Chest")
monster.variant = Isaac.GetEntityVariantByName("Mimic Chest")

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)

	if data.health == nil then
		data.health = 10
	end

	for i=1, #Isaac.GetRoomEntities() do
		local en = Isaac.GetRoomEntities()[i]

		if en ~= nil and en.Type == EntityType.ENTITY_TEAR then
			local dist = math.sqrt((en.Position.X * en.Position.X-ent.Position.X * ent.Position.X)+(en.Position.Y * en.Position.Y-ent.Position.Y * ent.Position.Y))

			if math.abs(en.Position.X - ent.Position.X) < 64 and math.abs(en.Position.Y - ent.Position.Y) < 64 then
				data.health = data.health - en.CollisionDamage
				en:Die()
				ent:BloodExplode()
			end
		end
	end

	if data.health <= 0 then
		ent:Die()
		Isaac.Spawn(5,50,0,ent.Position,ent.Velocity,ent)
	end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)
	
	if entsrc.IsFriendly and enthit.Type == monster.type and enthit.Variant == monster.variant then
		data.health = (data.health or 10) - amount
	end
end

return monster