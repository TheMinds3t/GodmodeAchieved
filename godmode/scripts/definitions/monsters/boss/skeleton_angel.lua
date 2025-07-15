local monster = {}
monster.name = "The Fallen Light"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

--for the new sprites
local fira_inject = ""--"fira_"
local crack_patterns = {
	{
		Vector(1,0):Rotated(45),
		Vector(1,0):Rotated(45+90),
		Vector(1,0):Rotated(45+180),
		Vector(1,0):Rotated(45+270),
	},
	{
		Vector(1,0):Rotated(45),
		Vector(1,0):Rotated(45+60),
		Vector(1,0):Rotated(45+120),
		Vector(1,0):Rotated(45+180),
		Vector(1,0):Rotated(45+240),
		Vector(1,0):Rotated(45+300),
	},
	{
		Vector(1,0):Rotated(45),
		Vector(1,0):Rotated(45+90),
		Vector(1,0):Rotated(45+180),
		Vector(1,0):Rotated(45+270),
	}
}
local crack_size = 512
local min_crack_size = {96,144,120}
local crack_rotation_speed = {5.0,3.0,3.25}
local crack_size_mult = {0.9,0.85,0.775}

local function is_in_room(pos)
	local tl = Game():GetRoom():GetTopLeftPos()
	local br = Game():GetRoom():GetBottomRightPos()
	return pos.X >= tl.X and pos.Y >= tl.Y and pos.X <= br.X and pos.Y <= br.Y
end

monster.data_init = function(self, params)
	local ent = params[1]
	local data = params[2]
	local player = Isaac.GetPlayer(0)
	ent.HitPoints = ent.HitPoints + math.min(1000,(GODMODE.util.get_basic_dps(ent) / 3.5) * 100)
    ent.MaxHitPoints = ent.HitPoints
	if HPBars then 
		HPBars.BossIgnoreList[monster.type..","..monster.variant] = false
	end
	local light = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LIGHT, 0, ent.Position, Vector.Zero, ent)
	light.Parent = ent
	light:ToEffect().Scale = 4.0
	data.dark_light = light

	Game():ShakeScreen(260)
end

monster.spawn_arc_tear = function(self, ent, ang, speed, curve, height)
    if curve == nil then curve = 0 end
    if height == nil then height = 1.0 end
    local vel = Vector(math.cos(ang) * speed,math.sin(ang) * speed)
    local offset = ent:GetDropRNG():RandomFloat() * 6.28
    local off = Vector(math.cos(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7),math.sin(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7))
    local params = ProjectileParams()
    params.HeightModifier = -1
    params.FallingSpeedModifier = 1.0
    params.FallingAccelModifier = 1.5
    params.Scale = 1.0 + ent:GetDropRNG():RandomFloat()*0.5
    params.CurvingStrength = curve

    local tear = ent:FireBossProjectiles(1, ent.Position + vel, speed, params)
    tear = tear:ToProjectile()
    tear.Height = tear.Height * height
	tear.CollisionDamage = 2
    if curve > 0 then
    	tear.ProjectileFlags = ProjectileFlags.SMART
    	tear.HomingStrength = 0.5
    	tear.CurvingStrength = curve
    end
    --tear.Position = tear.Position + off
    return tear
end
monster.spawn_flat_tear = function(self, ent, ang, speed, height, curve,var)
	curve = curve or 0
	height = height or 0
	var = var or 0
    local ang = math.rad(ang)
    local spd = speed
    local vel = Vector(math.cos(ang)*spd,math.sin(ang)*spd)
    local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,var,0,ent.Position+vel,vel,ent)
    tear = tear:ToProjectile()
    tear.Height = tear.Height * height
	tear.Scale = 1.0 + ent:GetDropRNG():RandomFloat()*0.5
	tear.CollisionDamage = 2

    if curve > 0 then
    	tear.ProjectileFlags = ProjectileFlags.SMART
    	tear.HomingStrength = 0.5
    	tear.CurvingStrength = curve
    end
    --tear.Position = tear.Position + off
    
    table.insert(GODMODE.get_ent_data(ent).tears, {tear,tear.Height})
    tear.Height = -100
    return tear
