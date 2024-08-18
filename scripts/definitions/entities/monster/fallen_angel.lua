local monster = {}
monster.name = "Fallen Angelic Baby"
monster.type = GODMODE.registry.entities.fallen_angelic_baby.type
monster.variant = GODMODE.registry.entities.fallen_angelic_baby.variant

monster.npc_update = function(self, ent, data, sprite)
if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
	local player = ent:GetPlayerTarget()
	if not data.init then
        data.init = true
        data.spawn_tear = function(self, ang, spd)
            local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,Vector(ent.Position.X,ent.Position.Y),Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
            tear = tear:ToProjectile()
            tear.Height = -20
            tear.FallingSpeed = 0.0
            tear.FallingAccel = -(3/60.0)
            tear:AddProjectileFlags(ProjectileFlags.ACCELERATE | ProjectileFlags.BOOMERANG)
            --tear.Position = tear.Position + off
        end
    end

	if sprite:IsEventTriggered("Ring") then
        ent:BloodExplode()
        local spd = 4.75 + ent:GetDropRNG():RandomFloat() * 0.25
        local ang = 45
		for i=0,3 do
            local f = math.rad(360 / 4 * i + ang)
            data:spawn_tear(f,spd)
        end
	end
end

return monster