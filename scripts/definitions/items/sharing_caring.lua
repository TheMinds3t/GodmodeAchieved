local item = {}
item.instance = Isaac.GetItemIdByName( "Sharing is Caring" )
item.eid_description = "↑ All familiars operate 33% faster"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Causes all familiars to move faster or effectively work 33% faster, depending on what is most effective for the familiar."},
		{str = "Currently does nothing for orbital familiars."},
	},
}

local blacklist = {
	[FamiliarVariant.BBF] = true,
	[FamiliarVariant.INCUBUS] = true
}
item.familiar_update = function(self, fam)
	if fam and fam.Player and fam.Player:HasCollectible(item.instance) then
		fam:GetSprite().PlaybackSpeed = 1.333--0.66
		local data = GODMODE.get_ent_data(fam)
		if not data.alt_up then
			data.alt_up = 0
			fam:MultiplyFriction(1.2)
		end
		data.alt_up = data.alt_up + 1

		if data.alt_up > 2 then
			data.alt_up = 0

			if fam.OrbitDistance.X + fam.OrbitDistance.Y == 0 then
				if fam.Variant == FamiliarVariant.SUCCUBUS then
					fam.Velocity = fam.Velocity * 1.25
				else
					fam:Update()
				end
				
				if fam.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) then
					fam.SpriteScale = fam.SpriteScale * 0.8
				end
			end
		end

		if fam.Variant == FamiliarVariant.BLOOD_BABY then 
			fam.Velocity = fam.Velocity * 0.95
		end

	end
end


return item