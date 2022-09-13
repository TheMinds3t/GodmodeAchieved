local item = {}
item.instance = Isaac.GetItemIdByName( "Portable Confessional" )
item.eid_description = "↑ When entering an angel room, receives full charge#↑ If in an angel room with broken hearts, removes 3 broken hearts and destroys the item#↑ If not in angel room or no broken hearts, spawns a soul heart#↓ Take 1 red heart damage on use"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, removes half a heart from the player to spawn a soul heart on the ground."},
		{str = "When entering a new angel room, this item receives full charge."},
        {str = "If the player has any broken hearts and the item is used in an angel room, the item is removed and the player will lose up to 3 broken hearts."}
	},
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
    if coll == item.instance then
        local dmg = 1 
        if player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) then dmg = 2 end
        player:TakeDamage(dmg, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG, EntityRef(player), 1)

        if Game():GetRoom():GetType() == RoomType.ROOM_ANGEL and player:GetBrokenHearts() > 0 then 
            player:AddBrokenHearts(-3)
            Game():BombExplosionEffects(player.Position,3.0)
            Game():ShakeScreen(30)
            SFXManager():Play(SoundEffect.SOUND_HOLY,1,2,false,0.75)
            player:RemoveCollectible(item.instance)
        else
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, Game():GetRoom():FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)
        end

        return true
    end
end

item.new_room = function(self) 
    if Game():GetRoom():GetType() == RoomType.ROOM_ANGEL then 
        GODMODE.util.macro_on_players_that_have(item.instance, function(player) 
            player:SetActiveCharge(6, GODMODE.util.get_active_slot(player, item.instance))
            Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.BATTERY,0,player.Position-Vector(0,32),Vector.Zero,player)
            SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE)
        end)
    end
end

return item