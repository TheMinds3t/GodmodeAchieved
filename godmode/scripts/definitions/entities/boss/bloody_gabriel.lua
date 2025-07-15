local monster = {}
monster.name = "Bloody Gabriel"
monster.type = GODMODE.registry.entities.bloody_gabriel.type
monster.variant = GODMODE.registry.entities.bloody_gabriel.variant

monster.npc_update = function(self, ent, data, sprite)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local player = ent:GetPlayerTarget()
	if not data.init then
        data.init = true
        data.spawn_tear = function(self, ang, speed, curve)
            if curve == nil then curve = 0 end
            local vel = Vector(math.cos(ang) * speed,math.sin(ang) * speed)
            local offset = ent:GetDropRNG():RandomFloat() * 6.28
            local off = Vector(math.cos(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7),math.sin(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7))
            local params = ProjectileParams()
            params.HeightModifier = -2
            params.FallingSpeedModifier = 0.1
            params.FallingAccelModifier = 0.05
            params.Scale = 1.2
            params.CurvingStrength = curve

            local tear = ent:FireBossProjectiles(1, off*10+player.Position, speed, params)
            if sprite:IsPlaying("Attack2") then
                off = off * 0.125 + Vector(-80,32)
            end
        end
    end

	if sprite:IsEventTriggered("Bleed") then
		for i=0,5 do
            local spd = 1.25 + ent:GetDropRNG():RandomFloat()
            local f = math.rad(360 / 8 * i + ent:GetDropRNG():RandomFloat() * 360)
            data:spawn_tear(f,spd,2.5)
        end
        ent:TakeDamage(1.0,DamageFlag.DAMAGE_DEVIL,EntityRef(ent),0)
	end
end

return monster