local item = {}
item.instance = Isaac.GetItemIdByName( "Devil's Food" )
item.eid_description = "+2 Black Hearts#↑ +1 Damage"
item.binge_eid_description = "+2 Black Hearts#↑ +1 Damage#↑ +0.2 Shot Speed"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - Adds two black hearts."},
      {str = " - +1 damage."},
    },
    { -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
	  {str = "Additionally gives +0.2 shot speed if Binge Eater is held."}
    },
}

item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end


	if cache == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + player:GetCollectibleNum(item.instance)
	end

	if player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) and cache == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed + 0.2 * player:GetCollectibleNum(item.instance)
	end
end

if EID and EID.addCollectible then
	item.player_update = function(self,player)
		if player:HasCollectible(item.instance) then
			local count = GODMODE.util.count_enemies(nil, EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,item.instance)

			if count > 0 and #GODMODE.util.does_player_have(CollectibleType.COLLECTIBLE_BINGE_EATER) > 0 then
				EID:addCollectible(item.instance,self.binge_eid_description)	
			else
				EID:addCollectible(item.instance,self.eid_description)	
			end
		end
	end
end


return item