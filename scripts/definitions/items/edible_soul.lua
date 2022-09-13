local item = {}
item.instance = Isaac.GetItemIdByName( "Edible Soul" )
item.eid_description = "↑ +1 Black Heart#When you die with no lives remaining, revive, lose your body and gain three charmed Furnace Knights, three broken hearts and flight# Health gets set to 1 black heart on trigger"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "+1 Black Heart"},
      {str = "When you die with no lives remaining, you will become revived with the following additions:"},
      {str = " - All hearts you previously had get converted into a single black heart"},
      {str = " - +3 broken hearts"},
      {str = " - +3 charmed Furnace Knights"},
      {str = " - Flight"},
    },
}

item.eval_cache = function(self, player,cache)
	local data = GODMODE.get_ent_data(player)
	local flag = GODMODE.save_manager.get_player_data(player, "EdibleSoulApplied", "false") == "true"

	if flag and Game():GetFrameCount() > 1 then
		if cache == CacheFlag.CACHE_FLYING then
			player.CanFly = true

			if data.edible_soul_costume ~= true then 
				data.edible_soul_costume = true
				player:TryRemoveNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/edible_soul_bodiless.anm2"))
				player:AddNullCostume(Isaac.GetCostumeIdByPath("gfx/costumes/edible_soul_bodiless.anm2"))
				player:AddCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_LORD_OF_THE_PIT),false)
				player:AddCostume(Isaac.GetItemConfig():GetCollectible(CollectibleType.COLLECTIBLE_ARIES),false)
			end
		end
	end
end

item.first_level = function(self)
	GODMODE.util.macro_on_players(function(player)
		GODMODE.save_manager.set_player_data(player, "EdibleSoulApplied", "false",true)
	end)
end

item.player_update = function(self,player)
	local data = GODMODE.get_ent_data(player)
	local flag = GODMODE.save_manager.get_player_data(player, "EdibleSoulApplied", "false") == "true"


	if data.edible_soul_eaten == true then 
		player:AddMaxHearts(-24)
		player:AddSoulHearts(-24)
		player:AddBlackHearts(-24)
		player:AddBoneHearts(-24)
		player:AddGoldenHearts(-24)
		player:AddRottenHearts(-24)

		if player:GetBrokenHearts() < 9 then 
			player:AddBlackHearts(2)
		end

		player:AddBrokenHearts(3)
		data.edible_soul_eaten = false
	end

	if flag == true then 
		if data.edible_soul_costume ~= true then 
			player:AddCacheFlags(CacheFlag.CACHE_FLYING)
			player:EvaluateItems()
		end
	end

	if player:IsExtraAnimationFinished() then 
		data.edible_soul_applied = false
	end
end

item.new_room = function(self)	
	local enter_door = Game():GetLevel().EnterDoor
	if enter_door > -1 then 
		GODMODE.util.macro_on_enemies(nil,Isaac.GetEntityTypeByName("Furnace Knight"),Isaac.GetEntityVariantByName("Furnace Knight"),1, function(knight)
			if knight:HasEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT) then 
				knight.Position = Game():GetRoom():GetDoorSlotPosition(enter_door)
			end
		end)	
	end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local flag = true
    if enthit:ToPlayer() and amount > 0 then
        local player = enthit:ToPlayer()
        local data = GODMODE.get_ent_data(player)
		local death_flag = player:GetSprite():IsPlaying("Death")

		if player:GetExtraLives() == 0 and player:GetHearts() + player:GetSoulHearts() + player:GetBlackHearts() + player:GetRottenHearts() <= amount and player:GetCollectibleNum(item.instance) > 0 or death_flag then 
			if not death_flag then 
				player:PlayExtraAnimation("Death")

				local offsets = {Vector(96,-64),Vector(-96,-64),Vector(0,96)}
				for i,offset in ipairs(offsets) do
					local knight = Isaac.Spawn(Isaac.GetEntityTypeByName("Furnace Knight"),Isaac.GetEntityVariantByName("Furnace Knight"),1, player.Position+offset,Vector(0,0),player) 
					knight:AddEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_PERSISTENT)
					knight:BloodExplode()
				end

				GODMODE.save_manager.set_player_data(player, "EdibleSoulApplied", "true",true)
				data.edible_soul_applied = true		

				data.edible_soul_eaten = true
				player:RemoveCollectible(item.instance)
			end

			flag = false
		end

		if data.edible_soul_applied == true then 
			return false
		end
    end

    if flag == false then
        return false
    end
end

return item