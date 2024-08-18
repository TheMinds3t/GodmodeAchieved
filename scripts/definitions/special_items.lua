local ret = {}

ret.fill_item_lists = function(self)
	self.quality_lists = {}
	self.quality_sizes = {}
	self.book_list = {}
	self.bob_list = {}
	self.syringe_list = {}
	self.cache_list = {}

	for i=1,CollectibleType.NUM_COLLECTIBLES do
		local config = Isaac.GetItemConfig():GetCollectible(i)

		if config and config:IsCollectible() and not config.Hidden then
			if config.Tags & ItemConfig.TAG_BOOK == ItemConfig.TAG_BOOK then
				table.insert(self.book_list, config)
			end

			if config.Tags & ItemConfig.TAG_BOB == ItemConfig.TAG_BOB then
				table.insert(self.bob_list, config)
			end

			if config.Tags & ItemConfig.TAG_SYRINGE == ItemConfig.TAG_SYRINGE then
				table.insert(self.syringe_list, config)
			end

			if config.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST then 
				for i=1,16 do 
					local flag = (1 << i) >> 1
					if config.CacheFlags & flag == flag then 
						self.cache_list[flag] = self.cache_list[flag] or {}
						table.insert(self.cache_list[flag], config)
					end
				end	
			end

			self.quality_lists[config.Quality] = self.quality_lists[config.Quality] or {}
			self.quality_sizes[config.Quality] = (self.quality_sizes[config.Quality] or 0) + 1
			
			table.insert(self.quality_lists[config.Quality], config)
		end
	end
end

ret.get_item_with_cache = function(self, cache, rng, locked_allowed)
	locked_allowed = GODMODE.validate_rgon() and locked_allowed or GODMODE.validate_rgon() and false or true --achievement checks are repentogon exclusive
	if self.cache_list[cache] == nil then 
		GODMODE.log("cache list \'"..cache.."\' does not exist, valid ones are:")
		for list,_ in pairs(self.cache_list) do 
			GODMODE.log("\t"..list,true)
		end
		return nil
	else 
		local item = self.cache_list[cache][rng:RandomInt(#self.cache_list[cache]) + 1]
		if locked_allowed then 
			return item.ID
		else
			local depth = 20
			local pred = function() return Isaac.GetPersistentGameData():Unlocked(item.AchievementID) end 
			
			while depth > 0 and pred() == false do 
				item = self.cache_list[cache][rng:RandomInt(#self.cache_list[cache]) + 1]
				depth = depth - 1
			end

			return item 
		end
	end
end

ret.get_book_item = function(self,rng)
	rng = rng or GODMODE.util.rng
	if self.book_list ~= nil then
		return self.book_list[rng:RandomInt(#self.book_list)+1].ID
	else
		return CollectibleType.COLLECTIBLE_BIBLE
	end
end

ret.get_bob_item = function(self,rng)
	rng = rng or GODMODE.util.rng
	if self.bob_list ~= nil then
		return self.bob_list[rng:RandomInt(#self.bob_list)+1].ID
	else
		return CollectibleType.COLLECTIBLE_BOBS_BRAIN
	end
end

ret.get_syringe_item = function(self,rng)
	rng = rng or GODMODE.util.rng
	if self.syringe_list ~= nil then
		return self.syringe_list[rng:RandomInt(#self.syringe_list)+1].ID
	else
		return CollectibleType.COLLECTIBLE_ROID_RAGE
	end
end

ret.get_item_of_quality = function(self,quality,rng)
	rng = rng or GODMODE.util.rng
	if self.quality_lists == nil then 
		self:fill_item_lists()
	end
	if self.quality_lists ~= nil and self.quality_lists[quality] ~= nil then
		return self.quality_lists[quality][rng:RandomInt(self.quality_sizes[quality])+1].ID
	end
end

return ret