local item = {}
item.instance = Isaac.GetItemIdByName( "Sugar!" )
item.eid_description = "↑ +0.25 Damage first 5 times picking up#↑ +0.35 Tears first 5 times picked up#↑ +0.35 Damage after 3 times picking up#↑ +0.2 Tears after 5 times picking up#↑ +0.125 speed#↓ -1 Heart container#↓ Next 3 items have 50% chance to turn into Sugar!"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "Grants -1 heart container, +0.125 speed as well as a varying effect based on how many Sugar! is held by the player."},
      {str = "For the first 5 times picked up, grants +0.25 damage. After this quantity is met, the next 5 will grant +0.55 damage each. After 10 is held, each additional held will grant +0.2 damage."},
      {str = "For the first 5 times picked up, grants +0.35 Fire Delay. After this quantity is met, each additional held will grant +0.2 fire delay."},
      {str = "Each time a Sugar! is picked up, an internal counter is increased by 3. Whenever a new item is found, this counter is reduced by 1 and the new item has a 50% chance to become Sugar!. Once this counter reaches 0, no more Sugar! will replace new items."},
    },
    { -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
	  {str = "Additionally gives +0.2 speed if Binge Eater is held."}
    },
}

item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end

	local data = GODMODE.get_ent_data(player)
    if cache == CacheFlag.CACHE_SPEED then
        data.num_sugar = tonumber(GODMODE.save_manager.get_player_data(player, "SugarCount", "0"))

        if data.num_sugar < player:GetCollectibleNum(item.instance) then
            GODMODE.save_manager.set_player_data(player, "SugarCount", data.num_sugar + 1,true)
            data.sugar_reroll_count = tonumber(GODMODE.save_manager.get_player_data(player, "SugarRerollCount", "0")) + 3
            GODMODE.save_manager.set_player_data(player, "SugarRerollCount", data.sugar_reroll_count,true)
        end

        player.MoveSpeed = player.MoveSpeed + 0.125 * (player:GetCollectibleNum(item.instance))
    end
    if cache == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + 0.25 * math.min(player:GetCollectibleNum(item.instance),5) + 0.35 * math.max(0,player:GetCollectibleNum(item.instance)-3)
    end
    if cache == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.35 * math.min(player:GetCollectibleNum(item.instance)-1,5) + 0.2 * math.max(0,player:GetCollectibleNum(item.instance)-5), true)
    end
end

item.pickup_init = function(self, pickup)
    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM then
        GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
            local data = GODMODE.get_ent_data(player)
             
            if (Isaac.GetChallenge() == Isaac.GetChallengeIdByName("Sugar Rush!") or (data.sugar_reroll_count or 0) > 0) and pickup.SubType ~= item.instance then
                data.sugar_reroll_count = data.sugar_reroll_count - 1
                GODMODE.save_manager.set_player_data(player, "SugarRerollCount", data.sugar_reroll_count,true)
                if player:GetCollectibleRNG(item.instance):RandomFloat() < 0.5 then
                    pickup:Morph(5,pickup.Variant,item.instance,true)
                end
            end
        end)
    end
end

return item