end
monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()
	local health_perc = ent.HitPoints / ent.MaxHitPoints

	if data.init == nil then
		data.cur_phase = 0
        data.init = true
	end

	if data.tears == nil then data.tears = {} else
		if #data.tears > 0 then
			for i=1,#data.tears do
				local tear = data.tears[i]
				if tear ~= nil then
					if math.abs(tear[1].Height-data.tears[i][2]) > 0.05 then
						tear[1].Height = (tear[1].Height * 9 + data.tears[i][2]) / 10
					else
						tear[1].Height = data.tears[i][2]
						table.remove(data.tears, i)
					end
				end
			end
		end
	end

	if ent:GetSprite():IsFinished("Appear") then
		ent:GetSprite():Play("Idle",true)
		Game():ShakeScreen(10)
	end

	ent.Velocity = ent.Velocity * 0.95

	if ent:GetSprite():IsFinished("Transition") and data.final_phase then
		ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		ent.CollisionDamage = 0
        ent.Size = 50
        ent.Mass = 99999
        ent.HitPoints = 1
        ent.MaxHitPoints = 1
		data.hole_made = true
		ent.Position = Game():GetRoom():GetCenterPos()
		ent.Velocity = Vector(0,0)

		-- for _,ent2 in ipairs(Isaac.FindInRadius(ent.Position,99999.0,EntityPartition.ENEMY)) do
		-- 	ent2:Kill()
		-- end
	end

	data.vessel_count = data.vessel_count or 0

	if data.time % 30 == 0 then 
		data.vessel_count = #GODMODE.util.does_player_have(Isaac.GetItemIdByName("Vessel of Purity")) + #GODMODE.util.does_player_have(Isaac.GetItemIdByName("Cracked Vessel of Purity")) + #GODMODE.util.does_player_have(Isaac.GetItemIdByName("Bloodied Vessel of Purity"))
	end

	if data.hole_made == true and data.soul_made ~= true then
		if data.vessel_count > 0 then
			local soul = Isaac.Spawn(Isaac.GetEntityTypeByName("The Sign"),Isaac.GetEntityVariantByName("The Sign"),0,ent.Position,Vector(0,0),ent)
			soul.DepthOffset = 100
			data.soul = soul
			data.soul_counter = 120
			ent.HitPoints = 1
			ent.MaxHitPoints = 1
		else
			if data.unlock_achieved ~= true then
				data.unlock_achieved = true
				GODMODE.util.macro_on_players(function(player) 
					GODMODE.achievements.unlock_fallen_light(player)
				end)

				if GODMODE.util.count_enemies(ent,EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_BIGCHEST,0) == 0 then 
					Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_BIGCHEST,0,Game():GetRoom():FindFreePickupSpawnPosition(ent.Position-Vector(0,96)),Vector.Zero,ent)
					Game():GetRoom():TrySpawnTheVoidDoor()
				end	
			end	
		end

		data.soul_made = true
	end

	if data.soul ~= nil then
		HPBars:removeBarEntry(ent)
		if data.soul:IsDead() then
			data.soul_counter = data.soul_counter - 1

			if data.soul_counter <= 0 then
				Game():GetRoom():SetClear(true)
			end
			ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		else
			if not ent:HasEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP) then
				ent:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
			end	
			ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		end
	elseif data.hole_made == true then
		if not ent:HasEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP) then
			ent:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP | EntityFlag.FLAG_HIDE_HP_BAR)
		end

		ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY

		if HPBars then 
			HPBars:removeBarEntry(ent)
		end
	end

	if ent:GetSprite():IsFinished("Transition") then 
		ent:GetSprite():Play("Hole",true)
	end

	if ent:GetSprite():IsPlaying("Appear") or ent:GetSprite():IsPlaying("Transition") then
		Game():ShakeScreen(10)
		ent.Position = Game():GetRoom():GetCenterPos()
		ent.Velocity = Vector(0,0)
	elseif ent:GetSprite():IsPlaying("Idle") then
		local ti = player.Position - ent.Position
	    local spd = 2.35
	    
	    if data.final_phase == true then
	    	ti = Game():GetRoom():GetCenterPos() - ent.Position
	    	spd = 2.35
		elseif ent:IsFrame(30, (data.time - data.real_time) % 30 or 0) and ent:GetDropRNG():RandomFloat() < 0.9 then
			local choose_atk = function()
				local chance = ent:GetDropRNG():RandomFloat()
				local attack = 0
				if chance < 0.2 then 
					attack = 3 --holy order
				elseif chance < 0.45+data.cur_phase * 0.1 then 
					attack = 4
				elseif chance < 0.7+data.cur_phase * 0.05 then 
					attack = 2 --crack the sky
				else
					attack = 1 --blood spill
				end

				return attack
			end

			if data.cur_phase == nil then
				data.cur_phase = 0
				choose_atk = function() return 0 end
			elseif data.cur_phase == 1 then
				if health_perc <= 0.444 then
					ent:GetSprite():Play("Phase",true)
					data.last_attack = nil
					choose_atk = function() return 0 end
				end
			elseif data.cur_phase == 0 then
				if health_perc <= 0.666 then
					ent:GetSprite():Play("Phase",true)
					data.last_attack = nil
					choose_atk = function() return 0 end
				end
			end

			local attack = choose_atk()
					
			if data.last_attack ~= nil then 
				while data.last_attack == attack do
					if attack == 1 and ent:GetDropRNG():RandomFloat() < 0.5 then 
						break
					end
					attack = choose_atk()
				end
			end

			if attack > 0 then
				-- attack = 4
				if attack == 1 then 
					data.atk1_off = ent:GetDropRNG():RandomFloat()
					ent:GetSprite():Play("Attack1",true)
				elseif attack == 2 then
					ent:GetSprite():Play("Attack2",true)
					data.crack_size = 10
					data.crack_pattern_size = crack_size
				elseif attack == 3 then
					ent:GetSprite():Play("Attack3",true)
				elseif attack == 4 then 
					ent:GetSprite():Play("Shield",true)
					local shield_type = ent:GetDropRNG():RandomInt(data.cur_phase + 1)
					while shield_type == (data.shield_type or -1) and data.cur_phase > 0 do 
						shield_type = ent:GetDropRNG():RandomInt(data.cur_phase + 1)
					end

					data.shield_type = shield_type
				end
				data.last_attack = attack
			end
		end

		if ti:Length() > 4 then
			ent.Position = ent.Position + ti:Resized(spd)
		elseif data.final_phase == true and data.hole_made ~= true then
			for i=0,16 do
				if fira_inject ~= "" and i ~= 5 and i ~= 16 or fira_inject == "" and i ~= 6 then --replace all spritesheets except for the light that shows during the appear animation
					ent:GetSprite():ReplaceSpritesheet(i,"/gfx/bosses/skeletal_angel_"..fira_inject.."2.png")
				end
			end
			ent:GetSprite():LoadGraphics()
			ent.DepthOffset = -100
			ent.Position = Game():GetRoom():GetCenterPos()
			ent:GetSprite():Play("Transition", true)
		end
	else
		local ti = Game():GetRoom():GetCenterPos() - ent.Position
	    local spd = 0.25
	    if ent:GetSprite():IsPlaying("Attack3") then spd = 0.0 end
	    if ent:GetSprite():IsPlaying("Attack2") then spd = 0.6 end
	    ent.Velocity = ent.Velocity * 0.6

	    ent.Position = ent.Position + Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)
	end

	if ent:GetSprite():IsFinished("Attack1") or ent:GetSprite():IsFinished("Attack2") or ent:GetSprite():IsFinished("Attack3") or ent:GetSprite():IsFinished("Shield") or ent:GetSprite():IsFinished("Phase") then
		ent:GetSprite():Play("Idle",true)
		data.crack_size = 10
	end

	if ent:GetSprite():IsEventTriggered("Shake") then
		Game():ShakeScreen(20)
	end	

	if ent:GetSprite():IsEventTriggered("Phase") then
		data.cur_phase = data.cur_phase	+ 1
		Game():GetRoom():EmitBloodFromWalls(5,10)
		Game():ShakeScreen(20)
		
		for i=0,16 do
			if i ~= 5 then
				ent:GetSprite():ReplaceSpritesheet(i,"/gfx/bosses/skeletal_angel_"..fira_inject..(tostring(data.cur_phase))..".png")
			end
		end

		ent:GetSprite():LoadGraphics()
		data.crack_spots = data.crack_spots or {}
		table.insert(data.crack_spots, {pos=ent.Position,var=ent:GetDropRNG():RandomInt(2)+1})

		for _,pos in ipairs(data.crack_spots) do 
			Isaac.Spawn(Isaac.GetEntityTypeByName("Fallen Light Crack"), Isaac.GetEntityVariantByName("Fallen Light Crack"), pos.var, pos.pos,Vector.Zero,ent)
		end

		if GODMODE.is_at_palace and GODMODE.is_at_palace() then
			GODMODE.set_palace_stage(math.max(GODMODE.get_palace_stage(),data.cur_phase+1))
		end

		-- local count = 6 + data.cur_phase * 2
		-- local off = ent:GetDropRNG():RandomFloat() * (360/count)
		-- for l=0,2 do
		-- 	local speed = 3+l*4
		-- 	for i=0,count do
		-- 		local ang = math.rad(360/count*i+off*(l+0.5)) 
		-- 		local vel = Vector(math.cos(ang)*speed,math.sin(ang)*speed)
		-- 		local orb = Isaac.Spawn(Isaac.GetEntityTypeByName("Skeletal Soul (The Fallen Light Projectile)"), Isaac.GetEntityVariantByName("Skeletal Soul (The Fallen Light Projectile)"), 2, ent.Position, vel, ent)
		-- 		orb:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		-- 		orb:GetSprite():Play("OrbSpawn", true)
		-- 		GODMODE.get_ent_data(orb).target_pos = ent.Position + vel:Resized(speed*50+300)
		-- 	end
		-- end
	end

	if ent:GetSprite():IsPlaying("Attack2") then --crack the sky new
		if ent:IsFrame(8-data.cur_phase,1) then 
			local target_pos = ent.Position 

			if (data.cur_phase or 0) >= 1 then 
				target_pos = player.Position
			end

			local pattern = crack_patterns[data.cur_phase+1]

			for _,pos in ipairs(pattern) do 
				local crack = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.CRACK_THE_SKY,2,
				target_pos+pos:Resized(1):Rotated(ent.FrameCount*crack_rotation_speed[data.cur_phase+1])*(data.crack_pattern_size+ent:GetDropRNG():RandomFloat()*4-2),	Vector.Zero,ent)
				crack.Parent = ent
			end
			data.crack_pattern_size = math.max(min_crack_size[data.cur_phase+1],(data.crack_pattern_size or 0) * crack_size_mult[data.cur_phase + 1])
		end
	end

	--Isaac.DebugString("SkelAngel CurPhase: "..tostring(data.cur_phase))

	if ent:GetSprite():IsEventTriggered("Shoot") then
		if ent:GetSprite():IsPlaying("Attack1") then --blood spill
			data.atk1_off = data.atk1_off + 1
			Game():ShakeScreen(2)
			local off =  data.atk1_off * (360/8)

			if data.cur_phase == 0 then
				local count = 4 + data.atk1_off/2
				for l=0,1 do
					for i=0, count/(1+l) do
			            local spd = 2.5 + data.atk1_off * 0.1
			            spd = spd / (1 + l)
			            local f = 360 / count * i + off
			            local tear = monster:spawn_flat_tear(ent,f,spd,0.8,0.0)
			            tear.FallingSpeed = 0.0
			            tear.FallingAccel = -(6/60.0)
			            tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.ACCELERATE 
			            --tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
			        end
		        end
			elseif data.cur_phase == 1 then
				local count = 6 + math.floor((ent:GetSprite():GetFrame() - 28) / 7.0)
				for l=0,1 do
					for i=0, count/(1+l) do
			            local spd = 2.5 + data.atk1_off * 0.1
			            spd = spd / (1 + l)
			            local f = 360 / count * i + off
			            if i % 6 == 0 then
				            local tear = monster:spawn_flat_tear(ent,f,spd * 0.5,1.25,0.00125)
				            tear.FallingSpeed = 0.3
				            tear.FallingAccel = (-3.0/60.0)
				            tear.Scale = 1.25
				            tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.ACCELERATE 
				            --tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
				        else
				            local tear = monster:spawn_flat_tear(ent,f,spd,0.8,0.0)
				            tear.FallingSpeed = 0.0
				            tear.FallingAccel = -(6/60.0)
				            tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.ACCELERATE 
				            --tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
				        end
			        end
		        end
			elseif data.cur_phase == 2 then
				local count = 3
				for l=0,3 do
					for i=0, count do
						if i % (l + count) < 3 then
							local spd = 2.75 + data.atk1_off * 0.085
							spd = spd / (1 + l)
							local f = 360 / count * i + off + l * data.atk1_off * 360 / count + ent:GetDropRNG():RandomFloat() * (360/count)
							local tear = monster:spawn_flat_tear(ent,f,spd,0.8,0.0)
							tear.FallingSpeed = 0.0
							tear.FallingAccel = -(6/60.0)
							tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.ACCELERATE 
							tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
							--tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
						end
			        end
		        end
			end
		elseif ent:GetSprite():IsPlaying("Attack2") then --crack the sky
			data.crack_size = data.crack_size or 0
			if data.crack_size > 9 then
				local count = 8 + data.cur_phase*2
				local off = (data.crack_size-9) * (360/count)/2
				local speed = 3+(data.crack_size-9)*4
				for i=0,count do
					local ang = math.rad(360/count*i+off*(data.crack_size-9)*1.25) 
					local vel = Vector(math.cos(ang)*speed,math.sin(ang)*speed)
					local orb = Isaac.Spawn(Isaac.GetEntityTypeByName("Skeletal Soul (The Fallen Light Projectile)"), Isaac.GetEntityVariantByName("Skeletal Soul (The Fallen Light Projectile)"), 2, ent.Position, vel, ent)
					orb:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					orb:GetSprite():Play("OrbSpawn", true)
					GODMODE.get_ent_data(orb).target_pos = ent.Position + vel:Resized(speed*50+300)
				end
	        end

			data.crack_size = data.crack_size - 0.5

			-- if data.cur_phase == 0 then
			-- 	local scale = data.crack_size * 0.8 + 0.125
			-- 	for i=0,2 do
		    --         local f = math.floor(360 / 3 * i + data.time * 20)
		    --         local off = Vector(math.cos(math.rad(f))*48*scale,math.sin(math.rad(f))*32*scale)

			-- 		if is_in_room(ent.Position + off) then
			-- 			local order = Isaac.Spawn(Isaac.GetEntityTypeByName("Crack The Sky (With Tell)"), Isaac.GetEntityVariantByName("Crack The Sky (With Tell)"),f,ent.Position+off,Vector(0,0),ent)
			-- 			order:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			-- 			order.Parent = ent
			-- 		end
		    --     end
			-- 	data.crack_size = data.crack_size - 0.5
			-- elseif data.cur_phase == 1 then
			-- 	local scale = data.crack_size
			-- 	for i=0,5 do
		    --         local f = math.floor(360 / 7 * i + data.time * 30)
		    --         local off = Vector(math.cos(math.rad(f))*64*scale,math.sin(math.rad(f))*48*scale)
			-- 		if is_in_room(ent.Position + off) then
			-- 			local order = Isaac.Spawn(Isaac.GetEntityTypeByName("Crack The Sky (With Tell)"), Isaac.GetEntityVariantByName("Crack The Sky (With Tell)"),f,ent.Position+off,Vector(0,0),ent)
			--             order.Parent = ent
			--             order:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			-- 		end
		    --     end
			-- 	data.crack_size = data.crack_size - 0.5
			-- elseif data.cur_phase == 2 then
			-- 	local scale = data.crack_size * 1.2
			-- 	for i=0,6 do
		    --         local f = math.floor(ent:GetDropRNG():RandomFloat() * 360)
		    --         local off = Vector(math.cos(math.rad(f))*45*scale,math.sin(math.rad(f))*40*scale)
			-- 		if is_in_room(ent.Position + off) then
			-- 			local order = Isaac.Spawn(Isaac.GetEntityTypeByName("Crack The Sky (With Tell)"), Isaac.GetEntityVariantByName("Crack The Sky (With Tell)"),f,ent.Position+off,Vector(0,0),ent)
			--             order.Parent = ent
			--             order:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			-- 		end
		    --     end
			-- 	data.crack_size = data.crack_size - 0.5
			-- end
		elseif ent:GetSprite():IsPlaying("Attack3") then --ring of holy orders
			Game():ShakeScreen(5)

			if data.cur_phase == 0 then
				local ang = ent:GetDropRNG():RandomFloat() * 360/10
				for i=0,10 do
		            local f = math.floor(360 / 10 * i + ang)
		            local off = Vector(math.cos(math.rad(f))*40,math.sin(math.rad(f))*40)
		            local order = Isaac.Spawn(Isaac.GetEntityTypeByName("Holy Order"), Isaac.GetEntityVariantByName("Holy Order"),f,ent.Position+off,Vector(0,0),ent)
		            order.Parent = ent
		        end
			elseif data.cur_phase == 1 then
				local ang = ent:GetDropRNG():RandomFloat() * 360/12
				for i=0,12 do
		            local f = math.floor(360 / 12 * i + ang)
		            local off = Vector(math.cos(math.rad(f))*40,math.sin(math.rad(f))*40)
		            local order = Isaac.Spawn(Isaac.GetEntityTypeByName("Holy Order"), Isaac.GetEntityVariantByName("Holy Order"),f,ent.Position+off,Vector(0,0),ent)
		            order.Parent = ent
		        end
			elseif data.cur_phase == 2 then
				local ang = 360 / 14
				local max_spread = 135
				for i=-7,7 do
		            local f = (player.Position) - ent.Position
		            f = f:GetAngleDegrees() + ang * i
		            if f < 0 then f = f + 360 end
		            f = f % 360
		            f = math.floor(f)-- + ang / 5 * i)
		            local off = Vector(math.cos(math.rad(f))*40,math.sin(math.rad(f))*40)
		            local order = Isaac.Spawn(Isaac.GetEntityTypeByName("Holy Order"), Isaac.GetEntityVariantByName("Holy Order"),f,ent.Position+off,Vector(0,0),ent)
		            order.Parent = ent
		        end
			end
		elseif ent:GetSprite():IsPlaying("Shield") then --shield

			if data.shield_type == 0 then -- star patterns
				local speed_levels = 2 + data.cur_phase
				local count = (speed_levels*2)*(9-math.floor(data.cur_phase * 2.5))
				local off = ent:GetDropRNG():RandomFloat()*(360/speed_levels)
				local dir = ent:GetDropRNG():RandomInt(2) == 1
	
				for i=1, count do
					local spd_lvl = math.abs(i % (speed_levels * 2) - speed_levels)
					-- GODMODE.log("lvl="..spd_lvl,true)
					local spd = 3
					local f = 360 / count * i + off
					local tear = monster:spawn_flat_tear(ent,f,spd,0.8,0.0,ProjectileVariant.PROJECTILE_BONE)
					-- tear.Scale = 1.0 + spd_lvl * 0.333*(1.125 - data.cur_phase * 0.125)
					tear.Scale = 1.0
					tear.FallingSpeed = 0.0
					tear.FallingAccel = -(6/60.0)
					tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.ACCELERATE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT 
					tear:AddChangeFlags(ProjectileFlags.SINE_VELOCITY)
					tear.ChangeTimeout = 20
					tear.ChangeVelocity = (spd_lvl*(1.3 - data.cur_phase * 0.3) + spd)
					tear.Color = Color(1.0,1.0,1.0,1.0,(50+(spd_lvl/speed_levels)*150)/255,0,0)
					--tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
				end
				-- GODMODE.log("ct="..count,true)
			elseif data.shield_type == 1 then --bone ring
				local count = 16+data.cur_phase * 2
				local off = (player.Position - ent.Position):GetAngleDegrees()--ent:GetDropRNG():RandomFloat()*(360/count)
	
				for i=1, count do
					-- GODMODE.log("lvl="..spd_lvl,true)
					local spd = 4
					local f = 360 / count * i + off
					local tear = monster:spawn_flat_tear(ent,f,spd,0.8,0.0,ProjectileVariant.PROJECTILE_BONE)
					tear.Scale = 1.0
					tear.FallingSpeed = 0.0
					tear.FallingAccel = -(6/60.0)
					tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.MEGA_WIGGLE | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT 
					tear.ChangeTimeout = 16
					tear.ChangeVelocity = 4
					-- tear.Color = Color(1.0,1.0,1.0,1.0,150/255,150/255,150/255)
					--tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
				end			
			elseif data.shield_type == 2 then --backsplit pattern
				local count = 2
				local off = (player.Position - ent.Position):GetAngleDegrees()--ent:GetDropRNG():RandomFloat()*(360/count)
	
				for i=1, count do
					-- GODMODE.log("lvl="..spd_lvl,true)
					local spd = 4
					local f = 360 / count * i + off
					local tear = monster:spawn_flat_tear(ent,f,spd,0.8,0.0)
					tear.Scale = 2.675
					tear.FallingSpeed = 0.0
					tear.FallingAccel = -(6/60.0)
					tear:AddChangeFlags(ProjectileFlags.SIDEWAVE)
					tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.SIDEWAVE | ProjectileFlags.CHANGE_FLAGS_AFTER_TIMEOUT | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT 
					tear.ChangeTimeout = 16
					tear.ChangeVelocity = 9
					-- tear.Color = Color(1.0,1.0,1.0,1.0,150/255,150/255,150/255)
					--tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
				end
			end
			

			-- GODMODE.log("proj count = "..count,true)
		end
	end

	if ent.HitPoints < 1.0 then ent.HitPoints = 1.0 end

	if ent:GetSprite():IsEventTriggered("Bleed") and data.cur_phase == 2 then
		for i=0,7 do
            local spd = 0.05 + ent:GetDropRNG():RandomFloat()*0.05
            local f = math.rad(360 / 8 * i + ent:GetDropRNG():RandomFloat() * 43)
            monster:spawn_arc_tear(ent,f,spd,0.0,0.9)
        end
        --ent:TakeDamage(5.0,DamageFlag.DAMAGE_DEVIL,EntityRef(ent),0)
	end
