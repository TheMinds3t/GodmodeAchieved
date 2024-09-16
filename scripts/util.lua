local util = {}

-- Create a copy of the list so it can be loaded w/o EID for item scripts
util.eid_transforms = {
	["GUPPY"] = 1,
	["LORD_OF_THE_FLIES"] = 3,
	["MUSHROOM"] = 2,
	["ANGEL"] = 10,
	["BOB"] = 8,
	["SPUN"] = 5,
	["MOM"] = 6,
	["CONJOINED"] = 4,
	["LEVIATHAN"] = 9,
	["POOP"] = 7,
	["BOOKWORM"] = 12,
	["ADULT"] = 14,
	["SPIDERBABY"] = 13,
	["SUPERBUM"] = 11,
	["CELESTE"] = "godmodeAchCeleste",
	["CYBORG"] = "godmodeAchCyborg",
	["CULTIST"] = "godmodeAchCultist",
	["JACK_OF_ALL_TRADES"] = "godmodeAchJackIcon", --unique icon rather than all icons
}

util.grid_size = 40.0

-- For stageapi
util.base_room_door = {
    RequireCurrent = {RoomType.ROOM_DEFAULT, RoomType.ROOM_MINIBOSS, RoomType.ROOM_SACRIFICE, RoomType.ROOM_BARREN, RoomType.ROOM_ISAACS, RoomType.ROOM_DICE, RoomType.ROOM_CHEST},
    RequireTarget = {RoomType.ROOM_DEFAULT, RoomType.ROOM_MINIBOSS, RoomType.ROOM_SACRIFICE, RoomType.ROOM_BARREN, RoomType.ROOM_ISAACS, RoomType.ROOM_DICE, RoomType.ROOM_CHEST}
}

util.wrap_angle = function(angle, degrees)
	degrees = degrees or true
	if degrees then angle = angle / 180 * math.pi end

	if angle < 0 then return math.abs(angle) else
		return (math.pi - angle) + math.pi
	end
end

util.get_basic_dps = function(ent)
	if ent == nil or ent.GetPlayerTarget == nil then ent = Isaac.GetPlayer() end
    local player = ent:ToPlayer() or ent:GetPlayerTarget()
	if player == nil then player = Isaac.GetPlayer() end

	if player:ToPlayer() then
		player = player:ToPlayer()
	    local freq = player.MaxFireDelay
    	local dmg = player.Damage
		return dmg * 30 / (freq + 1)
    end

	return 0
end

util.tearflag_mods = {
	[TearFlags.TEAR_SPECTRAL] = 0.3,
	[TearFlags.TEAR_PIERCING] = 0.4,
	[TearFlags.TEAR_HOMING] = 0.5,
	[TearFlags.TEAR_SLOW] = 0.1,
	[TearFlags.TEAR_POISON] = 0.1,
	[TearFlags.TEAR_FREEZE] = 0.1,
	[TearFlags.TEAR_SPLIT] = 0.3,
	[TearFlags.TEAR_GROW] = 0.1,
	[TearFlags.TEAR_PERSISTENT] = 0.25,
	[TearFlags.TEAR_MULLIGAN] = 0.4,
	[TearFlags.TEAR_EXPLOSIVE] = 0.3,
	[TearFlags.TEAR_CHARM] = 0.25,
	[TearFlags.TEAR_CONFUSION] = 0.25,
	[TearFlags.TEAR_QUADSPLIT] = 0.4,
	[TearFlags.TEAR_BOUNCE] = 0.25,
	[TearFlags.TEAR_FEAR] = 0.1,
	[TearFlags.TEAR_SHRINK] = 0.3,
	[TearFlags.TEAR_BURN] = 0.1,
	[TearFlags.TEAR_GLOW] = 0.45,
	[TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP] = 0.2,
	[TearFlags.TEAR_SHIELDED] = 0.5,
	[TearFlags.TEAR_STICKY] = 0.25,
	[TearFlags.TEAR_CONTINUUM] = 0.2,
	[TearFlags.TEAR_LIGHT_FROM_HEAVEN] = 0.5,
	[TearFlags.TEAR_GODS_FLESH] = 0.15,
	[TearFlags.TEAR_GREED_COIN] = 0.1,
	[TearFlags.TEAR_PERMANENT_CONFUSION] = 0.4,
	[TearFlags.TEAR_BOOGER] = 0.3,
	[TearFlags.TEAR_EGG] = 0.4,
	[TearFlags.TEAR_ACID] = 0.1,
	[TearFlags.TEAR_BONE] = 0.3,
	[TearFlags.TEAR_BELIAL] = 0.5,
	[TearFlags.TEAR_JACOBS] = 0.35,
	[TearFlags.TEAR_HORN] = 0.45,
	[TearFlags.TEAR_LASERSHOT] = 0.2,
	[TearFlags.TEAR_HYDROBOUNCE] = 0.2,
	[TearFlags.TEAR_BURSTSPLIT] = 0.35,
	[TearFlags.TEAR_PUNCH] = 0.25,
	[TearFlags.TEAR_ICE] = 0.5,
	[TearFlags.TEAR_BAIT] = 0.2,
	[TearFlags.TEAR_OCCULT] = 0.2,
	[TearFlags.TEAR_ROCK] = 0.25,
	[TearFlags.TEAR_RIFT] = 0.3,
	[TearFlags.TEAR_SPORE] = 0.25,
}

util.transform_mods = {
	[PlayerForm.PLAYERFORM_GUPPY] = 2.5,
	[PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES] = 2.0,
	[PlayerForm.PLAYERFORM_MUSHROOM] = 0.1,
	[PlayerForm.PLAYERFORM_ANGEL] = 0.75,
	[PlayerForm.PLAYERFORM_BOB] = 0.2,
	[PlayerForm.PLAYERFORM_DRUGS] = 1,
	[PlayerForm.PLAYERFORM_MOM] = 0.5,
	[PlayerForm.PLAYERFORM_BABY] = 1.5,
	[PlayerForm.PLAYERFORM_EVIL_ANGEL] = 0.85,
	[PlayerForm.PLAYERFORM_POOP] = 0.5,
	[PlayerForm.PLAYERFORM_BOOK_WORM] = 0.2,
	[PlayerForm.PLAYERFORM_ADULTHOOD] = 0.1,
	[PlayerForm.PLAYERFORM_SPIDERBABY] = 0.15,
	[PlayerForm.PLAYERFORM_STOMPY] = 0.25,
	[GODMODE.registry.transformations.celeste] = 2.5,
	[GODMODE.registry.transformations.cyborg] = 0.75,
	[GODMODE.registry.transformations.cultist] = 0.25,
}

