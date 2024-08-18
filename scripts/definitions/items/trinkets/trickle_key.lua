local item = {}
item.instance = GODMODE.registry.trinkets.trickle_key
item.eid_description = "+10% chance to charge keys that spawn#Adds 1 charge to your active items each stage"
item.trinket = true
item.encyc_entry = {
    { -- Effects
        {str = "Effects", fsize = 2, clr = 3, halign = 0},
        {str = "- 10% chance * trinket multiplier to convert non-golden keys into charged keys"},
        {str = "+1 charge * trinket multiplier to your active items when entering a new stage."}
    },
}

item.pickup_init = function(self, pickup)
    local total_count = GODMODE.util.total_item_count(item.instance,true)
    
    if pickup.Variant == PickupVariant.PICKUP_KEY and pickup.SubType ~= KeySubType.KEY_GOLDEN and pickup:GetDropRNG():RandomFloat() < total_count * 0.1 then 
        pickup:Morph(pickup.Type,pickup.Variant,KeySubType.KEY_CHARGED,true)
    end
end

item.new_level = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        for slot=0,4 do 
            if player:NeedsCharge(slot) then 
                player:SetActiveCharge(player:GetActiveCharge(slot) + math.ceil(player:GetTrinketMultiplier(item.instance)),slot)
            end
        end
    end, true)
end

return item