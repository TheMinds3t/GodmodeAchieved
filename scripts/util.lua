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

-- For stageapi
util.base_room_door = {
    RequireCurrent = {RoomType.ROOM_DEFAULT, RoomType.ROOM_MINIBOSS, RoomType.ROOM_SACRIFICE, RoomType.ROOM_BARREN, RoomType.ROOM_ISAACS, RoomType.ROOM_DICE, RoomType.ROOM_CHEST},
    RequireTarget = {RoomType.ROOM_DEFAULT, RoomType.ROOM_MINIBOSS, RoomType.ROOM_SACRIFICE, RoomType.ROOM_BARREN, RoomType.ROOM_ISAACS, RoomType.ROOM_DICE, RoomType.ROOM_CHEST}
}

util.wrap_angle = function(angle, degrees)
	if degrees == nil then degrees = true end
	if degrees then angle = angle / 180 / math.pi end

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

util.get_skin_color = function(player)
    if player:GetName() == "Azazel" or player:GetName() == "Lilith" or player:GetName() == "Xaphan" or player:HasCollectible(CollectibleType.COLLECTIBLE_ABADDON) or player:HasCollectible(CollectibleType.COLLECTIBLE_SPIRIT_NIGHT) or player:GetName() == "Black Judas" then return "_black" elseif
    player:GetName() == "Apollyon" or player:GetName() == "Keeper" then return "_grey" elseif
    player:HasCollectible(CollectibleType.COLLECTIBLE_SMB_SUPER_FAN) then return "_red" elseif
    player:GetName() == "Deli" or player:GetName() == "The Lost" then return "_white" elseif
    player:HasCollectible(CollectibleType.COLLECTIBLE_IPECAC) then return "_green" elseif
    player:GetName() == "???" then return "_blue" else
    return "" end
end

util.does_player_have = function(item, is_trinket)
	local ret = {}
	for i=1,Game():GetNumPlayers() do
		local player = Isaac.GetPlayer(i-1)
		if player and not is_trinket and player:HasCollectible(item) or is_trinket and player:HasTrinket(item) then
			table.insert(ret, player)
		end
	end

	if #ret == 0 then return {} else return ret end
end

util.macro_on_players_that_have = function(item, funct, is_trinket)
	local ret = {}
	for i=1,Game():GetNumPlayers() do
		local player = Isaac.GetPlayer(i-1)
		if not is_trinket and player:HasCollectible(item) or is_trinket and player:HasTrinket(item) then
			funct(player)
		end
	end
end

util.macro_on_players = function(funct)
	local ret = {}
	for i=1,Game():GetNumPlayers() do
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

local tear_mods = {
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

local tear_caps = {
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

		GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_FAMILIAR,FamiliarVariant.PASCHAL_CANDLE,nil,function(candle)
			candle = candle:ToFamiliar()
		end)

		return -ret / 2.0
	end,
}

local player_tear_mults = {
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

util.add_tears = function(player, firedelay, val, ignore_cap)
    local tears = 30 / (firedelay + 1)
	local cur_mult_val = val

	--scales tears multipliers
	for item,mult in pairs(tear_mods) do
		if player:HasCollectible(item) then 
			local scaled_val = mult(firedelay, val)
			if scaled_val and cur_mult_val > scaled_val 
				and (not player_tear_mults[player.SubType] or 
					player_tear_mults[player.SubType] and player_tear_mults[player.SubType](firedelay, val).ignore ~= nil and player_tear_mods[player.SubType].ignore ~= item) then 
				cur_mult_val = scaled_val
			end
		end
	end

	local p_scaled_val = player_tear_mults[player.SubType]

	if p_scaled_val ~= nil and cur_mult_val > p_scaled_val(firedelay, val).mod then 
		GODMODE.log("hi!",true)
		cur_mult_val = p_scaled_val(firedelay, val).mod
	end


	--implementing tears cap
	local cap = 5
	for item,add in pairs(tear_caps) do 
		if player:HasCollectible(item) then 
			cap = cap - add(firedelay, val, player)
		end
	end

	--cancer!
	cap = cap + player:GetTrinketMultiplier(TrinketType.TRINKET_CANCER) * 2

	if player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK) then 
		cap = cap * 4
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then 
		cap = cap * 5.5
	end

    local new_tears = tears + cur_mult_val

	if ignore_cap ~= true then 
		-- new_tears = math.min(new_tears, cap)
		local clamped_add = math.min(cur_mult_val,math.max(0,cap-tears))
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
			ret = ret + player:GetCollectibleNum(item)
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

util.macro_on_enemies = function(spawner,type,var,subtype, funct, predicate)
	if type == nil then type = -1 end
	if var == nil then var = -1 end
	if subtype == nil then subtype = -1 end
	predicate = predicate or function(ent) return true end

	local ents = Isaac.FindByType(type,var,subtype,true,false)

	for i=1,#ents do 
		local enemy = ents[i]
		if enemy then
			if ((spawner == nil or enemy.SpawnerEntity ~= nil and GetPtrHash(enemy.SpawnerEntity) == GetPtrHash(spawner)) and predicate(enemy) == true) then
				funct(enemy)
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
	predicate = predicate or function(ent) return true end

	local ents = Isaac.FindByType(type,var,subtype,true,not inc_friendly)

	local ret = 0
	for i=1,#ents do 
		local enemy = ents[i]
		if enemy then
			if (spawner == nil or enemy.SpawnerEntity ~= nil and GetPtrHash(enemy.SpawnerEntity) == GetPtrHash(spawner)) and predicate(enemy) == true then
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
	elseif str:match(seperator) == nil then 
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

