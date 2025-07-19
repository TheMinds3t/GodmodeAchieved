local item = {}
item.instance = GODMODE.registry.items.door_rift
item.eid_description = "#↑ +0.05 Speed#All doors have an ocular rift when you enter a room"
item.encyc_entry = {
	{ -- Effects
		{str = "Effects", fsize = 2, clr = 3, halign = 0},
		{str = "Every door spot in a room layout will have an ocular rift spawn in front of it when you enter a room for the first time."},
		{str = "The rift deals 1 contact damage per tick."},
		{str = "Stacking this item will spawn another rift after the previous rift is finished, deployed at an increasing interval per stack to keep it active longer"},
	},
}

local rift_time = 80
local base_rift_deploy_time = 10
local rift_spacing_time = 20

item.eval_cache = function(self, player,cache,data)
    local num = math.max(0,player:GetCollectibleNum(item.instance) + player:GetEffects():GetCollectibleEffectNum(item.instance))

    if cache == CacheFlag.CACHE_SPEED then
        player.MoveSpeed = player.MoveSpeed + 0.05 * num
    end
end

item.new_room = function(self)
	local amt = GODMODE.util.total_item_count(item.instance)

	if amt > 0 and GODMODE.room:IsFirstVisit() and not GODMODE.room:IsClear() then 
		for x=1,amt do 
			local delay = base_rift_deploy_time  + (x - 1) * (rift_time + rift_spacing_time)

			for doorslot=0,DoorSlot.NUM_DOOR_SLOTS do 
				if GODMODE.room:IsDoorSlotAllowed(doorslot) then 
					local seed = GODMODE.room:GetDecorationSeed()

					GODMODE.util.schedule_function(function()
						if GODMODE.room:GetDecorationSeed() == seed then 
							local rift = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.RIFT,0,GODMODE.room:GetDoorSlotPosition(doorslot),Vector.Zero,nil)
							rift = rift:ToEffect()
							rift.Timeout = rift_time
							rift.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
							rift.CollisionDamage = 1
							rift.MinRadius = 256
							rift.MaxRadius = 256
						end
					end, delay)
				end
			end
		end
	end
end


return item