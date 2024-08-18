local item = {}
item.instance = GODMODE.registry.items.divine_wrath
item.eid_description = "Gain +3% damage each time you clear a room without taking damage#Damage bonus caps at +100% damage#Bonus is lost if you take damage, damaging all enemies in the room"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Gain +3% damage each time you clear a room without taking damage, up to +100% damage."},
		{str = "The bonus is lost if you take damage that would impact your devil deal chance."},
		{str = "When the bonus is lost, all enemies in the room take that percentage of their current health as damage."},
	},
}

item.amt_scale = 0.03
local max_amt = math.floor(1 / item.amt_scale)

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_DAMAGE then
		local amt = tonumber(GODMODE.save_manager.get_player_data(player,"DivineWrathCount","0"))
		player.Damage = player.Damage * (1 + amt * item.amt_scale * player:GetCollectibleNum(item.instance))
	end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local flag = true
    if enthit:ToPlayer() and enthit:ToPlayer():HasCollectible(item.instance) and amount > 0 and flags & DamageFlag.DAMAGE_NO_PENALTIES ~= DamageFlag.DAMAGE_NO_PENALTIES then
        local player = enthit:ToPlayer()
		local amt = tonumber(GODMODE.save_manager.get_player_data(player,"DivineWrathCount","0")) * item.amt_scale * player:GetCollectibleNum(item.instance)
		GODMODE.save_manager.set_player_data(player,"DivineWrathCount",0,true)
		GODMODE.game:ShakeScreen(math.floor(math.min(15,amt/item.amt_scale/8))+5)
		GODMODE.shader_params.divine_wrath_time = math.floor(math.min(40,amt/item.amt_scale*5+5*amt))
		GODMODE.game:MakeShockwave(player.Position, 0.15*(0.1+amt/max_amt*0.9), 0.03, math.floor(10+40*amt/max_amt))

		for ind,ent in ipairs(Isaac.GetRoomEntities()) do 
			if ent and GODMODE.util.is_valid_enemy(ent,true) then 
				ent:TakeDamage(ent.HitPoints * math.min(1,amt/max_amt),DamageFlag.DAMAGE_IGNORE_ARMOR,EntityRef(player),0)
			end
		end

		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
    end
end


item.room_rewards = function(self,rng,pos)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player)
		GODMODE.save_manager.set_player_data(player,"DivineWrathCount",math.min(max_amt, tonumber(GODMODE.save_manager.get_player_data(player,"DivineWrathCount","0"))+1),true)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end)
end


return item