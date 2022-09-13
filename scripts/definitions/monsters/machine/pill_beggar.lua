local monster = {}
monster.name = "Pill Beggar"
monster.type = Isaac.GetEntityTypeByName(monster.name)
monster.variant = Isaac.GetEntityVariantByName(monster.name)

monster.data_init = function(self, params)
	params[2].persistent_state = GODMODE.persistent_state.single_room
end
monster.npc_update = function(self, ent)
	local data = self.data
    ent.Velocity = Vector(0,0)
    --When the entity first spawns, play the idle animation.
    if ent.FrameCount == 1 then
        ent:GetSprite():Play("Idle",true)
    end
    
    local player = Isaac.GetPlayer(0)

    --Calculate the distance between the player and the beggar
    local dist = math.abs(player.Position.X - ent.Position.X) + math.abs(player.Position.Y - ent.Position.Y)
    --Get the pill color the player has
    local pc = player:GetPill(0)
    if dist < ent.Size+16 and pc ~= PillColor.PILL_NULL and not ent:GetSprite():IsPlaying("Pill") then
        pill_effect = pc
        player:AddPill(PillColor.PILL_NULL)
        --Isaac.DebugString("Pill beggar found pill!")
        ent:GetSprite():Play("Pill",true)
    end

    if ent:GetSprite():IsPlaying("Pill") and ent:GetSprite():GetFrame() == 16 then
        local ent = Isaac.GetRoomEntities()
        for x=0,#ent-1 do
            local i = #ent - x
            if ent[i].Type == 5 and ent[i].Variant == PickupVariant.PICKUP_PILL and ent[i].SubType == pill_effect then ent[i]:Kill() break end
        end
        --Isaac.DebugString("Pill beggar removed pill!")
    end
    if ent:GetSprite():IsPlaying("Pill") and ent:GetSprite():GetFrame() == 48 then
        ent:GetSprite():Play("Idle",true)
    end

    if ent:GetSprite():IsEventTriggered("Prize") then
        --event will be a percentage between 0 and 1. This is what will happen, based on a percentage.
        local event = ent:GetDropRNG():RandomFloat()
        ent.SubType = ent.SubType + 1
        --Adding a subtype each time he gives a prize is a good way to limit the max amount of payouts he'll give.
        --Isaac.DebugString("Pill beggar selected event to happen ("..event..")!")
        --If the player has used him between 4-8 times, then kill him.
        if ent.SubType >= 4 + math.floor(ent:GetDropRNG():RandomFloat()*4) then
            ent:Kill()
        elseif event < 0.15 then
            local items = {CollectibleType.COLLECTIBLE_PLACEBO,CollectibleType.COLLECTIBLE_LITTLE_BAGGY,CollectibleType.COLLECTIBLE_ACID_BABY,CollectibleType.COLLECTIBLE_FORGET_ME_NOW,CollectibleType.COLLECTIBLE_MOMS_BOTTLE_PILLS,CollectibleType.COLLECTIBLE_SULFURIC_ACID,CollectibleType.COLLECTIBLE_MOMS_COIN_PURSE,CollectibleType.COLLECTIBLE_ROID_RAGE,CollectibleType.COLLECTIBLE_THE_VIRUS,CollectibleType.COLLECTIBLE_SPEED_BALL,CollectibleType.COLLECTIBLE_GROWTH_HORMONES,CollectibleType.COLLECTIBLE_SYNTHOIL,CollectibleType.COLLECTIBLE_ADDERLINE}
            -- Arguments: ID, Variant, Position, Velocity, Owner, Subtype, SpawnSeed
            Game():Spawn(5, 100, ent.Position+Vector(0,32), Vector(0,0), player, items[math.floor(ent:GetDropRNG():RandomFloat()*(#items-1))%#items+1], player.InitSeed)
            ent:Kill()
        elseif event > 0.4 then
            Game():Spawn(5, PickupVariant.PICKUP_PILL, ent.Position, Vector(-1+ent:GetDropRNG():RandomFloat()*2,2+ent:GetDropRNG():RandomFloat()*3), player, ent.FrameCount % PillColor.NUM_PILLS, player.InitSeed)
        else
            Game():Spawn(EntityType.ENTITY_FLY, PickupVariant.PICKUP_PILL, ent.Position, Vector(-1+ent:GetDropRNG():RandomFloat()*2,2+ent:GetDropRNG():RandomFloat()*3), player, 0, player.InitSeed)
        end
    end	
end
return monster