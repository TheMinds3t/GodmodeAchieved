local stage = {}
local stage_prefix = "nest/nest_"

stage.api_id = "TheNest"
stage.display_name = "The Nest"
stage.simulating_stage = LevelStage.STAGE3_1

stage.graphics = {
	rocks = "gfx/grid/"..stage_prefix.."rocks.png",
	pits = "gfx/grid/"..stage_prefix.."pits.png",
	alt_pits = "gfx/grid/"..stage_prefix.."pits.png",
    bridge = "gfx/grid/"..stage_prefix.."bridge.png",
	shading = "gfx/backdrop/base_shading/shading",
	player_spot = "gfx/ui/stage/"..stage_prefix.."boss_spot.png",
	boss_spot = "gfx/ui/stage/"..stage_prefix.."player_spot.png",

	backdrop_gfx = {
        Walls = {"1","2","3","4","5","6"},
        NFloors = {"nfloor"},
        LFloors = {"lfloor"},
        Corners = {"corner"}
    }, 

    backdrop_prefix = "gfx/backdrop/"..stage_prefix, 
    backdrop_suffix = ".png",

    doors = {
        {graphic="gfx/grid/"..stage_prefix.."doors/normal.png", req=GODMODE.util.base_room_door},
        {graphic="gfx/grid/basedoors/door_00_shopdoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_SHOP}}},
        {graphic="gfx/grid/basedoors/door_05_arcaderoomdoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_ARCADE}}},
        {graphic="gfx/grid/basedoors/door_13_librarydoor.png", req={RequireCurrent = {RoomType.ROOM_DEFAULT},RequireTarget = {RoomType.ROOM_LIBRARY}}},
    }
}

stage.room_path = "resources/rooms/"..stage_prefix.."rooms.lua"
stage.challenge_wave_path = {"resources.rooms.nest.challenge_waves","resources.rooms.nest.boss_challenge_waves"}

stage.bosses = {
	{
        Name="Wretched",
        Bossname = "gfx/ui/boss/bossname_100.1_thewretched.png",
        Portrait = "gfx/ui/boss/portrait_100.1_thewretched.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.rooms.nest.bosses.wretched",
    },
	{
        Name="Reap Creap",
        Bossname = "gfx/ui/boss/bossname_reapcreep.png",
        Portrait = "gfx/ui/boss/portrait_900.0_reapcreep.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.rooms.nest.bosses.reapcreep",
    },
	{
        Name="Widow",
        Bossname = "gfx/ui/boss/bossname_100.0_widow.png",
        Portrait = "gfx/ui/boss/portrait_100.0_widow.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.rooms.nest.bosses.widow",
    },
	{
        Name="Teratoma",
        Bossname = "gfx/ui/boss/bossname_71.1_teratoma.png",
        Portrait = "gfx/ui/boss/portrait_71.1_teratoma.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.rooms.nest.bosses.teratoma",
    },
    {
        Name="Outbreak",
        Bossname = "gfx/ui/boss/outbreak_name.png",
        Portrait = "gfx/ui/boss/outbreak.png",
        Weight = 2.0,
        Horseman = false,
        Rooms = "resources.rooms.nest.bosses.outbreak",
    },
    {
        Name="War",
        Bossname = "gfx/ui/boss/bossname_65.0_war.png",
        Portrait = "gfx/ui/boss/portrait_65.0_war.png",
        Weight = 1.0,
        Horseman = true,
        Rooms = "resources.rooms.nest.bosses.war",
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