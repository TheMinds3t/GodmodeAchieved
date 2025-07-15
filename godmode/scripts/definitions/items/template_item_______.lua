local item = {}
item.instance = Isaac.GetItemIdByName( "Morphine" )
item.getCache = function(self, player, cacheFlag)
end
item.postUpdate = function(self)
end
item.npcUpdate = function(self, npc)
end
item.postRender = function(self)
end
item.useItem = function(self, coll, rng)
	local player = Isaac.GetPlayer(0)
end
item.postPlEval = function(self, player)
end
item.useCard = function(self, card)
end
item.famUpdate = function(self, fam)
end
item.famInit = function(self, fam)
end
item.usePill = function(self, pill)
end
item.entityDamaged = function(self,enthit,amount,flags,entsrc,countdown)
end
item.postRoomCleared = function(self)
end
item.newRoom = function(self)
end
item.newLevel = function(self)
end
item.postTearFired = function(self, tear, player)
end
item.postTearUpdate = function(self, tear)
end
item.postPickupInit = function(self, pickup)
end
item.postEffectInit = function(self, effect)
end
item.writeData = function(self, data_func) --(key,value)
end
item.readData = function(self, data_func) --(key,default)
end
item.resetData = function(self)
end
return item