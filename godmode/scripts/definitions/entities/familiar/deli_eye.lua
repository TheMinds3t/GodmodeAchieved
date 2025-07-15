local monster = {}
monster.name = "Delirious Eye"
monster.type = GODMODE.registry.entities.deli_eye.type
monster.variant = GODMODE.registry.entities.deli_eye.variant

monster.familiar_init = function(self, fam)
	local count = fam.Player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
	if count > 0 then 
		
	end
end

monster.familiar_update = function(self, fam, data)
    local player = fam.Player
    if fam.Type == monster.type and fam.Variant == monster.variant then
		if fam:HasEntityFlags(EntityFlag.FLAG_APPEAR) then 
			fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end

		local anim = "Eye"..(fam.InitSeed % 3 + 1)

		if not fam:GetSprite():IsPlaying(anim) then 
			fam:GetSprite():Play(anim,true)
		end

		local ang = math.rad(fam.FrameCount * (3 + fam.InitSeed % 3) + fam.InitSeed % 360)
		local dist = math.abs((fam.FrameCount + fam.InitSeed) % 20 - 10) * 6
		local targ = ((player.Position + Vector(math.cos(ang)*dist,math.sin(ang)*dist)) - fam.Position)

		if targ:Length() > player.Size * 1.25 then 
			fam.Velocity = fam.Velocity * 0.9 + targ:Resized(math.min(1.5,targ:Length()/26)) + RandomVector():Resized(0.2)
		end

		fam.FlipX = fam.Velocity.X > 0

		fam.Color = Color(1,1,1,GODMODE.room:IsClear() and math.min(0.9,(fam.Color.A * 1.1)) or math.max(0.1,(fam.Color.A * 0.9)))
    end
end


return monster