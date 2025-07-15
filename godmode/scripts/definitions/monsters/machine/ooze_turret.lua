local monster = {}
-- monster.data gets updated every callback
monster.name = "Ooze Turret"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

-- monster.data_init = function(self, params)
-- 	params[2].persistent_state = GODMODE.persistent_state.single_room
-- end
monster.npc_update = function(self, ent)
	local data = GODMODE.get_ent_data(ent)
	local player = ent:GetPlayerTarget()

	if data.spider_time == nil then
		data.spider_time = 60 + ent:GetDropRNG():RandomInt(61)
		data.splat_level = 0
		ent:GetSprite():Play("Idle", true)
	end

	data.spider_time = data.spider_time - 1
	ent.Velocity = ent.Velocity * 0.0125

	if data.spider_time <= 0 and (ent.SubType == 1 or not Game():GetRoom():IsClear()) then
		ent:GetSprite():Play("Splat", false)
		--GODMODE.log("splooge!",true)
	end

	if ent:GetSprite():IsFinished("Splat") then
		data.spider_time = 60 + ent:GetDropRNG():RandomInt(61)
		data.splat_level = 0
		ent:GetSprite():Play("Idle", true)
	end

	if ent:GetSprite():IsEventTriggered("Splat") then
		local offset = Vector((-16+ent:GetDropRNG():RandomFloat()*32)*data.splat_level/2.25,(-16+ent:GetDropRNG():RandomFloat()*32)*data.splat_level/2.25)
		local e = Isaac.Spawn(1000,25,0,ent.Position + offset,Vector(0,0),ent) 
		e:ToEffect().Scale = 2.0 - (6 - (data.splat_level)) / 6.0
		data.splat_level = data.splat_level + 1
	end
end
monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == monster.Type and enthit.Variant == monster.Variant then
		return false
	end
end
return monster