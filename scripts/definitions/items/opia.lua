local item = {}
item.instance = Isaac.GetItemIdByName( "Opia" )
item.eid_description = "When used, throw your soul at an enemy to become that enemy and charm all enemies of the same type for the room#Deals 4x player damage against bosses instead"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, the next tear the player would fire is instead a soul tear."},
		{str = "If this soul tear collides with an enemy, all instances of that enemy are charmed for the room and the player will visually turn into the one that was hit."},
		{str = "The enemy that was hit will be locked to the player's position and attack other hostile enemies while the player continues to fire tears."},
		{str = "If the soul tear hits a boss, the soul tear will instead deal 4x the player's damage."},
	},
}

local offset = Vector(1200,1200)

item.reset_opia = function(self,fx)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        local data = GODMODE.get_ent_data(player)
        if data.opia_ent ~= nil then data.opia_ent:Remove() end
        data.opia_ent = nil 
        data.opia_tear = nil

        if tonumber(GODMODE.save_manager.get_player_data(player,"OpiaState","0")) > 0 and fx ~= false then
            Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,player.Position,Vector.Zero,player)
        end

        GODMODE.save_manager.set_player_data(player, "OpiaState", -1,true)
        player.PositionOffset = Vector(0,0)
    end)    
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        local data = GODMODE.get_ent_data(player)

        if tonumber(GODMODE.save_manager.get_player_data(player,"OpiaState","0")) > 0 then
            item:reset_opia()
        end
        GODMODE.save_manager.set_player_data(player, "OpiaState", 1,true)
        data.opia_animate = 1

        return true
    end
end


item.new_room = function(self)
    item:reset_opia()
end

item.player_update = function(self, player)
    if player:HasCollectible(item.instance) then
        local data = GODMODE.get_ent_data(player)
        local state = tonumber(GODMODE.save_manager.get_player_data(player, "OpiaState", "0"))

        if state == -1 then
            player.PositionOffset = Vector(0,0)
            GODMODE.save_manager.set_player_data(player, "OpiaState", 0)
        elseif state == 1 then
            if data.opia_animate == 0 then
                player:AnimateTrinket(TrinketType.TRINKET_YOUR_SOUL)
                data.opia_animate = 30
            end

            data.opia_animate = math.max(-1,(data.opia_animate or 0) - 1)

            if player:GetShootingJoystick().X + player:GetShootingJoystick().Y ~= 0 then
                player:StopExtraAnimation()
                local vel = player:GetShootingJoystick()*10
                local tear = player:FireTear(player.Position,vel+player:GetTearMovementInheritance(vel),false,true,false,player,0)
                tear:ChangeVariant(Isaac.GetEntityVariantByName("Opia Soul"))
                tear.TearFlags = TearFlags.TEAR_NORMAL
                tear:GetSprite():Play("RegularTear6",true)
                tear.Scale = 1.0
                tear.CollisionDamage = 3
                data.opia_tear = tear
                GODMODE.save_manager.set_player_data(player, "OpiaState", 2)
            end
        elseif state == 2 and data.opia_tear ~= nil then
            data.opia_tear:GetSprite().Rotation = data.opia_tear.Velocity:GetAngleDegrees()+90
        elseif state == 3 and data.opia_ent ~= nil then
            local count = Isaac.CountEnemies()
            --GODMODE.log("count:"..count,true)
            GODMODE.util.macro_on_enemies(nil,data.opia_ent.Type,data.opia_ent.Variant,data.opia_ent.SubType,function(ent2)
                ent2:AddEntityFlags(EntityFlag.FLAG_CHARM)
                ent2.CollisionDamage = 0
            end)

            --data.opia_ent.PositionOffset = offset
            data.opia_ent.TargetPosition = (player.Position)
            data.opia_ent.Position = player.Position
            data.opia_ent.Velocity = (player.Position - data.opia_ent.Position) + (player.Velocity - data.opia_ent.Velocity)*0.1
            data.opia_ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            data.opia_ent.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
            data.opia_ent.RenderZOffset = -9999
            data.opia_ent.Mass = 0

            if count == 0 or player:IsDead() or data.opia_ent:IsDead() then
                item:reset_opia()
            end

            if player:GetDamageCooldown() > 0 and data.opia_hurt ~= true then
                data.opia_hurt = true
                if data.opia_ent ~= nil then 
                    data.opia_ent:SetColor(Color(1,1,1,1,0.8*(player:GetDamageCooldown()/45),0,0),math.floor(player:GetDamageCooldown()/3),50,true,true)
                end
            else
                data.opia_hurt = false
            end
            player.PositionOffset = offset
        end
    end
end

item.tear_collide = function(self,tear,ent,entfirst)

    local flag = false
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        local data = GODMODE.get_ent_data(player)
        local state = tonumber(GODMODE.save_manager.get_player_data(player, "OpiaState", "0"))

        if state ~= 3 and data.opia_ent == nil and data.opia_tear ~= nil and not data.opia_tear:IsDead() and GetPtrHash(data.opia_tear) == GetPtrHash(tear) then
            if not ent:IsBoss() and ent:IsVulnerableEnemy() then
                if ent.HitPoints > tear.CollisionDamage then
                    GODMODE.save_manager.set_player_data(player, "OpiaState", 3,true)
                    data.opia_ent = ent
                    data.opia_ent:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
                    ent.Size = 0
                    ent.HitPoints = ent.MaxHitPoints
                    Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,player.Position,Vector.Zero,player)
                    Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,ent.Position,Vector.Zero,ent)
                    data.opia_tear:Kill()
                    data.opia_tear = nil
                end
            else
                tear.CollisionDamage = player.Damage * 4
                Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,tear.Position,Vector.Zero,tear)
            end

            if data.opia_ent and GetPtrHash(data.opia_ent) == GetPtrHash(ent) then
                flag = true 
            end
        end
    end)

    if flag == true then
        return true   
    end
end

item.tear_fire = function(self,tear)
    if tear.Parent ~= nil and tear.Parent:ToPlayer() then
        local state = tonumber(GODMODE.save_manager.get_player_data(tear.Parent:ToPlayer(), "OpiaState", "0"))
        local data = GODMODE.get_ent_data(tear.Parent)
        if data.opia_tear and not data.opia_tear:IsDead() then
            tear:Remove()
        end
    end
end

item.npc_collide = function(self,ent,ent2,entfirst)
    local flag = false
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        local data = GODMODE.get_ent_data(player)

        if data.opia_ent and GetPtrHash(data.opia_ent) == GetPtrHash(ent) then
            flag = true 
        end
    end)

    if flag == true then
        return true   
    end
end

return item