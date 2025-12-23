local stage = {}
local stage_prefix = "nest/nest_"

stage.api_id = "TheNest"
stage.display_name = "The Nest"
stage.simulating_stage = LevelStage.STAGE3_1

stage.graphics = {
	rocks = "godmode/gfx/grid/"..stage_prefix.."rocks.png",
	pits = "godmode/gfx/grid/"..stage_prefix.."pits.png",
	alt_pits = "godmode/gfx/grid/"..stage_prefix.."pits.png",
    bridge = "godmode/gfx/grid/"..stage_prefix.."bridge.png",
	shading = "godmode/gfx/backdrop/base_shading/shading",
	player_spot = "godmode/gfx/ui/stage/"..stage_prefix.."boss_spot.png",
	boss_spot = "godmode/gfx/ui/stage/"..stage_prefix.."player_spot.png",

	backdrop_gfx = {
        Walls = {"1","2","3","4","5","6"},
        NFloors = {"nfloor"},
        LFloors = {"lfloor"},
        Corners = {"corner"}
    }, 

    backdrop_prefix = "godmode/gfx/backdrop/"..stage_prefix, 
    backdrop_suffix = ".png",

    doors = {
        {graphic="godmode/gfx/grid/"..stage_prefix.."doors/normal.png", req=GODMODE.util.base_room_door},
        {graphic="gfx/grid/door_00_shopdoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_SHOP}}},
        {graphic="gfx/grid/door_00_shopdoor.png", req={RequireCurrent = {RoomType.ROOM_SHOP},RequireTarget = {RoomType.ROOM_DEFAULT}}},
        {graphic="gfx/grid/door_13_librarydoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_LIBRARY}}},
        {graphic="gfx/grid/door_13_librarydoor.png", req={RequireCurrent = {RoomType.ROOM_LIBRARY},RequireTarget = {RoomType.ROOM_DEFAULT}}},
        {graphic="gfx/grid/door_04_selfsacrificeroomdoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_SACRIFICE}}},
        {graphic="gfx/grid/door_04_selfsacrificeroomdoor.png", req={RequireCurrent = {RoomType.ROOM_SACRIFICE},RequireTarget = {RoomType.ROOM_DEFAULT}}},
        {graphic="gfx/grid/door_02b_chestroomdoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_CHEST}}},
        {graphic="gfx/grid/door_02b_chestroomdoor.png", req={RequireCurrent = {RoomType.ROOM_CHEST},RequireTarget = {RoomType.ROOM_DEFAULT}}},
        {graphic="gfx/grid/door_05_arcaderoomdoor.png", req={RequireCurrent = {RoomType.ROOM_ARCADE},RequireTarget = {RoomType.ROOM_DEFAULT}}},
        {graphic="gfx/grid/door_05_arcaderoomdoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_ARCADE}}},
        {graphic="gfx/grid/door_00x_planetariumdoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_PLANETARIUM}}},
        {graphic="gfx/grid/door_00x_planetariumdoor.png", req={RequireCurrent = {RoomType.ROOM_PLANETARIUM},RequireTarget = {RoomType.ROOM_DEFAULT}}},
        {graphic="gfx/grid/door_00_diceroomdoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_DICE}}},
        {graphic="gfx/grid/door_00_diceroomdoor.png", req={RequireCurrent = {RoomType.ROOM_DICE},RequireTarget = {RoomType.ROOM_DEFAULT}}},
        {graphic="gfx/grid/door_03_ambushroomdoor.png", req={RequireCurrent = {RoomType.ROOM_CHALLENGE},RequireTarget = {RoomType.ROOM_DEFAULT}}},
        {graphic="gfx/grid/door_03_ambushroomdoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_CHALLENGE}}},
    }
}

stage.room_path = "resources/godmode/rooms/"..stage_prefix.."rooms.lua"
stage.challenge_wave_path = {"resources.godmode.rooms.nest.challenge_waves","resources.godmode.rooms.nest.boss_challenge_waves"}

stage.bosses = {
	{
        Name="Wretched",
        Bossname = "gfx/ui/boss/bossname_100.1_thewretched.png",
        Portrait = "gfx/ui/boss/portrait_100.1_thewretched.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.godmode.rooms.nest.bosses.wretched",
    },
	{
        Name="Reap Creap",
        Bossname = "gfx/ui/boss/bossname_reapcreep.png",
        Portrait = "gfx/ui/boss/portrait_900.0_reapcreep.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.godmode.rooms.nest.bosses.reapcreep",
    },
	{
        Name="Widow",
        Bossname = "gfx/ui/boss/bossname_100.0_widow.png",
        Portrait = "gfx/ui/boss/portrait_100.0_widow.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.godmode.rooms.nest.bosses.widow",
    },
	{
        Name="Teratoma",
        Bossname = "gfx/ui/boss/bossname_71.1_teratoma.png",
        Portrait = "gfx/ui/boss/portrait_71.1_teratoma.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.godmode.rooms.nest.bosses.teratoma",
    },
    {
        Name="Outbreak",
        Bossname = "godmode/gfx/ui/boss/outbreak_name.png",
        Portrait = "godmode/gfx/ui/boss/outbreak.png",
        Weight = 2.0,
        Horseman = false,
        Rooms = "resources.godmode.rooms.nest.bosses.outbreak",
    },
    {
        Name="War",
        Bossname = "gfx/ui/boss/bossname_65.0_war.png",
        Portrait = "gfx/ui/boss/portrait_65.0_war.png",
        Weight = 1.0,
        Horseman = true,
        Rooms = "resources.godmode.rooms.nest.bosses.war",
    }
}

stage.music = GODMODE.registry.music.shellstepping
stage.boss_music = nil

stage.next = function(self,stg)
    if GODMODE.util.has_curse(LevelCurse.CURSE_OF_LABYRINTH) then 
        return {
            NormalStage = true,
            Stage = LevelStage.STAGE4_1,
            StageType = GODMODE.util.random(0,2)
        }    
    else
        return {
            NormalStage = true,
            Stage = LevelStage.STAGE3_2,
            StageType = GODMODE.util.random(0,2)
        }    
    end
end

stage.override_stage = StageAPI.StageOverride.NecropolisOne

stage.override = {
    Stage = LevelStage.STAGE3_1,
    StageType = StageType.STAGETYPE_ORIGINAL
}

stage.stage_update = function(self)

end

stage.try_switch = function(self)
    if GODMODE.level:GetStage() == LevelStage.STAGE3_1 then 
        return true
    else
        return false
    end
end


return stage