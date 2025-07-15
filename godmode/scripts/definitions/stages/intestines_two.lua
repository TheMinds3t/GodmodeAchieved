local stage = include("stages/intestines")
stage.api_id = "IntestinesII"
stage.display_name = "Colon II"

stage.override = function(self,stg)
	return {
	    OverrideStage = LevelStage.STAGE4_2,
	    OverrideStageType = StageType.STAGETYPE_ORIGINAL,
	    ReplaceWith = stg
	}
end

stage.next = function(self)
    return LevelStage.UteroTwo
end

stage.boss_room_path = "resources/rooms/intestines/it_breathes_fight.lua"

stage.bosses = {
	{
        Name="ItBreathes",
        Bossname = "gfx/ui/boss/bossname_it_breathes.png",
        Portrait = "gfx/ui/boss/portrait_it_breathes.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = nil,
    }
}

local old_update = stage.stage_update

stage.stage_update = function(self)
	old_update(self)
end


return stage