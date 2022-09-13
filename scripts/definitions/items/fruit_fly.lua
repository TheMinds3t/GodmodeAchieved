local item = {}
item.instance = Isaac.GetItemIdByName( "Fruit Flies" )
item.eid_description = "Summons 3 Fruit Flies to grow with you#On room clear, stacking 3% chance to explode into a random fruit and a new one to spawn"
item.eid_transforms = GODMODE.util.eid_transforms.CONJOINED
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "Spawns 3 Fruit Flies when taken."},
      {str = "A familiar that has a stacking 3% chance to explode into a random fruit while awake."},
      {str = "When the Fruit Fly dies, another one will spawn asleep for 3 rooms"},
    },
}

item.eval_cache = function(self,player,cache)
  if cache == CacheFlag.CACHE_FAMILIARS then 
    player:CheckFamiliar(Isaac.GetEntityVariantByName("Fruit Fly"), player:GetCollectibleNum(item.instance)*3, player:GetCollectibleRNG(item.instance), Isaac.GetItemConfig():GetCollectible(item.instance))
  end
end

-- item.player_update = function(self,player)
-- end

return item