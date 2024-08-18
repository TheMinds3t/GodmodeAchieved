local item = {}
item.instance = GODMODE.registry.items.moms_wish
item.eid_description = "Spawns a Holy Card# Spawns a soul heart if you are not Tainted Lost#↓ Permanent 5% all stat down if you are Tainted Lost"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "On use, spawns a holy card on the ground and, if you are Tainted Lost, reduces all primary stats by 5%."},
		{str = "If you are not Tainted Lost, spawns a soul heart on use."},
		{str = "The stat decrease will persist even if the item is dropped, however the stat decrease can not be stronger than -50%."},
	},
}

item.eval_cache = function(self, player,cache,data)
    if GODMODE.get_ent_data then
        data.wishes_used = tonumber(GODMODE.save_manager.get_player_data(player,"MomsWishUses","0"))
        GODMODE.save_manager.set_player_data(player,"MomsWishUses",data.wishes_used)

        local scale = (1.0 - math.min(0.75,data.wishes_used * 0.05))
        if cache == CacheFlag.CACHE_LUCK then
            if player.Luck < 0 then scale = 1.0 / scale end 
            player.Luck = player.Luck * scale
        end
        if cache == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed * scale
        end
        if cache == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * scale
        end
        if cache == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay / scale
        end
        if cache == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed * scale
        end    
    end
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
    if coll == item.instance then 
        Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,Card.CARD_HOLY,GODMODE.room:FindFreePickupSpawnPosition(player.Position),Vector.Zero,player)
        if player:GetPlayerType() == PlayerType.PLAYER_THELOST_B then 
            GODMODE.save_manager.set_player_data(player,"MomsWishUses",tonumber(GODMODE.save_manager.get_player_data(player,"MomsWishUses","0"))+1,true)
            player:AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SHOTSPEED)
            player:EvaluateItems()    
        else 
            Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_HEART,HeartSubType.HEART_SOUL,GODMODE.room:FindFreePickupSpawnPosition(player.Position),Vector.Zero,player)
        end

        return true
    end
end

item.new_level = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        local slot = GODMODE.util.get_active_slot(player,item.instance)

        if slot ~= -1 then
            player:SetActiveCharge(1,slot)
        end
    end)
end

return item