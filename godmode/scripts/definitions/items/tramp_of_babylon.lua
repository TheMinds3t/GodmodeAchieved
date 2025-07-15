local item = {}
item.instance = GODMODE.registry.items.tramp_of_babylon
item.eid_description = "↑ More damage the deeper you go #↓ When damaged for the first time in a room, all monsters are split in two and bosses regain 50% missing health"
item.eid_transforms = GODMODE.util.eid_transforms.LEVIATHAN
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "Grants a damage modifier equal to the current hardmode health scaling setting, or "},
      {str = "When the player holding this takes damage for the first time in a room, all enemies are split into two and all bosses gain half their missing health."},
    },
}

item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

    if cache == CacheFlag.CACHE_DAMAGE then
        -- local max_stage = 12
        -- local scale = tonumber(GODMODE.save_manager.get_config("HMEScale","2.0")) * 0.5
        -- local percent = (GODMODE.level:GetAbsoluteStage()-1) / math.max(1,max_stage-1) * math.max(1.0,scale-1.0)

        -- if GODMODE.game.Difficulty > 1 then 
        --     max_stage = 7 
        --     scale = tonumber(GODMODE.save_manager.get_config("GMEScale","1.5")) * 0.5
        --     percent = (GODMODE.level:GetStage()-1) / math.max(1,max_stage-1) * math.max(1.0,scale-1.0)
        -- end
        
        player.Damage = player.Damage * GODMODE.util.get_health_scale()
    end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
	if enthit.Type == EntityType.ENTITY_PLAYER and enthit:ToPlayer():HasCollectible(item.instance) and not GODMODE.get_ent_data(enthit).t_o_b_triggered then
		local entities = Isaac.GetRoomEntities( )
        for i = 1, #entities do
            local ent = entities[i]
            if ent:IsVulnerableEnemy() then
                if ent:IsBoss() then
                    ent.HitPoints = ent.HitPoints + (ent.MaxHitPoints - ent.HitPoints) / 2
                elseif not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) then
                    local ent2 = GODMODE.game:Spawn(ent.Type,ent.Variant,ent.Position,ent.Velocity,ent, ent.SubType, ent.InitSeed)
                    ent2.HitPoints = ent.HitPoints / 2
                    ent.HitPoints = ent.HitPoints / 2
                end
            end
        end
        GODMODE.get_ent_data(enthit).t_o_b_triggered = true
	end
end

item.new_room = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance, function(player)
        GODMODE.get_ent_data(player).t_o_b_triggered = false
    end)
end

return item