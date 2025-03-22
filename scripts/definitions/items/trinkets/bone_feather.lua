local item = {}
item.instance = GODMODE.registry.trinkets.bone_feather
item.eid_description = "Guarantees access to the Correction room each floor"
item.trinket = true
item.encyc_entry = {
    { -- Effects
        {str = "Effects", fsize = 2, clr = 3, halign = 0},
        {str = "Guarantees that the portal to the Correction room, in the starting room of each floor before exiting the Womb, will spawn."},
    },
}

item.new_room = function(self)
    GODMODE.save_manager.set_data("CorrectionNeeded","true")
end

item.new_level = function(self)
    if GODMODE.util.total_item_count(item.instance,true) > 0 and GODMODE.util.can_spawn_correction() then 
        local portal = Isaac.Spawn(GODMODE.registry.entities.correction_portal.type, GODMODE.registry.entities.correction_portal.variant, 1, 
        GODMODE.room:GetGridPosition(GODMODE.room:GetGridIndex((GODMODE.room_center or GODMODE.room:GetCenterPos()) + Vector(-102,64))), Vector.Zero, nil)    
        portal:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end

return item