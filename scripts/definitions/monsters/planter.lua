local monster = {}
monster.name = "Planter"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()

    if data.real_time == 1 then
        ent:GetSprite():Play("Walk",true)
    end

    if ent:GetSprite():IsPlaying("Walk") then
        local npc = ent:ToNPC()
        npc.Pathfinder:MoveRandomly(false)
    else
        ent.Velocity = Vector(0,0)
    end

    if data.time % 20 == 0 and ent:GetDropRNG():RandomFloat() < 0.5 and ent:GetSprite():IsPlaying("Walk") then
        ent:GetSprite():Play("Attack",true)
    end

    if ent:GetSprite():IsFinished("Attack") then
        ent:GetSprite():Play("Walk",true)
    end

    if ent:GetSprite():IsEventTriggered("Shoot") then
        ent:ToNPC():PlaySound(SoundEffect.SOUND_FETUS_JUMP, 1.0, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
        ent:ToNPC():PlaySound(SoundEffect.SOUND_BOSS2_BUBBLES, 1.0, 59, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
        Isaac.Spawn(1000,25,4,ent.Position,Vector(0,0),ent)   
        local r = Game():GetRoom()
        r:SpawnGridEntity(r:GetGridIndex(ent.Position), GridEntityType.GRID_SPIDERWEB, 0, ent.InitSeed, 0)
    end
end

return monster