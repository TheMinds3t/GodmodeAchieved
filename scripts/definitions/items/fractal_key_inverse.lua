local item = {}
item.instance = GODMODE.registry.items.fractal_key_inverse
item.eid_description = "On use:#- Wipes your Gilded chance, clearing 1 Broken and Faithless heart for every 12.5% Gilded chance (1/8)#- Destroys this item, creating a Mama Mega-style explosion"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When used, sets your Gilded chance to 0%. Whatever your Gilded chance was before this reset will dictate how strong the effects of this item are."},
      {str = "When used at 100% Gilded chance, removes 8 Broken hearts and 8 Faithless hearts from the user. When used at 0% chance, removes none of each."},
      {str = "Each 12.5% of Gilded chance grants 1 more Broken and Faithless heart removed."},
      {str = "In addition to this reset, this item turns back into the Fractal Key and the player explodes."},
      {str = "While held, all golden pickups are replaced with 3 random versions of that pickup (if another golden one is rolled without this bonus, this could lead to a chain reaction but the chance this item grants does not apply to this split)."},
      {str = "The chance that this item grants will decrease by 0.5% for each new room entered. When you re-use the item, the chance will go back to full strength (similar to the way that fruit stat buffs work)."},
    },
}

item.pickup_conversions = {
    [PickupVariant.PICKUP_HEART] = HeartSubType.HEART_GOLDEN,
    [PickupVariant.PICKUP_BOMB] = BombSubType.BOMB_GOLDEN,
    [PickupVariant.PICKUP_KEY] = KeySubType.KEY_GOLDEN,
    [PickupVariant.PICKUP_COIN] = CoinSubType.COIN_GOLDEN,
    [PickupVariant.PICKUP_PILL] = PillColor.PILL_GOLD,
    [PickupVariant.PICKUP_LIL_BATTERY] = BatterySubType.BATTERY_GOLDEN,
}

item.get_chance = function(uses)
    if uses <= 0 then 
        return 0
    elseif uses < 5 then 
        return 0.1 - math.max(uses - 1,0) * 0.02 + item.get_chance(uses - 1) 
    else
        return 0.05 / (uses - 3) + item.get_chance(uses - 1)
    end    
end

item.split_gold_val = 3

item.pickup_update = function(self, pickup, data, sprite)
    if pickup.FrameCount == 1 then 
        local uses = tonumber(GODMODE.save_manager.get_data("FractalKeyUses","0"))
        local convert_sub = item.pickup_conversions[pickup.Variant]
    
        if convert_sub ~= nil and (pickup.Touched ~= true or pickup.SubType == convert_sub) then 
            if pickup.SubType == convert_sub then
                pickup.Touched = true

                if item.split_gold_val > 0 and GODMODE.util.total_item_count(item.instance) > 0 then 
                    pickup:Morph(pickup.Type,pickup.Variant,1,false,true,false)
    
                    for i=1,item.split_gold_val-1 do 
                        local new_pickup = Isaac.Spawn(pickup.Type,pickup.Variant,0,pickup.Position,Vector(1,0):Rotated(pickup:GetDropRNG():RandomFloat()*360):Resized(pickup:GetDropRNG():RandomFloat()*0.75+0.25),pickup.SpawnerEntity)
                        new_pickup:ToPickup().Touched = new_pickup.SubType ~= convert_sub
                        new_pickup:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    end
                end
            else
                local chance = tonumber(GODMODE.save_manager.get_data("GildedChance","0.0"))
                
                if pickup:GetDropRNG():RandomFloat() <= chance and item.disable_convert ~= true then 
                    pickup:Morph(pickup.Type,pickup.Variant,convert_sub,true,false,false)
                end

                pickup.Touched = true
            end
        end    
    end
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        local uses = tonumber(GODMODE.save_manager.get_data("FractalKeyUses","0"))
        local chance = tonumber(GODMODE.save_manager.get_data("GildedChance","0.0"))
        -- GODMODE.save_manager.set_data("FractalKeyUses",uses+1)
        GODMODE.save_manager.set_data("FractalKeyUses", 0)
        GODMODE.save_manager.set_data("GildedChance", 0,true)
        GODMODE.util.add_faithless(player, -math.ceil(chance*8))
        player:AddBrokenHearts(-math.ceil(chance*8))
        -- GODMODE.room:MamaMegaExplosion(player.Position)
        GODMODE.game:BombExplosionEffects(player.Position, player.Damage * 2 + 50)
        -- player:RemoveCollectible(item.instance, true, slot)
        player:AddCollectible(GODMODE.registry.items.fractal_key,0,true,slot)
        GODMODE.game:MakeShockwave(player.Position + Vector(64,-64), 0.025, 0.01, 20)
        GODMODE.game:MakeShockwave(player.Position - Vector(64,64), 0.025, 0.01, 20)
        return true
    end
end

return item