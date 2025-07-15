local item = {}
item.instance = GODMODE.registry.items.fallen_skull
item.eid_description = "↑Correction rooms guaranteed#↑Spawns Godmode trinket#↑Chance to spawn secret lights on room clear#↑General stat up based on how many Faithless/Broken Hearts#+6 Faithless Hearts"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - Correction Rooms are guaranteed to spawn with the same rules as Bone Feather"},
      {str = " - Spawns the Godmode trinket if no player has Godmode, and grants 6 Faithless Hearts to the player if he doesn't already have Godmode on first pickup."},
      {str = " - When clearing a room, an internal counter is incremented by 10%-30% randomly. Every time it increases, it attempts to succeed a roll with the current chance value. If the roll is successful, a Secret Light is added to the room clear rewards."},
      {str = " - +15% Damage, +1 Luck, +0.05 Speed per Faithless/Broken Heart."},
      {str = " - -1.25% Tears per Faithless/Broken Heart."},
      {str = " - 85% Speed Multiplier (stat down)."},
      {str = " - 85% Damage Multiplier (stat down)."},
      {str = " - The stat difference with Faithless/Broken hearts intensifies by 50% for each additional stack of Fallen Skull."},
    },
}

item.beam_sprite = Sprite()
item.beam_sprite:Load("godmode/gfx/effect_fallen_skull_beam.anm2",true)
item.beam_sprite:SetFrame("Idle", 1)

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	-- give faithless hearts per player
	if GODMODE.save_manager.get_player_data(player, "FallenSkullProc", "false") == "false" then 
		if player:GetTrinketMultiplier(GODMODE.registry.trinkets.godmode) == 0 then 
			GODMODE.util.add_faithless(player, 6)
		end

		GODMODE.save_manager.set_player_data(player, "FallenSkullProc", "true", true)
	end

	-- spawn Godmode once
	if GODMODE.save_manager.get_data("FallenSkullProcGlobal", "false") == "false" then 
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, GODMODE.registry.trinkets.godmode, GODMODE.room:FindFreePickupSpawnPosition(player.Position, 1, true), Vector.Zero, nil)
		GODMODE.save_manager.set_data("FallenSkullProcGlobal", "true")
	end

	local faithless = GODMODE.util.get_faithless(player)
	local broken = player:GetBrokenHearts()
	local col_num = player:GetCollectibleNum(item.instance)
	local fx_scale = (math.min(0.5,col_num) + 0.5 * col_num) * (faithless + broken * 1.5)

	if cache == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + fx_scale
	end

	if cache == CacheFlag.CACHE_DAMAGE then
		player.Damage = (player.Damage * 0.85) * (1 + fx_scale * 0.15)
	end

	if cache == CacheFlag.CACHE_SPEED then
		player.MoveSpeed = (player.MoveSpeed * 0.85) + fx_scale * 0.05
	end

	if cache == CacheFlag.CACHE_FIREDELAY then
		GODMODE.util.modify_stat(player, cache, 1 - fx_scale * 0.0125, true, false)
	end
end

item.post_godmode_restart = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player)
		player:AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
	end)
end

item.new_room = function(self)
	item.post_godmode_restart(self)
end

item.room_rewards = function(self, rng, pos)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player)
		local chance = tonumber(GODMODE.save_manager.get_player_data(player, "FallenSkullLightChance","0.0"))

		if player:GetCollectibleRNG(item.instance):RandomFloat() < chance then 
			GODMODE.save_manager.set_player_data(player, "FallenSkullLightChance", "0.0", true)
			Isaac.Spawn(GODMODE.registry.entities.secret_light.type, GODMODE.registry.entities.secret_light.variant, GODMODE.registry.entities.secret_light.subtype, player.Position, Vector.Zero, nil)
		else 
			GODMODE.save_manager.set_player_data(player, "FallenSkullLightChance", chance + (player:GetCollectibleRNG(item.instance):RandomInt(3) + 1) * 0.1, true)
		end
	end)
end

item.player_render = function(self,player,offset)
	if player:HasCollectible(item.instance) then 
		local radial_tick = math.rad(player.FrameCount * (360.0 / 60.0) + player.InitSeed % 360)
		local perc = tonumber(GODMODE.save_manager.get_player_data(player,"FallenSkullLightChance","0.0"))
		local opacity = math.min(1.0,0.75 + math.cos(radial_tick) * 0.25) * math.min(1,perc)

		item.beam_sprite.Color = Color(1,1,1,opacity)
		item.beam_sprite.Scale = Vector(1-perc*0.1,1+perc*2.5)
		item.beam_sprite:Render(Isaac.WorldToScreen(player.Position + Vector(0,-48)))
	end
end

return item