local item = {}
item.bomb_size = 1
item.bomb_damage = 100
item.attack = 0
item.tears = 0
item.eid_description = "Explodes the current room after taking damage#Gives damage and firerate when cracked or bloodied#↓ Gets destroyed after taking damage 3 times from the boss fight"
item.instance = GODMODE.registry.items.vessel_of_purity_1

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay, item.tears*player:GetCollectibleNum(item.instance))
	end

	if cache == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + item.attack
	end
end


item.player_update = function(self,player,data)
	if player:HasCollectible(item.instance) then
		data.vessel_cooldown = (data.vessel_cooldown or 30) - 1
	end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	local entflag = GODMODE.is_at_palace and GODMODE.is_at_palace() and (GODMODE.room_type or GODMODE.room:GetType()) == RoomType.ROOM_BOSS and not entsrc.IsFriendly
	
	GODMODE.util.macro_on_players_that_have(item.instance, function(player)
		local data = GODMODE.get_ent_data(player)
		local t_sign_flag = player:GetPlayerType() == GODMODE.registry.players.t_sign and flags & DamageFlag.DAMAGE_NO_PENALTIES ~= DamageFlag.DAMAGE_NO_PENALTIES
		if GetPtrHash(player) == GetPtrHash(enthit) and (data.vessel_cooldown == nil or data.vessel_cooldown <= 0) and (entflag or t_sign_flag) then
			data.vessel_cooldown = 30
			GODMODE.game:BombExplosionEffects(player.Position, 100, TearFlags.TEAR_NORMAL, Color.Default, player, 1)
			-- GODMODE.game:ShakeScreen(20)
			player:RemoveCollectible(item.instance)

			if t_sign_flag then 
				player:AddBrokenHearts(2)
				GODMODE.util.add_faithless(player, 2)
			end

			if item.next_instance then
				player:AddCollectible(item.next_instance,0,false)
			end
			GODMODE.game:ShakeScreen(20)
			return false
		end
	end)
end

return item