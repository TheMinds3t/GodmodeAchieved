local monster = {}
monster.name = "Elohim's Throne"
monster.type = GODMODE.registry.entities.elohims_throne.type
monster.variant = GODMODE.registry.entities.elohims_throne.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
		data.persistent_state = GODMODE.persistent_state.single_room
	end
end

local item_group_clamps = {
	{
		x=function(x) return x < GODMODE.room:GetCenterPos().X-32 end,
		y=function(y) return y > GODMODE.room:GetCenterPos().Y end
	},
	{
		x=function(x) return x > GODMODE.room:GetCenterPos().X+32 end,
		y=function(y) return y > GODMODE.room:GetCenterPos().Y end
	},
	{
		x=function(x) return true end,
		y=function(y) return y < GODMODE.room:GetCenterPos().Y-96 end
	},
}

monster.npc_update = function(self, ent, data, sprite)
	if not sprite:IsPlaying("Idle") then
		sprite:Play("Idle",false)
	end

	ent.Velocity = Vector(0,0)
	ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY

	if data.inited ~= true then
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
		data.inited = true
	end	
	
	if ent.SubType == 0 then 
		for i,ent in ipairs(Isaac.GetRoomEntities()) do
			if ent.Type == 5 and ent.Variant == 100 then
				for l,clamp in ipairs(item_group_clamps) do
					local pickup = ent:ToPickup()
	
					if pickup.OptionsPickupIndex ~= l and pickup.OptionsPickupIndex > 0 and clamp.x(pickup.Position.X) and clamp.y(pickup.Position.Y) then
						pickup.OptionsPickupIndex = l
						break
					end
				end
			end
		end	
	end

	if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
		ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
	end
end

-- monster.post_render = function(self)
-- 	for i,ent in ipairs(Isaac.GetRoomEntities()) do
-- 		if ent.Type == 5 and ent.Variant == 100 then
-- 			local pos = Isaac.WorldToScreen(ent.Position)
-- 			Isaac.RenderText(ent:ToPickup().OptionsPickupIndex, pos.X, pos.Y, 1,1,1,1)
-- 		end
-- 	end
-- end

return monster