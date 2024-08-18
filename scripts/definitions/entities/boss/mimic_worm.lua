local monster = {}
-- monster.data gets updated every callback
monster.name = "Mimic Worm"
monster.type = GODMODE.registry.entities.mimic_worm.type
monster.variant = GODMODE.registry.entities.mimic_worm.variant

monster.data_init = function(self, ent,data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        data.persistent_state = GODMODE.persistent_state.single_room
    end
end

monster.set_delirium_visuals = function(self,ent)
	ent:GetSprite():ReplaceSpritesheet(0,"gfx/bosses/deliriumforms/gimmimick.png")
    for i=3,6 do 
        ent:GetSprite():ReplaceSpritesheet(i,"gfx/bosses/deliriumforms/gimmimick.png")
    end
    ent:GetSprite():LoadGraphics()
end

monster.npc_init = function(self, ent, data)
    if ent.Type == monster.type and ent.Variant == monster.variant then
        data.keys_left = ent:GetDropRNG():RandomInt(4) + 3
        data.init_pos = ent.Position

        data.enter_room = function(ent)
            local data2 = GODMODE.get_ent_data(ent)

            
        end
    end
end

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end
    local player = ent:GetPlayerTarget()

    if data.fire == nil then
        data.fire = function()
            local count = 3
            for i=1,count do
                local ang = math.rad(ent:GetDropRNG():RandomFloat()*(360/count)+360/count * i)
                local speed = ent:GetDropRNG():RandomFloat() * 0.5 + 1.0
                local vel = Vector(math.cos(ang) * speed,math.sin(ang) * speed)
                local offset = ent:GetDropRNG():RandomFloat() * 6.28
                local off = Vector(math.cos(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7),math.sin(offset) * 48*(ent:GetDropRNG():RandomFloat() * 0.6 + 0.7))+(player.Position-ent.Position)/4
                local params = ProjectileParams()
                params.HeightModifier = -56
                params.FallingSpeedModifier = 1.0
                params.FallingAccelModifier = 0.25
                params.Scale = 0.9+ent:GetDropRNG():RandomFloat()*0.5

                local tear = ent:FireBossProjectiles(1, ent.Position + off*(0.9+ent:GetDropRNG():RandomFloat()*0.5), speed, params)
                --tear.Height = tear.Height - 64
            end
        end
    end

    if sprite:IsEventTriggered("DropSound") then
        GODMODE.sfx:Play(SoundEffect.SOUND_CHEST_DROP)
    end
    if sprite:IsEventTriggered("OpenSound") then
        GODMODE.sfx:Play(SoundEffect.SOUND_CHEST_OPEN)
    end

    data.init_pos = data.init_pos or ent.Position 
    ent.Position = (ent.Position * 2 + data.init_pos) / 3
    ent.Velocity = ent.Velocity * 0.25

    if GODMODE.util.is_delirium() and data.opened ~= true then 
        data.keys_left = 0
        sprite:Play("Open",false)
        sprite.PlaybackSpeed = 2.5
    end

    if data.keys_left == 0 then
        if sprite:IsFinished("UseKey") or sprite:IsFinished("UseGoldenKey") then
            sprite:Play("Open",true)
        end    

        if sprite:IsEventTriggered("Open") then
            data.opened = true
            GODMODE.game:ButterBeanFart(ent.Position,64,ent,true,true)
            ent:ClearEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
            GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_YELL_B)
            GODMODE.sfx:Play(SoundEffect.SOUND_CHEST_OPEN)
        end

        if data.persistent_data.in_room == false then 
            ent:Remove()
        end

        if data.opened == true and not GODMODE.util.is_delirium() then
            GODMODE.room:SetClear(false)
            for i=0,8 do
                if i < 8 then
                    local door = GODMODE.room:GetDoor(i)
    
                    if door and door:IsOpen() then
                        door:Close(true)
                    end
                end
            end
        end

        if sprite:IsFinished("Open") or sprite:IsFinished("Attack") then
            sprite:Play("IdleOpen",false)
            ent.CollisionDamage = 1
            sprite.PlaybackSpeed = 1
        end

        if sprite:IsPlaying("IdleOpen") and data.time % 30 == 0 then
            sprite:Play("Attack",true)
            data.grunt_tell = 0
        end

        if sprite:IsEventTriggered("Shoot") then
            data.fire()
        end

        if sprite:IsEventTriggered("Spawn") then
            if GODMODE.util.count_enemies(nil,EntityType.ENTITY_SPIDER,0,-1) < 4 then
                EntityNPC.ThrowSpider(ent.Position,ent,ent.Position+Vector(ent:GetDropRNG():RandomFloat()*128-64,ent:GetDropRNG():RandomFloat()*128-64),false,-64-ent:GetDropRNG():RandomFloat()*16)
            else
                data.fire()
            end
        end

        if sprite:IsEventTriggered("Grunt") then
            data.grunt_tell = data.grunt_tell + 1
            if data.grunt_tell == 1 then
                GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_ROAR_2)
            else
                GODMODE.sfx:Play(SoundEffect.SOUND_MONSTER_YELL_B)
            end
        end
    else
        if sprite:IsFinished("UseKey") or sprite:IsFinished("UseGoldenKey") then
            sprite:Play("Idle",true)
        end    

        if not ent:HasEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP) then
            ent:AddEntityFlags(EntityFlag.FLAG_DONT_COUNT_BOSS_HP)
        end
        GODMODE.room:SetClear(true)
		for i=0,8 do
			if i < 8 then
				local door = GODMODE.room:GetDoor(i)

				if door then
                    door:Open()
                    --GODMODE.log("opening",true)
				end
			end
		end

        if Isaac.GetPlayer():GetNumKeys() < data.keys_left and not GODMODE.room:IsClear() then
            Isaac.GetPlayer():AddKeys(data.keys_left - Isaac.GetPlayer():GetNumKeys())
        end
    end
