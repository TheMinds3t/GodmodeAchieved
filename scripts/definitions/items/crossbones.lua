local item = {}
item.instance = Isaac.GetItemIdByName( "Crossbones" )
item.eid_description = "Gain a shield for 3 seconds when you kill 4 enemies"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "For every fourth enemy killed, gain a shield for 3 seconds."},
    },
	{ -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
      {str = "Due to modding limitations, the shield granted does not prevent holy mantle from being depleted, but will prevent death."},
    },
}

item.player_update = function(self, player)
	if player:HasCollectible(item.instance) then
        local data = GODMODE.get_ent_data(player)
        data.crossbones = math.max(0, (data.crossbones or 0) - 1)
    end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit:IsVulnerableEnemy() and GODMODE.util.is_player_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc):HasCollectible(item.instance) then
        GODMODE.util.macro_on_players_that_have(item.instance, function(player)
            local data = GODMODE.get_ent_data(player)
            if amount >= enthit.HitPoints then
                local kills = tonumber(GODMODE.save_manager.get_player_data(player,"CrossboneKills","0"))

                if kills >= 3 then
                    GODMODE.save_manager.set_player_data(player,"CrossboneKills", 0,true)
                    GODMODE.util.macro_on_enemies(player,Isaac.GetEntityTypeByName("Crossbones Shield"),Isaac.GetEntityVariantByName("Crossbones Shield"),nil, function(shield) 
                        shield:GetSprite():Play("Break", true)
                    end)

                    local shield = Isaac.Spawn(Isaac.GetEntityTypeByName("Crossbones Shield"), Isaac.GetEntityVariantByName("Crossbones Shield"), 0, player.Position, Vector.Zero, player)
                    shield:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    shield:GetSprite():Play("Form", false)
                    data.crossbones = 230
                else
                    GODMODE.save_manager.set_player_data(player, "CrossboneKills", kills+1,true)
                end

                -- shield.SpawnerEntity = player
            end
        end)
    elseif enthit:ToPlayer() and enthit:ToPlayer():HasCollectible(item.instance) then
        local data = GODMODE.get_ent_data(enthit)

        if (data.crossbones or 0) > 0 then
            return false
        end
    end
end

item.new_room = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        local data = GODMODE.get_ent_data(player)
        data.crossbones = 0
    end)
end

return item