local item = {}
item.instance = Isaac.GetItemIdByName( "Feather Duster" )
item.eid_description = "+0.1 Speed#Prevents negative door hazards from occurring#Walking over a web breaks it"
-- item.eid_transforms = GODMODE.util.eid_transforms.BOB
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "+0.1 movement speed."},
      {str = "Prevents negative door hazards from spawning."},
      {str = "Walking over webs will break the web beneath you."},
    },
}

item.eval_cache = function(self, player,cache)
	if cache == CacheFlag.CACHE_SPEED then 
		player.MoveSpeed = player.MoveSpeed + 0.1 * player:GetCollectibleNum(item.instance)
	end
end

item.player_update = function(self, player)
	if player:HasCollectible(item.instance) then
		if not player:IsDead() and player:IsFrame(1,10) and player:HasEntityFlags(EntityFlag.FLAG_SLOW) then
			local grid = Game():GetRoom():GetGridEntityFromPos(player.Position)
			
			if grid ~= nil and grid:GetType() == GridEntityType.GRID_SPIDERWEB and grid.State ~= 1 then 
				local pos = Game():GetRoom():GetGridPosition(Game():GetRoom():GetGridIndex(player.Position))
				local dust = Isaac.Spawn(Isaac.GetEntityTypeByName("Feather Dust"),Isaac.GetEntityVariantByName("Feather Dust"),1,pos,Vector.Zero,nil)
				dust.DepthOffset = 100
				dust:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				grid:Destroy()
				local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.DUST_CLOUD,0,pos,Vector.Zero,nil):ToEffect()
				cloud:SetTimeout(100)
			end
		end
	end
end

return item