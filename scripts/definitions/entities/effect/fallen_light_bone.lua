local monster = {}
monster.name = "Fallen Light Bone"
monster.type = GODMODE.registry.entities.fallen_light_bone.type
monster.variant = GODMODE.registry.entities.fallen_light_bone.variant

local splash_radius = 40

monster.npc_init = function(self,ent,data)
    ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR) 
    -- ent.SpriteOffset = Vector(0,-start_height)
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end

    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

    if ent.FrameCount == 1 then
        ent:AddEntityFlags(EntityFlag.FLAG_NO_DAMAGE_BLINK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
        sprite:Play("Impact",true)
    end

    if sprite:IsEventTriggered("Impact") then
        local shock = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, ent.Position+Vector(ent.Size,ent.Size):Resized(ent.Size/2):Rotated(ent:GetDropRNG():RandomFloat()*360), Vector.Zero, ent):ToEffect()
        shock.MaxRadius = 64
        GODMODE.game:ShakeScreen(5)
        shock.Parent = ent.Parent or ent 
        ent:BloodExplode()

        ent.Velocity = Vector.Zero

        if ent.Parent and ent.Parent.Type == GODMODE.registry.entities.the_fallen_light.type and ent.Parent.Variant == GODMODE.registry.entities.the_fallen_light.variant then 
            local fl_data = GODMODE.get_ent_data(ent.Parent)
            local var = ent:GetDropRNG():RandomInt(2)+1
			Isaac.Spawn(GODMODE.registry.entities.fallen_light_crack.type, GODMODE.registry.entities.fallen_light_crack.variant, var, ent.Position,Vector.Zero,ent)

            if fl_data and fl_data.crack_spots then 
                table.insert(fl_data.crack_spots, {pos=ent.Position,var=var})
            end
        end
    end

    if sprite:IsEventTriggered("Fire") then
        local rings = 1
        local spawns = 7 
        ent:BloodExplode()
        GODMODE.game:ShakeScreen(5)

        for ring=0,rings do 
            local new_spawns = spawns + ring * spawns * 0.5
            for i=math.min(ring,1),new_spawns  do 
                local off = Vector(1,0):Resized(splash_radius * (1 + ring * 0.75)):Rotated(360 / (new_spawns - 1) * i)
                if i == 0 then off = Vector.Zero end 
                local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_RED, 0, ent.Position + off, Vector.Zero, nil):ToEffect()
                creep.Timeout = (i == 0 and 120 or 90 - ring * 25)
                creep.Scale = (i == 0 and 2.5 or ring == 0 and 1.5 or 1.0)
            end    
        end
    end

    if sprite:IsFinished("Impact") then
        ent:Kill()
    end
end

return monster