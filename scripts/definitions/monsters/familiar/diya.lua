local monster = {}
monster.name = "Diya Candle"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.familiar_init = function(self, fam)
    if fam.Type == monster.type and fam.Variant == monster.variant then
        fam:AddToFollowers()
    end
end
monster.familiar_update = function(self, fam)
	local data = GODMODE.get_ent_data(fam)
    local player = fam.Player

    if player:HasCollectible(Isaac.GetItemIdByName("Diya")) == false then fam:Remove() end

    fam.SpriteOffset = Vector(0,-14)
    if fam.Type == monster.type and fam.Variant == monster.variant then
        if GODMODE.save_manager.get_player_data(player,"DiyaLit","false") == "true" then
            if data.light == nil then 
                data.light = {}

                for i=0,10 do
                    local light = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.LIGHT, 0, fam.Position, Vector.Zero, fam)
                    light.Parent = fam
                    light:ToEffect().Scale = 4.0
                    table.insert(data.light, light)
                end

                SFXManager():Play(SoundEffect.SOUND_FIREDEATH_HISS)
            end

            if data.light ~= nil then 
                for _,light in ipairs(data.light) do 
                    light.Position = fam.Position+fam.SpriteOffset
                    light:ToEffect().Scale = fam:GetDropRNG():RandomFloat()*0.25+4.0
                end
            end

            if fam.FrameCount % 20 == 0 then
                SFXManager():Play(SoundEffect.SOUND_FIRE_BURN)
            end

            fam:GetSprite():Play("Lit",false)

            for _,ent in ipairs(Isaac.FindInRadius(fam.Position,256,EntityPartition.ENEMY)) do
                if ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_WEAKNESS) then
                    ent:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
                end
            end
        else
            if data.light ~= nil then
                for _,light in ipairs(data.light) do
                    light:Remove()
                end
            end

            data.light = nil
            fam:GetSprite():Play("Unlit",false)
        end

        fam:FollowParent()
    end
end

return monster