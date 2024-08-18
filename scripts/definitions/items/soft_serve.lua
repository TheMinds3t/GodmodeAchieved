local item = {}
item.instance = GODMODE.registry.items.soft_serve
item.eid_description = "↑ +1 Soul Heart#↑ +2 Soul Hearts if full or empty red health#↑ Chance to spawn colored creep with unique effects when firing"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Grants +1 soul heart, and an additional +2 soul hearts if the player's red hearts are either full or empty."},
		{str = "Has a 10% chance, or 50% chance at 13.3 luck, to spawn a random colored creep trail from a tear fired. The creep's base tick damage is 0.5x player damage + 1.0 damage."},
		{str = "The effects are:"},
		{str = "- White: slows enemies, allowing them to be frozen if killed."},
		{str = "- Pink: homes in on enemies"},
		{str = "- Red: bounces against walls, moves faster than other colors"},
		{str = "- Light brown: enemies that stand on this will occasionally create linger beans"},
		{str = "- Dark brown: larger, smaller radius but deals more damage"},
	},
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

    data.num_soft_serves = tonumber(GODMODE.save_manager.get_player_data(player, "NumSoftServes", "0"))

    if data.num_soft_serves < player:GetCollectibleNum(item.instance) then
		data.num_soft_serves = (data.num_soft_serves or 0) + 1

		if player:GetHearts() >= player:GetMaxHearts() - player:GetRottenHearts() or player:GetHearts() == 0 then 
			player:AddSoulHearts(4)
		end

        GODMODE.save_manager.set_player_data(player, "NumSoftServes", data.num_soft_serves,true)
	end
end

item.player_update = function(self,player,data)
	if player:HasCollectible(item.instance) then 

		data.soft_serve_cooldown = math.max(0,(data.soft_serve_cooldown or 0) - 1)
	end
end

item.tear_init = function(self, tear)
	if tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer() and tear.SpawnerEntity:ToPlayer():HasCollectible(item.instance) then
		local player = tear.SpawnerEntity:ToPlayer()
		local player_data = GODMODE.get_ent_data(player)

		if (player_data.soft_serve_cooldown or 0) == 0 then 
			if player:GetCollectibleRNG(item.instance):RandomFloat() < math.min(0.5,0.1+player.Luck*0.03) then
				local puddle = Isaac.Spawn(GODMODE.registry.entities.soft_serve.type,GODMODE.registry.entities.soft_serve.variant,0,player.Position,player.Velocity*0.8,player)
				puddle.CollisionDamage = player.Damage * 0.5 + 1
				local data = GODMODE.get_ent_data(puddle)
				data.color = player:GetCollectibleRNG(item.instance):RandomInt(5)+1
				data.velocity = (tear.Velocity + player:GetTearMovementInheritance(player.Velocity)*0.25):Resized(6)
				player_data.soft_serve_cooldown = 30
			end
		end
	end
end


return item