local item = {}
item.instance = Isaac.GetItemIdByName( "Dad's Balloon" )
item.eid_description = "Random chance to do one of the following:#Spawn a pool of freezing creep beneath the player#Fire a ring of 4 tears#Fire a ring of 8 tears#Fire a ring of 16 tears"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "On use, does one of the following:"},
      {str = " - 20% chance to fire a ring of 8 tears at a high speed"},
      {str = " - 20% chance to spawn a holy water puddle beneath the player"},
      {str = " - 35% chance to fire a ring of 16 tears at a medium speed"},
      {str = " - 25% chance to fire 4 tears at a medium speed"},
      {str = "Charges once every 4 seconds."},
    },
}
item.use_item = function(self, coll,rng,player,flags,slot,var_data)
    if coll == item.instance then
        local act = rng:RandomFloat()
        if act < 0.2 then
            local off = rng:RandomFloat() * 360
            for i=0,7 do 
                local ang = math.rad(0 + (360 / 8) * i+off)
                local speed = 12.0 + rng:RandomFloat() * 1
                local vec = Vector(math.cos(ang)*speed, math.sin(ang)*speed)
                local tear = player:FireTear(player.Position,vec,false, true, false)
            end
            return true
        elseif act < 0.4 then
            Game():Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER, player.Position, Vector(0,0),player, 0, player.InitSeed)
            return true
        elseif act < 0.75 then
            local off = rng:RandomFloat() * 360
            for i=0,15 do 
                local ang = math.rad(0 + (360 / 16) * i+off)
                local speed = 8.5 + rng:RandomFloat() * 4
                local vec = Vector(math.cos(ang)*speed, math.sin(ang)*speed)
                local tear = player:FireTear(player.Position,vec,false, true, false)
            end

            return true
        else
            local off = rng:RandomFloat() * 360
            for i=0,3 do 
                local ang = math.rad(0 + (360 / 4) * i+off)
                local speed = 8.5 + rng:RandomFloat() * 4
                local vec = Vector(math.cos(ang)*speed, math.sin(ang)*speed)
                local tear = player:FireTear(player.Position,vec,false, true, false)
            end
            return true
        end

        return false
    end
end

item.room_rewards = function(self,rng,pos)
	GODMODE.util.macro_on_players_that_have(item.instance, function(player)
		local slot = GODMODE.util.get_active_slot(player, item.instance)
		player:SetActiveCharge(40, slot)
		Game():GetHUD():FlashChargeBar(player, slot)
		SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
	end)
end

item.player_update = function(self,player)
    if player:HasCollectible(item.instance) then
		local data = GODMODE.get_ent_data(player)
		data.balloon_charge = (data.balloon_charge or -1) + 1
        local slot = GODMODE.util.get_active_slot(player, item.instance)
        
		if slot > -1 and player:GetActiveCharge(slot) < 40 and data.balloon_charge >= math.max(1,6 / (1 + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BATTERY))) then
			player:SetActiveCharge(player:GetActiveCharge(slot) + 1, slot)
			data.balloon_charge = 0
		end
    end
end

return item