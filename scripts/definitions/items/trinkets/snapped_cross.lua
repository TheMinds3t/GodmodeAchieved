local item = {}
item.instance = Isaac.GetTrinketIdByName( "Snapped Cross" )
item.eid_description = "10% chance to gain a shield for 3 seconds when you kill an enemy"
item.trinket = true

item.player_update = function(self,player)
	if player:HasTrinket(item.instance) then
        local data = GODMODE.get_ent_data(player)
        if not player:HasCollectible(Isaac.GetItemIdByName("Crossbones")) then
            data.crossbones = math.max(0, (data.crossbones or 0) - 1)

            if data.crossbones > 0 then 
                player:SetMinDamageCooldown(1)
            end
        end
	end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit and enthit:IsVulnerableEnemy() and GODMODE.util.is_player_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc):HasTrinket(item.instance) then
        GODMODE.util.macro_on_players_that_have(item.instance, function(player)
            local data = GODMODE.get_ent_data(player)
            if amount >= enthit.HitPoints and player:GetTrinketRNG(item.instance):RandomFloat() < 0.1 then
                GODMODE.util.macro_on_enemies(player,Isaac.GetEntityTypeByName("Crossbones Shield"),Isaac.GetEntityVariantByName("Crossbones Shield"),nil, function(shield) 
                    shield:GetSprite():Play("Break", true)
                end)
                local shield = Isaac.Spawn(Isaac.GetEntityTypeByName("Crossbones Shield"), Isaac.GetEntityVariantByName("Crossbones Shield"), 0, player.Position, Vector.Zero, player)
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
item.new_room = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        local data = GODMODE.get_ent_data(player)
        data.crossbones = 0
    end, true)
end

return item