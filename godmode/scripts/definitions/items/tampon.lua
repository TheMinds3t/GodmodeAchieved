local item = {}
item.instance = GODMODE.registry.items.cloth_on_a_string
item.eid_description = "↑ +5% damage dealt per other instance of same enemy in the room#1% chance for item pedestal to turn into Cloth of Gold if not owned already"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Whenever damage is dealt to an enemy, that damage is increased by 5% for all other instances of the same enemy in the room."},
		{str = "If Cloth of Gold is also held, grants +25% damage dealt to the enemy that was hurt."},
		{str = "When this item is held and Cloth of Gold is not, all items have a 1% chance to turn into Cloth of Gold."},
	},
}


item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)

	if enthit:IsVulnerableEnemy() and entsrc.Entity and entsrc.Entity:ToPlayer() and entsrc.Entity:ToPlayer():HasCollectible(item.instance) and flags & DamageFlag.DAMAGE_NOKILL ~= DamageFlag.DAMAGE_NOKILL and flags & DamageFlag.DAMAGE_CLONES ~= DamageFlag.DAMAGE_CLONES then
		local ents = Isaac.GetRoomEntities()
		local count = 0

		for i=1,#ents do
			local ent = ents[i]

			if ent then
				if enthit.Type == ent.Type and enthit.Variant == ent.Variant and enthit.SubType == ent.SubType then
					count = count + 1
				end
			end
		end

		local gold_c = GODMODE.util.total_item_count(GODMODE.registry.items.cloth_of_gold)
		local dmg = ((count - 1) * 0.05) * GODMODE.util.total_item_count(item.instance) * (1 + gold_c * 0.25)

		if dmg > 0.0 then
			if enthit:ToNPC() then
				enthit:ToNPC():PlaySound(SoundEffect.SOUND_MEATY_DEATHS, 0.2, 0, false, 1.6+GODMODE.util.get_player_from_attack(entsrc):GetCollectibleRNG(item.instance):RandomFloat()*0.2)
			end

			Isaac.Spawn(1000,2,0,enthit.Position,Vector(0,0),enthit)
		end

		enthit:TakeDamage(amount*dmg, DamageFlag.DAMAGE_NOKILL, entsrc, countdown or 0)
	end
end

item.pickup_init = function(self, pickup)
    if (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM) and GODMODE.achievements.is_item_unlocked(GODMODE.registry.items.cloth_of_gold) and GODMODE.room:IsFirstVisit() then
		GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
			local data = GODMODE.get_ent_data(player)
			local config = Isaac.GetItemConfig():GetCollectible(pickup.SubType)

            if config:IsCollectible() and config.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST then             
				if not player:HasCollectible(GODMODE.registry.items.cloth_of_gold) then
					if player:GetCollectibleRNG(item.instance):RandomFloat() < 0.01*player:GetCollectibleNum(item.instance) then
						pickup:Morph(5,pickup.Variant,GODMODE.registry.items.cloth_of_gold, true)
					end
				end
			end
		end)
	end
end


return item