local item = {}
item.instance = GODMODE.registry.items.odd_dice
item.eid_description = "Rerolls items in the room#33% chance to hide a rerolled item#+10% chance after each use to break into 2 dice shards"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "When used, rerolls items within the room."},
      {str = "- 33% chance to hide a rerolled item. This DOES mean that using the item again may show that item and hide another."},
      {str = "- +10% chance to break into 2 dice shards after each use. This will never break on the first use, but if you find a second Odd Dice it may break on the first use. This only safeguards the first use of any Odd Dice."},
    },
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, false, true, true, false)

        GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE,-1,function(item)
            if item:GetDropRNG():RandomFloat() <= 0.33 then 
                if GODMODE.validate_rgon() then 
                    item:ToPickup():SetForceBlind(true)
                else 
                    item:GetSprite():ReplaceSpritesheet(1,"gfx/items/collectibles/questionmark.png")
                    item:GetSprite():LoadGraphics()    
                end
            end
        end)

        local uses = tonumber(GODMODE.save_manager.get_player_data(player,"OddDiceUsed","0"))

        -- 0,   1,   2,   3,   4,   5
        -- 0, 0.1, 0.2, 0.3, 0.8, 1.0
        if rng:RandomFloat() <= 0.1*uses*math.max(1,uses-3) then 
            GODMODE.sfx:Play(SoundEffect.SOUND_BLACK_POOF,1.2 * Options.SFXVolume)
            GODMODE.sfx:Play(SoundEffect.SOUND_POT_BREAK_2,1.2 * Options.SFXVolume,2,false,0.725+rng:RandomFloat()*0.05)
            GODMODE.game:ShakeScreen(10)

            for i=1,2 do 
                local shard = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TAROTCARD,Card.CARD_DICE_SHARD,player.Position,RandomVector():Rotated(rng:RandomInt(360)):Resized(rng:RandomFloat()*1.2+0.9),player)
                shard:SetColor(Color(0.4,0.8,1,1,0.0,0,0.0),9999,1,false,false)

                if i % 2 == 1 then 
                    shard.FlipX = not shard.FlipX
                end
            end

            return {Discharge=true,Remove=true,ShowAnim=false}
        end

        GODMODE.save_manager.set_player_data(player,"OddDiceUsed",uses + 1,true)

        return true
    end
end

return item