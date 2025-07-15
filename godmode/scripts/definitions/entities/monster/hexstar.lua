local monster = {}
monster.name = "Hexstar"
monster.type = GODMODE.registry.entities.hexstar.type
monster.variant = GODMODE.registry.entities.hexstar.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        data.spawn_tear = function(self, ang, spd)
            local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,Vector(ent.Position.X,ent.Position.Y),Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent)
            tear = tear:ToProjectile()
            tear.Height = -20
            tear.FallingSpeed = 0.0
            tear.FallingAccel = -(6/60.0)
            tear.Scale = 2.0
            tear:AddProjectileFlags(ProjectileFlags.ACCELERATE | ProjectileFlags.BOOMERANG)
            --tear.Position = tear.Position + off
        end
    end
end
monster.npc_kill = function(self, ent)
    if not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then 
        local data = GODMODE.get_ent_data(ent)
        local offset = ent:GetDropRNG():RandomFloat()*360/6
        for i=1,6 do 
            local ang = math.rad(360/6*i+offset)
            data:spawn_tear(ang,6.5)
        end
    end
end

return monster