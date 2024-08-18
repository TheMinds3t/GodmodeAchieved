local item = {}
item.instance = GODMODE.registry.trinkets.glitched_penny

if GODMODE.validate_rgon() then 
    item.eid_description = "+1.5% chance to spawn a glitched item or teleport to the I AM ERROR ROOM when collecting a coin"
else 
    item.eid_description = "+1.5% chance to teleport to the I AM ERROR ROOM when collecting a coin"
end

item.trinket = true
item.encyc_entry = {
    { -- Effects
        {str = "Effects", fsize = 2, clr = 3, halign = 0},
        {str = "- +1.5% chance to teleport to the I AM ERROR room when collecting a coin."},
        {str = "- When Repentogon is enabled, an additional +1.5% chance on collecting a coin to spawn a glitched item."},
    },
}

item.pickup_collide = function(self, pickup,ent2,entfirst)
    if pickup.Variant == PickupVariant.PICKUP_COIN and ent2:ToPlayer() and ent2:ToPlayer():GetTrinketMultiplier(item.instance) > 0 then 
        local total_count = GODMODE.util.total_item_count(item.instance,true)

        if pickup:GetDropRNG():RandomFloat() < 0.015 * total_count then 
            GODMODE.game:StartRoomTransition(GridRooms.ROOM_ERROR_IDX, Direction.DOWN, RoomTransitionAnim.TELEPORT, ent2:ToPlayer())
        elseif GODMODE.validate_rgon() and pickup:GetDropRNG():RandomFloat() < 0.015 * total_count then--0.015 * total_count then 
            local item = ProceduralItemManager.CreateProceduralItem(pickup.InitSeed, 0)
            Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,item,GODMODE.room:FindFreePickupSpawnPosition(ent2.Position),Vector.Zero,nil)
        end
    end    
end

return item