local stage = {}
local stage_prefix = "fruit_cellar/cellar_"

stage.api_id = "FruitCellar"
stage.display_name = "Fruit Cellar"
stage.simulating_stage = LevelStage.STAGE1_2

stage.graphics = {
	rocks = "gfx/grid/"..stage_prefix.."rocks.png",
	pits = "gfx/grid/"..stage_prefix.."pits.png",
	alt_pits = "gfx/grid/"..stage_prefix.."pits.png",
	bridge = "gfx/grid/"..stage_prefix.."bridge.png",
	shading = "gfx/backdrop/base_shading/shading",
	player_spot = "gfx/ui/stage/"..stage_prefix.."boss_spot.png",
	boss_spot = "gfx/ui/stage/"..stage_prefix.."player_spot.png",

	backdrop_gfx = {
        Walls = {"1","2", "3", "4", "5"},
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

stage.room_path = "resources.rooms.fruit_cellar.fruitcellar_rooms"

stage.rooms = {
    {path="resources.rooms.fruit_cellar.fruitcellar_rooms",type=RoomType.ROOM_DEFAULT,id="General"},
    {path="resources.rooms.fruit_cellar.secret_exit",type=RoomType.ROOM_SECRET_EXIT,id="SecretExit"},
}


stage.challenge_wave_path = {"resources.rooms.fruit_cellar.challenge_waves","resources.rooms.fruit_cellar.boss_challenge_waves"}

stage.bosses = {
	{
        Name="DukeOfFlies",
        Bossname = "gfx/ui/boss/bossname_67.0_dukeofflies.png",
        Portrait = "gfx/ui/boss/portrait_67.0_dukeofflies.png",
        Weight = 1,
        Horseman = false,
        Rooms = "resources.rooms.fruit_cellar.bosses.dukeofflies",
    },
	{
        Name="Dingle",
        Bossname = "gfx/ui/boss/bossname_261.0_dingle.png",
        Portrait = "gfx/ui/boss/portrait_261.0_dingle.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.rooms.fruit_cellar.bosses.dingle",
    },
	{
        Name="Little Horn",
        Bossname = "gfx/ui/boss/bossname_404.0_littlehorn.png",
        Portrait = "gfx/ui/boss/portrait_404.0_littlehorn.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.rooms.fruit_cellar.bosses.littlehorn",
    },
	{
        Name="Widow",
        Bossname = "gfx/ui/boss/bossname_100.0_widow.png",
        Portrait = "gfx/ui/boss/portrait_100.0_widow.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.rooms.fruit_cellar.bosses.widow",
    },
	{
        Name="Monstro",
        Bossname = "gfx/ui/boss/bossname_20.0_monstro.png",
        Portrait = "gfx/ui/boss/portrait_20.0_monstro.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.rooms.fruit_cellar.bosses.monstro",
    },
	{
        Name="Pin",
        Bossname = "gfx/ui/boss/bossname_62.0_pin.png",
        Portrait = "gfx/ui/boss/portrait_62.0_pin.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.rooms.fruit_cellar.bosses.pin",
    },
    {
        Name="Megaworm",
        Bossname = "gfx/ui/boss/megaworm_name.png",
        Portrait = "gfx/ui/boss/megaworm.png",
        Weight = 1.5,
        Horseman = false,
        Rooms = "resources.rooms.fruit_cellar.bosses.megaworm",
    },
    {
        Name="Famine",
        Bossname = "gfx/ui/boss/bossname_63.0_famine.png",
        Portrait = "gfx/ui/boss/portrait_63.0_famine.png",
        Weight = 1.0,
        Horseman = true,
        Rooms = "resources.rooms.fruit_cellar.bosses.famine",
    },
    {
        Name="BulgeBat",
        Bossname = "gfx/ui/boss/bulgebat_name.png",
        Portrait = "gfx/ui/boss/bulgebat.png",
        Weight = 2.0,
        Horseman = false,
        Rooms = "resources.rooms.fruit_cellar.bosses.bulgebat",
    },
}

stage.music = GODMODE.registry.music.peripheral_visions
stage.boss_music = nil

stage.next = function(self,stg)
    return {
        NormalStage = true,
        Stage = LevelStage.STAGE2_1,
        StageType = GODMODE.util.random(0,2)
    }    
end

stage.secret_next = function(self, stg)
    if GODMODE.util.has_curse(LevelCurse.CURSE_OF_LABYRINTH) then 
        return {
            NormalStage = true,
            Stage = LevelStage.STAGE1_2,
            StageType = StageType.STAGETYPE_REPENTANCE + GODMODE.util.random(0,2)
        }    
    else
        return {
            NormalStage = true,
            Stage = LevelStage.STAGE1_2,
            StageType = StageType.STAGETYPE_REPENTANCE + GODMODE.util.random(0,2)
        }    
    end
end

stage.try_switch = function(self)
    if GODMODE.level:GetStage() == LevelStage.STAGE1_2 then 
        return true
    else
        return false
    end
end

stage.override_stage = StageAPI.StageOverride.CatacombsOne
stage.override = {
    Stage = LevelStage.STAGE1_2,
    StageType = StageType.STAGETYPE_WOTL
}

return stage