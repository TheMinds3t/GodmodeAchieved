local item = {}
item.instance = GODMODE.registry.trinkets.mood_ring_blue
item.eid_description = "Prevents two damaging projectiles spawned by Call of the Void#Regenerate one use lost per floor#If held and entered a new floor while Call of the Void is active, gives a small permanent stat boost#If COTV is disabled, simply gives +0.5 luck and +0.5 damage while held"
item.trinket = true
item.encyc_entry = {
    { -- Effects
        {str = "Effects", fsize = 2, clr = 3, halign = 0},
        {str = "- If Call of the Void spawns on the stage, getting hit by any of its projectiles gets nullified and this trinket turns into Mood Ring (Yellow)."},
        {str = "- If Call of the Void spawns on the stage and this is held when traveling to a new level, a permanent all stats up is gained."},
        {str = "- If Call of the Void is disabled, then holding this grants a flat +0.5 Damage and +0.5 Luck."},
    },
}

local buffs = {CacheFlag.CACHE_FIREDELAY, CacheFlag.CACHE_DAMAGE, CacheFlag.CACHE_SHOTSPEED, CacheFlag.CACHE_LUCK, CacheFlag.CACHE_SPEED}
local buff_amounts = {0.2,0.1,0.1,3,0.1}
item.eval_cache = function(self, player,cache,data)
    if GODMODE.save_manager.get_config("CallOfTheVoid","true") == "false" then 
        if cache == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + 0.5*player:GetTrinketMultiplier(item.instance)
        end

        if cache == CacheFlag.CACHE_LUCK then 
            player.Luck = player.Luck + 0.5*player:GetTrinketMultiplier(item.instance)
        end
    else 
        for _,buff in ipairs(buffs) do 
            if cache == buff then 
                local amt = tonumber(GODMODE.save_manager.get_player_data(player,"MoodRing"..buff,"0"))*(1+math.max(0,player:GetTrinketMultiplier(item.instance)-1))
                if buff == CacheFlag.CACHE_FIREDELAY then 
                    player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,amt)
                elseif buff == CacheFlag.CACHE_DAMAGE then
                    player.Damage = player.Damage + player.Damage * amt
                elseif buff == CacheFlag.CACHE_SHOTSPEED then
                    player.ShotSpeed = player.ShotSpeed + amt
                elseif buff == CacheFlag.CACHE_LUCK then
                    player.Luck = player.Luck + amt
                elseif buff == CacheFlag.CACHE_SPEED then
                    player.MoveSpeed = player.MoveSpeed + amt
                end
            end
        end    
    end
end

item.first_level = function(self)
    GODMODE.util.macro_on_players(function(player) 
        for _,buff in ipairs(buffs) do 
            GODMODE.save_manager.set_player_data(player,"MoodRing"..buff,"0",true)
            player:AddCacheFlags(buff)
        end
        player:EvaluateItems()
    end)
end

item.new_level = function(self)
    local count = tonumber(GODMODE.save_manager.get_data("VoidBHProj","0")) + tonumber(GODMODE.save_manager.get_data("VoidDMProj","0"))

    if count > 0 then 
        GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
            local sel_buff = player:GetTrinketRNG(item.instance):RandomInt(#buffs)+1
            for _,buff in ipairs(buffs) do 
                GODMODE.save_manager.set_player_data(player,"MoodRing"..buff,tonumber(GODMODE.save_manager.get_player_data(player,"MoodRing"..buff,"0"))+buff_amounts[sel_buff],true)
                player:AddCacheFlags(buff)    
            end

            player:EvaluateItems()
        end, true)
    end
end


return item