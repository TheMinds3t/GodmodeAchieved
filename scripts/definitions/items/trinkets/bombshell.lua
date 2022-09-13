local item = {}
item.instance = Isaac.GetTrinketIdByName( "Bombshell" )
item.eid_description = "Placing a bomb spawns a poisonous cloud above the bomb and makes the player emit green creep for 5 seconds"
item.trinket = true

item.player_update = function(self,player)
	if player:HasTrinket(item.instance) then
        local data = GODMODE.get_ent_data(player)
        data.bombshell = math.max(0, (data.bombshell or 0) - 1)

        if data.bombshell > 0 and data.bombshell % 10 == 0 then
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_GREEN, 0, player.Position, Vector.Zero, player)
        end
	end
end

item.new_room = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        local data = GODMODE.get_ent_data(player)
        data.bombshell = 0
    end, true)
end

item.bomb_init = function(self, bomb)
    if bomb.SpawnerEntity ~= nil and bomb.SpawnerEntity.Type == EntityType.ENTITY_PLAYER then
        local player = bomb.SpawnerEntity:ToPlayer()
        if player:HasTrinket(item.instance) then
            GODMODE.get_ent_data(player).bombshell = 150
            local cloud = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SMOKE_CLOUD, 0, bomb.Position, Vector.Zero, bomb.SpawnerEntity)
            cloud:ToEffect():SetTimeout(150*player:GetTrinketMultiplier(item.instance))
        end
    end
end

return item