util.stat_dist = {
	["damage"] = 20,
	["firerate"] = 10,
	["luck"] = 10,
	["range"] = 4,
	["shotspeed"] = 3,
	["speed"] = 5,
	["health"] = 9,
	["tearflags"] = 12,
	["transformation"] = 12,
	["quality"] = 15,
}

util.stat_buff = {
	["damage"] = true,
	["firerate"] = true,
	["luck"] = true,
	["range"] = true,
	["shotspeed"] = true,
	["speed"] = true,
	["health"] = true,
	["tearflags"] = false,
	["transformation"] = false,
	["quality"] = false,
}

util.stat_scale = {
	["damage"] = function(player) 
		return math.min(util.stat_dist["damage"],player.Damage) end,
	["firerate"] = function(player) 
		local cur = 30 / (player.MaxFireDelay + 1)
		local max = util.get_max_tears(player)

		return math.min(util.stat_dist["firerate"],cur/max*util.stat_dist["firerate"]) end,
	["luck"] = function(player) 
		return math.min(util.stat_dist["luck"],player.Luck/1.25) end,
	["range"] = function(player) 
		return math.min(util.stat_dist["range"],player.TearRange/util.grid_size/2) end,
	["shotspeed"] = function(player) 
		return math.min(util.stat_dist["shotspeed"],player.ShotSpeed/2.0*util.stat_dist["shotspeed"]) end,
	["speed"] = function(player) 
		return math.min(util.stat_dist["speed"],player.MoveSpeed/2.0*util.stat_dist["speed"]) end,
	["health"] = function(player) 
		return math.min(util.stat_dist["health"], (player:GetMaxHearts() * (player:GetHearts()/player:GetMaxHearts())
			 + player:GetSoulHearts() + player:GetEternalHearts() + player:GetBoneHearts())/(player:GetHeartLimit()-player:GetBrokenHearts())*util.stat_dist["health"]) end,
	["tearflags"] = function(player)
		local total = 0
		for flag,amt in pairs(util.tearflag_mods) do 
			if type(amt) == "function" then 
				total = total + amt(player) or 0
			elseif player.TearFlags & flag == flag then
				total = total + amt
			end
		end
		return math.min(util.stat_dist["tearflags"],total*8) end,
	["transformation"] = function(player)
		local total = 0
		for form,amt in pairs(util.transform_mods) do 
			if type(amt) == "function" then 
				total = total + amt(player) or 0
			elseif type(form) == "string" and GODMODE.save_manager.get_player_data(player, form,"false") == "true"
				or type(form) == "number" and player:HasPlayerForm(form) then 
				total = total + amt
			end
		end
		return math.min(util.stat_dist["transformation"],total*5) end, --total used to be 4, now is 12
	["quality"] = function(player) 
		local items = GODMODE.save_manager.get_player_list_data(player, "ItemsCollected", false, function(ent) return tonumber(ent) end)
		local total_quality = 0
		local total_items = 0

		for item in ipairs(items) do 
			local config = Isaac.GetItemConfig():GetCollectible(item)

			if config and config:IsCollectible() then 
				total_quality = total_quality + config.Quality
				total_items = total_items + 1
			end
		end

		if total_items == 0 then return 0 else 
			return (total_quality / total_items) / 4.0 * util.stat_dist["quality"]
		end
	end
}

util.get_stat_perc = function(player, cache)
	return util.stat_scale[cache](player)
end

util.get_stat_score = function(player)
	local low_to_hi = {}
	local breakdown = {}
	local stat_score = 0 
	local concat = ""
	for stat,perc in pairs(util.stat_scale) do 
		if util.stat_buff[stat] then 
			table.insert(low_to_hi,stat)
		end

		breakdown[stat] = perc(player)
		stat_score = stat_score + perc(player)
		concat = concat.." ("..stat.."="..perc(player).."),"
	end

	table.sort(low_to_hi, function (a, b)
		return util.stat_scale[a](player) < util.stat_scale[b](player)
	end)
	-- GODMODE.log("Stat score for player "..player.ControllerIndex.." is "..stat_score.. "{\n\t"..concat.."\n}",true)
	return {order=low_to_hi,score=stat_score,breakdown=breakdown}
end

util.get_stat_scale = function()
	return tonumber(GODMODE.save_manager.get_config("StatHelpScale","0.8")) * util.get_health_scale(nil,1)
end

util.get_max_stat_score = function()
	local ret = 0

	for _,total in pairs(util.stat_dist) do 
		ret = ret + total
	end

	return ret 
end

local color_map = {
	[SkinColor.SKIN_PINK] = "",
	[SkinColor.SKIN_WHITE] = "_white",
	[SkinColor.SKIN_BLACK] = "_black",
	[SkinColor.SKIN_BLUE] = "_blue",
	[SkinColor.SKIN_RED] = "_red",
	[SkinColor.SKIN_GREEN] = "_green",
	[SkinColor.SKIN_GREY] = "_grey",
	[SkinColor.SKIN_SHADOW] = "_shadow",
}
util.get_color_suffix = function(color)
    return color_map[color]
end

util.get_num_players = function()
	local ret = 0
	local found = {}

	for i=1,GODMODE.game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i-1)
		if player and found[player.ControllerIndex] ~= true then 
			ret = ret + 1 
			found[player.ControllerIndex] = true
		end
	end

	return ret
end

util.does_player_have = function(item, is_trinket, check_sub)
	local ret = {}
	for i=1,GODMODE.game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i-1)
		if player and not is_trinket and (player:HasCollectible(item) or check_sub == true and player:GetSubPlayer() and player:GetSubPlayer():HasCollectible(item)) 
			or is_trinket and (player:HasTrinket(item) or check_sub == true and player:GetSubPlayer() and player:GetSubPlayer():HasCollectible(item)) then
			table.insert(ret, player)
		end
	end

	if #ret == 0 then return {} else return ret end
end

util.macro_on_players_that_have = function(item, funct, pred)
	if pred == true then --default trinket predicate
		pred = function(player) return player:GetTrinketMultiplier(item) end 
	elseif pred == nil then --default collectible predicate
		pred = function(player) return player:GetCollectibleNum(item) end 
	end
	
	if type(pred) == "function" then 
		for i=1,GODMODE.game:GetNumPlayers() do
			local player = Isaac.GetPlayer(i-1)
			local multiplier = pred(player)
			if multiplier and multiplier > 0 then
				funct(player,multiplier)
			end
		end	
	else 
		GODMODE.log("ERROR: Specified predicate for searching for \'"..item.."\' is not a function. It should be \'function(player) return 0 end\', or true for trinkets or unspecified for collectibles.")
	end