util.string_starts = function(str,start)
	return string.sub(str,1,string.len(start))==start
 end

util.is_start_of_run = function()
	return Game().TimeCounter < 2
end

util.mult_color = function(multiplier)
	return Color(multiplier,multiplier,multiplier,multiplier,multiplier,multiplier,multiplier)
end

--EID center of screen function
util.get_center_of_screen = function()
    local room = Game():GetRoom()
    local pos = room:WorldToScreenPosition(Vector(0,0)) - room:GetRenderScrollOffset() - Game().ScreenShakeOffset
    
    local rx = pos.X + 60 * 26 / 40
    local ry = pos.Y + 140 * (26 / 40)
    
    return Vector(rx*2 + 13*26, ry*2 + 7*26)
end

util.init_rand = function()
	util.rng = RNG()
	util.rng:SetSeed(Random(),0)
end

util.random = function(min,max)
	if util.rng == nil then
		util.init_rand()
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
        local data=Game():GetLevel():GetRoomByIdx(i).Data
        if data and data.Name=='Knife Piece Room' and Game():GetLevel():GetAbsoluteStage() == 2 then
            return true
        end
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
		and (ent.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE and ent.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_ENEMIES)
		and (ent:Exists() or dead_override == true)
		and (not ent:IsDead() or dead_override == true)
		and (ent:IsActiveEnemy(false) or dead_override == true)
		and (ent.Visible or dead_override == true)
		and GODMODE.armor_blacklist:can_be_champ(ent)
end

util.get_health_scale = function()
	local max_stage = 12
	local scale = tonumber(GODMODE.save_manager.get_config("HMEScale","2.0")) * 0.5

	local stage = Game():GetLevel():GetAbsoluteStage()

	if Game():GetLevel():IsAscent() then 
		stage = 6+7-stage
	end

	local percent = (stage-1) / math.max(1,max_stage-1) * math.max(1.0,scale-1.0)

	if Game().Difficulty > 1 then 
		max_stage = 7 
		scale = tonumber(GODMODE.save_manager.get_config("GMEScale","1.5")) * 0.5
		percent = (Game():GetLevel():GetStage()-1) / math.max(1,max_stage-1) * math.max(1.0,scale-1.0)
	end

	return 1 + percent
end

util.has_curse = function(curse)
	if curse > 0 then 
		return Game():GetLevel():GetCurses() & (2^(math.floor(curse)-1)) > 0
	elseif GODMODE.curse_notify ~= true then
		GODMODE.log("Restarting the game is required for curses/blessings to appear..", true)
		GODMODE.curse_notify = true
		return false
	end
end

util.is_delirium = function()
	local data = Game():GetLevel():GetCurrentRoomDesc().Data
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
		elseif Game():GetRoom():CheckLine(ent.Position,target_pos,linemode) == true then 
			return (target_pos - ent.Position):Resized(speed)
		else 
			return nil
		end
	end
end

util.is_cotv_counting = function()
	local room = Game():GetRoom()
	return GODMODE.util.total_item_count(Isaac.GetItemIdByName("A Second Thought")) == 0 and room:IsClear() and 
            ((((room:GetType() == RoomType.ROOM_CHALLENGE and Isaac.CountEnemies()+Isaac.CountBosses() == 0 or room:GetType() ~= RoomType.ROOM_CHALLENGE) and room:GetType() ~= RoomType.ROOM_BOSSRUSH and room:GetType() ~= RoomType.ROOM_ARCADE and room:GetType() ~= RoomType.ROOM_ISAACS) 
            and Game().Challenge == Challenge.CHALLENGE_NULL and (not GODMODE.is_at_palace or not GODMODE.is_at_palace()) and GODMODE.save_manager.get_config("CallOfTheVoid","false") == "true" 
            and Game().Difficulty == Difficulty.DIFFICULTY_HARD and Game():GetLevel():GetAbsoluteStage() <= LevelStage.STAGE5) or (Game().Challenge == Isaac.GetChallengeIdByName("Out Of Time")))
            and GODMODE.save_manager.get_data("VoidSpawned","false") ~= "true" and (ModConfigMenu == nil or not ModConfigMenu.IsVisible) and not GODMODE.is_in_secrets() and not room:HasCurseMist()
end

util.is_cotv_spawned = function()
	return GODMODE.save_manager.get_data("VoidSpawned","false") == "true"
end

util.get_cotv_counter_pos = function()
	if util.cotv_pos == nil then 
		util.cotv_pos = util.get_center_of_screen()
		util.cotv_pos.X = util.cotv_pos.X * tonumber(GODMODE.save_manager.get_config("COTVDisplayX","0.5"))
		util.cotv_pos.Y = util.cotv_pos.Y * tonumber(GODMODE.save_manager.get_config("COTVDisplayY","0.1"))
	end 

	return util.cotv_pos
end

util.modify_stat = function(player, cache, amt, mult)
	mult = mult or false
	if mult then 
		if cache == CacheFlag.CACHE_DAMAGE then 
			player.Damage = player.Damage * amt
		elseif cache == CacheFlag.CACHE_FIREDELAY then 
			player.MaxFireDelay = player.MaxFireDelay * 1/amt
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
			player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,amt)
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

return util