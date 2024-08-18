local item = include("scripts.definitions.items.purity_vessel_base")
item.instance = GODMODE.registry.items.vessel_of_purity_3
item.next_instance = nil

item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Grants +1 tears and +3 damage, and additionally allows the Fallen Light's final phase to appear."},
        {str = "If the player takes damage from the Fallen Light, the player explodes and the Bloodied Vessel of Purity is lost."}
	},
}


item.bomb_damage = 500
item.bomb_scale = 4.5
item.tears = 1.0
item.attack = 3

return item