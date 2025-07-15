local monster = {}
monster.name = "Fruit Fly"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.familiar_update = function(self, fam)
	local data = GODMODE.get_ent_data(fam)
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

		if fly.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) or fly.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) and fly.State >= 2 then 
			fly.State = fly.State + 1
		end

		if fly:GetDropRNG():RandomFloat() < math.max(0,(fly.State-2) * 0.03) then 
			fly:Kill()
			Isaac.Spawn(Isaac.GetEntityTypeByName("Fruit (Pickup)"), Isaac.GetEntityVariantByName("Fruit (Pickup)"), 0, fly.Position, RandomVector()*(fly:GetDropRNG():RandomFloat()+2), nil)
			fly.Player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
			fly.Player:EvaluateItems()
		end
	end)
end


return monster