local stage = include("stages/nest")
stage.api_id = "TheNestII"
stage.display_name = "The Nest II"

stage.override = function(self,stg)
	return {
	    OverrideStage = LevelStage.STAGE3_2,
	    OverrideStageType = StageType.STAGETYPE_ORIGINAL,
	    ReplaceWith = stg
	}
end

stage.next = function(self)
    return LevelStage.UteroOne
end

stage.boss_room_path = "resources/rooms/nest/mom_fight.lua"

stage.bosses = {
	{
        Name="Mom",
        Bossname = "gfx/ui/boss/bossname_45.0_mom.png",
        Portrait = "gfx/ui/boss/portrait_45.0_mom.png",
        Weight = 1.0,
        Horseman = false,
        Rooms = nil,
    }
}

stage.stage_update = function(self)
	
end


return stage