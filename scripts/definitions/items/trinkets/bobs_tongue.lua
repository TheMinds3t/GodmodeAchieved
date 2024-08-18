local item = {}
item.instance = GODMODE.registry.trinkets.bobs_tongue
item.eid_description = "#↑ +0.25 Tears#↑ If two Bob items are held by the player, gives a random Bob item and swallows this trinket"
item.trinket = true
item.encyc_entry = {
    { -- Effects
        {str = "Effects", fsize = 2, clr = 3, halign = 0},
        {str = "- +0.25 Tears."},
        {str = "- If two items fulfilling the Bob transformation are held, then all trinkets the player is holding currently get swallowed and you gain another random Bob item not currently held."},
    },
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasTrinket(item.instance) then return end

	local data = GODMODE.get_ent_data(player)

    if cache == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.25*player:GetTrinketMultiplier(item.instance))
    end
end

item.player_update = function(self,player)
    if player:IsFrame(30,1) and player:HasTrinket(item.instance) then
        local bob = GODMODE.special_items.bob_list 
        local count = 0

        for _,item in ipairs(bob) do
            if player:HasCollectible(item.ID) then
                count = count + player:GetCollectibleNum(item.ID)
            end
        end

        if count == 2 then
            local bob_item = bob[player:GetTrinketRNG(item.instance):RandomInt(#bob)+1].ID

            while player:HasCollectible(bob_item) do
                bob_item = bob[player:GetTrinketRNG(item.instance):RandomInt(#bob)+1].ID
            end

            player:AddCollectible(bob_item)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, true, true, false)
        end
    end
end

return item