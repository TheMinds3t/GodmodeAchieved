local item = {}
item.instance = GODMODE.registry.items.reclusive_tendencies
item.eid_description = "Charms small spiders in the room for 5 seconds#Spawns 3+(Small Spider count) chiggers"
item.eid_transforms = GODMODE.util.eid_transforms.LORD_OF_THE_FLIES..","..GODMODE.util.eid_transforms.SPIDERBABY
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, all small spiders in the room become charmed for 10 seconds."},
		{str = "When used, for each winged spider present a chigger will be spawned at the player's location dealing 10% of your damage."},
	},
}

item.wing_spider = {GODMODE.registry.entities.winged_spider.type,GODMODE.registry.entities.winged_spider.variant}

item.valid_spiders = {
    {EntityType.ENTITY_SPIDER,nil},
    {EntityType.ENTITY_BIGSPIDER,nil},
    {EntityType.ENTITY_STRIDER,nil},
    {EntityType.ENTITY_ROCK_SPIDER,nil},
    {EntityType.ENTITY_ROCK_SPIDER,nil},
    item.wing_spider
}

item.is_valid_spider = function(ent)
    for i=1,#item.valid_spiders do
        if item.valid_spiders[i][1] == ent.Type and (item.valid_spiders[i][2] == nil or item.valid_spiders[i][2] == ent.Variant) then
            return true
        end
    end

    return false
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        local data = GODMODE.get_ent_data(player)
        local birthright = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)

        for i=1,#item.valid_spiders do 
            local type = item.valid_spiders[i]
            GODMODE.util.macro_on_enemies(nil,type[1],type[2],nil, function(spider)
                local time = 150 
    
                if birthright then 
                    time = 300 
                end
    
                spider:AddCharmed(EntityRef(player),time)
    
                data.spiders = data.spiders or {}
                local flag = false
                for ind,spider2 in ipairs(data.spiders) do
                    if GetPtrHash(spider2) == GetPtrHash(spider) then
                        flag = true
                    end
                end

                if spider.MaxHitPoints ~= player.Damage then 
                    spider.MaxHitPoints = player.Damage
                    spider.HitPoints = spider.MaxHitPoints

                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then 
                        spider.CollisionDamage = player.Damage * 0.1
                    else
                        spider.CollisionDamage = player.Damage * 0.15
                    end

                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) or player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then 
                        spider.CollisionDamage = spider.CollisionDamage * 1.25
                    end
                end
    
                if flag == false then table.insert(data.spiders, spider) end
            end)
        end

        if not GODMODE.room:IsClear() then 
            local spiders = GODMODE.util.count_enemies(nil,GODMODE.registry.entities.winged_spider.type,GODMODE.registry.entities.winged_spider.variant,0) + GODMODE.util.count_enemies(nil,EntityType.ENTITY_STRIDER,0,0)+3
            if birthright then spiders = spiders * 2 end
    
            for i=1,spiders do 
                local chigger = Isaac.Spawn(GODMODE.registry.entities.chigger.type, GODMODE.registry.entities.chigger.variant, 1, player.Position, RandomVector()*(player:GetCollectibleRNG(item.instance):RandomFloat() * 4 + 3), nil)
                chigger:ToFamiliar().Player = player
                chigger:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                chigger:GetSprite():ReplaceSpritesheet(0, "gfx/familiars/chigger_tainted.png")
                chigger:GetSprite():LoadGraphics()
                chigger.CollisionDamage = player.Damage / 10.0 * 2.5
            end    
        end

        return true
    end
end

item.player_update = function(self, player, data)
    if player:HasCollectible(item.instance) then

        if data.spiders then
            for ind,spider in ipairs(data.spiders) do
                if not spider:Exists() then 
                    table.remove(data.spiders, ind)
                else
                    if not spider:HasEntityFlags(EntityFlag.FLAG_CHARM) then
                        spider.CollisionDamage = 1
                        table.remove(data.spiders, ind)
                    end
                end
            end
        end
    end
