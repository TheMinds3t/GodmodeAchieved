local monster = {}
monster.name = "Chest Infestor"
monster.type = GODMODE.registry.entities.chest_mimic.type
monster.variant = GODMODE.registry.entities.chest_mimic.variant

local base_offset = Vector(0,0)
local base_eye_offset = Vector(0,8)
monster.attach_chest = function(self, ent, data, sprite, radius)
	radius = radius or 512
	local closest = nil
	GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_PICKUP,nil,nil,function(pickup) 
		if GODMODE.registry.mimic_chests[pickup.Variant] and (closest == nil or (closest.Position-ent.Position):Length() > (pickup.Position-ent.Position):Length())
			and GODMODE.get_ent_data(pickup).chest_infest_chose ~= true then 
			closest = pickup
		end
	end)

	data.chest = closest 
	return not data.chest_locked and data.chest ~= nil
end

monster.data_init = function(self, ent, data, sprite)
	data.fire_bullet = function(self,ent,ang,spd,scale,flags)
        local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position,Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
        tear = tear:ToProjectile()
        tear.Height = -35
        tear.FallingSpeed = 1
        tear.FallingAccel = -(4.5/60.0)
        tear.Scale = scale
		if flags ~= nil then 
			tear.ProjectileFlags = tear.ProjectileFlags | flags
		end

		-- GODMODE.sfx:Play(SoundEffect.SOUND_WEIRD_WORM_SPIT,Options.SFXVolume*1.0+0.75)
	end

	data.launch_bullet = function(self,ent,pos,scale,flags)
		local params = ProjectileParams()
		params.Scale = scale
		params.HeightModifier = -25
		params.FallingSpeedModifier = -(1/20.0)

		if flags ~= nil then 
			params.BulletFlags = params.BulletFlags | flags
		end

		return ent:ToNPC():FireBossProjectiles(1,pos,1.0,params)
	end

	data.launch_ring = function(self,ent,count,spd,ang_offset,scale,flags)
		local ring_size = count or 12
		local angle = 360 / ring_size
		local size = spd or 16.0

		for i=1,ring_size do
			local ang = math.rad(angle * i + (ang_offset or 0))
			local pos = ent.Position + Vector(math.cos(ang)*size,math.sin(ang)*size)
			self:launch_bullet(ent,pos,scale,flags)
		end
	end


	data.fire_ring = function(self,ent,count,spd,ang_offset,scale,flags)
		local ring_size = count or 12
		local angle = 360 / ring_size

		for i=1,ring_size do
			local ang = math.rad(angle * i + (ang_offset or 0))
			self:fire_bullet(ent,ang,spd,scale,flags)
		end
	end
end

