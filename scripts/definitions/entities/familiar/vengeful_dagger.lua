local monster = {}
monster.name = "Vengeful Dagger"
monster.type = GODMODE.registry.entities.vengeful_dagger.type
monster.variant = GODMODE.registry.entities.vengeful_dagger.variant

local dagger_life = 50
local dagger_speed = 11
local bleed_fx_frame = 4

-- br
local br_swing_time = 80

local swing_radius = 40
local swing_time = 10
local num_swings = 3
local swing_vel_mod = 1.7
local swing_start_off = 1
local swing_knockback = 8

local states = {
	dagger = 0,
	anim = 1,
	swing = 2,
	idle = 3,
	swing_dagger = 4
}

monster.familiar_update = function(self, fam, data)
	
    local player = fam.Player
    if fam.Type == monster.type and fam.Variant == monster.variant then
		if fam.SubType == states.anim and data.target ~= nil then 
			fam.Velocity = (data.target.Position - fam.Position)
			fam.SpriteOffset = Vector(0,math.max(0,-64 + fam.FrameCount * 0.85))
		else 
			data.continue_vel = data.continue_vel or fam.Velocity
			fam.SpriteOffset = Vector(0,-8)	
		end

		local pd = GODMODE.get_ent_data(player)

		if fam.SubType == states.dagger or fam.SubType == states.swing_dagger then 
			data.spawn_room = data.spawn_room or GODMODE.room:GetDecorationSeed()
			if GODMODE.room:GetDecorationSeed() ~= data.spawn_room then fam:Remove() end

			data.continue_vel = data.continue_vel or fam.Velocity
			fam.Velocity = data.continue_vel	
			fam.SpriteRotation = data.continue_vel:GetAngleDegrees() - 90

			if fam.FrameCount == bleed_fx_frame and fam.SubType == 0 then 
				fam:BloodExplode()
				Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.BLOOD_EXPLOSION,0,(player.Position + fam.Position) / 2.0 - Vector(0,8), Vector.Zero, player)
			elseif fam.SubType == states.swing_dagger then 
				if fam:IsFrame(2,1) then 
					local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, fam.Position+RandomVector():Resized(fam.Size/4)+fam.SpriteOffset, -fam.Velocity * 0.2, nil):ToEffect()
					fx:SetTimeout(10)
					fx.LifeSpan = 20
					fx.Scale = fam:GetDropRNG():RandomFloat() * 0.5 + 0.5
					fx.DepthOffset = -100		
				end	
			end
		elseif fam.SubType == states.swing then
			fam.Size = 48
			fam:GetSprite():Play("Swing",false)
			data.initial_vel = data.initial_vel or data.continue_vel
			local pos = player.Position + data.initial_vel:Rotated((fam.FrameCount+swing_start_off) / swing_time * 360.0):Resized(swing_radius)
			fam.Velocity = pos - fam.Position
			fam.SpriteRotation = ((player.Position - fam.Position):GetAngleDegrees() + 135) % 360
			data.continue_vel = (Vector(-1,0):Rotated(pd.last_fire * 90) + player:GetTearMovementInheritance(player.Velocity) * 0.06125):Resized(data.continue_vel:Length())

			if fam:IsFrame(3,1) then 
				local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, fam.Position+RandomVector():Resized(fam.Size)+fam.SpriteOffset, Vector.Zero, nil):ToEffect()
				fx:SetTimeout(10)
				fx.LifeSpan = 20
				fx.Scale = fam:GetDropRNG():RandomFloat() * 0.5 + 0.5
				fx.DepthOffset = -100		
			end
		elseif fam.SubType == states.idle then 
			local br_flag = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and pd.vd_charge == br_swing_time
			fam:GetSprite():Play("Idle",false)
			local pos = player.Position + Vector(0,-swing_radius * (br_flag and -1 or 1)):Rotated((pd.last_fire or player:GetFireDirection()) * 90 + 90)
			fam.Velocity = ((pos - fam.Position) + fam.Velocity * 4.0) / 5.0
			fam.SpriteRotation = (player.Position - fam.Position):GetAngleDegrees() + (br_flag and 90 or -90)

			if pd.vd_charge == br_swing_time and fam:IsFrame(3,1) then 
				local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, fam.Position+RandomVector():Resized(fam.Size)+fam.SpriteOffset, Vector.Zero, nil):ToEffect()
				fx:SetTimeout(10)
				fx.LifeSpan = 20
				fx.Scale = fam:GetDropRNG():RandomFloat() * 0.5 + 0.5
				fx.DepthOffset = -100		
			end
		end

		if fam:GetSprite():IsEventTriggered("Hit") and data.target ~= nil then 
			data.target:TakeDamage(fam.CollisionDamage,0,EntityRef(fam.Player),0)
			data.target:BloodExplode()
		end

		data.last_pos = data.last_pos or fam.Position

		if fam:GetSprite():IsFinished("Hit") 
		or ((fam.SubType == states.dagger or fam.SubType == states.swing_dagger) and (fam.FrameCount >= dagger_life or (data.last_pos - fam.Position):Length() < dagger_speed / 30.0)
		or fam.SubType == states.swing and fam.FrameCount >= swing_time * num_swings - 1 and (fam.SpriteRotation > pd.last_fire * 90 + 90 or fam.SpriteRotation < pd.last_fire * 90 - 90)) 
		and fam.FrameCount > 5 then 
			fam:Remove()

			if fam.SubType == states.swing then 
				local dagger = Isaac.Spawn(GODMODE.registry.entities.vengeful_dagger.type,GODMODE.registry.entities.vengeful_dagger.variant,4,player.Position,Vector.Zero,player)
				dagger:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				dagger:GetSprite():Play("Dagger",true)
				dagger.Velocity = data.continue_vel * swing_vel_mod
				dagger:Update()
		
			end
		end

		data.last_pos = fam.Position
		
	end
end

monster.spawn_damage_dagger = function(self,ent,fam)
    local dagger = Isaac.Spawn(GODMODE.registry.entities.vengeful_dagger.type,GODMODE.registry.entities.vengeful_dagger.variant,1,ent.Position,Vector.Zero,fam.Player)
    dagger.CollisionDamage = fam.Player.Damage * 2
    GODMODE.get_ent_data(dagger).target = ent
    dagger:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    dagger:GetSprite():Play("Hit",true)
    dagger:Update()

	if GODMODE.room_ents then 
		for _,re in ipairs(GODMODE.room_ents) do 
			if re.seed == ent.InitSeed then 
				GODMODE.save_manager.add_list_data("VDHits"..fam.Player.InitSeed,re.x.."#"..re.y,true)
			end
		end	
	end
end

monster.familiar_collide = function(self, fam, ent, entfirst)
	local enemy_flag = ent:ToNPC() and ent:IsEnemy() and ent:ToNPC().CanShutDoors and ent.Type ~= EntityType.ENTITY_FIREPLACE and ent.MaxHitPoints > 0
	if (fam.SubType == states.dagger or fam.SubType == states.swing_dagger) and enemy_flag then
		monster.spawn_damage_dagger(self,ent,fam)
		fam:Remove()
		return true
	elseif fam.SubType == states.swing then 
		if ent:ToProjectile() then 
			ent:Remove()
		elseif enemy_flag then 
			ent.Velocity = ent.Velocity * 0.3 + (fam.Position - fam.Player.Position):Resized(swing_knockback)
		end
	end

	if fam.SubType ~= 2 then 
		return true
	end
end


return monster