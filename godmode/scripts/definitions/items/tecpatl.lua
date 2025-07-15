local item = {}
item.instance = GODMODE.registry.items.tecpatl
item.eid_description = "↑ Become invincible for 20 seconds # Shield persists between rooms#↓ +1 Broken Heart"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, creates a shield that grants invulnerability for 20 seconds."},
		{str = "The shield persists between rooms."},
	},
    { -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
      {str = "Without Repentogon, due to modding limitations, the shield granted does not prevent holy mantle from being depleted, but will prevent death."},
    },
}

item.player_update = function(self, player,data)
	if player:HasCollectible(item.instance) then
        local tecpatl_time = tonumber(GODMODE.save_manager.get_player_data(player,"TecpatlUseTime","0"))
        GODMODE.save_manager.set_player_data(player,"TecpatlUseTime",math.max(0,tecpatl_time - 1))

        if GODMODE.validate_rgon() and tecpatl_time > 0 then 
            player:SetDamageCountdown(tecpatl_time)
        end
    end
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
    if coll == item.instance then
        player:AddBrokenHearts(1)
        local data = GODMODE.get_ent_data(player)
        GODMODE.save_manager.set_player_data(player,"TecpatlUseTime",20*60 + 41)
        local shield = Isaac.Spawn(GODMODE.registry.entities.aztec_shield.type, GODMODE.registry.entities.aztec_shield.variant, GODMODE.registry.entities.aztec_shield.subtype, player.Position, Vector.Zero, player)
        shield.SpawnerEntity = player
        shield:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        shield:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
        shield:GetSprite():Play("Form", false)
        GODMODE.sfx:Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
        
        for i=0,8 do 
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, player.Position, player.Velocity * 2 + Vector(rng:RandomFloat()*4-2,rng:RandomFloat()*4-2),player)
        end

        if player:GetMaxHearts() == 0 then--and player:GetSoulHearts() + player:GetBlackHearts() + player:GetBoneHearts() == 0 then
            GODMODE.achievements.unlock_item(GODMODE.registry.items.impending_doom)
        end

        return true
    end
end

local hit_func = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit:ToPlayer() and enthit:ToPlayer():HasCollectible(item.instance) then
        local data = GODMODE.get_ent_data(enthit)
        local tecpatl_time = tonumber(GODMODE.save_manager.get_player_data(enthit:ToPlayer(),"TecpatlUseTime","0"))

        if tecpatl_time > 0 then
            return false
        end
    end
end

if GODMODE.validate_rgon() then 
    item.pre_player_hit = hit_func
else 
    item.npc_hit = hit_func
end

item.player_collide = function(self,player,ent2,entfirst,data)
    if player:ToPlayer() and player:ToPlayer():HasCollectible(item.instance) then
        local tecpatl_time = tonumber(GODMODE.save_manager.get_player_data(player,"TecpatlUseTime","0"))
        if tecpatl_time > 0 then
            return false
        end
    end
end

return item