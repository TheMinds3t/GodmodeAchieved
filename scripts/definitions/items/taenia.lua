local item = {}
item.instance = GODMODE.registry.items.taenia
item.eid_description = "↑ +5 Range#↑ +0.5 Tears#↓ -0.25 Shot speed#↑ Create a path for your tears by firing in certain directions"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "Grants +5 range, +0.5 tears and -0.25 shot speed on pickup."},
      {str = "By holding down different fire directions consecutively, all tears will follow a certain path based on the order of directions you fired in. This allows for some strategic manuevering around corners."},
    },
}


item.eval_cache = function(self, player,cache,data)
    if not player:HasCollectible(item.instance) then return end

	if cache == CacheFlag.CACHE_FIREDELAY then
	    player.MaxFireDelay = GODMODE.util.add_tears(player, player.MaxFireDelay,0.5*player:GetCollectibleNum(item.instance))
	end

	if cache == CacheFlag.CACHE_RANGE then
		player.TearRange = player.TearRange + GODMODE.util.grid_size * 5
	end

	if cache == CacheFlag.CACHE_SHOTSPEED then
		player.ShotSpeed = player.ShotSpeed - 0.25
	end
end

local function action_to_direction(action)
    local mirror_flag = GODMODE.util.is_mirror()
    if action == ButtonAction.ACTION_SHOOTLEFT then 
        return mirror_flag and Direction.RIGHT or Direction.LEFT
    elseif action == ButtonAction.ACTION_SHOOTRIGHT then 
        return mirror_flag and Direction.LEFT or Direction.RIGHT
    elseif action == ButtonAction.ACTION_SHOOTDOWN then 
        return Direction.DOWN
    elseif action == ButtonAction.ACTION_SHOOTUP then 
        return Direction.UP
    end

    return nil
end

item.player_update = function(self,player,data)
	if player:HasCollectible(item.instance) then
		if data.brain_tears == nil then data.brain_tears = {dirs = {}} end

        if GODMODE.util.is_action_group_pressed(GODMODE.util.action_groups.attack, player.ControllerIndex, false) ~= false then 
            data.brain_time = (data.brain_time or -1) + 1
            local newest = GODMODE.util.is_action_group_pressed(GODMODE.util.action_groups.attack, player.ControllerIndex, true)
            if newest ~= false then 
                data.brain_newest = newest
            end

            data.brain_tears.dirs[data.brain_time] = action_to_direction(data.brain_newest or newest)
        else 
            data.brain_time = nil
            data.brain_tears.dirs = {}
        end
        
        if player:GetFireDirection() == Direction.NO_DIRECTION then
        end
	end
end

item.tear_update = function(self, tear)
    local player = GODMODE.util.get_player_from_attack(EntityRef(tear))

    if player and player:HasCollectible(item.instance) then 
        local data = GODMODE.get_ent_data(player)

        if data and data.brain_tears and #data.brain_tears.dirs >= tear.FrameCount and GODMODE.room:IsPositionInRoom(tear.Position,0.0) then 
            local index = math.max(1,tear.FrameCount-1)
            GODMODE.get_ent_data(tear).old_dir = new_packet or -1
            local new_packet = data.brain_tears.dirs[index]

            if new_packet ~= nil then 
                local dir = Vector(-1,0):Rotated(data.brain_tears.dirs[index]*90)
                tear.Velocity = dir * player.ShotSpeed * 10
                tear.ContinueVelocity = dir * player.ShotSpeed * 10
            else 
            end

            tear.FallingSpeed = 0.1
        end
    end
end

item.new_room = function(self)
    GODMODE.util.macro_on_players_that_have(item.instance,function(player)
        GODMODE.get_ent_data(player).brain_tears = {dirs={}}
    end)
end

return item