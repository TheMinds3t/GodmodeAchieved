local item = {}
item.instance = GODMODE.registry.items.gold_plated_battery
item.eid_description = "Hold space to spend 5 coins on one charge of your active item"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Holding the use active button down with more than 5 coins will spend 5 coins to charge your active item once."},
		{str = "Can be done to fully charge the active item if you have enough coins."},
	},
}

local cost = 5
local charge_time = 40

item.player_update = function(self,player, data)
	if player:HasCollectible(item.instance) then
		local percent = math.max(0,(charge_time-(data.gold_battery_cooldown or charge_time))/charge_time)

		if player:IsFrame(15,1) or data.should_colorize == nil then 
			data.should_colorize = GODMODE.util.find_uncharged_active_slot(player) > -1 and player:GetNumCoins() >= cost
		end

		if data.should_colorize == false or data.should_colorize == nil then 
			percent = 0

			if (data.gold_battery_cooldown or charge_time) == 0 then data.gold_battery_cooldown = nil else 
				data.gold_battery_cooldown = math.max(0,((data.gold_battery_cooldown or charge_time) * 0.9 - 3))
			end
		else 
			if Input.IsActionPressed (ButtonAction.ACTION_ITEM, player.ControllerIndex) then
				data.gold_battery_cooldown = math.max(0,(data.gold_battery_cooldown or charge_time) - 1)
	
				if data.gold_battery_cooldown <= 0 then
					local slot = GODMODE.util.find_uncharged_active_slot(player)
					if slot > -1 then
						if player:GetNumCoins() >= cost then
							player:SetActiveCharge(player:GetActiveCharge(slot) + 1, slot)
							player:AddCoins(-cost)
	
							for i=1,cost do
								local c = Isaac.Spawn(GODMODE.registry.entities.shatter_coin.type,GODMODE.registry.entities.shatter_coin.variant,0,player.Position,Vector(player:GetCollectibleRNG(item.instance):RandomInt(10)-5,player:GetCollectibleRNG(item.instance):RandomInt(10)-5),player)
								c:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
								c.Velocity = Vector(player:GetCollectibleRNG(item.instance):RandomInt(8)-4,player:GetCollectibleRNG(item.instance):RandomInt(8)-4)
							end
	
							data.gold_battery_cooldown = charge_time
							local active_item = player:GetActiveItem(slot)
							
							if player:GetActiveCharge(slot) == GODMODE.util.get_max_charge(active_item) then 
								player:AnimateCollectible(active_item)
								GODMODE.sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
								GODMODE.game:GetHUD():FlashChargeBar(player, slot)
							else
								player:AnimateCollectible(item.instance)
								GODMODE.sfx:Play(SoundEffect.SOUND_BEEP)
							end
						end
					end
				end
			else
				data.gold_battery_cooldown = charge_time
			end	
		end

		player:SetColor(Color.Lerp(player:GetColor(), Color(1,1,1,1,0.5,0.4,0),percent), 1, 99, false, false)
	end
end

return item