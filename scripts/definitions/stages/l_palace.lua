local stage = {}
local stage_prefix = "luc/"

stage.api_id = "IvoryPalace"
stage.display_name = "Ivory Palace"
stage.simulating_stage = LevelStage.STAGE6

local default_graphics = {
    rocks = "gfx/grid/"..stage_prefix.."rocks.png",
    pits = "gfx/grid/"..stage_prefix.."pits.png",
    alt_pits = "gfx/grid/"..stage_prefix.."pits.png",
    bridge = "gfx/grid/"..stage_prefix.."bridge.png",
    shading = "gfx/backdrop/luc/shading/shading",
    player_spot = "gfx/ui/stage/"..stage_prefix.."boss_spot.png",
    boss_spot = "gfx/ui/stage/"..stage_prefix.."player_spot.png",

    backdrop_gfx = {
        Walls = {"1","2","3"},
        NFloors = {"nfloor"},
        LFloors = {"lfloor"},
        Corners = {"corner"}
    }, 

    backdrop_prefix = "gfx/backdrop/"..stage_prefix.."lucpalace_", 
    backdrop_suffix = ".png",

    grids = {
        {gfx = "gfx/grid/"..stage_prefix.."spikes.png", type=GridEntityType.GRID_SPIKES},
        {gfx = "gfx/grid/"..stage_prefix.."spikes.png", type=GridEntityType.GRID_SPIKES_ONOFF},
    },

    doors = {
        {graphic="gfx/grid/"..stage_prefix.."doors/normal_.png", req=StageAPI.DefaultDoorSpawn},
        {graphic="gfx/grid/"..stage_prefix.."doors/devil.png", req={RequireEither = {RoomType.ROOM_DEVIL}}},
        {graphic="gfx/grid/"..stage_prefix.."doors/angel.png", req={RequireEither = {RoomType.ROOM_ANGEL}}},
        {graphic="gfx/grid/"..stage_prefix.."doors/treasure.png", req={RequireEither = {RoomType.ROOM_TREASURE}}},
        {graphic="gfx/grid/"..stage_prefix.."doors/boss.png", req={RequireEither = {RoomType.ROOM_BOSS}}},
        {graphic="gfx/grid/"..stage_prefix.."doors/arcade.png", req={RequireEither = {RoomType.ROOM_ARCADE}}},
        {graphic="gfx/grid/"..stage_prefix.."doors/sacrifice.png", req={RequireEither = {RoomType.ROOM_SACRIFICE}}},
        {graphic="gfx/grid/"..stage_prefix.."doors/ambush.png", req={RequireEither = {RoomType.ROOM_CHALLENGE}}},
    }
}

stage.graphics = default_graphics

