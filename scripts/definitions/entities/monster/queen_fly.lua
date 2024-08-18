local monster = {}
monster.name = "Queen Fly"
monster.type = GODMODE.registry.entities.queen_fly.type
monster.variant = GODMODE.registry.entities.queen_fly.variant

monster.convert_map = {
	[EntityType.ENTITY_FLY] = EntityType.ENTITY_ATTACKFLY,
	[EntityType.ENTITY_ATTACKFLY] = EntityType.ENTITY_POOTER,
	[EntityType.ENTITY_ARMYFLY] = EntityType.ENTITY_POOTER,
	[EntityType.ENTITY_DART_FLY] = EntityType.ENTITY_POOTER,
	[EntityType.ENTITY_RING_OF_FLIES] = EntityType.ENTITY_POOTER,
	[EntityType.ENTITY_SWARM] = EntityType.ENTITY_POOTER,
	[EntityType.ENTITY_HUSH_FLY] = EntityType.ENTITY_HUSH_BOIL,
}

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
		data.rand = math.floor(ent:GetDropRNG():RandomInt(30))

		data.get_convert = function(self)
			local ents = Isaac.GetRoomEntities()
			local res = nil

			for i=1, #ents do
				local ent = ents[i]
				if ent then
					if monster.convert_map[ent.Type] ~= nil and ent:ToNPC() then
						res = ent:ToNPC()
						break
					end
				end
			end

			if res ~= nil then 
				return {ent=res,convert=monster.convert_map[res.Type]}
			else return nil end
		end
	end
end
monster.npc_update = function(self, ent, data, sprite)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local player = ent:GetPlayerTarget()

	if ent:GetDropRNG():RandomFloat() < 0.5 and ent:IsFrame(30,data.rand) then
		ent:ToNPC():PlaySound(SoundEffect.SOUND_INSECT_SWARM_LOOP, 0.3, 0, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
	end

	ent.Pathfinder:MoveRandomly(false)
	ent.Pathfinder:EvadeTarget(player.Position)

	if data.init == nil then
		sprite:Play("Idle",false)
		data.init = true
	end

	if sprite:IsPlaying("Idle") and ent:GetDropRNG():RandomFloat() < 0.85 and ent:IsFrame(30,data.rand) then 
		if GODMODE.util.count_enemies(nil,EntityType.ENTITY_POOTER) <= GODMODE.util.count_enemies(nil,monster.type,monster.variant) or data:get_convert() ~= nil then
			sprite:Play("Attack",true)
		end
	end

	if sprite:IsFinished("Attack") then
		sprite:Play("Idle",false)
	end

	if sprite:IsEventTriggered("Convert") then
		local convert_data = data:get_convert()

		if convert_data ~= nil then
			local ent2 = convert_data.ent
			local convert = convert_data.convert
			ent2:Morph(convert,0,0,ent2:GetChampionColorIdx())
			Isaac.Spawn(1000,3,0,ent2.Position - Vector(0,16),Vector(0,0),ent)
		elseif GODMODE.util.count_enemies(ent,EntityType.ENTITY_POOTER) == 0 then
			for i=0, ent:GetDropRNG():RandomInt(3)+1 do
				Isaac.Spawn(EntityType.ENTITY_FLY,0,0,ent.Position,Vector(0,0),ent)
			end
		end
	end
end

return monster