local item = {}
item.instance = GODMODE.registry.items.cash_dice
item.eid_description = "Selects the nearest item or shop item.#If it is a shop item, splits it into two new shop items#If it is an item, turns it into a shop item#Can be used 5 times in a room"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When used, the nearest item OR shop item is selected."},
      {str = "If a shop item is selected, that shop item is split into two new shop items and the existing one is removed."},
      {str = "If a regular, free item is selected, that item is turned into a shop item for sale."},
      {str = "The item can only be used up to 5 times in a room."},
    },
}

local get_item = function()
    return GODMODE.game:GetItemPool():GetCollectible(ItemPoolType.POOL_SHOP)
end

-- in terms of item size (locked to free pickup position after)
local split_dist = 8

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        local uses = tonumber(GODMODE.save_manager.get_player_data(player,"ShopDice"..GODMODE.room:GetDecorationSeed(),"0"))

        if uses < 5 then 
            local closest = nil 
            local dist_func = function(player,a,b)
                return a ~= nil and b ~= nil and player ~= nil and (a.Position - player.Position):Length() < (b.Position - player.Position):Length()
            end
    
            GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,-1,function(item)
                if (closest == nil or dist_func(player,item,closest) and item:ToPickup().Price <= closest.Price) and item:ToPickup():CanReroll() then 
                    closest = item:ToPickup()
                end
            end)
    
            if closest ~= nil then 
                GODMODE.save_manager.set_player_data(player,"ShopDice"..GODMODE.room:GetDecorationSeed(),uses+1,true)

                if closest.Price == 0 then 
                    closest.ShopItemId = -1
                    closest.Price = 15    
                    closest:Morph(closest.Type,closest.Variant,get_item(),true,false)    
                else
                    local items = {get_item(),get_item()}
    
                    for ind,item in ipairs(items) do 
                        local new = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,item,
                            GODMODE.room:FindFreePickupSpawnPosition(closest.Position-Vector(closest.Size * split_dist/2-closest.Size*split_dist*(ind-1),0)),Vector.Zero,closest.SpawnerEntity)
                        new = new:ToPickup()
                        new.ShopItemId = -1
                        new.Price = 15    
                    end
    
                    closest:Remove()
                end
            else
                return {Discharge=false,Remove=false,ShowAnim=true}
            end
    
            return true
        else 
            return {Discharge=false,Remove=false,ShowAnim=true}
        end
    end
end

return item