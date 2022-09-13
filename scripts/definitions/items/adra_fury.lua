local item = {}
item.instance = Isaac.GetItemIdByName( "Adramolech's Fury" )
item.eid_description = "↑ -20 or -50% charges to negate damage, whichever is larger#↑ Small all stats up for each charge#↓ 50% chance for enemies to become champions#↑ On use, teleports to special devil room"
item.eid_transforms = GODMODE.util.eid_transforms.LEVIATHAN
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "This item has multiple abilities:"},
      {str = " - Any charge the item has will be used as shields for you when taking damage. You will lose 20 charges each time you negate damage this way."},
      {str = " - Each charge you hold will grant a small all stats up, up to +20 luck, +1 speed, +5 damage, +2 fire delay, +1 tears, and +0.5 shot speed."},
      {str = " - If you use the item, you will be teleported to a unique devil room with high rewards and the charge will be set to 10."},
      {str = " - You will gain 1 charge for this item for every marked champion enemy killed by any player."},
      {str = " - Holding this item makes a constant 50% chance for enemies to be converted into champion enemies."},
    },
    { -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
	  {str = "If the item is not at full charge, you are unable to pick up new items. Instead, they will be converted to charges for Adramolech's Fury. The only time this is not true is within the unique devil room entered from using the item."}
    },
}

item.calc_birthright_chance = function(self)
    local total = 0

    GODMODE.util.macro_on_players_that_have(item.instance,function(player) 
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then 
            total = total + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
        end
    end)

    GODMODE.save_manager.set_data("AdraFuryBirthrightChance",total)
end


item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end
	local data = GODMODE.get_ent_data(player)
    local slot = GODMODE.util.get_active_slot(player,item.instance)
    local charges = player:GetActiveCharge(slot)
    local stat_bonus = charges/10

    if cache == CacheFlag.CACHE_LUCK then
        player.Luck = player.Luck + stat_bonus*2
    end
    if cache == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + stat_bonus/10.0
    end
    if cache == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + stat_bonus/2.0
    end
    if cache == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,stat_bonus/5.0,true)
        player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,stat_bonus/10.0)
    end
    if cache == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + stat_bonus/20.0
    end
end

item.indicator = Sprite()
item.indicator:Load("gfx/effect_adra_fury_champ.anm2", true)

--TODO: Genesis + ??? card
item.use_item = function(self, coll,rng,player,flags,slot,var_data)
    if coll == item.instance then 
        Isaac.ExecuteCommand("goto s.devil.651")
        player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SHOTSPEED)
        player:EvaluateItems()
        local slot = GODMODE.util.get_active_slot(player,item.instance)

        if slot > -1 then 
            player:SetActiveCharge(10,slot)
        end

        return true
    end
end

item.player_update = function(self,player,offset)
	if player:HasCollectible(item.instance) then
        local data = GODMODE.get_ent_data(player)
        data.adra_cooldown = math.max(0,(data.adra_cooldown or 0) - 1)
        -- if data.adra_cooldown > 0 then
        --     GODMODE.log("cooldown is "..data.adra_cooldown,true)
        -- end
    end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    local flag = true
    if enthit:ToPlayer() and enthit:ToPlayer():HasCollectible(item.instance) and amount > 0 and flags & DamageFlag.DAMAGE_NO_PENALTIES ~= DamageFlag.DAMAGE_NO_PENALTIES then
        local player = enthit:ToPlayer()
        local data = GODMODE.get_ent_data(player)
        local slot = GODMODE.util.get_active_slot(player, item.instance)

        if slot > -1 then
            if player:GetActiveItem(slot) == item.instance and player:GetActiveCharge(slot) > 0 or (data.adra_cooldown or 0) > 0 then
                if ((data.crossbones or 0) + (data.tecpatl or 0)) > 0 then
                    return false
                end

                if player:GetActiveCharge(slot) > 9 and player:GetActiveCharge(slot) < 21 then
                    Game():BombExplosionEffects(player.Position,player.Damage * 5 + 40,TearFlags.TEAR_NORMAL,Color.Default,player,1,false)
                    Game():ShakeScreen(10)
                elseif (data.adra_cooldown or 0) == 0 then
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, player.Position, Vector.Zero, nil)
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, player.Position, Vector.Zero, nil)
                    Game():ButterBeanFart(player.Position, 256, player, false, false)
                end

                if (data.adra_cooldown or 0) == 0 then 
                    player:SetActiveCharge(math.max(0,player:GetActiveCharge(slot)-20),slot)
                    data.adra_cooldown = 30
                    
                    player:AddCacheFlags(CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SHOTSPEED)
                    player:EvaluateItems()
                end

                flag = false
            end
        end
    end

    if flag == false then
        return false
    end
end

--weight rarer champions lower, randomly select champion color
local gen_color = function(ent)
    local color_type = ent:GetDropRNG():RandomFloat()
    local sel_color = -1 

    if color_type < 0.85 then
        sel_color = ent:GetDropRNG():RandomInt(18)
    else
        sel_color = ent:GetDropRNG():RandomInt(26)
    end
    
    return sel_color
end