end


-- item.npc_collide = function(self,ent,ent2,entfirst)
--     local flag = false

--     if ent.Type == item.wing_spider[1] and ent.Variant == item.wing_spider[2] 
--     GODMODE.util.macro_on_players_that_have(item.instance, function(player)
--         local data = GODMODE.get_ent_data(player)

--         if data.spiders then
--             for _,spider in ipairs(data.spiders) do
--                 if GetPtrHash(spider) == GetPtrHash(ent) and ent:HasEntityFlags(EntityFlag.FLAG_CHARM) and not ent2:IsVulnerableEnemy() then
--                     flag = true
--                     break
--                 end
--             end
--         end
--     end)

--     if flag == true then return true end
-- end

-- item.tear_collide = function(self,tear,ent,entfirst)
--     local flag = false
--     GODMODE.util.macro_on_players_that_have(item.instance, function(player)
--         local data = GODMODE.get_ent_data(player)

--         if data.spiders then
--             for _,spider in ipairs(data.spiders) do
--                 if spider then 
--                     if GetPtrHash(spider) == GetPtrHash(ent) and ent:HasEntityFlags(EntityFlag.FLAG_CHARM) then
--                         flag = Isaac.CountEnemies() ~= GODMODE.util.count_enemies(nil,GODMODE.registry.entities.winged_spider.type,GODMODE.registry.entities.winged_spider.variant,0) + GODMODE.util.count_enemies(nil,EntityType.ENTITY_STRIDER,0,0)
--                         break
--                     end
--                 end
--             end
--         end
--     end)

--     if flag == true then return true end
-- end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if (enthit:IsVulnerableEnemy() or enthit:IsBoss()) and GODMODE.util.is_player_attack(entsrc) and not item.is_valid_spider(enthit) then
        GODMODE.util.macro_on_players_that_have(item.instance, function(player)
            local tick_flag = player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) or flags & DamageFlag.DAMAGE_LASER ~= 0
            if (tick_flag and player.FrameCount % 5 == 0 or not tick_flag) then 
                if amount >= player.Damage * 0.25 and entsrc.Entity ~= nil and --damage size clause 
                    ((entsrc.Entity:ToTear() and entsrc.Entity:ToTear().Parent ~= nil and GetPtrHash(entsrc.Entity:ToTear().Parent) == GetPtrHash(player)) --tear proc clause
                        or GetPtrHash(entsrc.Entity) == GetPtrHash(player)) then --player proc clause
                    
                            -- GODMODE.log("SPIDER!",true)
                    
                    local spd = 5.0 + player:GetCollectibleRNG(item.instance):RandomFloat()
                    local ang = math.rad(player:GetCollectibleRNG(item.instance):RandomFloat() * 360)
                    local ent = Isaac.Spawn(GODMODE.registry.entities.winged_spider.type,GODMODE.registry.entities.winged_spider.variant,0,player.Position, Vector.Zero, player):ToNPC()
                    
                    local data = GODMODE.get_ent_data(ent)
                    data.throw_pos = (player.Position + enthit.Position*2) / 3
                    local dmg = amount
                    
                    if not player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then 
                        dmg = dmg * 0.1
                    else
                        dmg = dmg * 0.15
                    end

                    if player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) or player:HasCollectible(CollectibleType.COLLECTIBLE_HIVE_MIND) then 
                        local dmg_mod = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BFFS) + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_HIVE_MIND)
                        dmg = dmg * (1.0 + 0.25 * dmg_mod)
                        ent.Scale = 1.0 + 0.125 * dmg_mod
                    end

                    ent.CollisionDamage = dmg
                    ent.HitPoints = dmg
                    ent.MaxHitPoints = dmg
                    ent.SpawnerEntity = player

                    ent:AddCharmed(EntityRef(player), 90)
                    data = GODMODE.get_ent_data(player)
                    data.spiders = data.spiders or {}
                    table.insert(data.spiders, ent)
                    ent:Update()
                end
            end
        end)
    end
end


return item