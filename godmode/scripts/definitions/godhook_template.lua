local item = {}
-- -- use for collectibles
-- item.instance = GODMODE.registry.items.vengeful_dagger
-- -- in addition to instance, use "is_trinket" for trinket identification too
-- -- item.trinket = true 
-- auto-add an EID description and encyclopedia entry if you want them to show up
-- item.eid_description = "When used, launches a dagger in the direction you're firing, dealing 200% of your damage on hit.#If you leave and re-enter the room, each dagger deals 400% damage to the enemy it initially hit"
-- item.encyc_entry = {
-- 	{ -- Effects
-- 		{str = "Effects", fsize = 2, clr = 3, halign = 0},
-- 		{str = "When used, launches a dagger in the direction that you are firing."},
-- 		{str = "The dagger deals 200% damage to an enemy on contact. If you leave and re-enter a room (or take damage as T. Elohim), that enemy instantly takes 400% of your damage per dagger it was hit by."},
-- 		{str = "Recharges over 4 seconds."},
-- 	},
-- }

-- -- use for entity files 
-- monster.name = "[GODMODE] Bomb Barrel" -- name of entity
-- monster.type = Isaac.GetEntityTypeByName(monster.name) -- entity id 
-- monster.variant = Isaac.GetEntityVariantByName(monster.name) -- entity variant 

-- data is usually referring to the player or entity's godmode data 

-- for a full list of implemented callbacks, see GODMODE.godhooks.hook_list

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_FAMILIARS then 
		player:CheckFamiliar(GODMODE.registry.entities.vengeful_dagger.variant, player:GetActiveCharge(ActiveSlot.SLOT_POCKET) == 80 and 1 or 0, player:GetCollectibleRNG(item.instance), Isaac.GetItemConfig():GetCollectible(item.instance), 3)
	end
end

-- item.use_item = function(self, coll,rng,player,flags,slot,var_data)
-- 	if coll == item.instance then
--         local data = GODMODE.get_ent_data(player)
--         local br_flag = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and data.vd_charge == br_swing_time

--         local vel = (Vector(-1,0):Rotated(GODMODE.get_ent_data(player).last_fire * 90) + player:GetTearMovementInheritance(player.Velocity) * 0.06125):Resized(knife_speed)
--         local dagger = Isaac.Spawn(GODMODE.registry.entities.vengeful_dagger.type,GODMODE.registry.entities.vengeful_dagger.variant,br_flag and 2 or 0,player.Position-vel:Resized(swing_radius),Vector.Zero,player)
--         dagger:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
--         data.vd_charge = 0

--         if br_flag then 
--             dagger:GetSprite():Play("Swing",true)
--             dagger.CollisionDamage = 2.3 + player.Damage / 4.0
--             data.vd_charge = 0
--         else
--             dagger:GetSprite():Play("Dagger",true)
--             dagger.CollisionDamage = player.Damage / 4.0
--         end

--         dagger.Velocity = vel
--         dagger:Update()

--         return {Discharge=true,Remove=false,ShowAnim=false}
--     end
-- end

-- item.new_room = function(self)
--     temp_hits = {}
--     GODMODE.util.macro_on_players_that_have(item.instance,function(player) 
--         local hits = GODMODE.save_manager.get_list_data("VDHits"..player.InitSeed,false,function(val) 
--             local vec = GODMODE.util.string_split(val,"#")    
--             return {pos=Vector(tonumber(vec[1]),tonumber(vec[2])),player=player} 
--         end)

--         for _,hit in ipairs(hits) do 
--             table.insert(temp_hits,hit)
--         end
--     end)
-- end

-- item.room_rewards = function(self, rng, pos)
--     GODMODE.util.macro_on_players_that_have(item.instance,function(player) 
--         GODMODE.save_manager.clear_key("VDHits"..player.InitSeed)
--     end)

--     GODMODE.save_manager.clear_key("GodmodeRoom",true)
-- end

-- item.player_update = function(self, player, data, sprite)
-- end

-- item.npc_init = function(self,npc)
--     if GODMODE.level:GetCurrentRoomIndex() == tonumber(GODMODE.save_manager.get_data("GodmodeRoom","-1")) then 
--         local new_temp = {}
--         for ind,hit in ipairs(temp_hits) do 
--             -- local ent = GODMODE.util.get_ent_by_seed(hit)
--             local ent = nil 

--             for _,ent2 in ipairs(Isaac.GetRoomEntities()) do 
--                 if (ent2.Position - hit.pos):Length() < 0.1 then 
--                     ent = ent2 
--                 end
--             end

--             if ent ~= nil then 
--                 item.spawn_damage_dagger(self,hit.player,ent,2)
--             else 
--                 table.insert(new_temp,hit)
--             end 
--         end

--         temp_hits = new_temp
--     end
-- end

-- item.render_player_ui = function(self,player)
-- end


return item