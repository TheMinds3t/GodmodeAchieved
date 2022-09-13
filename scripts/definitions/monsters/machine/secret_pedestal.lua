local monster = {}
-- monster.data gets updated every callback
monster.name = "[GODMODE] Unlock Pedestal"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
monster.secrets_desc_anim = Sprite()
monster.secrets_desc_anim:Load("gfx/achievements/unlocks.anm2",true)
monster.locked_col = Color(0,0,0,0.66)
monster.max_desc_time = 50
monster.rev_desc_time = 150

-- monster.data_init = function(self, params)
-- 	params[2].persistent_state = GODMODE.persistent_state.single_room
-- end
monster.pickup_init = function(self, pickup)
	local unlock = GODMODE.achievements.get_unlock_at_index(pickup.SubType) 
	local data = GODMODE.get_ent_data(pickup)
	
	if unlock == nil then 
		local config = Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_BREAKFAST)
		if config and config:IsCollectible() then
			data.item_unlock = CollectibleType.COLLECTIBLE_BREAKFAST
			-- data.splash_gfx = GODMODE.achievements.get_splash_for(unlock):gsub("achievement_","")
			data.item_gfx = config.GfxFileName
			data.is_unlocked = true
		end
	else 
		local config = Isaac.GetItemConfig():GetCollectible(unlock)
		if config and config:IsCollectible() then
			data.item_unlock = unlock
			data.splash_gfx = GODMODE.achievements.get_splash_for(unlock):gsub("achievement_","")
			data.item_gfx = config.GfxFileName
			data.is_unlocked = GODMODE.achievements.is_item_unlocked(unlock,true)
		end
	end
end

monster.pickup_post_render = function(self, pickup, offset)
	local data = GODMODE.get_ent_data(pickup)
	local render_front = false 
	local anim_item_time = Game():GetFrameCount()*(1/15.0)+pickup.Position.Y+pickup.Position.X
	local item_off_pos = Vector(0,-40+math.sin(anim_item_time*0.66+pickup.Position.Y)*2)
	monster.secrets_desc_anim.Scale = Vector(1.0+math.cos(anim_item_time+pickup.Position.X)*0.05,1.0+math.sin(anim_item_time+pickup.Position.Y)*0.05)
	
	monster.secrets_desc_anim:RemoveOverlay()
	monster.secrets_desc_anim.Color = Color(1,1,1,1) 
	monster.secrets_desc_anim:SetFrame("ItemBack",0)
	monster.secrets_desc_anim:Render(Isaac.WorldToScreen(pickup.Position)+item_off_pos,Vector.Zero,Vector.Zero)
	
	monster.secrets_desc_anim:ReplaceSpritesheet(3,data.item_gfx)
	monster.secrets_desc_anim:LoadGraphics()
	monster.secrets_desc_anim:SetFrame("Item",0)

	if data.is_unlocked == false then 
		monster.secrets_desc_anim.Color = monster.locked_col
		render_front = true 
	end

	monster.secrets_desc_anim:Render(Isaac.WorldToScreen(pickup.Position)+item_off_pos,Vector.Zero,Vector.Zero)

	if render_front == true then 
		monster.secrets_desc_anim.Color = Color(1,1,1,1) 
		monster.secrets_desc_anim:SetFrame("ItemFront",0)
		monster.secrets_desc_anim:Render(Isaac.WorldToScreen(pickup.Position)+item_off_pos,Vector.Zero,Vector.Zero)
	end

	local desc_off = Vector(0,32)
	monster.secrets_desc_anim.Scale = Vector(1.0+math.cos(anim_item_time+pickup.Position.X)*0.025,1.0+math.sin(anim_item_time+pickup.Position.Y)*0.025)
	if (data.display_time or 0) > 0 and data.splash_gfx ~= nil then 
		local perc = math.min(1.0,(data.display_time or 0)/monster.max_desc_time)
		local col = Color(perc,perc,perc,perc)
		monster.secrets_desc_anim.Color = col
		monster.secrets_desc_anim:SetFrame("Back",0)
		monster.secrets_desc_anim:SetOverlayFrame(data.splash_gfx,0)
		monster.secrets_desc_anim:Render(Isaac.WorldToScreen(pickup.Position)+desc_off,Vector.Zero,Vector.Zero)
	end
end

monster.pickup_update = function(self, pickup)
	if not (pickup.Type == monster.type and pickup.Variant == monster.variant) then return end
	local data = GODMODE.get_ent_data(pickup) 
	data.anchor_pos = data.anchor_pos or Game():GetRoom():GetGridPosition(Game():GetRoom():GetGridIndex(pickup.Position))
	pickup.Velocity = (data.anchor_pos - pickup.Position)
	pickup:GetSprite():Play("Pedestal",true)
	pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY

	data.display_time = math.max(0,math.min(monster.rev_desc_time,(data.display_time or 0) + (data.display_mod or 0)))
	data.col_cooldown = math.max(0,(data.col_cooldown or 0) - 1)

	if data.display_time >= monster.rev_desc_time then data.display_mod = -1 end 
	if data.display_time <= 0 then data.display_mod = 0 pickup.DepthOffset = 0 else pickup.DepthOffset = 1000+data.display_time*100 end
end

monster.player_collide = function(self,player,pickup,entfirst) 
	if pickup.Type == monster.type and pickup.Variant == monster.variant then 
		local data = GODMODE.get_ent_data(pickup) 
		data.display_mod = 1

		if data.col_cooldown == 0 and data.is_unlocked then
			player:AnimateCollectible(data.item_unlock)
			player:AddCollectible(data.item_unlock)
			data.col_cooldown = 20
			data.transform_added = {}
		end

		return false 
	end
end
return monster