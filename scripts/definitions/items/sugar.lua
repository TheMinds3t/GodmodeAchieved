local item = {}
item.instance = GODMODE.registry.items.sugar
item.eid_description = "↑ +5% Damage first 5 times picking up#↑ +10% Fire Rate first 5 times picked up#↑ +10% Damage after 3 times picking up#↑ +5% Fire Rate after 5 times picking up#↑ +0.125 speed#↓ -1 Heart container#↓ Next 3 items have 50% chance to turn into Sugar!"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "Grants -1 heart container, +0.125 speed as well as a varying effect based on how many Sugar! is held by the player."},
      {str = "For the first 5 times picked up, grants +5% damage. For every time after picking it up 3 times, grants +10% damage."},
      {str = "For the first 5 times picked up, grants +10% Fire Delay. After this quantity is met, each additional held will grant +5% fire delay."},
      {str = "Each time a Sugar! is picked up, an internal counter is increased by 3. Whenever a new item is found, this counter is reduced by 1 and the new item has a 50% chance to become Sugar!. Once this counter reaches 0, no more Sugar! will replace new items."},
    },
    { -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
	  {str = "All stat bonuses granted by this item are increased by 25% if Binge Eater is held."}
    },
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end
    local binge_mod = (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BINGE_EATER) * 0.25) + 1

    if cache == CacheFlag.CACHE_SPEED then
        data.num_sugar = tonumber(GODMODE.save_manager.get_player_data(player, "SugarCount", "0"))

        if data.num_sugar < player:GetCollectibleNum(item.instance) then
            GODMODE.save_manager.set_player_data(player, "SugarCount", data.num_sugar + 1,true)
            data.sugar_reroll_count = tonumber(GODMODE.save_manager.get_player_data(player, "SugarRerollCount", "0")) + 3
            GODMODE.save_manager.set_player_data(player, "SugarRerollCount", data.sugar_reroll_count,true)
        end

        player.MoveSpeed = player.MoveSpeed + 0.125 * (player:GetCollectibleNum(item.instance)) * binge_mod
    end
    if cache == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage * (1 + (0.05 * math.min(player:GetCollectibleNum(item.instance),5) + 0.1 * math.max(0,player:GetCollectibleNum(item.instance)-3))*binge_mod)
    end
    if cache == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = player.MaxFireDelay / (1 + (0.1 * math.min(player:GetCollectibleNum(item.instance)-1,5) + 0.05 * math.max(0,player:GetCollectibleNum(item.instance)-5))*binge_mod)
        -- GODMODE.util.modify_stat(player, cache, 1 + (0.1 * math.min(player:GetCollectibleNum(item.instance)-1,5) + 0.05 * math.max(0,player:GetCollectibleNum(item.instance)-5))*binge_mod, true, false)
    end
end

item.pickup_init = function(self, pickup)
    local data = GODMODE.get_ent_data(pickup)
    if (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM) and (data and data.sugar_reroll_attempt ~= true) then
        data.sugar_reroll_attempt = true

        GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
            local data = GODMODE.get_ent_data(player)
            local config = Isaac.GetItemConfig():GetCollectible(pickup.SubType)

            if config:IsCollectible() and config.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST then             
                if (Isaac.GetChallenge() == GODMODE.registry.challenges.sugar_rush or (data.sugar_reroll_count or 0) > 0) and pickup.SubType ~= item.instance then
                    data.sugar_reroll_count = data.sugar_reroll_count - 1
                    GODMODE.save_manager.set_player_data(player, "SugarRerollCount", data.sugar_reroll_count,true)
                    if player:GetCollectibleRNG(item.instance):RandomFloat() < 0.5 then
                        pickup:Morph(5,pickup.Variant,item.instance,true)
                    end
                end
            end
        end)
    end
end

item.bypass_hooks = {["pickup_init"] = true}


return item