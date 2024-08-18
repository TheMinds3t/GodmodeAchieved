local item = {}
item.instance = GODMODE.registry.items.divine_approval
item.eid_description = "↑ +0.25 Tears per gold heart #↑ Gives 3 soul hearts and full gold hearts#↑ +1 gold heart per floor#↓ Removes all black hearts on pickup"
item.eid_transforms = GODMODE.util.eid_transforms.ANGEL
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "On pickup, grants 3 soul hearts and then full golden hearts."},
      {str = "At the beginning of each floor, grants one golden heart."},
      {str = "For each golden heart you have, grants +0.125 tears and +0.125 fire delay."},
    },
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

    data.num_divines = tonumber(GODMODE.save_manager.get_player_data(player, "NumDivine", "0"))

    if data.num_divines < player:GetCollectibleNum(item.instance) then
        local soul = player:GetSoulHearts()
        local gold = player:GetGoldenHearts()
        local black = 0
        local red = player:GetMaxHearts()

        for i = 1, 24 do
            if player:IsBlackHeart(i) then
                player:RemoveBlackHeart(i)
                black = black + 1
            end
        end

        player:AddSoulHearts(6)
        soul = player:GetSoulHearts()
        black = 0

        local gold_add = math.min(24, math.floor((red+soul)/2)-gold)

        player:AddGoldenHearts(gold_add)

        data.num_divines = (data.num_divines or 0) + 1
        GODMODE.save_manager.set_player_data(player, "NumDivine", data.num_divines,true)
    end

    if cache == CacheFlag.CACHE_FIREDELAY then
        local amt = math.min(12,player:GetGoldenHearts())*0.125
        player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,amt*player:GetCollectibleNum(item.instance))
        player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,amt*player:GetCollectibleNum(item.instance),true)
    end
end

item.pickup_collide = function(self, pickup,ent,entfirst)
    if ent:ToPlayer() then
        local player = ent:ToPlayer()

        if player:HasCollectible(item.instance) then
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
    end
end

item.player_update = function(self, player)
    if player:IsFrame(30,1) and player:HasCollectible(item.instance) then
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
    end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit:ToPlayer() and enthit:ToPlayer():HasCollectible(item.instance) then
        local player = enthit:ToPlayer()

        if player:HasCollectible(item.instance) then
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
        end
    end
end

item.new_level = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player)
        player:AddGoldenHearts(1*player:GetCollectibleNum(item.instance))
    end)
end

return item