local item = {}
item.instance = GODMODE.registry.items.fractal_key
item.eid_description = "On use:#- grants a decreasing, decaying chance to convert pickups to golden variants#- +1 Broken heart and Faithless heart#While held, golden pickups are replaced with 3 basic versions of that pickup#-0.5% chance per cleared room, resetting to full effect each use"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When used, grants 1 Broken heart and 1 Faithless heart"},
      {str = "as well as following this formula for a chance to replace pickups with a golden variant:"},
      {str = "  N = total number of uses"},
      {str = "  X = granted chance"},
      {str = "  if N <= 0: 0%"},
      {str = "  if N < 5: 10% - (N - 1) * 2%"},
      {str = "  if N >= 5: 5% / (N - 3)"},
      {str = "So in example, total chance to replace a pickup is as follows per use:"},
      {str = "- (10% -> 20% -> 28% -> 34% -> ...<39%)"},
      {str = ""},
      {str = "While held, all golden pickups are replaced with 3 random versions of that pickup (if another golden one is rolled without this bonus, this could lead to a chain reaction but the chance this item grants does not apply to this split)."},
      {str = "The chance that this item grants will decrease by 1% for each new room entered. When you re-use the item, the chance that will be added will be the compounded chance (similar to the way that fruit stat buffs work)."},
      {str = "If using this item would kill the player via broken/faithless hearts, instead turns this item into the Inverse Key and causes the player to explode."},
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
        GODMODE.save_manager.set_data("FractalKeyUses",uses+1)
        GODMODE.save_manager.set_data("GildedChance", math.min(1,chance + item.get_chance(uses+1)),true)
        GODMODE.game:MakeShockwave(player.Position + Vector(64,-64), 0.025, 0.01, 20)
        GODMODE.game:MakeShockwave(player.Position - Vector(64,64), 0.025, 0.01, 20)

        if player:GetBrokenHearts() + GODMODE.util.get_faithless(player) + 2 >= 12 then 
            player:RemoveCollectible(item.instance, true, slot)
            player:AddCollectible(GODMODE.registry.items.fractal_key_inverse,0,true,slot)
            -- GODMODE.room:MamaMegaExplosion(player.Position)
            GODMODE.game:BombExplosionEffects(player.Position, player.Damage * 2 + 50)
        -- GODMODE.game:BombExplosionEffects(player.Position, player.Damage * 2 + 20, 10.0)
        else 
            player:AddBrokenHearts(1)
            GODMODE.util.add_faithless(player, 1)    
        end

        return true
    end
end

local pos = GODMODE.util.get_center_of_screen() * Vector(tonumber(GODMODE.save_manager.get_config("FractalDisplayX","0.05")),tonumber(GODMODE.save_manager.get_config("FractalDisplayY","0.9"))) * 2

item.post_render = function(self,player,index)
    local chance = GODMODE.paused and 1 or tonumber(GODMODE.save_manager.get_data("GildedChance","0.0"))

	if chance > 0 then
        local render_type = tonumber(GODMODE.save_manager.get_config("FractalDisplay","1"))
        if render_type > 1 then 
            if item.ui_anim == nil then
                item.ui_anim = Sprite()
                item.ui_anim:Load("/gfx/ui/fractal_chance.anm2", true)
                item.ui_anim.Color = Color(0.8,0.8,0.8,1) --fixes over-exposure problem
            end
    
            item.ui_anim:SetFrame("Icon",0)

            local pos = GODMODE.util.get_center_of_screen() * Vector(tonumber(GODMODE.save_manager.get_config("FractalDisplayX","0.05")),tonumber(GODMODE.save_manager.get_config("FractalDisplayY","0.9"))) * 2

            if render_type == 3 then 
                pos = GODMODE.util.get_center_of_screen() * Vector(0.03+Options.HUDOffset * 0.07,1.375+Options.HUDOffset * 0.075)
            end
            
            item.ui_anim:Render(pos, Vector(0,0), Vector(0,0))
            Isaac.RenderText(math.floor(chance * 100).."%",pos.X+8,pos.Y - 5.5,255,255,255,255)
        end
    end
end

-- decay gilded chance
item.new_room = function(self)
    if GODMODE.room:IsFirstVisit() and not GODMODE.room:IsClear() then 
        GODMODE.save_manager.set_data("GildedChance", math.min(1,math.max(tonumber(GODMODE.save_manager.get_data("GildedChance","0.0")) - 0.01,0)),true)
    end
end

return item