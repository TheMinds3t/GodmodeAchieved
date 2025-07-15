local item = {}
item.instance = GODMODE.registry.items.crossbones
item.eid_description = "Gain a shield for 3 seconds when you kill 4 enemies"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "For every fourth enemy killed, gain a shield for 3 seconds. This does not stack."},
    },
	{ -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
      {str = "Without Repentogon, due to modding limitations, the shield granted does not prevent holy mantle from being depleted, but will prevent death."},
    },
}

item.player_update = function(self, player,data)
	if player:HasCollectible(item.instance) then
        data.crossbones = math.max(0, (data.crossbones or 0) - 1)

        if GODMODE.validate_rgon() and data.crossbones > 0 then 
            player:SetMinDamageCooldown(data.crossbones)
        end
    end
end

local hit_func = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit:IsVulnerableEnemy() and GODMODE.util.is_player_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc):HasCollectible(item.instance) then
        GODMODE.util.macro_on_players_that_have(item.instance, function(player)
            local data = GODMODE.get_ent_data(player)
            if amount >= enthit.HitPoints then
                local kills = tonumber(GODMODE.save_manager.get_player_data(player,"CrossboneKills","0"))

                if kills >= 3 then
                    GODMODE.save_manager.set_player_data(player,"CrossboneKills", 0,true)
                    GODMODE.util.macro_on_enemies(player,GODMODE.registry.entities.crossbones_shield.type,GODMODE.registry.entities.crossbones_shield.variant,nil, function(shield) 
                        shield:GetSprite():Play("Break", true)
                    end)

                    local shield = Isaac.Spawn(GODMODE.registry.entities.crossbones_shield.type, GODMODE.registry.entities.crossbones_shield.variant, 0, player.Position, Vector.Zero, player)
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

if GODMODE.validate_rgon() then 
    item.pre_player_hit = hit_func
else
    item.npc_hit = hit_func
end


item.new_room = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        local data = GODMODE.get_ent_data(player)
        data.crossbones = 0
    end)
end

return item