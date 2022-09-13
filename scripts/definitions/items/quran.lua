local item = {}
item.instance = Isaac.GetItemIdByName( "Qur'an" )
item.eid_description = "↓ Removes all black hearts ↑ +1.5 Soul heart per black heart removed # Instantly kills Mom and Mom's Heart# Kills you when used against Satan"
item.eid_transforms = GODMODE.util.eid_transforms.BOOKWORM

item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When used, all black hearts are removed from the player. For each black heart removed, grants 1.5x the amount of soul hearts."},
        {str = "This item instantly kills mom and mom's heart, and will kill you if used against satan."}
	},
}

item.use_item = function(self, coll,rng,player,flags,slot,var_data)
	if coll == item.instance then
        local black = 0
        for i = 1, 24 do
            if player:IsBlackHeart(i) then
                player:RemoveBlackHeart(i)
                black = black + 1
            end
        end

        player:AddSoulHearts(math.ceil(black*0.5+1))

        local saved_hearts = tonumber(GODMODE.save_manager.get_persistant_data("QuranHearts","0",true))
        GODMODE.save_manager.set_persistant_data("QuranHearts", saved_hearts + math.ceil(black*0.5+1))

        if saved_hearts + math.ceil(black*0.5+1) > 12 then
            GODMODE.achievements.unlock_item(Isaac.GetItemIdByName("Prayer Mat"))
        end

        SFXManager():Play(SoundEffect.SOUND_HOLY,1,2,false,0.75)
        SFXManager():Play(SoundEffect.SOUND_SUPERHOLY,1,2,false,0.5)

        GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_MOM,-1,-1, function(ent) ent:Die() end)
        GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_MOMS_HEART,-1,-1, function(ent) ent:Die() end)
        GODMODE.util.macro_on_enemies(nil,EntityType.ENTITY_SATAN,-1,-1, function(ent) player:Die() end)

        return true
    end
end

return item