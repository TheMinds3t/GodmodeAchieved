local item = {}
item.instance = GODMODE.registry.trinkets.godmode
item.eid_description = "↑ When you take damage, rewind time to before you entered the room#↓ +1 Broken Heart when this triggers#↓ You cannot drop this trinket after picking it up# Gets prioritized for removal by the Stifled Gatekeeper in Sheol over Angel room items"
item.trinket = true
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When damage is taken, time gets rewound to the last room and you gain a broken heart."},
      {str = "This trinket CANNOT be dropped."},
      {str = "The Stifled Gatekeeper in Sheol/Cathedral will prioritize this trinket over any angel/devil items collected throughout the run, removing the trinket!"},
    },
}

item.get_trinket = function(self,trinket,rng)
    if trinket == item.instance then 
        return rng:RandomInt(TrinketType.NUM_TRINKETS-1)+1
    end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local flag = true
    local player = enthit:ToPlayer()
    if player and amount > 0 and player:HasTrinket(item.instance) and (flags & DamageFlag.DAMAGE_NO_PENALTIES ~= DamageFlag.DAMAGE_NO_PENALTIES 
                    and flags & DamageFlag.DAMAGE_INVINCIBLE ~= DamageFlag.DAMAGE_INVINCIBLE
                    and flags & DamageFlag.DAMAGE_IV_BAG ~= DamageFlag.DAMAGE_IV_BAG
                    and entsrc.Type ~= EntityType.ENTITY_SLOT
                    or player:GetHearts()+player:GetSoulHearts()+player:GetBoneHearts()-amount <= 0) then
        
        local data = GODMODE.get_ent_data(player)
        -- GODMODE.log("entsrc="..entsrc.Type..","..entsrc.Variant,true)

        -- if data.recursive_godmode ~= true then 
            -- if player:GetHearts() + player:GetSoulHearts() + player:GetBlackHearts() + player:GetRottenHearts() <= amount * 3 then 

            flag = false
            GODMODE.get_ent_data(player).godmode_rewind = GODMODE.room:GetDecorationSeed()

            if GODMODE.shader_params.godmode_trinket_time == 0 then 
                GODMODE.shader_params.godmode_trinket_time = 35
            end
            -- else
            --     data.recursive_godmode = true
            --     player:TakeDamage(amount*3,flags,entsrc,math.floor(countdown/3))
            --     data.recursive_godmode = nil
            --     flag = false
            -- end
        -- end
    end

    if flag == false then
        return false
    end
end

-- local used = false

item.player_update = function(self,player,data)
    
    if player:HasTrinket(item.instance) then 
        if player:HasTrinket(item.instance, true) then 
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, true, true, false)
        end

        local rewind_flag = data.godmode_rewind
        -- add broken + fx
        if rewind_flag ~= nil and GODMODE.room:GetDecorationSeed() ~= rewind_flag then 
            player:GetSprite():Play("Appear",true)
            data.disable_time = 40
            player:AddBrokenHearts(1)
            data.godmode_rewind = nil
        end

        -- trigger rewind
        if GODMODE.shader_params.godmode_trinket_time > 32 and rewind_flag ~= nil and GODMODE.room:GetDecorationSeed() == rewind_flag then 
            GODMODE.shader_params.godmode_trinket_time = 32
            GODMODE.godhooks.call_hook("pre_godmode_restart")
            -- Isaac.ExecuteCommand("rewind")
            GODMODE.game:StartRoomTransition(GODMODE.level:GetPreviousRoomIndex(), Direction.NO_DIRECTION, RoomTransitionAnim.MAZE, player)
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, true, true, false)
            -- used = true
            -- player:UseActiveItem(CollectibleType.COLLECTIBLE_GLOWING_HOUR_GLASS, UseFlag.USE_NOANIM)
        end

        if GODMODE.shader_params.godmode_trinket_time == 0 and player:GetBrokenHearts() == 12 then 
            player:Kill()
        end 
    
        if (data.disable_time or 0) > 0 then 
            player.ControlsEnabled = false 
            data.disable_time = math.max(0,data.disable_time - 1)

            if data.disable_time == 0 then 
                player.ControlsEnabled = true
                GODMODE.godhooks.call_hook("post_godmode_restart")
            end
        end
    end
end

return item