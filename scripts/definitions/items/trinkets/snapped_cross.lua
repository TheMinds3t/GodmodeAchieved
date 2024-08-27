local item = {}
item.instance = GODMODE.registry.trinkets.snapped_cross
item.eid_description = "10% chance to gain a shield for 3 seconds when you kill an enemy"
item.trinket = true
item.encyc_entry = {
    { -- Effects
        {str = "Effects", fsize = 2, clr = 3, halign = 0},
        {str = "- When killing an enemy, 10% chance to gain a shield that lasts for 3 seconds."},
    },
}

item.player_update = function(self,player,data)
	if player:HasTrinket(item.instance) then
        if not player:HasCollectible(GODMODE.registry.items.crossbones) then
            data.crossbones = math.max(0, (data.crossbones or 0) - 1)

            if GODMODE.validate_rgon() and data.crossbones > 0 then 
                player:SetMinDamageCooldown(data.crossbones)
            end
        end
	end
end



local hit_func = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit and enthit:IsVulnerableEnemy() and GODMODE.util.is_player_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc):HasTrinket(item.instance) then
        GODMODE.util.macro_on_players_that_have(item.instance, function(player)
            local data = GODMODE.get_ent_data(player)
            if amount >= enthit.HitPoints and player:GetTrinketRNG(item.instance):RandomFloat() < 0.1 then
                GODMODE.util.macro_on_enemies(player,GODMODE.registry.entities.crossbones_shield.type,GODMODE.registry.entities.crossbones_shield.variant,nil, function(shield) 
                    shield:GetSprite():Play("Break", true)
                end)
                local shield = Isaac.Spawn(GODMODE.registry.entities.crossbones_shield.type, GODMODE.registry.entities.crossbones_shield.variant, 0, player.Position, Vector.Zero, player)
                shield:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                shield:GetSprite():Play("Form", false)
                data.crossbones = 230
                -- shield.SpawnerEntity = player
            end
        end, true)
    elseif enthit:ToPlayer() and enthit:ToPlayer():HasTrinket(item.instance) then
        local data = GODMODE.get_ent_data(enthit)

        if data.crossbones > 0 then
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
    end, true)
end

return item