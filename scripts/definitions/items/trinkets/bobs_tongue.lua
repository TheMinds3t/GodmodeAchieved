local item = {}
item.instance = Isaac.GetTrinketIdByName( "Bob's Tongue" )
item.eid_description = "#↑ +0.25 Tears#↑ If two Bob items are held by the player, gives a random Bob item and swallows this trinket"
item.trinket = true

item.eval_cache = function(self, player,cache)
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