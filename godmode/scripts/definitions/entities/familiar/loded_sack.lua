local monster = {}
monster.name = "[GODMODE] Loded Sack"
monster.type = GODMODE.registry.entities.loded_sack.type
monster.variant = GODMODE.registry.entities.loded_sack.variant

local rooms_to_activate = 3

local spawn_reward = function(fam,data,sprite)
	fam.Player:ThrowFriendlyDip(0,fam.Position,fam.Position+RandomVector():Resized(48*(0.5+fam:GetDropRNG():RandomFloat())))
end

monster.familiar_update = function(self, fam, data, sprite)
    if fam.Type == monster.type and fam.Variant == monster.variant then
		local player = fam.Player 
		
		if not fam.IsFollower then 
			fam:AddToFollowers()
		else 
			fam:FollowParent()
		end

		if fam.State >= rooms_to_activate and sprite:IsPlaying("Idle") then 
			sprite:Play((fam.FrameCount % 2 == 0 and "Reward2" or "Reward"),true)
			fam.State = fam.State - rooms_to_activate
		end

		if sprite:IsEventTriggered("Reward") then 
			spawn_reward(fam,data,sprite)
		end

		if sprite:IsEventTriggered("FX") then 
			fam:BloodExplode()
		end

		if sprite:IsFinished("Reward") or sprite:IsFinished("Reward2") then 
			sprite:Play("Idle",true)
		end
    end
end

monster.room_rewards = function(self,rng,pos)
	GODMODE.util.macro_on_enemies(nil, monster.type, monster.variant, 0, function(sack)
		sack = sack:ToFamiliar()
		sack.State = sack.State + 1
	end)
end


return monster