local item = include("scripts.definitions.items.purity_vessel_base")
item.instance = Isaac.GetItemIdByName( "Vessel of Purity" )
item.next_instance = Isaac.GetItemIdByName("Cracked Vessel of Purity")
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Grants no real effects aside from being a quest item that allows the Fallen Light's final phase to appear."},
        {str = "If the player takes damage from the Fallen Light, the player explodes and the Vessel of Purity becomes a Cracked Vessel of Purity."}
	},
}


return item