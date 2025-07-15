local monster = {}
monster.name = "Purple Heart"
monster.type = GODMODE.registry.entities.purple_heart.type
monster.variant = GODMODE.registry.entities.purple_heart.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()

    if data.spawn ~= true and ent.SubType == 0 then
        sprite:Play("Heart",true)
        data.proj = nil
        data.proj2 = nil
        data.mask = GODMODE.game:Spawn(monster.type,monster.variant,ent.Position,Vector(0,0),ent,1,ent.InitSeed)
        local dat = GODMODE.get_ent_data(data.mask)
        dat.heart = ent
        dat.ang = 0
        data.spawn = true
        data.proj_cooldown = 0
    end

    if ent.SubType == 1 then --mask
        if (data.heart == nil or data.heart:IsDead() or not data.heart.Visible) and ent.FrameCount > 2 then ent:Kill() else

            if data.heart and data.heart:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN) and not ent:HasEntityFlags(EntityFlag.FLAG_ICE_FROZEN) then 
                ent:AddEntityFlags(EntityFlag.FLAG_ICE_FROZEN)
            end
            
            if data.targ_pos == nil or data.time % 45 == 0 then
                data.targ_pos = player.Position - (data.heart or ent).Position
                data.targ_pos:Normalize()
                data.targ_pos = data.targ_pos * math.min(ent.FrameCount,80.0)
            end

            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
            ent.Velocity = (((data.heart or ent).Position + data.targ_pos) - ent.Position) / 6.0
 
            local dir = ""
            local x = ent.Position.X - (data.heart or ent).Position.X
            local y = ent.Position.Y - (data.heart or ent).Position.Y 
            if math.abs(x) > math.abs(y) then if x < 0 then dir = "Left" else dir = "Right" end else if y < 0 then dir = "Up" else dir = "Down" end end
            sprite:Play("Mask"..dir,false)
        end
    else
        ent.Velocity = Vector(ent:GetDropRNG():RandomFloat() - 0.5, ent:GetDropRNG():RandomFloat() - 0.5) / 1.1 + ent.Velocity / 1.0625 + (player.Position - ent.Position) * (1 / 240) / 4.0
        local scale = 1.0 - data.proj_cooldown / 25 if scale > 1 then scale = 1 end
        data.proj_cooldown = data.proj_cooldown - 1
        local targ_pos = data.mask.Position

        if data.mask == nil or data.mask:IsDead() then 
            targ_pos = ent.Position
        end

        if data.proj ~= nil then
            local dir = targ_pos - data.proj.Position
            local vect = Vector(math.cos(math.rad((dir:GetAngleDegrees()))), math.sin(math.rad((dir:GetAngleDegrees()))))
            data.proj.Velocity = data.proj.Velocity / (1+0.12*scale) + vect * (1.85*scale)
        end

        if data.proj2 ~= nil then
            local dir = targ_pos - data.proj2.Position
            local vect = Vector(math.cos(math.rad((dir:GetAngleDegrees()))), math.sin(math.rad((dir:GetAngleDegrees()))))
            data.proj2.Velocity = data.proj2.Velocity / (1+0.12*scale) + vect * (1.85*scale)
        end
    end

    if sprite:IsEventTriggered("Fire") then
        ent:ToNPC():PlaySound(SoundEffect.SOUND_HEARTBEAT_FASTER , 1.0, 1, false, 0.7 + ent:GetDropRNG():RandomFloat() * 0.3)
        local spd = 3.0
        local ang = player.Position - ent.Position
        local f = math.rad(ang:GetAngleDegrees())
        ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
        local p = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position + ang,ang*spd,ent)
        p.Color = Color(58/255.0,0,101/255.0,255/255.0,0,0,0)
        data.proj = p
        p.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        f = math.rad(-ang:GetAngleDegrees())
        ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
        local p1 = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position - ang,ang*spd,ent)
        p1.Color = Color(58/255.0,0,101/255.0,255/255.0,0,0,0)
        data.proj2 = p1
        p1.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
        data.proj_cooldown = 25
    end

end

monster.npc_kill = function(self, ent)
    if ent.SubType == 0 then 
        local data = GODMODE.get_ent_data(ent)

        if data.mask then 
            data.mask:Kill()
        end
    end
end

return monster