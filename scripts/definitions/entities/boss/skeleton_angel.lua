local monster = {}
monster.name = "The Fallen Light"
monster.type = GODMODE.registry.entities.the_fallen_light.type
monster.variant = GODMODE.registry.entities.the_fallen_light.variant

--for the new sprites
local fira_inject = "fira_" --""
local fira_max_layers = 16 --11
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
local base_tear_height = -160
local explode_height_off = -98
local tear_dampen = 12
local tear_up_frame_count = 8
local tear_up_strength = 18
local tear_up_strength_2 = 14 --for a "transition"

local cam_damp = 3


local function is_in_room(pos)
	local tl = GODMODE.room:GetTopLeftPos()
	local br = GODMODE.room:GetBottomRightPos()
	return pos.X >= tl.X and pos.Y >= tl.Y and pos.X <= br.X and pos.Y <= br.Y
end

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 	
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

		if GODMODE.save_manager.get_data("FallenLightCleared","false") == "false" then 
			GODMODE.game:ShakeScreen(260)
		end
	end
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
monster.spawn_flat_tear = function(self, ent, ang, speed, height, curve, var, start_high)
	curve = curve or 0
	height = height or 0
	var = var or 0
	start_high = start_high or false
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
    
    table.insert(GODMODE.get_ent_data(ent).tears, {tear,tear.Height,start_high})
    tear.Height = base_tear_height
    return tear
end

monster.spawn_blood_fx = function(self,ent,explode_col)
	explode_col = explode_col or Color(0.7,0.6,0.6,0.95,0.3,0,0)
	local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FLY_EXPLOSION,0,ent.Position+Vector(0, explode_height_off)+RandomVector()*((ent.InitSeed % 60) / 30),Vector(0,-0.1),ent):ToEffect()
	fx:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	fx.DepthOffset = 150
	fx:SetColor(explode_col,999,1,false,true)
	fx.Rotation = fx:GetDropRNG():RandomInt(360)
	fx.Scale = fx:GetDropRNG():RandomFloat()*0.2 + 0.9
end

monster.npc_init = function(self, ent, data)
	if GODMODE.save_manager.get_data("FallenLightCleared","false") == "true" then 
		ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		data.cur_phase = 2
		data.soul_made = true 
		ent:GetSprite():Play("Hole",true)

		ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		ent.CollisionDamage = 0
        ent.Size = 50
        ent.Mass = 99999
        ent.HitPoints = 1
        ent.MaxHitPoints = 1
		data.hole_made = true
		ent.Position = GODMODE.room:GetCenterPos()
		ent.Velocity = Vector(0,0)
		ent.DepthOffset = -150

		local chest = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_BIGCHEST,0,GODMODE.room:FindFreePickupSpawnPosition(ent.Position-Vector(0,96)),Vector.Zero,ent)
		chest:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	end
end

monster.do_unlocks = function(self, ent, data)
	if data.unlock_achieved ~= true then 
		GODMODE.util.macro_on_players(function(player) 
			GODMODE.achievements.unlock_fallen_light(player)
		end)
	
		if GODMODE.util.count_enemies(ent,EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_BIGCHEST,0) == 0 then 
			Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_BIGCHEST,0,GODMODE.room:FindFreePickupSpawnPosition(ent.Position-Vector(0,96)),Vector.Zero,ent)
			GODMODE.room:TrySpawnTheVoidDoor()
		end	
		
		if GODMODE.validate_rgon() and GODMODE.save_manager.get_data("FallenLightCleared","false") == "false" then 
			local add = math.max(0,-1 * Isaac.GetPersistentGameData():GetEventCounter(EventCounter.STREAK_COUNTER))
			Isaac.GetPersistentGameData():IncreaseEventCounter(EventCounter.STREAK_COUNTER,add + 1)
			GODMODE.log("adding "..(add + 1).." to win streak!",true)
		end

		if data.soul == nil then 
			GODMODE.save_manager.set_data("FallenLightCleared","true",true) 
		end	
	end
end

monster.npc_kill = function(self, ent)
	GODMODE.achievements.play_splash("cheater", 1)
	monster.do_unlocks(self,ent,GODMODE.get_ent_data(ent))
end

