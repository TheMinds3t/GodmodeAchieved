local monster = {}
monster.name = "Keepah (Shop Parrot)"
monster.type = GODMODE.registry.entities.keepah.type
monster.variant = GODMODE.registry.entities.keepah.variant
local donation_variant = {DONATION_MACHINE=8}
local donate_buy_cooldown = 30
local max_volume_range = 320 --silent
local min_volume_range = 80 --loudest
local anger_threshold = 3

local is_shop = function()
	return (GODMODE.room_type or GODMODE.room:GetType()) == RoomType.ROOM_SHOP
end

monster.npc_init = function(self,ent,data,sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
end

monster.npc_update = function(self, ent, data, sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	

	local player = ent:GetPlayerTarget()
	local appear_flag = not (sprite:IsPlaying("Appear") or sprite:IsPlaying("Appear2")) and data.real_time > 2

	if data.bubble == nil then
		data.bubble = Sprite()
		data.bubble:Load("godmode/gfx/famil_parrot.anm2", true)
	end

	ent.Velocity = ent.Velocity * 0.8

	if appear_flag then
		local target_pos = player.Position + Vector(1,0)
			:Rotated((ent.InitSeed + ent.FrameCount * (2 + (ent.InitSeed % 20) / 20)) % 360)
			:Resized((ent.InitSeed / 250.0) % 60 + ent.Size * 2)

		if data.run_from ~= nil then
			if data.run_from:IsDead() or not data.run_from:IsVisible() then
				data.run_from = nil
				-- GODMODE.log("run from is gone!",true)
			else
				target_pos = data.run_from.Position
				local room_state = ent.Position - target_pos
				local dist = (ent.Position - target_pos):Length()

				-- too close to enemy for keepah
				if ent.SubType == 0 and is_shop() then 
					if dist < ent.Size*16 then
						if is_shop() then 
							ent.Velocity = ent.Velocity + room_state:Resized(math.min(room_state:Length(),35)) / 80.0
						end
					end
				else
					room_state = target_pos - ent.Position 
					ent.Velocity = ent.Velocity + room_state:Resized(math.min(room_state:Length(),35)) / 20.0
				end
	
				if sprite:IsEventTriggered("Flap") then
					ent.Velocity = ent.Velocity + (room_state
					+Vector(
						ent:GetDropRNG():RandomInt(math.floor(ent.Size*16))-math.floor(ent.Size*8),
						ent:GetDropRNG():RandomInt(math.floor(ent.Size*16))-math.floor(ent.Size*8))) / 48.0
				end	
			end
		else
			if (ent.Position - target_pos):Length() > ent.Size*8 then
				local vel = (target_pos - ent.Position)
				ent.Velocity = ent.Velocity + vel:Resized(math.min(vel:Length(),64)) / 192.0
			end	

			if sprite:IsEventTriggered("Flap") then
				ent.Velocity = ent.Velocity + (target_pos+Vector(ent:GetDropRNG():RandomInt(math.floor(ent.Size*16))-math.floor(ent.Size*8),ent:GetDropRNG():RandomInt(math.floor(ent.Size*16))-math.floor(ent.Size*8)) - ent.Position) / 48.0
			end
		end

		ent.FlipX = ent.Position.X - target_pos.X < 0
	end

	if data.real_time == 2 and not sprite:IsPlaying("Appear2") or sprite:IsFinished("Appear2") then
		local add = ""
		if data.run_from ~= nil then add = "Sweat" end
		
		sprite:Play("Idle"..add,false)
	end

	if data.talk_sprite ~= nil and GODMODE.save_manager.get_config("MuteShopBird","false") == "false" then 
		local volume_mod = 1 - math.min(1,((ent.Position - player.Position):Length()- min_volume_range) / (max_volume_range))
		data.time = math.floor(data.time)

		if volume_mod > 0 then 
			local pitch_off = ent:GetDropRNG():RandomFloat()
			if data.run_from ~= nil then 
				if data.time % 7 == 6 then -- panic
					ent:PlaySound(GODMODE.registry.sounds.keepah_panic, 0.45*volume_mod, 0, false, 0.9-0.125+pitch_off*0.25)
				end
			else 
				if (data.donate or 0) > 0 then 
					if data.time % 5 == 3 then -- donate
						ent:PlaySound(GODMODE.registry.sounds.keepah, 0.55*volume_mod, 0, false, 1.1-0.125+pitch_off*0.25)
					end
				elseif (data.buy or 0) > 0 then -- buy
					if data.time % 6 == 5 then 
						ent:PlaySound(GODMODE.registry.sounds.keepah, 0.55*volume_mod, 0, false, 1-0.125+pitch_off*0.25)
					end
				elseif data.time % 7 == 4 then -- conversation
					ent:PlaySound(GODMODE.registry.sounds.keepah_panic, 0.45*volume_mod, 0, false, 1.0-0.0625+pitch_off*0.125)
				end	
			end	
		end
	end

	if sprite:IsFinished("Idle") or sprite:IsFinished("Talk") or sprite:IsFinished("IdleSweat") or sprite:IsFinished("TalkSweat") and appear_flag then
		for _,ent2 in ipairs(Isaac.GetRoomEntities()) do
			if GODMODE.util.is_valid_enemy(ent2,true) and not 
					(ent2:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or 
					ent2:HasEntityFlags(EntityFlag.FLAG_CHARM) or 
					ent2:HasEntityFlags(EntityFlag.FLAG_FRIENDLY_BALL)) and not (ent2.Type == monster.type and ent2.Variant == monster.variant) then
				if data.run_from == nil then
					data.run_from = ent2
				elseif (data.run_from.Position - ent.Position):Length() > (ent2.Position - ent.Position):Length() then
					data.run_from = ent2
				end
			end
		end

		data.talk_chance = (data.talk_chance or 0) + 1

		local add = ""
		if data.run_from ~= nil then add = "Sweat" end
		sprite.PlaybackSpeed = 1
		local reset_buy_donate = false

		if (data.donate or 0) > 0 and ent:GetDropRNG():RandomInt(5) >= 5 - data.talk_chance then
			data.talk_sprite = "BubbleDonate"..(ent:GetDropRNG():RandomInt(6)+1)
			sprite.PlaybackSpeed = sprite.PlaybackSpeed * 0.8
			data.talk_chance = 0
		elseif (data.buy or 0) > 0 and 1 >= 3 - data.talk_chance then
			data.talk_sprite = "BubbleBuy"..(ent:GetDropRNG():RandomInt(6)+1)
			sprite.PlaybackSpeed = sprite.PlaybackSpeed * 1.2
			data.talk_chance = 0
		elseif data.run_from ~= nil and ent:GetDropRNG():RandomInt(3) >= 5 - data.talk_chance then
			data.talk_sprite = "BubbleFear"..ent:GetDropRNG():RandomInt(2)
			
			if ent.SubType > 0 then 
				data.talk_sprite = "BubbleFear3"
			end

			data.talk_chance = 0
			reset_buy_donate = true 
		elseif ent:GetDropRNG():RandomInt(8) >= 10 - data.talk_chance then
			data.talk_sprite = "Bubble"..ent:GetDropRNG():RandomInt(8)
			data.talk_chance = 0
			reset_buy_donate = true 
		else
			data.talk_sprite = nil
			reset_buy_donate = true 
		end

		if reset_buy_donate then
			data.buy = 0
			data.donate = 0
		end

		if data.bubble ~= nil and data.talk_sprite ~= nil then 
			sprite:Play("Talk"..add,true)
			data.bubble:Play(data.talk_sprite,true)
		else 
			sprite:Play("Idle"..add,true)
		end
	end

	if data.bubble ~= nil and appear_flag then
		data.bubble:Update()
	end
end

monster.npc_post_render = function(self, ent, offset, data, sprite)
	if data.bubble ~= nil then
		if sprite:IsPlaying("Appear") then
			data.talk_sprite = "BubbleAppear"
			data.bubble:SetFrame("BubbleAppear", sprite:GetFrame())
		elseif data.bubble:GetAnimation() == "BubbleAppear" then
			data.bubble:SetFrame(0)
		end

		data.bubble:Render(Isaac.WorldToScreen(ent.Position),Vector.Zero,Vector.Zero)
	end
end

local config_parrot = function(parrot, appear2, alt_sprite)
	local data = GODMODE.get_ent_data(parrot)

	if alt_sprite then 
		parrot:GetSprite():ReplaceSpritesheet(0,alt_sprite)
		parrot:GetSprite():LoadGraphics()
		data.alt_sprite = true 
	end
	
	if parrot.SubType == 0 then 
		parrot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	else
		parrot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
	end
	
	parrot.FlipX = parrot.Position.X - Isaac.GetPlayer().Position.X < 0
	parrot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

	if appear2 then
		if parrot.SubType == 0 then 
			parrot:GetSprite():Play("Appear2",true)
		else 
			parrot:GetSprite():Play("Idle",true)
		end
	else
		parrot:GetSprite():Play("Appear",true)
		data.bubble = Sprite()
		data.bubble:Load("godmode/gfx/famil_parrot.anm2", true)
		data.talk_sprite = "BubbleAppear"

		if alt_sprite then 
			data.bubble:ReplaceSpritesheet(0,alt_sprite)
			data.bubble:LoadGraphics()
		end

		data.bubble:Play(data.talk_sprite,true)
	end
end

monster.new_room = function(self)
	GODMODE.room = Game():GetRoom()
	GODMODE.room_type = GODMODE.room:GetType()

	local kc_count = GODMODE.util.total_item_count(GODMODE.registry.trinkets.keepah_card, true)
	local count = (GODMODE.keepah_mode == true and GODMODE.level:GetAbsoluteStage() or 0) --april fools count
					+ math.min(2,kc_count * 2) + kc_count --keepah card count
	
	-- keepah card
	for i=1,count do 
		local parrot = Isaac.Spawn(monster.type,monster.variant,1,GODMODE.room:FindFreePickupSpawnPosition((GODMODE.room_center or GODMODE.room:GetCenterPos())) + RandomVector():Resized(16),Vector.Zero,nil)
		config_parrot(parrot, not GODMODE.room:IsFirstVisit(), "godmode/gfx/familiars/shopbird"..(parrot.InitSeed % 3)..".png")	
	end

	-- keepah!
	if is_shop() then
		if GODMODE.save_manager.get_config("ShopParrot","true") == "true" then 
			local parrot = Isaac.Spawn(monster.type,monster.variant,0,GODMODE.room:FindFreePickupSpawnPosition((GODMODE.room_center or GODMODE.room:GetCenterPos())),Vector.Zero,nil)
			config_parrot(parrot, GODMODE.room:IsFirstVisit(), (GODMODE.birthday_mode == true and "godmode/gfx/familiars/shopbird_birthday.png" or "godmode/gfx/familiars/shopbird.png"))
		end
	end
end

monster.explode_frame = function(self, ent, data, sprite, fx, explode_pos, explode_size, collided)
    if collided and ent.SubType == 0 then 
		data.talk_sprite = "BubbleWarn"
		sprite:Play("TalkSweat",true)
		data.bubble:Play(data.talk_sprite,true)
		local fought_already = GODMODE.save_manager.get_data("KeepahBossKilled","false") == "true"
		local targ_vel = (ent.Position - explode_pos)
		ent.Velocity = targ_vel:Resized(explode_size - targ_vel:Length())

		if not fought_already then 
			data.ouch_count = (data.ouch_count or 0) + 1

			if data.ouch_count >= anger_threshold then 
				ent:Remove()
				local new = Isaac.Spawn(GODMODE.registry.entities.keepah_boss.type,GODMODE.registry.entities.keepah_boss.variant,GODMODE.registry.entities.keepah_boss.subtype,ent.Position,Vector.Zero,ent)
				GODMODE.room:SetClear(false)

				for i=0,DoorSlot.NUM_DOOR_SLOTS do 
					local door = GODMODE.room:GetDoor(i)
					if door then 
						door:Close(true)
					end
				end	
			end
		end
    end
end

monster.player_collide = function(self, player,ent,entfirst,data) 
	if not data.parrot_talk or data.parrot_talk - player.FrameCount <= 0 then 
		if ent.Type == EntityType.ENTITY_PICKUP then-- and ent.Variant == PickupVariant.PICKUP_SHOPITEM then -- buy
			GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,-1,function(parrot)
				GODMODE.get_ent_data(parrot).buy = 1
			end)

			data.parrot_talk = player.FrameCount + donate_buy_cooldown
		elseif ent.Type == EntityType.ENTITY_SLOT and ent.Variant == (SlotVariant or donation_variant).DONATION_MACHINE then -- donate
			GODMODE.util.macro_on_enemies(nil,monster.type,monster.variant,-1,function(parrot)
				GODMODE.get_ent_data(parrot).donate = 1
			end)	

			data.parrot_talk = player.FrameCount + donate_buy_cooldown
		end	
	end
end

monster.npc_collide = function(self, ent, ent2, entfirst)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
		if GODMODE.util.is_valid_enemy(ent2, true) and ent:IsFrame(4,1) then 
			ent2:TakeDamage((GODMODE.level:GetAbsoluteStage() / 4.0 + 5.0) / 5.0, 0, EntityRef(Isaac.GetPlayer()), 0)
		end

		return false 
	end
end

monster.bypass_hooks = {["player_collide"] = true}

return monster