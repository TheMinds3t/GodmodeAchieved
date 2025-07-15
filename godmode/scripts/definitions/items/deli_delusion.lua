local item = {}
item.instance = GODMODE.registry.items.deli_delusion
item.eid_description = "Converts your delirious eyes into a delirious halo#2.5% Range Up for every eye open#The delirious halo blocks hits as long as there are eyes open#Lose ceil(1.5 * damage) eyes for every damage blocked#1 eye opens on room clear"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When used, enables the presence of your delirious halo."},
      {str = "As long as there is an eye open on your delirious halo, you are immune to damage."},
      {str = "Every time you take damage, ceil(1.5 * damage) eyes close (so for 1 damage, 2 eyes close, for 2 damage, 3 eyes close, 3 damage, 5 eyes close, etc.)."},
      {str = "When the halo is initially created, it is immune to damage for half a second allowing you to block with it without closing eyes."},
      {str = "When an enemy touches the halo, they are launched backwards and take damage equal to your damage stat."},
      {str = "When a projectile touches the halo, the projectile is launched and now deals damage to enemies equal to your damage stat and cannot hit the player."},
      {str = "1 eye opens when you clear a room."},
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

        if cache == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay - player.MaxFireDelay * 0.1
        end    

        if cache == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange * 0.8
        end    
    end
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance and player:GetPlayerType() == GODMODE.registry.players.t_deli then
        local eyes = tonumber(GODMODE.save_manager.get_player_data(player,"EyesOpen","16"))

        if eyes == 0 then 
            return {Discharge=false,Remove=false,ShowAnim=true}
        end

        GODMODE.save_manager.set_player_data(player,"RingHidden", "false", true)
        GODMODE.sfx:Play(SoundEffect.SOUND_MEATY_DEATHS,Options.SFXVolume*1.5+0.75)
        player:AddCollectible(GODMODE.registry.items.deli_oblivion, 0, false, GODMODE.util.get_active_slot(player,item.instance))
        GODMODE.util.macro_on_enemies(player,GODMODE.registry.entities.deli_halo.type,GODMODE.registry.entities.deli_halo.variant,-1,function(halo) 
            halo = halo:ToFamiliar()
            halo.Coins = 15
        end)

        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_SHOTSPEED | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_FAMILIARS)
        player:EvaluateItems()

        return {Discharge=true,Remove=false,ShowAnim=true}
    end
end

return item