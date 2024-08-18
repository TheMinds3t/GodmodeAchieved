local monster = {}
-- monster.data gets updated every callback
monster.name = "Winged Spider"
monster.type = GODMODE.registry.entities.winged_spider.type
monster.variant = GODMODE.registry.entities.winged_spider.variant
monster.item_instance = GODMODE.registry.items.reclusive_tendencies

local function is_in_room(pos)
	local tl = GODMODE.room:GetTopLeftPos()
	local br = GODMODE.room:GetBottomRightPos()
	return pos.X >= tl.X and pos.Y >= tl.Y and pos.X <= br.X and pos.Y <= br.Y
end

local function calc_targ_pos(data,player,ent)
    local target_pos = ent.Position
    
    if player ~= nil then 
        target_pos = (player.Position - ent.Position):Resized(96)+ent.Position
    end

    if (player.Position - ent.Position):Length() > 192 then 
        target_pos = target_pos + RandomVector():Resized(96)
    else
        target_pos = target_pos + RandomVector():Resized(24)
    end

    data.target_pos = target_pos
    data.target_found = 0
end

monster.npc_collide = function(self,ent,npc,first)
    if ent.Type == monster.type and ent.Variant == monster.variant then 
        if ent:HasEntityFlags(EntityFlag.FLAG_CHARM) and (not npc:ToPlayer() and npc:HasEntityFlags(EntityFlag.FLAG_CHARM) and npc:IsVulnerableEnemy() or npc:ToPlayer()) then 
            return true 
        end
    end
end

monster.tear_collide = function(self,tear,ent,first)
    if ent.Type == monster.type and ent.Variant == monster.variant and tear.SpawnerEntity ~= nil and 
        ((tear.SpawnerEntity:ToPlayer() and tear.SpawnerEntity:ToPlayer():HasCollectible(monster.item_instance)) 
        or (tear.SpawnerEntity:ToFamiliar() and tear.SpawnerEntity:ToFamiliar().Player ~= nil and tear.SpawnerEntity:ToFamiliar().Player:HasCollectible(monster.item_instance))) then 
        if ent:HasEntityFlags(EntityFlag.FLAG_CHARM) then 
            if Isaac.CountEnemies() ~= ent:ToNPC().I1 then
                return true 
            end
        end
    end
end

monster.familiar_collide = function(self,fam,ent,first)
    if ent.Type == monster.type and ent.Variant == monster.variant then 
        if ent:HasEntityFlags(EntityFlag.FLAG_CHARM) then 
            return true 
        end
    end
end


-- monster.effect_init = function(self,effect)
--     if effect.Variant == EffectVariant.ENEMY_GHOST then 
--         GODMODE.log("hi!",true)

--         if effect.Parent ~= nil and effect.Parent.Type == monster.type and effect.Parent.Variant == monster.variant then 
--             effect:Remove()
--         end
--     end
-- end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()
    data.target_pos = data.target_pos or ent.Position
    if sprite:IsFinished("Appear") then 
        sprite:Play("Idle",false)
    end

    if ent.I1 == 0 or ent:IsFrame(10,1) then 
        ent.I1 = GODMODE.util.count_enemies(nil,GODMODE.registry.entities.winged_spider.type,GODMODE.registry.entities.winged_spider.variant,0) + GODMODE.util.count_enemies(nil,EntityType.ENTITY_STRIDER,0,0)
    end

    if ent:HasEntityFlags(EntityFlag.FLAG_CHARM) and not ent:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) and Isaac.CountEnemies() ~= ent.I1 then 
        ent:AddEntityFlags(EntityFlag.FLAG_NO_TARGET) 
    elseif not ent:HasEntityFlags(EntityFlag.FLAG_CHARM) and ent:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
        ent:ClearEntityFlags(EntityFlag.FLAG_NO_TARGET) 
    end

    if GODMODE.room:IsClear() then 
        ent:Kill()
    end

    if data.throw_pos ~= nil then 
        if ent:HasEntityFlags(EntityFlag.FLAG_APPEAR) then ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR) sprite:Play("Appear",true) end 

        if data.throw_time == nil then 
            data.throw_time = (data.throw_pos - ent.Position):Length()/10
            data.max_throw_time = data.throw_time
        end

        local scale = (data.max_throw_time - data.throw_time) / data.max_throw_time
        ent.Velocity = (data.throw_pos - ent.Position) * (1/data.max_throw_time/2) + ent.Velocity * 0.6
        data.throw_time = data.throw_time - 1 
        
        local hyper_scale = 1.0 - math.abs(scale - 0.5)*2
        ent.SpriteOffset = Vector(0,-data.max_throw_time*hyper_scale)

        if data.throw_time <= 0 then 
            data.throw_time = nil
            data.throw_pos = nil
            calc_targ_pos(data,player,ent)
        end
    else
        if ent:HasEntityFlags(EntityFlag.FLAG_APPEAR) then ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR) sprite:Play("Appear",true) calc_targ_pos(data,player,ent) end 
        data.target_found = data.target_found or 0
        if data.target_found > 20 then 
            calc_targ_pos(data,player,ent)
            local depth = 20 

            while not is_in_room(data.target_pos) and depth > 0 do 
                calc_targ_pos(data,player,ent)
                depth = depth - 1
            end
        end
    
        if sprite:IsPlaying("Idle") then 
            if (data.target_pos - ent.Position):Length() > 16 then 
                ent.Velocity = ent.Velocity * math.min(0.45,math.max(0.6,(100-ent.FrameCount)/100)) + (data.target_pos - ent.Position):Resized(3.5)    
                data.target_found = data.target_found + 0.1
            else
                ent.Velocity = Vector.Zero
                data.target_found = data.target_found + 1
            end    
        end
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if (enthit.Type == monster.type and enthit.Variant == monster.variant) then 
        local player = entsrc.Entity and (entsrc.Entity:ToPlayer() or entsrc.Entity.SpawnerEntity and entsrc.Entity.SpawnerEntity:ToPlayer() or entsrc.Entity.Parent and entsrc.Entity.Parent:ToPlayer())
        if player ~= nil and enthit:ToNPC().I1 ~= Isaac.CountEnemies() and enthit:HasEntityFlags(EntityFlag.FLAG_CHARM) then 
            return false
        end
    end
end

return monster