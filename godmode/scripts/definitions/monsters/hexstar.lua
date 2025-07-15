local monster = {}
monster.name = "Hexstar"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self,params)
    local ent = params[1]
    params[2].spawn_tear = function(self, ang, spd)
        local tear = Game():Spawn(EntityType.ENTITY_PROJECTILE,0,Vector(ent.Position.X,ent.Position.Y),Vector(math.cos(ang)*spd,math.sin(ang)*spd),ent,0,ent.InitSeed)
        tear = tear:ToProjectile()
        tear.Height = -20
        tear.FallingSpeed = 0.0
        tear.FallingAccel = -(6/60.0)
        tear.Scale = 2.0
        tear:AddProjectileFlags(ProjectileFlags.ACCELERATE | ProjectileFlags.BOOMERANG)
        --tear.Position = tear.Position + off
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