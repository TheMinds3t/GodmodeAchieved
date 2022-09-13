local item = {}
item.instance = Isaac.GetItemIdByName( "Impending Doom" )
item.eid_description = "#↑ Deals 10 damage or 25% of max health to all enemies in the room, whichever is greater #↓ +1 Broken heart at the start of each floor"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "On use, deals the equivalent of either 25% of an enemy's max health or 10 damage, whichever is larger"},
      {str = "Taking this item to a new floor grants the holder a broken heart."},
    },
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then 
		local amt = 0.25
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then amt = 0.175 end
		for _,ent in ipairs(Isaac.GetRoomEntities()) do
			if ent:IsVulnerableEnemy() then
				ent:TakeDamage(math.max(10,ent.MaxHitPoints * amt), DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(player), 1)

				for i=0,8 do 
					Isaac.Spawn(EntityType.ENTITY_EFFECT, 5, 0, ent.Position, ent.Velocity * 2 + Vector(rng:RandomFloat()*4-2,rng:RandomFloat()*4-2),ent)
				end
			end
		end

		Game():ShakeScreen(20)

		return true
	end
end

item.new_level = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
		player:AddBrokenHearts(1)
	end)
end

return item