-- a helper class to override rooms on a single room basis. 

local ro = {}
ro.overrides = {}
local gridid_to_gridtype = {
    [1000]=GridEntityType.GRID_ROCK,
    [1001]=GridEntityType.GRID_ROCK_BOMB,
    [1002]=GridEntityType.GRID_ROCK_ALT,
    [1300]=GridEntityType.GRID_TNT,
    [3000]=GridEntityType.GRID_PIT,
    [1500]=GridEntityType.GRID_POOP,
    [1930]=GridEntityType.GRID_SPIKES,
    [1931]=GridEntityType.GRID_SPIKES_ONOFF,
    [1940]=GridEntityType.GRID_SPIDERWEB,
    [4000]=GridEntityType.GRID_LOCK,
    [4500]=GridEntityType.GRID_PRESSURE_PLATE,
    [9000]=GridEntityType.GRID_TRAPDOOR,
    [9100]=GridEntityType.GRID_STAIRS,
    [10000]=GridEntityType.GRID_GRAVITY,
}

--clears loaded overrides
ro.wipe_overrides = function()
    ro.overrides = {}
end

--use with set_override
ro.load_override_room = function(file,room_index,override_room)
    file = "scripts.room_overrides."..file
    room_index = room_index or -1
    
    if not GODMODE.loaded_rooms[file] then
        error("Missing reference for file \'"..file.."\'")
        return nil
    else
        local index = room_index
        if room_index == -1 then 
            if #GODMODE.loaded_rooms[file] == 1 then 
                index = 1 
            elseif override_room ~= nil then
                local room = Game():GetLevel():GetRoomByIdx(override_room)
                local tries = 50
                --fit the room, if possible
                while index == -1 or GODMODE.loaded_rooms[file][index]["SHAPE"] ~= room.Data.Shape and tries > 0 do
                    index = GODMODE.util.random(1,#GODMODE.loaded_rooms[file]) 
                    tries = tries - 1
                end
            else
                index = GODMODE.util.random(1,#GODMODE.loaded_rooms[file]) 
            end
        end
        return {file=file, room=GODMODE.loaded_rooms[file][index]}
    end
end

ro.set_override = function(gridindex, override_room, chance)
    ro.overrides[gridindex] = {file=override_room.file,override=override_room.room,chance=chance}
end

--called on entering each room
ro.try_override_room = function(gridindex)
    if StageAPI then return end 

    local override = ro.overrides[gridindex]
    GODMODE.log("Trying to override room..", true)

    if override ~= nil and GODMODE.util.random() < override.chance and not Game():GetRoom():IsClear() then
        local room = Game():GetRoom()
        GODMODE.log("Overriding current room! Override room file is \'"..override.file.."\', variant is "..override.override["VARIANT"], true)
        override.chance = 1 --guarantees the override for re-entering a room and such
        override = override.override

        if room:GetRoomShape() ~= override["SHAPE"] then
            return
        end

        --remove entities
        for _,ent in ipairs(Isaac.GetRoomEntities()) do 
            if ent.Type > 3 then
                ent:Remove()
            end
        end

        --remove grid
        -- for y = 1, room:GetGridHeight() - 1 do
        --     for x = 1, room:GetGridWidth() - 1 do
        --         local ind = y * room:GetGridWidth() + x
        --         room:RemoveGridEntity(ind,0,false)
        --         room:DestroyGrid(ind, true)
        --     end
        -- end

        for i = 0, room:GetGridSize() do
            local grid = room:GetGridEntity(i)
            if grid then
                local gridtype = grid.Desc.Type
                if gridtype ~= GridEntityType.GRID_WALL and gridtype ~= GridEntityType.GRID_DOOR and gridtype ~= GridEntityType.GRID_DECORATION then 
                    room:RemoveGridEntity(i,0,false)
                end
            end
        end

        -- for x = 1, room:GetGridWidth() - 1 do
        --     for y = 1, room:GetGridHeight() - 1 do
        --         local grid_id = room:GetGridIndex(Vector((x * 52),(y * 52)))
        --         local grident = room:GetGridEntity(grid_id)
        --         if grident then
        --             local gridtype = grident:GetType()
        --             if gridtype ~= GridEntityType.GRID_WALL and gridtype ~= GridEntityType.GRID_DOOR and gridtype ~= GridEntityType.GRID_DECORATION then 
        --                 room:RemoveGridEntity(grid_id,0,false)
        --                 Isaac.DebugString("Grid cleared.")    
        --             end
        --         end
        --     end
        -- end

        --add entities
        for _,comp in pairs(override) do
            if type(comp) == "table" then
                -- local grid_id = room:GetGridIndex(Vector(( * 10 * 4),(comp["GRIDY"] * 10 * 4)))
                local pos = room:GetGridPosition(comp["GRIDX"]+1 + (comp["GRIDY"]+1) * room:GetGridWidth())

                if comp["ISDOOR"] ~= true then
                    local entries = {}
                    --find array entry
                    for _,comp2 in pairs(comp) do
                        if type(comp2) == "table" then
                            local entry = comp2
                            --entities
                            if entry["TYPE"] < 1000 then
                                if entry["TYPE"] == 999 then entry["TYPE"] = 1000 end
                                table.insert(entries, {"ent", entry["TYPE"],entry["VARIANT"],entry["SUBTYPE"]})
                            elseif gridid_to_gridtype[entry["TYPE"]] ~= nil then --grid
                                table.insert(entries, {"grid",gridid_to_gridtype[entry["TYPE"]],entry["VARIANT"]})
                            else
                                GODMODE.log("Grid type "..entry["TYPE"].." not implemented, not spawning", true)
                            end
                        end
                    end    

                    if #entries > 0 then
                        local selected = 1
                        if #entries > 1 then
                            selected = GODMODE.util.random(1,#entries)
                        end

                        if entries[selected][1] == "ent" then --entity!
                            --GODMODE.log("adding type "..entries[selected][2].." to override!", true)
                            Isaac.Spawn(entries[selected][2],entries[selected][3],entries[selected][4],pos,Vector.Zero,nil)
                        elseif entries[selected][1] == "grid" then --grid!
                            --GODMODE.log("adding grid "..entries[selected][2].." to override!", true)
                            local grid = Isaac.GridSpawn(entries[selected][2],entries[selected][3],pos,true)
                            if grid then
                                grid:Init(Isaac.GetPlayer().InitSeed)
                                grid:PostInit()
                            end
                        end
                    end
                end
            end
        end

        return true
    end
end

return ro