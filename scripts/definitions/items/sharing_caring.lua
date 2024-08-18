local item = {}
item.instance = GODMODE.registry.items.sharing_is_caring
item.eid_description = "↑ All familiars operate 33% faster"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Causes all familiars to move faster or effectively work 33% faster, depending on what is most effective for the familiar."},
		{str = "Currently does nothing for orbital familiars."},
	},
}

local blacklist = { -- currently unused
	[FamiliarVariant.BBF] = true,
	[FamiliarVariant.INCUBUS] = true
}
item.familiar_update = function(self, fam, data)
	if fam and fam.Player and fam.Player:HasCollectible(item.instance) and data then
		fam:GetSprite().PlaybackSpeed = 1.333--0.66
		if not data.alt_up then
			data.alt_up = 0
			fam:MultiplyFriction(1.2)
		end
		data.alt_up = data.alt_up + 1

		if data.alt_up > 2 then
			data.alt_up = 0

			if fam.OrbitDistance.X + fam.OrbitDistance.Y == 0 then
				local old_scale = fam.SpriteScale:Length()
				if fam.Variant == FamiliarVariant.SUCCUBUS then
					fam.Velocity = fam.Velocity * 1.25
				else
					fam:Update()
				end
				
				if fam.SpriteScale:Length() ~= old_scale then 
					fam.SpriteScale = fam.SpriteScale * 0.8
				end
				-- if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) or fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then
				-- end
			end
		end

		if fam.Variant == FamiliarVariant.BLOOD_BABY then 
			fam.Velocity = fam.Velocity * 0.95
		end

	end
end


return item