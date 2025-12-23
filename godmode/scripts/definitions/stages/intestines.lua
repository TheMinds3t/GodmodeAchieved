local stage = {}
local stage_prefix = "intestines/intestines_"

stage.api_id = "Colon"
stage.display_name = "Colon"
stage.simulating_stage = LevelStage.STAGE4_1

stage.graphics = {
	rocks = "godmode/gfx/grid/"..stage_prefix.."rocks.png",
	pits = "godmode/gfx/grid/"..stage_prefix.."pits.png",
	alt_pits = "godmode/gfx/grid/"..stage_prefix.."pits.png",
    bridge = "godmode/gfx/grid/"..stage_prefix.."bridge.png",
	shading = "godmode/gfx/backdrop/base_shading/shading",
	player_spot = "godmode/gfx/ui/stage/"..stage_prefix.."boss_spot.png",
	boss_spot = "godmode/gfx/ui/stage/"..stage_prefix.."player_spot.png",

	backdrop_gfx = {
        Walls = {"1","2","3","4","5"},
        -- Walls = {"6"},
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
stage.challenge_wave_path = {"resources.godmode.rooms.intestines.challenge_waves","resources.godmode.rooms.intestines.boss_challenge_waves"}

stage.bosses = {
    {
        Name="DingDang",
        Bossname = "godmode/gfx/ui/boss/dingdang_name.png",
        Portrait = "godmode/gfx/ui/boss/ding_dang.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.godmode.rooms.intestines.bosses.dingdang",
    },
    {
        Name="Hostess",
        Bossname = "godmode/gfx/ui/boss/hostess_name.png",
        Portrait = "godmode/gfx/ui/boss/hostess.png",
        Weight = 1.5,
        Horseman = false,
        Rooms = "resources.godmode.rooms.intestines.bosses.hostess",
    },
    {
        Name="Brownie",
        Bossname = "gfx/ui/boss/bossname_402.0_brownie.png",
        Portrait = "gfx/ui/boss/portrait_402.0_brownie.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.godmode.rooms.intestines.bosses.brownie",
    },
    {
        Name="BowlPlay",
        Bossname = "godmode/gfx/ui/boss/bowlplay_name.png",
        Portrait = "godmode/gfx/ui/boss/bowlplay.png",
        Weight = 2.0,
        Horseman = false,
        Rooms = "resources.godmode.rooms.intestines.bosses.bowl_play",
    },
    {
        Name="MamaGurdy",
        Bossname = "gfx/ui/boss/bossname_266.0_mamagurdy.png",
        Portrait = "gfx/ui/boss/portrait_266.0_mamagurdy.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.godmode.rooms.intestines.bosses.mamagurdy",
    },
    {
        Name="Teratula",
        Bossname = "godmode/gfx/ui/boss/teratula_name.png",
        Portrait = "godmode/gfx/ui/boss/teratula.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = "resources.godmode.rooms.intestines.bosses.teratula",
    },
    {
        Name="Death",
        Bossname = "gfx/ui/boss/bossname_66.0_death.png",
        Portrait = "gfx/ui/boss/portrait_66.0_death.png",
        Weight = 1.0,
        Horseman = true,
        Rooms = "resources.godmode.rooms.intestines.bosses.death",
    }
}

stage.music = GODMODE.registry.music.pulsations
stage.boss_music = nil

stage.override_stage = StageAPI.StageOverride.UteroOne
stage.next = function(self,stg)
    if GODMODE.util.has_curse(LevelCurse.CURSE_OF_LABYRINTH) then 
        return {
            NormalStage = true,
            Stage = LevelStage.STAGE5,
            StageType = GODMODE.util.random(0,2)
        }    
    else
        return {
            NormalStage = true,
            Stage = LevelStage.STAGE4_2,
            StageType = GODMODE.util.random(0,2)
        }    
    end
end

stage.override = {
    Stage = LevelStage.STAGE4_2,
    StageType = StageType.STAGETYPE_WOTL
}

stage.fly_anim = Sprite()
stage.fly_anim:Load("godmode/gfx/grid/intestines_flies.anm2", true)

stage.fly_timer = 0
stage.beelzebub_toggle = nil
stage.check_beelzebub = function(self)
    stage.beelzebub_toggle = false 

    GODMODE.util.macro_on_players(function(player) if player:HasPlayerForm(PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES) then 
        stage.beelzebub_toggle = true 
    end end)
end
stage.stage_update = function(self)
    if (GODMODE.frame_count or GODMODE.game:GetFrameCount()) % 40 == 0 or stage.beelzebub_toggle == nil then 
        stage:check_beelzebub()
    end

    stage.fly_anim:Update()
    local room = GODMODE.room
    if not room:IsClear() and room:GetType() == RoomType.ROOM_DEFAULT and stage.beelzebub_toggle ~= true then 
        if Isaac.CountEnemies() ~= GODMODE.util.count_enemies(nil, EntityType.ENTITY_ATTACKFLY) then
            stage.fly_timer = stage.fly_timer + 1
            if stage.fly_timer % 120 == 0 and Isaac.CountEnemies() < 5 then
                local room = GODMODE.room
                local tl = room:GetTopLeftPos() + Vector(26,26)
                local tr = Vector(room:GetBottomRightPos().X - 26, room:GetTopLeftPos().Y+26)
                local bl = Vector(room:GetTopLeftPos().X + 26, room:GetBottomRightPos().Y-26)
                local br = room:GetBottomRightPos() + Vector(-26,-26)
                local cs = {tl,tr,bl,br}
                
                local fly = Isaac.Spawn(EntityType.ENTITY_ATTACKFLY,0,0,Vector.Zero,Vector(0,0),nil)
                local corner = fly:GetDropRNG():RandomInt(4)+1
                -- GODMODE.log("corner = "..corner.."! pos = {"..fly.Position.X..","..fly.Position.Y.."}, corner pos = {"..cs[corner].X..","..cs[corner].Y.."}",true)
                fly.Position = cs[corner]
            end
        end
    end
end

local fly_off = Vector(20,-28)
stage.stage_render = function(self)
    if (GODMODE.frame_count or GODMODE.game:GetFrameCount()) % 40 == 0 or stage.beelzebub_toggle == nil then 
        stage:check_beelzebub()
    end
    local room = GODMODE.room
    local corns = {
        room:GetTopLeftPos()+fly_off,
        Vector(room:GetTopLeftPos().X,room:GetBottomRightPos().Y)-Vector(-fly_off.X,fly_off.Y),
        room:GetBottomRightPos()-fly_off,
        Vector(room:GetBottomRightPos().X,room:GetTopLeftPos().Y)+Vector(-fly_off.X,fly_off.Y)
    }

    if not room:IsClear() and not stage.fly_anim:IsPlaying("Loop") and stage.beelzebub_toggle ~= true then
        stage.fly_anim:Play("In",false)
    end

    if stage.fly_anim:IsPlaying("Loop") and stage.fly_anim:IsEventTriggered("Transition") then 
        if room:IsClear() then 
            stage.fly_anim:Play("Out",true)
        end
    end

    if stage.fly_anim:IsFinished("In") and not stage.fly_anim:IsPlaying("Loop") then
        stage.fly_anim:Play("Loop",false)
    end

    for _,pos in ipairs(corns) do 
        stage.fly_anim:Render(Isaac.WorldToScreen(pos), Vector(0,0), Vector(0,0))
    end
end

stage.try_switch = function(self)
    if GODMODE.level:GetStage() == LevelStage.STAGE4_1 then 
        return true
    else
        return false
    end

end

return stage