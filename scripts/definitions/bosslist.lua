local function is_rep_stage()
    return Game():GetLevel():GetStageType() >= StageType.STAGETYPE_REPENTANCE
end

return {
    [Isaac.GetEntityVariantByName("The Ritual")] = {
        portrait="gfx/ui/boss/ritual.png",
        name="gfx/ui/boss/ritual_name.png",
        spot="gfx/ui/boss/bossspot_09_sheol.png",
        roomfile="the_ritual", --scripts/room_overrides/x
        chance = function()
            if Game():GetLevel():GetStage() == LevelStage.STAGE5 and not Game():GetLevel():IsAltStage() then
                return 0.5
            else
                return 0.0
            end
        end,

        stage_api_entry = {
            stage = LevelStage.STAGE5,
            stage_type = StageType.STAGETYPE_ORIGINAL,
            no_stage_two = true,
            weight = 1,
            major_boss = true,
        }
    },
    [Isaac.GetEntityVariantByName("The Sacred Mind")] = {
        portrait="gfx/ui/boss/sacred.png",
        name="gfx/ui/boss/sacred_name.png",
        spot="gfx/ui/boss/bossspot_10_cathedral.png",
        roomfile="the_sacred", --scripts/room_overrides/x
        chance = function()
            if Game():GetLevel():GetStage() == LevelStage.STAGE5 and Game():GetLevel():IsAltStage() then
                return 0.5
            else
                return 0.0
            end
        end,

        stage_api_entry = {
            stage = LevelStage.STAGE5,
            stage_type = StageType.STAGETYPE_WOTL,
            no_stage_two = true,
            weight = 1,
            major_boss = true,
        }

    },
    [Isaac.GetEntityVariantByName("Souleater")] = {
        portrait="gfx/ui/boss/souleater.png",
        name="gfx/ui/boss/souleater_name.png",
        spot="gfx/ui/boss/bossspot_11_darkroom.png",
        roomfile="souleater", --scripts/room_overrides/x
        chance = function()
            if Game():GetLevel():GetStage() == LevelStage.STAGE6 and not Game():GetLevel():IsAltStage() then
                return 0.5
            else
                return 0.0
            end
        end,

        stage_api_entry = {
            stage = LevelStage.STAGE6,
            stage_type = StageType.STAGETYPE_ORIGINAL,
            no_stage_two = true,
            weight = 1,
            major_boss = true,
        }

    },
    [Isaac.GetEntityVariantByName("The Grand Marshall")] = {
        portrait="gfx/ui/boss/grandmarshall.png",
        name="gfx/ui/boss/grandmarshall_name.png",
        spot="gfx/ui/boss/bossspot_12_chest.png",
        roomfile="grand_marshall", --scripts/room_overrides/x
        chance = function()
            if Game():GetLevel():GetStage() == LevelStage.STAGE6 and Game():GetLevel():IsAltStage() then
                return 0.5
            else
                return 0.0
            end
        end,

        stage_api_entry = {
            stage = LevelStage.STAGE6,
            stage_type = StageType.STAGETYPE_WOTL,
            no_stage_two = true,
            weight = 1,
            major_boss = true,
        }
    },
    [Isaac.GetEntityVariantByName("Hostess")] = {
        portrait="gfx/ui/boss/hostess.png",
        name="gfx/ui/boss/hostess_name.png",
        spot="gfx/ui/boss/bossspot_07_womb.png",
        roomfile="hostess", --scripts/room_overrides/x
        chance = function()
            if Game():GetLevel():GetStage() == LevelStage.STAGE4_1 and not is_rep_stage() then
                return 0.1
            else
                return 0.0
            end
        end,

        stage_api_entry = {
            stage = LevelStage.STAGE4_1,
            stage_type = nil,--StageType.STAGETYPE_WOTL,
            no_stage_two = true,
            weight = 1.5,
            major_boss = false,
        }
    },
    [Isaac.GetEntityVariantByName("Bathemo Swarm")] = {
        portrait="gfx/ui/boss/bathemo.png",
        name="gfx/ui/boss/bathemo_name.png",
        spot="gfx/ui/boss/bossspot_04_catacombs.png",
        roomfile="bathemo", --scripts/room_overrides/x
        chance = function()
            if (Game():GetLevel():GetStage() == LevelStage.STAGE2_1 or Game():GetLevel():GetStage() == LevelStage.STAGE2_2) and not is_rep_stage() then
                return 0.1
            else
                return 0.0
            end
        end,

        stage_api_entry = {
            stage = LevelStage.STAGE2_1,
            stage_type = nil,--StageType.STAGETYPE_ORIGINAL,
            no_stage_two = false,
            weight = 1.5,
            major_boss = false,
        }
    },
    [Isaac.GetEntityVariantByName("Ludomaw")] = {
        portrait="gfx/ui/boss/ludomaw.png",
        name="gfx/ui/boss/ludomaw_name.png",
        spot="gfx/ui/boss/bossspot_04_catacombs.png",
        roomfile="ludomaw", --scripts/room_overrides/x
        chance = function()
            if (Game():GetLevel():GetStage() == LevelStage.STAGE3_1) and not is_rep_stage() then
                return 0.1
            else
                return 0.0
            end
        end,

        stage_api_entry = {
            stage = LevelStage.STAGE3_1,
            stage_type = nil,--StageType.STAGETYPE_WOTL,
            no_stage_two = true,
            weight = 1.5,
            major_boss = false,
        }
    },
    [Isaac.GetEntityVariantByName("Bubbly Plum")] = {
        portrait="gfx/ui/boss/bubble_plum.png",
        name="gfx/ui/boss/bubble_plum_name.png",
        spot="gfx/ui/boss/bossspot_01x_downpour.png",
        roomfile="bubble_plum", --scripts/room_overrides/x
        chance = function()
            if Game():GetLevel():GetStage() == LevelStage.STAGE1_1 or Game():GetLevel():GetStage() == LevelStage.STAGE1_2 and is_rep_stage() then
                return 0.1
            else
                return 0.0
            end
        end,

        stage_api_entry = {
            stage = LevelStage.STAGE1_1,
            stage_type = "rep",
            no_stage_two = false,
            weight = 1.5,
            major_boss = false,
        }
    },
    [Isaac.GetEntityVariantByName("Mega Worm")] = {
        portrait="gfx/ui/boss/megaworm.png",
        name="gfx/ui/boss/megaworm_name.png",
        spot="gfx/ui/boss/bossspot.png",
        roomfile="megaworm", --scripts/room_overrides/x
        chance = function()
            if (Game():GetLevel():GetStage() == LevelStage.STAGE1_1 or Game():GetLevel():GetStage() == LevelStage.STAGE1_2) and not is_rep_stage() then
                return 0.1
            else
                return 0.0
            end
        end,

        stage_api_entry = {
            stage = LevelStage.STAGE1_1,
            stage_type = nil,--StageType.STAGETYPE_ORIGINAL,
            no_stage_two = false,
            weight = 1.625,
            major_boss = false,
        }
    },
    [Isaac.GetEntityVariantByName("Blightfly")] = {
        portrait="gfx/ui/boss/blightfly.png",
        name="gfx/ui/boss/blightfly_name.png",
        spot="gfx/ui/boss/bossspot.png",
        roomfile="blightfly", --scripts/room_overrides/x
        chance = function()
            if Game():GetLevel():GetStage() == LevelStage.STAGE4_1 and is_rep_stage() then
                return 0.25
            else
                return 0.0
            end
        end,

        stage_api_entry = {
            stage = LevelStage.STAGE4_1,
            stage_type = "rep",
            no_stage_two = true,
            weight = 1.75,
            major_boss = false,
        }
    },
}
