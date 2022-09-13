local item = {}
item.instance = Isaac.GetItemIdByName( "Taenia" )
item.eid_description = "↑ +10 Range#↑ +0.5 Tears#↓ -0.25 Shot speed#↑ Create a path for your tears by firing in certain directions"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "Grants +10 range, +0.5 tears and -0.25 shot speed on pickup."},
      {str = "By holding down different fire directions consecutively, all tears will follow a certain path based on the order of directions you fired in. This allows for some strategic manuevering around corners."},
      {str = "Alternatively, when the first fire button is pressed, all tears on the screen will alter their course to match the player's new fire direction."},
    },
}


item.eval_cache = function(self, player,cache)
    if not player:HasCollectible(item.instance) then return end


	if cache == CacheFlag.CACHE_FIREDELAY then
	    player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.45*player:GetCollectibleNum(item.instance))
	end

	if cache == CacheFlag.CACHE_RANGE then
		player.TearRange = player.TearRange + 5
	end

	if cache == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed - 0.25
	end
end

item.player_update = function(self,player)
	if player:HasCollectible(item.instance) then
        local data = GODMODE.get_ent_data(player)
		if data.brain_tears == nil then data.brain_tears = {dirs = {}} end
        
		if player.FireDelay == player.MaxFireDelay - 5 or player.FireDelay <= 1 then
            if data.brain_tears.dirs == nil then
                data.brain_tears.dirs = {}
            end
            local e = Isaac.GetRoomEntities()
            data.brain_tears.tears = {}
            local dir = player:GetFireDirection() * 90 - 180
            local vel = Vector(math.cos(math.rad(dir)),math.sin(math.rad(dir)))
            table.insert(data.brain_tears.dirs, vel)
            for i=1,#e do
                if e[i]:ToTear() and e[i]:ToTear().Parent and GetPtrHash(e[i]:ToTear().Parent) == GetPtrHash(player) then
                    local t = e[i]:ToTear()
                    table.insert(data.brain_tears.tears, e[i]:ToTear())
                end
            end
        end

        if player:GetFireDirection() == Direction.NO_DIRECTION then
            data.brain_tears.dirs = {}
        end

        if data.brain_tears.tears ~= nil then
            for i=1, #data.brain_tears.tears do
                local t = data.brain_tears.tears[i]
                local index = math.floor(t.FrameCount / 5)
                index = math.max(1,index)
                index = math.min(index, #data.brain_tears.dirs)
                t.FallingSpeed = 0.1

                if data.brain_tears.dirs[index] ~= nil then
                    t.Velocity = data.brain_tears.dirs[index] * player.ShotSpeed * 10
                end
            end
        end
	end
end

return item