local monster = {}
monster.name = "Fetal Baby"
monster.type = GODMODE.registry.entities.fetal_baby.type
monster.variant = GODMODE.registry.entities.fetal_baby.variant

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	

	if sprite:IsEventTriggered("Shoot") then
        data.bleed = (data.bleed or 0) + 10
	end

    if (data.bleed or 0) > 0 then 
        data.bleed = data.bleed - 1 

        if data.bleed % 3 == 0 then
            local blood = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION,0,ent.Position+Vector(0,-20)+RandomVector():Resized(ent:GetDropRNG():RandomFloat()*8),Vector.Zero,ent):ToEffect()
            blood.DepthOffset = 100
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED,0,ent.Position+RandomVector():Resized(ent:GetDropRNG():RandomFloat()*32),Vector.Zero,ent):ToEffect()
            creep:SetTimeout(100-ent:GetDropRNG():RandomInt(20))
            creep.Scale = 1.25-ent:GetDropRNG():RandomFloat()*0.4    
        end
    end
end

monster.npc_kill = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant and not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
        for i=0,5 do
            local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED,0,ent.Position+RandomVector():Resized(ent:GetDropRNG():RandomFloat()*32),Vector.Zero,ent):ToEffect()
            creep:SetTimeout(100-ent:GetDropRNG():RandomInt(20))
            creep.Scale = 1.8-ent:GetDropRNG():RandomFloat()*0.4    
        end
    end
end

monster.projectile_init = function(self, proj)
    if proj.SpawnerEntity ~= nil and proj.SpawnerType == monster.type and proj.SpawnerVariant == monster.variant then 
        proj:AddScale(-0.5)
        proj.ProjectileFlags = proj.ProjectileFlags | ProjectileFlags.DECELERATE | ProjectileFlags.BURST
    end
end

return monster