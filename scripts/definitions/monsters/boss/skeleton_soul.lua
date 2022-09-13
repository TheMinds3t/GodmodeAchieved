local monster = {}
monster.name = "The Sign"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

local max_health = 2 * 60 * 30 --two minutes
local max_timeout = 101 --used to penalize the player for standing still

monster.tell = Sprite()
monster.tell:Load("gfx/ui/chargebar.anm2", true)

local get_ring_offset = function(perc)
	if perc < 0.2 then
		return 20
	elseif perc < 0.4 then
		return 25
	elseif perc < 0.6 then
		return 30
	elseif perc < 0.8 then
		return 10
	else
		return 23
	end
end

local get_phase = function(perc)
	if perc < 0.2 then
		return 4
	elseif perc < 0.4 then
		return 3
	elseif perc < 0.6 then
		return 2
	elseif perc < 0.8 then
		return 1
	else
		return 0
	end
end

monster.spawn_flat_tear = function(self, ent, ang, speed, height, curve)
    if curve == nil then curve = 0 end
    if height == nil then height = 1.0 end
    local ang = math.rad(ang)
    local spd = speed
    local vel = Vector(math.cos(ang)*spd,math.sin(ang)*spd)
    local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position+vel,vel,ent)
    tear = tear:ToProjectile()
    tear.Height = tear.Height * height
    if curve > 0 then
    	tear.ProjectileFlags = ProjectileFlags.SMART
    	tear.HomingStrength = 0.5
    	tear.CurvingStrength = curve
    end
    --tear.Position = tear.Position + off
    
    return tear
end
monster.npc_init = function(self, ent)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
		ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		ent:GetSprite():Play("Spawn",true)
	end
