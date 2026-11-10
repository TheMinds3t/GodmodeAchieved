local monster = {}
monster.name = "[GODMODE] Mr. Bones"
monster.type = GODMODE.registry.entities.mr_bones.type
monster.variant = GODMODE.registry.entities.mr_bones.variant

local anim_front = {
	[1] = "Right",
	[2] = "Down",
	[3] = "Left",
	[4] = "Up"
}

monster.npc_update = function(self, ent, data, sprite)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local player = ent:GetPlayerTarget()
	local player_ang = (((player.Position - ent.Position):GetAngleDegrees() + 45) % 360)
	local ang_ind = math.ceil(player_ang / 90)
	local atk_flag = player_ang % 90 > 40 and player_ang % 90 < 50 or false
	if sprite:IsFinished("Appear") or not sprite:IsPlaying("Appear") then
		if data.dirx == nil then
			data.dirx = ent:GetDropRNG():RandomInt(2)*2-1
			data.diry = ent:GetDropRNG():RandomInt(2)*2-1
		end

		if data.attacking == false then 
			sprite:Play("Walk"..anim_front[ang_ind], false)
		else 
			sprite:Play("Attack"..anim_front[ang_ind], false)
		end


		ent.Velocity = ent.Velocity*(0.8 + (atk_flag and -0.5 or 0)) + Vector(data.dirx * 0.395,data.diry * 0.365)

		if ent.Position.X <= (GODMODE.room_top_left or GODMODE.room:GetTopLeftPos()).X+ent.Size*2 then data.dirx = 1 end
		if ent.Position.Y <= (GODMODE.room_top_left or GODMODE.room:GetTopLeftPos()).Y+ent.Size*2 then data.diry = 1 end
		if ent.Position.X >= (GODMODE.room_bottom_right or GODMODE.room:GetBottomRightPos()).X-ent.Size*2 then data.dirx = -1 end
		if ent.Position.Y >= (GODMODE.room_bottom_right or GODMODE.room:GetBottomRightPos()).Y-ent.Size*2 then data.diry = -1 end

		if sprite:GetAnimation():sub(0,4) == "Walk" and atk_flag and not data.attacking then
			data.attacking = true
		end
		if sprite:GetAnimation():sub(0,6) == "Attack" and sprite:IsFinished(sprite:GetAnimation()) then
			data.attacking = false
		end

		if sprite:IsEventTriggered("Shoot") then
			local spd = 2.8
			if GODMODE.game.Difficulty % 2 == 1 then spd = 3.2 end
			local ang = player.Position - ent.Position
			local f = math.rad(ang:GetAngleDegrees())
			ang = Vector(math.cos(f)*spd,math.sin(f)*spd)
			local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_BONE,0,ent.Position + ang,ang*spd,ent)

			if ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then 
				tear:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			end
		end
	end

	if ent.FrameCount % 20 == 0 and ent:GetDropRNG():RandomFloat() < (data.sound_tick or 0) * 0.1 then 
        ent:PlaySound(SoundEffect.SOUND_MONSTER_YELL_A,1,0,false,1.2+ent:GetDropRNG():RandomFloat()*0.075)
        data.sound_tick = 0
    else
        data.sound_tick = (data.sound_tick or 0) + 1 / 20.0
    end
end

monster.npc_kill = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant and not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
		GODMODE.game:BombExplosionEffects(ent.Position,30.0,TearFlags.TEAR_NORMAL,Color.Default,ent,0.8)
		Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF04,0,ent.Position,Vector.Zero,ent)
	end
end

return monster