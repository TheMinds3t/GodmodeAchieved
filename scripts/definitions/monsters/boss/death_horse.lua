local monster = {}
--fruit cellar famine
monster.name = "(GODMODE) Death Horse"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self,ent)
    if ent.SubType ~= 700 then return end
    if Game():GetRoom():IsPositionInRoom(ent.Position+Vector(ent.Size*2,0),0) then 
        if ent:IsFrame(7,1) then 
            local tear = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,ProjectileVariant.PROJECTILE_PUKE,0,ent.Position,ent.Velocity:Rotated(ent:GetDropRNG():RandomFloat()*10-5) * (0.125+ent:GetDropRNG():RandomFloat()*0.05),ent)
            tear = tear:ToProjectile()
            tear.Height = -20
            tear.FallingSpeed = 0.0
            tear.FallingAccel = -(4.8/60.0)
            tear.Scale = 1.0+ent:GetDropRNG():RandomFloat()*0.1
            tear.CollisionDamage = 2.0
            tear.ProjectileFlags = tear.ProjectileFlags | ProjectileFlags.DECELERATE 
            SFXManager():Play(SoundEffect.SOUND_TEARS_FIRE,Options.SFXVolume*1.0+0.75)    
        end
    end

    if Game():GetRoom():IsPositionInRoom(ent.Position,0) then
        local creep = Isaac.Spawn(1000,EffectVariant.CREEP_BROWN,0,ent.Position,Vector(0,0),ent):ToEffect()
        creep.Timeout = 80 + ent:GetDropRNG():RandomInt(20)
        creep.Scale = 1.0 + ent:GetDropRNG():RandomFloat()*0.05-0.025
        creep:Update()
    end
end  

return monster