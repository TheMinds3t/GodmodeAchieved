local monster = {}
-- monster.data gets updated every callback
monster.name = ""
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
--monster.subtype = 0 --deobfuscated
--monster.subtype_sensitive = false --deobfuscated

monster.data_init = function(self, ent, data)
end
monster.npcUpdate = function(self, ent)
	local data = self.data
	local player = Isaac.GetPlayer(0)
end
monster.renderEnt = function(self, ent, offset)
end
monster.entityDamaged = function(self,enthit,amount,flags,entsrc,countdown)
	return true
end
monster.entityKilled = function(self, ent)
end
-- There are a lot of functionless callbacks in all older enemies because I used the template_item lua class as a basis for this before I updated this one to be smoother. 
return monster