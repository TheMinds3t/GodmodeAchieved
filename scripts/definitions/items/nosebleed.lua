local item = {}
item.instance = Isaac.GetItemIdByName( "Nosebleed" )
item.eid_description = "Temporary x1.5 Damage boost that leaves after a few seconds each room"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Grants a 1.5x damage multiplier on entering a room, gradually fading over the course of 5 seconds."},
	},
}

item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end

	local data = GODMODE.get_ent_data(player)

	if cache == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + player.Damage * (((data.nosebleed_mult_level or 1) - 1) * (1 + (player:GetCollectibleNum(item.instance) - 1) * 0.25))
	end

	if cache == CacheFlag.CACHE_TEARCOLOR then
		local perc = ((data.nosebleed_mult_level or 1.5)-1.0)*2.0
		player.TearColor = Color.Lerp(player.TearColor, Color(0.8,0.1,0.1,1,0.25,0,0), perc)
	end
end
item.player_update = function(self,player)
	if player:HasCollectible(item.instance) then
		local data = GODMODE.get_ent_data(player)
		data.nosebleed_mult_level = math.max(1.0, (data.nosebleed_mult_level or 1.5) - (1 / 480.0))
		if data.nosebleed_mult_level > 1 then
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARCOLOR)
			player:EvaluateItems()
		end
	end
end

item.new_room = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player)
		local data = GODMODE.get_ent_data(player)
		data.nosebleed_mult_level = 1.5
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_TEARCOLOR)
		player:EvaluateItems()
	end)
end


return item