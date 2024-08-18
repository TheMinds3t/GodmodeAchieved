local monster = {}
monster.name = "Observatory FX"
monster.type = GODMODE.registry.entities.observatory_fx.type
monster.variant = GODMODE.registry.entities.observatory_fx.variant

local base_depth_off = -200
local depth_offsets = {
    [0] = 0, --platform 
    [1] = -10, --moon
    [2] = -20,
    [3] = -5,
    [4] = -7,
    [5] = -15,
    [6] = -3,
    [7] = -50, --background
    [8] = 150, --door
    [9] = -49, --background cloud
}

local anim_names = {
    [0] = "Platform",
    [1] = "Moon",
    [2] = "Stars1",
    [3] = "Stars2",
    [4] = "Stars3",
    [5] = "Stars4",
    [6] = "Stars5",
    [7] = "Background",
    [8] = "Opened", -- door
    [9] = "Stars6",
}

local moon_dist_scale = 120
local moon_time_scale = 1/60.0
local moon_size_dif = 0.33

local star_radius = 20 
local star_base_speed = 10 
local star_layer_mod = 5

local star_rotate_off_max = 5
local star_main_angle = 30
local star_side_angle = 90

monster.npc_update = function(self, ent, data, sprite)
    if not (ent.Type == monster.type and ent.Variant == monster.variant) then return end	

    ent.SplatColor = Color(0,0,0,0,255,255,255)
    ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE

    if ent:HasEntityFlags(EntityFlag.FLAG_APPEAR) then
        ent:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        if not ent:HasEntityFlags(GODMODE.util.get_pseudo_fx_flags()) then 
            ent:AddEntityFlags(GODMODE.util.get_pseudo_fx_flags())
        end
        
        sprite:Play(anim_names[ent.SubType],true)
    end

    ent.DepthOffset = base_depth_off + (depth_offsets[ent.SubType] or 0)

    ent.Velocity = Vector(0,0)

    if ent.SubType ~= 8 then 
        ent.Position = GODMODE.room:GetCenterPos()
    elseif not GODMODE.is_in_observatory() then 
        ent.DepthOffset = 200
    end

    if ent.SubType == 7 or ent.SubType == 9 then 
        sprite.PlaybackSpeed = 0.5
    end

    if ent.SubType > 1 and ent.SubType < 7 then 
        local frame = ent.FrameCount
        local rot_off = ent.FrameCount * (0.1 + ent.SubType / 24)
        local rotation = star_main_angle

        if ent.SubType >= 5 then 
            rotation = star_side_angle
        end

        ent.SpriteOffset = Vector(star_rotate_off_max,0):Rotated(rotation + rot_off):Resized(star_radius)
        ent.SpriteRotation = rotation + rot_off
    end

    if ent.SubType == 1 then --moon animation
        local offx = math.cos(math.rad(ent.FrameCount*6*moon_time_scale))*moon_dist_scale
        local offy = math.sin(math.rad(ent.FrameCount*4*moon_time_scale))*moon_dist_scale
        ent.SpriteOffset = Vector(offx, offy)

        local dist = math.min(1.0,(GODMODE.room:GetCenterPos() - (ent.Position + ent.SpriteOffset)):Length() / moon_dist_scale)
        local scale = 1 - dist*moon_size_dif
        ent.Scale = scale
        -- GODMODE.log("ent.scale = "..ent.Scale,true)
    end
end

return monster