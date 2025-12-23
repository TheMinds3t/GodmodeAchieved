local item = {}
item.instance = GODMODE.registry.items.curse_of_the_snail
item.eid_description = "A snail familiar#↑ Takes all damage you take if inside its radius, up to 1 full heart per room#↓ Tries to hurt you while inside its radius, dealing 1 full heart once per room"
item.eid_transforms = nil
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Spawns a snail familiar that deals 1 full heart of contact damage to Isaac while awake, but does not chase Isaac unless he is inside its radius. If the snail deals damage to Isaac, the snail sleeps for the room."},
		{str = "While inside its radius, he will also receive all damage you would take up to 1 full heart of damage per room."},
		{str = "BFFs! will multiply the maximum damage per room by 2, and stacking this item will increase the maximum damage he can inflict/receive per room by 1/2 hearts per stack."},
	},
}

local invuln_time = 40
local shield_offset = Vector(0,-16)
local cached_max = -1
local main_activation_radius = 192
local snail_cd_time = 30

item.calc_max_health_for = function()
	if cached_max == -1 then 
		cached_max = GODMODE.util.total_item_count(item.instance) * 2
		cached_max = cached_max * math.min(2,math.max(1,GODMODE.util.total_item_count(CollectibleType.COLLECTIBLE_BFFS)))		
	end

	return cached_max 
end

item.eval_cache = function(self, player,cache,data)
	cached_max = -1
	if cache == CacheFlag.CACHE_FAMILIARS then 
		player:CheckFamiliar(GODMODE.registry.entities.cursed_snail.variant, 
			math.min(1,player:GetCollectibleNum(item.instance)+player:GetEffects():GetCollectibleEffectNum(item.instance)), 
			player:GetCollectibleRNG(item.instance), Isaac.GetItemConfig():GetCollectible(item.instance))
	end
end

item.create_laser = function(player,data,pos,pos2,fam)
	local ang = (pos2 - pos)
	local laser = EntityLaser.ShootAngle(LaserVariant.ELECTRIC,pos,ang:GetAngleDegrees(), data.snail_shield_invuln, Vector.Zero, player)
	laser.CollisionDamage = 0.0
	laser.EndPoint = pos2
	laser.MaxDistance = ang:Length()
	laser.Parent = fam
	laser.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	data.snail_lasers = data.snail_lasers or {}
	table.insert(data.snail_lasers, laser)
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit:ToPlayer() and item.calc_max_health_for() > 0 and 
		flags & DamageFlag.DAMAGE_NO_PENALTIES ~= DamageFlag.DAMAGE_NO_PENALTIES 
			and not (entsrc.Type == GODMODE.registry.entities.cursed_snail.type and entsrc.Variant == GODMODE.registry.entities.cursed_snail.variant) then
		local player = enthit:ToPlayer()
		
		if player then 
			local data = GODMODE.get_ent_data(player)
			local shield_left = tonumber(GODMODE.save_manager.get_data("SnailHealth", item.calc_max_health_for()))
			local deflect_flag = false 

			if (data.snail_shield_invuln or 0) > 0 then
				deflect_flag = true			
			elseif data.snail_ref and amount <= shield_left then 
				if (data.snail_shield or 0) > 0 or (data.snail_ref.Position - player.Position):Length() < main_activation_radius then 
					local shield = Isaac.Spawn(GODMODE.registry.entities.snail_shield.type,GODMODE.registry.entities.snail_shield.variant,GODMODE.registry.entities.snail_shield.subtype,enthit.Position+shield_offset,Vector.Zero,enthit)
					shield = shield:ToEffect()
					shield.Timeout = invuln_time
					shield.DepthOffset = 100
					shield:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
					GODMODE.get_ent_data(data.snail_ref).snail_cooldown = snail_cd_time

					GODMODE.save_manager.set_data("SnailHealth", math.max(0,shield_left - amount),true)
					data.snail_shield_invuln = invuln_time 
					deflect_flag = true 
					item.create_laser(player,data,player.Position,data.snail_ref.Position,data.snail_ref)

                	GODMODE.game:BombExplosionEffects(data.snail_ref.Position, 0, player.TearFlags, Color.Default, player)
				end
			end

			GODMODE.log("snail_shield="..tostring(data.snail_shield)..",snail_shield_invuln="..tostring(data.snail_shield_invuln)..",deflect="..tostring(deflect_flag)..",amount="..tostring(amount)..",snailhealth="..shield_left,false)
			if deflect_flag == true then 
				-- spawn fx

				if entsrc.Entity and data.snail_shield then 
					entsrc.Entity.Velocity = entsrc.Entity.Velocity + (entsrc.Position - enthit.Position)
					data.snail_shield = nil 
				end

				return false 
			end
		end
	end
end

item.player_update = function(self, player, data, sprite)
	-- just have to decrement the counters if they exist
	if data.snail_shield ~= nil then 
		data.snail_shield = data.snail_shield - 1 
		if data.snail_shield <= 0 then data.snail_shield = nil data.snail_ref = nil end 
	end
	
	if data.snail_shield_invuln ~= nil then 
		data.snail_shield_invuln = data.snail_shield_invuln - 1 
		if data.snail_shield_invuln <= 0 then data.snail_shield_invuln = nil end 
	end

	-- make the laser connect to the snail and the player
	if data.snail_lasers and #data.snail_lasers > 0 then 
		for ind=#data.snail_lasers,0,-1 do 
			if data.snail_lasers[ind] then 
				local laser = data.snail_lasers[ind]

				if laser.SpawnerEntity and laser.Parent then 
					local ang = (laser.SpawnerEntity.Position - laser.Parent.Position)
					laser.AngleDegrees = ang:GetAngleDegrees()
					laser.MaxDistance = ang:Length()
					laser.Position = laser.Parent.Position
				end

				if laser.Timeout <= 0 or laser:IsDead() then 
					table.remove(data.snail_lasers,ind)
				end
			end
		end
	else 
		data.snail_lasers = nil 
	end
end

-- move the snail away
item.new_room = function(self)
	GODMODE.util.macro_on_enemies(nil,GODMODE.registry.entities.cursed_snail.type,GODMODE.registry.entities.cursed_snail.variant,-1,function(snail) 
		local pos = GODMODE.room:FindFreePickupSpawnPosition(GODMODE.room:GetCenterPos())
		local valid, collide = GODMODE.room:CheckLine(Isaac.GetPlayer().Position, pos, 0)
		if not valid then pos = GODMODE.room:FindFreePickupSpawnPosition(collide) end
		snail.Position = pos
	end)
end

item.room_rewards = function(self,rng,pos)
	GODMODE.save_manager.set_data("SnailHealth", item.calc_max_health_for(), true)
end

return item