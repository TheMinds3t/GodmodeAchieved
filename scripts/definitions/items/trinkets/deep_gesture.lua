local item = {}
item.instance = Isaac.GetTrinketIdByName( "Gesture of the Deep" )
item.eid_description = "Uses chargeable active items when fully charged in uncleared rooms# 1% chance to fart instead if item's max charge is <= 2# 5% chance for pickups to spawn with a Lil Battery"
item.trinket = true

item.pickup_init = function(self, pickup)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        if pickup.Variant ~= PickupVariant.PICKUP_LIL_BATTERY and player:GetTrinketRNG(item.instance):RandomFloat() < 0.05 and #GODMODE.util.does_player_have(item.instance, true) > 0 and Game():GetRoom():IsFirstVisit() then
            Isaac.Spawn(pickup.Type, PickupVariant.PICKUP_LIL_BATTERY, 0, Game():GetRoom():FindFreePickupSpawnPosition(pickup.Position), Vector.Zero, nil)
        end
    end, true)
end

item.player_update = function(self,player)
	if player:HasTrinket(item.instance) and player:IsExtraAnimationFinished() and not Game():GetRoom():IsClear() then
        local slots = {ActiveSlot.SLOT_PRIMARY, ActiveSlot.SLOT_SECONDARY, ActiveSlot.SLOT_POCKET, ActiveSlot.SLOT_POCKET2}
        for _,slot in ipairs(slots) do 
            local item_id = player:GetActiveItem(slot)
            if item_id > 0 then
                local max_charge = Isaac.GetItemConfig():GetCollectible(item_id).MaxCharges
                if max_charge > 0 and player:GetActiveCharge(slot) == max_charge then
                    if max_charge > 2 or max_charge <= 2 and player:GetTrinketRNG(item.instance):RandomFloat() > 0.01 then --1% chance to be a dud with < 3 charges
                        player:UseActiveItem(item_id)
                    else
                        player:AnimateTrinket(item.instance)
                        Game():ButterBeanFart(player.Position, 84, player, true, false)
                    end

                    player:SetActiveCharge(0, slot)
                end
            end
        end
	end
end


return item