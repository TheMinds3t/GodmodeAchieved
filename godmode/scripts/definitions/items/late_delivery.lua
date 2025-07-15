local item = {}
item.instance = GODMODE.registry.items.late_delivery
item.eid_description = "↑ +0.5 Tears#↑ Spawns an item after dealing 2500 damage#Spawns more items, but for an additional 5000 damage each time"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Grants +0.5 tears."},
		{str = "After dealing 2500 damage, an angelic baby familiar will appear and create an item pedestal from the current room's item pool."},
		{str = "After the first angelic baby has appeared, the item will continue to spawn more angelic babies, but for an additional 5000 damage dealt each time (i.e. first at 2500, second at 7500, third at 12500)."},
	},
}


item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.5*player:GetCollectibleNum(item.instance))
	end
end


item.render_player_ui = function(self,player,index)
	if player:HasCollectible(item.instance) then
		if item.delivery_anim == nil then
			item.delivery_anim = Sprite()
			item.delivery_anim:Load("/gfx/famil_late_delivery.anm2", true)
			item.delivery_anim.Color = Color(0.8,0.8,0.8,1) --fixes over-exposure problem
		end


		local data = GODMODE.get_ent_data(player)
		data.late_delivery_counter = tonumber(GODMODE.save_manager.get_player_data(player, "DeliveryCounter", "2500"))
		data.late_deliveries = tonumber(GODMODE.save_manager.get_player_data(player, "LateDeliveries", "0"))

		local anim = math.min(6,math.max(math.floor((data.late_delivery_counter + 2500 / 6 * 0.8) / 2500 * 6),1))
		if data.late_delivery_counter > 0 then
			data.late_delivery_anim = math.max(0,(data.late_delivery_anim or 0) - 1)
			local flash_time = data.late_delivery_anim
			item.delivery_anim:SetFrame("ChargeBottomFlash",11-flash_time)

			local pos = GODMODE.util.get_hud_corner_pos(GODMODE.util.get_player_index(player)) + Vector(54,-2)
			-- GODMODE.log("pos.x="..pos.X..",pos.y="..pos.Y,true)

			item.delivery_anim:Render(pos, Vector(0,0), Vector(0,0))
			local v_x = 80 - 80 * (data.late_delivery_counter / (2500+data.late_deliveries*5000))
			item.delivery_anim:Play("ChargeTop",false)
			item.delivery_anim:Render(pos, Vector(0,0), Vector(9+v_x,0))
			item.delivery_anim:Update()
			--Isaac.RenderText("Delivery Counter: "..delivery_counter,16,52,255,255,255,255)
		end
	end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if GODMODE.util.is_player_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc) and enthit:IsVulnerableEnemy() then
		GODMODE.util.macro_on_players_that_have(item.instance, function(player)
			local data = GODMODE.get_ent_data(player)

			data.late_delivery_counter = tonumber(GODMODE.save_manager.get_player_data(player, "DeliveryCounter", "2500")) - math.min(enthit.HitPoints, amount)
			GODMODE.save_manager.set_player_data(player, "DeliveryCounter", data.late_delivery_counter,true)
			data.late_delivery_anim = 11

			if data.late_delivery_counter <= 0 then
				data.late_deliveries = tonumber(GODMODE.save_manager.set_player_data(player, "LateDeliveries", tonumber(GODMODE.save_manager.get_player_data(player, "LateDeliveries", "0")) + 1,true))
				Isaac.Spawn(GODMODE.registry.entities.late_delivery.type,GODMODE.registry.entities.late_delivery.variant,0,GODMODE.room:GetRandomPosition(48),Vector(0,0),player)
				GODMODE.sfx:Play(SoundEffect.SOUND_SUPERHOLY, Options.SFXVolume*3.0, 0, false, 1)

				data.late_delivery_counter = 2500 + 5000 * data.late_deliveries	
				GODMODE.save_manager.set_player_data(player, "DeliveryCounter", data.late_delivery_counter,true)
			end
		end)
	end
end

return item