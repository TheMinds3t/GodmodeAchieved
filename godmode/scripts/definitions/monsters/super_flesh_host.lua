local monster = {}
monster.name = "Spiked Flesh Host"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()

	if data.init == nil then data.init = true ent:GetSprite():Play("Idle", true)
		data.spawn_tear = function(self, ang, spd)
			local tear = Game():Spawn(EntityType.ENTITY_PROJECTILE,0,Vector(ent.Position.X,ent.Position.Y),Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent,0,player.InitSeed)
			tear = tear:ToProjectile()
			tear.Height = -25
			tear.FallingSpeed = 0.0
			tear.FallingAccel = -(2/60.0)
		end
        data.rand = ent:GetDropRNG():RandomInt(10)
	end
	
	ent.Velocity = ent.Velocity * 0.7

	if ent:GetSprite():IsPlaying("Idle") and data.time % 35 == (25+data.rand) and ent:GetDropRNG():RandomInt(9) <= 6 then
		ent:GetSprite():Play("Attack", true)
		data.atk_count = 0
	end
	if ent:GetSprite():IsFinished("Attack") then
		ent:GetSprite():Play("Idle", true)
	end
	if ent:GetSprite():IsEventTriggered("Attack") then
		data.atk_count = data.atk_count + 1
		local count = 2+data.atk_count
		local space = 90 / count  
		for i=0,count-1 do
			local ang = (player.Position - ent.Position):GetAngleDegrees()+space/2
			data:spawn_tear(math.rad(ang-45 + i * space),8.0)
		end
	end
end

return monster