local monster = {}
monster.name = "Keepah (Shop Parrot)"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_init = function(self,ent)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
end
monster.npc_update = function(self, ent)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()
	local appear_flag = not (ent:GetSprite():IsPlaying("Appear") or ent:GetSprite():IsPlaying("Appear2")) and data.real_time > 2

	if data.bubble == nil then
		data.bubble = Sprite()
		data.bubble:Load("gfx/famil_parrot.anm2", true)
	end

	ent.Velocity = ent.Velocity * 0.8

	if appear_flag then
		local target_pos = player.Position

		if data.run_from ~= nil then
			if data.run_from:IsDead() then
				data.run_from = nil
			else
				target_pos = data.run_from.Position

				if (ent.Position - target_pos):Length() < ent.Size*16 then
					ent.Velocity = ent.Velocity + (ent.Position - target_pos) / 160.0
				end	
	
				if ent:GetSprite():IsEventTriggered("Flap") then
					ent.Velocity = ent.Velocity + (ent.Position - target_pos+Vector(ent:GetDropRNG():RandomInt(math.floor(ent.Size*16))-math.floor(ent.Size*8),ent:GetDropRNG():RandomInt(math.floor(ent.Size*16))-math.floor(ent.Size*8))) / 64.0
				end	
			end
		else
			if (ent.Position - target_pos):Length() > ent.Size*8 then
				local vel = (target_pos - ent.Position)
				ent.Velocity = ent.Velocity + vel:Resized(math.min(vel:Length(),64)) / 224.0
			end	

			if ent:GetSprite():IsEventTriggered("Flap") then
				ent.Velocity = ent.Velocity + (target_pos+Vector(ent:GetDropRNG():RandomInt(math.floor(ent.Size*16))-math.floor(ent.Size*8),ent:GetDropRNG():RandomInt(math.floor(ent.Size*16))-math.floor(ent.Size*8)) - ent.Position) / 64.0
			end
		end

		ent.FlipX = ent.Position.X - target_pos.X < 0
	end

	if data.real_time == 2 and not ent:GetSprite():IsPlaying("Appear2") or ent:GetSprite():IsFinished("Appear2") then
		local add = ""
		if data.run_from ~= nil then add = "Sweat" end
		
		ent:GetSprite():Play("Idle"..add,false)
	end

	if data.talk_sprite ~= nil then 
		if data.real_time % 5 == 4 and data.run_from ~= nil then 
			ent:PlaySound(GODMODE.sounds.keepah, 0.55, 0, false, 1.0-0.06125+ent:GetDropRNG():RandomFloat()*0.125)
		elseif data.real_time % 7 == 6 then 
			ent:PlaySound(GODMODE.sounds.keepah_panic, 0.45, 0, false, 1.0-0.06125+ent:GetDropRNG():RandomFloat()*0.125)
		end
	end

	if ent:GetSprite():IsFinished("Idle") or ent:GetSprite():IsFinished("Talk") or ent:GetSprite():IsFinished("IdleSweat") or ent:GetSprite():IsFinished("TalkSweat") and appear_flag then
		for _,ent2 in ipairs(Isaac.GetRoomEntities()) do
			if ent2:IsVulnerableEnemy() and not (ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or ent:HasEntityFlags(EntityFlag.FLAG_CHARM) or ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY_BALL)) then
				if data.run_from == nil then
					data.run_from = ent2
				elseif (data.run_from.Position - ent.Position):Length() > (ent2.Position - ent.Position):Length() then
					data.run_from = ent2
				end
			end
		end

		local add = ""
		if data.run_from ~= nil then add = "Sweat" end

		if ent:GetDropRNG():RandomInt(10) >= 9 then
			data.talk_sprite = "Bubble"..ent:GetDropRNG():RandomInt(8)
			
			if data.run_from ~= nil then
				data.talk_sprite = "BubbleFear"..ent:GetDropRNG():RandomInt(2)
			end
			
			ent:GetSprite():Play("Talk"..add,true)

			if data.bubble ~= nil then
				data.bubble:Play(data.talk_sprite,true)
			end
		else
			data.talk_sprite = nil
			ent:GetSprite():Play("Idle"..add,true)
		end
	end

	if data.bubble ~= nil and appear_flag then
		data.bubble:Update()
	end
end
monster.npc_post_render = function(self, ent, offset)
	local data = GODMODE.get_ent_data(ent)

	if data.bubble ~= nil then
		if ent:GetSprite():IsPlaying("Appear") then
			data.talk_sprite = "BubbleAppear"
			data.bubble:SetFrame("BubbleAppear", ent:GetSprite():GetFrame())
		elseif data.bubble:GetAnimation() == "BubbleAppear" then
			data.bubble:SetFrame(0)
		end

		data.bubble:Render(Isaac.WorldToScreen(ent.Position),Vector.Zero,Vector.Zero)
	end
end
monster.new_room = function(self)
	if Game():GetRoom():GetType() == RoomType.ROOM_SHOP then
		if GODMODE.save_manager.get_config("ShopParrot","true") == "true" then 
			local parrot = Isaac.Spawn(monster.type,monster.variant,0,Game():GetRoom():FindFreePickupSpawnPosition(Game():GetRoom():GetCenterPos()),Vector.Zero,nil)
			parrot.FlipX = parrot.Position.X - Isaac.GetPlayer().Position.X < 0

			if not Game():GetRoom():IsFirstVisit() then
				parrot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				parrot:GetSprite():Play("Appear2",true)
			else
				local data = GODMODE.get_ent_data(parrot)
				data.bubble = Sprite()
				data.bubble:Load("gfx/famil_parrot.anm2", true)
				data.talk_sprite = "BubbleAppear"
				data.bubble:Play(data.talk_sprite,true)
			end
		end
		local poses = {
			{pos=Game():GetRoom():GetCenterPos(),vel=RandomVector()*0.05},
			{pos=Game():GetRoom():GetTopLeftPos(),vel=Vector(math.abs(RandomVector().X),math.abs(RandomVector().Y)*0.25)*0.05+Vector(0.05,0)},
			{pos=Game():GetRoom():GetBottomRightPos(),vel=Vector(math.abs(RandomVector().X),math.abs(RandomVector().Y)*0.25)*-0.05-Vector(0.05,0)}
		}

		for _,pos in ipairs(poses) do
			local fog = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MIST, 0, pos.pos, pos.vel, nil)
			fog:Update()
			fog:Update()
			fog:Update()
		end
	end
end
return monster