stage.deterioration_levels = {
    {
        friendly_name = "Regular",

        graphics = default_graphics
    },
    {
        friendly_name = "Cracked",

        graphics = {
            rocks = "gfx/grid/"..stage_prefix.."rocks.png",
            pits = "gfx/grid/"..stage_prefix.."pits.png",
            alt_pits = "gfx/grid/"..stage_prefix.."pits.png",
            bridge = "gfx/grid/"..stage_prefix.."bridge.png",
            shading = "gfx/backdrop/luc/shading/shading",
            player_spot = "gfx/ui/stage/"..stage_prefix.."boss_spot.png",
            boss_spot = "gfx/ui/stage/"..stage_prefix.."player_spot.png",

            backdrop_gfx = {
                Walls = {"1","2","3"},
                NFloors = {"nfloor"},
                LFloors = {"lfloor"},
                Corners = {"corner"}
            }, 

            backdrop_prefix = "gfx/backdrop/"..stage_prefix.."lucpalacecrack_", 
            backdrop_suffix = ".png",

            grids = {
                {gfx = "gfx/grid/"..stage_prefix.."spikes.png", type=GridEntityType.GRID_SPIKES},
                {gfx = "gfx/grid/"..stage_prefix.."spikes.png", type=GridEntityType.GRID_SPIKES_ONOFF},
            },

            doors = {
                {graphic="gfx/grid/"..stage_prefix.."doors/normal_crack.png", req=StageAPI.DefaultDoorSpawn},
                {graphic="gfx/grid/"..stage_prefix.."doors/devil.png", req={RequireEither = {RoomType.ROOM_DEVIL}}},
                {graphic="gfx/grid/"..stage_prefix.."doors/angel.png", req={RequireEither = {RoomType.ROOM_ANGEL}}},
                {graphic="gfx/grid/"..stage_prefix.."doors/treasure.png", req={RequireEither = {RoomType.ROOM_TREASURE}}},
                {graphic="gfx/grid/"..stage_prefix.."doors/boss.png", req={RequireEither = {RoomType.ROOM_BOSS}}},
                {graphic="gfx/grid/"..stage_prefix.."doors/arcade.png", req={RequireEither = {RoomType.ROOM_ARCADE}}},
                {graphic="gfx/grid/"..stage_prefix.."doors/sacrifice.png", req={RequireEither = {RoomType.ROOM_SACRIFICE}}},
                {graphic="gfx/grid/"..stage_prefix.."doors/ambush.png", req={RequireEither = {RoomType.ROOM_CHALLENGE}}},
            }
        }
    },
    {
        friendly_name = "Bloodied",

        graphics = {
            rocks = "gfx/grid/"..stage_prefix.."rocks.png",
            pits = "gfx/grid/"..stage_prefix.."pits.png",
            alt_pits = "gfx/grid/"..stage_prefix.."pits.png",
            bridge = "gfx/grid/"..stage_prefix.."bridge.png",
            shading = "gfx/backdrop/luc/shading/shading",
            player_spot = "gfx/ui/stage/"..stage_prefix.."boss_spot.png",
            boss_spot = "gfx/ui/stage/"..stage_prefix.."player_spot.png",

            backdrop_gfx = {
                Walls = {"1","2","3"},
                NFloors = {"nfloor"},
                LFloors = {"lfloor"},
                Corners = {"corner"}
            }, 

            backdrop_prefix = "gfx/backdrop/"..stage_prefix.."lucpalacecrackblood_", 
            backdrop_suffix = ".png",

            grids = {
                {gfx = "gfx/grid/"..stage_prefix.."spikes.png", type=GridEntityType.GRID_SPIKES},
                {gfx = "gfx/grid/"..stage_prefix.."spikes.png", type=GridEntityType.GRID_SPIKES_ONOFF},
            },

            doors = {
                {graphic="gfx/grid/"..stage_prefix.."doors/normal_crackblood.png", req=StageAPI.DefaultDoorSpawn},
                {graphic="gfx/grid/"..stage_prefix.."doors/devil.png", req={RequireEither = {RoomType.ROOM_DEVIL}}},
                {graphic="gfx/grid/"..stage_prefix.."doors/angel.png", req={RequireEither = {RoomType.ROOM_ANGEL}}},
                {graphic="gfx/grid/"..stage_prefix.."doors/treasure.png", req={RequireEither = {RoomType.ROOM_TREASURE}}},
                {graphic="gfx/grid/"..stage_prefix.."doors/boss.png", req={RequireEither = {RoomType.ROOM_BOSS}}},
                {graphic="gfx/grid/"..stage_prefix.."doors/arcade.png", req={RequireEither = {RoomType.ROOM_ARCADE}}},
                {graphic="gfx/grid/"..stage_prefix.."doors/sacrifice.png", req={RequireEither = {RoomType.ROOM_SACRIFICE}}},
                {graphic="gfx/grid/"..stage_prefix.."doors/ambush.png", req={RequireEither = {RoomType.ROOM_CHALLENGE}}},
            }
        }
    }
}

stage.deterioration = 1

stage.modify_deterioration = function(self,level)
    if level < 1 or level > #self.deterioration_levels then return false else
        local det_old = self.deterioration_levels[self.deterioration]
        local det = self.deterioration_levels[level]
        self.deterioration = level

        --self.graphics.backdrop_prefix = "gfx/backdrop/"..stage_prefix.."lucpalace"..det.prefix.."_"
        self.graphics = det.graphics
        Isaac.DebugString("[GODMODE] Changed deterioration from "..det_old.friendly_name.." to "..det.friendly_name.."!")
        Isaac.ConsoleOutput("[GODMODE] Changed deterioration from "..det_old.friendly_name.." to "..det.friendly_name.."!")
    end
end

stage.get_cur_gfx = function(self)
    return self.deterioration_levels[self.deterioration].graphics
end

stage.rooms = {
    {path="resources.rooms.luc.ivory_rooms",type=RoomType.ROOM_DEFAULT,id="General"},
    {path="resources.rooms.luc.mask_room",type=RoomType.ROOM_SECRET,id="Secret"},
}

-- stage.room_path = "resources/rooms/luc/rooms.lua"
stage.challenge_wave_path = {"resources.rooms.luc.challenge_waves","resources.rooms.luc.boss_challenge_waves"}

stage.bosses = {
    {
        Name="AngelusossaHorseman", --A small nod at my old, weird way of naming things
        Bossname = "gfx/ui/boss/final_name.png",
        Portrait = "gfx/ui/boss/final.png",
        Weight = 1.0,
        Horseman = true,
        Rooms = "resources.rooms.luc.bossroom",
    },
    {
        Name="Angelusossa", --A small nod at my old, weird way of naming things
        Bossname = "gfx/ui/boss/final_name.png",
        Portrait = "gfx/ui/boss/final.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.rooms.luc.bossroom",
    },
}

stage.music = GODMODE.registry.music.a_blackened_light
stage.boss_music = GODMODE.registry.music.experiencing_revelation

stage.override_stage = StageAPI.StageOverride.NecropolisOne

stage.override = {
    Stage = LevelStage.STAGE4_2,
    StageType = StageType.STAGETYPE_ORIGINAL
}

return stage