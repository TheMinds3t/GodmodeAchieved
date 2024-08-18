local monster = {}
monster.name = "Correction FX"
monster.type = GODMODE.registry.entities.correction_fx.type
monster.variant = GODMODE.registry.entities.correction_fx.variant

local base_depth_off = 200
local depth_offsets = {
    [0] = -1000, --floor 
    [1] = -50, --background 
    [2] = -300, --carpet
    [3] = -500, --background
}

local anim_names = {
    [0] = "Floor",
    [1] = "Background",
    [2] = "Carpet",
    [3] = "Background",
}

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	

    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

    if ent:HasEntityFlags(EntityFlag.FLAG_APPEAR) then
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
            ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
        end
        sprite:Play(anim_names[ent.SubType],true)

        if ent.SubType == 0 then 
            ent.Visible = false 
        end
    end

    sprite.PlaybackSpeed = 2.0

    ent.DepthOffset = base_depth_off + depth_offsets[ent.SubType]
    ent.Velocity = Vector(0,0)
    ent.Position = GODMODE.room:GetCenterPos()

    if ent.SubType == 0 then 
        if data.active == true or ent.Visible == true then 
            ent.Visible = true 
        else 
            ent.Visible = false 
        end
    
        if not ent.Visible and (data.total_broken or 0) <= (data.base_broken or 1) then 
            data.total_broken = 0
    
            GODMODE.util.macro_on_players(function(player) 
                data.total_broken = data.total_broken + tonumber(GODMODE.save_manager.get_player_data(player,"FaithlessHearts","0"))
            end)
    
            data.base_broken = data.base_broken or data.total_broken
    
            if data.total_broken > data.base_broken then 
                GODMODE.game:ShowHallucination(10)
                data.base_broken = data.total_broken
                data.active = true
    
                if StageAPI and StageAPI.Loaded and StageAPI.GetCurrentStage ~= nil then 
                    StageAPI.ChangeRoomGfx(GODMODE.backdrops.correction_dogma_gfx)
                end
            end
        end    
    end
end

return monster