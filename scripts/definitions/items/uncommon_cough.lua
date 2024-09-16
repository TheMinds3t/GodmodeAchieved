local item = {}
item.instance = GODMODE.registry.items.uncommon_cough
item.eid_description = "Replaces tears with a spurt of tears#Spurts increase in quantity, speed and distance the longer you hold fire"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "Tears are replaced with spurts of blood, akin to Monstro's lung but weaker and not charged."},
      {str = "The longer you fire for, the blood spurt gains volume, speed and range until a cap after firing 3 times consecutively."},
    },
}

local function reformat_tears(player)
	GODMODE.get_ent_data(player).cough_tears = GODMODE.get_ent_data(player).cough_tears or {}
	local tears = GODMODE.get_ent_data(player).cough_tears
	local ret = {}
	for i,tear in ipairs(tears) do
		if tear ~= nil then
			if not tear:IsDead() and tear.StickTarget == nil then table.insert(ret, tear) end
		end
	end
	GODMODE.get_ent_data(player).cough_tears = ret
end

local function blood_spurt(player, pos, veloc, dmg_scale, count_mod)
	count_mod = count_mod or 0
	local data = GODMODE.get_ent_data(player)
	
	local mod_level = data.cough_mod_level or 0
	local csection_flag = player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) 

	if dmg_scale == nil then dmg_scale = 0.4 end
	data.cough_tears = data.cough_tears or {}

	if csection_flag then veloc = veloc * 0.33 end
	local count = math.max(1,(2 + math.floor(math.min(5, mod_level / 0.13 / 3)))*(player:GetCollectibleNum(item.instance))+count_mod)
	for i=0,count do
		local ter = player:FireTear(pos, 
			veloc:Rotated((1.0 + (player:GetCollectibleRNG(item.instance):RandomFloat() * 1.0-0.5) / 10.0) * (player:GetCollectibleRNG(item.instance):RandomFloat() * 20.0 - 10.0))
			 * (0.75 + player:GetCollectibleRNG(item.instance):RandomFloat() * 0.25), false, false, false)

		ter.Scale = ter.Scale * (0.5 + player:GetCollectibleRNG(item.instance):RandomFloat() * 0.3) * 1.25
		ter.CollisionDamage = player.Damage * ter.Scale * dmg_scale + math.max(count/25)
		ter.FallingAcceleration = (-2.0/60)-player:GetCollectibleRNG(item.instance):RandomFloat()*-1/60.0
		if i % 2 == 0 then ter.TearFlags = TearFlags.TEAR_NORMAL end

		if ter.Variant < 1 and not csection_flag then
			ter:ChangeVariant(1)
			ter:GetSprite():LoadGraphics()
		elseif csection_flag then 
			ter.TearFlags = ter.TearFlags | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_HOMING | TearFlags.TEAR_PIERCING
			ter:ChangeVariant(50)
			ter:GetSprite():LoadGraphics()
			ter.FallingAcceleration = (-5.5/60)
			ter.CollisionDamage = ter.CollisionDamage * 0.45
		else 
			ter.Height = ter.Height + (-0.5 + player:GetCollectibleRNG(item.instance):RandomFloat() * 0.5) * ter.Height * 0.05
			ter.Velocity = ter.Velocity * 1.1 + player:GetTearMovementInheritance(ter.Velocity) * 0.5
			ter:SetKnockbackMultiplier(0.15)
			table.insert(data.cough_tears, ter)
		end
	end
end

item.laser_init = function(self, laser)
	if laser.SpawnerEntity == nil then return end 
	local player = laser.SpawnerEntity:ToPlayer()
	if laser.Timeout < 5 and player ~= nil and laser.Variant ~= 1 and laser.Variant ~= 9 and player:HasCollectible(item.instance) and laser.Visible == false then 
		local data = GODMODE.get_ent_data(player)
		data.cough_disablerecursion = true
		blood_spurt(player,laser.Position,Vector(1,1):Rotated(laser.AngleDegrees-45):Resized(player.ShotSpeed*10)+player:GetTearMovementInheritance(player.Velocity),1,-2)
		data.cough_disablerecursion = false
		data.cough_mod_level = data.cough_mod_level + 0.25
		data.cough_mod_level = math.min(data.cough_mod_level, 1.3)
		player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_DAMAGE) 
		player:EvaluateItems()
	end
end

item.laser_update = function(self, laser)
	if laser.SpawnerEntity == nil then return end 
	local player = laser.SpawnerEntity:ToPlayer()

	if player ~= nil and player:HasCollectible(item.instance) and laser.Visible == true then 
		if laser.Variant == 1 or laser.Variant == 9 or laser.Variant == 2 and laser.SubType > 0 and laser.SubType < 3 then --brimstone
			local data = GODMODE.get_ent_data(player)

			if laser:IsFrame(2+math.min(1,laser.SubType)*5,1) then 
				data.cough_disablerecursion = true
				local angle = laser.AngleDegrees

				if laser.SubType > 0 then 
					angle = (laser.Position - player.Position):GetAngleDegrees()
				end

				blood_spurt(player,player.Position,Vector(1,1):Rotated(angle-45):Resized(player.ShotSpeed*20)+player:GetTearMovementInheritance(player.Velocity))
				data.cough_disablerecursion = false
				data.cough_mod_level = math.min(data.cough_mod_level, 1.3)
			end

			if laser.Timeout < 0 then 
				data.laser_firing = false
			else 
				data.laser_firing = true
			end 
		end
	end