end

util.macro_on_players = function(funct)
	for i=1,GODMODE.game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i-1)
		funct(player)
	end
end

util.is_player_attack = function(entref)
	return entref.Type == EntityType.ENTITY_TEAR or entref.Type == EntityType.ENTITY_KNIFE or (entref.Type == EntityType.ENTITY_LASER and entref.SpawnerType == EntityType.ENTITY_PLAYER) or entref.Type == EntityType.ENTITY_PLAYER
end

util.get_player_from_attack = function(entref)
	if entref.Type == EntityType.ENTITY_TEAR or entref.Type == EntityType.ENTITY_KNIFE then
		if entref.Entity.SpawnerEntity and entref.Entity.SpawnerEntity:ToPlayer() then
			return entref.Entity.SpawnerEntity:ToPlayer()
		elseif entref.Entity.Parent and entref.Entity.Parent:ToPlayer() then
			return entref.Entity.Parent:ToPlayer()
		end
	elseif entref.Type == EntityType.ENTITY_PLAYER then
		return entref.Entity:ToPlayer()
	end
end

util.tear_mods = {
	[CollectibleType.COLLECTIBLE_BRIMSTONE] = function(firedelay, val)
		return val / 3
	end,
	[CollectibleType.COLLECTIBLE_INNER_EYE] = function(firedelay, val) 
		return val * 0.51
	end,
	[CollectibleType.COLLECTIBLE_MUTANT_SPIDER] = function(firedelay, val)
		return val * 0.42
	end,
	[CollectibleType.COLLECTIBLE_DR_FETUS] = function(firedelay, val)
		return val * 0.4
	end,
	[CollectibleType.COLLECTIBLE_IPECAC] = function(firedelay, val)
		return val / 3
	end,
	[CollectibleType.COLLECTIBLE_POLYPHEMUS] = function(firedelay, val)
		return val * 0.42
	end,
	[CollectibleType.COLLECTIBLE_SACRED_HEART] = function(firedelay, val)
		return val * 0.9
	end,
	[CollectibleType.COLLECTIBLE_MONSTROS_LUNG] = function(firedelay, val)
		return val / 4.3
	end,
	[CollectibleType.COLLECTIBLE_EVES_MASCARA] = function(firedelay, val)
		return val * 0.66
	end,
	[CollectibleType.COLLECTIBLE_HAEMOLACRIA] = function(firedelay, val)
		return val / 2
	end,
	[CollectibleType.COLLECTIBLE_TECHNOLOGY_2] = function(firedelay, val)
		return val * 0.66
	end,
}

util.tear_caps = {
	[CollectibleType.COLLECTIBLE_GUILLOTINE] = function(firedelay, val) 
		return -1
	end,
	[CollectibleType.COLLECTIBLE_ANTI_GRAVITY] = function(firedelay, val)
		return -2
	end,
	[CollectibleType.COLLECTIBLE_CRICKETS_BODY] = function(firedelay, val)
		return -1
	end,
	[CollectibleType.COLLECTIBLE_MOMS_PERFUME] = function(firedelay, val)
		return -1
	end,
	[CollectibleType.COLLECTIBLE_CAPRICORN] = function(firedelay, val)
		return -1
	end,
	[CollectibleType.COLLECTIBLE_PISCES] = function(firedelay, val)
		return -1
	end,
	
	[CollectibleType.COLLECTIBLE_PASCHAL_CANDLE] = function(firedelay, val, player)
		local ret = 0 

		-- GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_FAMILIAR,FamiliarVariant.PASCHAL_CANDLE,nil,function(candle)
		-- 	candle = candle:ToFamiliar()
		-- end)

		return -ret / 2.0
	end,
}

util.player_tear_mults = {
	[PlayerType.PLAYER_AZAZEL] = function(firedelay,val)
		return {mod=val * 0.267,ignore=CollectibleType.COLLECTIBLE_BRIMSTONE}
	end,
	[PlayerType.PLAYER_AZAZEL_B] = function(firedelay,val)
		return {mod=val * 1/3.0,ignore=CollectibleType.COLLECTIBLE_BRIMSTONE}
	end,
	[PlayerType.PLAYER_EVE_B] = function(firedelay,val)
		return {mod=val * 0.66,ignore=CollectibleType.COLLECTIBLE_BRIMSTONE}
	end,
	[PlayerType.PLAYER_THEFORGOTTEN] = function(firedelay,val)
		return {mod=val * 0.5,ignore=CollectibleType.COLLECTIBLE_BRIMSTONE}
	end,
	[PlayerType.PLAYER_THEFORGOTTEN_B] = function(firedelay,val)
		return {mod=val * 0.5,ignore=CollectibleType.COLLECTIBLE_BRIMSTONE}
	end,
}

util.get_max_tears = function(player,firedelay)
	firedelay = firedelay or player.MaxFireDelay
	--implementing tears cap
	local cap = 5
	for item,add in pairs(util.tear_caps) do 
		if player:HasCollectible(item) then 
			cap = cap - add(firedelay, firedelay, player)
		end
	end

	local cur_mult_val = 1

	for item,mult in pairs(util.tear_mods) do
		if player:HasCollectible(item) then 
			local scaled_val = mult(firedelay, 1)
			if scaled_val and cur_mult_val > scaled_val 
				and (player_tear_mult == nil or player_tear_mult.ignore ~= nil and player_tear_mult.ignore ~= item) then 
				cur_mult_val = scaled_val
			end
		end
	end

	--cancer!
	cap = cap + player:GetTrinketMultiplier(TrinketType.TRINKET_CANCER) * 2

	if player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then 
		cap = cap * 4
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then 
		cap = cap * 5.5
	end

	return cap * cur_mult_val
end

util.add_tears = function(player, firedelay, val, ignore_cap)
    local tears = 30 / (firedelay + 1)
	local cur_mult_val = val
	local player_tear_mult = util.player_tear_mults[player.SubType] and util.player_tear_mults[player.SubType](firedelay, val) or nil 

	--scales tears multipliers
	for item,mult in pairs(util.tear_mods) do
		if player:HasCollectible(item) then 
			local scaled_val = mult(firedelay, val)
			if scaled_val and cur_mult_val > scaled_val 
				and (player_tear_mult == nil or player_tear_mult.ignore ~= nil and player_tear_mult.ignore ~= item) then 
				cur_mult_val = scaled_val
			end
		end
	end

	local p_scaled_val = util.player_tear_mults[player.SubType]

	if p_scaled_val ~= nil and cur_mult_val > p_scaled_val(firedelay, val).mod then 
		cur_mult_val = p_scaled_val(firedelay, val).mod
	end

	--implementing tears cap
	local cap = util.get_max_tears(player)

    local new_tears = tears + cur_mult_val

	if ignore_cap ~= true then 
		-- new_tears = math.min(new_tears, cap) -- replaced with clamped_add so that tear cap can work for godmode items and not impact modded items 
		local clamped_add = math.min(cur_mult_val,math.max(-0.99,cap-tears))
		-- GODMODE.log("add="..clamped_add..",tears="..tears..",cap="..cap..",cur_val="..cur_mult_val,true)
		new_tears = tears + clamped_add
	end

	local converted_tears = math.max((30 / new_tears) - 1, -0.99)
    return converted_tears
