local fam = {}
fam.name = "[GODMODE] [PLACEHOLDER]"
fam.type = GODMODE.registry.entities.placeholder.type
fam.variant = GODMODE.registry.entities.placeholder.variant

fam.familiar_update = function(self, fam, data)
    fam:MoveDiagonally(1.0+math.abs(math.cos(fam.InitSeed + fam.FrameCount / 12.5) * 0.125))
    fam.FireCooldown = math.max(0, fam.FireCooldown - 1)
end

local status_effects = {
    function(fami, ent) ent:AddBurn(EntityRef(fami), 150, 5) end,
    function(fami, ent) ent:AddFreeze(EntityRef(fami), 150) end,
    function(fami, ent) ent:AddCharmed(EntityRef(fami), 150) end,
    function(fami, ent) ent:AddConfusion(EntityRef(fami), 150) end,
    function(fami, ent) ent:AddFear(EntityRef(fami), 150) end,
    function(fami, ent) ent:AddMidasFreeze(EntityRef(fami), 150) end,
    function(fami, ent) ent:AddPoison(EntityRef(fami), 150, 5) end,
    function(fami, ent) ent:AddShrink(EntityRef(fami), 150) end,
}

local apply_fam_effect = function(fami, ent)
    local success = false 

    if ent:IsVulnerableEnemy() and fami.FireCooldown <= 0 then 
        status_effects[fami:GetDropRNG():RandomInt(#status_effects) + 1](fami, ent)
        success = true
    end

    if ent:ToPickup() and fami.FireCooldown <= 0 then 
        local reroll = true 
        ent = ent:ToPickup()
        if GODMODE.registry.mimic_chests[ent.Variant] ~= nil and fami:GetDropRNG():RandomFloat() <= 0.2 then 
            reroll = false 
        end

        if reroll then 
            local make_chest = fami:GetDropRNG():RandomFloat() <= 0.1

            if make_chest then -- chest 
                if fami:GetDropRNG():RandomFloat() < 0.75 then -- normal chest spawn
                    ent:Morph(ent.Type, PickupVariant.PICKUP_CHEST, 0, true, true)
                else -- locked_chest
                    ent:Morph(ent.Type, PickupVariant.PICKUP_LOCKEDCHEST, 0, true, true)
                end
            else
                ent:Morph(ent.Type, 0, 1, true, true)
            end
        end

        success = true
    end

    if success then 
        fami.FireCooldown = 30
        Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF01,0,ent.Position,Vector.Zero,ent)
        return true
    end
end

fam.familiar_collide = function(self, fami, ent, entfirst)
    if fami.Type == fam.type and fami.Variant == fam.variant then
        local applied = apply_fam_effect(fami, ent)
        if applied then return false end
    end
end

fam.pickup_collide = function(self,pickup,ent,entfirst)
    if ent.Type == fam.type and ent.Variant == fam.variant then
        local applied = apply_fam_effect(ent, pickup)
        if applied then return false end
    end
end

return fam