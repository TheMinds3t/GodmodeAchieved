local item = {}
item.instance = GODMODE.registry.trinkets.bone_feather
item.eid_description = "Guarantees access to the Correction room each floor"
item.trinket = true
item.encyc_entry = {
    { -- Effects
        {str = "Effects", fsize = 2, clr = 3, halign = 0},
        {str = "Guarantees that the portal to the Correction room, in the starting room of each floor, will spawn."},
    },
}

item.new_room = function(self)
    GODMODE.save_manager.set_data("CorrectionNeeded","true")
end

return item