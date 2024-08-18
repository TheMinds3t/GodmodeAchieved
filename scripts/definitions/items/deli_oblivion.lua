local item = {}
item.instance = GODMODE.registry.items.deli_oblivion
item.eid_description = "Converts your delirious halo into delirious eyes#Gain 5% damage for every eye#10% Fire Rate up#20% Range down#1 eye is created on room clear, up to 16"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When used, disables the presence of your delirious halo."},
      {str = "You become one-hit, but gain +5% damage for each eye that exists around you and an additional 10% Fire Rate up"},
      {str = "Recharges every 4 seconds"},
    },
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end
    if GODMODE.save_manager.get_player_data(player,"RingHidden","false") == "true" then 
        local eyes = tonumber(GODMODE.save_manager.get_player_data(player,"EyesOpen","16"))

        if cache == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage + player.Damage * (0.05 * eyes)
        end    

        if cache == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange * 1 + (0.025 * eyes)
        end    
    end
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance and player:GetPlayerType() == GODMODE.registry.players.t_deli then
        GODMODE.save_manager.set_player_data(player,"RingHidden", "true", true)
        GODMODE.sfx:Play(SoundEffect.SOUND_MEATY_DEATHS,Options.SFXVolume*1.5+0.75)
        player:AddCollectible(GODMODE.registry.items.deli_delusion, 0, false, GODMODE.util.get_active_slot(player,item.instance))
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_FAMILIARS)
        player:EvaluateItems()

        return {Discharge=true,Remove=false,ShowAnim=true}
    end
end

return item