local item = {}
item.instance = Isaac.GetTrinketIdByName( "Godmode" )
item.eid_description = "↑ When you take damage, rewind time to before you entered the room#↓ +1 Broken Heart when this triggers#↓ You cannot drop this trinket after picking it up"
item.trinket = true

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local flag = true
    if enthit:ToPlayer() and amount > 0 and enthit:ToPlayer():HasTrinket(item.instance) and flags & DamageFlag.DAMAGE_NO_PENALTIES ~= DamageFlag.DAMAGE_NO_PENALTIES then
        local player = enthit:ToPlayer()
        local data = GODMODE.get_ent_data(player)

        -- if data.recursive_godmode ~= true then 
            -- if player:GetHearts() + player:GetSoulHearts() + player:GetBlackHearts() + player:GetRottenHearts() <= amount * 3 then 

            flag = false
            GODMODE.get_ent_data(player).godmode_rewind = Game():GetRoom():GetDecorationSeed()

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

item.player_update = function(self,player)
    
    if player:HasTrinket(item.instance) then 
        local data = GODMODE.get_ent_data(player)
        if data.received_godmode ~= true then 
            player:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER, false, true, true, false)
            data.received_godmode = true
        end
        local rewind_flag = data.godmode_rewind
        if rewind_flag ~= nil and Game():GetRoom():GetDecorationSeed() ~= rewind_flag then 
            player:GetSprite():Play("Appear",true)
            data.godmode_rewind = nil
            data.disable_time = 40
            player:AddBrokenHearts(1)
        end

        if GODMODE.shader_params.godmode_trinket_time == 33 and rewind_flag ~= nil and Game():GetRoom():GetDecorationSeed() == rewind_flag then 
            GODMODE.shader_params.godmode_trinket_time = 32
            Isaac.ExecuteCommand("rewind")
        end

        if GODMODE.shader_params.godmode_trinket_time == 0 and player:GetBrokenHearts() == 12 then 
            player:Kill()
        end 
    

        if (data.disable_time or 0) > 0 then 
            player.ControlsEnabled = false 
            data.disable_time = math.max(0,data.disable_time - 1)

            if data.disable_time == 0 then 
                player.ControlsEnabled = true
            end
        end
    end
end

item.pickup_collide = function(self,pickup,ent,entfirst)
    if pickup.Variant == PickupVariant.PICKUP_TRINKET and pickup.SubType == item.instance and not entfirst and ent:ToPlayer() and ent:ToPlayer():HasTrinket(item.instance) then 
        GODMODE.get_ent_data(ent:ToPlayer()).received_godmode = false
    end
end

return item