local monster = {}
monster.name = "Elohim's Throne"
monster.type = GODMODE.registry.entities.elohims_throne.type
monster.variant = GODMODE.registry.entities.elohims_throne.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
		data.persistent_state = GODMODE.persistent_state.single_room
	end

	data.enter_room = function(ent)
		if not GODMODE.api.is_in_observatory() then ent:Remove() end 
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
	if state == true and sprite:GetAnimation() == "TorchOff" then -- turn torch on
		sprite:Play("TorchOn",true)
		if data.light ~= nil then data.light:Remove() data.light = nil end 

		data.light = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.LIGHT,0,torch.Position,Vector.Zero,torch)
		data.light:Update()
	elseif sprite:IsPlaying("TorchOn") then -- otherwise, extinguish torch
		sprite:Play("TorchOff",true)
		if data.light ~= nil then data.light:Remove() data.light = nil end 
	end
end

monster.npc_update = function(self, ent, data, sprite)
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
				data.enter_room = function(_)
					data.set_lighting = nil
				end

				ent.SizeMulti = Vector(1.0,0.6)
				ent.SpriteOffset = Vector(0,-12)
			end

			-- account for the eyes on the door 
			local count = math.max(0,num_minibosses_killed - 2)

			-- door is unlocked!
			if count > 0 then
				if not sprite:IsPlaying("Door") and not sprite:GetAnimation() == "DoorOpen" then 
					sprite:Play("DoorOpen",true)
				elseif sprite:IsFinished("DoorOpen") then 
					data.set_lighting = nil 
					sprite:Play("DoorOpened",true)
					ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
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
						monster.set_torch_state(self, torch, GODMODE.get_ent_data(torch), i > count, sprite)					
						GODMODE.log("set torch \'"..i.."\' to "..tostring(i > count),true)
					end
				end

				data.set_lighting = true 
			end
		elseif ent.SubType == GODMODE.registry.entities.ivory_torch.subtype then -- ivory torch
			ent.SpriteOffset = Vector(0,-8)

			-- watch for miniboss clear
			if GODMODE.room:GetType() == RoomType.ROOM_MINIBOSS then 
				if Isaac.CountBosses() + Isaac.CountEnemies() == 0 and sprite:IsPlaying("TorchOn") then 
					-- proc once, after room clear
					if GODMODE.room:IsFirstVisit() and data.contributed_to_kills == nil then 
						GODMODE.save_manager.set_data("PalaceMinibossKills", num_minibosses_killed + 1, true)
						data.contributed_to_kills = true 
					end

					monster.set_torch_state(self, ent, data, false, sprite)
				else
					sprite:Play(sprite:GetAnimation(),false)
				end
			elseif not sprite:IsPlaying("TorchOn") and not sprite:GetAnimation() == "TorchOff" then
				monster.set_torch_state(self, ent, data, true, sprite)
			end

			-- remove the light FX after the animation
			if sprite:GetAnimation() == "TorchOff" then 
				ent.SizeMulti = Vector(0.5,0.5)

				if sprite:IsFinished("TorchOff") and data.light then 
					data.light:Remove() 
				end
			else 
				ent.SizeMulti = Vector(1,1)
			end
		end

		local targ_pos = GODMODE.room:GetGridPosition(GODMODE.room:GetGridIndex(ent.Position))
		ent.Velocity = targ_pos - ent.Position
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