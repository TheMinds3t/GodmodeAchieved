local monster = {}
monster.name = "[GODMODE] Elohim's Throne"
monster.type = GODMODE.registry.entities.elohims_throne.type
monster.variant = GODMODE.registry.entities.elohims_throne.variant

monster.data_init = function(self, ent, data)
	if ent.Type == monster.type and ent.Variant == monster.variant and ent.SubType > GODMODE.registry.entities.elohims_throne.subtype then 
		-- data.persistent_state = GODMODE.persistent_state.single_room

		-- data.enter_room = function(ent)
		-- 	if not GODMODE.api.is_observatory() and ent.SubType == GODMODE.registry.entities.fake_god.subtype then ent:Remove() end

		-- 	GODMODE.log("resetting torch lighting flag...",true)
		-- 	data.set_lighting = nil
		-- end
	end
end

local item_group_clamps = {
	{
		x=function(x) return x < (GODMODE.room_center or GODMODE.room:GetCenterPos()).X-32 end,
		y=function(y) return y > (GODMODE.room_center or GODMODE.room:GetCenterPos()).Y end
	},
	{
		x=function(x) return x > (GODMODE.room_center or GODMODE.room:GetCenterPos()).X+32 end,
		y=function(y) return y > (GODMODE.room_center or GODMODE.room:GetCenterPos()).Y end
	},
	{
		x=function(x) return true end,
		y=function(y) return y < (GODMODE.room_center or GODMODE.room:GetCenterPos()).Y-96 end
	},
}

monster.set_torch_state = function(self, torch, data, state, sprite)
	data.lit = state
	if state == true then -- turn torch on
		sprite:Play("TorchOn",true)
	else -- otherwise, extinguish torch
		sprite:Play("TorchOff",true)
	end
end

monster.npc_update = function(self, ent, data, sprite)
	if (data.persistent_data and data.persistent_data.in_room) then 
		if ent.SubType < 2 then 
			if not sprite:IsPlaying("Idle") then
				sprite:Play("Idle",false)
			end

			ent.Velocity = Vector(0,0)
			ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
			
			if ent.SubType == GODMODE.registry.entities.elohims_throne.subtype then 
				GODMODE.util.macro_on_enemies(nil, EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, -1, function(item) 
					for l,clamp in ipairs(item_group_clamps) do
						local pickup = ent:ToPickup()

						if pickup.OptionsPickupIndex ~= l and pickup.OptionsPickupIndex > 0 and clamp.x(pickup.Position.X) and clamp.y(pickup.Position.Y) then
							pickup.OptionsPickupIndex = l
							break
						end
					end		
				end)
			end
		else -- ivory palace miniboss lock pieces 
			local num_minibosses_killed = tonumber(GODMODE.save_manager.get_data("PalaceMinibossKills","0"))

			if ent.SubType == GODMODE.registry.entities.fallen_light_lock.subtype then -- the door lock itself
				if data.enter_room == nil then 
					ent.SizeMulti = Vector(1.0,0.6)
					ent.SpriteOffset = Vector(0,-12)
				end

				-- account for the eyes on the door 
				local count = math.max(0,num_minibosses_killed - 2)

				if sprite:GetAnimation() == "DoorOpen" then 
					GODMODE.game:ShakeScreen(5)
				end

				-- door is unlocked!
				if num_minibosses_killed >= 2 then
					if sprite:GetAnimation() ~= "DoorOpened" and not sprite:IsPlaying("DoorOpen") then 
						if sprite:GetAnimation() == "DoorOpen" then 
							data.set_lighting = nil 
							sprite:Play("DoorOpened",true)
							ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
						else
							sprite:Play("DoorOpen",true)
						end
					end
				else -- door is locked
					local anim = "Door"..math.min(2,math.max(0,num_minibosses_killed))
					
					if not sprite:IsPlaying(anim) then 
						sprite:Play(anim,true)
						data.set_lighting = nil 
						GODMODE.log("started playing \'"..anim.."\'",true)
					end
				end

				if data.set_lighting == nil then 
					local cur_torch = 0
					data.torches = data.torches or {}
					GODMODE.log("setting torch lighting!", true)

					if #data.torches == 0 then 
						GODMODE.util.macro_on_enemies(nil, monster.type, monster.variant, GODMODE.registry.entities.ivory_torch.subtype, function(torch) 
							if torch:ToNPC() then 
								cur_torch = cur_torch + 1 
								torch:ToNPC().I1 = cur_torch
								table.insert(data.torches, torch)
							end
						end)
					end

					for i=1,#data.torches do 
						local torch = data.torches[i]

						if torch then 
							torch.Parent = ent 
							torch:GetSprite():Play("Torch"..(i > count and "On" or "Off"),true)
							GODMODE.log("set torch \'"..i.."\' to "..tostring(i > count),true)
						end
					end

					data.set_lighting = true 
				end
			elseif ent.SubType == GODMODE.registry.entities.ivory_torch.subtype then -- ivory torch
				ent.SpriteOffset = Vector(0,-8)

				-- if the torch is not managed by the FL lock above then it handles itself
				if ent.Parent == nil then 
					-- watch for miniboss clear
					if GODMODE.room:GetType() == RoomType.ROOM_MINIBOSS then 
						if Isaac.CountBosses() + Isaac.CountEnemies() == 0 then 
							-- proc once, after room clear
							if GODMODE.room:IsFirstVisit() and data.contributed_to_kills == nil and GODMODE.is_at_palace and GODMODE.is_at_palace() then 
								GODMODE.save_manager.set_data("PalaceMinibossKills", num_minibosses_killed + 1, true)
								data.contributed_to_kills = true 
							end
			
							if data.lit then 
								monster.set_torch_state(self, ent, data, false, sprite)
							end
						elseif not data.lit then  
							monster.set_torch_state(self, ent, data, true, sprite)
						end

					elseif not data.lit then 
						monster.set_torch_state(self, ent, data, true, sprite)
					end
				end

				if sprite:GetAnimation() == "TorchOff" then 
					ent.SizeMulti = Vector(0.5,0.5)
					ent.CollisionDamage = 0.0
				else 
					ent.SizeMulti = Vector(1,1)
					ent.CollisionDamage = 1.0
				end
			end
			
			local grid_index = GODMODE.room:GetGridIndex(ent.Position) 
			local targ_pos = GODMODE.room:GetGridPosition(grid_index)
			GODMODE.room:SetGridPath(grid_index, 950)
			ent.Velocity = targ_pos - ent.Position
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