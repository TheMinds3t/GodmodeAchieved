local monster = {}
monster.name = "Big Dipper"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.npc_update = function(self, ent)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	
    local data = GODMODE.get_ent_data(ent)
    local player = ent:GetPlayerTarget()

    if not ent:GetSprite():IsPlaying("Jump") then
        ent:GetSprite():Play("Idle",false)
    end

    if ent:GetSprite():IsPlaying("Idle") then
        local npc = ent:ToNPC()
        npc.Pathfinder:MoveRandomly(false)
        ent.Velocity = ent.Velocity * 0.9
    else
        ent.Velocity = Vector(0,0)
    end

    if data.time % 40 == 0 and ent:GetDropRNG():RandomFloat() < 0.65 and ent:GetSprite():IsPlaying("Idle") then
        ent:ToNPC():PlaySound(SoundEffect.SOUND_LITTLE_HORN_GRUNT_1, 1.0, 180, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
        ent:GetSprite():Play("Jump",true)
    end
    if data.time % 10 == 0 then
        local creep = Isaac.Spawn(1000,EffectVariant.CREEP_BROWN,0,ent.Position,Vector(0,0),ent)
        creep:Update()
    end

    if ent:GetSprite():IsFinished("Jump") then
        ent:GetSprite():Play("Idle",true)
    end

    if ent:GetSprite():IsEventTriggered("SFX") then 
        ent:ToNPC():PlaySound(SoundEffect.SOUND_FETUS_JUMP, 1.0, 1, false, 0.9 + ent:GetDropRNG():RandomFloat() * 0.2)
    end

    if ent:GetSprite():IsEventTriggered("Jump") then
        local entities = Isaac.GetRoomEntities()
        local nm = 0
        local dm = 0
        for i=1,#entities do if entities[i].Type == EntityType.ENTITY_DIP and entities[i].Variant == 0 and entities[i].SubType == 0 then nm = nm + 1 end end
        for x=0,6 do
            if nm < 9 and dm < 3 then
                if ent:GetDropRNG():RandomFloat() < 0.35 then
                    local poop = Isaac.Spawn(EntityType.ENTITY_DIP,2,0,ent.Position,Vector(-3+ent:GetDropRNG():RandomFloat()*6,-3+ent:GetDropRNG():RandomFloat()*6),ent)   
                    poop:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    nm = nm + 1
                    dm = dm + 1
                end
            end
            for u=0,ent:GetDropRNG():RandomFloat()*3 do
                local t = Isaac.Spawn(EntityType.ENTITY_PROJECTILE,5,0,ent.Position,Vector(-5+ent:GetDropRNG():RandomFloat()*10,-5+ent:GetDropRNG():RandomFloat()*10),ent):ToProjectile() 
                for p=0,ent:GetDropRNG():RandomFloat() * 20 do
                    t:Update()
                end
                t.Position = ent.Position
                t.Height = t.Height - 5
            end
        end
        local r = Game():GetRoom()
    end
end

monster.npc_init = function(self,ent)
    if ent.SpawnerEntity ~= nil and ent.Type == EntityType.ENTITY_DIP then 
        if GODMODE.get_ent_data(ent.SpawnerEntity).brownie == true then 
            ent:Morph(ent.Type,2,ent.SubType,ent:GetChampionColorIdx())
        end
    end
end

monster.bypass_hooks = {["npc_init"] = true}

monster.npc_kill = function(self, ent)
    if ent.Type == monster.type and ent.Variant == monster.variant and not ent:HasEntityFlags(EntityFlag.FLAG_ICE) then
		Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.POOF04,0,ent.Position,Vector.Zero,ent)

		for i=1,4 do
            local ent2 = nil
            if i < 2 then 
    			ent2 = Isaac.Spawn(EntityType.ENTITY_SQUIRT,0,0,ent.Position,Vector(-3+ent:GetDropRNG():RandomFloat()*6,-3+ent:GetDropRNG():RandomFloat()*6),ent)
                ent2:GetSprite():ReplaceSpritesheet(0,"gfx/monsters/brownie_squirt.png")
                ent2:GetSprite():LoadGraphics()
                GODMODE.get_ent_data(ent2).brownie = true
            else
    			ent2 = Isaac.Spawn(EntityType.ENTITY_DIP,2,0,ent.Position,Vector(-3+ent:GetDropRNG():RandomFloat()*6,-3+ent:GetDropRNG():RandomFloat()*6),ent)
            end  

            ent2:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		end
	end
end

return monster