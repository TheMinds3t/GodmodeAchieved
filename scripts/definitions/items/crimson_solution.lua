local item = {}
item.instance = GODMODE.registry.items.crimson_solution
item.eid_description = "Random syringe effect when entering a room#On taking fatal damage, prevent death and this item turns into the Broken Syringe trinket"
item.eid_transforms = GODMODE.util.eid_transforms.SPUN
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Grants a random syringe effect on entering a room."},
		{str = "When taking fatal damage, prevent death and convert this item into the Broken Syringe trinket."},
	},
}


item.player_update = function(self,player,data)
    if player:HasCollectible(item.instance) or (data.crimson_cooldown or 0) > 0 then
        data.crimson_cooldown = (data.crimson_cooldown or 0) - 1
    end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit:ToPlayer() and amount > 0 then
        local player = enthit:ToPlayer()
        local data = GODMODE.get_ent_data(player)

        if (player:HasCollectible(item.instance) and GODMODE.util.get_player_hits(player) <= amount and player:GetExtraLives() == 0) or (data.crimson_cooldown or 0) > 0 then
            if data.crimson_cooldown == nil or data.crimson_cooldown <= 0 then 
                data.crimson_cooldown = amount * 60
                GODMODE.sfx:Play(SoundEffect.SOUND_GLASS_BREAK, Options.SFXVolume*2.5)
                player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR,false,true)
                player:AnimateCollectible(item.instance)
                player:RemoveCollectible(item.instance)
                Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET,TrinketType.TRINKET_BROKEN_SYRINGE,player.Position,RandomVector():Resized(4+player:GetCollectibleRNG(item.instance):RandomFloat()*2),player)
            end

            return false
        end
    end
end

item.new_room = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player)
        local rng = RNG()
        rng:SetSeed(GODMODE.room:GetDecorationSeed(),35)
        local item = GODMODE.special_items:get_syringe_item(rng)
        local old_item = tonumber(GODMODE.save_manager.get_player_data(player,"CrimsonSol","-1"))

        if old_item ~= -1 then 
            player:GetEffects():RemoveCollectibleEffect(item)
        end

        player:GetEffects():AddCollectibleEffect(item)
        GODMODE.save_manager.set_player_data(player,"CrimsonSol",item,true)
    end)
end

return item