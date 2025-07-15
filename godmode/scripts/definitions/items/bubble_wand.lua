local item = {}
item.instance = GODMODE.registry.items.bubble_wand
item.eid_description = "↑ Spawns a wave of bubbles dealing 100% damage on entering a room# The amount of bubbles correlates with how much red health is missing and how many soul hearts the player has# Bubbles have a 25% chance at 10 luck to be larger and explode into projectiles on popping"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = " - On entering a room, spawns 3-5 + ((red health missing) + (soul hearts)) / 2 bubbles that seek nearby enemies before popping."},
      {str = " - Each bubble has a 5% chance, up to 25% chance at 10 luck, to be a larger bubble that creates 8 projectiles upon popping."},
    },
}

item.new_room = function(self)
	if not GODMODE.room:IsClear() then 
		GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
			local count = 3 + player:GetCollectibleRNG(item.instance):RandomInt(3) + (player:GetMaxHearts() - player:GetHearts())/4 + player:GetSoulHearts()/4
			count = math.ceil(count + count * (player:GetCollectibleNum(item.instance) - 1) * 0.3)
			local vel = GODMODE.level.EnterDoor
	
			for i=0,count do 
				local bubble = nil 
	
				if player:GetCollectibleRNG(item.instance):RandomFloat() < (math.min(10,math.max(0,player.Luck))*0.2+0.05) then 
					bubble = Isaac.Spawn(GODMODE.registry.entities.bubbly_plum_bubble_l.type,GODMODE.registry.entities.bubbly_plum_bubble_l.variant,GODMODE.registry.entities.bubbly_plum_bubble_l.subtype,player.Position,player.Velocity,player)
				else
					bubble = Isaac.Spawn(GODMODE.registry.entities.bubbly_plum_bubble_s.type,GODMODE.registry.entities.bubbly_plum_bubble_s.variant,GODMODE.registry.entities.bubbly_plum_bubble_s.subtype,player.Position,player.Velocity,player)
				end
	
				bubble:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				bubble:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags() & ~EntityFlag.FLAG_NO_STATUS_EFFECTS & ~EntityFlag.FLAG_NO_FLASH_ON_DAMAGE)
				bubble:AddEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)

				if bubble.SubType == 2 then 
					bubble:ToNPC().I2 = 1
					bubble.CollisionDamage = player.Damage * 0.75
				else 
					bubble:ToNPC().I2 = 2
					bubble.CollisionDamage = player.Damage * 1.5
				end
				GODMODE.get_ent_data(bubble).timeout = (GODMODE.get_ent_data(bubble).timeout or (100+(player:GetCollectibleRNG(item.instance):RandomInt(30)-15))) + 50
	
				if vel > -1 then 
					bubble.Velocity = Vector(1,0):Rotated((vel%4)*90-90+player:GetCollectibleRNG(item.instance):RandomFloat()*180):Resized(3.0+player:GetCollectibleRNG(item.instance):RandomFloat()*6.0)
				end
	
				bubble:Update()
			end
		end)	
	end
end

return item