local monster = {}
monster.name = "Bomb Barrel"
monster.type = GODMODE.registry.entities.bomb_barrel.type
monster.variant = GODMODE.registry.entities.bomb_barrel.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
		data.persistent_state = GODMODE.persistent_state.single_room
		data.enter_room = function(ent) 
			ent:GetSprite():Play("Idle",true)
		end 
		data.exit_room = data.enter_room
	end
end

monster.npc_update = function(self, ent, data, sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end

	if data.abs_pos == nil then
		data.abs_pos = ent.Position 
		sprite:Play("Idle", false)
	end

	if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
		ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
	end

	ent.Position = data.abs_pos
	ent.Velocity = Vector(0,0)

	if sprite:IsEventTriggered("Explode") then
		GODMODE.game:BombExplosionEffects(ent.Position, 20.0, 0, Color(1.0,1.0,1.0,1.0,0,0,0), ent, 1.0, false, true)--Isaac.Explode(ent.Position, ent, 40.0)
		ent:Remove()
	end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == monster.type and enthit.Variant == monster.variant then
		enthit:GetSprite():Play("Explode", false)
	end
end

return monster