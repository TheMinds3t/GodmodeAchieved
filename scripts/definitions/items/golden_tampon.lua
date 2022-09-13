local item = {}
item.instance = Isaac.GetItemIdByName( "Cloth of Gold" )
item.eid_description = "Spreads damage to all enemies of the same type in the room#Doesn't increase damage dealt, just distributes it#Doesn't work on enemies with armor#5% chance for item pedestal to turn into Cloth on a String if not owned already"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Whenever damage is dealt to an enemy, that damage is distributed evenly among all instances of that enemy within the room."},
		{str = "Damage flags are also spread between enemies, so certain items that have effects on kill, like fruit cake spawning runes, will be applied to all enemies at once."},
		{str = "When this item is held and Cloth on a String is not, all items have a 5% chance to turn into Cloth on a String."},
	},
}

local dmg = function(enthit,amount,flags,entsrc,countdown,count)
	if amount * (1/count) * GODMODE.util.total_item_count(item.instance) > enthit.MaxHitPoints / 10.0 and enthit.Parent == nil then
		Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.BLOOD_EXPLOSION,0,enthit.Position,Vector(0,0),enthit)
	end
	enthit:TakeDamage(amount * (1/count) * GODMODE.util.total_item_count(item.instance), flags | DamageFlag.DAMAGE_CLONES, entsrc, countdown or 0)
end
item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit:IsVulnerableEnemy() and flags & DamageFlag.DAMAGE_CLONES ~= DamageFlag.DAMAGE_CLONES and not GODMODE.armor_blacklist:has_armor(enthit) 
		and GODMODE.util.is_player_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc):HasCollectible(item.instance) then
		local count = GODMODE.util.count_enemies(nil,enthit.Type, enthit.Variant, enthit.SubType)
		
		GODMODE.util.macro_on_enemies(nil,enthit.Type, enthit.Variant, enthit.SubType, function(ent)
			dmg(ent,amount,flags,entsrc,countdown,count)
		end)

		return false
	end
end

item.pickup_init = function(self, pickup)
    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM then
		GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
			local data = GODMODE.get_ent_data(player)
			if not player:HasCollectible(Isaac.GetItemIdByName("Cloth on a String")) then
				if player:GetCollectibleRNG(item.instance):RandomFloat() < 0.05*player:GetCollectibleNum(item.instance) then
					pickup:Morph(5,pickup.Variant,Isaac.GetItemIdByName("Cloth on a String"), true)
				end
			end
		end)
	end
end

return item