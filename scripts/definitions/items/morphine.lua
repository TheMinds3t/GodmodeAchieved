local item = {}
item.instance = GODMODE.registry.items.morphine
item.eid_description = "↑ +10% Damage#↓ -20% Speed#↑ 30% chance to negate damage taken#↓ +2 Broken hearts"
item.eid_transforms = GODMODE.util.eid_transforms.SPUN
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Grants +10% damage, -20% speed and 2 broken hearts on picking it up."},
		{str = "The player has a 30% chance to negate any form of damage taken."},
	},
}


item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end
    local num = tonumber(GODMODE.save_manager.get_player_data(player, "MorphineBrokens", "0"))

    if tonumber(GODMODE.save_manager.get_player_data(player, "MorphineBrokens", "0")) < player:GetCollectibleNum(item.instance) then
        player:AddBrokenHearts(2)
        GODMODE.save_manager.set_player_data(player, "MorphineBrokens", player:GetCollectibleNum(item.instance), true)
    end

    if cache == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + 0.1*(player:GetCollectibleNum(item.instance)) * player.Damage
    end
    if cache == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed * (0.8/(player:GetCollectibleNum(item.instance)))
    end
end

item.player_update = function(self,player,data)
    if player:HasCollectible(item.instance) then
        data.morphine_cooldown = (data.morphine_cooldown or 0) - 1
    end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit:ToPlayer() and enthit:ToPlayer():HasCollectible(item.instance) and amount > 0 then
        local player = enthit:ToPlayer()
        local data = GODMODE.get_ent_data(player)

        if player:HasCollectible(item.instance) and (player:GetCollectibleRNG(item.instance):RandomFloat() < 0.33 or (data.morphine_cooldown or 0) > 0) then
            if data.morphine_cooldown == nil or data.morphine_cooldown <= 0 then 
                data.morphine_cooldown = 30 
                GODMODE.sfx:Play(SoundEffect.SOUND_ANIMAL_SQUISH, Options.SFXVolume+0.2, 20)
                GODMODE.sfx:Play(SoundEffect.SOUND_BLOBBY_WIGGLE, Options.SFXVolume+0.2)
                player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR,false,true)
                player:AnimateCollectible(Isaac.GetItemIdByName("Morphine Used"))
            end

            return false
        end
    end
end

return item