local monster = {}
-- monster.data gets updated every callback
monster.name = "Dream"
monster.type = GODMODE.registry.entities.dream.type
monster.variant = GODMODE.registry.entities.dream.variant

local orbit_radius = 128
local orbit_variance = 64

monster.npc_update = function(self, ent, data, sprite)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()
	ent.SplatColor = Color(0.1,1,1,0.4,1,1,1)

    if sprite:IsFinished("Appear") then
        sprite:Play("Idle",true)
    end

    if sprite:IsFinished("Fire") or sprite:IsFinished("TeleportIn") then
        sprite:Play("Idle",false)
    end

    if sprite:IsFinished("Idle") then
        ent.I1 = ent.I1 + 1

        if ent:GetDropRNG():RandomFloat() < (ent.I1 * 0.1 + 0.5) and (player.Position - ent.Position):Length() > orbit_radius - orbit_variance/2 then 
            if ent:GetDropRNG():RandomFloat() < 0.25+ent.I2 * 0.125 then
                sprite:Play("TeleportOut",true)
                ent.I2 = 0
            else
                sprite:Play("Fire",true)
                ent.I2 = ent.I2 + 1
            end
            
            ent.I1 = 0
        else 
            sprite:Play("Idle",true)

            if ent:GetDropRNG():RandomFloat() < 0.3 then 
                GODMODE.sfx:Play(SoundEffect.SOUND_SCARED_WHIMPER,1,1,false,1.25)
            end
        end
    end

    local time_scale = math.rad(ent.FrameCount*4)
    local off = Vector(1,0):Resized(orbit_radius+orbit_variance/2-math.sin(ent.Index*50+time_scale)*orbit_variance/2):Rotated(ent.Index*50+ent.FrameCount+(data.ang_off or 0))
    local targ_pos = ((player.Position+off) - ent.Position) 

    ent.Velocity = ent.Velocity * 0.9 + targ_pos:Resized(math.cos(time_scale)*0.5+1)

    if sprite:IsEventTriggered("Teleport") then
        local v = player.Position
        local ang = math.rad(ent:GetDropRNG():RandomFloat() * 360)
        v = v + Vector(math.cos(ang) * 160,math.sin(ang) * 160)
        ent.Position = v
        sprite:Play("TeleportIn",true)
        ent.Velocity = Vector(0,0)
        data.ang_off = ent:GetDropRNG():RandomInt(360)
    end

    if sprite:IsEventTriggered("Fire") then
        GODMODE.sfx:Play(SoundEffect.SOUND_GHOST_SHOOT,1,1,false,1.25)
        local ang = (player.Position - ent.Position):Resized(3)
        local proj = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_FIRE,0,ent.Position + ang,ang,ent):ToProjectile()
        proj.Scale = 1.5
        proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.ACCELERATE
        proj.FallingAccel = -(4.0/60.0)
        proj:SetColor(Color(50/255,50/255,255/255,1,100/255,100/255,255/255), 999, 1, false, false)
    end
end

monster.npc_collide = function(self, ent, ent2, entfirst)
    if ent2:ToPlayer() then
        return true
    end
end
return monster