end

item.knife_update = function(self, knife)
	if knife.SpawnerEntity == nil then return end 
	local player = knife.SpawnerEntity:ToPlayer()
	
	if not player or not player:HasCollectible(item.instance) then return end

	local ludo_flag = player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE)
	if player ~= nil and knife:IsFlying() or ludo_flag then 
		
		if knife:IsFrame(5,1) and not ludo_flag or knife:IsFrame(10,1) then 
			local data = GODMODE.get_ent_data(player)
			data.cough_disablerecursion = true
			blood_spurt(player,player.Position,Vector(1,1):Rotated((knife.Position - player.Position):GetAngleDegrees()-45):Resized(player.ShotSpeed*20)+player:GetTearMovementInheritance(player.Velocity))
			data.cough_disablerecursion = false
		end
	end
end

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	data.cough_mod_level = math.max(0,data.cough_mod_level or 0)
	
	if data.cough_firing == false then data.cough_mod_level = 0 end

	if cache == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed * (0.75 + math.min(0.5, data.cough_mod_level))
	end

	if cache == CacheFlag.CACHE_RANGE then
		player.TearRange = player.TearRange * (0.5 + math.min(0.5, data.cough_mod_level*1.3))
	end

	if cache == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage * (1.0 - math.min(0.8,0.25*player:GetCollectibleNum(item.instance)))
	end
end

item.player_update = function(self,player,data)
	if player:HasCollectible(item.instance) then
		local data = GODMODE.get_ent_data(player)
		if player:GetFireDirection() ~= Direction.NO_DIRECTION and data.laser_firing ~= true then
			if data.cough_firing == false then
				data.cough_firing = true
			end

			if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) or player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG) or player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
				data.cough_mod_level = data.cough_mod_level + 0.035
				data.cough_firing = true
			end

			if data.cough_firing then 
				player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_DAMAGE) 
				player:EvaluateItems()
			end
		elseif (data.laser_firing or false) == false then 
			data.cough_firing = false

			if (data.cough_mod_level or 0) > 0 then
				data.cough_mod_level = -0.13
				player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_DAMAGE) 
				player:EvaluateItems()
			end
		end

		data.cough_tears = data.cough_tears or {}
		for i=1,#data.cough_tears do
			local t = data.cough_tears[i]

			if t ~= nil then
				local amt = math.cos(math.rad(math.min(90,math.max(270,t.FrameCount * 10))))*5

				if t.FrameCount < 10 then 
					t.Height = t.Height - 3
				end

				if amt < 0 then 
					t.FallingSpeed = t.FallingSpeed + amt
					amt = amt / (player.TearRange/GODMODE.util.grid_size * 10)
					t.FallingAcceleration = 1.2
				else 
					amt = amt + (player.TearRange/GODMODE.util.grid_size / 10)
					t.FallingAcceleration = 0.75
				end

				t.Height = t.Height - amt
				--  if t.FrameCount < 12 then t.Height = t.Height - 5 else t.Height = t.Height + 1 end
				-- else
				-- 	t.FallingSpeed = t.FallingSpeed + 0.01 + 0.2 * player:GetCollectibleRNG(item.instance):RandomFloat()
				-- 	t.Height = t.Height + player:GetCollectibleRNG(item.instance):RandomFloat() * 2.5
				-- end

				if t:IsDead() or t.StickTarget ~= nil then reformat_tears(player) end
			end
		end
	end
end

item.tear_fire = function(self, tear)
	if tear.SpawnerEntity ~= nil and tear.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
		local player = tear.SpawnerEntity:ToPlayer()

		if player:HasCollectible(item.instance) then
			local data = GODMODE.get_ent_data(player)

			if data.celeste_fire ~= true then 
				if player:HasCollectible(CollectibleType.COLLECTIBLE_LACHRYPHAGY) then data.cough_firing = true return end
				if data.cough_disablerecursion == true then return end
				data.cough_disablerecursion = true
				local count = player:GetCollectibleNum(item.instance)

				blood_spurt(player, tear.Position, tear.Velocity)
				
				if not player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then 
					tear:Remove()
				end

				data.cough_disablerecursion = false
				data.cough_mod_level = data.cough_mod_level + 0.125
				data.cough_mod_level = math.min(data.cough_mod_level, 1.3)
				GODMODE.sfx:Play(GODMODE.registry.sounds.regular_cough,Options.SFXVolume * 1.8,1,false,1.0+player:GetCollectibleRNG(item.instance):RandomFloat()*0.125)
				player:AddCacheFlags(CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_DAMAGE) 
				player:EvaluateItems()
			end
		end
	end
end

return item