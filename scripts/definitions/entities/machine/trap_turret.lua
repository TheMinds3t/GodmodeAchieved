local monster = {}
-- monster.data gets updated every callback
monster.name = "Stone Beggar"
monster.type = GODMODE.registry.entities.stone_beggar.type
monster.variant = GODMODE.registry.entities.stone_beggar.variant

monster.npc_update = function(self, ent, data, sprite)
	local player = ent:GetPlayerTarget()

	if data.cooldown == nil then 
		if ent.SubType == 0 then
			sprite:Play("Idle", true)
		elseif ent.SubType == 1 then
			sprite:Play("Idle", true)
		else
			sprite:Play("Idle", true)
		end

		if ent.SubType ~= 0 then
			data.numleft = 4
		end

		data.cooldown = 60
	end

	data.cooldown = data.cooldown - 1
	ent.Velocity = ent.Velocity * 0.7
	
	if ent.SubType ~= 0 and not data.exploding then
	    sprite:SetFrame("Idle", 4-data.numleft)
	elseif ent.SubType == 0 then
		if data.cooldown >= 0 then
			sprite:Play("Idle", false)
		end
	end

	if sprite:IsEventTriggered("Transition") then
		ent:PlaySound(SoundEffect.SOUND_STONESHOOT, Options.SFXVolume * 1.3+0.5, 1, false, 1.0 + (sprite:GetFrame() / 30)*0.04)
		sprite:Play("Explode", true)
		data.exploding = true
	end

	if sprite:IsEventTriggered("Tick") then 
		if sprite:IsPlaying("Explode") then 
			ent:PlaySound(SoundEffect.SOUND_MONSTER_GRUNT_4, Options.SFXVolume * 1.3+0.5, 1, false, 0.7)
		else 
			ent:PlaySound(SoundEffect.SOUND_STONESHOOT, Options.SFXVolume * 1.3+0.5, 1, false, 1.0 + (sprite:GetFrame() / 30)*0.04)
		end
	end

	if sprite:IsEventTriggered("Explode") then
		GODMODE.game:BombExplosionEffects(ent.Position, 40.0, 0, Color(1.0,1.0,1.0,1.0,0,0,0), ent, 1.0, false, true)--Isaac.Explode(ent.Position, ent, 40.0)
		ent:Remove()
	end

	if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
		ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
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
			elseif ent.SubType == 2 then
				if player:GetNumBombs() ~= 0 or player:HasGoldenBomb() then
					if not player:HasGoldenBomb() then
						player:AddBombs(-1)
					end

					flag = true
				end
			elseif ent.SubType == 3 then
				if player:GetNumCoins() ~= 0 then 
					player:AddCoins(-1)

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