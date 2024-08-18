local monster = {}
-- monster.data gets updated every callback
monster.name = "Outbreak"
monster.type = GODMODE.registry.entities.outbreak.type
monster.variant = GODMODE.registry.entities.outbreak.variant
monster.move_delay = 18 
monster.subtypes = {
    boss = 0,
    burrow = 1,
    burrow_spawn = 2,
    minion = 3
}

monster.burrow_health_pool = 100
monster.burrow_health_pool_scaled = 20
monster.max_enemies = 5

monster.burrow_spawn_int = 2
monster.burrow_spawn_var = 3

monster.health_max = 12

monster.spawnable_spiders = {
    {
        {type=EntityType.ENTITY_SPIDER,var=0},
        {type=EntityType.ENTITY_SPIDER,var=0},
        {type=EntityType.ENTITY_SPIDER,var=0},
        {type=EntityType.ENTITY_SPIDER,var=0},
        {type=EntityType.ENTITY_SPIDER,var=0},
        {type=EntityType.ENTITY_BIGSPIDER,var=0},    
    },
    {
        {type=EntityType.ENTITY_SPIDER,var=0},
        {type=EntityType.ENTITY_SPIDER,var=0},
        {type=EntityType.ENTITY_SPIDER,var=0},
        {type=EntityType.ENTITY_SPIDER,var=0},
        {type=EntityType.ENTITY_SPIDER_L2,var=0},
        {type=EntityType.ENTITY_BIGSPIDER,var=0},    
    },
    {
        {type=EntityType.ENTITY_SPIDER,var=0},
        {type=EntityType.ENTITY_SPIDER,var=0},
        {type=EntityType.ENTITY_HOPPER,var=1}, --trite
        {type=EntityType.ENTITY_HOPPER,var=1}, --trite
        {type=EntityType.ENTITY_SPIDER_L2,var=0},
        {type=EntityType.ENTITY_BIGSPIDER,var=0},    
    },
    {
        {type=EntityType.ENTITY_SPIDER,var=0},
        {type=EntityType.ENTITY_SPIDER,var=0},
        {type=EntityType.ENTITY_HOPPER,var=1}, --trite
        {type=EntityType.ENTITY_HOPPER,var=1}, --trite
        {type=EntityType.ENTITY_CRAZY_LONG_LEGS,var=1},
        {type=EntityType.ENTITY_BIGSPIDER,var=0},    
    },
    -- {type=EntityType.ENTITY_SPIDER,var=0},
    -- {type=EntityType.ENTITY_BIGSPIDER,var=0},    
    -- {type=EntityType.ENTITY_SPIDER_L2,var=0},
    -- {type=EntityType.ENTITY_BABY_LONG_LEGS,var=0},
    -- {type=EntityType.ENTITY_CRAZY_LONG_LEGS,var=0},
    -- {type=EntityType.ENTITY_BABY_LONG_LEGS,var=1},
    -- {type=EntityType.ENTITY_CRAZY_LONG_LEGS,var=1},
    -- {type=EntityType.ENTITY_HOPPER,var=1}, --trite
    -- {type=GODMODE.registry.entities.planter.type,var=GODMODE.registry.entities.planter.variant},
    -- {type=GODMODE.registry.entities.godleg.type,var=GODMODE.registry.entities.godleg.variant},
}        

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

local function get_rand_pos(ent,player,dist)
    local room = GODMODE.room
    local targ_pos = room:GetGridPosition(room:GetGridIndex(room:GetRandomPosition(16.0)))
    local depth = 20
    dist = dist or 96
    local grid_flag = function(pos)
        return room:GetGridCollisionAtPos(pos) == GridCollisionClass.COLLISION_NONE
    end

    while (targ_pos - player.Position):Length() < dist and depth > 0 and grid_flag(targ_pos) do 
        targ_pos = room:GetGridPosition(room:GetGridIndex(room:GetRandomPosition(16.0)))
        depth = depth - 1
    end

    return targ_pos
end

local function spawn_rock_fx(ent)
    for i=1, ent:GetDropRNG():RandomInt(2) + 1 do 
        local vel = RandomVector():Resized(ent:GetDropRNG():RandomFloat()*1.5+1)
        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.ROCK_POOF,0,ent.Position+Vector(0,-8)+vel*4,vel,nil):Update()
    end
