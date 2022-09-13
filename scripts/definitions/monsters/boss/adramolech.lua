local monster = {}
-- monster.data gets updated every callback
monster.name = "Adramelech"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
--monster.subtype = 0 --deobfuscated
--monster.subtype_sensitive = false --deobfuscated

monster.postUpdate = function(self)
end
monster.npcUpdate = function(self, ent)
	local data = self.data
	local player = Isaac.GetPlayer(0)
    ent.Velocity = Vector(0,0)
    --When the entity first spawns, play the idle animation.
    if ent.FrameCount == 1 then
        ent:GetSprite():Play("Attack",true)
    end

    ent.Position = Vector(ent.Position.X+25.5,Game():GetRoom():GetTopLeftPos().Y+5*51)
end
monster.postRender = function(self)
end
monster.entityDamaged = function(self,enthit,amount,flags,entsrc,countdown)
end
monster.postRoomCleared = function(self)
end
monster.newRoom = function(self)
end
monster.newLevel = function(self)
end
return monster