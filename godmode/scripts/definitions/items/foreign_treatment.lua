local item = {}
item.instance = GODMODE.registry.items.foreign_treatment
item.eid_description = "Grants a modifier to each stat at the beginning of each floor, ranging from -10% to +20%"

item.encyc_entry = {
  	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - Each floor this item grants a stat modifier to each stat ranging from 90% to 120%."},
      {str = " - These modifiers are rerolled completely at the beginning of each new floor, negating any previous stat modifiers given by this item."},
      {str = " - Collecting more Foreign Treatments will roll the modifier for each item, stacking the modifier, but limiting it to a minimum of 50% and a maximum of 200%. This means that a stat buff is more likely the more Foreign Treatments you have due to the way the modifier is generated."},
    },
}

local min_range = -0.1
local max_range = 0.2

local stats = {
  [CacheFlag.CACHE_DAMAGE] = 1,
  [CacheFlag.CACHE_FIREDELAY] = 2,
  [CacheFlag.CACHE_RANGE] = 3,
  [CacheFlag.CACHE_SPEED] = 4,
  [CacheFlag.CACHE_SHOTSPEED] = 5,
  [CacheFlag.CACHE_LUCK] = 6,
}

item.eval_cache = function(self, player,cache,data)
    if stats[cache] ~= nil then
        local mod = tonumber(GODMODE.save_manager.get_player_data(player,"Foreign"..stats[cache],"0"))
        GODMODE.util.modify_stat(player, cache, 1 + mod, true, false)
    end
end

item.new_level = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance,function(player) 
        for stat,ind in pairs(stats) do 
            local mod = 0
            for i=0,player:GetCollectibleNum(item.instance) do 
              mod = mod + player:GetCollectibleRNG(item.instance):RandomFloat()*(max_range - min_range)+min_range
            end

            GODMODE.save_manager.set_player_data(player,"Foreign"..ind,math.min(math.max(mod,-0.5),1),true)
            player:AddCacheFlags(stat)
        end

        player:EvaluateItems()
    end)
end

return item