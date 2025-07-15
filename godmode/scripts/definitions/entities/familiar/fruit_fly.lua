local monster = {}
monster.name = "Fruit Fly"
monster.type = GODMODE.registry.entities.fruit_fly.type
monster.variant = GODMODE.registry.entities.fruit_fly.variant

monster.familiar_update = function(self, fam, data)
    local player = fam.Player
    if fam.Type == monster.type and fam.Variant == monster.variant then
		local spd_mult = 0
		if not fam:GetSprite():IsPlaying("Appear") then
			if fam.State < 2 then 
				fam:GetSprite():Play("Sleep"..math.max(0,math.min(1,(fam.State))), false)
				spd_mult = 0.5
			else 
				fam:GetSprite():Play("Idle"..math.max(0,math.min(9,math.floor((fam.State-2)/3))), false)
				spd_mult = 1
			end
		end

		local targ = ((player.Position) - fam.Position)

		if targ:Length() > player.Size * 1.5 then 
			fam.Velocity = fam.Velocity * 0.9 + targ:Resized(math.min(0.5,targ:Length()/120))*spd_mult+RandomVector()*(fam:GetDropRNG():RandomFloat()*0.5+0.5)
		end

		fam.FlipX = fam.Velocity.X > 0
    end
end

monster.room_rewards = function(self,rng,pos)
	GODMODE.util.macro_on_enemies(nil, monster.type, monster.variant, 0, function(fly)
		fly = fly:ToFamiliar()
		fly.State = fly.State + 1

		if fly.State >= 2 then 
			fly.State = fly.State + math.max(math.min(1,fly:GetDropRNG():RandomInt(3)-1),0)

			if fly.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) or fly.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then 
				fly.State = fly.State + 1
			end
		end

		if fly:GetDropRNG():RandomFloat() < math.max(0,(fly.State-2) * 0.03) then 
			fly:Kill()
			Isaac.Spawn(GODMODE.registry.entities.fruit.type, GODMODE.registry.entities.fruit.variant, 0, fly.Position, RandomVector()*(fly:GetDropRNG():RandomFloat()+2), nil)
			fly.Player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
			fly.Player:EvaluateItems()
		end
	end)
end


return monster