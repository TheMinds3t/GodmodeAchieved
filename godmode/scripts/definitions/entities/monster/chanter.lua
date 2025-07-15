local monster = {}
monster.name = "Chanter"
monster.type = GODMODE.registry.entities.chanter.type
monster.variant = GODMODE.registry.entities.chanter.variant

monster.npc_update = function(self, ent, data, sprite)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local player = ent:GetPlayerTarget()

	if sprite:IsPlaying("HeadChant") then
		ent.Velocity = ent.Velocity * 0.2
		sprite:RemoveOverlay()
	else
		sprite:SetOverlayAnimation("Head")
		sprite:SetOverlayRenderPriority(false)
		ent:AnimWalkFrame("WalkHori","WalkVert",0.06)
		local y = ent.Velocity.Y
		local x = ent.Velocity.X

		if (ent.Position - player.Position):Length() > 128 then
			local pathfinding = GODMODE.util.ground_ai_movement(ent,player,0.9,true)

			if pathfinding ~= nil then 
				ent.Velocity = ent.Velocity * 0.75 + pathfinding 
			elseif ent:GetPlayerTarget() ~= nil then 
				ent.Pathfinder:FindGridPath(player.Position,0.7,0,true)
			end
		end

		if not sprite:IsPlaying("HeadChant") and ent:IsFrame(40,15) and ent:GetDropRNG():RandomFloat() < (0.8-math.min(ent.I2 / 8, 0.65)) and ent.FrameCount > 30 then
			ent.I2 = 0
			GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,function(chanter) 
				chanter:GetSprite():Play("HeadChant",true)
				ent.I2 = ent.I2 + 1
			end)
		end
	end

	ent.V1 = (ent.V1 * 9 + player.Velocity) / 10.0

	if ent.I1 > 0 then 
		ent.I1 = ent.I1 - 1
		ent.Velocity = ent.Velocity * 0.5
	end

	if sprite:IsEventTriggered("Ring") then
		ent.I1 = 10
		local threshold = math.min(ent.I2,8) * (5 + (5/8))
		local off = (math.floor(((player.Position + ent.V1 * 36 + ent.Velocity * 48) - ent.Position):GetAngleDegrees() + ent:GetDropRNG():RandomFloat()*threshold-threshold/2)) % 360--ent:GetDropRNG():RandomFloat() * 360 / 5.0
        for l=0,4 do
            local x = ent.Position.X + math.cos(math.rad(off + 360 / 5 * l)) * 32
            local y = ent.Position.Y + math.sin(math.rad(off + 360 / 5 * l)) * 32
            local b = Isaac.Spawn(GODMODE.registry.entities.holy_order.type,GODMODE.registry.entities.holy_order.variant,math.floor(off + 360 / 5 * l),Vector(x,y),Vector(0,0),ent)
            b.Parent = ent
			local b_data = GODMODE.get_ent_data(b)
			b_data.fire_time = 40
			b_data.laser_timeout = 23
        end
	end
end

return monster