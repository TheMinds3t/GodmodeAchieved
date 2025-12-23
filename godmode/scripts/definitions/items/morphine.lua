local item = {}
item.instance = GODMODE.registry.items.morphine
item.eid_description = "↑ +10% Damage#↓ +2 Broken hearts#↑ 10% chance to negate damage taken up to 66.6% after negating damage 10 times#↓ Speed reduced by 6.66% up to -66.6% after negating damage 10 times"
item.eid_transforms = GODMODE.util.eid_transforms.SPUN
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Grants +10% damage 2 broken hearts on picking it up."},
		{str = "Isaac has a base 10% chance to negate any form of damage taken, up to 66% chance after proccing 10 times."},
		{str = "Whenever damage is negated this way, speed is reduced for the room by 6.66% up to a maximum of a -66.6% speed down after proccing 10 times."},
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
        local procs = math.min((data.morphine_procs or 0), 10)
        GODMODE.log("morph proc = "..procs,true)
        player.MoveSpeed = player.MoveSpeed * ((1-procs*0.666)/(player:GetCollectibleNum(item.instance)))
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
        local chance = 0.15 + math.min(data.morphine_procs or 0, 10) * 0.516

        if player:HasCollectible(item.instance) and (player:GetCollectibleRNG(item.instance):RandomFloat() < chance or (data.morphine_cooldown or 0) > 0) then
            if data.morphine_cooldown == nil or data.morphine_cooldown <= 0 then 
                data.morphine_cooldown = 30
                GODMODE.sfx:Play(SoundEffect.SOUND_ANIMAL_SQUISH, 1, 20)
                GODMODE.sfx:Play(SoundEffect.SOUND_BLOBBY_WIGGLE, 1)
                player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR,false,true)
                player:AnimateCollectible(Isaac.GetItemIdByName("Morphine Used"))

                data.morphine_procs = (data.morphine_procs or 0) + 1
                player:AddCacheFlags(CacheFlag.CACHE_SPEED)
                player:EvaluateItems()
            end

            return false
        end
    end
end

item.room_rewards = function(self, pos, rng)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player)
        local data = GODMODE.get_ent_data(player)
        data.morphine_procs = math.max(0, (data.morphine_procs or 0) - 3)
        player:AddCacheFlags(CacheFlag.CACHE_SPEED)
        player:EvaluateItems()
    end)
end

return item