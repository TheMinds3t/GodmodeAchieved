local monster = {}
monster.name = "Elohim's Throne"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, params)
    params[2].persistent_state = GODMODE.persistent_state.single_room
end

local item_group_clamps = {
	{
		x=function(x) return x < Game():GetRoom():GetCenterPos().X-32 end,
		y=function(y) return y > Game():GetRoom():GetCenterPos().Y end
	},
	{
		x=function(x) return x > Game():GetRoom():GetCenterPos().X+32 end,
		y=function(y) return y > Game():GetRoom():GetCenterPos().Y end
	},
	{
		x=function(x) return true end,
		y=function(y) return y < Game():GetRoom():GetCenterPos().Y-96 end
	},
}

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
	if not ent:GetSprite():IsPlaying("Idle") then
		ent:GetSprite():Play("Idle",false)
	end

	ent.Velocity = Vector(0,0)
	ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY

	if data.inited ~= true then
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS )
		data.inited = true
	end	
	
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

-- monster.post_render = function(self)
-- 	for i,ent in ipairs(Isaac.GetRoomEntities()) do
-- 		if ent.Type == 5 and ent.Variant == 100 then
-- 			local pos = Isaac.WorldToScreen(ent.Position)
-- 			Isaac.RenderText(ent:ToPickup().OptionsPickupIndex, pos.X, pos.Y, 1,1,1,1)
-- 		end
-- 	end
-- end

return monster