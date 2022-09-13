local item = {}
item.instance = Isaac.GetItemIdByName( "Larval Therapy" )
item.eid_description = "Spawns a chigger when an enemy dies#Chiggers target the enemy with the highest health in the room"
item.eid_transforms = GODMODE.util.eid_transforms.LORD_OF_THE_FLIES..","..GODMODE.util.eid_transforms.SPIDERBABY
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When an enemy dies, creates a chigger that will target the healthiest enemy in the room for 25% of your damage per attack (up to 250% damage per chigger)."},
		{str = "Chiggers will deal tick damage 10 times before dying."},
	},
}

item.npc_kill = function(self,ent)
    if GODMODE.util.is_valid_enemy(ent, true, true) then 
        GODMODE.util.macro_on_players_that_have(item.instance, function(player)
            local spd = 5.0 + player:GetCollectibleRNG(item.instance):RandomFloat()
            local ang = math.rad(player:GetCollectibleRNG(item.instance):RandomFloat() * 360)
            local s = nil 
            
            if player:GetName() == "Recluse" and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
                s = Isaac.Spawn(3, Isaac.GetEntityVariantByName("Chigger"), 1, ent.Position+Vector(math.cos(ang)*spd,math.sin(ang)*spd), Vector(math.cos(ang)*spd,math.sin(ang)*spd), nil)
                s.MaxHitPoints = s.MaxHitPoints * 1.5
                s.HitPoints = s.MaxHitPoints
            else
                s = Isaac.Spawn(3, Isaac.GetEntityVariantByName("Chigger"), 0, ent.Position+Vector(math.cos(ang)*spd,math.sin(ang)*spd), Vector(math.cos(ang)*spd,math.sin(ang)*spd), nil)
            end
            
            s:ToFamiliar().Player = player
            s:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            s.CollisionDamage = player.Damage / 10.0 * 2.5
        end)
    end
end

-- item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
--     if enthit:IsVulnerableEnemy() and GODMODE.util.is_player_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc) and GODMODE.util.get_player_from_attack(entsrc):HasCollectible(item.instance) then
        
--     end
-- end

return item