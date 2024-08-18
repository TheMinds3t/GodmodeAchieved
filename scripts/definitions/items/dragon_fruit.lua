local item = {}
item.instance = GODMODE.registry.items.dragon_fruit
item.eid_description = "#↑ Heal 1 half heart#↑ gives a random, medium buff that lasts 5 minutes and stacks with fruit pickups"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When used, heals one half red heart and randomly gain a medium sized stat boost that lasts 5 minutes."},
      {str = "If the boosted stat has any currently active buffs from fruit pickups, the timer is reset and the buff is added to the existing buff."},
      {str = "Stat boosts are doubled if Binge Eater is held."},
    },
}

--from fruit pickup entity
local stat_ups = {
    {flag = CacheFlag.CACHE_SPEED, amt = 0.125},
    {flag = CacheFlag.CACHE_FIREDELAY, amt = 0.1},
    {flag = CacheFlag.CACHE_DAMAGE, amt = 0.15},
    {flag = CacheFlag.CACHE_SHOTSPEED, amt = 0.1},
    {flag = CacheFlag.CACHE_RANGE, amt = 0.15},
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        player:AddHearts(1)
		GODMODE.sfx:Play(SoundEffect.SOUND_VAMP_GULP)
        local sub = rng:RandomInt(5)+1
        local mult = 1
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BINGE_EATER) then mult = 2.0 end
        GODMODE.save_manager.set_player_data(player,"Fruit"..sub,tonumber(GODMODE.save_manager.get_player_data(player,"Fruit"..sub,"0"))+stat_ups[sub].amt*mult,true)
        GODMODE.save_manager.set_player_data(player,"MaxFruit"..sub,tonumber(GODMODE.save_manager.get_player_data(player,"MaxFruit"..sub,"0"))+stat_ups[sub].amt*mult,true)
        GODMODE.save_manager.set_player_data(player,"TimeStamp"..sub,GODMODE.game:GetFrameCount(),true)
        player:AddCacheFlags(stat_ups[sub].flag)
        player:EvaluateItems()

        return true
    end
end

return item