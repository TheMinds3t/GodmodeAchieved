local item = {}
item.instance = Isaac.GetItemIdByName( "Crown of Gold" )
item.eid_description = "↑ Midas freeze an enemy for 7.5 seconds when entering a room #↑ +1 luck for every 25 coins, up to +3.0 luck at 99 coins#↓ Drop (5*damage-(1 to 3)) coins on taking damage"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "One enemy is selected when entering a room to be midas frozen for 7.5 seconds"},
		{str = "+1 luck for every 25 coins held"},
		{str = "Lose either 10 coins or 5 x damage taken, whichever is higher, whenever you take damage"},
	},
}

item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end
	local am = math.floor(player:GetNumCoins()/25)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) and player:GetNumCoins() > 99 then 
		am = 4 + math.floor(player:GetNumCoins()/100)
	elseif player:GetNumCoins() == 99 then am = am+1 end

	if cache == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck + am * player:GetCollectibleNum(item.instance)
	end
end

item.player_update = function(self,player)
	if player:HasCollectible(item.instance) then
		if Isaac.GetFrameCount() % 60 == 10 then 
			player:AddCacheFlags(CacheFlag.CACHE_LUCK)
			player:EvaluateItems()
		end
	end
end

item.pickup_collide = function(self, pickup,ent,entfirst)
	if (pickup.Variant == PickupVariant.PICKUP_COIN or pickup.Variant == PickupVariant.PICKUP_SHOPITEM) and ent:ToPlayer() then
		local player = ent:ToPlayer()
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	end
end

item.new_room = function(self)
	local count = GODMODE.util.total_item_count(item.instance)

	if not Game():GetRoom():IsClear() and Isaac.GetPlayer():GetNumCoins() < 99 then
		local depth = count*25
		while count > 0 and depth > 0 do 
			local added = 0
			for _,ent in ipairs(Isaac.GetRoomEntities()) do 
				if not ent:HasEntityFlags(EntityFlag.FLAG_MIDAS_FREEZE) and ent:GetDropRNG():RandomFloat() < 0.1 and ent.MaxHitPoints > 0 and ent:IsVulnerableEnemy() then 
					if ent:IsBoss() then 
						ent:AddMidasFreeze(EntityRef(Isaac.GetPlayer()),30*5)
					else
						ent:AddMidasFreeze(EntityRef(Isaac.GetPlayer()),30*7.5)
					end
					added = added + 1

					if count - added <= 0 then break end
				end
			end

			if added > 0 then
				count = count - added
			end
			depth = depth - 1
		end
	end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)

	if enthit:ToPlayer() and enthit:ToPlayer():HasCollectible(item.instance) and flags & DamageFlag.DAMAGE_NO_PENALTIES ~= DamageFlag.DAMAGE_NO_PENALTIES then
		local player = enthit:ToPlayer()
		local coins = player:GetNumCoins()
		local co = math.min(player:GetCollectibleRNG(item.instance):RandomInt(2),coins)
		local coins_lost = math.min(10, amount*5)

		if player:GetName() == "Gehazi" and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
			co = co + 2*math.min(2,amount)
		end

		local sh = math.min(coins-co, coins_lost - co)
		player:AddCoins(-coins_lost)

		for i=1,co do
			Game():Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COIN,enthit.Position,Vector(player:GetCollectibleRNG(item.instance):RandomInt(10)-5,player:GetCollectibleRNG(item.instance):RandomInt(10)-5),enthit,1,enthit.InitSeed)
		end

		for i=1,sh do
			local coin = Game():Spawn(Isaac.GetEntityTypeByName("Shatter Coin"),Isaac.GetEntityVariantByName("Shatter Coin"),enthit.Position,Vector(player:GetCollectibleRNG(item.instance):RandomInt(10)-5,player:GetCollectibleRNG(item.instance):RandomInt(10)-5),enthit,0,enthit.InitSeed)
			coin:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			coin.Velocity = Vector(player:GetCollectibleRNG(item.instance):RandomInt(10)-5,player:GetCollectibleRNG(item.instance):RandomInt(10)-5)
		end
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	end
end


return item