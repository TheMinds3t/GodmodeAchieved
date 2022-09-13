local transform = {}
transform.instance = "transform"
transform.transformation = true
transform.eid_transform = nil
transform.cache_flags = 0
transform.num_items = 3
transform.has_transform = function(player)
	return GODMODE.save_manager.get_player_data(player,transform.instance,"false") == "true"
end
transform.is_transform_active = function(self, data, player)
	return data.transform_cooldown[transform.instance] == 0
end

transform.pickup_collide = function(self, pickup,ent,entfirst)
	if ent:ToPlayer() and 
		(
			((ent:ToPlayer().SubType ~= PlayerType.PLAYER_CAIN_B and (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM)) and 
			transform.items[pickup.SubType] == true and not pickup.Touched) 
			
			or 

			(pickup.Variant == Isaac.GetEntityVariantByName("[GODMODE] Unlock Pedestal") and transform.items[GODMODE.achievements.get_unlock_at_index(pickup.SubType)] == true)
		) then

		local data = GODMODE.get_ent_data(pickup)
		data.transform_added = data.transform_added or {}
		if data.transform_added[transform.instance] ~= true and not transform.has_transform(ent:ToPlayer()) then
			GODMODE.save_manager.set_player_data(ent:ToPlayer(), transform.instance.."Items", tonumber(GODMODE.save_manager.get_player_data(ent:ToPlayer(), transform.instance.."Items","0"))+1, true)
			data.transform_added[transform.instance] = true
			data.transform_cooldown = data.transform_cooldown or {}
			GODMODE.get_ent_data(ent).transform_cooldown[transform.instance] = 75
			return true
		end
	end
end

transform.first_level = function(self)
	GODMODE.util.macro_on_players(function(player)
		GODMODE.save_manager.set_player_data(player, transform.instance.."Items","0")
		GODMODE.save_manager.set_player_data(player, transform.instance.."","false",true)
	end)
end

transform.player_update = function(self, player)
	local data = GODMODE.get_ent_data(player)
	data.transform_cooldown = data.transform_cooldown or {}
	data.transform_cooldown[transform.instance] = math.max((data.transform_cooldown[transform.instance] or 0) - 1, 0)

	if transform:is_transform_active(data, player) then
		if not transform.has_transform(player) then
			if tonumber(GODMODE.save_manager.get_player_data(player, transform.instance.."Items","0")) >= transform.num_items then
				GODMODE.save_manager.set_player_data(player, transform.instance.."","true", true)
				player:AddCacheFlags(transform.cache_flags)
				player:EvaluateItems()
				SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER)
				Game():GetHUD():ShowItemText(transform.instance.."!","")
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)
			end
		else 
			transform.transform_update(self, player)
		end
	end
end

transform.transform_update = function(self, player) end

return transform