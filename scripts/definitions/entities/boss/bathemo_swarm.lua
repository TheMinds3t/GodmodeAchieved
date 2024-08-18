local monster = {}
monster.name = "Bathemo Swarm"
monster.type = GODMODE.registry.entities.bathemo_swarm.type
monster.variant = GODMODE.registry.entities.bathemo_swarm.variant

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

monster.set_delirium_visuals = function(self,ent)
	ent:GetSprite():ReplaceSpritesheet(0,"gfx/bosses/deliriumforms/bathemo.png")
    ent:GetSprite():LoadGraphics()
end

monster.npc_update = function(self, ent, data, sprite)
	if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local player = ent:GetPlayerTarget()

	local dest = (GODMODE.room:GetCenterPos() * 5 + player.Position) / 6

	ent.Position = (ent.Position * 119.0 + dest) / 120.0
	ent.Velocity = ent.Velocity * 0.9
	if math.abs(ent.Velocity.X) + math.abs(ent.Velocity.Y) < 0.125 then 
		ent.Velocity = Vector(0,0)
	end

	if sprite:IsFinished("Idle") or sprite:IsFinished("Attack") or sprite:IsFinished("Spawn") then
		local task = ent:GetDropRNG():RandomFloat()

		if task < 0.5 then
			sprite:Play("Attack",true)
		elseif task < 0.875 then
			sprite:Play("Spawn",true)
		else
			sprite:Play("Idle",true)
		end
	end

	if sprite:IsEventTriggered("FlyUp") then
		ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	elseif sprite:IsEventTriggered("FlyDown") then
		ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
	elseif sprite:IsEventTriggered("SwarmSpawn") then
		local teethers = GODMODE.util.count_enemies (nil,GODMODE.registry.entities.teether.type , GODMODE.registry.entities.teether.variant, -1)
		local onetooths = GODMODE.util.count_enemies (nil,GODMODE.registry.entities.swarm_one_tooth.type, GODMODE.registry.entities.swarm_one_tooth.variant, -1)
		local fatbats = GODMODE.util.count_enemies (nil,GODMODE.registry.entities.swarm_fat_bat.type, GODMODE.registry.entities.swarm_fat_bat.variant, -1)

		if teethers < 2 and ent:GetDropRNG():RandomFloat() < 0.25 then
			Isaac.Spawn(GODMODE.registry.entities.teether.type , GODMODE.registry.entities.teether.variant,0,ent.Position,Vector(0,0),ent):Update()
		elseif onetooths < 3 then
			Isaac.Spawn(GODMODE.registry.entities.swarm_one_tooth.type, GODMODE.registry.entities.swarm_one_tooth.variant,0,ent.Position,Vector(0,0),ent):Update()
		elseif fatbats < 2 then
			Isaac.Spawn(GODMODE.registry.entities.swarm_fat_bat.type, GODMODE.registry.entities.swarm_fat_bat.variant,0,ent.Position,Vector(0,0),ent):Update()
		end
	elseif sprite:IsEventTriggered("SwarmAttack") then
		local off = ent:GetDropRNG():RandomFloat()
		local count = 14
		for i=1, count do
            local spd = 3.5--4.0-(1/4 * 0.5) * data.fire_spread

			if i % 2 == 0 then spd = 3 end

            local tear = monster:spawn_flat_tear(ent,360/count * i+360*off,spd,0.8)
            tear.FallingSpeed = 0.0
            tear.FallingAccel = -(6/60.0)
            tear.ProjectileFlags = tear.ProjectileFlags + ProjectileFlags.ACCELERATE 
            --tear.Color = Color(0.25,0.65,0.65,1.0,200,200,200)
        end
	end
end
monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == monster.type and enthit.Variant == monster.variant then
		return enthit.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE
	end
end
monster.npc_kill = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant then
		ent:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP | EntityFlag.FLAG_HIDE_HP_BAR)
		Isaac.Spawn(GODMODE.registry.entities.bathemo.type, GODMODE.registry.entities.bathemo.variant,0,ent.Position,ent.Velocity,ent)
		Isaac.Spawn(GODMODE.registry.entities.teether.type , GODMODE.registry.entities.teether.variant,0,ent.Position,Vector(0,0),ent):Update()
		Isaac.Spawn(GODMODE.registry.entities.teether.type , GODMODE.registry.entities.teether.variant,0,ent.Position,Vector(0,0),ent):Update()
		Isaac.Spawn(GODMODE.registry.entities.teether.type , GODMODE.registry.entities.teether.variant,0,ent.Position,Vector(0,0),ent):Update()
		Isaac.Spawn(GODMODE.registry.entities.swarm_one_tooth.type, GODMODE.registry.entities.swarm_one_tooth.variant,0,ent.Position,Vector(0,0),ent):Update()
		Isaac.Spawn(GODMODE.registry.entities.swarm_fat_bat.type, GODMODE.registry.entities.swarm_fat_bat.variant,0,ent.Position,Vector(0,0),ent):Update()
	end
end

return monster