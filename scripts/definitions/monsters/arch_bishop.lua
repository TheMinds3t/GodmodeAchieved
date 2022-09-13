local monster = {}
monster.name = "Arch Bishop" -- and demon priest (subtype 1)
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_init = function(self, ent)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local killed = GODMODE.save_manager.get_data("DemonPriestKill","false")

	if killed == "true" and Game():GetRoom():GetType() == RoomType.ROOM_CURSE and (ent.SubType == 1 or GODMODE.util.is_delirium()) then
		local data = GODMODE.get_ent_data(ent)
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

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()

	if data.real_time > 1 then
		if data.dirx == nil then
			data.dirx = (ent:GetDropRNG():RandomInt(2))*2-1
			data.diry = (ent:GetDropRNG():RandomInt(2))*2-1
			data.lasers = {}
			ent:GetSprite():Play("Idle", true)
			data.move_speed = 1.0
		end

		if data.unmask == true and data.unmasked ~= true then
			ent:GetSprite():Play("Break", false)
		end

		if data.real_time == 2 and (ent.SubType == 1 and not GODMODE.util.is_delirium()) and data.unmask ~= true then
			Game():GetHUD():ShowItemText(Isaac.GetPlayer():GetName().." vs. Demon Priest", "")
		end

		ent.Velocity = ent.Velocity*0.85 + Vector(data.dirx * 0.195,data.diry * 0.165)*data.move_speed

		if ent.Position.X <= Game():GetRoom():GetTopLeftPos().X+ent.Size*2 then data.dirx = 1 end
		if ent.Position.Y <= Game():GetRoom():GetTopLeftPos().Y+ent.Size*2 then data.diry = 1 end
		if ent.Position.X >= Game():GetRoom():GetBottomRightPos().X-ent.Size*2 then data.dirx = -1 end
		if ent.Position.Y >= Game():GetRoom():GetBottomRightPos().Y-ent.Size*2 then data.diry = -1 end

		data.burst_cooldown = (data.burst_cooldown or 0) - 1
		if (ent:GetSprite():IsPlaying("Idle") or ent:GetSprite():IsPlaying("IdleUnmasked")) and (data.burst_cooldown or 0) <= 0 then
			data.move_speed = math.min(1, (data.move_speed + 0.05) * (31/30))
		else
			data.move_speed = data.move_speed * 0.75
			if data.move_speed < 0.1 then data.move_speed = 0 end
		end

		if ent:GetSprite():IsPlaying("Idle") and math.floor(data.time) % 25 == 0 and ent.FrameCount > 25 then
			if ent:GetDropRNG():RandomFloat() < 0.8 and (ent.SubType > 0 or 
				GODMODE.util.count_enemies(nil,monster.type,monster.variant) == Isaac.CountEnemies())then
				ent:GetSprite():Play("Attack",false)
			end
		end

		if ent:GetSprite():IsPlaying("IdleUnmasked") and math.floor(data.time) % 20 == 0 then
			if ent:GetDropRNG():RandomFloat() < 0.8 then
				ent:GetSprite():Play("Retaliate",false)
			end
		end

		if ent:GetSprite():IsFinished("Attack") then
			ent:GetSprite():Play("Idle",false)
		end

		if ent:GetSprite():IsFinished("Retaliate") then
			if data.unmasked == true then 
				ent:GetSprite():Play("IdleUnmasked",false)
			else
				ent:GetSprite():Play("Idle",false)
			end
		end

		if ent:GetSprite():IsFinished("Break") then
			ent:GetSprite():Play("IdleUnmasked",false)
		end
		
		if ent:GetSprite():IsEventTriggered("Attack") then
			local dist = 4
			local f = player.Position - ent.Position
			f = f:GetAngleDegrees()
			if f < 0 then f = f + 360 end
			f = f % 360
			f = math.floor(f)-- + ang / 5 * i)
			local offset = Vector(math.cos(math.rad(f))*dist,math.sin(math.rad(f))*dist)
			local tell = Game():Spawn(Isaac.GetEntityTypeByName("Unholy Order"),Isaac.GetEntityVariantByName("Unholy Order"),ent.Position+offset,Vector.Zero,ent,f,ent.InitSeed)
			local tell_data = GODMODE.get_ent_data(tell)
			
			if ent:GetSprite():IsPlaying("Retaliate") then
				tell_data.fire_time = 15
				tell_data.laser_timeout = 20
			else
				tell_data.fire_time = 25
				tell_data.laser_timeout = 20
			end

			tell.Parent = ent
			tell.SpriteOffset = tell.SpriteOffset - Vector(0,20)
			table.insert(data.lasers, tell)
		end

		if ent:GetSprite():IsEventTriggered("Burst") then
			if ent:GetSprite():IsPlaying("Break") then
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
					local tell = Game():Spawn(Isaac.GetEntityTypeByName("Unholy Order"),Isaac.GetEntityVariantByName("Unholy Order"),ent.Position+offset,Vector.Zero,ent,math.floor(ang),ent.InitSeed)
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
		if GODMODE.save_manager.get_data("DemonPriestKill","false") ~= "true" and ent.SubType == 1 and Game():GetRoom():GetType() == RoomType.ROOM_CURSE or ent.SubType ~= 1 or Game():GetRoom():GetType() ~= RoomType.ROOM_CURSE then
			if not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then 

				for i=0,count do
					local ang = i * (360 / count)
					local f = math.rad(ang)
					local offset = Vector(math.cos(f)*dist,math.sin(f)*dist) + base_offset
					local tell = Isaac.Spawn(Isaac.GetEntityTypeByName("Unholy Order"),Isaac.GetEntityVariantByName("Unholy Order"),math.floor(ang),ent.Position+offset,Vector.Zero,nil)
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

		if data.unmasked == true and Game():GetRoom():GetType() == RoomType.ROOM_CURSE then
			local rand_vel = function()
				return Vector(-4+ent:GetDropRNG():RandomFloat()*8,-4+ent:GetDropRNG():RandomFloat()*8)
			end
			local rewards = {
				function() 
					Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0, ent.Position, Vector.Zero, nil) 
				end, 
				function() 
					for i=0,1 do 
						Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_GRAB_BAG, 2, ent.Position, rand_vel(), nil) 
					end
				end, 
				function() 
					for i=0,2 do 
						Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLACK, ent.Position, rand_vel(), nil) 
					end
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
			   bishop:GetSprite():Play("Retaliate",false)
		   end)
	   end
	end
end

return monster