local devil_price = {
    [-4] = function(player) player:AddMaxHearts(-2) player:AddSoulHearts(-4) end,
    [-3] = function(player) player:AddSoulHearts(-6) end,
    [-2] = function(player) player:AddMaxHearts(-4) end,
    [-1] = function(player) player:AddMaxHearts(-2) end,
}

item.pickup_collide = function(self, pickup,ent,entfirst)
	if ent:ToPlayer() and (pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE or pickup.Variant == PickupVariant.PICKUP_SHOPITEM) and entfirst == false then
        local room = Game():GetRoom()
        local room_data = Game():GetLevel():GetCurrentRoomDesc().Data
        item:calc_birthright_chance()

        if room:GetType() == RoomType.ROOM_ANGEL or room_data.Name == "[GODMODE] Adramolech's Fury" or room_data.Name == "Death Certificate" then
        else 
            local player = ent:ToPlayer()
                
            if player:HasCollectible(item.instance) then 
                if pickup.FrameCount < 30 then --for chests and other items that show up when interacting with other pickups
                    return false
                end
    
                local slot = GODMODE.util.get_active_slot(player,item.instance)

                if player:GetActiveCharge(slot) < 100 and pickup.SubType > 0 and pickup.SubType ~= CollectibleType.COLLECTIBLE_BIRTHRIGHT and pickup.SubType ~= Isaac.GetItemIdByName("Adramolech's Blessing") then 
                    local config = Isaac.GetItemConfig():GetCollectible(pickup.SubType)

                    if config.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST then 
                        pickup:Remove()
                        local count = math.floor(5 + (math.max(1,config.Quality-1)-1)*2.5)

                        if room:GetType() == RoomType.ROOM_DEVIL and pickup.Price ~= 0 then 
                            devil_price[pickup.Price](player)
                            count = count + 10
                            SFXManager():Play(SoundEffect.SOUND_DEVILROOM_DEAL,Options.SFXVolume*10.0)
                        end

                        player:AnimateCollectible(pickup.SubType)

                        for i=1,count do 
                            local charge = Isaac.Spawn(Isaac.GetEntityTypeByName("Adramolech's Fuel"), Isaac.GetEntityVariantByName("Adramolech's Fuel"),1,ent.Position,RandomVector()*(player:GetCollectibleRNG(item.instance):RandomFloat()*2+4.0),pickup)
                            GODMODE.get_ent_data(charge).player_target = player 
                            GODMODE.get_ent_data(charge).seek_time = 10
                        end

                        player:AddMaxHearts(config.AddMaxHearts)
                        player:AddMaxHearts(config.AddBlackHearts)
                        player:AddMaxHearts(config.AddSoulHearts)

                        return false
                    end
                end
            end
        end
    end
end


item.first_level = function(self) 
    item:calc_birthright_chance()
end

item.new_room = function(self)
    item:calc_birthright_chance()
end

item.npc_init = function(self, ent)
    if ent and ent:ToNPC() and GODMODE.util.is_valid_enemy(ent) and not ent:IsBoss() and ent.MaxHitPoints > 5 and ent.SpawnerEntity == nil and ent.CollisionDamage > -1 and GODMODE.armor_blacklist:can_be_champ(ent) then 
        local br_mod = tonumber(GODMODE.save_manager.get_data("AdraFuryBirthrightChance","0"))
        if ent:GetDropRNG():RandomFloat() < 0.5+math.min(0.25, br_mod) and GODMODE.util.total_item_count(item.instance) > 0 then 
            if br_mod <= 0 or br_mod > 0 and ent:GetDropRNG():RandomFloat() > 0.225 + math.min(0.525,br_mod*0.025) then 
                local color = gen_color(ent)

                while color == ChampionColor.DARK_RED do 
                    color = gen_color(ent)
                end

                ent:MakeChampion(ent.DropSeed,color,true)
            end

            GODMODE.get_ent_data(ent).adra_fury = true
            local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, ent.Position, Vector.Zero, nil)
            fx:Update()
        end
    end
end

item.npc_post_render = function(self, ent,offset)
    local data = GODMODE.get_ent_data(ent)
    if data and data.adra_fury == true then
        item.indicator:SetFrame("Blessing", ent.FrameCount % 6)
        item.indicator:Render(Isaac.WorldToScreen(ent.Position+ent.SpriteOffset)-Vector(0,ent.Size+8),Vector.Zero,Vector.Zero)
    end
end

item.npc_kill = function(self, ent)
    if ent:ToNPC() and (ent:IsBoss() and ent:ToNPC().ParentNPC == nil or GODMODE.get_ent_data(ent).adra_fury == true) then
        local count = 1 
        if ent:IsBoss() then count = math.floor(ent.MaxHitPoints/50) end

        GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
            if not player:IsDead() then 
                for i=1,count do 
                    local charge = Isaac.Spawn(Isaac.GetEntityTypeByName("Adramolech's Fuel"), Isaac.GetEntityVariantByName("Adramolech's Fuel"),1,ent.Position,RandomVector()*(player:GetCollectibleRNG(item.instance):RandomFloat()*2+4.0),ent)
                    GODMODE.get_ent_data(charge).player_target = player
                    GODMODE.get_ent_data(charge).seek_time = 5
                end
            end
        end)            
    end
end

return item