monster.npc_update = function(self, ent, data, sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
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
					if math.abs(tear[1].Height-tear[2]) > 0.05 then
						local tear_up_perc = math.max(0,math.min(1, (tear[1].FrameCount - tear_up_frame_count) / tear_up_frame_count))
						-- GODMODE.log(tostring(tear[3]),true)
						if tear[1].FrameCount < tear_up_frame_count and tear[3] == true then --raise the tear initially if floaty tear is enabled
							local dampen = (1 - math.max(0,math.min(1, (tear[1].FrameCount - tear_up_frame_count) / tear_up_frame_count))) * (0.85 + (tear[1].InitSeed % 64) / 64 * 0.3)
							tear[1].Height = tear[1].Height - tear_up_strength * dampen
						else -- 
							local dampen = tear_dampen

							if tear[3] == true and tear[1].FrameCount < tear_up_frame_count * 2 then --add a dampen if floaty tear is enabled to make an "arc"
								local dampen = 1 - math.max(0,math.min(1, (tear[1].FrameCount - tear_up_frame_count * 2) / tear_up_frame_count))
								tear[1].Height = tear[1].Height - tear_up_strength_2 * dampen
							end

							tear[1].Height = (tear[1].Height * (dampen - 1) + tear[2]) / dampen
						end
					else
						tear[1].Height = tear[2]
						table.remove(data.tears, i)
					end
				end
			end
		end
	end

	if sprite:IsFinished("Appear") then
		sprite:Play("Idle",true)
		GODMODE.game:ShakeScreen(10)
	end

	ent.Velocity = ent.Velocity * 0.95

	if sprite:IsFinished("Transition") and data.final_phase then
		ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
		ent.CollisionDamage = 0
        ent.Size = 50
        ent.Mass = 99999
        ent.HitPoints = 1
        ent.MaxHitPoints = 1
		data.hole_made = true
		ent.Position = GODMODE.room:GetCenterPos()
		ent.Velocity = Vector(0,0)

		-- for _,ent2 in ipairs(Isaac.FindInRadius(ent.Position,99999.0,EntityPartition.ENEMY)) do
		-- 	ent2:Kill()
		-- end
	end

	if data.hole_made == true and data.soul_made ~= true then
		if (GODMODE.util.total_item_count(GODMODE.registry.items.vessel_of_purity_1) + GODMODE.util.total_item_count(GODMODE.registry.items.vessel_of_purity_2) + GODMODE.util.total_item_count(GODMODE.registry.items.vessel_of_purity_3)) > 0 then
			local soul = Isaac.Spawn(GODMODE.registry.entities.the_sign.type,GODMODE.registry.entities.the_sign.variant,0,ent.Position,Vector(0,0),ent)
			soul.DepthOffset = 100
			data.soul = soul
			data.soul_counter = 120
			ent.HitPoints = 1
			ent.MaxHitPoints = 1
		else
			monster.do_unlocks(self,ent,GODMODE.get_ent_data(ent))
		end

		data.soul_made = true
	end
	
	if data.hole_made == true then 
		ent.Velocity = GODMODE.room:GetCenterPos() - ent.Position
	end

	if data.soul ~= nil then
		-- if HPBars then HPBars:removeBarEntry(ent) end
		
		if data.soul:IsDead() then
			data.soul_counter = data.soul_counter - 1

			if data.soul_counter <= 0 then
				GODMODE.room:SetClear(true)
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

	if sprite:IsFinished("Transition") then 
		sprite:Play("Hole",true)
	end

	if sprite:IsPlaying("Appear") or sprite:IsPlaying("Transition") then
		GODMODE.game:ShakeScreen(10)
		ent.Position = GODMODE.room:GetCenterPos()
		ent.Velocity = Vector(0,0)
	elseif sprite:IsPlaying("Idle") then
		local ti = player.Position - ent.Position
	    local spd = 2.35
	    
	    if data.final_phase == true then
	    	ti = GODMODE.room:GetCenterPos() - ent.Position
	    	spd = 2.35
		elseif ent:IsFrame(12, ((data.time or 0) - (data.real_time or 0)) % 12) and ent:GetDropRNG():RandomFloat() < 0.9 then
			local choose_atk = function()
				local attack = 0

				-- chance to attack
				if (data.atk_cooldown or 0) * (0.11 + (data.cur_phase or 1) * 0.225) > math.max(ent:GetDropRNG():RandomFloat(),0.5) then 
					-- attack chance
					local chance = ent:GetDropRNG():RandomFloat()
					data.atk_cooldown = 0

					if chance < 0.2+data.cur_phase * 0.025 then 
						attack = 3 --holy order
					elseif chance < 0.45+data.cur_phase * 0.1 then 
						attack = 4 --bone star, bone ring, double large proj with perp shots, bone proj
					elseif chance < 0.7+data.cur_phase * 0.05 then 
						attack = 2 --crack the sky
					else
						attack = 1 --blood spill
					end	
				else 
					data.atk_cooldown = (data.atk_cooldown or 0) + 1 + ent:GetDropRNG():RandomFloat()
				end

				return attack
			end

			if data.cur_phase == nil then
				data.cur_phase = 0
				choose_atk = function() return 0 end
			elseif data.cur_phase == 1 then
				if health_perc <= 0.444 then
					sprite:Play("Phase",true)
					data.last_attack = nil
					choose_atk = function() return 0 end
				end
			elseif data.cur_phase == 0 then
				if health_perc <= 0.666 then
					sprite:Play("Phase",true)
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
					sprite:Play("Attack1",true)
				elseif attack == 2 then
					sprite:Play("Attack2",true)
					data.crack_size = 10
					data.crack_pattern_size = crack_size
				elseif attack == 3 then
					sprite:Play("Attack3",true)
				elseif attack == 4 then 
					sprite:Play("Shield",true)
					local shield_type = ent:GetDropRNG():RandomInt(data.cur_phase + 2)
					while shield_type == (data.shield_type or -1) and data.cur_phase > 0 do 
						shield_type = ent:GetDropRNG():RandomInt(data.cur_phase + 2)
					end

					data.shield_type = shield_type
				end
				data.last_attack = attack
			end
		end

		if ti:Length() > 4 then
			ent.Position = ent.Position + ti:Resized(spd)
		elseif data.final_phase == true and data.hole_made ~= true then
			for i=0,fira_max_layers do
				if fira_inject ~= "" and i ~= 5 and i ~= fira_max_layers or fira_inject == "" and i ~= 6 then --replace all spritesheets except for the light that shows during the appear animation
					sprite:ReplaceSpritesheet(i,"/gfx/bosses/skeletal_angel_"..fira_inject.."2.png")
				end
			end
			sprite:LoadGraphics()
			ent.DepthOffset = -100
			ent.Position = GODMODE.room:GetCenterPos()
			sprite:Play("Transition", true)
		end
	else
		local ti = GODMODE.room:GetCenterPos() - ent.Position
	    local spd = 0.25
	    if sprite:IsPlaying("Attack3") then spd = 0.0 end
	    if sprite:IsPlaying("Attack2") then spd = 0.6 end
	    ent.Velocity = ent.Velocity * 0.6

	    ent.Position = ent.Position + Vector(math.cos(math.rad(ti:GetAngleDegrees())) * spd,math.sin(math.rad(ti:GetAngleDegrees())) * spd)
	end

	-- camera logic!
	if GODMODE.validate_rgon() and data.hole_made ~= true then 
		local targ = (GODMODE.room:GetCenterPos() * 3 + player.Position * 2 + ent.Position) / 6.0
		data.cam_pos = ((data.cam_pos or targ) * (cam_damp - 1) + targ) / cam_damp

		GODMODE.room:GetCamera():SetFocusPosition(data.cam_pos)
	end

	if sprite:IsFinished("Attack1") or sprite:IsFinished("Attack2") or sprite:IsFinished("Attack3") or sprite:IsFinished("Shield") or sprite:IsFinished("Phase") then
		sprite:Play("Idle",true)
		data.crack_size = 10
	end

	if sprite:IsEventTriggered("Shake") then
		GODMODE.game:ShakeScreen(20)
	end	

	if sprite:IsEventTriggered("Phase") then
		data.cur_phase = data.cur_phase	+ 1
		GODMODE.room:EmitBloodFromWalls(5,10)
		GODMODE.game:ShakeScreen(20)
		
		for i=0,fira_max_layers do
			if fira_inject ~= "" and i ~= 5 and i ~= fira_max_layers or fira_inject == "" and i ~= 6 then
				sprite:ReplaceSpritesheet(i,"/gfx/bosses/skeletal_angel_"..fira_inject..(tostring(data.cur_phase))..".png")
			end
		end

		sprite:LoadGraphics()
		GODMODE.game:MakeShockwave(ent.Position, 0.05, 0.15, 20)
		data.crack_spots = data.crack_spots or {}
		table.insert(data.crack_spots, {pos=ent.Position,var=ent:GetDropRNG():RandomInt(2)+1})

		for _,pos in ipairs(data.crack_spots) do 
			Isaac.Spawn(GODMODE.registry.entities.fallen_light_crack.type, GODMODE.registry.entities.fallen_light_crack.variant, pos.var, pos.pos,Vector.Zero,ent)
		end

		if GODMODE.is_at_palace and GODMODE.is_at_palace() then
			GODMODE.set_palace_stage(math.max(GODMODE.get_palace_stage(),data.cur_phase+1))
		end
	end

	if sprite:IsPlaying("Attack2") then --crack the sky new
		if ent:IsFrame(8-math.floor(data.cur_phase * 1.5),1) then 
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

	if sprite:IsEventTriggered("Shoot") then
		if sprite:IsPlaying("Attack1") then --blood spill
			monster:spawn_blood_fx(ent)
			data.atk1_off = data.atk1_off + 1
			GODMODE.game:ShakeScreen(2)
			local off =  data.atk1_off * (360/8)

			if data.cur_phase == 0 then
				local count = 4 + data.atk1_off/2
				for l=0,1 do
					for i=0, count/(1+l) do
			            local spd = 2.5 + data.atk1_off * 0.1
			            spd = spd / (1 + l)
			            local f = 360 / count * i + off
			            local tear = monster:spawn_flat_tear(ent,f,spd,0.8,0.0,ProjectileVariant.PROJECTILE_BLOOD,true)
			            tear.FallingSpeed = 0.0
			            tear.FallingAccel = -(6/60.0)
			            tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.ACCELERATE 
			            --tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
			        end
		        end
			elseif data.cur_phase == 1 then
				local count = 6 + math.floor((sprite:GetFrame() - 28) / 7.0)
				for l=0,1 do
					for i=0, count/(1+l) do
			            local spd = 2.5 + data.atk1_off * 0.1
			            spd = spd / (1 + l)
			            local f = 360 / count * i + off
			            if i % 6 == 0 then
				            local tear = monster:spawn_flat_tear(ent,f,spd * 0.5,1.25,0.00125,ProjectileVariant.PROJECTILE_BLOOD,true)
				            tear.FallingSpeed = 0.3
				            tear.FallingAccel = (-3.0/60.0)
				            tear.Scale = 1.25
				            tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.ACCELERATE 
				            --tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
				        else
				            local tear = monster:spawn_flat_tear(ent,f,spd,0.8,0.0,ProjectileVariant.PROJECTILE_BLOOD,true)
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
							local tear = monster:spawn_flat_tear(ent,f,spd,0.8,0.0,ProjectileVariant.PROJECTILE_BLOOD,true)
							tear.FallingSpeed = 0.0
							tear.FallingAccel = -(6/60.0)
							tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.ACCELERATE 
							tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
							--tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
						end
			        end
		        end
			end
		elseif sprite:IsPlaying("Attack2") then --crack the sky

			data.crack_size = data.crack_size or 0
			if data.crack_size > 9 then
				local count = 8 + data.cur_phase*2
				local off = (data.crack_size-9) * (360/count)/2
				local speed = 3+(data.crack_size-9)*4
				for i=1,count do
					local ang = math.rad(360/count*i+off*(data.crack_size-9)*1.25) 
					local vel = Vector(math.cos(ang)*speed,math.sin(ang)*speed)
					local orb = Isaac.Spawn(GODMODE.registry.entities.cotv_damage_orb.type, GODMODE.registry.entities.cotv_damage_orb.variant, GODMODE.registry.entities.cotv_damage_orb.subtype, ent.Position, vel, ent)
					orb:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					orb:GetSprite():Play("OrbSpawn", true)
					GODMODE.get_ent_data(orb).target_pos = ent.Position + vel:Resized(speed*50+300)
				end
	        end

			data.crack_size = data.crack_size - 0.5
		elseif sprite:IsPlaying("Attack3") then --ring of holy orders
			GODMODE.game:ShakeScreen(5)

			if data.cur_phase == 0 then
				local ang = ent:GetDropRNG():RandomFloat() * 360/10
				for i=0,10 do
		            local f = math.floor(360 / 10 * i + ang)
		            local off = Vector(math.cos(math.rad(f))*40,math.sin(math.rad(f))*40)
		            local order = Isaac.Spawn(GODMODE.registry.entities.holy_order.type, GODMODE.registry.entities.holy_order.variant,f,ent.Position+off,Vector(0,0),ent)
		            order.Parent = ent
		        end
			elseif data.cur_phase == 1 then
				local ang = ent:GetDropRNG():RandomFloat() * 360/12
				for i=0,12 do
		            local f = math.floor(360 / 12 * i + ang)
		            local off = Vector(math.cos(math.rad(f))*40,math.sin(math.rad(f))*40)
		            local order = Isaac.Spawn(GODMODE.registry.entities.holy_order.type, GODMODE.registry.entities.holy_order.variant,f,ent.Position+off,Vector(0,0),ent)
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
		            local order = Isaac.Spawn(GODMODE.registry.entities.holy_order.type, GODMODE.registry.entities.holy_order.variant,f,ent.Position+off,Vector(0,0),ent)
		            order.Parent = ent
		        end
			end
		elseif sprite:IsPlaying("Shield") then --shield

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
					local tear = monster:spawn_flat_tear(ent,f,spd,0.8,0.0,ProjectileVariant.PROJECTILE_BONE,false)
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
			elseif data.shield_type == 1 then -- fallen light bohn
				local max_random = 3 + data.cur_phase
				local spawn_bone = function(pos)
					local bone = Isaac.Spawn(GODMODE.registry.entities.fallen_light_bone.type,GODMODE.registry.entities.fallen_light_bone.variant,0,pos,RandomVector():Resized(ent:GetDropRNG():RandomFloat()*0.5+1) + (player.Position - pos):Resized(4),nil)
					bone.Parent = ent
					bone:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					bone:Update()
				end
				GODMODE.util.macro_on_players(function(player) 
					spawn_bone(player.Position)
					max_random = max_random - 1
				end)

				while max_random > 0 do 
					local off = Vector(0,1):Resized(128 + ent:GetDropRNG():RandomFloat() * 200):Rotated(ent:GetDropRNG():RandomFloat() * 360.0)
					spawn_bone(GODMODE.room:FindFreePickupSpawnPosition(Isaac.GetRandomPosition()))
					-- local bone = Isaac.Spawn(GODMODE.registry.entities.fallen_light_bone.type,GODMODE.registry.entities.fallen_light_bone.variant,0,Isaac.GetRandomPosition(),Vector.Zero,nil)
					-- bone:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					max_random = max_random - 1
				end
			elseif data.shield_type == 2 then --bone ring
				local count = 16+data.cur_phase * 2
				local off = (player.Position - ent.Position):GetAngleDegrees()--ent:GetDropRNG():RandomFloat()*(360/count)
				
				for i=1, count do
					-- GODMODE.log("lvl="..spd_lvl,true)
					local spd = 4
					local f = 360 / count * i + off
					local tear = monster:spawn_flat_tear(ent,f,spd,0.8,0.0,ProjectileVariant.PROJECTILE_BONE,false)
					tear.Scale = 1.0
					tear.FallingSpeed = 0.0
					tear.FallingAccel = -(6/60.0)
					tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.MEGA_WIGGLE | ProjectileFlags.CHANGE_VELOCITY_AFTER_TIMEOUT 
					tear.ChangeTimeout = 16
					tear.ChangeVelocity = 4
					-- tear.Color = Color(1.0,1.0,1.0,1.0,150/255,150/255,150/255)
					--tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
				end			
			elseif data.shield_type == 3 then --backsplit pattern
				local count = 2
				local off = (player.Position - ent.Position):GetAngleDegrees()--ent:GetDropRNG():RandomFloat()*(360/count)
				
				for i=1, count do
					-- GODMODE.log("lvl="..spd_lvl,true)
					local spd = 4
					local f = 360 / count * i + off
					local tear = monster:spawn_flat_tear(ent,f,spd,0.8,0.0,ProjectileVariant.PROJECTILE_BLOOD,false)
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

	if sprite:IsEventTriggered("RoarFX") then 
		if sprite:IsPlaying("Attack2") then 
			monster:spawn_blood_fx(ent,Color(0.2,0.2,0.2,0.5,0.8,0.8,0.8))
		elseif sprite:IsPlaying("Attack3") then 
			monster:spawn_blood_fx(ent,Color(1,0.9,0.2,0.7,0.9,0.8,0.7))
		end
	end

	if sprite:IsEventTriggered("Bleed") and data.cur_phase == 2 then
		for i=0,7 do
            local spd = 0.05 + ent:GetDropRNG():RandomFloat()*0.05
            local f = math.rad(360 / 8 * i + ent:GetDropRNG():RandomFloat() * 43)
            local tear = monster:spawn_arc_tear(ent,f,spd,0.0,0.9)
			tear.Height = tear.Height - ent:GetDropRNG():RandomInt(40)
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
		local phase_locks = {0.666,0.444,0.05}

		if enthit.HitPoints / enthit.MaxHitPoints < phase_locks[(data.cur_phase or 0) + 1] then 
			GODMODE.log("phase="..data.cur_phase,true)

			if (data.cur_phase or 0) == 2 then 
				enthit.HitPoints = enthit.MaxHitPoints * phase_locks[(data.cur_phase or 0) + 1]
				data.final_phase = true
			end

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
	end
end

return monster