local ret = {}
ret["ItBreathes"] = {
	{TYPE=1, VARIANT=0, SUBTYPE=0, NAME="It Breathes", DIFFICULTY=1, WEIGHT=1, WIDTH=13, HEIGHT=7, SHAPE=1,
		{ISDOOR=true, GRIDX=6, GRIDY=7, SLOT=3, EXISTS=true},
		{ISDOOR=true, GRIDX=13, GRIDY=3, SLOT=2, EXISTS=true},
		{ISDOOR=true, GRIDX=-1, GRIDY=3, SLOT=0, EXISTS=true},
		{ISDOOR=true, GRIDX=6, GRIDY=-1, SLOT=1, EXISTS=true},
		{ISDOOR=false, GRIDX=6, GRIDY=3,
			{TYPE=800, VARIANT=128, SUBTYPE=0, WEIGHT=0},
		},
	},
}

return ret