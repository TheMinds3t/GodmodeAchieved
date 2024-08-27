local monster = {}
monster.name = "Ivory Portal"
monster.type = GODMODE.registry.entities.ivory_portal.type
monster.variant = GODMODE.registry.entities.ivory_portal.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        if GODMODE.is_at_palace and (not GODMODE.is_at_palace() or GODMODE.room:GetType() == RoomType.ROOM_ERROR) and ent.SubType == 0 then 
            data.persistent_state = GODMODE.persistent_state.single_room
        end

        ent.SplatColor = Color(0,0,0,0,255,255,255)
        if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
            ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
        end
    end
end

monster.npc_update = function(self, ent, data, sprite)
    sprite:Play("Idle",false)
    local player = Isaac.GetPlayer(0)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    ent.Velocity = (GODMODE.room:GetGridPosition(GODMODE.room:GetGridIndex(ent.Position))) - ent.Position
    
    if ent.SubType == 1 and data.player ~= nil then 

        if data.player:IsExtraAnimationFinished() then 
            Isaac.ExecuteCommand("goto s.barren.550")
            ent:Remove()    
        else 
            data.player.Velocity = ent.Position - data.player.Position
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end
    end
end

monster.npc_collide = function(self, ent, ent2, entfirst)
    if ent2:ToPlayer() then
        ent2 = ent2:ToPlayer()
        if ent.SubType == 0 then -- ivory portal
            ent2:PlayExtraAnimation("LightTravel")
            if GODMODE.is_at_palace and GODMODE.is_at_palace() ~= true then --teleport to ivory palace
                if GODMODE.transition_to_palace then
                    GODMODE.transition_to_palace()
                    ent:Remove()
                end
            elseif StageAPI and StageAPI.Loaded and StageAPI.GetCurrentStage ~= nil then  
                if GODMODE.is_at_palace and GODMODE.is_at_palace() == true then
                    local rt = GODMODE.room:GetType()
                    if rt == RoomType.ROOM_BOSS then -- teleport to FL fight
                        Isaac.ExecuteCommand("croom 1000 IvoryPalace-General")
                        StageAPI.PlayBossAnimation(StageAPI.GetBossData("IvoryPalace_Angelusossa"))
                        local pos = GODMODE.room:GetCenterPos()+Vector(0,96)
                        GODMODE.util.macro_on_players(function(player)
                            player.Position = pos
                        end)         
                    elseif rt == RoomType.ROOM_ERROR then --teleport to previous room
                        GODMODE.game:StartRoomTransition(GODMODE.level:GetPreviousRoomIndex(), Direction.NO_DIRECTION, RoomTransitionAnim.FADE)
                    end
                end
            end    
        elseif ent.SubType == 1 and ent2:IsExtraAnimationFinished() then -- correction portal
            ent2:PlayExtraAnimation("Trapdoor")
            ent2.Position = ent.Position
            GODMODE.get_ent_data(ent).player = ent2
        end
    end
end

return monster