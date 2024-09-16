local item = {}
item.instance = GODMODE.registry.items.prayer_mat
item.eid_description = "Gain half a soul heart the first time you stand still for 10 seconds in an uncleared room"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "When in a room with hostile enemies, standing still for 5 seconds grants the player half a soul heart as well as spawns a crack the sky beam on top of the player dealing damage to nearby enemies."},
        {str = "This effect can only be used once per room."}
	},
}

item.player_update = function(self, player,data)
	if player:HasCollectible(item.instance) then
        local diff = player:GetCollectibleNum(item.instance)
        local prayer_used = GODMODE.save_manager.get_player_data(player,"PrayerUsed","false")

        if (player.Velocity:Length() > 0.2 or prayer_used == "true" or GODMODE.room:IsClear()) and data.finish_anim ~= true then
            diff = -1
            data.prayer_mat = math.min(data.prayer_mat or 0,5)
        end

        data.prayer_mat = math.max(0, (data.prayer_mat or 0) + diff)

        if data.prayer_glow == nil then
            data.prayer_glow = Sprite()
            data.prayer_glow:Load("gfx/effect_prayer_glow.anm2", true)
            data.prayer_glow.PlaybackSpeed = 0
        end

        if data.prayer_glow and (data.prayer_mat or 0) == 3*30 then
            data.finish_anim = nil
        end

        if data.prayer_glow:IsEventTriggered("Success") and prayer_used ~= "true" and diff > 0 then
            GODMODE.save_manager.set_player_data(player,"PrayerUsed","true",true)
            data.finish_anim = true
            player:AddSoulHearts(1)
            GODMODE.sfx:Play(SoundEffect.SOUND_HOLY,1,2,false,1)
            player:AnimateHappy()
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY,0,player.Position,Vector.Zero,player)
        end
    end
end

item.room_rewards = function(self,rng,pos)
    GODMODE.util.macro_on_players_that_have(item.instance,function(player) 
        GODMODE.save_manager.set_player_data(player,"PrayerUsed","true",true)
        GODMODE.get_ent_data(player).prayer_mat = 0
    end)
end

item.new_room = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance,function(player) 
        GODMODE.save_manager.set_player_data(player,"PrayerUsed","false",true)
        GODMODE.get_ent_data(player).prayer_mat = 0
    end)
end

item.player_render = function(self,player,offset)
    if player:HasCollectible(item.instance) then
        local data = GODMODE.get_ent_data(player)
        if data.prayer_glow == nil then
            data.prayer_glow = Sprite()
            data.prayer_glow:Load("gfx/effect_prayer_glow.anm2", true)
            data.prayer_glow.PlaybackSpeed = 0
        end

        data.prayer_glow:SetFrame("Glow", math.floor((data.prayer_mat or 0)*(10/3)))
        data.prayer_glow:Render(Isaac.WorldToScreen(player.Position-Vector(0,16)),Vector.Zero,Vector.Zero)
    end
end

return item