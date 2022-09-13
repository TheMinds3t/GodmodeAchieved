local item = {}
item.instance = Isaac.GetItemIdByName( "Heart Arrest" )
item.eid_description = "↑ Tears up#Fire tears in a heartbeat pattern#↑ Tears additionally goes up as red health gets emptier"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Your tears fire in an alternating pattern of 1/3 your current tears to 7/4 of your current tears, effectively raising the tears cap between the two tears."},
		{str = "If you have red health, similar to Adrenaline, the larger delay will be shortened to your current tears when all red hearts are empty."},
	},
}

local tear_shifts = {
	[TearVariant.BLUE] = TearVariant.BLOOD,
	[TearVariant.CUPID_BLUE] = TearVariant.CUPID_BLOOD,
	[TearVariant.NAIL] = TearVariant.NAIL_BLOOD,
	[TearVariant.GODS_FLESH] = TearVariant.GODS_FLESH_BLOOD,
	[TearVariant.PUPULA] = TearVariant.PUPULA_BLOOD,
	[TearVariant.GLAUCOMA] = TearVariant.GLAUCOMA_BLOOD,
	[TearVariant.KEY] = TearVariant.KEY_BLOOD,
	[TearVariant.EYE] = TearVariant.EYE_BLOOD,
}

item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.25*player:GetCollectibleNum(item.instance))
	end
end

item.tear_init = function(self, tear)
	if tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer() and tear.SpawnerEntity:ToPlayer():HasCollectible(item.instance) then
		if tear_shifts[tear.Variant] ~= nil then 
			tear:ChangeVariant(tear_shifts[tear.Variant])
		end

		tear.ParentOffset = tear.ParentOffset + Vector(0, 8)
	end
end

item.tear_fire = function(self, tear)
	if tear.SpawnerEntity ~= nil and tear.SpawnerEntity:ToPlayer() and tear.SpawnerEntity:ToPlayer():HasCollectible(item.instance) then
		local player = tear.SpawnerEntity:ToPlayer()
		local dat = GODMODE.get_ent_data(player)
		local scale = 1
		if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then scale = 0.5 dat.toggle = dat.toggle or 0.5 end
		if not dat.toggle or dat.toggle >= 1 then
			dat.toggle = 0
			player.FireDelay = math.floor(player.MaxFireDelay / 3)
		else
			dat.toggle = dat.toggle + scale
			player.FireDelay = player.MaxFireDelay * (1.75 - (0.75 - (0.75 * player:GetHearts() / player:GetMaxHearts())))
		end
		--GODMODE.log(tostring(dat.toggle).."tear: "..player.FireDelay,true)
	end
end

return item