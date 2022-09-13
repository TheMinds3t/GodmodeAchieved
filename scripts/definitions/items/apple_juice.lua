local item = {}
item.instance = Isaac.GetItemIdByName( "Angry Apple Juice" )
item.eid_description = "↑ +Heals 1 half heart ↑ +20% Damage and +1.0 Damage for the room #↓ Short term pixelation effect every other second when used"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - Heals a half heart and +20% damage +1 damage for the room on use."},
      {str = " - When used, briefly pixellates the screen every few seconds for the duration of the room."},
    },
}


item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end

	local data = GODMODE.get_ent_data(player)

	data.apple_use_room = tonumber(GODMODE.save_manager.get_player_data(player, "AppleRoomSeed", "-1",false))
	if data.apple_use_room > 0 and data.apple_use_room == Game():GetRoom():GetDecorationSeed() and data.applied_apple ~= true then
		data.applied_apple = true
		-- player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		-- player:EvaluateItems()
	end

	if data.apple_use_room == Game():GetRoom():GetDecorationSeed() then
		if cache == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 1.2 + 1.0
		end
	end
end
item.player_update = function(self, player)
	if player and player:HasCollectible(item.instance) then
		local data = GODMODE.get_ent_data(player)

		if data.apple_use_room == Game():GetRoom():GetDecorationSeed() then
			local total = GODMODE.util.total_item_count(item.instance)
			if Game():GetFrameCount() % 120 == 0 and total > 0 then
				Game():AddPixelation(total * 25)
			end
		end
	end
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	local data = GODMODE.get_ent_data(player)
	if coll == item.instance then
		player:AddHearts(1)
		SFXManager():Play(SoundEffect.SOUND_VAMP_GULP)
		data.apple_use_room = Game():GetRoom():GetDecorationSeed()
		GODMODE.save_manager.set_player_data(player, "AppleRoomSeed", data.apple_use_room,true)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
		return true
	end
end
item.new_room = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
		GODMODE.get_ent_data(player).apple_use_room = nil
		GODMODE.get_ent_data(player).applied_apple = nil
		GODMODE.save_manager.set_player_data(player, "AppleRoomSeed", "-1",true)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end)
end

return item