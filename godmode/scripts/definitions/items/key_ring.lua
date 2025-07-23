local item = {}
item.instance = GODMODE.registry.items.key_ring
item.eid_description = "Gain a stacking chance to activate Dad's Key when:#- Clearing rooms +12.5%#- Taking damage +33%"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "A stacking chance builds up to activate Dad's Key when this item procs. The chance starts at 0% and grows by:"},
      {str = "  - Clearing rooms (+12.5%)"},
      {str = "  - Taking Damage (+33.4%)"},
      {str = "When clearing a room, the chance is attempted and if successful uses Dad's Key and the chance is reset to 0%. Otherwise, does nothing (Random key trinket displayed)."},
      {str = "When taking damage, if the chance is currently above 100% then Dad's Key is used and the chance is reset to 0%."},
    }
}

local dmg_perc_increase = 0.334
local room_clear_perc_increase = 0.125

local success_items = {
    CollectibleType.COLLECTIBLE_DADS_KEY
}

local fail_items = {
    TrinketType.TRINKET_RUSTED_KEY,
    TrinketType.TRINKET_STORE_KEY,
    TrinketType.TRINKET_GILDED_KEY,
    TrinketType.TRINKET_CRYSTAL_KEY,
    TrinketType.TRINKET_STRANGE_KEY,
}

item.try_key = function(self, player)
    local chance = tonumber(GODMODE.save_manager.get_player_data(player,"KeyRingChance","0.0"))
    local rng = player:GetCollectibleRNG(item.instance)
    local data = GODMODE.get_ent_data(player)

    if rng:RandomFloat() < chance then 
        GODMODE.save_manager.set_player_data(player,"KeyRingChance","0.0",true)
        if data.dads_key_ring ~= true then 
            player:UseActiveItem(success_items[rng:RandomInt(#success_items)+1],true)
        end

        data.dads_key_ring = true  
        return true 
    else 
        player:AnimateTrinket(fail_items[rng:RandomInt(#fail_items)+1])
        return false 
    end
end

local hit_func = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit:ToPlayer() and enthit:ToPlayer():HasCollectible(item.instance) then
        local player = enthit:ToPlayer()
        local chance = tonumber(GODMODE.save_manager.get_player_data(player,"KeyRingChance","0.0"))
        local data = GODMODE.get_ent_data(player)

        if chance >= 1.0 then 
            if item.try_key(self, player) then
            end
        elseif data.dads_key_ring ~= true then 
            GODMODE.save_manager.set_player_data(player,"KeyRingChance",math.min(1,chance+dmg_perc_increase * player:GetCollectibleNum(item.instance)),true)
        end
    end
end

if GODMODE.validate_rgon() then 
    item.pre_player_hit = hit_func
else
    item.npc_hit = hit_func
end

item.new_room = function()
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        GODMODE.get_ent_data(player).dads_key_ring = nil
    end)
end

item.room_rewards = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        item.try_key(self, player)
        local chance = tonumber(GODMODE.save_manager.get_player_data(player,"KeyRingChance","0.0"))
        GODMODE.save_manager.set_player_data(player,"KeyRingChance",math.min(1,chance+room_clear_perc_increase * player:GetCollectibleNum(item.instance)),true)
    end)
end

return item