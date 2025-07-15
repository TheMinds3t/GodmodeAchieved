local monster = {}
monster.name = "Ivory Portal"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, params)
    if GODMODE.is_at_palace and not GODMODE.is_at_palace() then 
        params[2].persistent_state = GODMODE.persistent_state.single_room
    end

    params[1].SplatColor = Color(0,0,0,0,255,255,255)
    params[1]:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )        
end

monster.npc_update = function(self, ent)
	local data = GODMODE.get_ent_data(ent)
    ent:GetSprite():Play("Idle",false)
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
        elseif StageAPI then  
            Isaac.ExecuteCommand("croom 1000")
            StageAPI.PlayBossAnimation(StageAPI.GetBossData("IvoryPalace_Angelusossa"))
            local pos = Game():GetRoom():GetCenterPos()+Vector(0,96)
            GODMODE.util.macro_on_players(function(player)
                player.Position = pos
            end)
        end
    end
end

return monster