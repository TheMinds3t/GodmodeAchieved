local monster = {}
monster.name = "Bathemo Swarm"
monster.type = GODMODE.registry.entities.bathemo_swarm.type
monster.variant = GODMODE.registry.entities.bathemo_swarm.variant
local spawn_thres_min = 0.3
local slam_spam_thres = 0.2
local max_slam_dist = 320
local min_slam_dist = 160

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

	local dest = (GODMODE.room:GetCenterPos() * 3 + player.Position + Vector(1,0):Resized(ent.InitSeed % 40):Rotated((ent.InitSeed / 20 + ent.FrameCount * 2) % 360)) / 4
	local speed = 0.3
	local dampen = 0.9

	if sprite:IsPlaying("Slam") then 
		if sprite:IsEventTriggered("SwarmAttack") then 
			local dir = player.Position - ent.Position
			data.slam_dest = ent.Position + dir:Resized(math.min(math.max(min_slam_dist,dir:Length()),max_slam_dist))
		end

		if ent.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE and data.slam_dest then --airborn
			speed = 1.5
			dest = data.slam_dest
			data.airborn = true 
		end

		if ent.EntityCollisionClass == EntityCollisionClass.ENTCOLL_PLAYEROBJECTS and data.airborn == true then 
			speed = 0.0
			dampen = 0.75
		end
	end

	local dir = dest - ent.Position
	ent.Velocity = dir:Resized(math.min(speed,dir:Length())) + ent.Velocity * dampen
	if math.abs(ent.Velocity.X) + math.abs(ent.Velocity.Y) < 0.125 then 
		ent.Velocity = Vector(0,0)
	end

	local perc = ent.HitPoints / ent.MaxHitPoints
	ent.Scale = 1.0 - (1.0-perc) * 0.125

	if sprite:IsFinished("Idle") or sprite:IsFinished("Attack") or sprite:IsFinished("Spawn") or sprite:IsFinished("Slam") then
		ent.I1 = ent.I1 + 1 

		if ent:GetDropRNG():RandomFloat() < ent.I1 * 0.33 then 
			ent.I1 = (perc < slam_spam_thres and 3 or -1)
			local spawn_flag = perc > spawn_thres_min
			local task = ent:GetDropRNG():RandomFloat()

			local base_thres = 0.25 + (not spawn_flag and 0.25 or 0.0)

			if perc < slam_spam_thres then 
				sprite:Play("Slam",true)
				data.slam_dest = nil
				data.airborn = nil
			elseif task < base_thres then
				sprite:Play("Attack",true)
			elseif task < base_thres + 0.25 then
				sprite:Play("Slam",true)
				data.slam_dest = nil
				data.airborn = nil
			elseif spawn_flag then
				sprite:Play("Spawn",true)
			else 
				sprite:Play("Idle",true)
			end
		else
			sprite:Play("Idle",true)
		end
	end

	if sprite:IsEventTriggered("FlyUp") then
		ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	elseif sprite:IsEventTriggered("FlyDown") then
		ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS

		if sprite:IsPlaying("Slam") then 
			local ents = Isaac.FindInRadius(ent.Position, ent.Size * 2.25)

			for _,bat in ipairs(ents) do 
				if bat and bat.Parent and GetPtrHash(bat.Parent) == GetPtrHash(ent) then 
					bat:Die()
					ent:AddHealth(bat.HitPoints * 2.0)
				end
			end

			local shock = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, ent.Position+Vector(ent.Size,ent.Size):Resized(ent.Size/2):Rotated(ent:GetDropRNG():RandomFloat()*360), Vector.Zero, ent)
			shock.Parent = ent
			GODMODE.game:MakeShockwave(ent.Position, 0.0575, 0.005, 20)
			GODMODE.game:ShakeScreen(10)
		end
	elseif sprite:IsEventTriggered("SwarmSpawn") then
		local teethers = GODMODE.util.count_enemies (nil,GODMODE.registry.entities.teether.type , GODMODE.registry.entities.teether.variant, -1)
		local onetooths = GODMODE.util.count_enemies (nil,GODMODE.registry.entities.swarm_one_tooth.type, GODMODE.registry.entities.swarm_one_tooth.variant, -1)
		local fatbats = GODMODE.util.count_enemies (nil,GODMODE.registry.entities.swarm_fat_bat.type, GODMODE.registry.entities.swarm_fat_bat.variant, -1)
		local result = nil 

		if teethers + onetooths + fatbats < 5 then 
			local roll = ent:GetDropRNG():RandomFloat()
			if roll < 0.3 then
				result = Isaac.Spawn(GODMODE.registry.entities.teether.type, GODMODE.registry.entities.teether.variant,0,ent.Position,Vector(0,0),ent)
			elseif roll < 0.7 then
				result = Isaac.Spawn(GODMODE.registry.entities.swarm_one_tooth.type, GODMODE.registry.entities.swarm_one_tooth.variant,0,ent.Position,Vector(0,0),ent)
			else
				result = Isaac.Spawn(GODMODE.registry.entities.swarm_fat_bat.type, GODMODE.registry.entities.swarm_fat_bat.variant,0,ent.Position,Vector(0,0),ent)
			end	
		end

		if result ~= nil then
			result.Parent = ent
			result:Update()
			ent:TakeDamage(result.MaxHitPoints,0,EntityRef(ent),0)
			ent.HitPoints = ent.HitPoints - result.MaxHitPoints
		end
	elseif sprite:IsEventTriggered("SwarmAttack") then

		if sprite:IsPlaying("Attack") then 
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
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == monster.type and enthit.Variant == monster.variant then
		return enthit.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE
	end
end

monster.npc_kill = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant then
		GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_EFFECT,EffectVariant.SHOCKWAVE,-1,function(sw) 
			sw:Remove() 
			Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.ROCK_PARTICLE,0,sw.Position,sw.Velocity,nil):Update()
		end)

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