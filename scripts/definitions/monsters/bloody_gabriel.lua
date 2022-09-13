local monster = {}
-- monster.data gets updated every callback
monster.name = "Bloody Gabriel"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
--monster.subtype = 0 --deobfuscated
--monster.subtype_sensitive = false --deobfuscated

monster.data_init = function(self, ent, data)
end
monster.npcUpdate = function(self, ent)
	local data = self.data
	local player = Isaac.GetPlayer(0)
	if not data.init then
        data.init = true
        data.spawn_tear = function(self, ang, speed, curve)
            if curve == nil then curve = 0 end
            local vel = Vector(math.cos(ang) * speed,math.sin(ang) * speed)
            local offset = ent:GetDropRNG():RandomFloat() * 6.28
            local off = Vector(math.cos(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7),math.sin(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7))
            local params = ProjectileParams()
            params.HeightModifier = -1.5
            params.FallingSpeedModifier = 0.1
            params.FallingAccelModifier = 0.25
            params.Scale = 1.0
            params.CurvingStrength = curve

            local tear = ent:FireBossProjectiles(1, ent.Position + off*(0.9+ent:GetDropRNG():RandomFloat()*0.5), speed, params)
            --tear.Position = tear.Position + off
        end
    end

	if ent:GetSprite():IsEventTriggered("Bleed") then
		for i=0,4 do
            local spd = 1.05 + ent:GetDropRNG():RandomFloat()
            local f = math.rad(360 / 8 * i + ent:GetDropRNG():RandomFloat() * 360)
            data:spawn_tear(f,spd,2.5)
        end
        ent:TakeDamage(5.0,DamageFlag.DAMAGE_DEVIL,EntityRef(ent),0)
	end
end
monster.renderEnt = function(self, ent, offset)
end
monster.entityDamaged = function(self,enthit,amount,flags,entsrc,countdown)
	return true
end
monster.entityKilled = function(self, ent)
end
-- There are a lot of functionless callbacks in all older enemies because I used the template_item lua class as a basis for this before I updated this one to be smoother. 
return monster