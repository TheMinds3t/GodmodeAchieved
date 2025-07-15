local monster = {}
-- monster.data gets updated every callback
monster.name = "Ivory Palace"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
--monster.subtype = 0 --deobfuscated
--monster.subtype_sensitive = false --deobfuscated

monster.postUpdate = function(self)
end
monster.npcUpdate = function(self, ent)
	local data = self.data
    if ent.SubType == 0 then
        ent.Position = GODMODE.room:GetTopLeftPos()-Vector(80,80)
    elseif ent.SubType == 1 then
        ent.Position = GODMODE.room:GetTopLeftPos()-Vector(80,12)+Vector(0,156)
    elseif ent.SubType == 2 then
        local v = Vector(GODMODE.room:GetBottomRightPos().X+84,GODMODE.room:GetTopLeftPos().Y-12)+Vector(0,156)
        ent.Position = v
    elseif ent.SubType == 3 then
        local v = Vector(GODMODE.room:GetTopLeftPos().X-80,GODMODE.room:GetBottomRightPos().Y+80)
        ent.Position = v
    elseif ent.SubType == 4 then
        local v = Vector(GODMODE.room:GetBottomRightPos().X+84,GODMODE.room:GetBottomRightPos().Y+80)
        ent.Position = v
    end
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    if ent.SubType == 0 then
        ent.RenderZOffset = 500
    end
    if ent.SubType > 0 then
        ent.Position = ent.Position + Vector(0,4)
        ent.RenderZOffset = 10
        sprite:Play(getIvoryPalaceAnimName(ent),false)
    else
        sprite:Play(getIvoryPalaceAnimName(ent),false)
    end

    if data.time == 2 then
        for i=1,GODMODE.room:GetGridSize() do
            if GODMODE.room:GetGridEntity(i) and not GODMODE.room:GetGridEntity(i):ToDoor() then
                GODMODE.room:DestroyGrid(i,true)
            end
        end
    end

    if GODMODE.room:GetType() == RoomType.ROOM_BOSS then
        if data.time == 2 then
            local flag = false
            for i=1,#Isaac.GetRoomEntities() do 
                local e = Isaac.GetRoomEntities()[i]
                if e and e.Type == EntityType.ENTITY_ISAAC then flag = true end
            end

            data.hasBeaten = not flag
        end
        if data.hasBeaten then
        elseif not GODMODE.room:IsClear() then
            local v = math.min(data.time, 255)
            if v == 200 then
                for i=1,#Isaac.GetRoomEntities() do 
                    local e = Isaac.GetRoomEntities()[i]
                    if e and e.Type == EntityType.ENTITY_ISAAC then e:Kill() end
                end

                if ent.SubType == 0 then
                    GODMODE.game:Spawn(800, 140, GODMODE.room:GetCenterPos(), Vector(0,0), player, 0, player.InitSeed)
                end
            end
            local a = 1
            if ent.SubType > 0 then a = 1.0 - (v)/255.0*2.0 end
            ent:SetColor(Color(1.0 - (v)/255.0,1.0 - (v)/255.0,1.0 - (v)/255.0,a,-v,-v,-v),2,9999,true,true)
        else
            if not data.complete_anim then data.complete_anim = 255 end
            local v = math.max(data.complete_anim, 0)
            local a = 1
            if ent.SubType > 0 then a = 1.0 - (v)/255.0*2.0 end
            ent:SetColor(Color(1.0 - (v)/255.0,1.0 - (v)/255.0,1.0 - (v)/255.0,a,-v,-v,-v),2,9999,true,true)
            data.complete_anim = data.complete_anim - 1
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