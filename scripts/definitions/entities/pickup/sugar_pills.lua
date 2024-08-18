local monster = {}
monster.name = "Sugar Pill"
monster.type = EntityType.ENTITY_PICKUP
monster.variant = PickupVariant.PICKUP_PILL

local sparkle = {time=24,chance=0.5,ent=GODMODE.registry.entities.sugar_sparkle,}

monster.pickup_init = function(self, ent, data, sprite)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
		if GODMODE.achievements.is_achievement_unlocked("achievement_sugarpills") then 
			local sugar_drop_flag = false

			if ent.SpawnerEntity and ent.SpawnerEntity:ToPlayer() then 
				local player = ent.SpawnerEntity:ToPlayer()
				local sugar_uses = tonumber(GODMODE.save_manager.get_player_data(player,"SugarPillRolls","0"))

				if sugar_uses > 0 then 
					sugar_drop_flag = true
				end

				GODMODE.save_manager.set_player_data(player, "SugarPillRolls", math.max(sugar_uses - 1,0), true)
			end
	
			if sugar_drop_flag or ent.InitSeed % 100 < tonumber(GODMODE.save_manager.get_config("SugarPillChance","0.2")) * 100 then 
				GODMODE.save_manager.set_ent_data(ent,"SugarPill","true")
				sprite:ReplaceSpritesheet(0, "gfx/pickups/sugar_pills.png")
				sprite:LoadGraphics()
			end
		end	
	end
end

monster.pickup_update = function(self, ent, data, sprite)
	local sugar = GODMODE.save_manager.get_ent_data(ent,"SugarPill","false") == "true"
	data.sparkle_time = data.sparkle_time or sparkle.time 

	if sugar then 
		if ent:IsFrame(data.sparkle_time,ent.InitSeed % data.sparkle_time) then
			if ent:GetDropRNG():RandomFloat() < sparkle.chance then 
				local fx = Isaac.Spawn(sparkle.ent.type,sparkle.ent.variant,sparkle.ent.subtype or 0, ent.Position + Vector(1,0):Rotated(ent:GetDropRNG():RandomFloat()*360):Resized(ent:GetDropRNG():RandomFloat()*ent.Size), 
				Vector(1,0):Rotated(ent:GetDropRNG():RandomFloat()*360.0):Resized(0.2 + ent:GetDropRNG():RandomFloat() * 0.55), ent):ToEffect()

				fx:ClearEntityFlags(EntityFlag.FLAG_APPEAR)					
				data.sparkle_time = sparkle.time
			else
				data.sparkle_time = data.sparkle_time - 2
			end
		end
	end
end

-- on collide effect
monster.player_collide = function(self, player, ent2, entfirst)
	if ent2.Type == monster.type and ent2.Variant == monster.variant and GODMODE.save_manager.get_ent_data(ent2,"SugarPill","false") == "true" then 
		ent2 = ent2:ToPickup()

		if ent2.Touched ~= true then 
			local sugar_uses = tonumber(GODMODE.save_manager.get_player_data(player,"SugarPillRolls","0"))
			GODMODE.save_manager.set_player_data(player, "SugarPillRolls", sugar_uses + 1, true)
		end
	end
end

return monster