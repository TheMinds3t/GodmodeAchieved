local item = {}
item.instance = Isaac.GetItemIdByName( "Nirvana" )
item.eid_description = "All enemies spawn with 80% health"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Every enemy and boss spawns with 80% max health if this item is held by any player."},
	},
}

item.get_scale = function(self)
	local num = GODMODE.nirvana_cache or 0
	return math.max(0.2,1.0 - 0.1 * num - 0.1)
end

item.new_room = function(self)
	GODMODE.nirvana_cache = GODMODE.util.total_item_count(item.instance)
end

item.npc_update = function(self,ent)
	if not GODMODE.util.is_valid_enemy(ent,true) then return end
	if not GODMODE.nirvana_cache then GODMODE.nirvana_cache = GODMODE.util.total_item_count(item.instance) end 

	if (GODMODE.nirvana_cache or 0) > 0 then 
		local data = GODMODE.get_ent_data(ent)
		data.nirvana_scale = data.nirvana_scale or {}

		if data.nirvana_scale[ent.Type..","..ent.Variant] == nil then 
			local scale = item:get_scale()
			ent.Scale = ent.Scale * (scale*0.5 + 0.5)
			data.nirvana_scale[ent.Type..","..ent.Variant] = 1
			ent.HitPoints = ent.HitPoints * scale
			ent.MaxHitPoints = ent.HitPoints
		end
	end
end

return item