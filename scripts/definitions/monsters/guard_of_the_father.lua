local monster = {}
-- monster.data gets updated every callback
monster.name = "Guard of the Father"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)
monster.npc_update = function(self, ent)

monster.sounds = {GODMODE.sounds.sacred_1,GODMODE.sounds.sacred_2,GODMODE.sounds.sacred_3}

if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	local data = GODMODE.get_ent_data(ent)
    data.target = ent:GetPlayerTarget().Position
    
    if ent:GetSprite():IsPlaying("Fire") then
        ent.Velocity = ent.Velocity * 0.95

        if ent:GetSprite():IsEventTriggered("Shoot") then--data.time % 30 == 0 or data.time % 30 == 15 then
            ent:ToNPC():PlaySound(monster.sounds[ent:GetDropRNG():RandomInt(#monster.sounds)+1], 1.0, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
            SFXManager():Play(SoundEffect.SOUND_DEVILROOM_DEAL ,0.5)
            SFXManager():AdjustPitch(SoundEffect.SOUND_DEVILROOM_DEAL ,1.2)
            local range = 65
            local count = math.max(5,math.min(9,(data.target - ent.Position):Length()/32))
            for i=-math.floor(count/2),math.floor(count/2) do
                local spd = 6.0 - math.abs(i/math.floor(count/2))*3.0
                local ang = data.target - ent.Position
                ang = ang / 32 / 4
                ang = ang:Rotated(i*range/count)
                local t = Game():Spawn(EntityType.ENTITY_PROJECTILE,0,ent.Position + ang,(ang*spd):Resized(math.min(12,math.max(4,(ang*spd):Length()))),ent,0,ent.InitSeed)
                t.Color = Color(0,80,200,1,0,50/255,180/255)
                t.RenderZOffset = -64
            end
        end

        if ent:GetSprite():IsFinished("Fire") then
            ent:GetSprite():Play("Idle", true) 
        end
    end
    
    if ent:GetSprite():IsPlaying("Idle") then
        local t = data.target - ent.Position
        t = t / 32 / 16
        t = t:Rotated(ent:GetDropRNG():RandomFloat() * 30 - 15)
        ent.Velocity = ent.Velocity + t * 0.0125
        ent.Position = ent.Position + t * 0.025    

        if ent:GetDropRNG():RandomFloat() < 0.8 and ent:GetSprite():IsEventTriggered("TryShoot") then
            ent:GetSprite():Play("Fire", false)
        end
    elseif not ent:GetSprite():IsPlaying("Fire") then
        ent:GetSprite():Play("Idle", false) 
    end

    
end
return monster