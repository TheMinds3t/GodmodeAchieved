local item = {}
item.instance = Isaac.GetItemIdByName( "Cloth on a String" )
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

		local dmg = ((count - 1) * 0.05) * GODMODE.util.total_item_count(item.instance) + GODMODE.util.total_item_count(Isaac.GetItemIdByName("Cloth of Gold")) * 0.25

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
    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM and GODMODE.achievements.is_item_unlocked(Isaac.GetItemIdByName("Cloth of Gold")) then
		GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
			local data = GODMODE.get_ent_data(player)
			if not player:HasCollectible(Isaac.GetItemIdByName("Cloth of Gold")) then
				if player:GetCollectibleRNG(item.instance):RandomFloat() < 0.01*player:GetCollectibleNum(item.instance) then
					pickup:Morph(5,pickup.Variant,Isaac.GetItemIdByName("Cloth of Gold"), true)
				end
			end
		end)
	end
end


return item