local item = {}
item.instance = Isaac.GetItemIdByName( "Adramolech's Blessing" )
item.eid_description = "↑ Charges negate damage taken#One charge gained for every 4 champion enemy killed#↓ +10% per charge champion chance#+10% chance per charge for devil item to be rerolled into higher quality#↑ On use, permanent all stats up while holding"
item.eid_transforms = GODMODE.util.eid_transforms.LEVIATHAN
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "This item has multiple abilities:"},
      {str = " - Any charge the item has will be used as shields for you when taking damage. The ratio is one half heart per charge."},
      {str = " - If you use the item, you will get a small all stats up (much larger all stats up if you are Xaphan)."},
      {str = " - You will gain 1 charge for this item for every 4 marked champion enemies killed by any player."},
      {str = " - Merely holding this item gives an additional chance for marked champions to spawn. It is a weighted chance for this to occur, beginning at a 10% chance and increasing by 10% for each time it fails to create a champion. This chance is increased by 10% for each charge all players have with this item combined."},
    },
    { -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
	  {str = "If you are playing as Xaphan, losing this item lowers your Luck by 6."}
    },
}


item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end
	local data = GODMODE.get_ent_data(player)

    if cache == CacheFlag.CACHE_LUCK and player:GetName() == "Xaphan" then
        player.Luck = player.Luck + 5
    end

    if GODMODE.util.is_start_of_run() then 
        GODMODE.save_manager.set_player_data(player,"AdraUses","0",true)
    end

    local add = tonumber(GODMODE.save_manager.get_player_data(player,"AdraUses","0"))

    if player:GetName() ~= "Xaphan" then 
        add = add * 0.5
    end

    if cache == CacheFlag.CACHE_LUCK then
        if add > 0 then player.Luck = player.Luck + 1 end
        player.Luck = player.Luck + add
    end
    if cache == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + add * 0.2
    end
    if cache == CacheFlag.CACHE_DAMAGE then
        player.Damage = player.Damage + add * 0.75
    end
    if cache == CacheFlag.CACHE_FIREDELAY then
        if player:GetName() == "Xaphan" then 
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,add*0.15,true)
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,add*0.15)
        else
            player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,add*0.3)
        end
    end
    if cache == CacheFlag.CACHE_SHOTSPEED then
        player.ShotSpeed = player.ShotSpeed + add * 0.06125
    end
end

item.post_get_collectible = function(self,coll,pool,decrease,seed)
    local count = item.calc_total_charge()

    if count > 0 then
        if pool == ItemPoolType.POOL_DEVIL then
            if Isaac.GetPlayer():GetCollectibleRNG(item.instance):RandomFloat() < count * 0.1 then
                local item = coll
                local config = Isaac.GetItemConfig():GetCollectible(item)

                while config.Quality < 3 do 
                    item = Game():GetItemPool():GetCollectible(pool)
                    config = Isaac.GetItemConfig():GetCollectible(item)
                end

                return item
            end
        end
    end
end

item.calc_total_charge = function()
    local charge = -1
    GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
        local slot = GODMODE.util.get_active_slot(player, item.instance)

        if charge == -1 then charge = 0 end

        charge = charge + player:GetActiveCharge(slot)
    end)

    return charge
end

item.indicator = Sprite()
item.indicator:Load("gfx/effect_adra_champ.anm2", true)


--TODO: Genesis + ??? card
item.use_item = function(self, coll,rng,player,flags,slot,var_data)
    if coll == item.instance then 
        local void_slot = GODMODE.util.get_active_slot(player,CollectibleType.COLLECTIBLE_VOID)
        GODMODE.save_manager.set_player_data(player,"AdraUses",tonumber(GODMODE.save_manager.get_player_data(player,"AdraUses","0"))+1,true)
        player:AddCacheFlags(CacheFlag.CACHE_LUCK | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_SHOTSPEED)
        player:EvaluateItems()

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

                if (data.adra_cooldown or 0) == 0 then 
                    player:SetActiveCharge(player:GetActiveCharge(slot)-1,slot)
                    data.adra_cooldown = 30
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, player.Position, Vector.Zero, nil)
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, player.Position, Vector.Zero, nil)
                    Game():ButterBeanFart(player.Position, 256, player, false, false)
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

item.npc_init = function(self, ent)
    local charge = item.calc_total_charge()
    if ent and ent:ToNPC() and GODMODE.util.is_valid_enemy(ent) and not ent:IsBoss() and ent.MaxHitPoints > 5 and ent.SpawnerEntity == nil and ent.CollisionDamage > -1 and GODMODE.armor_blacklist:can_be_champ(ent) then 
        local champ_inc = tonumber(GODMODE.save_manager.get_data("AdraChampInc","0"))
        local count = item.calc_total_charge() + 1 + champ_inc

        if count > 0 then
            if ent:GetDropRNG():RandomFloat() < count * 0.1 then 
                GODMODE.get_ent_data(ent).adra_blessed = true
                local color = gen_color(ent)

                while color == ChampionColor.DARK_RED do 
                    color = gen_color(ent)
                end

                ent:MakeChampion(ent.DropSeed,color,true)
                Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, ent.Position, Vector.Zero, nil)
                GODMODE.save_manager.set_data("AdraChampInc",0)
            else
                GODMODE.save_manager.set_data("AdraChampInc",champ_inc+1)
            end
        end
    end
end

item.npc_post_render = function(self, ent,offset)
    local data = GODMODE.get_ent_data(ent)
    if data and data.adra_blessed == true then
        item.indicator:SetFrame("Blessing", ent.FrameCount % 6)
        item.indicator:Render(Isaac.WorldToScreen(ent.Position+ent.SpriteOffset)-Vector(0,ent.Size+8),Vector.Zero,Vector.Zero)
    end
end

item.npc_kill = function(self, ent)
    if ent:ToNPC() and ent:ToNPC():IsChampion() and GODMODE.get_ent_data(ent).adra_blessed == true then
        GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
            local charge = Isaac.Spawn(Isaac.GetEntityTypeByName("Adramolech's Fuel"), Isaac.GetEntityVariantByName("Adramolech's Fuel"),0,ent.Position,RandomVector()*(player:GetCollectibleRNG(item.instance):RandomFloat()*2+4.0),ent)
            GODMODE.get_ent_data(charge).player_target = player
            GODMODE.get_ent_data(charge).seek_time = 5
        end)            
    end
end

return item