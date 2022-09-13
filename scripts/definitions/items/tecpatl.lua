local item = {}
item.instance = Isaac.GetItemIdByName( "Tecpatl" )
item.eid_description = "↑ Become invincible for 20 seconds # Shield persists between rooms#↓ +1 Broken Heart"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, creates a shield that grants invulnerability for 20 seconds."},
		{str = "The shield persists between rooms."},
	},
    { -- Notes
      {str = "Notes", fsize = 2, clr = 3, halign = 0},
      {str = "Due to modding limitations, the shield granted does not prevent holy mantle from being depleted, but will prevent death."},
    },
}

item.player_update = function(self, player)
	if player:HasCollectible(item.instance) then
        local data = GODMODE.get_ent_data(player)
        data.tecpatl = math.max(0, (data.tecpatl or 0) - 1)
    end
end

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
    if coll == item.instance then
        player:AddBrokenHearts(1)
        local data = GODMODE.get_ent_data(player)
        data.tecpatl = 20 * 60 + 41
        local shield = Isaac.Spawn(Isaac.GetEntityTypeByName("Aztec Shield"), Isaac.GetEntityVariantByName("Aztec Shield"), 1, player.Position, Vector.Zero, player)
        shield:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        shield:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
        shield:GetSprite():Play("Form", false)
        SFXManager():Play(SoundEffect.SOUND_DEATH_BURST_LARGE)
        
        for i=0,8 do 
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, player.Position, player.Velocity * 2 + Vector(rng:RandomFloat()*4-2,rng:RandomFloat()*4-2),player)
        end

        if player:GetMaxHearts() == 0 and player:GetSoulHearts() + player:GetBlackHearts() + player:GetBoneHearts() == 0 then
            GODMODE.achievements.unlock_item(Isaac.GetItemIdByName("Impending Doom"))
        end

        return true
    end
end

item.npc_hit = function(self,enthit,amount,flags,entsrc,countdown)
    if enthit:ToPlayer() and enthit:ToPlayer():HasCollectible(item.instance) then
        local data = GODMODE.get_ent_data(enthit)

        if (data.tecpatl or 0) > 0 then
            return false
        end
    end
end

return item