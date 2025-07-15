local monster = {}
-- monster.data gets updated every callback
monster.name = "Furnace Bubble"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
--monster.subtype = 0 --deobfuscated
--monster.subtype_sensitive = false --deobfuscated

monster.postUpdate = function(self)
end
monster.npcUpdate = function(self, ent)
	local data = self.data
    --When the entity first spawns, play the idle animation.
    if data.OriPos == nil then
        ent.SplatColor = Color(0,0,0,0,255,255,255)
        data.OriPos = ent.Position
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
    else
        ent:GetSprite():Play("Grow",false)
        ent.Position = data.OriPos
        ent.Velocity = Vector(0,0)
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

        if ent:GetSprite():IsEventTriggered("Burst") then
            ent:Kill()
            Isaac.Explode(ent.Position,ent,30.0)
        end
    end
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