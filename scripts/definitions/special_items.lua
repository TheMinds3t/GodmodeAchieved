local ret = {}

ret.fill_item_lists = function(self)
	self.quality_lists = {}
	self.quality_sizes = {}
	self.book_list = {}
	self.bob_list = {}

	for i=1,CollectibleType.NUM_COLLECTIBLES do
		local config = Isaac.GetItemConfig():GetCollectible(i)

		if config and config:IsCollectible() and not config.Hidden then
			if config.Tags & ItemConfig.TAG_BOOK == ItemConfig.TAG_BOOK then
				table.insert(self.book_list, config)
			end
			if config.Tags & ItemConfig.TAG_BOB == ItemConfig.TAG_BOB then
				table.insert(self.bob_list, config)
			end

			self.quality_lists[config.Quality] = self.quality_lists[config.Quality] or {}
			self.quality_sizes[config.Quality] = (self.quality_sizes[config.Quality] or 0) + 1
			
			table.insert(self.quality_lists[config.Quality], config)
		end
	end
end

ret.get_book_item = function(self)
	if self.book_list ~= nil then
		return self.book_list[GODMODE.util.random(1,#ret.book_list)].ID
	else
		return CollectibleType.COLLECTIBLE_BIBLE
	end
end

ret.get_bob_item = function(self)
	if self.bob_list ~= nil then
		return self.bob_list[GODMODE.util.random(1,#self.bob_list)].ID
	else
		return CollectibleType.COLLECTIBLE_BOBS_BRAIN
	end
end

ret.get_item_of_quality = function(self,quality)
	if self.quality_lists == nil then 
		self:fill_item_lists()
	end
	if self.quality_lists ~= nil and self.quality_lists[quality] ~= nil then
		return self.quality_lists[quality][GODMODE.util.random(1,self.quality_sizes[quality])].ID
	end
end

return ret