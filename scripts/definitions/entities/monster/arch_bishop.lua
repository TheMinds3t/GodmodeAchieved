local monster = {}
monster.name = "Arch Bishop" -- and demon priest (subtype 1)
monster.type = GODMODE.registry.entities.arch_bishop.type
monster.variant = GODMODE.registry.entities.arch_bishop.variant

monster.npc_init = function(self, ent, data)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local killed = GODMODE.save_manager.get_data("DemonPriestKill","false")

	if killed == "true" and GODMODE.room:GetType() == RoomType.ROOM_CURSE and (ent.SubType == 1 or GODMODE.util.is_delirium()) then
		data.unmasked = true
		monster.npc_kill(self,ent)
		Isaac.Spawn(monster.type,monster.variant,2,ent.Position,Vector.Zero,ent)
		ent:Remove()
	end
end

monster.set_delirium_visuals = function(self,ent)
    for i=0,3 do 
        ent:GetSprite():ReplaceSpritesheet(i,"gfx/bosses/deliriumforms/demon_priest.png")
    end
    ent:GetSprite():LoadGraphics()
end

monster.npc_update = function(self, ent, data, sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local player = ent:GetPlayerTarget()

	if data.real_time > 1 then
		if data.dirx == nil then
			data.dirx = (ent:GetDropRNG():RandomInt(2))*2-1
			data.diry = (ent:GetDropRNG():RandomInt(2))*2-1
			data.lasers = {}
			sprite:Play("Idle", true)
			data.move_speed = 1.0
		end

		if data.unmask == true and data.unmasked ~= true then
			sprite:Play("Break", false)
		end

		if data.real_time == 2 and (ent.SubType == 1 and not GODMODE.util.is_delirium()) and data.unmask ~= true then
			GODMODE.game:GetHUD():ShowItemText(Isaac.GetPlayer():GetName().." vs. Demon Priest", "")
		end

		ent.Velocity = ent.Velocity*0.85 + Vector(data.dirx * 0.195,data.diry * 0.165)*data.move_speed

		if ent.Position.X <= GODMODE.room:GetTopLeftPos().X+ent.Size*2 then data.dirx = 1 end
		if ent.Position.Y <= GODMODE.room:GetTopLeftPos().Y+ent.Size*2 then data.diry = 1 end
		if ent.Position.X >= GODMODE.room:GetBottomRightPos().X-ent.Size*2 then data.dirx = -1 end
		if ent.Position.Y >= GODMODE.room:GetBottomRightPos().Y-ent.Size*2 then data.diry = -1 end

		data.burst_cooldown = (data.burst_cooldown or 0) - 1
		if (sprite:IsPlaying("Idle") or sprite:IsPlaying("IdleUnmasked")) and (data.burst_cooldown or 0) <= 0 then
			data.move_speed = math.min(1, (data.move_speed + 0.05) * (31/30))
		else
			data.move_speed = data.move_speed * 0.75
			if data.move_speed < 0.1 then data.move_speed = 0 end
		end

		if sprite:IsPlaying("Idle") and math.floor(data.time) % 25 == 0 and ent.FrameCount > 25 then
			if ent:GetDropRNG():RandomFloat() < 0.8 and (ent.SubType > 0 or 
				GODMODE.util.count_enemies(nil,monster.type,monster.variant) == Isaac.CountEnemies())then
				sprite:Play("Attack",false)
			end
		end

		if sprite:IsPlaying("IdleUnmasked") and math.floor(data.time) % 20 == 0 then
			if ent:GetDropRNG():RandomFloat() < 0.8 then
				sprite:Play("Retaliate",false)
			end
		end

		if sprite:IsFinished("Attack") then
			sprite:Play("Idle",false)
		end

		if sprite:IsFinished("Retaliate") then
			if data.unmasked == true then 
				sprite:Play("IdleUnmasked",false)
			else
				sprite:Play("Idle",false)
			end
		end

		if sprite:IsFinished("Break") then
			sprite:Play("IdleUnmasked",false)
		end
		
		if sprite:IsEventTriggered("Attack") then
			local dist = 4
			local f = player.Position - ent.Position
			f = f:GetAngleDegrees()
			if f < 0 then f = f + 360 end
			f = f % 360
			f = math.floor(f)-- + ang / 5 * i)
			local offset = Vector(math.cos(math.rad(f))*dist,math.sin(math.rad(f))*dist)
			local tell = Isaac.Spawn(GODMODE.registry.entities.unholy_order.type,GODMODE.registry.entities.unholy_order.variant,f,ent.Position+offset,Vector.Zero,ent)
			local tell_data = GODMODE.get_ent_data(tell)
			
			if sprite:IsPlaying("Retaliate") then
				tell_data.fire_time = 20
				tell_data.laser_timeout = 20
			else
				tell_data.fire_time = 30
				tell_data.laser_timeout = 20
			end

			tell.Parent = ent
			tell.SpriteOffset = tell.SpriteOffset - Vector(0,20)
			table.insert(data.lasers, tell)
		end

		if sprite:IsEventTriggered("Burst") then
			if sprite:IsPlaying("Break") then
				ent:BloodExplode()
				ent:BloodExplode()
				ent:BloodExplode()
				ent.HitPoints = ent.MaxHitPoints / 2
				data.unmasked = true
			else
				data.burst_cooldown = 50
				local dist = 4
				local ang_off = ent:GetDropRNG():RandomFloat() * 90
				for i=0,3 do
					local ang = i * (360 / 4) + ang_off
					local f = math.rad(ang)
					local offset = Vector(math.cos(f)*dist,math.sin(f)*dist)
					local tell = Isaac.Spawn(GODMODE.registry.entities.unholy_order.type,GODMODE.registry.entities.unholy_order.variant,math.floor(ang),ent.Position+offset,Vector.Zero,ent)
					local tell_data = GODMODE.get_ent_data(tell)
					tell_data.fire_time = 30
					tell_data.laser_timeout = 30
					tell.Parent = ent
				end
			end
		end

		for ind,laser in ipairs(data.lasers) do
			if laser ~= nil then
				local f = math.rad(laser.SubType)
				local offset = Vector(math.cos(f)*4,math.sin(f)*4)
				laser.Position = ent.Position + offset
			end
			if laser:IsDead() then
				table.remove(data.lasers, ind)
			end
		end
	end
