local monster = {}
monster.name = "Ludomini"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()
	if player ~= nil then 
		local targ_pos = player.Position - ent.Position
		local targ_vel = ((targ_pos) * (1/80.0))
		local accel = math.min(ent.FrameCount, 60)/60.0*0.1
		ent.Velocity = ent.Velocity * (0.82+accel) + targ_vel:Resized(math.min(0.55+accel,targ_vel:Length()*(0.9+accel)))
	end

	ent:GetSprite():Play("Idle",false)
end

monster.npc_kill = function(self, ent)
	if ent.Type == monster.type and ent.Variant == monster.variant and not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
		local spd = 2.0+ent:GetDropRNG():RandomFloat()*0.25
		for i=1,4 do
			local f = math.rad(90 * i)
			local ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
			local t = Game():Spawn(EntityType.ENTITY_PROJECTILE,0,ent.Position + ang,ang*spd,ent,0,ent.InitSeed)
			t = t:ToProjectile()
			t.ProjectileFlags = ProjectileFlags.SMART
			t.HomingStrength = 0.7
			t.CurvingStrength = 0.5
			t.Height = t.Height-10
			t.Scale = 1.25
		end
	end
end

return monster