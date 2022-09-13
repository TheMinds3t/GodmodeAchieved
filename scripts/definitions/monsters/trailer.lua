local monster = {}
monster.name = "Trailer"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()
	
    if ent.FrameCount == 1 and ent.SubType == 0 then
        ent:GetSprite():Play("MrMawBodyHori",true)
    end

    if ent.FrameCount == 1 and ent.SubType == 1 then
        ent:GetSprite():Play("Head",true)
        data.started = ent:GetSprite():IsPlaying("Neck")
    end

    if ent.FrameCount == 1 and ent.SubType == 10 then
        ent:GetSprite():Play("Neck",true)
        data.started = ent:GetSprite():IsPlaying("Neck")
    end

    if ent.SubType == 0 then
        if data.head == nil then
            local h = Game():Spawn(ent.Type,ent.Variant,ent.Position, Vector(0,0),ent,1,ent.InitSeed)
            data.head = h
            GODMODE.get_ent_data(h).body = ent
        end

        if data.neck == nil then
            data.neck = {}

            for i=0,9 do
                local n = Game():Spawn(ent.Type,ent.Variant,ent.Position, Vector(0,0),ent,10,ent.InitSeed)
                table.insert(data.neck, n)
                local da = GODMODE.get_ent_data(n)
                da.head = data.head
                da.body = ent
            end
        end

        ent:AnimWalkFrame("MrMawBodyHori","MrMawBodyVert",0.1)
        local pathfinding = GODMODE.util.ground_ai_movement(ent,player,0.8,true)

        if pathfinding ~= nil then 
            ent.Velocity = ent.Velocity * 0.75 + pathfinding 
        elseif player ~= nil then 
            ent.Pathfinder:FindGridPath(player.Position,0.65,0,true)
        end

        local d = ent.Position
        if data.head ~= nil then d = d - data.head.Position end
        d = math.abs(d.X) + math.abs(d.Y)
        d = d / 2
        if d > 2 and data.head ~= nil then
            data.head.Position = data.head.Position + (ent.Position - data.head.Position) * (1 / 45)
        end
        if data.head == nil then d = (ent.Position-Vector(0,16)) else d = (ent.Position-Vector(0,12)) - (data.head.Position - Vector(0,6)) end

        for i=1,#data.neck do
            data.neck[i].Position = (ent.Position-Vector(0,16)) - (d) / #data.neck * i
        end
    end

    if ent.SubType == 10 then
        ent.Velocity = Vector(0,0)
        ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
        ent:GetSprite():Play("Neck",false)
        if data.head == nil or data.body == nil then ent:Kill() elseif data.head:IsDead() or data.body:IsDead() then ent:Kill() end 
    end

    if ent.SubType == 1 then
        ent:GetSprite():Play("Head",false)
        if ent.FrameCount % 10 == 0 then
            Game():Spawn(EntityType.ENTITY_EFFECT,EffectVariant.CREEP_RED,ent.Position, Vector(0,0),ent,0,ent.InitSeed)
        end

        if data.body == nil or data.body:IsDead() then
            ent.Pathfinder:FindGridPath(player.Position, 0.5, 4, true)
        else
            ent.Velocity = Vector(0,0)
        end
    end
end
return monster