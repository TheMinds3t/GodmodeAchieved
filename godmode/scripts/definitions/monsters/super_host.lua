local monster = {}
monster.name = "Spiked Host"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()

	if data.init == nil then 
		data.init = true 
		ent:GetSprite():Play("Idle", true) 
		data.vulnerable = false 
		data.spawn_tear = function(self, ang, speed, curve)
            if curve == nil then curve = 0 end
            local vel = Vector(math.cos(ang) * speed,math.sin(ang) * speed)
            local params = ProjectileParams()
            params.HeightModifier = -2
            params.FallingSpeedModifier = 0.125
            params.FallingAccelModifier = 0.1
            params.Scale = 1.2
            params.CurvingStrength = curve
            local tear = ent:FireBossProjectiles(1, ent.Position + vel, speed, params)
			tear.Height = tear.Height - 5
        end
		data.invuln_hits = 0
		data.invuln_tries = 0
        data.rand = ent:GetDropRNG():RandomInt(9)
	end
	
	ent.Velocity = ent.Velocity * 0.7

	if ent:GetSprite():IsPlaying("Idle") and data.time % 30 == (20+data.rand) then
		if ent:GetDropRNG():RandomInt(11-math.min(data.invuln_tries,8)) <= 2 then
			ent:GetSprite():Play("Attack", true)
			data.invuln_hits = 0
			data.invuln_tries = -1
		end

		data.invuln_tries = data.invuln_tries + 1
	end

	local cur_anim = "Idle"

	if data.invuln_hits >= 10 then
		cur_anim = "IdleGrin"
	end

	if data.invuln_hits > 0 then
		data.invuln_hits = data.invuln_hits - (2/30)
	else
		cur_anim = "Idle"
	end

	if not ent:GetSprite():IsPlaying("Attack") then
		ent:GetSprite():Play(cur_anim, false)
	end

	if data.vulnerable then
		ent.CollisionDamage = 1
	else
		ent.CollisionDamage = 0
	end

	data.invuln_cooldown = math.max(0,(data.invuln_cooldown or 0) - 1)
	
	if ent:GetSprite():IsEventTriggered("Toggle") then
		data.vulnerable = not data.vulnerable
	end
	if ent:GetSprite():IsEventTriggered("Attack") then
		for i=0,3 do
			local ang = (player.Position - ent.Position):GetAngleDegrees() + ent:GetDropRNG():RandomFloat() * 10 - 5
			data:spawn_tear(math.rad(ang),4.0-i*0.7)
		end
	end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	local data = GODMODE.get_ent_data(enthit)
	
	if enthit.Type == monster.type and enthit.Variant == monster.variant and not data.vulnerable then
		if entsrc.Type ~= 3 then
			if (data.invuln_cooldown or 0) <= 0 then 
				data.invuln_hits = math.min(15, (data.invuln_hits or 0) + amount) 
				data.invuln_cooldown = 30+data.invuln_hits
			end
		end
		return false
	end
end

return monster