end

monster.npc_kill = function(self, ent)
	local dist = 4
	local base_offset = Vector.Zero
	local count = 4
	local data = GODMODE.get_ent_data(ent)
	local flag = true

	if (ent.SubType == 1 or GODMODE.util.is_delirium())then --Demon Priest
		if data.unmasked ~= true then
			local new = Isaac.Spawn(ent.Type,ent.Variant,ent.SubType,ent.Position,Vector.Zero,ent)
			new:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			GODMODE.get_ent_data(new).unmask = true
			new.HitPoints = 1
			flag = false
			ent:Remove()
		else
			count = 8 
		end
	end

	if flag then
		if GODMODE.save_manager.get_data("DemonPriestKill","false") ~= "true" and ent.SubType == 1 and GODMODE.room:GetType() == RoomType.ROOM_CURSE or ent.SubType ~= 1 or GODMODE.room:GetType() ~= RoomType.ROOM_CURSE then
			if not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then 

				for i=0,count do
					local ang = i * (360 / count)
					local f = math.rad(ang)
					local offset = Vector(math.cos(f)*dist,math.sin(f)*dist) + base_offset
					local tell = Isaac.Spawn(GODMODE.registry.entities.unholy_order.type,GODMODE.registry.entities.unholy_order.variant,math.floor(ang),ent.Position+offset,Vector.Zero,nil)
					local tell_data = GODMODE.get_ent_data(tell)
					tell_data.fire_time = 20
					tell_data.laser_length = 160

					if data.unmasked == true then
						tell_data.laser_timeout = 35
					else
						tell_data.laser_timeout = 25
						tell.Parent = ent
					end
				end
			end
		end

		-- demon priest rewards
		if data.unmasked == true and GODMODE.room:GetType() == RoomType.ROOM_CURSE then
			local rand_vel = function()
				return Vector(-4+ent:GetDropRNG():RandomFloat()*8,-4+ent:GetDropRNG():RandomFloat()*8)
			end
			local rewards = {
				function() 
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0, ent.Position, Vector.Zero, nil) 
				end, 
				function() 
					for i=0,2 do 
						Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 2, ent.Position, rand_vel(), nil) 
					end
				end, 
				function() 
					for i=0,1 do 
						Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, ent.Position, rand_vel(), nil) 
					end

					Isaac.Spawn(GODMODE.registry.entities.heart_container.type, GODMODE.registry.entities.heart_container.variant, 0, ent.Position, rand_vel(), nil) 
				end}
				
			rewards[ent:GetDropRNG():RandomInt(#rewards)+1]()
			GODMODE.save_manager.set_data("DemonPriestKill","true")
		end
	end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)
    if (enthit.Type == monster.type and enthit.Variant == monster.variant) and (enthit.FrameCount < 25 or enthit:GetSprite():IsPlaying("Break") or (flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER and (entsrc.Type ~= 1 and entsrc.Type ~= 3))) then 
        return false 
	elseif GODMODE.util.count_enemies(nil, monster.type, monster.variant) > 0 then
		if flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER
		and enthit:IsVulnerableEnemy() and (entsrc.Type ~= 1 and entsrc.Type ~= 3) and not (enthit.Type == monster.type and enthit.Variant == monster.variant) then 
			local flag = false 
			GODMODE.util.macro_on_enemies(nil, monster.type, monster.variant, 0, function(bishop)
				if bishop:HasEntityFlags(EntityFlag.FLAG_FRIENDLY_BALL) or bishop:HasEntityFlags(EntityFlag.FLAG_CHARM) then 
					flag = true 
				end
			end)
			
			if flag == false then 
			    return false
			end
		elseif amount > 0 and enthit:IsVulnerableEnemy() and not (enthit.Type == monster.type and enthit.Variant == monster.variant) then 
		   GODMODE.util.macro_on_enemies(nil, monster.type, monster.variant, 0, function(bishop)
				if not bishop:GetSprite():IsPlaying("Retaliate") then 
					bishop:GetSprite():Play("Retaliate",true)
				end
		   end)
	   end
	end
end

return monster