monster.npc_update = function(self, ent, data, sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local player = ent:GetPlayerTarget()

	if sprite:IsFinished("Appear") or sprite:IsFinished("WalkSmall") then 
		sprite:Play("WalkSmall",true)
		ent.CollisionDamage = 0
		ent.DepthOffset = -20

		if monster.attach_chest(self,ent,data,sprite) then 
			if (data.chest.Position - ent.Position):Length() < ent.Size then 
				data.chest_locked = true
				sprite:Play("Manifest",true)

				GODMODE.get_ent_data(data.chest).chest_infest_chose = true
				GODMODE.get_ent_data(data.chest).chest_infest = ent
				GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,nil,nil,function(mimic)
					local mim_dat = GODMODE.get_ent_data(mimic)

					if GetPtrHash(mimic) ~= GetPtrHash(ent) and mim_dat and mim_dat.chest ~= nil and GetPtrHash(mim_dat.chest) == GetPtrHash(data.chest) then 
						mim_dat.chest = nil
					end
				end)
			end
		end
	end

	if not sprite:IsPlaying("Attack") and not sprite:IsPlaying("Walk") and not sprite:IsPlaying("Manifest") and data.chest_locked == true then
		if sprite:GetAnimation() == "Manifest" then --transformation from slug form to spider form
			ent.CollisionDamage = 1
			ent.MaxHitPoints = ent.MaxHitPoints * 2
			ent.HitPoints = ent.HitPoints * 2
			ent.DepthOffset = 0
			ent.Mass = ent.Mass * 4
			ent.Size = ent.Size * 1.25
		end

		sprite:Play("Walk", true)
	end

	-- tie chest to null frame
	if data.chest_locked == true and data.chest ~= nil then 
		if not GODMODE.registry.mimic_chests[data.chest.Variant] then 
			-- detach in case of morph
			if data.chest then 
				GODMODE.get_ent_data(data.chest).chest_infest_chose = nil
				GODMODE.get_ent_data(data.chest).chest_infest = nil	
			end

			data.chest = nil 
			data.chest_locked = false 
		else
			if GODMODE.registry.mimic_chests[data.chest.Variant].atk_update then 
				GODMODE.registry.mimic_chests[data.chest.Variant].atk_update(ent,data,sprite)
			end
			
			local chest_nf = sprite:GetNullFrame("chest")
			data.chest:GetSprite().Scale = chest_nf:GetScale()
			data.chest:GetSprite().Color = chest_nf:GetColor()
			data.chest.SpriteOffset = chest_nf:GetPos() + GODMODE.registry.mimic_chests[data.chest.Variant].null_pos_off + base_offset
			data.chest.Velocity = data.chest.Velocity * 0.1 + ent.Position - data.chest.Position
			data.chest.Position = ent.Position
			data.chest.DepthOffset = 10
		end
	end
	
	if not sprite:IsPlaying("Attack") and not sprite:IsPlaying("Manifest") then
		if ent:IsFrame(60,ent.InitSeed % 60) and ent:GetDropRNG():RandomFloat() < 0.75 and data.chest_locked == true then
			sprite:Play("Attack", true)
		end

		local move_mod = sprite:IsPlaying("WalkSmall") and 0.3 or 0.6
		local pathfinding = GODMODE.util.ground_ai_movement(ent,(data.chest ~= nil and data.chest_locked ~= true and data.chest or player),0.6 * move_mod,true)

        if pathfinding ~= nil then 
            ent.Velocity = ent.Velocity * (0.96 - (sprite:IsPlaying("WalkSmall") and 0.08 or 0)) + pathfinding
        elseif player ~= nil then 
            ent.Pathfinder:FindGridPath((data.chest ~= nil and data.chest_locked ~= true and data.chest.Position or player.Position),0.5 * move_mod,0,true)
        end

		--ent.Pathfinder:MoveRandomly(false)
	else
		if sprite:IsFinished("Attack") or sprite:IsFinished("Manifest") then
			sprite:Play("Walk", true)
		end

		ent.Velocity = ent.Velocity * 0.6
	end

	if sprite:IsEventTriggered("Attack") then
		local atk_data = GODMODE.registry.mimic_chests[data.chest.Variant] or GODMODE.registry.mimic_chests[PickupVariant.PICKUP_CHEST]
		if atk_data then 
			if atk_data.attack then 
				atk_data.attack(ent,data,sprite)
			end

			-- unlock chest if specified
			if atk_data.unlock == true then 
				data.chest:ToPickup():TryOpenChest()
			end
		end
	end

	if sprite:IsEventTriggered("PreAttack") and data.chest and data.chest_locked == true then 
		local dat = GODMODE.registry.mimic_chests[data.chest.Variant] or GODMODE.registry.mimic_chests[PickupVariant.PICKUP_CHEST]
		if dat and dat.preattack then 
			dat.preattack(ent,data,sprite)
		end
	end

	if sprite:IsEventTriggered("Explode") then
		GODMODE.game:ShakeScreen(5)
		GODMODE.game:BombExplosionEffects(ent.Position,10.0,0,Color(1,1,1,1,0,0,0),ent,1.0,false,true)
	end
end

monster.npc_kill = function(self,ent)
	local dat = GODMODE.get_ent_data(ent)

	if dat and dat.chest then 
		local mimic_dat = GODMODE.registry.mimic_chests[dat.chest.Variant]
		
		if mimic_dat and mimic_dat.death_unlock == true and dat.chest:ToPickup() and dat.chest:GetSprite():GetAnimation():match("Open") == nil then 
			mimic_dat.attack(ent,dat,ent:GetSprite())
			dat.chest:ToPickup():TryOpenChest()
		end

		GODMODE.get_ent_data(dat.chest).chest_infest_chose = nil
		GODMODE.get_ent_data(dat.chest).chest_infest = nil
	end
