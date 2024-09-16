local transform = include("scripts.definitions.items.transformations.transform")
transform.instance = "Celeste"
transform.costume = GODMODE.registry.costumes.celeste
transform.eid_transform = GODMODE.util.eid_transforms.CELESTE
transform.cache_flags = CacheFlag.CACHE_SPEED | CacheFlag.CACHE_FLYING | CacheFlag.CACHE_TEARCOLOR
transform.custom_itemtag = "celeste"
transform.num_items = 2
local super_active = transform.is_transform_active
transform.is_transform_active = function(self, data, player)
	return Isaac.GetChallenge() == GODMODE.registry.challenges.the_galactic_approach or super_active(self, data, player)
end
transform.has_transform = function(player)
	return GODMODE.save_manager.get_player_data(player,transform.instance,"false") == "true" or Isaac.GetChallenge() == GODMODE.registry.challenges.the_galactic_approach
end

transform.items = {
	[GODMODE.registry.items.celestial_paw] = true,
	[GODMODE.registry.items.celestial_tail] = true,
	[GODMODE.registry.items.celestial_collar] = true,
	[GODMODE.registry.items.jack_of_all_trades] = true,
}

local star_color_unmodified = Color(0.8,0.8,0.2,1,0.25,0.25,0)
local star_color_2 = Color(0.8,0.8,0.1,1,0.5,0.5,0)

transform.eval_cache = function(self, player,cache,data)
	if GODMODE.save_manager.get_player_data(player,"Celeste","false") == "true" or Isaac.GetChallenge() == GODMODE.registry.challenges.the_galactic_approach then
		if cache == CacheFlag.CACHE_SPEED then
			player.MoveSpeed = player.MoveSpeed + 0.2
		end

		if cache == CacheFlag.CACHE_FLYING then
			player.CanFly = true
		end

		if cache == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = Color.Lerp(player.TearColor, Color(0.8,0.75,0.3,1,0.25,0.2,0), 0.7)
		end

		if player:HasPlayerForm(PlayerForm.PLAYERFORM_GUPPY) and not data.celeste_guppy_interaction then 
			player:TryRemoveNullCostume(GODMODE.registry.costumes.celeste)
			player:TryRemoveNullCostume(GODMODE.registry.costumes.celeste_guppy)
			player:AddNullCostume(GODMODE.registry.costumes.celeste_guppy)

			data.celeste_guppy_interaction = true
		end
	end
end

transform.first_level = function(self)
	GODMODE.util.macro_on_players(function(player)
		if Isaac.GetChallenge() == GODMODE.registry.challenges.the_galactic_approach then 
			for item,_ in pairs(transform.items) do 
				if item ~= GODMODE.registry.items.jack_of_all_trades then 
					player:AddCollectible(item)
				end
			end

			GODMODE.save_manager.set_player_data(player, "CelesteItems","3")
			GODMODE.save_manager.set_player_data(player, "Celeste","true")
			GODMODE.get_ent_data(player).transform_cooldown = GODMODE.get_ent_data(player).transform_cooldown or {}
			GODMODE.get_ent_data(player).transform_cooldown["Celeste"] = 10
		else
			GODMODE.save_manager.set_player_data(player, "CelesteItems","0")
			GODMODE.save_manager.set_player_data(player, "Celeste","false",true)
		end
	end)
end

transform.transform_update = function(self, player)
	local data = GODMODE.get_ent_data(player)
	local floor = 5

	if GODMODE.util.add_tears(player, player.MaxFireDelay,0.0) > 15 then 
		floor = 3
	end

	local frame = math.max(floor,math.floor(player.MaxFireDelay*1.1))
	if math.floor(data.real_time) % frame == 0 and Isaac.CountEnemies() + Isaac.CountBosses() > 0 then
		data.celeste_fire = true
		data.gehazi_keep_coin = true
		local tear = player:FireTear(player.Position+Vector(player:GetDropRNG():RandomInt(math.floor(player.Size*16))-player.Size*8,player:GetDropRNG():RandomInt(math.floor(player.Size*16))-player.Size*8),-player.Velocity:Resized(math.min(player.Velocity:Length(),1)) * math.max(0.1,player.ShotSpeed*0.5-0.4),false,true,false,player,1.0)
		data.gehazi_keep_coin = false
		data.celeste_fire = false
		
		tear:SetColor(star_color_unmodified,200,99,false,false)

		tear.FallingSpeed = 0.0
		tear.FallingAcceleration = -(4/60.0)
		tear.Height = -20
		tear.CollisionDamage = math.min(10,player.Damage * (0.2 + player:GetDropRNG():RandomFloat() * 0.05))
		tear.Scale = math.min(10.0,tear.CollisionDamage/3.5)
		--GODMODE.log("tear!",true)

		if player:GetDropRNG():RandomFloat() < 1.0 then--0.65 then
			tear:ChangeVariant(0)

			for _,flag in ipairs(TearFlags) do
				if flag ~= TearFlags.TEAR_NORMAL then
					tear:ClearTearFlags(flag)
				end
			end

			tear.TearFlags = TearFlags.TEAR_NORMAL | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_HOMING | TearFlags.TEAR_ORBIT
			tear:SetColor(star_color_2,200,99,false,false)
			tear:ResetSpriteScale()
			GODMODE.get_ent_data(tear).celeste_tear = true

			if tear.Variant == 50 then tear:ChangeVariant(0) end

			local size = math.max(1,math.min(13, math.floor(tear.Scale*6)))
			tear:GetSprite():Play("RegularTear"..size,true)
		end

		tear.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
		tear:AddTearFlags(TearFlags.TEAR_NORMAL | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_HOMING | TearFlags.TEAR_ORBIT)
	end
end

return transform