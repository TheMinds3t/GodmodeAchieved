local monster = {}
monster.name = "[GODMODE] Hellfiah"
monster.type = GODMODE.registry.entities.hellfiah_familiar.type
monster.variant = GODMODE.registry.entities.hellfiah_familiar.variant

monster.min_charge_time = 24
monster.blue_flame_threshold = 50
monster.max_charge_time = 80
monster.charge_decay_scale = math.floor(monster.max_charge_time / 17.5)
monster.attack_increase_scale = math.floor(monster.max_charge_time / 10.0)
monster.fire_delay = 2
monster.min_fire_stats = {spread=50,speed=9,life=35,dmg=2}
monster.add_fire_stats = {spread=-40,speed=10,life=-18,dmg=4}
monster.additive_intensity = 0.75
monster.fire_variance = 0.33
monster.fire_move_scale = 0.0625

monster.color_max = 0.6
monster.color_var = 0.025
monster.color_scale = {r = 0, g = 0.7, b = 1}

local states = {
	idle = 0,
	charge = 1,
	attack = 2,
	exit_attack = 3,
}

local anim_states = { -- anim_states[dir][state]
	[Direction.LEFT] = {
		flip=true,
		anims={
			[states.idle]="FloatSide",
			[states.charge]="ChargeSide",
			[states.attack]="ShootSide",
			[states.exit_attack]="ExitShootSide", 
		}
	},
	[Direction.UP] = {
		flip=false,
		anims={
			[states.idle]="FloatUp",
			[states.charge]="ChargeUp",
			[states.attack]="ShootUp",
			[states.exit_attack]="ExitShootUp",
		}
	},
	[Direction.RIGHT] = {
		flip=false,
		anims={
			[states.idle]="FloatSide",
			[states.charge]="ChargeSide",
			[states.attack]="ShootSide",
			[states.exit_attack]="ExitShootSide", 
		}
	},
	[Direction.DOWN] = {
		flip=false,
		anims={
			[states.idle]="FloatDown",
			[states.charge]="ChargeDown",
			[states.attack]="ShootDown",
			[states.exit_attack]="ExitShootDown",
		}
	},
}

monster.familiar_init = function(self, fam)
    if fam.Type == monster.type and fam.Variant == monster.variant then
    end
end

monster.update_cur_anim = function(self, fam, data)
	local dir = fam.Player:GetFireDirection() 
	if dir == Direction.NO_DIRECTION then dir = data.last_dir or Direction.DOWN end 
		
	local anm_dat = anim_states[dir]
	fam.FlipX = anm_dat.flip
	data.cur_anim = anm_dat.anims[fam.State]
	fam:GetSprite():Play(data.cur_anim,true)
end

