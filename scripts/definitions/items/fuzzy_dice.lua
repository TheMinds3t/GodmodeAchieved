local item = {}
item.instance = Isaac.GetItemIdByName( "Fuzzy Dice" )
item.eid_description = "Redistributes 33% of current coins, keys and bombs randomly"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When used, removes one third of the player's coins, keys and bombs and puts it into a common pool."},
      {str = "This pool is then randomly distributed between keys, bombs and coins, effectively slightly equalizing the player's pickups."},
    },
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        local coins = math.ceil(player:GetNumCoins() / 3.3)
        local keys = math.ceil(player:GetNumKeys() / 3.3)
        local bombs = math.ceil(player:GetNumBombs() / 3.3)
        player:AddCoins(-coins)
        player:AddKeys(-keys)
        player:AddBombs(-bombs)
        local pool = coins + keys + bombs

        while pool > 0 do
            local spot = rng:RandomFloat()

            if spot < 1 / 3 then
                player:AddKeys(1)
            elseif spot < 2 / 3 then
                player:AddBombs(1)
            else 
                player:AddCoins(1)
            end
            
            pool = pool - 1
        end

        return true
    end
end

return item