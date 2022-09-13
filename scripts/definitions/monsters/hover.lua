local monster = {}
monster.name = "Hover"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()

	if data.real_time > 1 then
		if data.dirx == nil then
			data.dirx = ent:GetDropRNG():RandomInt(2)*2-1
			data.diry = ent:GetDropRNG():RandomInt(2)*2-1
			data.canspawn = function(self)
				return (GODMODE.util.count_enemies(nil,EntityType.ENTITY_SPIDER,0,0) + GODMODE.util.count_enemies(nil,EntityType.ENTITY_ATTACKFLY,0,0)) < 6
			end
			ent:GetSprite():Play("Walk", true)
		end

		ent.Velocity = ent.Velocity*0.8 + Vector(data.dirx * 0.395,data.diry * 0.365)

		if ent.Position.X <= Game():GetRoom():GetTopLeftPos().X+ent.Size*2 then data.dirx = 1 end
		if ent.Position.Y <= Game():GetRoom():GetTopLeftPos().Y+ent.Size*2 then data.diry = 1 end
		if ent.Position.X >= Game():GetRoom():GetBottomRightPos().X-ent.Size*2 then data.dirx = -1 end
		if ent.Position.Y >= Game():GetRoom():GetBottomRightPos().Y-ent.Size*2 then data.diry = -1 end

		if ent:GetSprite():IsPlaying("Walk") and ent:GetDropRNG():RandomFloat() < 0.4 and math.floor(data.time) % 25 == 0 and data:canspawn() then
			ent:GetSprite():Play("Attack",false)
		end
		if ent:GetSprite():IsPlaying("Attack") and ent:GetSprite():GetFrame() == 15 then
			ent:GetSprite():Play("Walk",false)
		end

		if ent:GetSprite():IsEventTriggered("Explode") then
			Game():BombExplosionEffects(ent.Position,40,0,KColor(1.0,1.0,1.0,1.0),ent,1.1,true,true)
			ent:Die()
		end

		if ent:GetSprite():IsEventTriggered("Attack") and data:canspawn() then
			Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,ent.Position,Vector.Zero,ent)
			if ent:GetDropRNG():RandomFloat() < 0.7 then
				Isaac.Spawn(EntityType.ENTITY_ATTACKFLY,0,0,ent.Position,ent.Velocity * 0.8,ent)
			else
				EntityNPC.ThrowSpider(ent.Position,ent,Game():GetRoom():FindFreeTilePosition(ent.Position+Vector(ent:GetDropRNG():RandomInt(64)-32,ent:GetDropRNG():RandomInt(64)-32), 64),false,-48-ent:GetDropRNG():RandomInt(32))
			end
		end
	end
end

monster.npc_kill = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant and not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
		Game():BombExplosionEffects(ent.Position,30.0,TearFlags.TEAR_NORMAL,Color.Default,ent,0.8)
		Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF04,0,ent.Position,Vector.Zero,ent)

		for i=1,4 do
			local ent2 = nil  
			if ent:GetDropRNG():RandomFloat() < 0.7 then
				ent2 = Isaac.Spawn(EntityType.ENTITY_ATTACKFLY,0,0,ent.Position,ent.Velocity * 0.8,ent)
			else
				ent2 = EntityNPC.ThrowSpider(ent.Position,ent,Game():GetRoom():FindFreeTilePosition(ent.Position+Vector(ent:GetDropRNG():RandomInt(64)-32,ent:GetDropRNG():RandomInt(64)-32), 64),false,-48-ent:GetDropRNG():RandomInt(32))
			end

			ent2:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end
	end
end

return monster