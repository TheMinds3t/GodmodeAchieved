local monster = {}
monster.name = "Cursed Snail"
monster.type = GODMODE.registry.entities.cursed_snail.type
monster.variant = GODMODE.registry.entities.cursed_snail.variant

local moving_animations = {
	["Move Hori"] = true,
	["Move Down"] = true,
	["Move Up"] = true,
}

local main_activation_radius = 192
local activation_radius = 320
local shield_check_time = 15 
local target_pos_scalar = 1.0 / 120.0
local min_distance = 20
local min_speed, max_speed = 0.025, 0.2

monster.familiar_update = function(self, fam, data, sprite)
    if fam.Type == monster.type and fam.Variant == monster.variant then
		local player = fam.Player 
		local spd_mult = 0
		if not sprite:IsPlaying("Appear") then
			if fam.State == 0 then 
				fam.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
				sprite:Play("Sleep", false)
				spd_mult = 0.0
			elseif fam.State == 1 then
				if sprite:GetAnimation() == "Sleep" then 
					spd_mult = 0.2
					sprite:Play("Wake", false)
				elseif sprite:IsFinished("Wake") or moving_animations[sprite:GetAnimation()] == true then 
					spd_mult = 1
					local x,y = fam.Velocity.X,fam.Velocity.Y

					if math.abs(x) > math.abs(y) then 
						sprite:Play("Move Hori",false)
					else 
						if y > 0 then 
							sprite:Play("Move Down",false)
						else
							sprite:Play("Move Up",false)
						end
					end
				end
			end
		end
		
		if sprite:IsEventTriggered("SFX") then 
			GODMODE.sfx:Play(GODMODE.registry.sounds.meow)
		end

		if fam:IsFrame(shield_check_time,1) then 
			local players = Isaac.FindInRadius(fam.Position, activation_radius)
			local closest = nil 
			data.player_targ = nil

			GODMODE.util.macro_on_players(function(player2) 
				local targ = (player2.Position - fam.Position)
				local goal_targ = (Vector(-1000,-1000) - fam.Position)
				
				if targ:Length() <= main_activation_radius then 
					local play_dat = GODMODE.get_ent_data(player2)
					play_dat.snail_shield = shield_check_time
					play_dat.snail_ref = fam

					if targ:Length() < goal_targ:Length() then 
						data.player_targ = player2 
					end
				end		
			end)
		end

		if data.player_targ and moving_animations[sprite:GetAnimation()] == true then 
			local targ = ((data.player_targ and data.player_targ.Position or fam.Position) - fam.Position)
			GODMODE.get_ent_data(data.player_targ).snail_shield = invuln_time 
			GODMODE.get_ent_data(data.player_targ).snail_ref = fam 

			if targ:Length() > activation_radius then 
				spd_mult = 0.33
			end

			if targ:Length() > min_distance then 
				fam.Velocity = fam.Velocity * 0.9 + targ:Resized(math.max(min_speed, math.min(max_speed, targ:Length() * target_pos_scalar))*spd_mult)
			end
			
			fam.FlipX = fam.Velocity.X < 0

			if targ:Length() <= fam.Size then 
				if data.player_targ then 
					data.player_targ:TakeDamage(2,DamageFlag.DAMAGE_INVINCIBLE,EntityRef(fam),1)
					GODMODE.save_manager.set_data("SnailHealth", 0)
				else 
					GODMODE.game:BombExplosionEffects(fam.Position, 2, TearFlags.TEAR_NORMAL, Color(0.8,0.9,1.0,1,0,0.05,0.1), nil, 0.66)
				end
			end
		else 
			fam.Velocity = fam.Velocity * 0.9
		end

		if fam:IsFrame(5,1) then 
			local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.PLAYER_CREEP_WHITE,0,fam.Position,Vector.Zero,fam)
			creep = creep:ToEffect()
			creep.Timeout = math.floor(7 + fam:GetDropRNG():RandomInt(5)) 
			creep.Scale = 0.65
			creep.CollisionDamage = 0.0
			creep:SetColor(Color(0.5,0.75,1,0.66,-0.1,-0.05,0),999,1,true,false)
			creep:Update()
		end

		if (data.snail_cooldown or 0) > 0 then 
			data.snail_cooldown = data.snail_cooldown - 1
		else data.snail_cooldown = nil end 

		if GODMODE.room then 
			local life = tonumber(GODMODE.save_manager.get_data("SnailHealth",monster.calc_max_health_for()))
			if GODMODE.room:IsClear() or life == 0 or data.player_targ == nil or (data.snail_cooldown or 0) > 0 then 
				fam.State = 0
			elseif life > 0 then 
				fam.State = 1 
			end
		end
    end
end

monster.calc_max_health_for = function()
	local base = GODMODE.util.total_item_count(GODMODE.registry.items.curse_of_the_snail)
	base = base * math.min(2,math.max(1,GODMODE.util.total_item_count(CollectibleType.COLLECTIBLE_BFFS)))
	return base 
end

monster.room_rewards = function(self,rng,pos)
	GODMODE.util.macro_on_enemies(nil, monster.type, monster.variant, 0, function(fly)
		fly = fly:ToFamiliar()
		fly.State = fly.State + 1

		if fly.State >= 2 then 
			fly.State = fly.State + math.max(math.min(1,fly:GetDropRNG():RandomInt(3)-1),0)

			if fly.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) or fly.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then 
				fly.State = fly.State + 1
			end
		end

		if fly:GetDropRNG():RandomFloat() < math.max(0,(fly.State-2) * 0.03) then 
			fly:Kill()
			Isaac.Spawn(GODMODE.registry.entities.fruit.type, GODMODE.registry.entities.fruit.variant, 0, fly.Position, RandomVector()*(fly:GetDropRNG():RandomFloat()+2), nil)
			fly.Player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
			fly.Player:EvaluateItems()
		end
	end)
end


return monster