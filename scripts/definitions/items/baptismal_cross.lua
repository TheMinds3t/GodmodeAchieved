local item = {}
item.instance = Isaac.GetItemIdByName( "Baptismal Cross" )
item.eid_description = "Spawn many tears from above the player, dealing 0.5-1.5x current damage per tear"
item.eid_transforms = GODMODE.util.eid_transforms.ANGEL
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "On use, for one second, spawns a large barrage of tears from above the player each dealing between 0.5 to 1.5 times your damage."},
    },
}

item.player_update = function(self, player)
	if player:HasCollectible(item.instance) then
		local data = GODMODE.get_ent_data(player)
		data.baptismal_time = data.baptismal_time or {}
		for i=1, #data.baptismal_time do
			local time = data.baptismal_time[i]
			if time then
				if time.time > 0 then
					time.time = time.time - 1
					local player = time.player
					for i=1,2 do
						local ang = math.rad(time.rng:RandomFloat() * 180 + i * (360/2))
						local t = Game():Spawn(EntityType.ENTITY_TEAR,0,player.Position,Vector(math.cos(ang)*(player:GetCollectibleRNG(item.instance):RandomFloat() * 10),math.sin(ang)*(player:GetCollectibleRNG(item.instance):RandomFloat() * 10)),player,0,player.InitSeed)
						t = t:ToTear()
						t.Height = -384 - time.rng:RandomFloat() * 256.0
						t.FallingSpeed = 24.0 + time.rng:RandomFloat() * 16.0
						t.FallingAcceleration = 1.125 + time.rng:RandomFloat() * 0.25
						t.CollisionDamage = player.Damage * (time.rng:RandomFloat() + 0.5) * 2
						t.Scale = 0.75 + t.CollisionDamage / 10.0 + time.rng:RandomFloat()
					end
				else
					table.remove(data.baptismal_time, i)
				end
			end
		end		
	end
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
		local data = GODMODE.get_ent_data(player)
		data.baptismal_time = data.baptismal_time or {}
		table.insert(data.baptismal_time, {player=player, rng=rng, time=60})
		return true
	end
end

return item