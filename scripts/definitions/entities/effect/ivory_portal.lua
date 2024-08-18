local monster = {}
monster.name = "Ivory Portal"
monster.type = GODMODE.registry.entities.ivory_portal.type
monster.variant = GODMODE.registry.entities.ivory_portal.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        if GODMODE.is_at_palace and not GODMODE.is_at_palace() then 
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
end

monster.npc_collide = function(self, ent, ent2, entfirst)
    if ent2:ToPlayer() then
        ent2:ToPlayer():PlayExtraAnimation("LightTravel")
        if GODMODE.is_at_palace and GODMODE.is_at_palace() ~= true then
            if GODMODE.transition_to_palace then
                GODMODE.transition_to_palace()
                ent:Remove()
            end
        elseif StageAPI and StageAPI.Loaded and StageAPI.GetCurrentStage ~= nil then  
            Isaac.ExecuteCommand("croom 1000 IvoryPalace-General")
            StageAPI.PlayBossAnimation(StageAPI.GetBossData("IvoryPalace_Angelusossa"))
            local pos = GODMODE.room:GetCenterPos()+Vector(0,96)
            GODMODE.util.macro_on_players(function(player)
                player.Position = pos
            end)
        end
    end
end

return monster