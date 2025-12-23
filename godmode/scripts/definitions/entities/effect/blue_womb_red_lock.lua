local monster = {}
monster.name = "[GODMODE] Door Hazard"
monster.type = GODMODE.registry.entities.blue_womb_red_lock.type
monster.variant = GODMODE.registry.entities.blue_womb_red_lock.variant


monster.data_init = function(self, ent,data)
    -- data.persistent_state = GODMODE.persistent_state.single_room
end

monster.clear_anims = {
    [true] = function(sprite, anim, finished, first_visit) 
        if not first_visit then return "Opened", false end 

        if anim == "Closed" or anim == "Close" or anim == "default" then 
            return "Open", true
        elseif anim == "Open" and not finished then 
            return "Open", false
        end

        return "Opened", false 
    end, 
    [false] = function(sprite, anim, finished, first_visit) 
        if anim == "Opened" or anim == "Open" or anim == "default" then 
            return "Close", true
        elseif anim == "Close" and not finished then 
            return "Close", false
        end

        return "Closed", false 
    end 
}

monster.doorslots = {
    [DoorSlot.LEFT0] = Vector(-5,-1),
    [DoorSlot.UP0] = Vector(1,-5),
    [DoorSlot.DOWN0] = Vector(-1,5),
    [DoorSlot.RIGHT0] = Vector(5,1),
}

monster.npc_update = function(self, ent, data, sprite)
    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.Velocity = Vector.Zero

    if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
        ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
    end

    local clear_flag = GODMODE.room:IsClear()
    local cur_anim = sprite:GetAnimation()
    ent.EntityCollisionClass = clear_flag and EntityCollisionClass.ENTCOLL_NONE or EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
    ent.DepthOffset = -99 

    --i1 = DoorSlot.
    if ent.I1 > 0 then 
        if GODMODE.room:IsDoorSlotAllowed(ent.I1-1) then 
            local door_pos = GODMODE.room:GetDoorSlotPosition(ent.I1-1)
            local ang = math.floor(((GODMODE.room_center or GODMODE.room:GetCenterPos()) - door_pos):GetAngleDegrees()/90)*90
            ent.Position = door_pos
            ent.SpriteRotation = ((ent.I1-1)%4)*90-90
        end

        if monster.doorslots[ent.I1 - 1] then 
            ent.SpriteOffset = monster.doorslots[ent.I1 - 1]
        end
    end

    local anim, reset_anim = monster.clear_anims[clear_flag](sprite, cur_anim, sprite:IsFinished(cur_anim), GODMODE.room:IsFirstVisit())
    if not sprite:IsPlaying(anim) then 
        sprite:Play(anim,reset_anim)
    end
end

monster.player_collide = function(self,player,ent,entfirst)
    if entfirst and ent.SubType == 0 then
        return false
    end
end

monster.new_room = function()
    local room_desc = GODMODE.level:GetCurrentRoomDesc()
    local first_visit = GODMODE.room:IsFirstVisit()
    local room_clear = GODMODE.room:IsClear()
    local red_room = room_desc.Flags & RoomDescriptor.FLAG_RED_ROOM == RoomDescriptor.FLAG_RED_ROOM
    local room_type = GODMODE.room:GetType()

    if GODMODE.level:GetStage() == LevelStage.STAGE4_3 
        and ((red_room and room_type == RoomType.ROOM_DEFAULT) or (not red_room and room_type == RoomType.ROOM_TREASURE)) then 

        for slot=0,DoorSlot.NUM_DOOR_SLOTS do 
            local slot_pos = GODMODE.room:GetDoorSlotPosition(slot)
            local door_ent = GODMODE.room:GetGridEntityFromPos(slot_pos) and GODMODE.room:GetGridEntityFromPos(slot_pos):ToDoor() or nil

            if GODMODE.room:IsDoorSlotAllowed(slot) and door_ent then 
                local door_pos = GODMODE.room:GetDoorSlotPosition(slot)
                local ang = math.floor(((GODMODE.room_center or GODMODE.room:GetCenterPos()) - door_pos):GetAngleDegrees()/90)*90
                local ent = Isaac.Spawn(monster.type, monster.variant, 0, door_pos, Vector.Zero, nil)
                ent = ent:ToNPC()

                if first_visit then 
                    ent:GetSprite(room_clear and "Open" or "Close", true)
                else 
                    ent:GetSprite(room_clear and "Opened" or "Close", true)
                end

                ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                ent:Update()
                ent.I1 = slot + 1
            end 
        end
    end
end


return monster