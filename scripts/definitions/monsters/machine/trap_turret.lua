local monster = {}
-- monster.data gets updated every callback
monster.name = "Trap Turret"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()

	if data.val == nil then 
		if ent.SubType == 0 then
			data.val = "Timer"
			ent:GetSprite():Play("IdleTimer", true)
		elseif ent.SubType == 1 then
			data.val = "Key"
			ent:GetSprite():Play("IdleKey", true)
		else
			data.val = "Bomb"
			ent:GetSprite():Play("IdleBomb", true)
		end

		if ent.SubType ~= 0 then
			data.numleft = 4
		end

		data.cooldown = 60
	end

	data.cooldown = data.cooldown - 1
	ent.Velocity = ent.Velocity * 0.7
	
	if ent.SubType ~= 0 and not data.exploding then
	    ent:GetSprite():SetFrame("Idle"..data.val, 4-data.numleft)
	elseif ent.SubType == 0 then
		if data.cooldown >= 0 then
			ent:GetSprite():Play("IdleTimer", false)
		end
	end

	if ent:GetSprite():IsEventTriggered("Transition") then
		ent:GetSprite():Play("Explode"..data.val, true)
		data.exploding = true
	end

	if ent:GetSprite():IsEventTriggered("Explode") then
		Game():BombExplosionEffects(ent.Position, 40.0, 0, Color(1.0,1.0,1.0,1.0,0,0,0), ent, 1.0, false, true)--Isaac.Explode(ent.Position, ent, 40.0)
		ent:Remove()
	end
end

monster.npc_collide = function(self, ent, ent2, entfirst)
    if ent2:ToPlayer() and ent.SubType > 0 then
		local player = ent2:ToPlayer()
        local data = GODMODE.get_ent_data(ent)

		if data.cooldown <= 0 then
			local flag = false
			if ent.SubType == 1 then
				if player:TryUseKey() then
					flag = true
				end
			else
				if player:GetNumBombs() ~= 0 or player:HasGoldenBomb() then
					if not player:HasGoldenBomb() then
						player:AddBombs(-1)
					end

					flag = true
				end
			end

			if flag then
				data.numleft = data.numleft - 1
				data.cooldown = 60
			end
		end
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == monster.Type and enthit.Variant == monster.variant then
		return false
	end
end
return monster