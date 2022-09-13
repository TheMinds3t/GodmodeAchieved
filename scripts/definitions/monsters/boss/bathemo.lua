local monster = {}
monster.name = "Bathemo"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.spawn_flat_tear = function(self, ent, ang, speed, height)
    if curve == nil then curve = 0 end
    if height == nil then height = 1.0 end
    local ang = math.rad(ang)
    local spd = speed
    local vel = Vector(math.cos(ang)*spd,math.sin(ang)*spd)
    local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position+vel,vel,ent)
    tear = tear:ToProjectile()
    tear.Height = tear.Height * height
    return tear
end

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
    Game():GetRoom():SetClear(false)
    if data.init == nil then
        data.init = true
        data.fire_spread = 0
    end

    if ent.SubType == 0 and (data.last_anim or "Appear") == "Dash" and ent:GetSprite():IsPlaying("Idle") then
        local count = 8
        for i=1, count do
            local spd = 5.5--4.0-(1/4 * 0.5) * data.fire_spread
            local f = math.rad(360/count*i)

            local tear = monster:spawn_flat_tear(ent,f,spd,0.8)
            tear.Velocity = Vector(math.cos(f)*spd,math.sin(f)*spd)
            tear.FallingSpeed = 0.0
            tear.FallingAccel = -(6/60.0)
            tear.Scale = 1.75
            tear.ProjectileFlags = tear.ProjectileFlags + ProjectileFlags.ACCELERATE 
            --tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
        end
    end
    data.last_anim = ent:GetSprite():GetAnimation()

    if ent:GetSprite():IsPlaying("Idle") then
        data.fire_spread = 0
    end

	if ent:GetSprite():IsEventTriggered("Fire") then
        if data.fire_spread == nil then data.fire_spread = 0 else data.fire_spread = data.fire_spread + 1 end

        for i=0, 4 do

            if i ~= 2 then
                local spd = 2.5--4.0-(1/4 * 0.5) * data.fire_spread
                local spread = 30 + 10 * data.fire_spread
                local f = math.rad(spread*2-(i)*spread)

                local angle = math.atan(ent.Velocity.Y / ent.Velocity.X)

                if ent.Velocity.X < 0 then
                    angle = angle + math.rad(180)
                end

                local tear = monster:spawn_flat_tear(ent,f,spd,0.8)
                tear.Velocity = Vector(math.cos(angle+f)*spd,math.sin(angle+f)*spd)
                tear.FallingSpeed = 0.0
                tear.FallingAccel = -(6/60.0)
                tear.ProjectileFlags = tear.ProjectileFlags + ProjectileFlags.ACCELERATE 
                --tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
            end
        end
	end
end

return monster