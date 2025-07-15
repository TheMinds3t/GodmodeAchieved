local monster = {}
monster.name = ""
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, ent, data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
	end
end

monster.npc_update = function(self, ent, data, sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
	local player = ent:GetPlayerTarget()
end


return monster