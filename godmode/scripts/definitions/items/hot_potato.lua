local item = {}
item.instance = GODMODE.registry.items.hot_potato
item.eid_description = "3% chance to hurl a flaming potato instead of firing a tear#This potato deals high contact damage#On contact, the potato breaks into small chunks that auto target up to 4 nearby enemies#Max chance is 20% at 17 luck"
item.encyc_entry = {
	{ -- Effects
      {str = "Effects", fsize = 2, clr = 3, halign = 0},
      {str = "3% + 1% per luck chance to hurl a flaming potato instead of firing a tear. This potato deals (Damage * 1.5 + 5) contact damage and burns for 10% of this damage, and then the potato breaks into chunks. Each chunk deals 10% of the potato's damage, with each one targeting a nearby enemy within a large radius."},
      {str = "The maximum chance to hurl a flaming potato with 1 copy of this item is 20% at 17 luck. However, the maximum chance goes up by 20% per additional copy, at the cost of an additional 20 luck required for max chance. In example, 5 copies of Hot Potato! allows you to reach 100% chance at 97 luck."},
    },
}

local chunk_radius = 192
local vel_range = {0.5,1.1}

item.tear_fire = function(self, tear, data)
    local player = GODMODE.util.get_player_from_attack(EntityRef(tear))

    if player and player:HasCollectible(item.instance) then 
        local chance = math.min(math.max(0.03,0.03 + player.Luck * 0.01),0.20 * player:GetCollectibleNum(item.instance))

        if player:GetCollectibleRNG(item.instance):RandomFloat() <= chance then 
            data.hot_potato = true
            tear:ChangeVariant(GODMODE.registry.entities.hot_potato_tear.variant)
            tear.TearFlags = TearFlags.TEAR_NORMAL
            tear.CollisionDamage = player.Damage * 1.5 + 5
            tear.Parent = player
			local size = math.max(1,math.min(13, math.floor(tear.Scale*6)))
			tear:GetSprite():Play("RegularTear"..size,true)

            if tear.Scale > 1 then 
                tear.Scale = 1 + (tear.Scale - 1) * 0.25
            elseif tear.Scale < 0.5 then 
                tear.Scale = 0.5 + (tear.Scale)
            end

            tear.Scale = math.max(0.5,math.min(2,tear.Scale))
        end
    end
end

item.tear_collide = function(self, tear, ent2, entfirst)
    local player = GODMODE.util.get_player_from_attack(EntityRef(tear))

    if player and player:HasCollectible(item.instance) then 
        local data = GODMODE.get_ent_data(tear)
        if data.hot_potato then 
            ent2:AddBurn(EntityRef(tear),23,tear.CollisionDamage * 0.1)
        end
    end
end

local spawn_chunk = function(parent_tear,dmg,targ)
    local vel = ((targ and targ["pos"] ~= nil and targ.pos or targ.Position) - parent_tear.Position)
    local vel_scale = parent_tear:GetDropRNG():RandomFloat() * (vel_range[2] - vel_range[1]) + vel_range[1]

    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, GODMODE.registry.entities.hot_potato_tear_chunk.variant, 0, parent_tear.Position,
        vel:Resized(parent_tear.Velocity:Length() * vel_scale):Rotated(parent_tear:GetDropRNG():RandomFloat() * 30.0 - 15.0),
        (parent_tear.Parent or GODMODE.util.get_player_from_attack(EntityRef(parent_tear)) or parent_tear))
    tear = tear:ToTear()

    local data = GODMODE.get_ent_data(tear)
    tear.TearFlags = TearFlags.TEAR_NORMAL
    tear.CollisionDamage = dmg
    tear:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    tear:GetSprite():Play("Chunk"..(tear:GetDropRNG():RandomInt(2) + 1),true)
    tear.Parent = parent_tear.Parent
    data.hot_potato = true 
    data.chunk = true
end

item.npc_remove = function(self, tear)
    if tear:ToTear() then 
        tear = tear:ToTear()
        local data = GODMODE.get_ent_data(tear)

        if data.hot_potato then 
            local fx = Isaac.Spawn(EntityType.ENTITY_EFFECT,EffectVariant.FIRE_JET,0,tear.Position,Vector.Zero,tear.Parent)
            fx = fx:ToEffect()
            fx:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            fx.DepthOffset = 60
            fx:GetSprite().Scale = Vector(1,1) * tear.Scale * (data.chunk and 0.5 or 1)
            fx.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
            fx.CollisionDamage = 0
    
            if not data.chunk then 
                local ents = Isaac.FindInRadius(tear.Position,chunk_radius,EntityPartition.ENEMY)
                local pick_rand_targ = function()
                    return {pos=tear.Position + Vector(chunk_radius,chunk_radius):Rotated(tear:GetDropRNG():RandomFloat() * 360.0):Resized(tear:GetDropRNG():RandomFloat() * chunk_radius * 0.9 + chunk_radius * 0.1)}
                end
    
                for i=0,3 do 
                    local ent = (#ents > 0 and i <= #ents and ents[i] or #ents > 0 and tear:GetDropRNG():RandomFloat() < 0.5 and ents[i % #ents]) or nil
                    if ent then 
                        spawn_chunk(tear,tear.CollisionDamage*0.1,ent)
                    else 
                        spawn_chunk(tear,tear.CollisionDamage*0.1,pick_rand_targ())
                    end
                end    
            end
        end
    end
end

item.tear_update = function(self, tear, data)
    local player = GODMODE.util.get_player_from_attack(EntityRef(tear))

    if player and player:HasCollectible(item.instance) and data.hot_potato then 
        if tear.Height < -10 then 
            local additive = math.min(math.max(0,math.cos(math.rad(tear.FrameCount / 20.0 * 180)) * -20),tear.FrameCount * 2-20)
            tear.Height = math.min(-5,tear.Height + additive)
        else 
            tear:Remove()
        end

        tear.SpriteRotation = tear.FrameCount * 25
    end
end

return item