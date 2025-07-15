local monster = {}
-- monster.data gets updated every callback
monster.name = "Ooze Turret"
monster.type = GODMODE.registry.entities.ooze_turret.type
monster.variant = GODMODE.registry.entities.ooze_turret.variant

-- monster.data_init = function(self, params)
-- 	params[2].persistent_state = GODMODE.persistent_state.single_room
-- end
monster.npc_update = function(self, ent, data, sprite)
	local player = ent:GetPlayerTarget()

	if data.spider_time == nil then
		data.spider_time = 60 + ent:GetDropRNG():RandomInt(61)
		data.splat_level = 0
		sprite:Play("Idle", true)
	end

	if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
		ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
	end

	data.spider_time = data.spider_time - 1
	ent.Velocity = ent.Velocity * 0.0125

	if data.spider_time <= 0 and (ent.SubType == 1 or not GODMODE.room:IsClear()) then
		sprite:Play("Splat", false)
		--GODMODE.log("splooge!",true)
	end

	if sprite:IsFinished("Splat") then
		data.spider_time = 60 + ent:GetDropRNG():RandomInt(61)
		data.splat_level = 0
		sprite:Play("Idle", true)
	end

	if sprite:IsEventTriggered("Splat") then
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