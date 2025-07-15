local function is_rep_stage()
    return GODMODE.level:GetStageType() >= StageType.STAGETYPE_REPENTANCE
end

return {
    [GODMODE.registry.entities.the_ritual.variant] = {
        portrait="gfx/ui/boss/ritual.png",
        name="gfx/ui/boss/ritual_name.png",
        spot="gfx/ui/boss/bossspot_09_sheol.png",
        roomfile="the_ritual", --scripts/room_overrides/x
        chance = function()
            if GODMODE.level:GetStage() == LevelStage.STAGE5 and not GODMODE.level:IsAltStage() then
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
    [GODMODE.registry.entities.sacred_mind.variant] = {
        portrait="gfx/ui/boss/sacred.png",
        name="gfx/ui/boss/sacred_name.png",
        spot="gfx/ui/boss/bossspot_10_cathedral.png",
        roomfile="the_sacred", --scripts/room_overrides/x
        chance = function()
            if GODMODE.level:GetStage() == LevelStage.STAGE5 and GODMODE.level:IsAltStage() then
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
    [GODMODE.registry.entities.souleater.variant] = {
        portrait="gfx/ui/boss/souleater.png",
        name="gfx/ui/boss/souleater_name.png",
        spot="gfx/ui/boss/bossspot_11_darkroom.png",
        roomfile="souleater", --scripts/room_overrides/x
        chance = function()
            if GODMODE.level:GetStage() == LevelStage.STAGE6 and not GODMODE.level:IsAltStage() then
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
    [GODMODE.registry.entities.grand_marshall.variant] = {
        portrait="gfx/ui/boss/grandmarshall.png",
        name="gfx/ui/boss/grandmarshall_name.png",
        spot="gfx/ui/boss/bossspot_12_chest.png",
        roomfile="grand_marshall", --scripts/room_overrides/x
        chance = function()
            if GODMODE.level:GetStage() == LevelStage.STAGE6 and GODMODE.level:IsAltStage() then
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
    [GODMODE.registry.entities.hostess.variant] = {
        portrait="gfx/ui/boss/hostess.png",
        name="gfx/ui/boss/hostess_name.png",
        spot="gfx/ui/boss/bossspot_07_womb.png",
        roomfile="hostess", --scripts/room_overrides/x
        chance = function()
            if GODMODE.level:GetStage() == LevelStage.STAGE4_1 and not is_rep_stage() then
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
    [GODMODE.registry.entities.bathemo_swarm.variant] = {
        portrait="gfx/ui/boss/bathemo.png",
        name="gfx/ui/boss/bathemo_name.png",
        spot="gfx/ui/boss/bossspot_04_catacombs.png",
        roomfile="bathemo", --scripts/room_overrides/x
        chance = function()
            if (GODMODE.level:GetStage() == LevelStage.STAGE2_1 or GODMODE.level:GetStage() == LevelStage.STAGE2_2) and not is_rep_stage() then
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
    [GODMODE.registry.entities.ludomaw.variant] = {
        portrait="gfx/ui/boss/ludomaw.png",
        name="gfx/ui/boss/ludomaw_name.png",
        spot="gfx/ui/boss/bossspot_04_catacombs.png",
        roomfile="ludomaw", --scripts/room_overrides/x
        chance = function()
            if (GODMODE.level:GetStage() == LevelStage.STAGE3_1) and not is_rep_stage() then
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
    [GODMODE.registry.entities.bubbly_plum.variant] = {
        portrait="gfx/ui/boss/bubble_plum.png",
        name="gfx/ui/boss/bubble_plum_name.png",
        spot="gfx/ui/boss/bossspot_01x_downpour.png",
        roomfile="bubble_plum", --scripts/room_overrides/x
        chance = function()
            if GODMODE.level:GetStage() == LevelStage.STAGE1_1 or GODMODE.level:GetStage() == LevelStage.STAGE1_2 and is_rep_stage() then
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
    [GODMODE.registry.entities.mega_worm.variant] = {
        portrait="gfx/ui/boss/megaworm.png",
        name="gfx/ui/boss/megaworm_name.png",
        spot="gfx/ui/boss/bossspot.png",
        roomfile="megaworm", --scripts/room_overrides/x
        chance = function()
            if (GODMODE.level:GetStage() == LevelStage.STAGE1_1 or GODMODE.level:GetStage() == LevelStage.STAGE1_2) and not is_rep_stage() then
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
    [GODMODE.registry.entities.blightfly.variant] = {
        portrait="gfx/ui/boss/blightfly.png",
        name="gfx/ui/boss/blightfly_name.png",
        spot="gfx/ui/boss/bossspot.png",
        roomfile="blightfly", --scripts/room_overrides/x
        chance = function()
            if GODMODE.level:GetStage() == LevelStage.STAGE4_1 and is_rep_stage() then
                return 0.25
            else
                return 0.0
            end
        end,

        stage_api_entry = {
            stage = LevelStage.STAGE4_1,
            stage_type = "rep",
            no_stage_two = true,
            weight = 1.5,
            major_boss = false,
        }
    },
    [GODMODE.registry.entities.brazier.variant] = {
        portrait="gfx/ui/boss/brazier.png",
        name="gfx/ui/boss/brazier_name.png",
        spot="gfx/ui/boss/bossspot.png",
        roomfile="brazier", --scripts/room_overrides/x
        chance = function()
            if GODMODE.level:GetStage() == LevelStage.STAGE2_1 and is_rep_stage() then
                return 0.25
            else
                return 0.0
            end
        end,

        stage_api_entry = {
            stage = LevelStage.STAGE2_1,
            stage_type = "rep",
            no_stage_two = false,
            weight = 1.3,
            major_boss = false,
        }
    },
}