monster.familiar_update = function(self, fam, data)
    local player = fam.Player
    if fam.Type == monster.type and fam.Variant == monster.variant then
		fam:GetSprite():Play("Idle", false)
		local dir = player:GetFireDirection()
		local bffs = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)

		if fam.State == states.exit_attack then 
			if fam:GetSprite():IsFinished(data.cur_anim) then 
				fam.State = states.idle
				monster.update_cur_anim(self, fam, data)
				fam:AddToFollowers()
			end

			fam.Velocity = fam.Velocity * 0.925
		else
			if dir ~= Direction.NO_DIRECTION then 
				if fam.State == states.idle then 
					-- start charge
					fam.State = states.charge
					monster.update_cur_anim(self, fam, data)
				elseif fam.State == states.charge and (data.last_dir or 0) ~= dir then 
					monster.update_cur_anim(self, fam, data)
				end

				if fam.State ~= states.attack then 
					data.last_dir = dir 
				end
			else
				if fam.FireCooldown >= monster.min_charge_time and fam.State ~= states.attack then -- start attack
					fam.State = states.attack
					fam:RemoveFromFollowers()
					GODMODE.sfx:Play(GODMODE.registry.sounds.child_blargh, 1.5, 2, false, 0.95 + fam:GetDropRNG():RandomFloat()*0.1)
					GODMODE.sfx:Play(SoundEffect.SOUND_FIRE_RUSH, 0.7, 0, false, 0.95 + fam:GetDropRNG():RandomFloat()*0.1)
				elseif fam.State ~= states.attack then -- reset
					fam.State = states.idle
					fam.FireCooldown = 0
				end
	
				if fam.State > states.idle then 
					monster.update_cur_anim(self, fam, data)
				end
			end	

			if fam.State ~= states.attack then 
				fam:FollowParent()
			end
		end

		-- animate blue pulse
		if fam.FireCooldown > monster.blue_flame_threshold and fam.State == states.charge or bffs == true then 
			data.blue_tick = (data.blue_tick or 0) + 1
		end

		if fam.State == states.charge then 
			fam:GetSprite().PlaybackSpeed = 0

			fam.FireCooldown = math.min(monster.max_charge_time,fam.FireCooldown + 1)
			local perc = fam.FireCooldown / monster.max_charge_time 

			fam:GetSprite():SetFrame(math.floor(perc * 15))
		elseif fam.State == states.attack then 
			fam.FireCooldown = math.max(0,math.min(monster.max_charge_time,fam.FireCooldown) - monster.charge_decay_scale)
			data.attack_time = (data.attack_time or 0) + monster.attack_increase_scale

			if not bffs then 
				data.blue_tick = 0
			end

			local attack_perc = math.min(1,math.max(0,(data.attack_time) / monster.max_charge_time))

			if fam:IsFrame(monster.fire_delay, 1) then -- fire!
				local spread = monster.min_fire_stats.spread + monster.add_fire_stats.spread * attack_perc
				local life_scalar = 1
				local var = EffectVariant.RED_CANDLE_FLAME

				if fam:GetDropRNG():RandomFloat() < 0.5 then 
					GODMODE.sfx:Play(SoundEffect.SOUND_FIREDEATH_HISS, 0.75, 2, false, 0.95 + fam:GetDropRNG():RandomFloat()*0.1)
				else
					GODMODE.sfx:Play(SoundEffect.SOUND_BEAST_FIRE_BARF, 0.6, 2, false, 1.05 + fam:GetDropRNG():RandomFloat()*0.1)
				end

				data.roll_blue = ((data.roll_blue or 0.33) + 0.33)

				if fam.FireCooldown >= monster.blue_flame_threshold or fam:GetDropRNG():RandomFloat() < data.roll_blue * (bffs and 1 or 0) then 
					var = EffectVariant.BLUE_FLAME
					life_scalar = 3.5
					spread = spread / life_scalar
					data.roll_blue = 0.33
				end

				local dir = Vector(-1,0):Rotated(data.last_dir * 90 - spread / 2.0 + fam:GetDropRNG():RandomFloat() * spread)
					:Resized((monster.min_fire_stats.speed + monster.add_fire_stats.speed * attack_perc)*(1.0 - fam:GetDropRNG():RandomFloat() * monster.fire_variance)/(1 + (life_scalar - 1) * 0.085))
				
				dir = dir + player:GetTearMovementInheritance(dir) * 1.5

				local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, var, 0, fam.Position+dir:Resized(16 - attack_perc * 8), dir, fam.Player):ToEffect()
				effect:SetTimeout(math.floor((monster.min_fire_stats.life + monster.add_fire_stats.life * (1 - attack_perc))*(1.0 - fam:GetDropRNG():RandomFloat() * monster.fire_variance)*life_scalar))
				effect.CollisionDamage = (monster.min_fire_stats.dmg + monster.add_fire_stats.dmg * (1 - attack_perc)) / (1 + (life_scalar - 1) / 5)
				effect.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS 
				effect.Scale = 1 - attack_perc * 0.25
				effect:ClearEntityFlags(EntityFlag.FLAG_APPEAR)	
				effect:SetTimeout(100)
				fam.Velocity = fam.Velocity - dir * monster.fire_move_scale
				effect:Update()
			end

			if fam.FireCooldown <= 0 then 
				fam:GetSprite().PlaybackSpeed = 1
				fam.State = states.exit_attack
				monster.update_cur_anim(self, fam, data)
			end
		else 
			if fam:GetSprite().PlaybackSpeed == 0 then 
				monster.update_cur_anim(self, fam, data)
			end

			fam:GetSprite().PlaybackSpeed = 1
			data.attack_time = 0

			if not bffs then 
				data.blue_tick = 0
			end
		end

		local col_off = math.min(monster.max_charge_time, fam.FireCooldown) / monster.max_charge_time * monster.color_max
						 + math.sin(fam.FireCooldown) * monster.color_var

		local blue_off = math.abs(math.sin(math.rad((data.blue_tick or 0) * 10))) * 0.15
		if fam.FireCooldown < monster.min_charge_time then 
			col_off = 0 
			if not bffs then 
				blue_off = 0 
			else 
				blue_off = blue_off * 0.25
			end
		end 

		fam:SetColor(Color(
			1-col_off*monster.color_scale.r-blue_off,
			1-col_off*monster.color_scale.g-blue_off*0.5,
			1-col_off*monster.color_scale.b+blue_off,
			1,
			(col_off*(1.0 - monster.color_scale.r) - blue_off)*monster.additive_intensity,
			(col_off*(1.0 - monster.color_scale.g) - blue_off*0.5)*monster.additive_intensity,
			(col_off*(1.0 - monster.color_scale.b) + blue_off)*monster.additive_intensity),
			100,100,false,false)

		fam.Velocity = fam.Velocity * 0.925
    end
end

return monster