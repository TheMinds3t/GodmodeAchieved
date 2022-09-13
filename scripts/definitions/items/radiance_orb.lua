local item = {}
item.instance = Isaac.GetItemIdByName( "Orb of Radiance" )
item.eid_description = "On use, summons a ring of spectral piercing godhead tears that rotates around you for a small period of time #12 seconds to full charge"
item.eid_transforms = GODMODE.util.eid_transforms.ANGEL

item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, summons six spectral, piercing godhead tears that rapidly rotate around you."},
        {str = "Each tear deals 30% of your damage + 1, in addition to the halo damage."},
        {str = "The item takes 12 seconds to recharge."},
	},
}


item.player_update = function(self, player)
	if player:HasCollectible(item.instance) then
		local data = GODMODE.get_ent_data(player)
		data.radiance_charge = data.radiance_charge or 0
		data.radiance_tears = data.radiance_tears or {}
		local slot = GODMODE.util.get_active_slot(player, item.instance)

		if player:GetActiveCharge(slot) < 24 and data.radiance_charge >= 30 / (1 + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BATTERY)) then
			player:SetActiveCharge(player:GetActiveCharge() + 1, slot)

			if player:GetActiveCharge(slot) == 24 then 
				Game():GetHUD():FlashChargeBar(player, slot)
                SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
			end
			data.radiance_charge = 0
		end

		if #data.radiance_tears == 0 then
			data.radiance_charge = data.radiance_charge + 1
		end

		local flag = false
		local flag1 = false
		for _,tear in ipairs(data.radiance_tears) do
			if tear then
				local te = tear.tear
				local time = tear.time
				local scale = 1.0 - math.max(0,math.abs(time)-10) / 60.0
				te.Scale = scale * 3
				if time <= -60 then te:Kill() flag1 = true end
				if time == 59 then 	player:AnimateCollectible(item.instance, "LiftItem", "PlayerPickupSparkle") end
				time = time - 1

				local offset = math.rad(360 / 5 * tear.index + time * 4)
				te.Position = player.Position + Vector(math.cos(offset)*128*scale,math.sin(offset)*128*scale)
				te.FallingSpeed = 0
				te.CollisionDamage = player.Damage * 0.3 + 1.0
				if te:IsDead() or flag1 then tear.disable = true flag = true end
				tear.time = time
			end
		end

		if flag then
			player:AnimateCollectible(item.instance, "HideItem", "PlayerPickupSparkle")		
			local disabled = {}
			for i=1,#data.radiance_tears do
				if data.radiance_tears[i] and not data.radiance_tears[i].disable then
					table.insert(disabled, data.radiance_tears[i])
				end
			end
			data.radiance_tears = disabled
		end
	end
end

item.room_rewards = function(self,rng,pos)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player)
		local slot = GODMODE.util.get_active_slot(player, item.instance)
		player:SetActiveCharge(24, slot)
		Game():GetHUD():FlashChargeBar(player, slot)
		SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
	end)
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
		local data = GODMODE.get_ent_data(player)

		for i=0,4 do 
			local t = player:FireTear(player.Position,Vector(0,0),false,true,false)
			t.TearFlags = TearFlags.TEAR_NORMAL | TearFlags.TEAR_GLOW | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL
			t.Height = -90
			t.CollisionDamage = player.Damage * 2.0 + 20
			local t1 = {}
			t1.tear = t
			t1.time = 60
			t1.index = i
			data.radiance_charge = 0
			table.insert(data.radiance_tears, t1)
		end
		return true
	end
end

item.new_room = function(self)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player)
		local data = GODMODE.get_ent_data(player)
		data.radiance_charge = 0
		data.radiance_tears = {}
	end)
end

return item