end

util.total_item_count = function(item, trinket)
	local players = util.does_player_have(item, trinket)
	local ret = 0
	if players ~= nil then
		for i,player in ipairs(players) do
			if trinket then 
				ret = ret + player:GetTrinketMultiplier(item)
			else
				ret = ret + player:GetCollectibleNum(item)
			end
		end
	end

	return ret 
end

util.get_active_slot = function(player, item)
	local slots = {ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_SECONDARY, ActiveSlot.SLOT_POCKET, ActiveSlot.SLOT_POCKET2}
	for _,slot in ipairs(slots) do 
		if player:GetActiveItem(slot) == item then
			return slot
		end
	end

	return -1
end

util.get_card_slot = function(player, card)
	local slots = {0, 1, 2, 3}
	for _,slot in ipairs(slots) do 
		-- GODMODE.log("slot "..slot.." = "..card.." ? "..player:GetCard(slot),true)
		if player:GetCard(slot) == card then
			return slot
		end
	end

	return -1
end

util.find_uncharged_active_slot = function(player)
	local slots = {ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_SECONDARY, ActiveSlot.SLOT_POCKET, ActiveSlot.SLOT_POCKET2}
	for _,slot in ipairs(slots) do 
		if player:GetActiveItem(slot) > -1 then
			local config = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(slot))
			if config and config:IsCollectible() and config.MaxCharges > player:GetActiveCharge(slot) then
				return slot
			end
		end
	end

	return -1
end

util.get_max_charge = function(item)
	local config = Isaac.GetItemConfig():GetCollectible(item)
	if config and config:IsCollectible() then
		return config.MaxCharges
	end
end

util.macro_on_enemies = function(spawner,ent_type,var, subtype, funct, predicate, search_all)
	ent_type = ent_type or -1
	var = var or -1
	subtype = subtype or -1
	predicate = predicate or function(ent) 
		return true
	end

	local ents = (ent_type == -1 or search_all) and Isaac.GetRoomEntities() or Isaac.FindByType(ent_type,var,subtype,true,false)

	for i=1,#ents do 
		local enemy = ents[i]
		if enemy then
			local spawner_flag = (spawner == nil or ((enemy.SpawnerEntity ~= nil and GetPtrHash(enemy.SpawnerEntity) == GetPtrHash(spawner)) or 
			(enemy.Parent ~= nil and GetPtrHash(enemy.Parent) == GetPtrHash(spawner))))
			local type_flag = (ent_type == -1 or enemy.Type == ent_type) and (var == -1 or enemy.Variant == var) and (subtype == -1 or enemy.SubType == subtype)
			if spawner_flag and predicate(enemy) == true and type_flag then
					funct(enemy)
			end
		end
	end
end

util.macro_on_grid = function(type,var, funct, predicate)
	type = type or -1
	var = var or -1
	predicate = predicate or function(grid_ent) 
		return grid_ent ~= nil 
			and (type == -1 or grid_ent:GetType() == type) 
			and (var == -1 or grid_ent:GetVariant() == var) 
	end
	local room = GODMODE.room

	for y = 1, room:GetGridHeight() - 1 do
	    for x = 1, room:GetGridWidth() - 1 do
	        local ind = y * room:GetGridWidth() + x
	        local grid_ent = room:GetGridEntity(ind)

			if predicate(grid_ent) then 
				funct(grid_ent,ind,room:GetGridPosition(ind))
			end
	    end
	end
end

util.count_child_enemies = function(spawner,inc_friendly,predicate)
	if spawner == nil then return 0 end 
	inc_friendly = inc_friendly or true
	predicate = predicate or function(ent) return true end

	local ents = Isaac.GetRoomEntities()
	local ret = 0
	for i=1,#ents do 
		local enemy = ents[i]
		if enemy then
			if enemy:ToNPC() and ((enemy.SpawnerEntity ~= nil and GetPtrHash(enemy.SpawnerEntity) == GetPtrHash(spawner)) or (enemy.Parent ~= nil and GetPtrHash(enemy.Parent) == GetPtrHash(spawner))) and predicate(enemy) == true then
				ret = ret + 1
			end
		end
	end

	return ret
end

util.count_enemies = function(spawner,type,var,subtype,inc_friendly,predicate)
	var = var or -1
	subtype = subtype or -1
	inc_friendly = inc_friendly or true
	predicate = predicate or function(ent) return ent.Type == type and (var == -1 or var == nil or var == ent.Variant) and (subtype == -1 or subtype == nil or ent.SubType == subtype) end

	local ents = Isaac.GetRoomEntities()--Isaac.FindByType(type,var,subtype,true,not inc_friendly)

	local ret = 0
	for i=1,#ents do 
		local enemy = ents[i]
		if enemy and (type == nil or type == -1 or enemy.Type == type) and (variant == nil or variant == -1 or enemy.Variant == variant) and (subtype == nil or subtype == -1 or enemy.SubType == subtype) then
			if (spawner == nil or spawner == -1 or enemy.SpawnerEntity ~= nil and GetPtrHash(enemy.SpawnerEntity) == GetPtrHash(spawner)) and predicate(enemy) == true then
				ret = ret + 1
			end
		end
	end

	return ret
end

util.string_split = function(str,seperator)
	if str == nil then
		return nil
	elseif seperator == nil then
		return nil
	else
		if str:match(seperator) == nil then 
			return {str}
		else
			ret = {}
			count = 1
			splitter = "([^"..seperator.."]+)"
			for word in string.gmatch(str, splitter) do
				ret[count] = word
				count = count + 1
			end
			
			return ret
		end
	end
end

util.string_starts = function(str,start)
	return string.sub(str,1,string.len(start))==start
 end

util.is_start_of_run = function()
	return GODMODE.game.TimeCounter < 2
end

util.mult_color = function(multiplier)
	return Color(multiplier,multiplier,multiplier,multiplier,multiplier,multiplier,multiplier)
end

--DSS center of screen function
util.get_center_of_screen = function()
	return (GODMODE.room:GetRenderSurfaceTopLeft() * 2 + Vector(442, 286))/2
