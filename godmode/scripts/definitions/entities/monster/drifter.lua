local monster = {}
monster.name = "Drifter"
monster.type = GODMODE.registry.entities.drifter.type
monster.variant = GODMODE.registry.entities.drifter.variant

monster.npc_update = function(self, ent, data, sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
	local player = ent:GetPlayerTarget()
	ent.SplatColor = Color(0.1,1,1,0.4,1,1,1)

	local set_pos = function()
		ent.TargetPosition = ent.Position + Vector(1,1):Rotated(ent:GetDropRNG():RandomFloat() * 360):Resized(80)

		if player ~= nil and (player.Position - ent.Position):Length() < 160 then 
			ent.TargetPosition = ent.Position + (player.Position - ent.Position):Resized(math.min((player.Position - ent.Position):Length(),80))
		end

		ent.TargetPosition = GODMODE.room:GetGridPosition(GODMODE.room:GetGridIndex(ent.TargetPosition))
	end

	if sprite:IsFinished("Appear") then 
		sprite:Play("Idle",true)
		ent.TargetPosition = ent.Position
	end

	if sprite:IsEventTriggered("Jump") then 
		set_pos()
		local depth = 25

		while (GODMODE.room:GetGridPosition(GODMODE.room:GetGridIndex(ent.Position)) == GODMODE.room:GetGridPosition(GODMODE.room:GetGridIndex(ent.TargetPosition))
			or (ent.TargetPosition - ent.Position):Length() > 128
			or GODMODE.room:GetGridCollision(GODMODE.room:GetGridIndex(ent.TargetPosition)) ~= GridCollisionClass.COLLISION_NONE) and depth > 0 do 
			set_pos()
			depth = depth - 1
		end

	elseif sprite:IsEventTriggered("Land") then 
		ent.TargetPosition = ent.Position
	end

	if sprite:IsFinished("Hop") then 
		sprite:Play("Idle",true)
	elseif sprite:IsFinished("Idle") then 
		sprite:Play("Hop",true)
	end

	if ent.TargetPosition ~= ent.Position and sprite:IsPlaying("Hop") then 
		ent.Velocity = ent.Velocity * 0.8 + (ent.TargetPosition - ent.Position) / 20.0
	else
		ent.Velocity = ent.Velocity * 0.9
	end

	if sprite:IsEventTriggered("fire") then
		local t = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,2,0,ent.Position,ent.Velocity * -0.15,ent)   
		t:SetColor(Color(0.25,1.0,1.0,0.4,1.8,1.8,1.8),60,100,false,false)
	end
end

return monster