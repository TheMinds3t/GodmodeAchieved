local monster = {}
monster.name = "Godmode Tainted Char"
monster.type = GODMODE.registry.entities.closet_tchar.type
monster.variant = GODMODE.registry.entities.closet_tchar.variant

monster.data_init = function(self, ent, data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        data.persistent_state = GODMODE.persistent_state.single_room
    end
end

monster.player_collide = function(self,player,ent,ent_first)
    if player:ToPlayer() then
        if ent_first and ent:GetSprite():IsPlaying("Idle") then 
            ent:GetSprite():Play("Interact",true)
        end

        return false 
    end
end

monster.npc_init = function(self, ent)
    if GODMODE.registry.closet_chars[ent.SubType] then 
        local dat = GODMODE.registry.closet_chars[ent.SubType]
        ent:GetSprite():ReplaceSpritesheet(0,dat.char_sprite)
        ent:GetSprite():LoadGraphics()
    end

    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
end

monster.new_room = function(self)
    if GODMODE.level:GetAbsoluteStage() == LevelStage.STAGE8 and GODMODE.room:IsFirstVisit() then 
        local data = GODMODE.level:GetRoomByIdx(GODMODE.level:GetCurrentRoomIndex()).Data

        if data and data.Name=='Closet L' then 
            local sel_player = nil 

            for i=1,GODMODE.game:GetNumPlayers() do
                local player = Isaac.GetPlayer(i-1)
                if GODMODE.registry.closet_chars[player:GetPlayerType()] ~= nil then
                    sel_player = player:GetPlayerType()
                    break 
                end
            end

            if sel_player ~= nil and (GODMODE.validate_rgon() and Isaac.GetPersistentGameData():Unlocked(GODMODE.registry.closet_chars[sel_player].achievement) == false) then 
                -- 
                Isaac.CreateTimer(function() 
                    GODMODE.util.clear_radius(GODMODE.room:GetCenterPos(), 64.0, function(ent) return (GODMODE.room:GetCenterPos() - ent.Position):Length() < 80.0 end)                
                end, 2, 1, false)

                Isaac.CreateTimer(function() 
                    local tchar = Isaac.Spawn(monster.type,monster.variant,sel_player, GODMODE.room:GetCenterPos(), Vector.Zero, nil)
                    tchar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    
                    GODMODE.log("tainted character placed! sel_player = "..sel_player,true)
                end, 5, 1, false)
            end
        end
    end
end

monster.npc_update = function(self, ent, data, sprite)
    data.origin = data.origin or ent.Position
    ent.Velocity = ((data.origin or ent.Position) - ent.Position) / 4

    if not sprite:IsPlaying("Interact") and not sprite:IsPlaying("Idle") then 
        if sprite:GetAnimation() == "Interact" and sprite:IsFinished("Interact") then 
            ent:Remove()
        end

        sprite:Play("Idle",true)
    end

    if sprite:IsEventTriggered("Sound") then 
        
    end

    if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
		ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
	end

    if sprite:IsEventTriggered("Unlock") then 
        GODMODE.achievements.unlock_character(GODMODE.registry.closet_chars[ent.SubType].unlock)
        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,ent.Position,Vector.Zero,ent)
    end
end

return monster