end

local corners = {{x=0.05,y=0.075},{x=1.25,y=0.075},{x=0.05,y=1.9},{x=1.25,y=1.9}}

util.get_hud_corner_pos = function(index)
	return util.get_center_of_screen() * Vector((corners[index] or {x=1}).x,(corners[index] or {y=2}).y)
end

util.get_player_from_controller = function(index)
	for i=1,GODMODE.game:GetNumPlayers() do
		local player = Isaac.GetPlayer(i)
		if player.ControllerIndex == index then 
			return player
		end
	end

	return nil
end

util.get_player_index = function(player)
	return tonumber(GODMODE.save_manager.get_data("Player"..player.InitSeed,"-1"))
end

util.init_rand = function(seed)
	seed = math.max(1,seed or GODMODE.game:GetSeeds():GetPlayerInitSeed())
	util.rng = RNG()
	util.rng:SetSeed(seed,35)
end

util.random = function(min,max)
	local seed = math.max(1,GODMODE.game:GetSeeds():GetPlayerInitSeed())
	if util.rng == nil or (util.rng_seed or 0) ~= seed then
		util.init_rand(seed)
		util.rng_seed = seed
	end

	if min == nil and max == nil then
		return util.rng:RandomFloat()
	elseif min ~= nil and max == nil then
		return util.rng:RandomInt(min)
	elseif min ~= nil and max ~= nil then
		return util.rng:RandomInt(max - min) + min
	end
end

util.is_mirror = function()
    for i=0,168 do
        local data=GODMODE.level:GetRoomByIdx(i).Data
        if data and data.Name=='Knife Piece Room' and GODMODE.level:GetAbsoluteStage() == 2 then
            return true
        end
    end
    return false
end

util.is_correction = function()
	local data=GODMODE.level:GetCurrentRoomDesc().Data
	if data and data.Name=='[GODMODE] Corrective Room' then
		return true
	end

    return false
end


util.deep_copy = function(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

util.is_valid_enemy = function(ent, coll_damage_override, dead_override)
	return ent.MaxHitPoints > 0 and (coll_damage_override == true or ent.CollisionDamage > 0) 
		and not (ent:HasEntityFlags(EntityFlag.FLAG_CHARM) or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))
		-- and ent:CanShutDoors()
		and ent.Type ~= EntityType.ENTITY_FIREPLACE 
		and ent.Type ~= EntityType.ENTITY_GAPING_MAW
		and ent.Type ~= EntityType.ENTITY_BROKEN_GAPING_MAW
		and ent.Type ~= EntityType.ENTITY_STONEY
		and (ent.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE and ent.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_ENEMIES)
		and (ent:Exists() or dead_override == true)
		and (not ent:IsDead() or dead_override == true)
		and (ent:IsActiveEnemy(false) or dead_override == true)
		and (ent.Visible or dead_override == true)
		and (GODMODE.armor_blacklist and GODMODE.armor_blacklist:can_be_champ(ent) or not GODMODE.armor_blacklist)
end

util.scaling_presets = {
	[1] = function(ent) -- how deep you are floor-wise
		local max_stage = 12
		local type = "E"
		if ent and ent.IsBoss and ent:IsBoss() then type = "B" end 
		local scale = tonumber(GODMODE.save_manager.get_config("HM"..type.."Scale","2.0")) * 0.5
	
		local stage = GODMODE.level:GetAbsoluteStage()
	
		if GODMODE.level:IsAscent() then 
			stage = 6+7-stage
		end
	
		if StageAPI and StageAPI.GetCurrentStage() and GODMODE.stages[StageAPI.GetCurrentStage().Name] then 
			stage = GODMODE.stages[StageAPI.GetCurrentStage().Name].simulating_stage or stage
		end
	
		local percent = (stage-1) / math.max(1,max_stage-1) * math.max(1.0,scale-1.0)
	
		if GODMODE.game.Difficulty > 1 then 
			max_stage = 7 
			scale = tonumber(GODMODE.save_manager.get_config("GM"..type.."Scale","1.5")) * 0.5
			percent = (stage-1) / math.max(1,max_stage-1) * math.max(1.0,scale-1.0)
	
			if GODMODE.save_manager.get_config("GMEnable","true") == "false" then 
				percent = 0
			end
		elseif GODMODE.save_manager.get_config("HMEnable","true") == "false" then 
			percent = 0
		end

		local max_health = tonumber(GODMODE.save_manager.get_config("ScaleSelectorMax","3000"))

		if ent and (ent.MaxHitPoints >= max_health or GODMODE.armor_blacklist:has_armor(ent)) then
			percent = 0
		end
	
		return 1 + percent
	end,
	
	[2] = function(ent) -- sum of player stat scores
		local percent = 0
		local type = "E"
		if ent and ent.IsBoss and ent:IsBoss() then type = "B" end 

		local max = tonumber(GODMODE.save_manager.get_config("HM"..type.."Scale"))
		local total_score = 0
		local total_players = 0
		util.macro_on_players(function(player) 
			local base_score = tonumber(GODMODE.save_manager.get_player_data(player,"BaseStats","-1"))

			total_score = total_score + util.get_stat_score(player).score - math.max(base_score,0)
			total_players = total_players + 1
		end)
		
		if GODMODE.game.Difficulty > 1 then
			max = tonumber(GODMODE.save_manager.get_config("GM"..type.."Scale"))

			if GODMODE.save_manager.get_config("GMEnable","true") == "false" then 
				percent = -1
			end
		else
			if GODMODE.save_manager.get_config("HMEnable","true") == "false" then 
				percent = -1
			end
		end

		if percent >= 0 then 
			percent = total_score / (util.get_max_stat_score() * total_players)
		end

		local max_health = tonumber(GODMODE.save_manager.get_config("ScaleSelectorMax","3000"))

		if ent and (ent.MaxHitPoints >= max_health or GODMODE.armor_blacklist:has_armor(ent)) then 
			percent = 0
		end

		if GODMODE.level:GetAbsoluteStage() == 1 then 
			return 1
		end

		return 1 + math.max(percent,0)
	end
}

util.get_health_scale = function(ent, preset)
	preset = preset or tonumber(GODMODE.save_manager.get_config("HPScaleMode","2"))
	return util.scaling_presets[preset](ent)
end

util.get_stage = function()
	local stage = GODMODE.level:GetAbsoluteStage()
	
	if StageAPI and StageAPI.GetCurrentStage() and GODMODE.stages[StageAPI.GetCurrentStage().Name] then 
		stage = GODMODE.stages[StageAPI.GetCurrentStage().Name].simulating_stage or stage
	end

	return stage
