local monster = {}
monster.name = "Dynamite Rock (Brazier)"
monster.type = GODMODE.registry.entities.dynamite_rock.type
monster.variant = GODMODE.registry.entities.dynamite_rock.variant

monster.npc_update = function(self, ent, data, sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	

	if data.abs_pos == nil then
		data.abs_pos = ent.Position - Vector(22,22) - Vector(0,44)
		data.frame = ent:GetDropRNG():RandomInt(3)
	end

	sprite:SetFrame("Rock",data.frame or 1)
	ent.Position = data.abs_pos
	ent.Velocity = Vector(0,0)
	
	if ent:IsChampion() then 
		ent:Morph(ent.Type, ent.Variant, ent.SubType, -1)
	end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == monster.type and enthit.Variant == monster.variant then
		return false
	end
end

return monster