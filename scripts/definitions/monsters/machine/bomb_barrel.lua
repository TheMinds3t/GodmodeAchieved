local monster = {}
monster.name = "Bomb Barrel"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, params)
    params[2].persistent_state = GODMODE.persistent_state.single_room
end

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)

	if data.abs_pos == nil then
		data.abs_pos = ent.Position 
		ent:GetSprite():Play("Idle", false)
	end

	ent.Position = data.abs_pos
	ent.Velocity = Vector(0,0)


	if ent:GetSprite():IsEventTriggered("Explode") then
		Game():BombExplosionEffects(ent.Position, 20.0, 0, Color(1.0,1.0,1.0,1.0,0,0,0), ent, 1.0, false, true)--Isaac.Explode(ent.Position, ent, 40.0)
		ent:Die()
	end
end

monster.new_room = function(self)
	GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(barrel) 
		if barrel:GetSprite():IsPlaying("Explode") then 
			barrel:GetSprite():Play("Idle",true)
			GODMODE.log("hi!",true)	
		end
	end)
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == monster.type and enthit.Variant == monster.variant then
		enthit:GetSprite():Play("Explode", false)
	end
end
return monster