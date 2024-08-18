local monster = {}
monster.name = "Pill Beggar"
monster.type = GODMODE.registry.entities.pill_beggar.type
monster.variant = GODMODE.registry.entities.pill_beggar.variant

monster.data_init = function(self, ent, data)
	if ent.Type == monster.type and ent.Variant == monster.variant then 
        data.persistent_state = GODMODE.persistent_state.single_room
    end
end

monster.player_collide = function(self,ent2,ent,ent_first)
    if ent2:ToPlayer() then
        if ent_first then 
            local player = ent2:ToPlayer()

            if ent:GetSprite():IsPlaying("Idle") and player:GetNumCoins() > 0 then 
                player:AddCoins(-1)
                local data = GODMODE.get_ent_data(ent)
                data.charge = (data.charge or 0) + 1
                local suf = "Nothing"
    
                -- 5-6 first time, 5 after first time
                if (data.charge or 0) >= math.min(6,6-math.min(3,(data.rewards or 0)) + ent:GetDropRNG():RandomInt(3)) then 
                    data.rewards = (data.rewards or 0) + 1 
                    data.charge = 0
    
                    suf = "Prize"
                end
    
                ent:GetSprite():Play("Pay"..suf,true)
                GODMODE.sfx:Play(SoundEffect.SOUND_SCAMPER,Options.SFXVolume*5.25)
            end                
        end

        return false 
    end
end

monster.npc_update = function(self, ent, data, sprite)
    data.origin = data.origin or ent.Position 
    ent.Velocity = data.origin - ent.Position
    ent.SpriteOffset = Vector(0,4)

    --When the entity first spawns, play the idle animation.
    if not sprite:IsPlaying("Teleport") and 
        (sprite:IsFinished("Idle") or sprite:IsFinished("PayNothing") or sprite:IsFinished("Prize")) then
        if data.rewards == -1 then 
            sprite:Play("Teleport",true)
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        else 
            ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
            sprite:Play("Idle",false)
        end
    end

    if sprite:IsFinished("PayPrize") then 
        if data.rewards == -1 then 
        else
            sprite:Play("Prize",true)
        end
    end

    if sprite:IsPlaying("Pill") and sprite:GetFrame() == 48 then
        sprite:Play("Idle",true)
    end

    if sprite:IsEventTriggered("Prize") then
        local chance = ent:GetDropRNG():RandomFloat() 
        GODMODE.sfx:Play(SoundEffect.SOUND_SLOTSPAWN,Options.SFXVolume*5.25)

        if chance < math.min(1,0.1+data.rewards*0.125) then -- item!
            data.rewards = -1
            local item = GODMODE.itempools.get_from_pool("pill_beggar",ent:GetDropRNG())
            Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,item,GODMODE.room:FindFreePickupSpawnPosition(ent.Position+Vector(0,64)),Vector.Zero,nil)
        else -- pill!
            local speed = 2
            Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_PILL,ent:GetDropRNG():RandomInt(PillColor.NUM_PILLS),ent.Position,(RandomVector()*speed+Vector(0,speed*1.5)):Resized(ent:GetDropRNG():RandomFloat()*3+2),nil)
        end
    end	

    if sprite:IsEventTriggered("Disappear") then 
        ent:Remove()
    end
end

return monster