end

local curses = {
	LevelCurse.CURSE_OF_DARKNESS,
	LevelCurse.CURSE_OF_LABYRINTH,
	LevelCurse.CURSE_OF_THE_LOST,
	LevelCurse.CURSE_OF_THE_UNKNOWN,
	LevelCurse.CURSE_OF_MAZE,
	LevelCurse.CURSE_OF_BLIND,
}

util.get_random_curse = function(rng)
	return curses[rng:RandomInt(#curses)+1]
end

--use for custom curses, ids do NOT work when working with curses must be shifted
util.get_shifted_curse = function(curse)
	if type(curse) == "number" then 
		return 1 << (curse - 1)
	end
end

util.has_curse = function(curse,shifted)
	shifted = shifted or false 
	if shifted then curse = util.get_shifted_curse(curse) end

	if curse >= 0 then 
		-- GODMODE.log("curse="..curse..",ind_curse="..tostring(ind_curse_list[curse])..",curse_list="..tostring(util.curse_list[ind_curse_list[curse]]),true)
		return GODMODE.level:GetCurses() & curse ~= 0
	elseif GODMODE.curse_notify ~= true then
		GODMODE.log("Restarting the game is required for curses/blessings to appear..", true)
		GODMODE.curse_notify = true
		return false
	end
end

util.max_curse = LevelCurse.NUM_CURSES + 20
-- optimize \/
cached_curse_list = nil
util.blessing_list = {}

for _,blessing in ipairs(GODMODE.registry.blessings) do 
	util.blessing_list[blessing] = true
end

util.get_curse_list = function(blessings)
	if blessings == nil then blessings = true end
	if cache_curse_list == nil or cache_curse_list.timestamp ~= GODMODE.game:GetFrameCount() then 
		cached_curse_list = {timestamp=GODMODE.game:GetFrameCount(),list={}}

		for curse=0, util.max_curse do 
			if curse <= LevelCurse.NUM_CURSES then 
				-- GODMODE.log("curse="..curse..",shifted="..tostring(util.get_shifted_curse(curse))
				-- ..",tb="..tostring(blessings == true)
				-- ..",fb="..tostring(util.blessing_list[util.get_shifted_curse(curse)] == false and blessings == false)
				-- ..",hc="..tostring(util.has_curse(util.get_shifted_curse(curse))),true)	
			end
			
			if util.has_curse(util.get_shifted_curse(curse)) 
				--optionally omit blessings
				and (blessings == true 
				or util.blessing_list[curse] ~= true and blessings == false) then 

				-- expand for modded curses
				if curse >= util.max_curse - 1 then 
					GODMODE.log("Expanding curse capacity for detection!",true)
					util.max_curse = util.max_curse + 10
				end
	
				table.insert(cached_curse_list.list, curse)
			end
		end	
	end

	return (cached_curse_list or {list={}}).list
end

util.add_curse = function(curse, show_name, shift_bit)
	-- GODMODE.log("added curse \'"..curse.."\' ("..util.get_valid_curse(curse)..")",true)
	shift_bit = shift_bit or false
	if shift_bit then 
		GODMODE.level:AddCurse(util.get_shifted_curse(curse),show_name or true)
	else
		GODMODE.level:AddCurse(curse,show_name or true)
	end
end

util.is_delirium = function()
	local data = GODMODE.level:GetCurrentRoomDesc().Data
	return data.Subtype == 70 and data.Type == RoomType.ROOM_BOSS
end

util.ground_ai_movement = function(ent,target,speed,direct,linemode,ignore_poop)
	linemode = linemode or 1
	speed = speed or 1
	direct = direct or true
	ignore_poop = ignore_poop or false

	if not ent:ToNPC() or target == nil then return Vector.Zero else 
		ent = ent:ToNPC()
		local path = ent.Pathfinder

		local target_pos = target

		if target["FrameCount"] ~= nil then --if target is an entity use the position
			target_pos = target.Position 
		end
		
		if not path:HasPathToPos(target_pos,ignore_poop) then 
			return Vector.Zero
		elseif GODMODE.room:CheckLine(ent.Position,target_pos,linemode) == true then 
			return (target_pos - ent.Position):Resized(speed)
		else 
			return nil
		end
	end
end

util.is_cotv_counting = function()
	local room = GODMODE.room
	return GODMODE.util.total_item_count(GODMODE.registry.items.a_second_thought) == 0 and room:IsClear() and not util.is_death_certificate() and
            ((((room:GetType() == RoomType.ROOM_CHALLENGE and Isaac.CountEnemies()+Isaac.CountBosses() == 0 or room:GetType() ~= RoomType.ROOM_CHALLENGE) and room:GetType() ~= RoomType.ROOM_BOSSRUSH and room:GetType() ~= RoomType.ROOM_ARCADE and room:GetType() ~= RoomType.ROOM_ISAACS) 
            and GODMODE.game.Challenge == Challenge.CHALLENGE_NULL and (not GODMODE.is_at_palace or not GODMODE.is_at_palace()) and GODMODE.save_manager.get_config("CallOfTheVoid","false") == "true" 
            and GODMODE.game.Difficulty == Difficulty.DIFFICULTY_HARD and GODMODE.level:GetAbsoluteStage() <= LevelStage.STAGE5 and GODMODE.level:GetAbsoluteStage() > 1) or (GODMODE.game.Challenge == GODMODE.registry.challenges.out_of_time))
            and GODMODE.save_manager.get_data("VoidSpawned","false") ~= "true" and not GODMODE.paused and not GODMODE.is_in_secrets() and not room:HasCurseMist()
end

util.is_cotv_spawned = function()
	return GODMODE.save_manager.get_data("VoidSpawned","false") == "true"
end

util.get_cotv_counter_pos = function()
	if util.cotv_pos == nil then 
		util.cotv_pos = util.get_center_of_screen() * 2
		util.cotv_pos.X = util.cotv_pos.X * tonumber(GODMODE.save_manager.get_config("COTVDisplayX","0.5"))
		util.cotv_pos.Y = util.cotv_pos.Y * tonumber(GODMODE.save_manager.get_config("COTVDisplayY","0.1"))
	end 

	return util.cotv_pos
end

util.modify_stat = function(player, cache, amt, mult, tear_capped)
	mult = mult or false
	tear_capped = tear_capped or true
	if mult then 
		if cache == CacheFlag.CACHE_DAMAGE then 
			player.Damage = player.Damage * amt
		elseif cache == CacheFlag.CACHE_FIREDELAY then 
			local tears = 30 / (player.MaxFireDelay + 1)
			player.MaxFireDelay = util.add_tears(player,player.MaxFireDelay,(tears*amt) - tears,not tear_capped)
		elseif cache == CacheFlag.CACHE_LUCK then 
			player.Luck = player.Luck * amt
		elseif cache == CacheFlag.CACHE_SPEED then 
			player.MoveSpeed = player.MoveSpeed * amt
		elseif cache == CacheFlag.CACHE_SHOTSPEED then 
			player.ShotSpeed = player.ShotSpeed * amt
		elseif cache == CacheFlag.CACHE_RANGE then 
			player.TearRange = player.TearRange * amt
		end	
	else
		if cache == CacheFlag.CACHE_DAMAGE then 
			player.Damage = player.Damage + amt
		elseif cache == CacheFlag.CACHE_FIREDELAY then 
			player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,amt,not tear_capped)
		elseif cache == CacheFlag.CACHE_LUCK then 
			player.Luck = player.Luck + amt
		elseif cache == CacheFlag.CACHE_SPEED then 
			player.MoveSpeed = player.MoveSpeed + amt
		elseif cache == CacheFlag.CACHE_SHOTSPEED then 
			player.ShotSpeed = player.ShotSpeed + amt
		elseif cache == CacheFlag.CACHE_RANGE then 
			player.TearRange = player.TearRange + amt
		end	
	end
end

local input_maps = {
	attack = {
		[ButtonAction.ACTION_SHOOTLEFT] = true,
		[ButtonAction.ACTION_SHOOTRIGHT] = true,
		[ButtonAction.ACTION_SHOOTUP] = true,
		[ButtonAction.ACTION_SHOOTDOWN] = true,
	},
	move = {
		[ButtonAction.ACTION_LEFT] = true,
		[ButtonAction.ACTION_RIGHT] = true,
		[ButtonAction.ACTION_UP] = true,
		[ButtonAction.ACTION_DOWN] = true,
	}
}

util.is_action_attack = function(action)
	return input_maps.attack[action] == true
end

util.is_action_move = function(action)
	return input_maps.move[action] == true
end

util.action_groups = {
	attack = "attack",
	move = "move"
}

util.is_action_group_pressed = function(group, controller, once)
	controller = controller or Isaac.GetPlayer().ControllerIndex
	once = once or false 

	if input_maps[group] then 
		for key,_ in pairs(input_maps[group]) do 
			if Input.IsActionPressed(key, controller) and not once or Input.IsActionTriggered(key, controller) and once then 
				return key
			end
		end		

		return false
	else
		GODMODE.log("Input group \'"..group.."\' is invalid, please check GODMODE.util.action_groups",true)
		return false
	end
end

util.get_set_from = function(array,keys)
	local ret = {}
	keys = keys or true
	for key,val in pairs(array) do 
		if keys == true then 
			table.insert(ret,key)
		else
			table.insert(ret,val)
		end
	end

	return ret
end


local max_doors = { --used for pile of keys
    [RoomShape.ROOMSHAPE_1x1] = 4,
    [RoomShape.ROOMSHAPE_IH] = 2,
    [RoomShape.ROOMSHAPE_IV] = 2,
    [RoomShape.ROOMSHAPE_1x2] = 6,
    [RoomShape.ROOMSHAPE_IIV] = 2,
    [RoomShape.ROOMSHAPE_2x1] = 6,
    [RoomShape.ROOMSHAPE_IIH] = 2,
    [RoomShape.ROOMSHAPE_2x2] = 8,
    [RoomShape.ROOMSHAPE_LTL] = 8,
    [RoomShape.ROOMSHAPE_LTR] = 8,
    [RoomShape.ROOMSHAPE_LBL] = 8,
    [RoomShape.ROOMSHAPE_LBR] = 8,
}

util.get_max_doors = function(shape)
	return max_doors[shape]
end

util.add_faithless = function(player,amt)
    -- player:AddBrokenHearts(amt)

    -- if player:GetBrokenHearts() == 12 then 
        -- player:Die()
    -- end
	local max_hits = 12 + (player:GetPlayerType() == PlayerType.PLAYER_MAGDALENE and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and 6 or 0)
	
    GODMODE.save_manager.set_player_data(player,"FaithlessHearts",math.max(0,math.min(max_hits,tonumber(GODMODE.save_manager.get_player_data(player,"FaithlessHearts","0"))+amt)),true)
end

util.get_faithless = function(player)
	return tonumber(GODMODE.save_manager.get_player_data(player,"FaithlessHearts","0"))
end

util.calc_broken_perc = function()
    local total_broken = 0
    local total_capacity = 0

    GODMODE.util.macro_on_players(function(player) 
        total_broken = total_broken + player:GetBrokenHearts()
        total_capacity = total_capacity + player:GetHeartLimit()
    end)

    return total_broken / total_capacity
end

util.get_player_hits = function(player,containers,red_only)
	return math.ceil((((containers or red_only) and player:GetMaxHearts() or player:GetHearts()) + player:GetSoulHearts() + (player:GetBoneHearts() * (containers and 2 or 1))) / (containers and 2 or 1)) + player:GetBrokenHearts() * (red_only and 2 or 0)
end

util.is_death_certificate = function()
	local id = GODMODE.level:GetCurrentRoomIndex()
	return GetPtrHash(GODMODE.level:GetRoomByIdx(id,-1)) == GetPtrHash(GODMODE.level:GetRoomByIdx(id,2))
end

local heart_start = {
	[1] = Vector(48,12),
	[2] = Vector(469,12),
	[3] = Vector(106,267),
	[4] = Vector(533,267),
}

local hud_mult = {
	Vector(1,1), Vector(-1.2,1), Vector(1,-1), Vector(-0.8,-0.5)
}

local heart_size = Vector(12,10)
local hud_off_vec = Vector(20,12)

util.get_heart_pos_for = function(player,h_ind)
	local slot = tonumber(GODMODE.save_manager.get_data("Player"..player.InitSeed,"0"))
	local width = 6 / math.min(slot,2)
	local invert = Vector(1,1)
	if player:GetPlayerType() == PlayerType.PLAYER_ESAU then slot = slot + 2 width = 6 end
	if slot == 4 then 
		invert = Vector(-1,1)
		-- h_ind = 12 - h_ind
	end

	if slot > 4 or slot < 1 then GODMODE.log("trying to render heart ui for slot "..slot..", which is invalid",true) return nil end
	local base_pos = heart_start[slot]

	return base_pos + Vector(heart_size.X * (h_ind % width), heart_size.Y * math.floor(h_ind / width)) * invert + hud_off_vec * Options.HUDOffset * hud_mult[slot]
end

local heart_spots = {
	--faithless
	[1] = function(player)
		return util.get_player_hits(player,true) - 1 + player:GetBrokenHearts()
	end,
	--delirious
	[2] = function(player)
		return util.get_player_hits(player,true) + player:GetBrokenHearts()
	end,
	--toxic
	[3] = function(player)
		return 5
	end,
}

-- get the starting index of a specific heart type 
util.get_heart_ind_for = function(player,type)
	return heart_spots[type](player)
end

-- harsh function, use carefully
util.clear_radius = function(pos,radius,predicate)
	local predicate = predicate or function(ent) 
		return true 
	end

	local ents = Isaac.GetRoomEntities()

	for _,ent in ipairs(ents) do 
		if ent and not ent:ToPlayer() and not ent:ToFamiliar() and predicate(ent) then 
			if (ent.Position - pos):Length() < radius then 
				ent:Remove()
			end
		end
	end
end

util.get_options_index = function(pickup,check_all_pickups)
	check_all_pickups = check_all_pickups or false
	if GODMODE.validate_rgon() then return pickup:ToPickup():SetNewOptionsPickupIndex() else 
		local ind = pickup.InitSeed % 999
		local valid_flag = false 
		local depth = 20
		
		while valid_flag == false and depth > 0 do 
			depth = depth - 1
			valid_flag = true 
			util.macro_on_enemies(nil,pickup.Type,check_all_pickups and nil or pickup.Variant,nil, function(pickup2)
				if pickup2.OptionsPickupIndex == ind then 
					valid_flag = false
				end
			end)

			if valid_flag == false then 
				ind = pickup:GetDropRNG():RandomInt(999)
			end
		end

		return ind 
	end
end

-- from taintedtreasures for new observatory gen
util.shuffle = function(tbl)
	if util.rng == nil or (util.rng_seed or 0) ~= seed then
		local seed = math.max(1,GODMODE.game:GetSeeds():GetPlayerInitSeed())
		util.init_rand(seed)
		util.rng_seed = seed
	end

	for i = #tbl, 2, -1 do
    local j = util.rng:RandomInt(1, i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

util.schedule_function = function(func,delay,call)
	delay = delay or 0
	call = call or ModCallbacks.MC_POST_UPDATE
	GODMODE.timers = GODMODE.timers or {}
	table.insert(GODMODE.timers,{delay=delay,call=func,callback=call})
end

util.get_pseudo_fx_flags = function()
	return EntityFlag.FLAG_NO_DEATH_TRIGGER | EntityFlag.FLAG_NO_FLASH_ON_DAMAGE | EntityFlag.FLAG_NO_REWARD | EntityFlag.FLAG_NO_PLAYER_CONTROL | EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS
end

util.get_floor_color = function(pos)
	if not GODMODE.validate_rgon() then return Color(1,1,1,1) else 
		local fly = Isaac.Spawn(EntityType.ENTITY_FLY,0,0,pos,Vector.Zero,nil):ToNPC()
		fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		fly:AddEntityFlags(util.get_pseudo_fx_flags())
		fly:Update()
		fly:UpdateDirtColor(true)
		local col = fly:GetDirtColor()
		fly:Remove()	
		return col 
	end
end

-- flushed out in GODMODE.register_player
util.seeded_players = {}

util.get_player_by_seed = function(init_seed)
	return util.seeded_players[init_seed]
end

-- set init to false to get by drop seed
util.get_entity_by_seed = function(seed,init)
	init = init or true 
	if seed == nil then return nil end 
	local ret = {}

	for ind,ent in ipairs(Isaac.GetRoomEntities()) do 
		if ent ~= nil and (init == true and ent.InitSeed == seed or init == false and ent.DropSeed == seed) then 
			table.insert(ret,ent)
		end
	end

	return (#ret == 0 and nil or #ret == 1 and ret[1] or ret)
end

util.is_modded_item = function(item) return item > CollectibleType.COLLECTIBLE_MOMS_RING end 

util.find_room_idx = function(type)
	local ret = {} 

	for i=0,168 do
		local data=GODMODE.level:GetRoomByIdx(i).Data
		if data and data.Type == type then
			table.insert(ret,i)
		end
	end

	return ret
end

util.for_each = function(list, transform) 
	local ret = {}

	for key,val in pairs(list) do 
		table.insert(ret,transform(key,val))
	end

	return ret 
end

util.hazard_grid_types = {
	[GridEntityType.GRID_ROCK_SPIKED] = GridEntityType.GRID_ROCK,
	[GridEntityType.GRID_SPIKES_ONOFF] = GridEntityType.GRID_NULL,
	[GridEntityType.GRID_SPIKES] = GridEntityType.GRID_NULL,
}

util.hazard_ent_types = {
	[EntityType.ENTITY_CONSTANT_STONE_SHOOTER] = function(ent) ent:GetSprite():Play("CloseEyes",true) end,
	[EntityType.ENTITY_STONEHEAD] = function(ent) ent:GetSprite():Play("CloseEyes",true) end,
	[EntityType.ENTITY_BRIMSTONE_HEAD] = function(ent) ent:GetSprite():Play("CloseEyes",true) end,
	[EntityType.ENTITY_QUAKE_GRIMACE] = function(ent) ent:GetSprite():Play("CloseEyes",true) end,
	[EntityType.ENTITY_SPIKEBALL] = function(ent) ent:Die() end,
	[EntityType.ENTITY_BALL_AND_CHAIN] = function(ent) ent:Remove() end,
	[EntityType.ENTITY_FIREPLACE] = function(ent) 
		if ent.Variant % 2 == 1 then 
			ent:ToNPC():Morph(ent.Type,ent.Variant - 1, ent.SubType, -1)
		end
	end,
}

util.dehazard_room = function() 
	if GODMODE.validate_rgon() then 
		Isaac.ClearBossHazards(true)
	end

	for targ_type,rep_type in pairs(util.hazard_grid_types) do 
		GODMODE.util.macro_on_grid(targ_type,-1,function(grident,ind,pos) 
			GODMODE.room:RemoveGridEntity(ind,0,true)
			grident:Update()	

			if rep_type ~= GridEntityType.GRID_NULL then 
				GODMODE.room:SpawnGridEntity(ind,rep_type,grident:GetRNG():GetSeed(),0)
			else 
				GODMODE.room:SetGridPath(ind,0)
			end

			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pos, Vector.Zero, nil)
		end)
	end

	for targ_type,rep_func in pairs(util.hazard_ent_types) do 
		GODMODE.util.macro_on_enemies(nil,targ_type,-1,-1,function(ent) 
			rep_func(ent)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, ent.Position, Vector.Zero, nil)
		end)
	end
end

return util