end

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()

	local dest = Game():GetRoom():GetCenterPos()

	ent.Position = (ent.Position * 59.0 + dest) / 60.0
	ent.Velocity = Vector(0,0)

	if data.phase_count == nil then
		data.phase_count = -1
		data.prev_offset = 23
		data.phase_pause = 0
		data.wave_type = 0
		data.death_time = 0
		data.idle_timeout = 0
		data.idle_pos_check = {}
	end

	if data.finished_intro ~= true then
		if not ent:GetSprite():IsPlaying("Spawn") then
			-- if ent:HasEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP) then
			-- 	ent:ClearEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
			-- end

			if ent.HitPoints < max_health then
				ent.MaxHitPoints = max_health
				ent.HitPoints = ent.HitPoints + 60
			elseif ent.HitPoints > max_health then
				ent.HitPoints = max_health
			end
		else
			ent.HitPoints = 1
			ent.MaxHitPoints = max_health
			-- if not ent:HasEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP) then
			-- 	ent:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
			-- end
		end
	elseif player:ToPlayer() and not ent:GetSprite():IsPlaying("Death") then
		data.idle_pos_check = data.idle_pos_check or {}
		table.insert(data.idle_pos_check,player.Position)
		local timeout = max_timeout
		if player:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_GNAWED_LEAF) then timeout = 60 end
		if #data.idle_pos_check > timeout then
			table.remove(data.idle_pos_check,1)
		end

		local count = 0
		for i=1,#data.idle_pos_check do
			local pos = data.idle_pos_check[i]

			if math.abs(pos.X - player.Position.X) < 2.0 and math.abs(pos.Y - player.Position.Y) < 2.0 then
				count = count + 1
			end
		end

		data.idle_timeout = math.min(timeout,count)
		if count >= 9 and data.render_flag ~= true then
			data.render_idle_timeout = math.min(9,data.idle_timeout)
			data.render_flag = true
		end

		if count >= timeout and ent:IsFrame(10,0) and not ent:GetSprite():IsPlaying("Death") then
			player.Velocity = player.Velocity + Vector(0,1)
			player:ToPlayer():ResetItemState()
			Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.CRACK_THE_SKY,0,player.Position,Vector(0,0),ent)
			Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.CRACK_THE_SKY,0,ent.Position,Vector(0,0),ent)
		end
	end

	if ent.HitPoints >= max_health then
		data.finished_intro = true
	end

	if ent:GetSprite():IsFinished("Spawn") then
		ent:GetSprite():Play("Idle0", true)
	end

	if ent:GetSprite():IsEventTriggered("BloodExplode") then
		ent:BloodExplode()
	end

	if data.finished_intro == true then
		if ent.HitPoints <= 0 then
			--death sequence
			data.death_time = data.death_time - 1
			if ent:GetSprite():IsPlaying("Idle4") and data.death_time <= -120 then
				ent:GetSprite():Play("Death", true)
			end

			if ent:GetSprite():IsFinished("Death") then
				ent:Die()
			elseif ent:GetSprite():IsPlaying("Death") then
				Game():ShakeScreen(10)
			end
		else
			local perc = ent.HitPoints / max_health
			ent.HitPoints = ent.HitPoints - 1

			ent:GetSprite():Play("Idle"..tostring(get_phase(perc)), false)

			if data.prev_offset ~= get_ring_offset(perc) then
				data.phase_count = data.phase_count + 1
				data.prev_offset = get_ring_offset(perc)
				data.phase_pause = 30
			end

			data.phase_pause = data.phase_pause - 1

			if ent:IsFrame(math.floor(60 - get_ring_offset(perc)), 0) and data.phase_pause <= 0 then
				local count = 36
				local flags = 0
				local scale = 1.0
				local speed = 0.0
				local fall_accel = -((5.1)/60.0)
				local used_flag = false
				local color = Color(1,1,1,1)


				if used_flag == false and (data.phase_count == 1 or (data.phase_count >= 2 and data.wave_type == 0)) then
					count = 6
					scale = 2.5
					speed = 1.9
					fall_accel = -((5.5)/60.0)
					flags = ProjectileFlags.EXPLODE + ProjectileFlags.WIGGLE
					used_flag = true
					data.wave_type = 1

					if data.phase_count == 3 then
						count = 4
					end
				end

				if used_flag == false and (data.phase_count == 0 or (data.phase_count >= 2 and data.wave_type == 1)) then 
					count = 10
					scale = 1.5
					speed = 1.2
					fall_accel = -((4.85)/60.0)
					flags = ProjectileFlags.BURST
					used_flag = true
					color = Color(0.6,0.5,0.2,1,0.15,0.05,0)

					if data.phase_count == 2 then
						count = 8
						data.wave_type = 0
					end
					if data.phase_count == 3 then
						count = 6
						data.wave_type = -1
					end
				end

				if used_flag == false and (data.phase_count == 3 and data.wave_type <= -1) then
					data.wave_type = 0
					count = 32
				end

				local off = ent:GetDropRNG():RandomFloat()*360/count
				if data.phase_count == 3 then count = math.min(48,math.floor(count * 1.25)) end

				local spot = ent:GetDropRNG():RandomInt(math.max(3,count-3))+3

				if count <= 30 then spot = -1 end
	
				for i=1, count do
					if math.abs(spot - i) > math.floor(data.phase_count/3 + 3) or spot == -1 then 
			            local spd = 3.0 + speed
			            local f = 360 / count * i + off
			            local tear = monster:spawn_flat_tear(ent,f,spd,1.0,0.0)
			            tear.Scale = scale
			            -- tear.FallingSpeed = 0.0
			            tear.FallingAccel = -5.0/60.0
						-- tear:SetColor(color,9999,9999,false,false)
						GODMODE.get_ent_data(tear).base_color = color
			            tear.Position = tear.Position - tear.Velocity:Resized(740)
			            tear.ProjectileFlags = tear.ProjectileFlags + ProjectileFlags.NO_WALL_COLLIDE + flags
			            --tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
						tear.Parent = ent
						tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
					end
		        end
			end
		end
	end
end

