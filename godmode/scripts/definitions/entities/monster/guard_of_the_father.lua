local monster = {}
-- monster.data gets updated every callback
monster.name = "Guard of the Father"
monster.type = GODMODE.registry.entities.guard_of_the_father.type
monster.variant = GODMODE.registry.entities.guard_of_the_father.variant
monster.npc_update = function(self, ent, data, sprite)

monster.sounds = {GODMODE.registry.sounds.sacred_1,GODMODE.registry.sounds.sacred_2,GODMODE.registry.sounds.sacred_3}
local min_speed = 2.0
local min_speed_hard = 4.0

if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    data.target = ent:GetPlayerTarget().Position
    
    if sprite:IsPlaying("Fire") then
        ent.Velocity = ent.Velocity * 0.95

        if sprite:IsEventTriggered("Shoot") then--data.time % 30 == 0 or data.time % 30 == 15 then
            ent:ToNPC():PlaySound(monster.sounds[ent:GetDropRNG():RandomInt(#monster.sounds)+1], 1.0, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
            GODMODE.sfx:Play(SoundEffect.SOUND_DEVILROOM_DEAL ,0.5)
            GODMODE.sfx:AdjustPitch(SoundEffect.SOUND_DEVILROOM_DEAL ,1.2)
            local range = 65
            local count = math.max(5,math.min(9,(data.target - ent.Position):Length()/32))
            for i=-math.floor(count/2),math.floor(count/2) do
                local spd = math.max(GODMODE.game.Difficulty == Difficulty.DIFFICULTY_HARD and min_speed_hard or min_speed, 6.0 - math.abs(i/math.floor(count/4))*3.0)
                local ang = data.target - ent.Position
                ang = ang / 32 / 4
                ang = ang:Rotated(i*range/count)
                local t = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,0,0,ent.Position + ang,(ang*spd):Resized(math.min(12,math.max(4,(ang*spd):Length()))),ent)
                t.Color = Color(0,80,200,1,0,50/255,180/255)
                t.RenderZOffset = -64
            end
        end

        if sprite:IsFinished("Fire") then
            sprite:Play("Idle", true) 
        end
    end
    
    if sprite:IsPlaying("Idle") then
        local t = data.target - ent.Position
        t = t / 32 / 16
        t = t:Rotated(ent:GetDropRNG():RandomFloat() * 30 - 15)
        ent.Velocity = ent.Velocity + t * 0.0125
        ent.Position = ent.Position + t * 0.025    

        if ent:GetDropRNG():RandomFloat() < 0.8 and sprite:IsEventTriggered("TryShoot") then
            sprite:Play("Fire", false)
        end
    elseif not sprite:IsPlaying("Fire") then
        sprite:Play("Idle", false) 
    end

    
end
return monster