end

monster.npc_kill = function(self, ent)
    GODMODE.game:BombExplosionEffects(ent.Position,30)
    local pickups = {
        PickupVariant.PICKUP_COIN,
        PickupVariant.PICKUP_COIN,
        PickupVariant.PICKUP_HEART,
        PickupVariant.PICKUP_HEART,
        PickupVariant.PICKUP_BOMB,
        PickupVariant.PICKUP_KEY
    }

    for i=1,8+ent:GetDropRNG():RandomInt(5) do
        Isaac.Spawn(EntityType.ENTITY_PICKUP,pickups[ent:GetDropRNG():RandomInt(#pickups)+1],0,ent.Position,Vector(ent:GetDropRNG():RandomFloat()*12-6,ent:GetDropRNG():RandomFloat()*12-6),ent)
    end

    Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,0,GODMODE.room:FindFreePickupSpawnPosition(ent.Position),Vector.Zero,ent)
    Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,0,GODMODE.room:FindFreePickupSpawnPosition(ent.Position),Vector.Zero,ent)

    GODMODE.room:SetClear(true)
end

monster.npc_collide = function(self, ent, ent2, entfirst)
    if ent2:ToPlayer() then
        local data = GODMODE.get_ent_data(ent)

        if data.opened ~= true and not (ent:GetSprite():IsPlaying("UseKey") or ent:GetSprite():IsPlaying("UseGoldenKey") or ent:GetSprite():IsPlaying("Open")) then 
            local player = ent2:ToPlayer()
            
            local cost = 1 
            local gold_flag = player:HasGoldenKey()

            if gold_flag or player:GetNumKeys() > 0 then
                data.keys_left = math.max(0,data.keys_left-cost)
                --GODMODE.log("key!",true)
                if not gold_flag then
                    ent:GetSprite():Play("UseKey",false)
                    player:AddKeys(-cost)
                else
                    ent:GetSprite():Play("UseGoldenKey",false)
                end    
            else
                return false
            end

        elseif (ent:GetSprite():IsPlaying("UseKey") or ent:GetSprite():IsPlaying("UseGoldenKey") or ent:GetSprite():IsPlaying("Open")) then
            return false
        end
    end
end

monster.tear_collide = function(self,tear,ent,entfirst)
    local data = GODMODE.get_ent_data(ent)

    if data.opened ~= true then
        return true
    end
end

monster.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local data = GODMODE.get_ent_data(enthit)

    if (enthit.Type == monster.type and enthit.Variant == monster.variant) and data.opened ~= true then
        return false
    end
end

return monster