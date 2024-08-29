local monster = {}
monster.name = "Godleg"
monster.type = GODMODE.registry.entities.godleg.type
monster.variant = GODMODE.registry.entities.godleg.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
		data.init = true
		data.rand = math.floor(ent:GetDropRNG():RandomInt(61))
	end
end

monster.npc_update = function(self, ent, data, sprite)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local player = ent:GetPlayerTarget()

	if not sprite:IsPlaying("Attack") and not sprite:IsPlaying("Walk") then
		sprite:Play("Walk", false)
	end
	
	if not sprite:IsPlaying("Attack") then
		if ent:IsFrame(60,data.rand) and ent:GetDropRNG():RandomFloat() < 0.75 then
			sprite:Play("Attack", true)
		end

		local pathfinding = GODMODE.util.ground_ai_movement(ent,player,0.4,true)

        if pathfinding ~= nil then 
            ent.Velocity = ent.Velocity * 0.75 + pathfinding 
        elseif player ~= nil then 
            ent.Pathfinder:FindGridPath(player.Position,0.25,0,true)
        end

		--ent.Pathfinder:MoveRandomly(false)
	else
		if sprite:IsFinished("Attack") then
			sprite:Play("Walk", false)
		end

		ent.Velocity = ent.Velocity * 0.6
	end

	if sprite:IsEventTriggered("Shoot") then
		local params = ProjectileParams()
		params.Scale = 1.25
		params.HeightModifier = -25
		params.FallingSpeedModifier = -(1/20.0)
		local ring_size = 12
		local angle = 360 / ring_size
		local offset = ent:GetDropRNG():RandomFloat() * angle
		local size = 32.0

		for i=1,ring_size do
			local ang = math.rad(angle * i + offset)
			local pos = ent.Position + Vector(math.cos(ang)*size,math.sin(ang)*size)
			ent:ToNPC():FireBossProjectiles(1,pos,1.0,params)
		end
	end

	if sprite:IsEventTriggered("Explode") then
		GODMODE.game:ShakeScreen(5)
		GODMODE.game:BombExplosionEffects(ent.Position,10.0,0,Color(1,1,1,1,0,0,0),ent,1.0,false,true)
		ent.I1 = 1
	end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if (enthit.Type == monster.type and enthit.Variant == monster.variant) and 
		(flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION and 
			(entsrc.Entity and entsrc.Entity.SpawnerEntity and entsrc.Entity.SpawnerEntity.Type ~= 1 or not (entsrc.Entity and entsrc.Entity.SpawnerEntity) and entsrc.Type ~= 1)) then
		return false
	end
end

-- explode if no attacks happened, prevent softlocks!
monster.npc_kill = function(self,ent)
	if ent:ToNPC() and ent:ToNPC().I1 ~= 1 then 
		GODMODE.game:ShakeScreen(5)
		GODMODE.game:BombExplosionEffects(ent.Position,10.0,0,Color(1,1,1,1,0,0,0),ent,1.0,false,true)	
	end
end

return monster