local item = {}
item.instance = GODMODE.registry.items.larval_therapy
item.eid_description = "Spawns a chigger when an enemy dies#Chiggers target the enemy with the highest health in the room"
item.eid_transforms = GODMODE.util.eid_transforms.LORD_OF_THE_FLIES..","..GODMODE.util.eid_transforms.SPIDERBABY
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When an enemy dies, creates a chigger that will target the healthiest enemy in the room for (15% Damage + 0.5 * (Num Larval Therapy)) per attack (up to 250% damage per chigger)."},
		{str = "Chiggers will deal tick damage 10 times before dying."},
		{str = "If Reclusive Tendencies is held, Chiggers will be able to attack more before death, calculated 10 / ((Num Larval Therapy) + (Num Reclusive Tendencies))."},
	},
}

item.npc_kill = function(self,ent)
    if GODMODE.util.is_valid_enemy(ent, true, true) then 
        GODMODE.util.macro_on_players_that_have(item.instance, function(player)
            local recluse_flag = player:GetPlayerType() == GODMODE.registry.players.recluse
            local br_flag = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
            local num = player:GetCollectibleNum(item.instance)
            local chance_inc = tonumber(GODMODE.save_manager.get_player_data(player,"LarvalChanceInc","1"))
            
            -- recluse is 100%, others are stacking 33.3% chance
            if recluse_flag or player:GetCollectibleRNG(item.instance):RandomFloat() < chance_inc * 0.333 * num then 
                local spd = 5.0 + player:GetCollectibleRNG(item.instance):RandomFloat()
                local ang = math.rad(player:GetCollectibleRNG(item.instance):RandomFloat() * 360)
                local s = nil 

                if recluse_flag and br_flag then
                    s = Isaac.Spawn(GODMODE.registry.entities.chigger.type, GODMODE.registry.entities.chigger.variant, 1, ent.Position+Vector(math.cos(ang)*spd,math.sin(ang)*spd), Vector(math.cos(ang)*spd,math.sin(ang)*spd), player)
                    s.MaxHitPoints = s.MaxHitPoints * 1.5
                    s.HitPoints = s.MaxHitPoints
                else
                    s = Isaac.Spawn(GODMODE.registry.entities.chigger.type, GODMODE.registry.entities.chigger.variant, 0, ent.Position+Vector(math.cos(ang)*spd,math.sin(ang)*spd), Vector(math.cos(ang)*spd,math.sin(ang)*spd), player)
                end
                
                s:ToFamiliar().Player = player
                s:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                s.CollisionDamage = player.Damage / 10.0 * 1.5 + num * 0.5

                if not recluse_flag then 
                    GODMODE.save_manager.set_player_data(player,"LarvalChanceInc","1",true)
                end
            elseif not recluse_flag then 
                GODMODE.save_manager.set_player_data(player,"LarvalChanceInc",chance_inc + 1)
            end
        end)
    end
end

-- item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
--     if enthit:IsVulnerableEnemy() and GODMODE.util.is_player_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc):HasCollectible(item.instance) then
        
--     end
-- end

return item