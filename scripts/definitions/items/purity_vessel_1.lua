local item = include("scripts.definitions.items.purity_vessel_base")
item.instance = Isaac.GetItemIdByName( "Cracked Vessel of Purity" )
item.next_instance = Isaac.GetItemIdByName("Bloodied Vessel of Purity")

item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Grants +0.5 tears and +1 damage, and additionally allows the Fallen Light's final phase to appear."},
        {str = "If the player takes damage from the Fallen Light, the player explodes and the Cracked Vessel of Purity becomes the Bloodied Vessel of Purity."}
	},
}


item.bomb_damage = 250
item.bomb_scale = 2.5
item.tears = 0.5
item.attack = 1

return item