end

monster.pickup_post_render = function(self, pickup, offset)
	if GODMODE.validate_rgon() and pickup.Type == EntityType.ENTITY_PICKUP and GODMODE.registry.mimic_chests[pickup.Variant] and pickup:GetSprite():GetAnimation():match("Open") ~= nil then --needs null position
		local ent = GODMODE.get_ent_data(pickup).chest_infest
		local data = GODMODE.get_ent_data(ent)

		if ent and data and data.chest_locked == true and GetPtrHash(data.chest) == GetPtrHash(pickup) then 
			if monster.eye_sprite == nil then
				monster.eye_sprite = Sprite()
				monster.eye_sprite:Load("gfx/50_chest_mimic.anm2",true)
			end
		
			local chest_nf = ent:GetSprite():GetNullFrame("chest")
			monster.eye_sprite.Scale = chest_nf:GetScale()
			monster.eye_sprite.Color = ent:GetSprite().Color
			monster.eye_sprite.Offset = (GODMODE.registry.mimic_chests[pickup.Variant].eye_pos_off or Vector.Zero)
			-- local pos = pickup.Position + base_eye_offset + (GODMODE.registry.mimic_chests[pickup.Variant].eye_pos_off or Vector.Zero)
		
			monster.eye_sprite:SetFrame("Eye"..ent:GetSprite():GetAnimation(),ent:GetSprite():GetFrame())
			monster.eye_sprite:Render(Isaac.WorldToScreen(pickup.Position) + data.chest.SpriteOffset,Vector.Zero,Vector.Zero)	
		end	
	end
end

monster.pickup_init = function(self,pickup)
	local mimic_dat = GODMODE.registry.mimic_chests[pickup.Variant]
    if GODMODE.save_manager.get_config("ChestInfestToggle","true") == "true" 
		and mimic_dat and (mimic_dat.can_spawn == nil or mimic_dat.can_spawn(pickup) == true)
		and pickup:GetDropRNG():RandomFloat() < tonumber(GODMODE.save_manager.get_config("ChestInfestChance","30.0"))/100.0 and GODMODE.achievements.is_achievement_unlocked("achievement_chest_infest") then 
        
		local infestor = Isaac.Spawn(monster.type,monster.variant,0,GODMODE.room:FindFreeTilePosition(GODMODE.room:GetRandomPosition(64.0),512.0), Vector.Zero,nil)
		-- infestor:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end

monster.bypass_hooks = {["pickup_init"] = true, ["pickup_post_render"] = true}

monster.npc_post_render = function(self, ent, offset)
	if GODMODE.validate_rgon() then --needs null position
		local data = GODMODE.get_ent_data(ent)

		if data and data.chest_locked == true and data.chest ~= nil then 
			if monster.eye_sprite == nil then
				monster.eye_sprite = Sprite()
				monster.eye_sprite:Load("gfx/50_chest_mimic.anm2",true)
			end
		
			local chest_nf = ent:GetSprite():GetNullFrame("chest")
			monster.eye_sprite.Scale = chest_nf:GetScale()
			monster.eye_sprite.Color = chest_nf:GetColor()
			monster.eye_sprite.Offset = chest_nf:GetPos() + base_offset + (GODMODE.registry.mimic_chests[data.chest.Variant].null_pos_off or Vector.Zero)
			local pos = ent.Position + base_eye_offset + (GODMODE.registry.mimic_chests[data.chest.Variant].eye_pos_off or Vector.Zero)
		
			monster.eye_sprite:SetFrame("Eye"..ent:GetSprite():GetAnimation(),ent:GetSprite():GetFrame())
			monster.eye_sprite:Render(Isaac.WorldToScreen(pos),Vector.Zero,Vector.Zero)	
		end	
	end
end

return monster