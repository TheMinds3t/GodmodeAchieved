local monster = {}
monster.name = "Ivory Portal"
monster.type = GODMODE.registry.entities.ivory_portal.type
monster.variant = GODMODE.registry.entities.ivory_portal.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        if ent.SubType == 0 
            or ent.SubType == 1 and GODMODE.util.total_item_count(GODMODE.registry.trinkets.bone_feather, true) > 0 then 
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
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
    ent.Velocity = (GODMODE.room:GetGridPosition(GODMODE.room:GetGridIndex(ent.Position))) - ent.Position
    
    if ent.SubType == 1 then 
        if ent:IsFrame(2,1) then 
            local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, ent.Position+RandomVector():Resized(ent:GetDropRNG():RandomFloat() * ent.Size) * Vector(1,1.25), Vector.Zero, nil):ToEffect()
            fx:SetTimeout(10)
            fx.LifeSpan = 20
            fx.Scale = ent:GetDropRNG():RandomFloat() * 0.5 + 1.0
            fx:SetColor(Color(0,0,0,0.25),999,1,false,false)
            fx.DepthOffset = -100
        end

        if data.player ~= nil then 
            if data.player:IsExtraAnimationFinished() then 
                Isaac.ExecuteCommand("goto s.barren.550")
                ent:Remove()    
            else 
                data.player.Velocity = ent.Position - data.player.Position
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            end    
        end
    end
end

monster.npc_collide = function(self, ent, ent2, entfirst)
    if ent2:ToPlayer() then
        ent2 = ent2:ToPlayer()
        if ent.SubType == 0 then -- ivory portal
            ent2:PlayExtraAnimation("LightTravel")
            local player2 = ent2:GetSubPlayer() or ent2:GetMainTwin() or ent2:GetOtherTwin()
            if GetPtrHash(player2) == GetPtrHash(ent2) then player2 = ent2:GetOtherTwin() or ent2:GetMainTwin() or ent2:GetSubPlayer() end 
            
            if player2 ~= nil then 
                player2:PlayExtraAnimation("LightTravel")
            end
            
            if GODMODE.is_at_palace and GODMODE.is_at_palace() ~= true then --teleport to ivory palace
                if GODMODE.transition_to_palace then
                    GODMODE.transition_to_palace()
                    ent:Remove()
                end
            elseif StageAPI and StageAPI.Loaded and StageAPI.GetCurrentStage ~= nil then  
                if GODMODE.is_at_palace and GODMODE.is_at_palace() == true then
                    local rt = (GODMODE.room_type or GODMODE.room:GetType())

                    if rt == RoomType.ROOM_ERROR then --teleport to previous room
                        GODMODE.log("escape palace error!")
                        GODMODE.game:StartRoomTransition(GODMODE.level:GetPreviousRoomIndex(), Direction.NO_DIRECTION, RoomTransitionAnim.FADE)
                    else -- teleport to FL fight
                        GODMODE.log("enter palace boss!")
                        Isaac.ExecuteCommand("croom 1000 IvoryPalace-General")
                        StageAPI.PlayBossAnimation(StageAPI.GetBossData("IvoryPalace_Angelusossa"))
                        local pos = (GODMODE.room_center or GODMODE.room:GetCenterPos())+Vector(0,96)
                        GODMODE.util.macro_on_players(function(player)
                            player.Position = pos
                        end)
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