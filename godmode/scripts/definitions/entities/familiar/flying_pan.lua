local monster = {}
monster.name = "[GODMODE] Flying Pan"
monster.type = GODMODE.registry.entities.flying_pan.type
monster.variant = GODMODE.registry.entities.flying_pan.variant

local num_frames_behind = 50
local falling_speed = 12
local flying_speed = 3
local flying_dampen = 20 

local max_height = 512
local max_slide_speed = 4
local max_fly_speed = 5

monster.familiar_init = function(self, fam)
    if fam.Type == monster.type and fam.Variant == monster.variant then
        fam:AddToDelayed()
    end
end

monster.familiar_update = function(self, fam, data, sprite)
    local player = fam.Player
    local land_state = GODMODE.save_manager.get_player_data(player,"FlyingPanLand","0")
    local flying = GODMODE.save_manager.get_player_data(player,"FlyingPanThrown","false")
    local targ = (player.Position - fam.Position)

    data.fly_pos = data.fly_pos or 10

    if land_state ~= "0" then 
        data.fall_time = (data.fall_time or 0) + 1
        data.fly_pos = math.max(0,data.fly_pos * (0.95 - (data.fall_time * 0.01)) - falling_speed)
        if data.fly_pos <= 0 then 
            if land_state == "1" then 
                sprite.PlaybackSpeed = 0
                sprite:Play("Land",false)
                GODMODE.game:ShakeScreen(10 + (GODMODE.april_fools == true and 60 or 0))
                GODMODE.game:BombExplosionEffects(fam.Position, 40 + (GODMODE.april_fools == true and 60 or 0), player:GetBombFlags(), Color.Default, (GODMODE.april_fools == false and player or nil))
                local shock = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SHOCKWAVE, 0, fam.Position, Vector.Zero, player)
                shock = shock:ToEffect()
                shock.Timeout = 20 + (GODMODE.april_fools == true and 20 or 0)
                shock.MinRadius = 16 + (GODMODE.april_fools == true and 4 or 0)
                shock.MaxRadius = shock.MinRadius * (5.5 + (GODMODE.april_fools == true and 5.5 or 0))
                shock.CollisionDamage = 10 + (GODMODE.april_fools == true and 10 or 0)
                shock.Parent = player
                GODMODE.save_manager.set_player_data(player, "FlyingPanLand", "2")
                data.stunned = 60
                fam.Velocity = Vector.Zero
            elseif land_state == "2" then
                fam.Velocity = Vector.Zero
                targ = Vector.Zero
            end
        else 
            sprite.PlaybackSpeed = 1
            sprite:Play("Falling",false)
        end
    elseif flying == "true" then 
        data.fly_time = (data.fly_time or 0) + 1
        sprite.PlaybackSpeed = 1
        sprite:Play("Flying",false)
        data.fly_pos = math.min(max_height, data.fly_pos * (0.9 + data.fly_time * 0.01) + flying_speed)
    end

    targ = targ:Resized(math.min(targ:Length() / 26.0, max_fly_speed))
    fam.Velocity = (fam.Velocity * (flying_dampen - 1) + targ) / flying_dampen
    fam.SpriteOffset = Vector(0,-data.fly_pos)
end

monster.player_collide = function(self, player, fam, ent_first)
    if fam.Type == monster.type and fam.Variant == monster.variant then 
        local land_state = GODMODE.save_manager.get_player_data(player, "FlyingPanLand", "0")

        if land_state == "2" then -- if the pan is on the ground and the player touches it, retrieve it! 
            local coll = player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)

            if coll ~= 0 then 
                player:RemoveCollectible(coll, true)
                coll = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, coll, fam.Position, Vector.Zero, player)
                coll = coll:ToPickup()
                coll.Touched = true
            end

            player:AnimateCollectible(GODMODE.registry.items.flying_pan)
            player:QueueItem(Isaac.GetItemConfig():GetCollectible(GODMODE.registry.items.flying_pan), 0, true, false)
            GODMODE.save_manager.set_player_data(player, "FlyingPanThrown", "false")
            GODMODE.save_manager.set_player_data(player, "FlyingPanLand", "0")
            GODMODE.save_manager.set_player_data(player, "FlyingPanChance", "0", true)
            player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
            player:EvaluateItems()
        end
    end
end

return monster