end


monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)
	--Isaac.DebugString("Parent type: "..tostring(entsrc.Entity.Parent.Type)..", Spawner type: "..tostring(entsrc.Entity.SpawnerEntity.Type)..", Child type: "..tostring(entsrc.Entity.Child.Type)..", Child type: "..tostring(entsrc.Entity.Child.Type))
	if enthit.Type == monster.type and enthit.Variant == monster.variant then
		if data and (data.final_phase or false) == true or enthit.MaxHitPoints == 1 then return false end
		local flag = false
		local phase_locks = {0.666,0.444,0.0}

		if enthit.HitPoints / enthit.MaxHitPoints < phase_locks[(data.cur_phase or 0) + 1] then 
			return false 
		end 

		if entsrc.Entity then
			if entsrc.Entity.Parent then
				flag = enthit.Type == entsrc.Entity.Parent.Type	
			elseif entsrc.Entity.SpawnerEntity then
				flag = enthit.Type == entsrc.Entity.SpawnerEntity.Type	
			end
		end
		
		if flags & DamageFlag.DAMAGE_LASER == DamageFlag.DAMAGE_LASER and flag or enthit:GetSprite():IsPlaying("Appear") then 
			return false 
		end

		if enthit.HitPoints - amount <= Isaac.GetPlayer(0).Damage * 10  then
			data.final_phase = true
			return false
		end
	end
end

return monster