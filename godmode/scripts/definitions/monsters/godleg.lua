local monster = {}
monster.name = "Godleg"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, params)
	local ent = params[1]
	local data = params[2]
	data.init = true
	data.rand = math.floor(ent:GetDropRNG():RandomInt(61))
end

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()

	if not ent:GetSprite():IsPlaying("Attack") and not ent:GetSprite():IsPlaying("Walk") then
		ent:GetSprite():Play("Walk", false)
	end
	
	if not ent:GetSprite():IsPlaying("Attack") then
		if ent:IsFrame(60,data.rand) and ent:GetDropRNG():RandomFloat() < 0.75 then
			ent:GetSprite():Play("Attack", true)
		end

		local pathfinding = GODMODE.util.ground_ai_movement(ent,player,0.4,true)

        if pathfinding ~= nil then 
            ent.Velocity = ent.Velocity * 0.75 + pathfinding 
        elseif player ~= nil then 
            ent.Pathfinder:FindGridPath(player.Position,0.25,0,true)
        end

		--ent.Pathfinder:MoveRandomly(false)
	else
		if ent:GetSprite():IsFinished("Attack") then
			ent:GetSprite():Play("Walk", false)
		end

		ent.Velocity = ent.Velocity * 0.6
	end

	if ent:GetSprite():IsEventTriggered("Shoot") then
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

	if ent:GetSprite():IsEventTriggered("Explode") then
		Game():ShakeScreen(5)
		Game():BombExplosionEffects(ent.Position,10.0,0,Color(1,1,1,1,0,0,0),ent,1.0,false,true)
	end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if (enthit.Type == monster.type and enthit.Variant == monster.variant) and 
		(flags & DamageFlag.DAMAGE_EXPLOSION == DamageFlag.DAMAGE_EXPLOSION and 
			(entsrc.Entity and entsrc.Entity.SpawnerEntity and entsrc.Entity.SpawnerEntity.Type ~= 1 or not (entsrc.Entity and entsrc.Entity.SpawnerEntity) and entsrc.Type ~= 1)) then
		return false
	end
end

return monster