monster.npc_remove = function(self,ent) 
	if GODMODE.is_at_palace and GODMODE.is_at_palace() and StageAPI.InExtraRoom() and ent:IsDead() then 
		GODMODE.util.macro_on_players(function(player) 
			GODMODE.achievements.unlock_fallen_light(player)
		end)
		local count = GODMODE.util.total_item_count(Isaac.GetItemIdByName("Vessel of Purity")) * 3 + GODMODE.util.total_item_count(Isaac.GetItemIdByName("Cracked Vessel of Purity")) * 2 + GODMODE.util.total_item_count(Isaac.GetItemIdByName("Bloodied Vessel of Purity")) * 1

		for i=1,count+1 do
			GODMODE.achievements.unlock_sign_buff()
		end

		Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_BIGCHEST,0,Game():GetRoom():FindFreePickupSpawnPosition(ent.Position-Vector(0,96)),Vector.Zero,nil)
		Game():GetRoom():TrySpawnTheVoidDoor()
	end
end

monster.npc_post_render = function(self, ent, offset)
	local data = GODMODE.get_ent_data(ent)

	if data.finished_intro == true then 
		if monster.tell ~= nil and (data.idle_timeout or 0) > 1 then
			monster.tell.Color = Color(1,1,1,math.min(9,math.max(0,data.idle_timeout - 9))/9)

			local scale = 1

			if ent:GetPlayerTarget():ToPlayer() and ent:GetPlayerTarget():ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_GNAWED_LEAF) then 
				scale = 101/60
			end

			monster.tell:SetFrame("Charging", math.ceil(data.idle_timeout*scale))
			data.render_flag = true

			monster.tell:Render(Isaac.WorldToScreen(ent.Position+ent.SpriteOffset)+Vector(0,-40),Vector.Zero,Vector.Zero)
		elseif (data.render_idle_timeout or 0) > 9 or data.render_flag == true then
			monster.tell.Color = Color(1,1,1,1)
			monster.tell:SetFrame("Disappear", 9-math.ceil(data.render_idle_timeout or 0))
			data.render_idle_timeout = (data.render_idle_timeout or 0) - 0.5
			if data.render_idle_timeout <= 0 then data.render_flag = false end

			monster.tell:Render(Isaac.WorldToScreen(ent.Position+ent.SpriteOffset)+Vector(0,-40),Vector.Zero,Vector.Zero)
		end
	end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == monster.type and enthit.Variant == monster.variant and (GODMODE.get_ent_data(enthit).finished_intro ~= true or enthit.HitPoints / enthit.MaxHitPoints < 0.1) then
		return false
	end
end


--Make projectiles remove themselves
local scale_dists = {
	[1.0] = 48,
	[1.5] = 256,
	[2.5] = -780,
}

local proj_color_threshold = 256

monster.projectile_update = function(self, projectile)
	if projectile.Parent ~= nil and projectile.Parent.Type == monster.type and projectile.Parent.Variant == monster.variant then 
		local data = GODMODE.get_ent_data(projectile)
		local soul = projectile.Parent 
		local dist = scale_dists[projectile.Scale] or 64
		data.base_height = data.base_height or projectile.Height

		if projectile.Scale >= 1.0 then --prevent split projectiles from persisting
			projectile.Height = data.base_height
		end

		local perc = math.min(1.0,math.min((projectile.Position - soul.Position):Length()-dist,proj_color_threshold) / (proj_color_threshold))
		data.base_color = data.base_color or projectile.Color
		projectile.Color = Color.Lerp(data.base_color,Color(data.base_color.R,data.base_color.G,data.base_color.B,1.0,((1.0-perc)*100)/255,0,0),1.0-perc)

		if (projectile.Position - soul.Position):Length() < math.abs(dist) then 
			if dist < 0 then 
				data.entered = true 
			else 
				projectile:Kill()
			end
		elseif (data.entered or false) == true then 
			projectile:Remove()
		end
	end
end

return monster