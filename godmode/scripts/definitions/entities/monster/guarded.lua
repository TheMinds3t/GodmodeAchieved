local monster = {}
monster.name = "Guarded"
monster.type = GODMODE.registry.entities.guarded.type
monster.variant = GODMODE.registry.entities.guarded.variant

monster.npc_update = function(self, ent, data, sprite)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()

    if data.angels == nil then
        sprite:Play("Idle",true)
        data.angels = {}
        data.angel_time = 100
        data.idling = true
    end

    if data.angels and data.time % 5 == 0 and data.idling then
        if #data.angels > 0 then
            sprite:Play("IdleInvul",false)
        else
            sprite:Play("Idle",false)
        end
    end

    if data.angels then
        if data.angel_time > 100 and data.idling and #data.angels < 2 and ent.FrameCount > 10 then
            if #data.angels > 0 then
                sprite:Play("SummonInvul",true)
            else
                sprite:Play("Summon",true)
            end

            data.angel_time = 0
            data.idling = false
        end

        if #data.angels == 0 then data.angel_time = data.angel_time + 1.0 
        else
            data.angel_time = data.angel_time + 0.01
        end
        
        for i=1, #data.angels do
            if data.angels[i] ~= nil and data.angels[i]:IsActiveEnemy(false) then
                local a = data.angels[i]
                local ang = math.rad(i * (360 / #data.angels) + (ent.FrameCount * 3) % 360)
                local targ_pos = ent.Position + Vector(math.cos(ang)*(96),math.sin(ang)*(96))
                a.Velocity = a.Velocity * 0.9 + (targ_pos - a.Position) * (1/40)
            else
                local d = {}
                for i=1,#data.angels do
                    if data.angels[i]:IsActiveEnemy(false) then
                        table.insert(d,data.angels[i])
                    end
                end
                data.angels = d
            end
        end
    end

    local ti = player.Position - ent.Position
    local spd = 0.35
    if sprite:IsPlaying("Summon") or sprite:IsFinished("SummonInvul") then spd = 0.05 end

    local vel = (player.Position - ent.Position):Resized(spd)
    ent.Velocity = ent.Velocity * 0.91 + vel * 0.6
    
    if sprite:IsFinished("Summon") or sprite:IsFinished("SummonInvul") then
        if #data.angels > 0 then
            sprite:Play("IdleInvul",true)
        else
            sprite:Play("Idle",true)
        end

        data.idling = true
    end

    if sprite:IsEventTriggered("Summon") then
        ent:ToNPC():PlaySound(SoundEffect.SOUND_ANGRY_GURGLE, 1.2, 1, false, 1.0 + ent:GetDropRNG():RandomFloat() * 0.2)
        
        for i=0,2 do
            if #data.angels < 3 then
                local child = Isaac.Spawn(EntityType.ENTITY_BABY,1,1,ent.Position+Vector(1,0):Rotated(30+i*120):Resized(48),Vector(0,0),ent)
                -- child.HitPoints = child.HitPoints / 2.5
                -- child.MaxHitPoints = child.HitPoints
                table.insert(data.angels, child)
            end
        end
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit.Type == monster.type and enthit.Variant == monster.variant and GODMODE.util.count_child_enemies(enthit,false) > 0 then 
        enthit:SetColor(Color(1, 1, 1, 1, 1, 1, 1), 15, 1, true, false)
        return false 
    end
end

return monster