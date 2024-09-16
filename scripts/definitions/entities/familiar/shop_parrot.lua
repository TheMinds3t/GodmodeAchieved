local monster = {}
monster.name = "Keepah (Shop Parrot)"
monster.type = GODMODE.registry.entities.keepah.type
monster.variant = GODMODE.registry.entities.keepah.variant
local donation_variant = {DONATION_MACHINE=8}
local donate_buy_cooldown = 30
local max_volume_range = 320 --silent
local min_volume_range = 80 --loudest

local is_not_shop = function()
	return GODMODE.room:GetType() ~= RoomType.ROOM_SHOP
end

monster.npc_init = function(self,ent,data,sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
end

monster.npc_update = function(self, ent, data, sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	

	if ent.FrameCount == 1 then 
		if is_not_shop() or data.replace_sprite == true then 
			ent:GetSprite():ReplaceSpritesheet(0,"gfx/familiars/shopbird"..(ent.InitSeed % 3)..".png")
			ent:GetSprite():LoadGraphics()
		elseif GODMODE.birthday_mode == true then 
			ent:GetSprite():ReplaceSpritesheet(0,"gfx/familiars/shopbird_birthday.png")
			ent:GetSprite():LoadGraphics()
		end	
	end

	local player = ent:GetPlayerTarget()
	local appear_flag = not (sprite:IsPlaying("Appear") or sprite:IsPlaying("Appear2")) and data.real_time > 2

	if data.bubble == nil then
		data.bubble = Sprite()
		data.bubble:Load("gfx/famil_parrot.anm2", true)
	end

	ent.Velocity = ent.Velocity * 0.8

	if appear_flag then
		local target_pos = player.Position + Vector(1,0):Rotated((ent.InitSeed + ent.FrameCount * (2 + (ent.InitSeed % 20) / 20)) % 360):Resized((ent.InitSeed / 250.0) % 60 + ent.Size * 2)

		if data.run_from ~= nil then
			if data.run_from:IsDead() or not data.run_from:IsVisible() then
				data.run_from = nil
			else
				target_pos = data.run_from.Position

				if (ent.Position - target_pos):Length() < ent.Size*16 or is_not_shop() then
					ent.Velocity = ent.Velocity + (is_not_shop() and (target_pos - ent.Position) or (ent.Position - target_pos)) / 80.0
				end	
	
				if sprite:IsEventTriggered("Flap") then
					ent.Velocity = ent.Velocity + (ent.Position - target_pos+Vector(ent:GetDropRNG():RandomInt(math.floor(ent.Size*16))-math.floor(ent.Size*8),ent:GetDropRNG():RandomInt(math.floor(ent.Size*16))-math.floor(ent.Size*8))) / 48.0

					if string.match(sprite:GetAnimation(),"Sweat") and is_not_shop() then 
						local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, ent.Position, Vector(0,0), ent)
						creep:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
						creep.CollisionDamage = GODMODE.level:GetAbsoluteStage() / 4.0 + 5.0
						creep:ToEffect().Timeout = 20
					end
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
			if ent2:IsVulnerableEnemy() and not 
					(ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or 
					ent:HasEntityFlags(EntityFlag.FLAG_CHARM) or 
					ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY_BALL)) then
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
			
			if is_not_shop() then 
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

local config_parrot = function(parrot, appear2)
	parrot.FlipX = parrot.Position.X - Isaac.GetPlayer().Position.X < 0

	if appear2 then
		parrot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		if GODMODE.room:GetType() == RoomType.ROOM_SHOP then 
			parrot:GetSprite():Play("Appear2",true)
		else 
			parrot:GetSprite():Play("Idle",true)
		end
	else
		local data = GODMODE.get_ent_data(parrot)
		data.bubble = Sprite()
		data.bubble:Load("gfx/famil_parrot.anm2", true)
		data.talk_sprite = "BubbleAppear"
		data.bubble:Play(data.talk_sprite,true)
	end
end

monster.new_room = function(self)
	if true then --GODMODE.room:GetType() == RoomType.ROOM_SHOP then
		if GODMODE.save_manager.get_config("ShopParrot","true") == "true" then 
			local kc_count = GODMODE.util.total_item_count(GODMODE.registry.trinkets.keepah_card, true)
			local count = (GODMODE.room:GetType() == RoomType.ROOM_SHOP and 1 --shop count
							or GODMODE.keepah_mode == true and GODMODE.level:GetAbsoluteStage() or 0) --april fools count
							+ kc_count * 2 --keepah card count

			for i=1,count do 
				local parrot = Isaac.Spawn(monster.type,monster.variant,0,GODMODE.room:FindFreePickupSpawnPosition(GODMODE.room:GetCenterPos()),Vector.Zero,nil)
				config_parrot(parrot, not GODMODE.room:IsFirstVisit() or is_not_shop())	

				if not is_not_shop() and i > 1 then 
					GODMODE.get_ent_data(parrot).replace_sprite = true
				end
			end
		end

		if GODMODE.save_manager.get_config("ShopFog","true") == "true" and not is_not_shop() then 
			local poses = {
				{pos=GODMODE.room:GetCenterPos(),vel=RandomVector()*0.05},
				{pos=GODMODE.room:GetTopLeftPos(),vel=Vector(math.abs(RandomVector().X),math.abs(RandomVector().Y)*0.25)*0.05+Vector(0.05,0)},
				{pos=GODMODE.room:GetBottomRightPos(),vel=Vector(math.abs(RandomVector().X),math.abs(RandomVector().Y)*0.25)*-0.05-Vector(0.05,0)}
			}
	
			for _,pos in ipairs(poses) do
				local fog = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MIST, 0, pos.pos, pos.vel, nil)
				fog:Update()
				fog:Update()
				fog:Update()
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

monster.bypass_hooks = {["player_collide"] = true}

return monster