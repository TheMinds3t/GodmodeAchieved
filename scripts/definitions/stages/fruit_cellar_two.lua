local stage = include("scripts.definitions.stages.fruit_cellar")
stage.api_id = "FruitCellarII"
stage.display_name = "Fruit Cellar II"
stage.simulating_stage = LevelStage.STAGE1_2
stage.second = "FruitCellar"

stage.override = function(self,stg)
    return {
        OverrideStage = LevelStage.STAGE1_2,
        OverrideStageType = StageType.STAGETYPE_ORIGINAL,
        ReplaceWith = stg
    }
end

stage.next = function(self,stg)
    local spots = {
        {
            NormalStage = true,
            Stage = LevelStage.STAGE2_1
        },
        --[[{
           Stage=GODMODE.stages["FruitCellarII"].stage 
        },]]
    }
    return spots[math.random(1,#spots)]
end
return stage