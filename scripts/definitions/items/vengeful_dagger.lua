local item = {}
item.instance = GODMODE.registry.items.vengeful_dagger
item.eid_description = "When used, launches a dagger in the direction you're firing, dealing 200% of your damage on hit.#If you leave and re-enter the room, each dagger deals 400% damage to the enemy it initially hit"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, launches a dagger in the direction that you are firing."},
		{str = "The dagger deals 200% damage to an enemy on contact. If you leave and re-enter a room (or take damage as T. Elohim), that enemy instantly takes 400% of your damage per dagger it was hit by."},
		{str = "Recharges over 4 seconds."},
	},
}

local knife_speed = 12
local swing_radius = 40
local br_swing_time = 80
local temp_hits = {}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_FAMILIARS then 
		player:CheckFamiliar(GODMODE.registry.entities.vengeful_dagger.variant, player:GetActiveCharge(ActiveSlot.SLOT_POCKET) == 80 and 1 or 0, player:GetCollectibleRNG(item.instance), Isaac.GetItemConfig():GetCollectible(item.instance), 3)
	end
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        local data = GODMODE.get_ent_data(player)
        local br_flag = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and data.vd_charge == br_swing_time

        local vel = (Vector(-1,0):Rotated(GODMODE.get_ent_data(player).last_fire * 90) + player:GetTearMovementInheritance(player.Velocity) * 0.06125):Resized(knife_speed)
        local dagger = Isaac.Spawn(GODMODE.registry.entities.vengeful_dagger.type,GODMODE.registry.entities.vengeful_dagger.variant,br_flag and 2 or 0,player.Position-vel:Resized(swing_radius),Vector.Zero,player)
        dagger:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        data.vd_charge = 0

        if br_flag then 
            dagger:GetSprite():Play("Swing",true)
            dagger.CollisionDamage = 2.3 + player.Damage / 4.0
            data.vd_charge = 0
        else
            dagger:GetSprite():Play("Dagger",true)
            dagger.CollisionDamage = player.Damage / 4.0
        end

        dagger.Velocity = vel
        dagger:Update()

        return {Discharge=true,Remove=false,ShowAnim=false}
    end
end

item.spawn_damage_dagger = function(self,player,ent,mod)
    local dagger = Isaac.Spawn(GODMODE.registry.entities.vengeful_dagger.type,GODMODE.registry.entities.vengeful_dagger.variant,1,ent.Position,Vector.Zero,player)
    dagger.CollisionDamage = player.Damage * 2 * (mod or 1)
    GODMODE.get_ent_data(dagger).target = ent
    dagger:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    dagger:GetSprite():Play("Hit",true)
    dagger:Update()
end

item.new_room = function(self)
    temp_hits = {}
    GODMODE.util.macro_on_players_that_have(item.instance,function(player) 
        local hits = GODMODE.save_manager.get_list_data("VDHits"..player.InitSeed,false,function(val) 
            local vec = GODMODE.util.string_split(val,"#")    
            return {pos=Vector(tonumber(vec[1]),tonumber(vec[2])),player=player} 
        end)

        for _,hit in ipairs(hits) do 
            table.insert(temp_hits,hit)
        end
    end)
end

item.room_rewards = function(self, rng, pos)
    GODMODE.util.macro_on_players_that_have(item.instance,function(player) 
        GODMODE.save_manager.clear_key("VDHits"..player.InitSeed)
    end)

    GODMODE.save_manager.clear_key("GodmodeRoom",true)
end

item.player_update = function(self, player, data)
    if data.last_fire == nil or player:GetFireDirection() ~= Direction.NO_DIRECTION then 
        data.last_fire = player:GetFireDirection()
    end
    if data.birthright == nil or player:IsFrame(30,1) then data.birthright = player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) end 

    if player:GetActiveCharge(ActiveSlot.SLOT_POCKET) == 80 then 
        if (data.cached_dagger or false) == false then 
            player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
            player:EvaluateItems()
            data.cached_dagger = true    
        end

        if data.birthright then 
            data.vd_charge = math.min(br_swing_time,(data.vd_charge or 0) + 1)
        end
    elseif (data.cached_dagger or true) == true then 
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
        player:EvaluateItems()
        data.cached_dagger = false
    end
end

item.pre_godmode_restart = function(self)
    temp_room_ents = GODMODE.room_ents
    GODMODE.save_manager.set_data("GodmodeRoom",GODMODE.level:GetCurrentRoomIndex(),true)
end

item.post_godmode_restart = function(self)
end

item.npc_init = function(self,npc)
    if GODMODE.level:GetCurrentRoomIndex() == tonumber(GODMODE.save_manager.get_data("GodmodeRoom","-1")) then 
        local new_temp = {}
        for ind,hit in ipairs(temp_hits) do 
            -- local ent = GODMODE.util.get_ent_by_seed(hit)
            local ent = nil 

            for _,ent2 in ipairs(Isaac.GetRoomEntities()) do 
                if (ent2.Position - hit.pos):Length() < 0.1 then 
                    ent = ent2 
                end
            end

            if ent ~= nil then 
                item.spawn_damage_dagger(self,hit.player,ent,2)
            else 
                table.insert(new_temp,hit)
            end 
        end

        temp_hits = new_temp
    end
end

item.render_player_ui = function(self,player)
    if player:HasCollectible(item.instance) then 
        local data = GODMODE.get_ent_data(player)
        if data.birthright == true then 
            if Input.IsActionPressed (ButtonAction.ACTION_MAP, player.ControllerIndex) or data and (data.vd_charge or br_swing_time) < br_swing_time then
                data.vd_display = math.min(50,(data.vd_display or 0) + 5)
            end
        
            if (data.vd_display or 0) > 0 then
                local opacity = math.min(1.0, data.vd_display / 50.0)
                local pos = Isaac.WorldToScreen(player.Position + Vector(24,-44))
        
                if GODMODE.sprites.vd_sprite == nil then
                    GODMODE.sprites.vd_sprite = Sprite()
                    GODMODE.sprites.vd_sprite:Load("gfx/ui/chargebar.anm2", true)
                end
        
                GODMODE.sprites.vd_sprite.Color = Color(1,1,1,opacity)
                GODMODE.sprites.vd_sprite:SetFrame("VDCharge", math.floor(data.vd_charge / br_swing_time * 100.0))
                GODMODE.sprites.vd_sprite:Render(pos,Vector.Zero,Vector.Zero)
                -- GODMODE.sprites.vd_sprite:SetFrame("Blessing",player.FrameCount % 6)
                -- GODMODE.sprites.vd_sprite:Render(pos,Vector.Zero,Vector.Zero)
                data.vd_display = data.vd_display - 1
            end        
        end
    end
end


item.bypass_hooks = {"npc_init"}

return item