end


monster.spider_logic = function(self,data,ent, sprite)

    data.target_pos = data.target_pos or ent.Position
    local player = ent:GetPlayerTarget()
    if sprite:IsFinished("Appear") then 
        sprite:Play("Idle",false)
    end

    if ent:HasEntityFlags(EntityFlag.FLAG_APPEAR) then 
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR) 
        sprite:Play("Appear",true) 
        calc_targ_pos(data,player,ent)
    end 

    data.target_found = data.target_found or 0

    if data.target_found > monster.move_delay + ent.SubType*3 then 
        calc_targ_pos(data,player,ent)

        while not is_in_room(data.target_pos) do 
            calc_targ_pos(data,player,ent)
        end
    end

    if sprite:IsPlaying("Idle") or sprite:IsPlaying("Walk") then 
        if (data.target_pos - ent.Position):Length() > ent.Size then 
            ent.Velocity = ent.Velocity * math.min(0.45,math.max(0.8,(100-ent.FrameCount)/100)) + (data.target_pos - ent.Position):Resized(4)    
            data.target_found = data.target_found + 0.1
            sprite:Play("Walk",false)
        else
            sprite:Play("Idle",false)
            ent.Velocity = Vector.Zero
            data.target_found = data.target_found + 1
        end    
    end
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local player = ent:GetPlayerTarget()

    if ent.SubType == monster.subtypes.boss then --outbreak -------------------------------------------------------------------------
        if ent.MaxHitPoints ~= monster.health_max then 
            ent.HitPoints = monster.health_max
            ent.MaxHitPoints = monster.health_max
        end

        if sprite:IsEventTriggered("Shake") then 
            GODMODE.game:ShakeScreen(16)
        end

        ent.HitPoints = math.max(ent.HitPoints,(monster.health_max - (data.burrow_count or 0)*3-3))

        monster:spider_logic(data,ent,sprite)
        data.burrow_health_pool = data.burrow_health_pool or 0

        if data.burrow_health_pool > 0 then 
            data.burrow_spawn_next = data.burrow_spawn_next - 1

            if data.burrow_spawn_next <= 0 then 
                local burrow = nil 
                if ent:GetDropRNG():RandomFloat() < (data.burrow_duds or 0) * (0.125+(data.burrow_count or 0)*0.025)
                    and GODMODE.util.count_child_enemies(ent,false,function(child) return not (ent.Type == child.Type and ent.Variant == child.Variant) end) < monster.max_enemies then 
                    burrow = Isaac.Spawn(ent.Type,ent.Variant,monster.subtypes.burrow_spawn,get_rand_pos(ent,player,160),Vector.Zero,ent)
                    data.burrow_duds = 0
                else
                    burrow = Isaac.Spawn(ent.Type,ent.Variant,monster.subtypes.burrow,get_rand_pos(ent,player,32),Vector.Zero,ent)
                    data.burrow_duds = data.burrow_duds + 1
                end

                burrow.Parent = ent
                burrow:Update()
                data.burrow_spawn_next = ent:GetDropRNG():RandomInt(monster.burrow_spawn_var) + monster.burrow_spawn_int
            end
        elseif sprite:GetAnimation() == "DigIn" then
            data.burrow_spawn_next = (data.burrow_spawn_next or 0) - 1 

            if data.burrow_spawn_next % monster.burrow_spawn_int == 0 then 
                local burrow = Isaac.Spawn(ent.Type,ent.Variant,monster.subtypes.burrow,get_rand_pos(ent,player,32),Vector.Zero,ent)
                burrow.Parent = ent
                burrow:Update()
            end

            if data.burrow_spawn_next <= -50 then 
                if true then -- then 
                    for i=1,3+data.burrow_count do 
                        local burrow = Isaac.Spawn(ent.Type,ent.Variant,monster.subtypes.burrow_spawn,get_rand_pos(ent,player,160),Vector.Zero,ent)
                        burrow.Parent = ent
                        burrow:Update()        
                    end

                    sprite:Play("DigOut",true)
                end

                data.burrow_spawn_next = 0
            end
        end

        if sprite:IsPlaying("DigIn") then 
            ent.Velocity = ent.Velocity * 0.5
        elseif sprite:IsFinished("DigOut") then 
            sprite:Play("Idle",true)
        end

        if sprite:IsEventTriggered("Emerge") then 
            spawn_rock_fx(ent)
            if sprite:IsPlaying("DigIn") then 
                ent.CollisionDamage = 0
                data.burrow_health_pool = monster.burrow_health_pool + monster.burrow_health_pool_scaled * (data.burrow_count or 0)
                data.burrow_count = (data.burrow_count or 0) + 1
                data.burrow_spawn_next = ent:GetDropRNG():RandomInt(monster.burrow_spawn_var) + monster.burrow_spawn_int
                data.burrow_duds = 0
            else
                ent.CollisionDamage = 1
            end
        end

        ent.I1 = math.max(0,ent.I1 - 1)
    
        if sprite:IsEventTriggered("Dig") then 
            if sprite:IsPlaying("DigIn") then 
                ent.Visible = false
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                ent.Velocity = Vector.Zero
            else
                ent.Visible = true
                ent.Position = get_rand_pos(ent,player)
                ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                data.target_found = 0
                ent.I1 = 30
            end
        end    
    elseif ent.SubType ~= monster.subtypes.minion then --burrows -------------------------------------------------------------------------
        if ent:HasEntityFlags(EntityFlag.FLAG_APPEAR) then 
            ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR) 
            if ent.SubType == monster.subtypes.burrow then 
                sprite:Play("Burrow",true) 
            else
                sprite:Play("BurrowSpawn",true) 
            end

            sprite.PlaybackSpeed = 0.6+ent:GetDropRNG():RandomFloat()*0.6
        end 

        data.anchor_pos = data.anchor_pos or ent.Position 
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

        if sprite:IsEventTriggered("Spawn") then 
            if ent.Parent ~= nil and ent.Parent.Type == monster.type and ent.Parent.Variant == monster.variant then
                local count = math.min(#monster.spawnable_spiders,GODMODE.get_ent_data(ent.Parent).burrow_count)
                
                if count > 0 and count < 5 then 
                    local spider = monster.spawnable_spiders[count][ent:GetDropRNG():RandomInt(#monster.spawnable_spiders[count])+1]
                    local enemy = nil 
    
                    if spider ~= nil then 
                        enemy = Isaac.Spawn(spider.type,spider.var or 0,spider.subtype or 0,ent.Position,Vector.Zero,ent.Parent)
                    end
    
                    spawn_rock_fx(ent)
    
                    if enemy ~= nil then 
                        GODMODE.get_ent_data(ent.Parent).burrow_health_pool = GODMODE.get_ent_data(ent.Parent).burrow_health_pool - enemy.MaxHitPoints 
                        GODMODE.game:ShakeScreen(5)
                    end    
                end
            elseif data.spawn_data ~= nil and data.spawn_data.type ~= nil then 
                local spider = Isaac.Spawn(data.spawn_data.type,data.spawn_data.var or 0,data.spawn_data.subtype or 0,ent.Position,Vector.Zero,ent.Parent or ent.SpawnerEntity)
                spawn_rock_fx(ent)

                if data.spawn_data.hp_mod ~= nil and spider:ToNPC() then 
                    spider.MaxHitPoints = spider.MaxHitPoints * data.spawn_data.hp_mod 
                    spider.HitPoints = spider.MaxHitPoints
                end
            end
        end

        if sprite:IsFinished("Burrow") or sprite:IsFinished("BurrowSpawn") then 
            ent:Remove()
        end
    else --outbreak spider -------------------------------------------------------------------------
        monster:spider_logic(data,ent,sprite)
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit.Type == monster.type and enthit.Variant == monster.variant then 
        if amount ~= 1 then
            enthit:TakeDamage(1,flags,entsrc,countdown)
            return false 
        end

        if (enthit:GetSprite():IsPlaying("DigIn") or enthit:GetSprite():IsPlaying("DigOut") or enthit:GetSprite():IsPlaying("Appear")) or enthit:ToNPC().I1 > 0 then 
            return false 
        elseif math.ceil(enthit.HitPoints) % 3 == 0 and math.ceil(enthit.HitPoints) < enthit.MaxHitPoints then
            enthit:GetSprite():Play("DigIn",true)
        end
    end
end

return monster